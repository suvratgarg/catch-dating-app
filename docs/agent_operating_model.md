---
doc_id: agent_operating_model
version: 1.2.0
updated: 2026-07-01
owner: agent_operating_model
status: active
---

# Agent Operating Model

Catch should be easy for an AI agent to understand because the repo contains
small routing docs, machine-readable contracts, deterministic checks, and proof
ledgers. The goal is not to make agents remember more. The goal is to make the
correct workflow cheaper than a partial fix.

## Operating Principle

Treat every agent as a capable contributor with unreliable ambient memory.
Instructions that matter must be one of:

- executable: lint, scanner, test, contract check, generated manifest, Widgetbook
  coverage, CI job;
- versioned: canonical docs and registries with clear owners;
- measured: pass receipts, regression ids, readiness scores, and trendable
  metrics; or
- explicitly manual: a named human review point with a stable checklist.

If a rule is only a paragraph in a long doc, expect it to drift.

## Execution Modes

| Mode | Use when | Required behavior |
|---|---|---|
| `answer` | The user asks a pointed question | Read the narrow source of truth and answer with file-backed current state. |
| `focused-change` | The user asks for a specific code/doc change | Read owner docs, edit the smallest safe surface, run focused checks. |
| `broad-cleanup` | The user asks for cleanup, migration, consolidation, or refactor | Generate a context pack, declare scope, classify findings, fix a coherent batch, stamp proof. |
| `design-implementation` | The user gives a design/handoff/screenshot | Convert intent into component contracts and Widgetbook states before or alongside Flutter implementation. |
| `release-operation` | The task affects deploy, release, CI, Firebase, App Store, or production data | Use documented runbooks and verify live/workflow state when the answer depends on it. |
| `parallel-delegation` | The user authorizes parallel agents or the current batch has independent sidecar work | Use short-lived Git worktrees, assign disjoint scopes, review branch commits before importing, keep canonical docs/stamps parent-owned, and record a delegation outcome metric. |
| `strategy` | The user asks what to do | Separate current-state facts from recommendations and propose an executable next pass. |

## Broad Cleanup Contract

Before editing in `broad-cleanup`, the agent must be able to state:

- goal: the durable outcome, not just a file list;
- scope: included paths and explicitly excluded paths;
- owner docs: source-of-truth files that govern the change;
- active rules: audit or architecture rules that apply;
- regression ids: relevant entries from `docs/agent_regression_ledger.json`;
- commands: checks that prove the batch;
- acceptance: what must be true to call the batch done.

Use `node tool/agent/context_pack.mjs` to assemble this packet. If the packet is
too broad, split the work into numbered batches and record remaining debt.
For autonomous refactor loops, prefer
`dart tool/audit_registry.dart next --code-only --screen-limit <n>` after each
pass so reference-only or future-design gaps stay tracked without blocking code
work.

## Reference Pattern Contract

Architecture refactors must not begin as prose-only rollouts. When a batch is
implementing a repeated app architecture pattern, the agent must:

- create or reuse a pattern id from
  `docs/audit_registry/architecture_pattern_adoption.json`;
- build one high-quality prototype before migrating sibling files;
- copy the reference code excerpt into `docs/app_architecture.md` as an exhibit;
- record prototype files, candidate files, adopters, variants, exceptions, and
  required checks in the tracker;
- if a later candidate improves or changes the pattern, update the exhibit first
  and revisit all existing adopters in the tracker; and
- stamp the pass with the pattern id and adopter list.

This makes migration quality ratchet forward: the file edited at the start of a
round must remain comparable to the file edited at the end of the round.

## Parallel Worktree Delegation Contract

Parallel agents may speed up Catch work only when they preserve a single
integration owner. The parent agent owns architecture decisions, final diffs,
canonical docs, generated registries, audit receipts, and verification. A
subagent owns only its assigned branch/worktree task.

Use delegation for sidecar work that can run while the parent continues the
critical path:

- read-only inventory, candidate selection, or risk review;
- isolated patch proposals in disjoint files;
- test-gap discovery or scanner interpretation; and
- alternative implementation sketches for a named pattern.

Do not delegate final architecture decisions, shared primitive API decisions,
app-wide naming, docs consolidation, audit stamping, or generated registry
updates unless the parent explicitly makes that subagent the owner for that
single file set and later reviews the result.

### Git Protocol

Use Git worktrees as the isolation boundary:

1. Parent records the current branch and HEAD before delegation.
2. Parent creates or asks for a disposable subagent branch from that HEAD.
3. Each subagent receives a task id, owned paths, excluded paths, required owner
   docs, allowed checks, and the structured result format.
4. Subagent commits its proposal on its branch and reports the commit SHA,
   changed files, checks run, blockers, and quality risks.
5. Parent reviews with `git show`, `git diff`, or `cherry-pick -n`, then imports
   only the accepted changes into the parent branch.
6. Parent runs final checks, updates canonical docs/registries, stamps the audit
   pass, commits the integrated loop, and records the delegation outcome.
