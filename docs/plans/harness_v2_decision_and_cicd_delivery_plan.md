---
doc_id: harness_v2_decision_and_cicd_delivery_plan
version: 1.1.2
updated: 2026-08-08
owner: agent_operating_model
status: active
---

# Harness v2 Decision And Delivery Architecture

## Status

Accepted and being integrated. This document is the durable architecture
decision and current status, not an execution diary. The former checkpoint
tables and daily measurements remain available in Git history.

The permanent system is ordinary Git and CI/CD with four small Catch-specific
capabilities:

1. a read-only impact planner;
2. optional stdout-only context guidance;
3. a thin local Git-worktree guard; and
4. exact-SHA, checksum-bound delivery with ordered resume.

The first three capabilities organize source work. The fourth makes CI output
safe to promote. None is a second source-control system, task scheduler, or
repository database.

## Context

Catch began with useful deterministic checks: linters, schema validation,
rules tests, generated-output drift checks, and environment-specific deploy
guards. Over time, an agent-support layer accumulated around them:

- generated file inventories and pass histories committed to every branch;
- a central regression snapshot and document-routing catalog;
- readiness scores and per-agent measurements;
- a task broker with its own command permissions, execution stages, recovery
  state, and materialized checkout model; and
- long plans whose checkpoint bookkeeping became another source of truth.

Those additions tried to answer legitimate questions—what changed, what should
run, whether parallel work overlaps, and what was deployed—but answered them by
duplicating Git and CI. The duplication caused conflicts, global regeneration
after small edits, expensive preflight, stale instructions, and failures in the
support system before product checks even began.

The core lesson is that Catch needs product-specific dependency knowledge, not
a repository operating system. Git already answers what changed and preserves
work. CI already records shared execution and deployment history. The harness
should only translate Catch paths into existing operations and close a few
concrete safety gaps.

## Decision

### 1. Git And CI Remain Authoritative

Git owns source, branches, commits, diffs, worktrees, merge ancestry, recovery,
and the identity of the code being reviewed. CI owns shared check output,
artifacts, environment approvals, and deployment history.

The repository does not store per-task proof. An ordinary product change must
not update an agent log, pass history, readiness score, generated file catalog,
or central regression database.

Actionable engineering debt belongs in GitHub Issues, where it can be assigned,
prioritized, linked to code, and closed. Completed debt history belongs in Git
and the closed issue, not a regenerated repository backlog.

### 2. The Impact Planner Is Read-Only

`tool/harness.mjs` maps explicit paths or a Git diff through the authored Catch
component graph. It explains and selects existing checks, builds, safe codegen,
and delivery lanes. Unmapped or ambiguous paths fail closed.

```sh
node tool/harness.mjs explain --paths <path[,path...]> --json
node tool/harness.mjs plan --base <base-ref> --head HEAD --json
```

The planner does not edit source, create worktrees, start processes, grant
command permissions, or record completion. Compile-critical generated outputs
remain tracked where review and offline builds require them; the planner may
select their deterministic freshness checks.

### 3. Context Guidance Is Optional And Ephemeral

`tool/agent/context_pack.mjs` may print relevant owner documents, project
skills, source rules, and suggested checks for a supplied path set:

```sh
node tool/agent/context_pack.mjs --task <label> --paths <path[,path...]>
```

It writes only to stdout. Its output is guidance, not permission, a persisted
task contract, or a completion condition. Agents can work directly from
`AGENTS.md`, owner documents, Git, and planner output when no extra orientation
is useful.

### 4. Parallel Work Uses A Thin Git Guard

Parallel work is still ordinary branches and worktrees. The optional local
guard adds only the protections Git does not conveniently enforce by itself:

```sh
node tool/git/worktree_guard.mjs start \
  --task-id <task-id> --base-sha <40-character-sha> --paths <claimed-paths>
node tool/git/worktree_guard.mjs doctor --worktree <path>
node tool/git/worktree_guard.mjs finish --worktree <path>
node tool/git/worktree_guard.mjs stale --stale-days 7
```

- `start` creates a normal worktree from an exact commit and rejects overlap
  with another active local claimed-path set.
- `doctor` reports registration, branch, dirty-state, and out-of-scope changes.
- `finish` drops only the local claim, and only after unique work is committed
  and pushed.
- `stale` reports candidates. It never deletes worktrees, branches, or claims.

