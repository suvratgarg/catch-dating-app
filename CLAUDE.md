# Catch Claude Context

Read [AGENTS.md](AGENTS.md) first and follow its routing, safety, audit, and verification rules.

Claude-specific notes:

- Preserve unrelated dirty work and inspect the current source of truth before editing.
- Keep machine-specific settings under ignored `.claude/`. Create delegated worktrees with `node tool/harness.mjs task start`, require `task doctor` before edits, and close them with `task finish`; task worktrees belong under `.claude/worktrees/`, never a temporary system directory. `task reap --dry-run` reports candidates but never deletes them.
- Use [PROJECT_CONTEXT.md](PROJECT_CONTEXT.md) only as an orientation map. The documents linked from [docs/README.md](docs/README.md) own detailed contracts.
- Use [TESTS.md](TESTS.md) for test commands and [docs/release_operations.md](docs/release_operations.md) for release work.
