---
doc_id: agent_operating_model
version: 1.6.2
updated: 2026-08-07
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

## Enforcement Integrity

Rules, tools, CI wiring, and doc anchors must not drift independently. Active
rules in `docs/audit_registry/rules.json` declare their `enforcement` entries;
manifest tools that enforce rules declare `role`, `rules`, and, for gates or
ratchets, a `vacuityProof`. Manual enforcement is explicit with
`stage: manual`, not implied by a missing scanner.

`node tool/check_enforcement_integrity.mjs` is the meta-gate for this layer. It
validates active-rule coverage, reverse rule/tool mappings, doc anchors,
non-count runtime checks for gates and ratchets, known-bad proof declarations,
runtime-checked tool role declarations, architecture-scanner ownership, and
ratchet baseline receipts for both `maxCounts` and `allowedFindings` baselines.
It is registered in `tool/tools_manifest.json` under category `meta`, so
`node tool/run.mjs check --category meta` is the local and CI entrypoint.

When adding or changing an enforcement asset, update the rule entry, manifest
entry, doc anchor, vacuity proof, and ratchet baseline or metric receipt in the
same pass. If a rule is not yet machine-checkable, keep it as a manual
enforcement entry with a stable owner doc rather than leaving it absent.

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

## Git Preservation And Reconciliation Contract

Working branches are single-use, pushed preservation units. Create the upstream
when the branch is created (`push.autoSetupRemote=true`), and push every bounded
commit. If an agent session ends with intended dirty work, make a scoped
`chore(wip)` commit on that session branch and push it. Do not leave unique work
only in a working tree, stash, reflog, or unpushed local branch.

Long-running omnibus branches must stop accumulating changes as soon as one of
their slices is re-derived into another PR. On the same day, either reconcile
the branch onto the merged result or freeze its current tip under a pushed
`backup/` ref and replace it with focused branches. A frozen backup is evidence,
not a new integration source.

Before any rebase, reset, amend, history rewrite, or merge expected to require
manual conflict resolution:

1. fetch the remote and record the current branch, HEAD, upstream, and status;
2. create a dated `backup/<branch>-<date>` ref at the pre-operation HEAD and
   push it when the source branch is shared or holds unique work;
3. keep `rerere.enabled=true` so repeated conflict resolutions are stable; and
4. never rewrite a branch that has a shared upstream. Use a fresh branch and
   cherry-pick reviewed commits instead.

After any reconciliation touching more than 50 paths, run the exact four-tree
classifier and keep its JSON plus a reason for every discarded side:

```sh
node tool/git/audit_merge_drops.mjs \
  --base <merge-base> --ours <pre-merge-ours> \
  --theirs <integrated-tip> --merged <result> \
  --receipt <receipt.json> --strict --json
```

`both-diverged` paths still require semantic review; exact blob classification
cannot prove that one side's behavior was incorporated.

Governed document metadata has two deliberately separate clocks:

- `docs/audit_registry/doc_versions.json` stores authored semantic versions,
  ownership, and read policy. For governed non-Markdown artifacts it also owns
  lifecycle status. Governed Markdown owns lifecycle status exclusively in one
  valid frontmatter field; missing, malformed, or duplicate status fails closed
  for deletion. Change a semantic version only when the document's contract,
  schema, protocol, or reader workflow changes. Ordinary prose corrections do
  not require a version bump.
- `tool/docs/build_doc_state.mjs` derives Markdown lifecycle status, content
  revision, last integrated commit, and integration timestamp from source and
  Git. CI publishes that state as an immutable artifact for the integrated SHA;
  it never commits generated version/date churn back to an author branch.

Authored versions may stay unchanged or move monotonically:

```sh
node tool/docs/check_doc_version_monotonic.mjs --base origin/main
node tool/docs/build_doc_state.mjs --ref HEAD --output build/ci/doc-state.json
```

Do not use a CI bot to push version bumps to `main`. Integration metadata is a
derived receipt, while intentional semantic version changes remain normal
reviewed source edits.

After a squash/merge is proven on `origin/main`, delete its remote branch,
remove its disposable worktree, and prune local tracking refs. Do not reuse it
for the next slice.

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

Use Git worktrees as the isolation boundary, but do not create them with ad hoc
`git worktree add` commands. The Harness lifecycle is the canonical broker:

```sh
node tool/agent/context_pack.mjs \
  --task <task-id> \
  --mode parallel-delegation \
  --paths <owned-path[,owned-path...]> \
  --json \
  --output build/agent-context/<task-id>.json
node tool/harness.mjs task start \
  --task-id <task-id> \
  --base-sha <40-character-parent-sha> \
  --stack-parent <parent-ref> \
  --paths <owned-path[,owned-path...]> \
  --context-pack build/agent-context/<task-id>.json \
  --budget-mib 256
node tool/harness.mjs task doctor --worktree <task-worktree>
node tool/harness.mjs task finish --worktree <task-worktree>
node tool/harness.mjs task reap --dry-run
```