The guard does not install dependencies, run checks, push, merge, remove a
worktree, schedule an agent, or police commands. Its state is local and
disposable; a Git branch remains the durable work unit.

### 5. Delivery Promotes Exact Bytes From An Exact Commit

A successful CI result for a commit is necessary but does not prove that a
later independent rebuild produced the same bytes. Delivery therefore uses a
small provenance contract:

- the full 40-character source SHA;
- the producing CI workflow generation, workflow-scoped run number, run
  identifier, and attempt;
- artifact basename and byte length;
- the artifact SHA-256 digest; and
- the ordered delivery stages allowed for that artifact.

The producing job builds once and creates the provenance manifest. Its final
required job publishes a small successful-attempt authority only after the
current attempt owns exactly one plan artifact and, when needed, one backend
package. That authority records the immutable artifact ids, names, and GitHub
SHA-256 digests. Delivery selects from those authorities, downloads by artifact
id, and verifies the archive digest, SHA, workflow generation, run identity,
attempt, size, and package provenance before credentials are used or remote
state is changed. A mismatched or modified artifact fails closed.

Queue discovery is metadata-first: one paginated artifact catalogue identifies
the greatest cursor and oldest pending successful authority, then only those
two ZIPs and their historical attempts are fully verified. Candidate count
therefore affects catalogue pages, not ZIP downloads or per-candidate API
calls. Workflow-scoped run numbers are never compared across CI workflow ids.
If the CI workflow is deleted/recreated, cursor generation mismatch requires an
explicit reviewed migration. Every selected plan must also start at the cursor
SHA; a missing or expired intermediate authority stops delivery instead of
skipping a release window.

This is promotion, not rebuilding. Website bundles, signed mobile packages,
and deployable backend bundles may use different packaging adapters, but each
adapter must preserve the same identity contract where the platform permits
artifact promotion.

### 6. Resume Is Ordered And Artifact-Bound

Multi-stage delivery records an ephemeral checkpoint document bound to:

- the provenance-manifest digest;
- source SHA and producing run id/attempt;
- artifact digest; and
- an immutable target scope such as environment plus project id.

Checkpoints form an ordered prefix of the stages declared by the manifest.
Each stage records a postcondition as passed or failed. A retry verifies the
artifact and checkpoint binding again, finds the first incomplete stage, and
continues from there. It cannot skip ahead. Replaying an already-passed stage
is idempotent and cannot rewrite its prior result.

Checkpoint files are written atomically and belong in CI artifacts or bounded
recovery output, not tracked source. Stage completion means the documented
postcondition passed; starting a deploy command is not completion.

Resume and rollback are different operations. Resume continues promotion of
the same verified bytes. Rollback follows the target-specific release runbook
and may require a prior verified artifact, a compensating change, or a
roll-forward. No generic helper claims to reverse partially applied remote
state automatically.

### 7. Environment And Mutation Policy Stay With Release Owners

The delivery core proves identity, integrity, order, and resume state. The
owning release path still defines:

- environment-readiness checks before expensive work;
- authentication and least-privilege credentials;
- approval boundaries and concurrency;
- target-specific stage postconditions and smoke tests;
- whether a deployment is automatic, manual, or prohibited; and
- rollback or roll-forward instructions.

No delivery helper may infer production permission merely because an artifact
verifies. Environment approval and remote-mutation policy remain separate.

## What Was Removed

The migration deletes the tracked agent-evidence layer and its writers:

- generated file and pass histories;
- agent measurements and documentation-version catalog;
- the central agent regression snapshot;
- the audit-registry writer and readiness-score command;
- delegation-recording helpers; and
- the task-broker implementation, command-permission layer, and lifecycle
  state machine.

Authored product rules, architecture contracts, deterministic scanners,
compile-critical generated source, release runbooks, and CI checks remain.
Historical implementation details remain recoverable from Git; they are not
copied into an archive that would become a second active authority.

Governed Markdown keeps identity and semantic version in source frontmatter.
The metadata check blocks identity swaps and version decreases. Reviewed
deletions are ordinary Git diffs; they do not require a preparatory lifecycle
state or catalog edit.

## Why This Will Not Recreate The Same Failure

The boundary is structural:

