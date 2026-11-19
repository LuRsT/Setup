#!/usr/bin/env python3
from __future__ import annotations

import json
import os
import subprocess
import tempfile
import unittest
from pathlib import Path

GUARD_SCRIPT = str(Path(__file__).parent / "guard-git.py")

PUSH_BLOCKED_MESSAGE = (
    "Blocked by guard-git: `git push` — Gil drives pushing himself. "
    "Don't run it; tell him the exact command to run.\n"
)
FORCE_PUSH_BLOCKED_MESSAGE = (
    "Blocked by guard-git: force-pushing is never allowed, not even in a repo "
    "with claude.allowPush set. Don't run it; tell Gil the exact command to run.\n"
)

# Keeps the user's own git config, and the GIT_DIR of a surrounding git hook,
# from deciding which repo a test's git commands read.
ISOLATED_ENVIRONMENT = {}
for variable_name, variable_value in os.environ.items():
    if not variable_name.startswith("GIT_"):
        ISOLATED_ENVIRONMENT[variable_name] = variable_value
ISOLATED_ENVIRONMENT["GIT_CONFIG_GLOBAL"] = os.devnull
ISOLATED_ENVIRONMENT["GIT_CONFIG_NOSYSTEM"] = "1"


class GuardGitTest(unittest.TestCase):
    def test_push_in_repository_without_opt_in_is_blocked(self) -> None:
        # Given a repository that has not opted in to pushing
        repository = self.enterContext(tempfile.TemporaryDirectory())
        subprocess.run(["git", "init", "--quiet", repository], check=True, env=ISOLATED_ENVIRONMENT)

        # When Claude runs a push there
        hook_input = json.dumps({"cwd": repository, "tool_input": {"command": "git push origin main"}})
        guard_run = subprocess.run(
            [GUARD_SCRIPT], input=hook_input, capture_output=True, text=True, env=ISOLATED_ENVIRONMENT
        )

        # Then the guard blocks it with the usual message
        self.assertEqual(guard_run.returncode, 2)
        self.assertEqual(guard_run.stderr, PUSH_BLOCKED_MESSAGE)

    def test_push_in_opted_in_repository_is_allowed(self) -> None:
        # Given a repository that has opted in to pushing
        repository = self.enterContext(tempfile.TemporaryDirectory())
        subprocess.run(["git", "init", "--quiet", repository], check=True, env=ISOLATED_ENVIRONMENT)
        subprocess.run(
            ["git", "-C", repository, "config", "claude.allowPush", "true"], check=True, env=ISOLATED_ENVIRONMENT
        )

        # When Claude runs a push there
        hook_input = json.dumps({"cwd": repository, "tool_input": {"command": "git push origin main"}})
        guard_run = subprocess.run(
            [GUARD_SCRIPT], input=hook_input, capture_output=True, text=True, env=ISOLATED_ENVIRONMENT
        )

        # Then the guard lets it through
        self.assertEqual(guard_run.returncode, 0)
        self.assertEqual(guard_run.stderr, "")

    def test_push_in_repository_with_opt_in_set_to_false_is_blocked(self) -> None:
        # Given a repository whose opt-in is explicitly turned off
        repository = self.enterContext(tempfile.TemporaryDirectory())
        subprocess.run(["git", "init", "--quiet", repository], check=True, env=ISOLATED_ENVIRONMENT)
        subprocess.run(
            ["git", "-C", repository, "config", "claude.allowPush", "false"], check=True, env=ISOLATED_ENVIRONMENT
        )

        # When Claude runs a push there
        hook_input = json.dumps({"cwd": repository, "tool_input": {"command": "git push origin main"}})
        guard_run = subprocess.run(
            [GUARD_SCRIPT], input=hook_input, capture_output=True, text=True, env=ISOLATED_ENVIRONMENT
        )

        # Then the guard blocks it
        self.assertEqual(guard_run.returncode, 2)
        self.assertEqual(guard_run.stderr, PUSH_BLOCKED_MESSAGE)

    def test_push_in_repository_with_opt_in_set_to_non_boolean_is_blocked(self) -> None:
        # Given a repository whose opt-in holds something that isn't a boolean
        repository = self.enterContext(tempfile.TemporaryDirectory())
        subprocess.run(["git", "init", "--quiet", repository], check=True, env=ISOLATED_ENVIRONMENT)
        subprocess.run(
            ["git", "-C", repository, "config", "claude.allowPush", "maybe"], check=True, env=ISOLATED_ENVIRONMENT
        )

        # When Claude runs a push there
        hook_input = json.dumps({"cwd": repository, "tool_input": {"command": "git push origin main"}})
        guard_run = subprocess.run(
            [GUARD_SCRIPT], input=hook_input, capture_output=True, text=True, env=ISOLATED_ENVIRONMENT
        )

        # Then the guard blocks it
        self.assertEqual(guard_run.returncode, 2)
        self.assertEqual(guard_run.stderr, PUSH_BLOCKED_MESSAGE)

    def test_push_with_opt_in_only_in_global_config_is_blocked(self) -> None:
        # Given a repository that has not opted in
        repository = self.enterContext(tempfile.TemporaryDirectory())
        subprocess.run(["git", "init", "--quiet", repository], check=True, env=ISOLATED_ENVIRONMENT)

        # Given the user's global git config opts in every repository
        global_config_directory = self.enterContext(tempfile.TemporaryDirectory())
        global_config = os.path.join(global_config_directory, "gitconfig")
        subprocess.run(
            ["git", "config", "--file", global_config, "claude.allowPush", "true"],
            check=True,
            env=ISOLATED_ENVIRONMENT,
        )
        environment_with_global_opt_in = dict(ISOLATED_ENVIRONMENT)
        environment_with_global_opt_in["GIT_CONFIG_GLOBAL"] = global_config

        # When Claude runs a push in the repository
        hook_input = json.dumps({"cwd": repository, "tool_input": {"command": "git push origin main"}})
        guard_run = subprocess.run(
            [GUARD_SCRIPT], input=hook_input, capture_output=True, text=True, env=environment_with_global_opt_in
        )

        # Then the guard blocks it, because the opt-in is per repository
        self.assertEqual(guard_run.returncode, 2)
        self.assertEqual(guard_run.stderr, PUSH_BLOCKED_MESSAGE)

    def test_push_outside_any_repository_is_blocked(self) -> None:
        # Given a directory that isn't a git repository
        directory = self.enterContext(tempfile.TemporaryDirectory())

        # When Claude runs a push there
        hook_input = json.dumps({"cwd": directory, "tool_input": {"command": "git push origin main"}})
        guard_run = subprocess.run(
            [GUARD_SCRIPT], input=hook_input, capture_output=True, text=True, env=ISOLATED_ENVIRONMENT
        )

        # Then the guard blocks it
        self.assertEqual(guard_run.returncode, 2)
        self.assertEqual(guard_run.stderr, PUSH_BLOCKED_MESSAGE)

    def test_push_without_cwd_in_hook_input_is_blocked(self) -> None:
        # Given hook input that doesn't say which directory the command runs in
        hook_input = json.dumps({"tool_input": {"command": "git push origin main"}})

        # When the guard inspects the push
        guard_run = subprocess.run(
            [GUARD_SCRIPT], input=hook_input, capture_output=True, text=True, env=ISOLATED_ENVIRONMENT
        )

        # Then it blocks it
        self.assertEqual(guard_run.returncode, 2)
        self.assertEqual(guard_run.stderr, PUSH_BLOCKED_MESSAGE)

    def test_push_after_another_git_command_in_repository_without_opt_in_is_blocked(self) -> None:
        # Given a repository that has not opted in to pushing
        repository = self.enterContext(tempfile.TemporaryDirectory())
        subprocess.run(["git", "init", "--quiet", repository], check=True, env=ISOLATED_ENVIRONMENT)

        # When Claude runs a push after another git command in the same call
        hook_input = json.dumps({"cwd": repository, "tool_input": {"command": "git log; git push"}})
        guard_run = subprocess.run(
            [GUARD_SCRIPT], input=hook_input, capture_output=True, text=True, env=ISOLATED_ENVIRONMENT
        )

        # Then the guard blocks it
        self.assertEqual(guard_run.returncode, 2)
        self.assertEqual(guard_run.stderr, PUSH_BLOCKED_MESSAGE)

    def test_git_command_other_than_push_in_repository_without_opt_in_is_allowed(self) -> None:
        # Given a repository that has not opted in to pushing
        repository = self.enterContext(tempfile.TemporaryDirectory())
        subprocess.run(["git", "init", "--quiet", repository], check=True, env=ISOLATED_ENVIRONMENT)

        # When Claude runs a git command that doesn't push
        hook_input = json.dumps({"cwd": repository, "tool_input": {"command": "git commit -m 'Add a file'"}})
        guard_run = subprocess.run(
            [GUARD_SCRIPT], input=hook_input, capture_output=True, text=True, env=ISOLATED_ENVIRONMENT
        )

        # Then the guard lets it through
        self.assertEqual(guard_run.returncode, 0)
        self.assertEqual(guard_run.stderr, "")

    def test_unreadable_hook_input_is_allowed(self) -> None:
        # Given hook input that isn't JSON
        hook_input = "git push origin main"

        # When the guard inspects it
        guard_run = subprocess.run(
            [GUARD_SCRIPT], input=hook_input, capture_output=True, text=True, env=ISOLATED_ENVIRONMENT
        )

        # Then it fails open
        self.assertEqual(guard_run.returncode, 0)

    def test_force_push_with_short_flag_in_opted_in_repository_is_blocked(self) -> None:
        # Given a repository that has opted in to pushing
        repository = self.enterContext(tempfile.TemporaryDirectory())
        subprocess.run(["git", "init", "--quiet", repository], check=True, env=ISOLATED_ENVIRONMENT)
        subprocess.run(
            ["git", "-C", repository, "config", "claude.allowPush", "true"], check=True, env=ISOLATED_ENVIRONMENT
        )

        # When Claude force-pushes with -f
        hook_input = json.dumps({"cwd": repository, "tool_input": {"command": "git push -f origin main"}})
        guard_run = subprocess.run(
            [GUARD_SCRIPT], input=hook_input, capture_output=True, text=True, env=ISOLATED_ENVIRONMENT
        )

        # Then the guard blocks it as a force push
        self.assertEqual(guard_run.returncode, 2)
        self.assertEqual(guard_run.stderr, FORCE_PUSH_BLOCKED_MESSAGE)

    def test_force_push_with_short_flag_among_others_in_opted_in_repository_is_blocked(self) -> None:
        # Given a repository that has opted in to pushing
        repository = self.enterContext(tempfile.TemporaryDirectory())
        subprocess.run(["git", "init", "--quiet", repository], check=True, env=ISOLATED_ENVIRONMENT)
        subprocess.run(
            ["git", "-C", repository, "config", "claude.allowPush", "true"], check=True, env=ISOLATED_ENVIRONMENT
        )

        # When Claude force-pushes with -f bundled into -uf
        hook_input = json.dumps({"cwd": repository, "tool_input": {"command": "git push -uf origin main"}})
        guard_run = subprocess.run(
            [GUARD_SCRIPT], input=hook_input, capture_output=True, text=True, env=ISOLATED_ENVIRONMENT
        )

        # Then the guard blocks it as a force push
        self.assertEqual(guard_run.returncode, 2)
        self.assertEqual(guard_run.stderr, FORCE_PUSH_BLOCKED_MESSAGE)

    def test_force_push_with_long_flag_in_opted_in_repository_is_blocked(self) -> None:
        # Given a repository that has opted in to pushing
        repository = self.enterContext(tempfile.TemporaryDirectory())
        subprocess.run(["git", "init", "--quiet", repository], check=True, env=ISOLATED_ENVIRONMENT)
        subprocess.run(
            ["git", "-C", repository, "config", "claude.allowPush", "true"], check=True, env=ISOLATED_ENVIRONMENT
        )

        # When Claude force-pushes with --force
        hook_input = json.dumps({"cwd": repository, "tool_input": {"command": "git push --force origin main"}})
        guard_run = subprocess.run(
            [GUARD_SCRIPT], input=hook_input, capture_output=True, text=True, env=ISOLATED_ENVIRONMENT
        )

        # Then the guard blocks it as a force push
        self.assertEqual(guard_run.returncode, 2)
        self.assertEqual(guard_run.stderr, FORCE_PUSH_BLOCKED_MESSAGE)

    def test_force_push_with_lease_in_opted_in_repository_is_blocked(self) -> None:
        # Given a repository that has opted in to pushing
        repository = self.enterContext(tempfile.TemporaryDirectory())
        subprocess.run(["git", "init", "--quiet", repository], check=True, env=ISOLATED_ENVIRONMENT)
        subprocess.run(
            ["git", "-C", repository, "config", "claude.allowPush", "true"], check=True, env=ISOLATED_ENVIRONMENT
        )

        # When Claude force-pushes with --force-with-lease
        hook_input = json.dumps(
            {"cwd": repository, "tool_input": {"command": "git push --force-with-lease origin main"}}
        )
        guard_run = subprocess.run(
            [GUARD_SCRIPT], input=hook_input, capture_output=True, text=True, env=ISOLATED_ENVIRONMENT
        )

        # Then the guard blocks it as a force push
        self.assertEqual(guard_run.returncode, 2)
        self.assertEqual(guard_run.stderr, FORCE_PUSH_BLOCKED_MESSAGE)

    def test_force_push_with_lease_value_in_opted_in_repository_is_blocked(self) -> None:
        # Given a repository that has opted in to pushing
        repository = self.enterContext(tempfile.TemporaryDirectory())
        subprocess.run(["git", "init", "--quiet", repository], check=True, env=ISOLATED_ENVIRONMENT)
        subprocess.run(
            ["git", "-C", repository, "config", "claude.allowPush", "true"], check=True, env=ISOLATED_ENVIRONMENT
        )

        # When Claude force-pushes with --force-with-lease and an expected value
        hook_input = json.dumps(
            {"cwd": repository, "tool_input": {"command": "git push --force-with-lease=main:abc123 origin main"}}
        )
        guard_run = subprocess.run(
            [GUARD_SCRIPT], input=hook_input, capture_output=True, text=True, env=ISOLATED_ENVIRONMENT
        )

        # Then the guard blocks it as a force push
        self.assertEqual(guard_run.returncode, 2)
        self.assertEqual(guard_run.stderr, FORCE_PUSH_BLOCKED_MESSAGE)

    def test_force_push_with_abbreviated_long_flag_in_opted_in_repository_is_blocked(self) -> None:
        # Given a repository that has opted in to pushing
        repository = self.enterContext(tempfile.TemporaryDirectory())
        subprocess.run(["git", "init", "--quiet", repository], check=True, env=ISOLATED_ENVIRONMENT)
        subprocess.run(
            ["git", "-C", repository, "config", "claude.allowPush", "true"], check=True, env=ISOLATED_ENVIRONMENT
        )

        # When Claude force-pushes with --force-with, which git expands to --force-with-lease
        hook_input = json.dumps({"cwd": repository, "tool_input": {"command": "git push --force-with origin main"}})
        guard_run = subprocess.run(
            [GUARD_SCRIPT], input=hook_input, capture_output=True, text=True, env=ISOLATED_ENVIRONMENT
        )

        # Then the guard blocks it as a force push
        self.assertEqual(guard_run.returncode, 2)
        self.assertEqual(guard_run.stderr, FORCE_PUSH_BLOCKED_MESSAGE)

    def test_force_push_if_includes_in_opted_in_repository_is_blocked(self) -> None:
        # Given a repository that has opted in to pushing
        repository = self.enterContext(tempfile.TemporaryDirectory())
        subprocess.run(["git", "init", "--quiet", repository], check=True, env=ISOLATED_ENVIRONMENT)
        subprocess.run(
            ["git", "-C", repository, "config", "claude.allowPush", "true"], check=True, env=ISOLATED_ENVIRONMENT
        )

        # When Claude pushes with --force-if-includes
        hook_input = json.dumps(
            {"cwd": repository, "tool_input": {"command": "git push --force-if-includes origin main"}}
        )
        guard_run = subprocess.run(
            [GUARD_SCRIPT], input=hook_input, capture_output=True, text=True, env=ISOLATED_ENVIRONMENT
        )

        # Then the guard blocks it as a force push
        self.assertEqual(guard_run.returncode, 2)
        self.assertEqual(guard_run.stderr, FORCE_PUSH_BLOCKED_MESSAGE)

    def test_mirror_push_in_opted_in_repository_is_blocked(self) -> None:
        # Given a repository that has opted in to pushing
        repository = self.enterContext(tempfile.TemporaryDirectory())
        subprocess.run(["git", "init", "--quiet", repository], check=True, env=ISOLATED_ENVIRONMENT)
        subprocess.run(
            ["git", "-C", repository, "config", "claude.allowPush", "true"], check=True, env=ISOLATED_ENVIRONMENT
        )

        # When Claude pushes with --mirror, which overwrites every remote ref
        hook_input = json.dumps({"cwd": repository, "tool_input": {"command": "git push --mirror origin"}})
        guard_run = subprocess.run(
            [GUARD_SCRIPT], input=hook_input, capture_output=True, text=True, env=ISOLATED_ENVIRONMENT
        )

        # Then the guard blocks it as a force push
        self.assertEqual(guard_run.returncode, 2)
        self.assertEqual(guard_run.stderr, FORCE_PUSH_BLOCKED_MESSAGE)

    def test_force_push_with_plus_refspec_in_opted_in_repository_is_blocked(self) -> None:
        # Given a repository that has opted in to pushing
        repository = self.enterContext(tempfile.TemporaryDirectory())
        subprocess.run(["git", "init", "--quiet", repository], check=True, env=ISOLATED_ENVIRONMENT)
        subprocess.run(
            ["git", "-C", repository, "config", "claude.allowPush", "true"], check=True, env=ISOLATED_ENVIRONMENT
        )

        # When Claude force-pushes a single branch with a + refspec
        hook_input = json.dumps({"cwd": repository, "tool_input": {"command": "git push origin +main"}})
        guard_run = subprocess.run(
            [GUARD_SCRIPT], input=hook_input, capture_output=True, text=True, env=ISOLATED_ENVIRONMENT
        )

        # Then the guard blocks it as a force push
        self.assertEqual(guard_run.returncode, 2)
        self.assertEqual(guard_run.stderr, FORCE_PUSH_BLOCKED_MESSAGE)

    def test_force_push_after_plain_push_in_opted_in_repository_is_blocked(self) -> None:
        # Given a repository that has opted in to pushing
        repository = self.enterContext(tempfile.TemporaryDirectory())
        subprocess.run(["git", "init", "--quiet", repository], check=True, env=ISOLATED_ENVIRONMENT)
        subprocess.run(
            ["git", "-C", repository, "config", "claude.allowPush", "true"], check=True, env=ISOLATED_ENVIRONMENT
        )

        # When Claude runs a plain push and then a force push in the same call
        hook_input = json.dumps(
            {"cwd": repository, "tool_input": {"command": "git push origin main && git push --force origin dev"}}
        )
        guard_run = subprocess.run(
            [GUARD_SCRIPT], input=hook_input, capture_output=True, text=True, env=ISOLATED_ENVIRONMENT
        )

        # Then the guard blocks the call as a force push
        self.assertEqual(guard_run.returncode, 2)
        self.assertEqual(guard_run.stderr, FORCE_PUSH_BLOCKED_MESSAGE)

    def test_push_with_directory_option_into_opted_in_repository_is_allowed(self) -> None:
        # Given a repository that has opted in to pushing
        repository = self.enterContext(tempfile.TemporaryDirectory())
        subprocess.run(["git", "init", "--quiet", repository], check=True, env=ISOLATED_ENVIRONMENT)
        subprocess.run(
            ["git", "-C", repository, "config", "claude.allowPush", "true"], check=True, env=ISOLATED_ENVIRONMENT
        )

        # Given Claude's shell sits in a repository that has not opted in
        other_repository = self.enterContext(tempfile.TemporaryDirectory())
        subprocess.run(["git", "init", "--quiet", other_repository], check=True, env=ISOLATED_ENVIRONMENT)

        # When Claude pushes the opted-in repository with -C
        hook_input = json.dumps(
            {"cwd": other_repository, "tool_input": {"command": f"git -C {repository} push origin main"}}
        )
        guard_run = subprocess.run(
            [GUARD_SCRIPT], input=hook_input, capture_output=True, text=True, env=ISOLATED_ENVIRONMENT
        )

        # Then the guard lets it through
        self.assertEqual(guard_run.returncode, 0)
        self.assertEqual(guard_run.stderr, "")

    def test_push_with_relative_directory_option_into_opted_in_repository_is_allowed(self) -> None:
        # Given a repository that has opted in to pushing, inside a parent directory
        parent_directory = self.enterContext(tempfile.TemporaryDirectory())
        repository = os.path.join(parent_directory, "project")
        subprocess.run(["git", "init", "--quiet", repository], check=True, env=ISOLATED_ENVIRONMENT)
        subprocess.run(
            ["git", "-C", repository, "config", "claude.allowPush", "true"], check=True, env=ISOLATED_ENVIRONMENT
        )

        # When Claude, sitting in the parent directory, pushes it with a relative -C
        hook_input = json.dumps(
            {"cwd": parent_directory, "tool_input": {"command": "git -C project push origin main"}}
        )
        guard_run = subprocess.run(
            [GUARD_SCRIPT], input=hook_input, capture_output=True, text=True, env=ISOLATED_ENVIRONMENT
        )

        # Then the guard lets it through
        self.assertEqual(guard_run.returncode, 0)
        self.assertEqual(guard_run.stderr, "")

    def test_push_with_directory_option_under_tilde_into_opted_in_repository_is_allowed(self) -> None:
        # Given a home directory holding a repository that has opted in to pushing
        home_directory = self.enterContext(tempfile.TemporaryDirectory())
        repository = os.path.join(home_directory, "dev", "project")
        subprocess.run(["git", "init", "--quiet", repository], check=True, env=ISOLATED_ENVIRONMENT)
        subprocess.run(
            ["git", "-C", repository, "config", "claude.allowPush", "true"], check=True, env=ISOLATED_ENVIRONMENT
        )
        environment_with_home = dict(ISOLATED_ENVIRONMENT)
        environment_with_home["HOME"] = home_directory

        # Given Claude's shell sits in a directory that isn't a repository
        other_directory = self.enterContext(tempfile.TemporaryDirectory())

        # When Claude pushes the repository with -C and a path under ~
        hook_input = json.dumps(
            {"cwd": other_directory, "tool_input": {"command": "git -C ~/dev/project push origin main"}}
        )
        guard_run = subprocess.run(
            [GUARD_SCRIPT], input=hook_input, capture_output=True, text=True, env=environment_with_home
        )

        # Then the guard lets it through
        self.assertEqual(guard_run.returncode, 0)
        self.assertEqual(guard_run.stderr, "")

    def test_push_with_directory_option_under_home_variable_into_opted_in_repository_is_allowed(self) -> None:
        # Given a home directory holding a repository that has opted in to pushing
        home_directory = self.enterContext(tempfile.TemporaryDirectory())
        repository = os.path.join(home_directory, "dev", "project")
        subprocess.run(["git", "init", "--quiet", repository], check=True, env=ISOLATED_ENVIRONMENT)
        subprocess.run(
            ["git", "-C", repository, "config", "claude.allowPush", "true"], check=True, env=ISOLATED_ENVIRONMENT
        )
        environment_with_home = dict(ISOLATED_ENVIRONMENT)
        environment_with_home["HOME"] = home_directory

        # Given Claude's shell sits in a directory that isn't a repository
        other_directory = self.enterContext(tempfile.TemporaryDirectory())

        # When Claude pushes the repository with -C and a path under $HOME
        hook_input = json.dumps(
            {"cwd": other_directory, "tool_input": {"command": "git -C $HOME/dev/project push origin main"}}
        )
        guard_run = subprocess.run(
            [GUARD_SCRIPT], input=hook_input, capture_output=True, text=True, env=environment_with_home
        )

        # Then the guard lets it through
        self.assertEqual(guard_run.returncode, 0)
        self.assertEqual(guard_run.stderr, "")

    def test_push_with_directory_option_under_braced_home_variable_into_opted_in_repository_is_allowed(
        self,
    ) -> None:
        # Given a home directory holding a repository that has opted in to pushing
        home_directory = self.enterContext(tempfile.TemporaryDirectory())
        repository = os.path.join(home_directory, "dev", "project")
        subprocess.run(["git", "init", "--quiet", repository], check=True, env=ISOLATED_ENVIRONMENT)
        subprocess.run(
            ["git", "-C", repository, "config", "claude.allowPush", "true"], check=True, env=ISOLATED_ENVIRONMENT
        )
        environment_with_home = dict(ISOLATED_ENVIRONMENT)
        environment_with_home["HOME"] = home_directory

        # Given Claude's shell sits in a directory that isn't a repository
        other_directory = self.enterContext(tempfile.TemporaryDirectory())

        # When Claude pushes the repository with -C and a path under ${HOME}
        hook_input = json.dumps(
            {"cwd": other_directory, "tool_input": {"command": "git -C ${HOME}/dev/project push origin main"}}
        )
        guard_run = subprocess.run(
            [GUARD_SCRIPT], input=hook_input, capture_output=True, text=True, env=environment_with_home
        )

        # Then the guard lets it through
        self.assertEqual(guard_run.returncode, 0)
        self.assertEqual(guard_run.stderr, "")

    def test_push_with_directory_option_under_other_variable_is_blocked(self) -> None:
        # Given a repository that has opted in to pushing
        repository = self.enterContext(tempfile.TemporaryDirectory())
        subprocess.run(["git", "init", "--quiet", repository], check=True, env=ISOLATED_ENVIRONMENT)
        subprocess.run(
            ["git", "-C", repository, "config", "claude.allowPush", "true"], check=True, env=ISOLATED_ENVIRONMENT
        )

        # Given the guard's own environment happens to name that repository in a variable
        environment_with_variable = dict(ISOLATED_ENVIRONMENT)
        environment_with_variable["PROJECT_DIRECTORY"] = repository

        # When Claude pushes with -C and a path built from that variable, which the shell may see differently
        hook_input = json.dumps(
            {"cwd": repository, "tool_input": {"command": "git -C $PROJECT_DIRECTORY push origin main"}}
        )
        guard_run = subprocess.run(
            [GUARD_SCRIPT], input=hook_input, capture_output=True, text=True, env=environment_with_variable
        )

        # Then the guard blocks it
        self.assertEqual(guard_run.returncode, 2)
        self.assertEqual(guard_run.stderr, PUSH_BLOCKED_MESSAGE)

    def test_push_after_cd_under_tilde_into_opted_in_repository_is_allowed(self) -> None:
        # Given a home directory holding a repository that has opted in to pushing
        home_directory = self.enterContext(tempfile.TemporaryDirectory())
        repository = os.path.join(home_directory, "dev", "project")
        subprocess.run(["git", "init", "--quiet", repository], check=True, env=ISOLATED_ENVIRONMENT)
        subprocess.run(
            ["git", "-C", repository, "config", "claude.allowPush", "true"], check=True, env=ISOLATED_ENVIRONMENT
        )
        environment_with_home = dict(ISOLATED_ENVIRONMENT)
        environment_with_home["HOME"] = home_directory

        # Given Claude's shell sits in a directory that isn't a repository
        other_directory = self.enterContext(tempfile.TemporaryDirectory())

        # When Claude changes into the repository through ~ and pushes
        hook_input = json.dumps(
            {"cwd": other_directory, "tool_input": {"command": "cd ~/dev/project && git push origin main"}}
        )
        guard_run = subprocess.run(
            [GUARD_SCRIPT], input=hook_input, capture_output=True, text=True, env=environment_with_home
        )

        # Then the guard lets it through
        self.assertEqual(guard_run.returncode, 0)
        self.assertEqual(guard_run.stderr, "")

    def test_push_with_directory_option_into_repository_without_opt_in_is_blocked(self) -> None:
        # Given Claude's shell sits in a repository that has opted in to pushing
        repository = self.enterContext(tempfile.TemporaryDirectory())
        subprocess.run(["git", "init", "--quiet", repository], check=True, env=ISOLATED_ENVIRONMENT)
        subprocess.run(
            ["git", "-C", repository, "config", "claude.allowPush", "true"], check=True, env=ISOLATED_ENVIRONMENT
        )

        # Given another repository that has not opted in
        other_repository = self.enterContext(tempfile.TemporaryDirectory())
        subprocess.run(["git", "init", "--quiet", other_repository], check=True, env=ISOLATED_ENVIRONMENT)

        # When Claude pushes the other repository with -C
        hook_input = json.dumps(
            {"cwd": repository, "tool_input": {"command": f"git -C {other_repository} push origin main"}}
        )
        guard_run = subprocess.run(
            [GUARD_SCRIPT], input=hook_input, capture_output=True, text=True, env=ISOLATED_ENVIRONMENT
        )

        # Then the guard blocks it
        self.assertEqual(guard_run.returncode, 2)
        self.assertEqual(guard_run.stderr, PUSH_BLOCKED_MESSAGE)

    def test_push_with_other_global_option_in_opted_in_repository_is_blocked(self) -> None:
        # Given a repository that has opted in to pushing
        repository = self.enterContext(tempfile.TemporaryDirectory())
        subprocess.run(["git", "init", "--quiet", repository], check=True, env=ISOLATED_ENVIRONMENT)
        subprocess.run(
            ["git", "-C", repository, "config", "claude.allowPush", "true"], check=True, env=ISOLATED_ENVIRONMENT
        )

        # Given another repository that has not opted in
        other_repository = self.enterContext(tempfile.TemporaryDirectory())
        subprocess.run(["git", "init", "--quiet", other_repository], check=True, env=ISOLATED_ENVIRONMENT)

        # When Claude pushes from the opted-in repository but points git at the other one with --git-dir
        command = f"git --git-dir={other_repository}/.git push origin main"
        hook_input = json.dumps({"cwd": repository, "tool_input": {"command": command}})
        guard_run = subprocess.run(
            [GUARD_SCRIPT], input=hook_input, capture_output=True, text=True, env=ISOLATED_ENVIRONMENT
        )

        # Then the guard blocks it
        self.assertEqual(guard_run.returncode, 2)
        self.assertEqual(guard_run.stderr, PUSH_BLOCKED_MESSAGE)

    def test_push_with_prefix_before_git_in_opted_in_repository_is_blocked(self) -> None:
        # Given a repository that has opted in to pushing
        repository = self.enterContext(tempfile.TemporaryDirectory())
        subprocess.run(["git", "init", "--quiet", repository], check=True, env=ISOLATED_ENVIRONMENT)
        subprocess.run(
            ["git", "-C", repository, "config", "claude.allowPush", "true"], check=True, env=ISOLATED_ENVIRONMENT
        )

        # Given another repository that has not opted in
        other_repository = self.enterContext(tempfile.TemporaryDirectory())
        subprocess.run(["git", "init", "--quiet", other_repository], check=True, env=ISOLATED_ENVIRONMENT)

        # When Claude pushes through env, which moves git into the other repository
        command = f"env -C {other_repository} git push origin main"
        hook_input = json.dumps({"cwd": repository, "tool_input": {"command": command}})
        guard_run = subprocess.run(
            [GUARD_SCRIPT], input=hook_input, capture_output=True, text=True, env=ISOLATED_ENVIRONMENT
        )

        # Then the guard blocks it
        self.assertEqual(guard_run.returncode, 2)
        self.assertEqual(guard_run.stderr, PUSH_BLOCKED_MESSAGE)

    def test_push_after_cd_into_opted_in_repository_is_allowed(self) -> None:
        # Given a repository that has opted in to pushing
        repository = self.enterContext(tempfile.TemporaryDirectory())
        subprocess.run(["git", "init", "--quiet", repository], check=True, env=ISOLATED_ENVIRONMENT)
        subprocess.run(
            ["git", "-C", repository, "config", "claude.allowPush", "true"], check=True, env=ISOLATED_ENVIRONMENT
        )

        # Given Claude's shell sits in a repository that has not opted in
        other_repository = self.enterContext(tempfile.TemporaryDirectory())
        subprocess.run(["git", "init", "--quiet", other_repository], check=True, env=ISOLATED_ENVIRONMENT)

        # When Claude changes into the opted-in repository and pushes
        hook_input = json.dumps(
            {"cwd": other_repository, "tool_input": {"command": f"cd {repository} && git push origin main"}}
        )
        guard_run = subprocess.run(
            [GUARD_SCRIPT], input=hook_input, capture_output=True, text=True, env=ISOLATED_ENVIRONMENT
        )

        # Then the guard lets it through
        self.assertEqual(guard_run.returncode, 0)
        self.assertEqual(guard_run.stderr, "")

    def test_push_after_cd_into_repository_without_opt_in_is_blocked(self) -> None:
        # Given Claude's shell sits in a repository that has opted in to pushing
        repository = self.enterContext(tempfile.TemporaryDirectory())
        subprocess.run(["git", "init", "--quiet", repository], check=True, env=ISOLATED_ENVIRONMENT)
        subprocess.run(
            ["git", "-C", repository, "config", "claude.allowPush", "true"], check=True, env=ISOLATED_ENVIRONMENT
        )

        # Given another repository that has not opted in
        other_repository = self.enterContext(tempfile.TemporaryDirectory())
        subprocess.run(["git", "init", "--quiet", other_repository], check=True, env=ISOLATED_ENVIRONMENT)

        # When Claude changes into the other repository and pushes
        hook_input = json.dumps(
            {"cwd": repository, "tool_input": {"command": f"cd {other_repository} && git push origin main"}}
        )
        guard_run = subprocess.run(
            [GUARD_SCRIPT], input=hook_input, capture_output=True, text=True, env=ISOLATED_ENVIRONMENT
        )

        # Then the guard blocks it
        self.assertEqual(guard_run.returncode, 2)
        self.assertEqual(guard_run.stderr, PUSH_BLOCKED_MESSAGE)

    def test_push_after_cd_to_relative_path_is_blocked(self) -> None:
        # Given a repository that has opted in to pushing, with a subdirectory
        repository = self.enterContext(tempfile.TemporaryDirectory())
        subprocess.run(["git", "init", "--quiet", repository], check=True, env=ISOLATED_ENVIRONMENT)
        subprocess.run(
            ["git", "-C", repository, "config", "claude.allowPush", "true"], check=True, env=ISOLATED_ENVIRONMENT
        )
        os.mkdir(os.path.join(repository, "docs"))

        # When Claude changes into a relative path, which CDPATH could send anywhere, and pushes
        hook_input = json.dumps({"cwd": repository, "tool_input": {"command": "cd docs && git push origin main"}})
        guard_run = subprocess.run(
            [GUARD_SCRIPT], input=hook_input, capture_output=True, text=True, env=ISOLATED_ENVIRONMENT
        )

        # Then the guard blocks it
        self.assertEqual(guard_run.returncode, 2)
        self.assertEqual(guard_run.stderr, PUSH_BLOCKED_MESSAGE)

    def test_push_after_cd_to_path_with_shell_expansion_is_blocked(self) -> None:
        # Given a repository that has opted in to pushing
        repository = self.enterContext(tempfile.TemporaryDirectory())
        subprocess.run(["git", "init", "--quiet", repository], check=True, env=ISOLATED_ENVIRONMENT)
        subprocess.run(
            ["git", "-C", repository, "config", "claude.allowPush", "true"], check=True, env=ISOLATED_ENVIRONMENT
        )

        # When Claude changes into a directory named by a variable and pushes
        hook_input = json.dumps(
            {"cwd": repository, "tool_input": {"command": "cd $OTHER_REPOSITORY && git push origin main"}}
        )
        guard_run = subprocess.run(
            [GUARD_SCRIPT], input=hook_input, capture_output=True, text=True, env=ISOLATED_ENVIRONMENT
        )

        # Then the guard blocks it
        self.assertEqual(guard_run.returncode, 2)
        self.assertEqual(guard_run.stderr, PUSH_BLOCKED_MESSAGE)

    def test_push_after_cd_that_may_not_have_run_is_blocked(self) -> None:
        # Given a repository that has opted in to pushing
        repository = self.enterContext(tempfile.TemporaryDirectory())
        subprocess.run(["git", "init", "--quiet", repository], check=True, env=ISOLATED_ENVIRONMENT)
        subprocess.run(
            ["git", "-C", repository, "config", "claude.allowPush", "true"], check=True, env=ISOLATED_ENVIRONMENT
        )

        # Given Claude's shell sits in a repository that has not opted in
        other_repository = self.enterContext(tempfile.TemporaryDirectory())
        subprocess.run(["git", "init", "--quiet", other_repository], check=True, env=ISOLATED_ENVIRONMENT)

        # When Claude pushes only if changing into the opted-in repository fails
        hook_input = json.dumps(
            {"cwd": other_repository, "tool_input": {"command": f"cd {repository} || git push origin main"}}
        )
        guard_run = subprocess.run(
            [GUARD_SCRIPT], input=hook_input, capture_output=True, text=True, env=ISOLATED_ENVIRONMENT
        )

        # Then the guard blocks it
        self.assertEqual(guard_run.returncode, 2)
        self.assertEqual(guard_run.stderr, PUSH_BLOCKED_MESSAGE)

    def test_push_after_cd_inside_compound_command_is_blocked(self) -> None:
        # Given Claude's shell sits in a repository that has opted in to pushing
        repository = self.enterContext(tempfile.TemporaryDirectory())
        subprocess.run(["git", "init", "--quiet", repository], check=True, env=ISOLATED_ENVIRONMENT)
        subprocess.run(
            ["git", "-C", repository, "config", "claude.allowPush", "true"], check=True, env=ISOLATED_ENVIRONMENT
        )

        # Given another repository that has not opted in
        other_repository = self.enterContext(tempfile.TemporaryDirectory())
        subprocess.run(["git", "init", "--quiet", other_repository], check=True, env=ISOLATED_ENVIRONMENT)

        # When Claude changes into the other repository inside an if, and pushes there
        command = f"if cd {other_repository}; then git push origin main; fi"
        hook_input = json.dumps({"cwd": repository, "tool_input": {"command": command}})
        guard_run = subprocess.run(
            [GUARD_SCRIPT], input=hook_input, capture_output=True, text=True, env=ISOLATED_ENVIRONMENT
        )

        # Then the guard blocks it
        self.assertEqual(guard_run.returncode, 2)
        self.assertEqual(guard_run.stderr, PUSH_BLOCKED_MESSAGE)

    def test_push_after_quoted_text_that_looks_like_cd_is_blocked(self) -> None:
        # Given a repository that has opted in to pushing
        repository = self.enterContext(tempfile.TemporaryDirectory())
        subprocess.run(["git", "init", "--quiet", repository], check=True, env=ISOLATED_ENVIRONMENT)
        subprocess.run(
            ["git", "-C", repository, "config", "claude.allowPush", "true"], check=True, env=ISOLATED_ENVIRONMENT
        )

        # Given Claude's shell sits in a repository that has not opted in
        other_repository = self.enterContext(tempfile.TemporaryDirectory())
        subprocess.run(["git", "init", "--quiet", other_repository], check=True, env=ISOLATED_ENVIRONMENT)

        # When Claude echoes a quoted string that contains a cd into the opted-in repository, then pushes
        command = f'echo "note; cd {repository}; "; git push origin main'
        hook_input = json.dumps({"cwd": other_repository, "tool_input": {"command": command}})
        guard_run = subprocess.run(
            [GUARD_SCRIPT], input=hook_input, capture_output=True, text=True, env=ISOLATED_ENVIRONMENT
        )

        # Then the guard blocks it, since the push really runs in the other repository
        self.assertEqual(guard_run.returncode, 2)
        self.assertEqual(guard_run.stderr, PUSH_BLOCKED_MESSAGE)


if __name__ == "__main__":
    unittest.main()