The context pack keeps human commands for execution guidance, but task
materialization is authorized only by structured tool ids. Scope directories
are expanded to their tracked descendants when skills, rules, regressions, and
checks are selected; task start recomputes that same expansion from the exact
base commit. Index-view checks become task checks; full-view checks are
recorded as deferred integration checks for the parent so a repository scanner
cannot pass vacuously against a sparse projection. Generated command plans name
an owner and phase: the worker runs only worker-owned preflight/task checks,
while the parent owns lifecycle creation/finish, full-view integration,
unstructured regression guards, canonical records, and final verification.
The pack is consumable only when its source worktree is clean, its SHA and
owned scope match task start, and every selected id resolves to an active
manifest tool. Command regressions awaiting structured ids remain explicit
deferred parent checks; their display strings never authorize sparse
materialization. With `--output`, the full artifact is written to disk and
stdout contains only a compact task/digest receipt.

`task start` requires and validates the exact parent SHA, explicit owned paths,
and context-pack digest. It checks a fixed allocated-disk reserve plus the
allocated task budget, rejects local and
remote branch collisions, creates the worktree under ignored
`.claude/worktrees/`, Git-locks the active worktree, and pushes the new branch
to `origin`. Closure-aware starts record v3 metadata that separates owned paths,
support-only materialization, required physical entrypoints, task check ids,
deferred integration ids, base SHA, and digest. New starts cannot bypass the
pack contract. The reader retains v1/v2 compatibility for tasks created before
this cutover. V2 and v3
receipts name the tracked logical estimate, projected initial allocation,
initial logical materialization, and initial allocated materialization
separately. Current allocation and growth are allocated-to-allocated
measurements; never subtract a logical measurement from an allocated one. V1
allocated growth remains unknown because v1 recorded only an initial logical
measurement. Task worktrees never use `/tmp` or `/private/tmp`.

1. Parent records its current branch and 40-character HEAD, chooses disjoint
   owned paths, generates the JSON context pack from that clean exact SHA, then
   runs `task start` with the same owned paths and `--context-pack`.
2. Each subagent receives the task id, generated worktree path and branch,
   owned paths, excluded paths, required owner docs, its worker-owned command
   phases, and the structured result format. Parent-owned command phases are
   not delegated.
3. Before editing, the subagent runs `task doctor` and reports `pwd`,
   `git branch --show-current`, `git rev-parse HEAD`, and
   `git status --short --branch`. Any doctor blocker or mismatch stops the
   task without editing.
4. The subagent commits and pushes its proposal, then reports the commit SHA,
   changed files, checks run, blockers, and quality risks.
5. Parent reviews with `git show`, `git diff`, or `cherry-pick -n`, then imports
   only the accepted changes into the parent branch.
6. Parent runs the pack's deferred integration checks plus final checks, updates
   canonical docs/registries, stamps the audit pass, commits the integrated
   loop, and records the delegation outcome.
7. After the task branch is clean and its exact head exists at `origin`, run
   `task finish`. Doctor and finish share the same root, metadata-path,
   sparse-checkout, command-entrypoint closure, owned-scope, storage, base-ancestry,
   ignored-payload, dependency, and filesystem-reserve integrity checks;
   allowlisted task-local dependency/build directories remain valid. Finish
   additionally performs a live origin-head
   query, reports an unavailable query separately from a mismatched remote
   head, records terminal metadata, and unlocks the worktree. It never removes
   a worktree or deletes a branch.
8. `task reap --dry-run` refreshes remote refs and emits a digested inventory.
   It is report-only. Removal requires a separate, exact owner acknowledgment;
   dirty, active, remotely unpreserved, legacy-unknown, or inspection-failed
   worktrees remain blocked.

If a subagent is discovered on the parent worktree or on a branch that includes
unreviewed parent-only commits, interrupt it immediately. Accept only reviewed
commit diffs by cherry-picking them onto the intended parent branch, record the
isolation failure in delegation metrics, and do not delegate more patch work
until the next worker can pass the preflight.

If the parent branch advances while a subagent is still working, finish the
existing task after preserving its proposal and create a new task from the new
exact parent SHA. Long-lived or silently rebased subagent branches are not part
of the operating model.

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
preflight:
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
- `guard`: command, test, scanner, or manual check; command guards may add
  structured `check_ids`, while the command string remains display guidance;
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

The readiness gate checks that skill source docs and commands still exist. When
a guard explicitly builds Functions before running compiled `functions/lib`
tests, readiness validates the corresponding tracked `functions/src` test. This
keeps clean checkouts authoritative instead of relying on local build residue.

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