- planner and context commands are read-only with respect to the repository;
- the worktree guard keeps only disposable local claims;
- delivery provenance and checkpoints are expiring CI/recovery artifacts;
- recurring product rules live in their owning executable check;
- new harness behavior must prevent a demonstrated failure or materially
  reduce wall-clock/runner cost; and
- root hygiene rejects the deleted evidence paths if they return.

Adding another tracked task history, global readiness score, or per-agent
database violates this decision even if it is generated automatically.

## Current Implementation Status

| Capability | Status on 2026-08-07 | Remaining work |
|---|---|---|
| Read-only component planner | Implemented and covered by component, CLI, and workflow-wiring tests | Keep path ownership and selection fixtures current when product surfaces change |
| Optional context guidance | Implemented as source-derived stdout/JSON output | Keep project-skill paths and active tool ids valid |
| Tracked evidence retirement | Deletion and source-metadata replacement are in the current migration branch | Merge after stale documentation references and affected checks are clean |
| Thin worktree guard | Implemented with focused Git-repository tests in the current migration branch | Integrate, then use only when concurrent local claims need protection |
| Exact-artifact delivery core | Provenance verification, ordered checkpoint/resume, the Firebase backend adapter, the Admin/Marketing Hosting build/promote adapters, the signed mobile package producer, and the separate no-rebuild internal-store promoter are implemented with adversarial and workflow-wiring tests in the current migration branch | Exercise the web/mobile promotion paths after required live environment access is explicitly approved and configured |
| Exact mobile release routing | The Harness plan carries role-and-platform-specific signed release targets and the mobile producer consumes the CI-authorized target list without widening web or desktop changes | Keep the compatibility role output only until downstream non-release consumers no longer read it |
| Owner settings | GitHub secret scanning, push protection, dependency alerts, and Dependabot security updates are enabled; routine version-update PRs remain disabled | The first dependency scan found 38 patchable npm alerts across 11 packages and three lockfiles. Reduce that backlog in bounded security slices, review the nine open Firebase client-key alerts, and keep environment approvals, token rotation, and any organization migration as separate owner decisions |

Workflow adoption must be reported honestly. A reusable delivery primitive is
not proof that every website, backend, or mobile path already consumes it.

### Measured Migration Evidence (2026-08-07)

| Measurement | Current result | Why it matters |
|---|---:|---|
| Harness-scope staged diff before the backend tranche commit | 200 files, +10,934 / -142,630, net -131,696 lines | The retired evidence/control plane is being removed rather than wrapped in another compatibility layer. The count includes newly added exact-delivery code and uses Git's rename-aware staged diff; three unrelated UI test files are excluded from this scope. |
| Read-only planner `explain` | 0.07 seconds | Ordinary routing is a cheap source-derived query, not a registry refresh. |
| Optional context pack | 0.43 seconds | Context guidance remains bounded and leaves Git status unchanged. |
| Focused backend/harness verification | 76/76 tests in 0.67 seconds | Exact artifact, queue, resume, graph, and workflow contracts execute locally in under a second. |
| Full repository Node verification | 932/932 tests in 8.28 seconds | Removing the retired control plane did not weaken the surviving tool, contract, or workflow test surface. |
| High-cardinality queue fixture | 7,500 artifact records; correct cursor and numeric attempt selected in about 0.4 seconds | Candidate history no longer creates one API request or ZIP download per retained merge. |
| Delivery API shape | catalogue pages + at most 8 fixed calls for a deploying item with an existing cursor | The prior design required roughly three calls per cursor plus one per plan; at 450 retained cursors it exceeded 1,350 calls before package download. The new fixed verification work is a greater-than-99% reduction at that history size, excluding catalogue pagination. |
| Web deployable builds | 2 → 1 production Vite bundle per Admin or Marketing main run | Promotion installs only the pinned Firebase CLI before credentials, consumes the verified package, and performs zero source dependency installation, Vite rebuild, or organizer rematerialization. |
| Web read-only identity preflight | The dedicated account retains only `roles/datastore.viewer`, has no user-managed keys, and has one exact `prod-hosting` environment-subject impersonation binding; both GitHub variables match. Marketing run `31254427583` then completed the first environment-scoped OIDC/Firestore snapshot job and passed only the bounded snapshot artifact to the uncredentialed build | Live inspection caught and closed the deterministic Marketing deployment blocker without granting the build or reader any Hosting, Functions, Rules, Storage, Secret Manager, or Firestore-write authority. |
| Mobile target routing | Role-wide two-platform expansion → exact `consumer-ios`, `consumer-android`, `host-ios`, or `host-android` targets | The producer now avoids unrelated signed builds and rejects Cartesian role/platform widening. |
| Mobile package retention | 14 days → 90 days | Exact signed IPA/AAB packages and their upload receipts now remain available for the full bounded internal-promotion and recovery window, a 6.4× increase. |
| Mobile promotion work | One selected target per dispatch; zero Flutter, Gradle, Xcode archive/export, or signing commands; iOS alone uses `macos-26` while Android uses `ubuntu-24.04` | Internal-store mutation consumes verified signed bytes instead of rebuilding up to four products or spending Android work on an Xcode runner. |
| Combined web/mobile focused contracts | 221/221 tests in 3.67 seconds after final Play rollback, Apple ambiguity, signature, rerun, and exact-claim hardening | Exact package, workflow, graph, target-routing, store-reconciliation, and app-ownership contracts remain cheap enough to run on every relevant change. |
| First full Harness v2 PR run | 30 jobs passed, 2 intentionally skipped, 22m10s wall time; planner 13s and `Required CI` 4s | The control plane is no longer the long pole. Current optimization targets are Admin validation at 21m44s, iOS builds at 16m28s, coverage at 13m43s, and visual integration at 11m42s. |