7. Disposable worktrees/branches may be removed after the parent has accepted or
   rejected the proposal.

If the parent branch advances while a subagent is still working, either rebase
the subagent branch onto the new parent HEAD or discard/recreate the worktree.
Long-lived subagent branches are not part of the operating model.

### Ownership Rules

- One file has one writer per loop. If two agents need the same file, make that
  file parent-owned.
- Parent-owned by default: `AGENTS.md`, `docs/agent_operating_model.md`,
  `docs/app_architecture.md`, `docs/README.md`, `docs/audit_registry/**`,
  `docs/design_parity/**`, `docs/widget_catalog.md`, `tool/tools_manifest.json`,
  generated files, and pass receipts.
- Subagent patch branches should avoid generated artifacts unless generation is
  the explicit task.
- Flutter tests, Flutter analyzer, emulator-backed checks, and native builds run
  sequentially in the parent unless the parent explicitly assigns one isolated
  verification task to a subagent.

### Required Subagent Result

Subagents must return a structured packet:

```text
task_id:
agent_role:
base_branch:
base_sha:
worktree_path:
branch:
commit_sha:
owned_paths:
excluded_paths:
files_changed:
canonical_rules_applied:
checks_run:
checks_failed:
proposed_change_summary:
pattern_delta:
scanner_risks:
open_blockers:
do_not_merge_if:
```

`pattern_delta` is required. If the current architecture pattern is sufficient,
write `none`. If the subagent found a better pattern, it must describe the
candidate change instead of silently inventing a variant.

### Metrics

After every delegated task that informs the parent branch, record an outcome:

```sh
node tool/agent/record_delegation_outcome.mjs \
  --task-id <task-id> \
  --mode worker-patch \
  --status integrated \
  --parent-review-outcome accepted-with-edits \
  --subagent-branch <branch> \
  --subagent-commit <sha> \
  --files-changed path/one.dart,path/two.dart \
  --checks-run "flutter test test/example_test.dart"
```

Use these measurements to decide whether delegation is actually faster and
higher quality than parent-only execution. If a delegated path creates repeated
merge conflicts, parent rewrites, or scanner regressions, update this operating
model or the relevant skill before repeating it.

## UI And Design Implementation Contract

Do not use "read design and eyeball implementation" as the main workflow.
Design work should flow through:

```text
design or handoff
  -> component/screen contract
  -> Widgetbook states or preview surface
  -> implementation
  -> screenshot, golden, or focused visual review
  -> design/check proof
```

When design intent is ambiguous, ask for a narrow decision only after inspecting
the actual design artifact or Widgetbook surface.

## Regression Ledger

`docs/agent_regression_ledger.json` is the durable list of hard-won fixes that
should not be reintroduced. Each entry has:

- `id`: stable id referenced by context packs and pass receipts;
- `title`: short failure description;
- `status`: `active`, `watch`, or `archived`;
- `applies_to`: paths or globs;
- `symptom`: what regressed;
- `guard`: command, test, scanner, or manual check;
- `owner_docs`: canonical docs to read before touching the area.

Add a ledger entry whenever a bug or drift pattern has cost enough time that the
next agent should see it before editing.

## Skill Freshness

Project-local agent skills live under `docs/agent_skills/`. They are not a
second architecture system. They are short workflow routers that point to
canonical docs, commands, ledgers, and acceptance criteria.

Each skill must declare:

- `skill_id`;
- `version`;
- `updated`;
- `source_docs`;
- `required_commands`;
- `success_receipt`;
- `known_failure_modes`.

The readiness gate checks that skill source docs and commands still exist.

## Measuring Workflow Quality

The readiness gate reports an `agent readiness score`. The score is intentionally
simple at first:

- required docs exist and are indexed;
- regression ledger is valid and every active entry has a guard;
- project-local skills resolve their source docs and commands;
- tool manifest includes the agent scripts;
- metric files are parseable.

Append durable measurements to `docs/audit_registry/agent_metrics.jsonl` after
meaningful broad passes. Useful metrics:

- readiness score;
- context-pack count generated for the pass;
- checks planned versus checks run;
- scanner count deltas;
- regressions added, moved to watch, or archived;
- user-reported rework after the pass.
- delegation outcomes, including mode, base SHA, branch/commit, files changed,
  checks run, parent review outcome, conflicts, and whether the parent accepted,
  edited, rejected, or used the result as information only.

Over time, workflows with higher pass rates and lower rework should become the
default recommended path in `AGENTS.md` and the relevant skill.

## Done Criteria For This Harness

This operating model is active only if:

- `AGENTS.md` routes agents here;
- `docs/README.md` and `docs/audit_registry/doc_versions.json` index this doc;
- `tool/agent/context_pack.mjs` can build scoped packets;
- `tool/agent/check_agent_readiness.mjs` validates the harness; and
- `tool/agent/record_delegation_outcome.mjs` records parseable delegation
  outcomes when parallel agents are used; and
- `node tool/run.mjs check --category agent` passes.
