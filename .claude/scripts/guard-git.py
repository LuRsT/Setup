#!/usr/bin/env python3
# PreToolUse(Bash) guard: Gil drives pushing himself.
#
# Blocks push, except a plain push in a repo that opted in with
# `git config claude.allowPush true`. Force pushes are blocked everywhere. Local
# history rewrites (rebase / reset / cherry-pick / commit --amend) are allowed —
# Gil delegates those to Claude on purpose and reviews the result before he
# pushes. Fails OPEN when the hook input can't be read, so it can never wedge real
# work, but the opt-in fails CLOSED: a push whose repo can't be worked out with
# certainty is blocked.
from __future__ import annotations

import json
import os
import re
import shlex
import subprocess
import sys
from dataclasses import dataclass

PUSH_BLOCKED_MESSAGE = (
    "Blocked by guard-git: `git push` — Gil drives pushing himself. "
    "Don't run it; tell him the exact command to run.\n"
)
FORCE_PUSH_BLOCKED_MESSAGE = (
    "Blocked by guard-git: force-pushing is never allowed, not even in a repo "
    "with claude.allowPush set. Don't run it; tell Gil the exact command to run.\n"
)
# git global flags that take a separate-word value (so we skip that value when
# hunting for the real subcommand): `git -C /path push`, `git -c k=v push`, ...
VALUE_FLAGS = {"-C", "-c", "--git-dir", "--work-tree", "--namespace",
               "--super-prefix", "--exec-path"}
# git accepts any unambiguous prefix of a long option, so `--force-w` is a force.
FORCE_LONG_OPTIONS = ("force", "force-with-lease", "force-if-includes", "mirror")
DIRECTORY_CHANGING_WORDS = {"cd", "pushd", "popd"}
SHELL_SEPARATOR_PATTERN = re.compile(r"[|;&\n]+")
HOME_VARIABLE_PATTERN = re.compile(r"\$(HOME\b|\{HOME\})")
UNEXPANDED_SHELL_CHARACTERS = set("~$`*?[{")
GIT_CONFIG_TIMEOUT_SECONDS = 5


@dataclass(frozen=True)
class ShellCommand:
    text: str
    separator_after: str


@dataclass(frozen=True)
class GitInvocation:
    is_first_word: bool
    directory_options: tuple[str, ...]
    has_other_global_options: bool
    subcommand: str
    arguments: tuple[str, ...]


@dataclass(frozen=True)
class GitPush:
    # None when the repo the push runs in can't be worked out with certainty.
    repository_directory: str | None
    is_force: bool


def split_into_shell_commands(command: str) -> list[ShellCommand]:
    shell_commands = []
    position = 0
    for separator_match in SHELL_SEPARATOR_PATTERN.finditer(command):
        text = command[position:separator_match.start()]
        shell_commands.append(ShellCommand(text, separator_match.group()))
        position = separator_match.end()
    shell_commands.append(ShellCommand(command[position:], ""))
    return shell_commands


def parse_git_invocation(words: list[str]) -> GitInvocation | None:
    git_index = None
    for index, word in enumerate(words):
        if word == "git" or word.endswith("/git"):
            git_index = index
            break
    if git_index is None:
        return None

    directory_options = []
    has_other_global_options = False
    index = git_index + 1
    while index < len(words) and words[index].startswith("-"):
        option = words[index]
        index += 1
        if option == "-C" and index < len(words):
            directory_options.append(words[index])
            index += 1
            continue
        has_other_global_options = True
        if option in VALUE_FLAGS:
            index += 1
    if len(words) <= index:
        return None

    return GitInvocation(
        is_first_word=git_index == 0,
        directory_options=tuple(directory_options),
        has_other_global_options=has_other_global_options,
        subcommand=words[index],
        arguments=tuple(words[index + 1:]),
    )


def is_force_long_option(argument: str) -> bool:
    option = argument.removeprefix("--")
    option_name = option.partition("=")[0]
    if option_name == "":
        return False
    for force_option in FORCE_LONG_OPTIONS:
        if force_option.startswith(option_name):
            return True
    return False