These are implementation measurements, not the final developer-velocity SLO.
The ten-comparable-PR p95/runner-minute acceptance criterion below remains the
decision point for graph tuning after merge.

## Measurable Acceptance Criteria

The transition is complete only when all of the following are demonstrated:

1. Two ordinary product changes complete with zero tracked governance-evidence
   modifications.
2. Planning and optional context commands leave `git status --short` unchanged.
3. An ordinary documentation change selects the documentation lane rather than
   every toolchain; an ordinary presentation change avoids unrelated backend,
   device, and visual lanes unless an explicit graph edge requires them.
4. High-risk contract, rules, payment, consent, auth, storage, signing, and
   release changes retain their declared checks.
5. The worktree guard proves exact-base creation, overlap refusal,
   dirty/out-of-scope reporting, unpushed-close refusal, and report-only stale
   inspection in focused tests.
6. Delivery tests reject source-SHA mismatch, source-run mismatch, artifact
   tampering, checkpoint-provenance mismatch, and out-of-order stages; they
   prove atomic writes and idempotent replay of passed stages.
7. A deployment adapter promotes the producing run's verified artifact without
   an independent rebuild and resumes from the first incomplete verified stage.
8. After ten comparable pull requests, ordinary-change p95 wall time improves
   by at least 40% or runner-minutes by at least 50%, with no escaped defect
   attributable to an omitted edge. If not, adjust the graph or workflow rather
   than adding another evidence system.

## Owner-Only Settings

The repository can validate configuration shape but cannot perform or prove
these console actions without owner access:

- rotate any exposed App Check debug token and remove it from local agent
  configuration;
- verify required-check rules for `main` and decide separately whether an
  organization transfer for merge-queue availability is worth its OIDC and
  environment-configuration migration cost;
- configure reviewer-protected production environments and approval policy;
- provision environment-specific secrets, parameters, APIs, IAM, and TTL
  policies without storing secret values in the repository; and
- enable store or production mutation only after the owning release runbook's
  external prerequisites pass.

Agents must label these as unverified until live settings are inspected. Their
absence does not justify inventing local substitute state.

## Non-Goals

- A distributed scheduler, agent queue, or command-permission service.
- Continuous worktree heartbeats or automatic cleanup.
- A repository dashboard, readiness score, or replacement evidence database.
- An external artifact database when CI artifact retention is sufficient.
- Atomic multi-PR merge machinery.
- Automatic Remote Config deployment, destructive index deletion, or generic
  production rollback.
- Untracking compile-critical generated source.

## Consequences

Agents receive less ceremony and fewer automatic declarations of readiness.
They must still read owner documents, inspect the actual diff, run the focused
checks, and report external blockers honestly. In exchange, a small product
change no longer needs to rewrite global governance files or satisfy a second
task state machine before its real tests can run.

The desired steady state is deliberately boring: Git preserves the work, the
planner explains what Catch-specific checks apply, CI proves and packages the
change, and delivery promotes the exact bytes that were proved.
