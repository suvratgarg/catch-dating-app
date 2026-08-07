---
doc_id: ai_first_workflow_guide
version: 2.0.0
updated: 2026-08-07
owner: agent_operating_model
status: active
---

# Catch AI Workflow

Catch uses Git and ordinary CI/CD. The repository adds only the Catch-specific
knowledge those systems do not have: which product components a changed path
affects, which existing operations should run, and how concurrent local agents
avoid editing the same scope.

## System Boundary

```text
Git diff + event mode
        |
        v
read-only Catch planner
        |
        +-- existing tests and scanners
        +-- existing builds
        +-- existing deployment workflows
        |
        v
GitHub logs and expiring artifacts
```

Git owns commits, branches, history, and worktrees. GitHub Actions owns
scheduling, approvals, logs, and artifacts. Firebase and the app stores own
deployment state. The Catch tooling does not replace any of them.

## 1. Change Planner

`tool/harness/component_graph.json` maps repository paths to product
components and declares directional dependencies and supported operations.
`node tool/harness.mjs plan` combines that graph with a Git diff and an event
mode:

- `pr`: validations needed before merge;
- `merge_group`: validations for the exact queued result;
- `main`: affected builds and deploy groups after integration;
- `nightly`: broad backstop checks;
- `release`: promotion operations.

The planner is a pure, read-only explanation. It may output check ids, build
targets, deploy groups, and the edges that selected them. It must not edit the
repository, execute deployment, or become an authorization database.

Unknown or ambiguous paths fail closed. Adding a new component relationship is
an architecture change; ordinary feature work does not update the graph.

## 2. Existing Checks

`tool/tools_manifest.json` gives stable ids to real commands. A command can be
a unit test, analyzer, scanner, contract check, code-generation freshness
check, build, or other bounded validation.

`node tool/run.mjs check <id...>` executes selected checks. It is a command
runner, not a second test framework. Product-specific assertions remain in
their owning Flutter, Node, emulator, or scanner suites.

Repeated rules should become executable. If a rule cannot be automated, put a
short manual check in the owning document with an expiry or explicit review
condition.

## 3. Concurrent Agent Work

Git worktrees isolate simultaneous Codex, Claude, and human changes. The local
task guard should add only four protections:

1. create a worktree from an exact commit;
2. refuse overlapping active write scopes;
3. report out-of-scope or dirty changes;
4. refuse closeout when unique commits are not pushed.

Task state belongs under the common Git directory and is local. It does not
belong in repository ledgers. The guard must work without GitHub for local
start, doctor, and reporting; it must never delete a worktree automatically.

The current lifecycle has additional migration compatibility. That code is
temporary and will be reduced to the boundary above.

## 4. CI/CD

CI consumes the planner output and runs the existing jobs. Cheap deterministic
checks run before expensive fan-out. A normal Flutter presentation change
should select Flutter validation and the affected app-role smoke build, not
Functions, rules, every website, and device builds.

Deployment begins only from a trusted, successful integrated commit. A
deployment workflow:

1. checks environment prerequisites before installs or expensive validation;
2. checks out the exact triggering SHA;
3. downloads or builds a checksum-bound artifact once;
4. applies affected deployment groups in their declared order;
5. records stage postconditions in GitHub artifacts;
6. resumes the first incomplete idempotent stage for the same SHA and artifact.

Environment approval and secrets remain GitHub/platform responsibilities.
Rollback and roll-forward remain explicit per deployment target.

## 5. Repository Evidence Policy

Repository source contains authored decisions and compile-critical generated
outputs. It does not contain per-run proof.

These legacy files are frozen pending deletion:

- `docs/audit_registry/files.jsonl`;
- `docs/audit_registry/passes.jsonl`;
- `docs/audit_registry/agent_metrics.jsonl`;
- `docs/audit_registry/doc_versions.json`;
- `docs/agent_regression_ledger.json`.

Do not refresh or append to them. Git contains their history. CI artifacts may
hold generated inventories, summaries, coverage, and diagnostics for a bounded
retention period.

## 6. Normal Task

```sh
git status --short
node tool/harness.mjs plan --mode pr --base <base> --head HEAD
node tool/run.mjs check <selected-check-id...>
git diff --check
```

For broad work, a context pack may summarize owner documents and selected
checks. It is read-only planning help, not execution authority or a completion
receipt.

For parallel work, use an isolated task worktree and let the parent review the
result. Git, task output, the PR, and CI preserve evidence.

## 7. Guardrails Against Another Governance Layer

- Ordinary product changes modify zero governance-evidence files.
- No check writes to tracked source by default.
- Derived reports are generated on demand or uploaded as expiring artifacts.
- No new ledger, receipt file, readiness score, or per-task registry replaces
  the frozen system.
- New Harness functionality must prevent a demonstrated failure or materially
  reduce wall-clock/runner cost.
- Nightly broad validation is the backstop for omissions; PR validation stays
  affected-only.

The durable outcome is a small planner, a thin Git-native worktree guard, and
exact-artifact CI/CD—not a repository operating system.
