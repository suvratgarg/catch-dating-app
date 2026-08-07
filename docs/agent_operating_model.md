---
doc_id: agent_operating_model
version: 2.0.0
updated: 2026-08-07
owner: agent_operating_model
status: active
---

# Agent Operating Model

Catch should be easy for an AI agent to understand because the repo contains
small routing docs, machine-readable contracts, and deterministic checks. The
goal is not to make agents remember more. The goal is to make the correct
workflow cheaper than a partial fix.

## Operating Principle

Treat every agent as a capable contributor with unreliable ambient memory.
Instructions that matter must be one of:

- executable: lint, scanner, test, contract check, Widgetbook coverage, or CI
  job;
- authored: canonical source documents and domain contracts with clear owners;
- derived: read-only planner output, Git history, or expiring CI artifacts; or
- explicitly manual: a named human review point with a stable checklist.

If a rule is only a paragraph in a long doc, expect it to drift.

## Evidence Freeze

The file inventory, pass ledger, agent metrics, document-version catalog, and
regression ledger are frozen migration inputs. No agent or tool may append,
refresh, stamp, or version-bump them. Older instructions requiring those writes
are superseded by this section. Git and CI own execution history; generated
reports are ephemeral; recurring regressions move into their owning tests or
scanners. Do not create a replacement ledger.

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
directly exercised ratchet baselines.
It is registered in `tool/tools_manifest.json` under category `meta`, so
`node tool/run.mjs check --category meta` is the local and CI entrypoint.

When adding or changing an enforcement asset, update the rule entry, manifest
entry, doc anchor, vacuity proof, and ratchet baseline in the same pass. If a
rule is not yet machine-checkable, keep it as a manual
enforcement entry with a stable owner doc rather than leaving it absent.

## Execution Modes

| Mode | Use when | Required behavior |
|---|---|---|
| `answer` | The user asks a pointed question | Read the narrow source of truth and answer with file-backed current state. |
| `focused-change` | The user asks for a specific code/doc change | Read owner docs, edit the smallest safe surface, run focused checks. |
| `broad-cleanup` | The user asks for cleanup, migration, consolidation, or refactor | Generate a read-only plan, declare scope, classify findings, fix a coherent batch, and run the selected checks. |
| `design-implementation` | The user gives a design/handoff/screenshot | Convert intent into component contracts and Widgetbook states before or alongside Flutter implementation. |
| `release-operation` | The task affects deploy, release, CI, Firebase, App Store, or production data | Use documented runbooks and verify live/workflow state when the answer depends on it. |
| `parallel-delegation` | The user authorizes parallel agents or the current batch has independent sidecar work | Use short-lived Git worktrees, assign disjoint scopes, review branch commits before importing, and keep final integration parent-owned. |
| `strategy` | The user asks what to do | Separate current-state facts from recommendations and propose an executable next pass. |

## Broad Cleanup Contract

Before editing in `broad-cleanup`, the agent must be able to state:

- goal: the durable outcome, not just a file list;
- scope: included paths and explicitly excluded paths;
- owner docs: source-of-truth files that govern the change;
- active executable rules and component relationships that apply;
- commands: checks that prove the batch;
- acceptance: what must be true to call the batch done.

Use `node tool/agent/context_pack.mjs` as read-only planning help. If the
packet is too broad, split the work into numbered batches. It is not execution
authority and does not create a completion receipt.

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
- run the pattern's focused checks for the prototype and adopters.

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

Document metadata is moving to source:

- `docs/audit_registry/doc_versions.json` is a frozen compatibility snapshot.
  Do not update it. Governed Markdown owns lifecycle status in source
  frontmatter; non-Markdown contracts should own version and lifecycle in their
  existing schema or manifest.
- `tool/docs/build_doc_state.mjs` derives Markdown lifecycle status, content
  revision, last integrated commit, and integration timestamp from source and
  Git. CI publishes that state as an immutable artifact for the integrated SHA;
  it never commits generated version/date churn back to an author branch.

During migration, the old monotonic check remains read-only compatibility:

```sh
node tool/docs/check_doc_version_monotonic.mjs --base origin/main
node tool/docs/build_doc_state.mjs --ref HEAD --output build/ci/doc-state.json
```