def is_force_push(push_arguments: tuple[str, ...]) -> bool:
    for argument in push_arguments:
        if argument.startswith("+"):
            return True
        if argument.startswith("--"):
            if is_force_long_option(argument):
                return True
            continue
        is_short_options = argument.startswith("-")
        if is_short_options and "f" in argument:
            return True
    return False


def expand_path(path: str) -> str | None:
    # shlex leaves expansion to the shell. Only ~ and $HOME are expanded here,
    # because any other variable may hold something else in Claude's shell than
    # in this hook's environment.
    home_directory = os.path.expanduser("~")
    # A function replacement keeps any backslash in the home path literal.
    path_with_home = HOME_VARIABLE_PATTERN.sub(lambda _match: home_directory, path)
    expanded_path = os.path.expanduser(path_with_home)
    if expanded_path == "":
        return None
    for character in expanded_path:
        if character in UNEXPANDED_SHELL_CHARACTERS:
            return None
    return expanded_path


def resolve_repository_directory(git_invocation: GitInvocation, directory: str | None) -> str | None:
    if directory is None:
        return None
    if not git_invocation.is_first_word:
        return None
    if git_invocation.has_other_global_options:
        return None
    resolved_directory = directory
    for directory_option in git_invocation.directory_options:
        expanded_option = expand_path(directory_option)
        if expanded_option is None:
            return None
        resolved_directory = os.path.join(resolved_directory, expanded_option)
    return resolved_directory


def has_directory_change(words: list[str]) -> bool:
    for word in words:
        bare_word = word.lstrip("({$`!")
        if bare_word in DIRECTORY_CHANGING_WORDS:
            return True
    return False


def is_sequential(separator: str) -> bool:
    separator_without_newlines = separator.replace("\n", "")
    return separator_without_newlines in ("", ";", "&&")


def change_directory(directory: str | None, words: list[str], separator_after: str) -> str | None:
    if directory is None:
        return None
    if not has_directory_change(words):
        return directory
    is_plain_cd = len(words) == 2 and words[0] == "cd"
    if not is_plain_cd or not is_sequential(separator_after):
        return None
    target = expand_path(words[1])
    # A relative target is looked up in CDPATH first, which this hook can't see.
    if target is None or not os.path.isabs(target):
        return None
    return os.path.normpath(target)


def find_pushes(command: str, cwd: object) -> list[GitPush]:
    pushes = []
    directory = None
    if isinstance(cwd, str) and os.path.isabs(cwd):
        directory = cwd
    for shell_command in split_into_shell_commands(command):
        try:
            words = shlex.split(shell_command.text)
        except ValueError:
            words = shell_command.text.split()
            # A quoted separator splits a quote across commands, so whatever
            # follows can't be placed in a directory with certainty.
            directory = None
        git_invocation = parse_git_invocation(words)
        if git_invocation is not None and git_invocation.subcommand == "push":
            repository_directory = resolve_repository_directory(git_invocation, directory)
            pushes.append(GitPush(repository_directory, is_force_push(git_invocation.arguments)))
        directory = change_directory(directory, words, shell_command.separator_after)
    return pushes


def is_push_allowed(repository_directory: str | None) -> bool:
    if repository_directory is None:
        return False
    git_config_command = ["git", "-C", repository_directory, "config", "--local",
                          "--type=bool", "--get", "claude.allowPush"]
    try:
        git_config_run = subprocess.run(git_config_command, capture_output=True, text=True,
                                        timeout=GIT_CONFIG_TIMEOUT_SECONDS, check=False)
    except (OSError, subprocess.TimeoutExpired):
        return False
    if git_config_run.returncode != 0:
        return False
    return git_config_run.stdout.strip() == "true"


def main() -> int:
    try:
        hook_input = json.load(sys.stdin)
        command = hook_input.get("tool_input", {}).get("command", "") or ""
        cwd = hook_input.get("cwd")
    except Exception:
        return 0  # fail open

    for push in find_pushes(command, cwd):
        if push.is_force:
            sys.stderr.write(FORCE_PUSH_BLOCKED_MESSAGE)
            return 2
        if not is_push_allowed(push.repository_directory):
            sys.stderr.write(PUSH_BLOCKED_MESSAGE)
            return 2
    return 0


sys.exit(main())
