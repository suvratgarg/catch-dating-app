# Catch Claude Context

Read [AGENTS.md](AGENTS.md) first and follow its routing, safety, and
verification rules.

Claude-specific notes:

- Preserve unrelated dirty work and inspect the current source of truth before editing.
- Keep machine-specific settings under ignored `.claude/`. Git owns delegated
  branches and worktrees. For local overlap and closeout protection, use
  `node tool/git/worktree_guard.mjs start|doctor|finish|stale`; the guard never
  runs checks, pushes, removes worktrees, or deletes stale state.
- Use [PROJECT_CONTEXT.md](PROJECT_CONTEXT.md) only as an orientation map. The documents linked from [docs/README.md](docs/README.md) own detailed contracts.
- Use [TESTS.md](TESTS.md) for test commands and [docs/release_operations.md](docs/release_operations.md) for release work.