Do not use a CI bot or agent to update the frozen catalog. Integration metadata
is derived evidence.

After a squash/merge is proven on `origin/main`, delete its remote branch,
remove its disposable worktree, and prune local tracking refs. Do not reuse it
for the next slice.

## Parallel Worktree Delegation Contract

Parallel agents may speed up Catch work only when they preserve a single
integration owner. The parent agent owns architecture decisions, final diffs,
canonical source, and verification. A subagent owns only its assigned
branch/worktree task.

Use delegation for sidecar work that can run while the parent continues the
critical path:

- read-only inventory, candidate selection, or risk review;
- isolated patch proposals in disjoint files;
- test-gap discovery or scanner interpretation; and
- alternative implementation sketches for a named pattern.

Do not delegate final architecture decisions, shared primitive API decisions,
app-wide naming, or docs consolidation unless the parent explicitly makes that
subagent the owner for that single file set and later reviews the result.

### Git Protocol

Use Git worktrees as the isolation boundary, but do not create them with ad hoc
`git worktree add` commands. The Harness lifecycle is the canonical broker:

```sh
node tool/agent/context_pack.mjs \
  --task <task-id> \
  --mode parallel-delegation \
  --owned-paths <owned-path[,owned-path...]> \
  --planned-impact-paths <planned-change-path[,planned-change-path...]> \
  --output build/agent-context/<task-id>.json
node tool/harness.mjs task start \
  --task-id <task-id> \
  --base-sha <40-character-parent-sha> \
  --stack-parent <parent-ref> \
  --owned-paths <owned-path[,owned-path...]> \
  --context-pack build/agent-context/<task-id>.json \
  --budget-mib 256
node tool/harness.mjs task doctor --worktree <task-worktree>
node tool/harness.mjs task finish --worktree <task-worktree>
node tool/harness.mjs task recover-lease --worktree <task-worktree>
node tool/harness.mjs task reap --dry-run
```

| Artifact | Current writer | Legacy reader contract |
|---|---|---|
| Context pack | `catch.agent-context-pack/v3` | V2 is reconstructed only to verify existing task-metadata v3 receipts. |
| Digested task input | `catch.harness-task-input/v2` | V1 is reconstructed only to verify existing task-metadata v3 receipts. |
| Task lifecycle state mirror | `catch.harness-task/v5` | V1-V4 remain readable for doctor/finish closeout and are never upgraded in place; they cannot authorize worker execution. |
| Parent-issued task authority | `catch.harness-task-authority/v1` | No legacy authority is inferred from worker-editable metadata. |

The context pack keeps human commands for execution guidance, but task
materialization is authorized only by structured tool ids. `--owned-paths` declares
the hard write ceiling and sparse ownership projection. `--planned-impact-paths`
declares the narrower expected diff used to select owner docs, skills, rules,
regressions, and checks. Planned impact must stay within ownership. Existing
planned directories expand to their tracked descendants at the exact base
commit. They do not authorize new descendants; every future leaf must be named
exactly, and a missing planned path authorizes only that exact leaf. Parallel
tasks with directory ownership must state planned impact explicitly. Index-view
checks become task checks; full-view checks are
recorded as deferred integration checks for the parent so a repository scanner
cannot pass vacuously against a sparse projection. Generated command plans name
an owner and phase: the worker runs only worker-owned preflight/task checks,
while the parent owns lifecycle creation/finish, explicit stale-lease recovery,
maintenance, full-view integration, canonical owner docs, and final
verification. Every lifecycle instruction is projected from
the same canonical task-command contract.
This split is enforced at execution, not left to operator memory. Before any
execution output or child command, `node tool/run.mjs check ...` locates the
actual linked-worktree administrative id, then requires three agreeing control
signals: the Git-local v5 state mirror, the write-once parent authority under
the common Git directory, and the registered live worktree lock whose reason
contains the task and authority ids. It binds physical path, branch, base
ancestry, owned/planned scope, sparse closure, storage limits, and worker/deferred
ids to that parent record, then recomputes the check contract from the
authority's base-SHA manifest and skills. The frozen regression ledger is not a
planning or execution authority. Each selected
tool's executable manifest signature is also compared with that base view, so a
worker cannot keep an allowed id while replacing its command. Affected and
impacted execution also compares the complete live tool manifest, component
graph, and repository relationship manifest used for planning with the same
base-SHA values; a worker cannot preserve an allowed command while rewriting
which commands the planner selects. A missing receipt or authority beneath the
canonical task root is an error, not an ordinary checkout. The complete selected
id set must be a subset of the base-proven worker `checkIds`; a mixed set is
rejected atomically with exit 77.

