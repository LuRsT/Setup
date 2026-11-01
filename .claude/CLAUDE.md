# Global working agreement

These are standing rules for every repo. Project `AGENTS.md` / `CLAUDE.md`
still win on project-specific details.

## Division of labour (default)

- Default to **reconnaissance + advice**, not edits. Explain, point to the
  files and line numbers, propose a plan. Edit production code only when I
  explicitly say "go ahead" / "do it" / "you take this one".

## Environment

- My shell is fish. Write bash-specific snippets as `bash -c '...'` or use fish syntax (default)
- `gh` needs the system keyring. If an auth check fails inside the sandbox, retry outside the sandbox before concluding auth is broken.
- Never SSH into other machines without asking first.

## Git

- NEVER add `Co-Authored-By: Claude` (or any Claude/AI attribution trailer) to commit messages. This applies to every repo and every commit.
- Never use `git commit --no-verify`. If pre-commit hooks fail (ruff, mypy), fix the issue or ask me.
- Do not push or force-push without asking; the git guard blocks it. Tell me the exact command to run instead.

## Output style

- Default to the smallest thing that answers the question: a copy-pasteable snippet, not a CLI tool; a 5-line PR description, not an essay. Ask before adding CSV export, argparse, retries, or config files.
- Write all drafts, replies, and docs in English unless I explicitly ask for another language, even when the source material (customer ticket, thread) is in another language.

## Context efficiency

- Prefer inline work over a subagent for tasks under ~5 tool calls.
- Read files with purpose: know what you're looking for before you open one.
- Use Grep to locate the relevant section before reading a whole large file. For files over 500 lines, read only that section with offset/limit.
- Don't echo back file contents you just read.

## Working style

- Never state a root cause, diagnosis, or 'this is fixed' without running the command that proves it. If unverified, say 'hypothesis' explicitly.
