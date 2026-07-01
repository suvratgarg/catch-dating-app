# catch-parallel-delegation

Use when the user authorizes subagents, parallel agents, branch/worktree
delegation, or faster sidecar work during a broad Catch cleanup/refactor pass.

Read: `docs/agent_operating_model.md`, `AGENTS.md`,
`docs/audit_registry/README.md`, and `docs/agent_regression_ledger.json`.

Loop:

1. Parent generates a context pack for the parent task and chooses the critical
   path it will keep locally.
2. Parent assigns subagents only independent sidecar work with explicit owned
   paths, excluded paths, base branch, base SHA, checks, and result format.
3. Before editing, each subagent reports `pwd`, `git branch --show-current`,
   `git rev-parse HEAD`, and `git status --short --branch`. Stop the subagent
   if it is on the parent branch, in the parent worktree, or not at the assigned
   base SHA.
4. Subagents work in disposable Git worktrees/branches and commit proposals
   there.
5. Parent reviews the subagent commit, imports accepted changes into the parent
   branch, updates canonical docs/registries/stamps, and runs final checks.
6. Parent records a delegation outcome with
   `node tool/agent/record_delegation_outcome.mjs`.

Default parent-owned files: `AGENTS.md`, `docs/agent_operating_model.md`,
`docs/app_architecture.md`, `docs/README.md`, `docs/audit_registry/**`,
`docs/design_parity/**`, `docs/widget_catalog.md`, generated registries, tool
manifest entries, and audit pass receipts.

Failure modes to avoid: subagents accidentally sharing the parent worktree,
parallel agents editing the same file, subagents updating canonical docs without
parent review, long-lived stale branches, parallel Flutter test/analyzer races,
and accepting a patch whose pattern delta was not reviewed.