The runner atomically publishes a populated task execution gate, rereads live
authority, holds that gate through every child, and releases it in `finally`;
`task finish` must own the same gate before its first integrity snapshot. Every
mutable receipt lives under the lease token's generation directory, and child
and transition receipts are fsynced in unique staging paths before atomic
publication. Recovery or release publishes one immutable transition plus a
single PID-named claim. A dead claim is taken over by atomically renaming that
claim directory; exact gate layout, ordinary-directory ancestry, and all live
child groups are rechecked before the entire gate is atomically retired. That
whole-gate rename is the only unlock point. A delayed publisher from an old
generation therefore cannot write into a replacement lease, and a crash before
retirement leaves a complete resumable gate rather than a half-deleted marker.

On POSIX, managed commands run through a detached helper that records its
process group before starting the command. Interrupts are forwarded to the
whole group, the outer runner waits for descendants after the shell exits, and
explicit recovery cannot retire the gate until the owner and every recorded
group are dead. Managed execution on Windows fails closed with exit 77 until an
equivalent job-object process-tree boundary exists. Live task state is also
checked again before each child;
parent-deferred ids report `parent_deferred_check`, and ids outside both phases
report `unplanned_task_check`. Direct `run`/`exec` dispatch is unavailable in a
managed task because forwarded arguments cannot be proven by the check plan.
Malformed, legacy, finishing, or terminal task authority fails closed. Full
checkouts with no task receipt retain ordinary runner behavior. Read-only
discovery and stdout-only planning remain available, including `list`, impact
planning without `--check`, and `check --manifest-only`; `--github-output` is a
write and therefore crosses the same gate and whole-plan authorization boundary.
The pack is consumable only when its source worktree is clean, its SHA and
owned and planned-impact scopes match task start, and every selected id
resolves to an active manifest tool. Command regressions awaiting structured ids remain explicit
deferred parent checks; their display strings never authorize sparse
materialization. With `--output`, a `.json` suffix selects JSON and `.md` or
`.markdown` selects Markdown, case-insensitively. `--json` remains an explicit
JSON override for an unrecognized suffix but cannot contradict a recognized
Markdown suffix. Ambiguous output without that explicit override fails before
the target is created or replaced. The compact stdout receipt uses the resolved
artifact format, includes that format, and is emitted only after the full pack
is written successfully.

`task start` requires and validates the exact parent SHA, explicit owned paths,
and context-pack digest. It checks a fixed allocated-disk reserve plus the
allocated task budget, rejects local and
remote branch collisions, creates the worktree under ignored
`.claude/worktrees/`, writes a read-only parent authority keyed by Git's linked-
worktree id, Git-locks the active worktree with the task and authority ids, and
pushes the new branch to `origin`. Closure-aware starts record v5 state that separates owned paths,
planned impact paths, support-only materialization, required physical
entrypoints, task check ids, deferred integration ids, base SHA, and digest.
New starts cannot bypass the pack contract. The lifecycle reader retains
v1-v4 compatibility for closeout; only v5 plus authority v1 are written, and
only that pair can dispatch worker checks. V2, v3, v4, and v5
receipts name the tracked logical estimate, projected initial allocation,
initial logical materialization, and initial allocated materialization
separately. Current allocation and growth are allocated-to-allocated
measurements; never subtract a logical measurement from an allocated one. V1
allocated growth remains unknown because v1 recorded only an initial logical
measurement. Task worktrees never use `/tmp` or `/private/tmp`.

An interrupted child can leave a stale execution gate, but it is never stolen
implicitly. `task recover-lease` acts only after an explicit parent call, dead
owner and claim PIDs, dead recorded process groups, an exact generation layout,
and an atomic claim takeover. A live, malformed, symlinked, or unexpected gate
stays fail-closed. Retired-gate cleanup is non-authoritative and can never touch
a replacement generation. The authority and gate are an operational boundary
against accidental or buggy parallel agents, not a hostile same-Unix-user
security sandbox. Hostile workers require an external broker or credentials
unavailable inside worker sandboxes.

