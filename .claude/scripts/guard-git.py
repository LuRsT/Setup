#!/usr/bin/env python3
# PreToolUse(Bash) guard: Gil drives pushing himself.
#
# Blocks only push. Local history rewrites (rebase / reset / cherry-pick /
# commit --amend) are allowed — Gil delegates those to Claude on purpose and
# reviews the result before he pushes. Plain `git add` / `git commit` were
# always allowed. Fails OPEN on any parsing error so it can never wedge real work.
from __future__ import annotations

import json
import re
import shlex
import sys

BLOCKED_SUBCOMMANDS = {"push"}
# git global flags that take a separate-word value (so we skip that value when
# hunting for the real subcommand): `git -C /path push`, `git -c k=v push`, ...
VALUE_FLAGS = {"-C", "-c", "--git-dir", "--work-tree", "--namespace",
               "--super-prefix", "--exec-path"}


def offending(piece: str) -> str | None:
    try:
        toks = shlex.split(piece)
    except ValueError:
        toks = piece.split()
    for i, tok in enumerate(toks):
        if tok != "git" and not tok.endswith("/git"):
            continue
        j = i + 1
        while j < len(toks) and toks[j].startswith("-"):
            flag = toks[j]
            j += 1
            if flag in VALUE_FLAGS and j < len(toks):
                j += 1  # also skip the flag's value
        if j >= len(toks):
            return None
        sub = toks[j]
        if sub in BLOCKED_SUBCOMMANDS:
            return sub
        return None
    return None


def main() -> int:
    try:
        cmd = json.load(sys.stdin).get("tool_input", {}).get("command", "") or ""
    except Exception:
        return 0  # fail open

    # Split on shell separators so `git log; git push` is inspected per-command.
    for piece in re.split(r"[|;&\n]+", cmd):
        hit = offending(piece)
        if hit:
            sys.stderr.write(
                f"Blocked by guard-git: `git {hit}` — Gil drives pushing "
                "himself. Don't run it; tell him the exact command to run.\n"
            )
            return 2
    return 0


sys.exit(main())