1. Parent records its current branch and 40-character HEAD, chooses disjoint
   owned paths and narrower planned impacts, generates the JSON context pack
   from that clean exact SHA, then runs `task start` with the same owned paths
   and `--context-pack`.
2. Each subagent receives the task id, generated worktree path and branch,
   owned paths, planned impacts, excluded paths, required owner docs, its worker-owned command
   phases, and the structured result format. Parent-owned command phases are
   not delegated.
3. Before editing, the subagent runs `task doctor` and reports `pwd`,
   `git branch --show-current`, `git rev-parse HEAD`, and
   `git status --short --branch`. Any doctor blocker or mismatch stops the
   task without editing.
4. The subagent runs only the receipt's worker-owned check ids through
   `node tool/run.mjs check <id...>`. It does not invoke deferred ids or use
   `node tool/run.mjs run/exec` from the sparse task. It then commits and pushes
   its proposal and reports the commit SHA,
   changed files, checks run, blockers, and quality risks.
5. Parent reviews with `git show`, `git diff`, or `cherry-pick -n`, then imports
   only the accepted changes into the parent branch.
6. Parent runs the relevant integration checks, reviews the final diff,
   commits the accepted result, and leaves evidence in Git, task output, and CI.
7. After the task branch is clean and its exact head exists at `origin`, run
   `task finish`. Doctor and finish share the same root, metadata-path,
   sparse-checkout, command-entrypoint closure, owned-scope, planned-impact,
   storage, base-ancestry,
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
commit diffs by cherry-picking them onto the intended parent branch, and do not
delegate more patch work until the next worker can pass the preflight.

If the parent branch advances while a subagent is still working, finish the
existing task after preserving its proposal and create a new task from the new
exact parent SHA. Long-lived or silently rebased subagent branches are not part
of the operating model.

### Ownership Rules

- One file has one writer per loop. If two agents need the same file, make that
  file parent-owned.
- Parent-owned by default: `AGENTS.md`, `docs/agent_operating_model.md`,
  `docs/app_architecture.md`, `docs/README.md`, authored design contracts,
  `docs/widget_catalog.md`, and `tool/tools_manifest.json`.
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

### Measurement

Use caller wall time, GitHub job duration, and task/PR output to decide whether
delegation is actually faster and higher quality than parent-only execution.
Do not append those samples to the repository. If a delegated path repeatedly
creates merge conflicts, parent rewrites, or scanner regressions, simplify the
workflow before repeating it.

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

## Regression Migration

`docs/agent_regression_ledger.json` is a frozen migration input. Existing
entries may be inspected only during their one-time classification; current
planners, context packs, readiness checks, and task authorization must not load
them. Do not add or update entries. Move executable value into the owning test,
scanner, or component risk gate; move genuinely manual external verification
to the owning runbook with an expiry.

## Skill Freshness

Project-local agent skills live under `docs/agent_skills/`. They are not a
second architecture system. They are short workflow routers that point to
canonical docs, commands, and acceptance criteria.

Each skill must declare:

- `skill_id`;
- `version`;
- `updated`;
- `source_docs`;
- `required_commands`;
- success evidence;
- `known_failure_modes`.

The compatibility readiness gate checks that skill source docs and commands
still exist. When
a guard explicitly builds Functions before running compiled `functions/lib`
tests, readiness validates the corresponding tracked `functions/src` test. This
keeps clean checkouts authoritative instead of relying on local build residue.

## Measuring Workflow Quality

Measure PR wall-clock, runner-minutes, selected operations, escaped defects, and
user rework in GitHub summaries or bounded analysis output. Do not commit
per-run metrics. Prefer ten comparable samples before optimizing a path.

## Done Criteria For This Harness

This operating model is active only if:

- `AGENTS.md` routes agents here;
- `docs/README.md` indexes this doc;
- the Catch planner explains affected operations without writing source;
- registered checks execute through `tool/run.mjs`;
- parallel work stays isolated in Git worktrees; and
- ordinary product work changes zero frozen evidence files.
