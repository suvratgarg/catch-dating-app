---
doc_id: agent_harness_rearchitecture_fable_review
version: 0.1.0
updated: 2026-08-06
owner: agent_operating_model
status: proposed-for-review
---

# Catch Agent Harness Re-architecture — Fable Review Brief

## Purpose and requested decision

This is a decision proposal for Fable and the Catch integration owner. It
explains why ordinary product changes have become overnight operations, what the
current agent harness gets structurally wrong, which pieces should no longer
exist, what should be consolidated, and what the replacement system should look
like.

This is not a proposal to maintain the current system more carefully. The
recommendation is to replace its operating model.

Requested decision:

1. Approve a 48-hour functional cutover from the current required PR path to a
   smaller Harness v2 path.
2. Keep the current full harness only as a reversible nightly/manual shadow for
   a short validation window.
3. Use days three through five to remove the structures that create shared
   churn, rather than tuning them indefinitely.

This file is a temporary review and cutover artifact. If accepted, its durable
decisions should replace the relevant owner documents and this file should be
retired. It must not become one more permanent documentation layer.

## Executive conclusion

The Catch harness is now a material production-engineering incident.

Its original goals were sound:

- preserve unrelated work;
- make hidden architecture rules executable;
- keep generated contracts synchronized;
- prevent agents from relying on ambient memory;
- provide repeatable CI and deployment proof;
- allow Codex and Claude threads to work safely in parallel.

The implementation no longer achieves those goals efficiently. It is
over-governed and under-orchestrated:

- derived observations and operational history are stored as shared source;
- broad, partly incorrect path matching stands in for a directional dependency
  graph;
- parallel feature work converges on global ledgers and generated registries;
- ordinary PRs run release-grade validation;
- readiness measures governance volume and shape, not operational truth;
- worktree and branch lifecycle rules are documented but not enforced;
- deployment repeats validation instead of promoting an already validated
  artifact;
- each incident adds another permanent rule, scanner, registry entry, baseline,
  receipt, or document.

Every individual mechanism has a defensible origin. Their composition is
globally dysfunctional.

The replacement design rule should be:

> Git stores authored product intent and executable safety guards. Generated
> observations, audit history, agent coordination, CI evidence, deployment
> receipts, and performance metrics do not travel through feature branches.

## Context: what the repository coordinates

Catch is no longer a single Flutter application. The repository coordinates:

- Consumer and Host Flutter applications;
- shared Dart features and domain code;
- Firebase Functions;
- Firestore, Storage, indexes, and security rules;
- schema-derived Flutter, Functions, and admin bindings;
- admin and marketing React applications;
- operations and organizer-intake workflows;
- Widgetbook, design contracts, visual baselines, and captures;
- release, Firebase deployment, and mobile distribution;
- multiple Codex and Claude threads operating concurrently.

That complexity requires a real control plane. It does not require every feature
branch to rewrite a repository-wide audit database and run every release
surface.

The present control plane is distributed across:

- AGENTS.md;
- CLAUDE.md and local Claude permissions;
- docs/agent_operating_model.md;
- docs/ai_first_workflow_guide.md;
- project-local and installed skills;
- tool/agent/context_pack.mjs;
- docs/audit_registry;
- docs/agent_regression_ledger.json;
- tool/tools_manifest.json;
- tool/run.mjs and tool/ci/plan_ci.mjs;
- roughly twenty CI and release workflow surfaces;
- manual worktree, branch, backup-ref, and delegation protocols.

The same policy is repeated in prose, JSON, JSONL, generated catalogs, tool
metadata, workflow YAML, and agent-specific configuration. Those copies drift,
then require more checks to prove that they have not drifted.

## What happened during Cross Paths

Cross Paths is genuinely cross-cutting. It touches consent, privacy, event
capacity, invitations, matches, notifications, payments, Firestore rules, and
multiple UI surfaces. Some complexity was legitimate.

The amount of harness work was not legitimate.

Across the final Explore, invitation, and pair-inventory PRs, #143 through
#145:

- nine CI runs failed and four were cancelled before the final green runs;
- the chain took approximately 10 hours and 12 minutes from the first WIP
  commit to final merge;
- PR #144 and PR #145 selected all thirteen CI targets and exposed about thirty
  job/check contexts;
- the three PRs changed 55, 154, and 163 files respectively;
- after the initial implementations, roughly two corrective commits were
  principally product/source corrections;
- most corrective commits repaired generated governance artifacts, incomplete
  dependency declarations, or unrelated test noise;
- the final phase passed local 4559/4559 readiness, then failed CI because
  adminCallableValidators.ts was stale;
- the sequence repeatedly refreshed provider graphs, widget variants, design
  packs, test and field inventories, localization outputs, audit files, and
  callable validators;
- Phase 2 began before Phase 1 merged and Phase 3 began before Phase 2 merged,
  while all phases touched the same parent-owned canonical/generated files.

The dominant failure was not poor Cross Paths code. The harness could not
cheaply and correctly identify the sufficient proof for the change.

## Measured current state

These figures were measured against main on 2026-08-06.

| Surface | Current state | Why it matters |
|---|---:|---|
| Audit registry | Approximately 382,694 lines | A second product that every feature must maintain |
| passes.jsonl | 2,214 receipts, including 88 duplicate pass IDs | High write volume without strong integrity |
| Recent audit churn | 68 of the last 73 commits touched docs/audit_registry | Parallel branches share a conflict surface |
| Tool manifest | 277 entries, including 85 generators and 80 gates | Too many mirrored orchestration facts |
| Audit rules | 83 active, 4 watch, 0 archived | The intended sunset lifecycle is not operating |
| Regression ledger | 171 active, 0 watch, 0 archived | Historical scars remain permanent taxes |
| Governed docs | 77 catalog entries | Metadata is duplicated |
| Doc metadata drift | 20 version, 16 date, 7 status, and 1 ID mismatch | Gates validate shape, not semantic truth |
| Registered worktrees | 36, including 3 under private temp and 1 prunable | Lifecycle policy is not enforced |
| Worktree disk | Approximately 24 GB | Stale dependencies and builds accumulate |
| Local branches | 123, including 42 dead upstreams and 26 backups | Recovery policy has become accumulation |
| Current PR fan-out | Up to 13 targets and about 30 jobs | Small edits pay monorepo/release cost |

There is a useful live demonstration in the context pack generated for this
document. A single documentation path selected Firestore-rules testing and
action-cardinality rules in addition to documentation rules. That is noisy
routing, not useful fail-closed behavior.

## Root-cause findings

### 1. The dependency model is directionally wrong

tool/run.mjs impacted combines relationship sources, generated outputs, and
consumers into one symmetric pattern set. A changed consumer can therefore
trigger upstream generators and unrelated systems.

Examples from tool/repository_root_manifest.json:

- lib is a consumer of backend contracts;
- lib is a consumer of the design system;
- lib is a consumer of the content system.

An ordinary Dart presentation edit can inherit backend-contract, design,
content, and Flutter checks.

The CI planner separately maps every lib change to Flutter, Functions, Android,
iOS, web, visual integration, and both Consumer and Host.

The planner is also order-dependent. tool/ci/plan_ci.mjs uses find for each
changed path, so an overlapping path receives only the first matching rule.
The current model can be simultaneously over-broad and under-validating.
Reordering the manifest can change safety behavior.

This is a design defect, not a tuning issue.

### 2. Derived evidence is treated as authored source

Audit registries, provider graphs, widget inventories, similarity reports,
coverage snapshots, merge-drop reports, context manifests, and agent metrics
describe a source tree or workflow run. They are observations, not product
intent.

Committing them means:

1. every branch recomputes global state from a different base;
2. parallel work conflicts in files unrelated to the product change;
3. a stale observation becomes a source defect requiring another commit and
   another full CI run.

Evidence should be immutable and keyed by commit SHA. It should not be merged
through every feature branch.

### 3. The harness serializes the work it claims to parallelize

The operating model makes canonical docs, audit registries, generated files,
pass receipts, and final verification parent-owned. Subagents run in parallel
only until integration reaches those files. The critical path becomes one
parent repeatedly resolving generated and documentation conflicts.

That prevents independent agents from becoming competing sources of truth by
creating a global parent mutex.

The correct model is parallel authored-source work plus a serialized automated
integration queue that generates shared runtime outputs once.

### 4. Readiness measures governance shape, not operational health

check_agent_readiness verifies required files, expected strings, manifest
entries, ledger shape, and metric parseability. The denominator grows as
historical records accumulate.

It does not establish that:

- all affected outputs are current;
- the task is in a valid isolated worktree;
- dependencies resolve from that worktree;
- the branch is based on current main;
- path ownership is non-overlapping;
- the CI plan is sufficient and minimal;
- deployment has an environment lease;
- document front matter agrees with its catalog.

The numeric readiness score should not exist.

### 5. Checks are not tiered by cost or confidence

All selected workflows start after planning. Expensive native, visual, React,
emulator, and full-suite jobs can run while a cheap generated-drift check is
already destined to fail.

The current pipeline also repeats work:

- four Flutter shards run, then coverage reruns the full suite serially;
- six tool buckets independently install Flutter, npm, Functions dependencies,
  and system tooling;
- a shared Flutter change can build four web, two Android, and two iOS variants;
- deployment reruns Functions and rules validation already completed by CI.

Release confidence and pull-request feedback are different products. They need
different tiers.

### 6. Generator ownership is incomplete and fragmented

The local contract loop checked the main schema generator but omitted the admin
callable-validator generator. Other changes separately required provider graph,
widget variant, context pack, and inventory refreshes.

There is no transactional command that answers:

> Given these authoritative inputs, what complete set of downstream outputs is
> stale across Flutter, Functions, admin, marketing, rules fixtures, and docs?

Agents are expected to remember topology from several documents and manifests.
CI then discovers the forgotten edge.

### 7. Documentation has competing authorities

Document front matter, doc_versions.json, doc_summaries.json, docs/README,
skills, regression entries, and tool metadata repeat ownership and routing.

The copies disagree. For example, docs/cross_paths.md says version 1.7.0 and
status implemented-default-off, while doc_versions.json says version 1.3.0 and
status active.

The docs index lists eleven files as retirement-ready, but they remain in the
maintenance surface. widget_catalog.md contains thousands of lines of edit
history that Git already records.

Docs should describe current architecture, decisions, invariants, and runbooks.
They should not duplicate Git history or generated inventory.

### 8. Rule accumulation has no effective decay

The documented lifecycle says solved rules move from active to watch to
archived. In practice, all 171 regression entries remain active and none is
archived. Eighty-three audit rules remain active.

Every painful incident makes the next task read or run more. There is no cost
budget, expiry, or proof that the guard remains useful.

A real regression should normally become a focused test beside the affected
code. Temporary exceptions should be narrow waivers with an owner and expiry.
Historical incidents belong in closed issues or postmortems, not active prompt
context.

### 9. Worktree safety is prose, not a lifecycle service

Policy correctly says worktrees must be durable, short-lived, isolated, and
never under OS temp. Actual state includes thirty-six registered worktrees,
three under private temp, one prunable registration, and roughly 24 GB of data.

Recent Cross Paths worktrees symlinked node_modules from main. Because npm
workspace links are relative, package source could resolve from main instead of
the feature tree. This creates false-green and false-red risk.

There is a worktree protocol but no broker, lease, heartbeat, dependency
fingerprint, expiry, or reaper.

### 10. Deployment is not a resumable delivery system

Automatic dev deployment waits for CI, then reruns Functions lint/tests and
Firestore/Storage emulator tests. A broad backend boolean deploys Functions,
indexes, Firestore rules, and Storage rules.

Deployment can partially succeed. A later transient failure can leave earlier
targets live. The runbook generally directs failed automatic deployment into
another repair PR, turning infrastructure failure into a source-change cycle.

Deployment should consume an immutable receipt for one exact SHA, select
explicit resource groups, checkpoint successful stages, re-check environment
state, and resume the same SHA when safe.

### 11. Agent-specific policy copies drift while authority is broad

The installed catch-recursive-audit skill mandates a global refresh at the
start of every pass and shared ledger writes at the end. It points to deleted
files. Project instructions, installed skills, Codex configuration, and Claude
configuration do not share one executable policy source.

At the same time, local Claude permissions allow broad wildcard Git, shell,
Firebase deploy, and production-wrapper commands without a shared deployment
lease. A debug token appears in local configuration and should be removed and
rotated without reproducing it in logs or this document.

The system is strict in prose but permissive at the mutation boundary.

## The four kinds of repository artifact

“Move generated artifacts out of Git” needs a precise boundary.

| Category | Examples | Target policy |
|---|---|---|
| Authored product intent | Source, schemas, tests, specs, ADRs, runbooks | Track and review |
| Compile-critical generated source | Flutter DTOs, Functions types, admin validators | Prefer deterministic bootstrap; if tracked, only integration writes it |
| Derived audit evidence | Inventories, graphs, receipts, metrics, coverage | Never travel through feature branches |
| Deployable build artifacts | IPAs, AABs, web bundles, Functions packages | Immutable artifact store with provenance |

Only derived audit evidence categorically leaves Git immediately.
Compile-critical generated source may remain during cutover until integration
generation, offline builds, and review visibility are proven.

## Components that should not exist in Harness v2

These are deletion decisions, not optimization suggestions.

| Current component | Decision | Replacement |
|---|---|---|
| files.jsonl | Remove from trunk | Optional on-demand inventory artifact |
| passes.jsonl | Remove from trunk | Immutable CI/task receipt |
| agent_metrics.jsonl | Remove from trunk | External workflow telemetry |
| Tracked merge-drop reports | Remove | Attach to reconciliation run or PR |
| Tracked widget/provider/l10n/definition inventories | Remove | Generate on demand or nightly |
| Recursive file stamping | Eliminate | Source review and executable checks |
| Mandatory pass receipts | Eliminate | Required exact-SHA check result |
| doc_versions as second metadata source | Eliminate | Front matter plus generated catalog |
| doc_summaries as hand-maintained routing | Eliminate | Component-selected owner docs |
| Global active regression ledger | Eliminate after migration | Tests or expiring local waivers |
| Global active rules ledger | Eliminate after migration | Component invariants and tests |
| Numeric readiness scoring | Eliminate | Named invariants in harness doctor |
| Mandatory context-pack preloading | Eliminate | harness explain for affected scope |
| 277-entry tool manifest as router | Replace | Small component graph and standard operations |
| Reverse rule/tool/vacuity meta-system | Eliminate | Tests of planner and checks |
| Giant widget catalog and edit history | Replace | Widgetbook/source plus concise guidance |
| Copied architecture code exhibits | Eliminate | ADRs, boundaries, tests against live source |
| Routine manual backup branches | Eliminate | Automatic expiring recovery refs |
| Forced WIP commits for interrupted sessions | Eliminate | Broker autosave and explicit commits |
| Manual delegation packets and metric commits | Eliminate | Machine-recorded task lease |
| Shared dependency directories | Prohibit | Isolated installs with shared download caches |
| Long-lived unleased worktrees | Prohibit | TTL, heartbeat, close, and reap |
| Full role/platform builds for every Flutter edit | Remove from PR default | Merge smoke, nightly and release matrix |
| Second serial coverage run | Eliminate | Merge coverage from shards |
| Backend revalidation during deployment | Eliminate | Consume integration receipt |
| Repair PRs for transient deploy failures | Eliminate | Resume the same SHA and stage |

Useful underlying tests, scanners, generators, and security checks do not need
to be deleted merely because their meta-system is deleted. Keep the guard;
remove the governance machinery around it.

## What should be consolidated

### Agent instructions

Consolidate AGENTS.md, the operating model, AI-first guide, project skills,
installed Catch skills, and Claude/Codex procedures into:

1. A universal AGENTS.md of roughly fifty lines.
2. One small executable harness CLI.
3. Tiny Codex and Claude adapters that call the same CLI and add no Catch policy.
4. Feature-local docs and ADRs for domain decisions.

The user-facing lifecycle should be:

    harness task start
    harness explain --affected
    harness check --affected
    harness task finish

### Rules, regressions, and tools

Consolidate rules, regression routing, most tool-manifest routing, context-pack
commands, CI impact routing, generator ownership, and deployment targeting into
one directional component model.

Each component exposes standard operations:

- format;
- lint;
- test;
- generate;
- build;
- deploy.

Underlying scripts remain independently runnable. They no longer each need a
separate role, reverse mapping, owner-doc anchor, baseline receipt, and vacuity
proof.

Avoid one giant globally contended harness file. Use small component manifests
composed by a thin planner, with one schema and order-independent validation.

### CI workflows

Consolidate CI into four entry workflows:

1. Pull request.
2. Merge queue.
3. Nightly.
4. Release.

Shared actions can remain behind those entrypoints. Bootstrap each ecosystem
once per relevant run or cache it by lockfile and toolchain.

### Generators

Register all source-derived outputs in one graph:

    authoritative contract
      -> Flutter bindings
      -> Functions bindings and validators
      -> admin callable validators
      -> public bindings where applicable
      -> rules fixtures and index metadata

harness generate --affected --check reports every stale downstream in one run.
Write mode generates into a temporary directory, compares the complete set, and
atomically replaces output. Deterministic committed output has no timestamps.

### Documentation metadata

Use front matter as the one authored source for ID, owner, status, and optional
replacement. Let Git provide revision history. Generate catalog and read routing
in CI.

### Worktrees and delegation

Consolidate worktree creation, branch creation, dependency setup, path and
contract ownership, resource scheduling, heartbeat, cleanup, and task state
into one broker. Agents must not reproduce a protocol from prose.

### Validation and delivery

Use the same component graph for local checks, PR jobs, merge checks,
generation, and deployment. They are different queries over one model.

## Target architecture

    Agent request
      -> broker creates a hermetic leased worktree
      -> authored source/contracts/tests change
      -> directional component graph explains affected ownership
      -> cheap deterministic preflight
      -> affected PR checks
      -> serialized merge queue rebases
      -> transactional shared generation runs once
      -> integration proof produces exact-SHA receipt
      -> merge and automatic task cleanup
      -> exact-target deployment consumes receipt
      -> full role/platform matrix runs nightly and before release

### Authored source plane

Git contains application/backend source, schemas, contracts, executable tests,
security rules, compact feature specs, short current-state architecture, ADRs,
and deployment configuration.

Git does not contain continuously regenerated evidence about itself.

### Orchestration plane

Small component manifests define:

- source roots;
- upstream dependencies;
- generators and outputs;
- runtime consumers;
- checks by confidence tier;
- deployable resource groups;
- explicit high-risk blast radius.

Graph semantics are directional and order-independent:

- a source change follows explicit downstream edges;
- a consumer edit does not imply an upstream generator;
- overlapping ownership composes as a union or fails as ambiguous;
- unknown paths fail planning clearly;
- dynamic Flutter, asset, flavor, Firebase, and platform dependencies are
  declared where static discovery is insufficient;
- representative fixtures prove selection.

The first implementation can remain Node-based and invoke useful existing
scripts. Cutover does not require rewriting every checker.

### Worktree and task plane

One task equals one managed change-set lease:

    task ID
    agent and thread identity
    branch and base SHA
    worktree path
    owned and excluded paths
    contract dependencies and prerequisite change sets
    generated outputs and affected components
    created time, heartbeat, and expiry
    dependency fingerprints
    environment and scarce-resource leases
    PR and merge disposition

Path leases alone are insufficient: disjoint files can encode incompatible
contract decisions. The broker must model prerequisite/stacked change sets and
shared contract ownership.

harness task start:

- fetches and starts from current main unless explicitly stacking;
- creates a durable worktree outside OS temp;
- rejects overlapping or semantically incompatible leases;
- creates isolated dependency directories;
- shares download caches, never installed dependency trees;
- records an automatic expiring recovery ref.

harness task finish:

- records disposition outside tracked source;
- removes merged worktrees;
- deletes task branches when safe;
- releases path, simulator, Flutter, and environment leases.

harness task reap --dry-run reports abandoned leases. Cleanup requires proof
that work is clean or preserved remotely/recoverably, the PR is merged or
abandoned, and untracked files are quarantined.

### Derived evidence plane

Use build/harness, GitHub Actions artifacts, or an authenticated object store
keyed by SHA for:

- inventories and context explanations;
- provider and dependency graphs;
- pass receipts and telemetry;
- coverage and visual reports;
- reconciliation evidence;
- document catalog and integration state.

Evidence has an owner, retention policy, access controls, and a PR link. It does
not become a branch conflict surface.

### Integration plane

Parallel agents submit authored source, contracts, and tests. A merge queue:

1. rebases onto current main;
2. batches compatible change sets where useful;
3. runs transactional shared generation once;
4. exposes generated diffs for review;
5. runs affected integration checks;
6. produces an immutable exact-SHA receipt;
7. merges and closes the task automatically.

If compile-critical generated source remains tracked, only integration writes
it. Global outputs should be removed or sharded so the queue does not become a
new parent-agent bottleneck.

### Delivery plane

Deployment consumes the integration receipt and immutable build artifacts.
The receipt includes source SHA, artifact digest, toolchain and generator
versions, relevant configuration identities, and environment-independent build
inputs.

Delivery must:

- deploy the exact validated artifact;
- select explicit resource dependency groups;
- acquire an environment lease;
- preserve approvals and destructive-action confirmation;
- record each successful stage;
- re-check current environment state before resume;
- retry the same SHA when safe;
- retain a manual full-deploy fallback.

Not every Firebase resource is safely partial. Shared Functions dependencies,
desired-state rules, indexes, and data migrations need explicit grouping and
separate rollback policy.

## Validation tiers

| Tier | Target | Required work |
|---|---:|---|
| Local/pre-push | Under 2 minutes | Format, affected analysis/tests, generation freshness |
| PR preflight | First signal under 2; total under 10 | Ownership, schemas, affected typechecks/tests, deterministic drift |
| Merge queue | Under 15 ordinary; under 20 contract | Rebase, generation, affected integration, relevant compile smoke |
| Nightly | Exhaustive | All roles/platforms, visuals, broad scanners, complete coverage |
| Release | Exhaustive and environment-specific | Signed artifacts, provenance, deployment and rollback proof |

Heavy jobs do not begin until deterministic preflight succeeds. Flutter coverage
is merged from existing shards rather than rerunning the suite.

## Expected workflows

### Flutter presentation edit

Required: format changed Dart, analyze the feature, run affected tests, and
possibly one Consumer compile smoke in merge queue.

Not selected: Functions, rules, Host, three platform builds, full visual
integration, or global audit regeneration.

### Schema or contract edit

Required: validate schema, calculate every downstream, check all generated
consumers transactionally, run focused compatibility/security tests, and let
integration write tracked generated source once.

This path is broader because the edge is real.

### Documentation edit

Required: Markdown/front-matter validation, links, and ephemeral catalog check.

Not selected: Flutter, Functions, emulators, action-cardinality, or native
builds.

### Transient deployment failure

Preserve the validated artifact and successful stages, classify the failure,
re-check environment state, and retry the failed stage against the same SHA.
Do not create a no-op source commit.

## Safety capabilities that must survive

The redesign removes meta-governance, not product safety.

- dirty-work isolation and one writer per owned path/contract;
- protected main and serialized integration;
- deterministic contract generation across every consumer;
- formatter, analyzer, compiler, and focused tests;
- authentication, privacy, consent, payment, migration, Firestore, and Storage
  security tests;
- secret scanning and environment-scoped credentials;
- production leases, dry runs, and explicit destructive-operation approval;
- immutable build/deploy provenance;
- rollback and idempotent/resumable delivery;
- affected native checks for native changes;
- full role/platform validation nightly and before release;
- manual full-validation and full-deploy escape hatches;
- conservative handling of unknown ownership during migration.

The criterion is whether a check protects a product or delivery invariant, not
whether it has extensive governance metadata.

## Rapid cutover: relief in 48 hours, target in five working days

This does not require waiting two weeks before development improves.

The strategy is demolition-first and reversible:

- remove v1 from the required PR path quickly;
- keep it as a non-blocking nightly/manual comparison;
- preserve high-risk executable checks in v2;
- remove obsolete files after v2 already carries daily work.

### Hours 0–2: declare a harness incident

- Freeze additions to rules, scanners, ledgers, generated audit artifacts, and
  governance docs unless security-critical.
- Stop requiring pass receipts and file stamps for product work.
- Record current branch protection and deployment settings.
- Create an immutable Harness v1 preservation ref.
- Archive the audit registry outside trunk without destroying history.
- Assign one cutover window and the parallel streams below.

This is not a product-development freeze.

### Hours 2–8: build the minimum v2 graph and preflight

- Introduce small component manifests and the planner.
- Add fixtures for presentation, domain, contract, Functions, rules, docs,
  native iOS, and unknown-path edits.
- Make graph evaluation order-independent.
- Add one affected generator-freshness aggregator.
- Include the missing admin callable-validator edge.
- Keep auth, privacy, payment, migration, and rules paths conservative.

### Hours 8–16: replay real failures

Replay recent PR path sets and deterministic failures. V2 must catch:

- stale callable validators and schema bindings;
- missing dependencies;
- analyzer and affected test failures;
- malformed, ambiguous, and unmapped ownership.

V2 must classify network, registry, runner, signing, and cloud outages separately
from source failure. Run v2 informationally beside v1 and compare selection.

### Hours 16–24: cut over required PR checks

- Make deterministic preflight the first required stage.
- Make affected jobs depend on preflight.
- Expose one stable aggregate check such as PR Gate.
- Move v1 full validation to manual/nightly shadow.
- Preserve old branch protection for ten-minute rollback.
- Keep affected emulator/security/contract checks required.
- Remove the lib-to-everything default.
- Move full coverage and full platform/role matrix out of ordinary PRs.

At this point, ordinary development should be fast even though cleanup remains.

### Hours 24–48: make parallel work hermetic

- Add minimal task start, doctor, finish, and reap commands.
- Reject temp worktrees, shared dependencies, stale bases, and overlapping
  leases.
- Reuse download caches, not installations.
- Stop feature branches updating global audit artifacts.
- Merge coverage from Flutter shards.
- Consolidate repeated CI setup.
- Keep v1 full validation nightly and compare it with v2.

This is the functional cutover and the end of overnight small changes.

### Day 3: remove derived evidence from Git

- Stop tracking file/pass/metric ledgers and generated audit reports.
- Move useful graphs, inventories, coverage, and doc state to CI artifacts.
- Replace doc registry metadata with front matter.
- delete or archive retirement-ready docs;
- remove edit-history sections from living catalogs;
- reduce agent context to the router, feature spec, and relevant ADRs.

### Day 4: centralize generation and delivery receipts

- Put shared generation under integration ownership.
- Generate all consumers transactionally.
- Produce a checksummed receipt keyed by SHA and artifact digest.
- Make dev deployment consume the receipt.
- Model Functions/rules/index/storage resource groups explicitly.
- Add stage receipts and safe same-SHA resume.
- Retain the manual full-deploy path.

### Day 5: delete obsolete control-plane machinery

- Remove readiness scoring.
- Migrate real regressions into tests or expiring waivers.
- Retire the flat tool manifest as router while preserving useful scripts.
- Replace the operating model and AI guide with the short lifecycle.
- Make v1 scheduled/manual only after acceptance criteria pass.
- Reap worktrees and dead branches only after proving ownership and preservation.

## Parallel execution plan

| Stream | Owns | Excludes |
|---|---|---|
| A — CI and component graph | Planner, fixtures, preflight, affected workflow, coverage | Docs/audit deletion and deployment |
| B — Knowledge and evidence | Instructions, registry externalization, doc metadata, archive | CI graph and deployment |
| C — Task and delivery | Worktree broker, leases, receipts, targeted deployment | CI graph and canonical instruction decisions |
| Integrator | Component schema, branch protection, generated policy, cutover, rollback | Delegates implementation but serializes shared decisions |

The graph is the critical path. Documentation cleanup must not delay the 48-hour
cutover.

## Reversibility and migration controls

- Preserve v1 under an immutable tag/ref.
- Keep v1 workflow_dispatch and nightly for at least seven days.
- Keep one documented switch between PR Gate and legacy Required CI.
- Preserve useful scanners during the first 48 hours.
- Archive historical ledgers rather than erasing them.
- Keep compile-critical generated source tracked until integration generation
  is proven.
- Keep manual full-validation and full-deploy paths.
- Default unknown high-risk configuration to conservative validation.
- Require three consecutive green nightlies before deleting legacy workflows.
- Automatically quarantine or revert a merge that introduces a confirmed
  nightly regression; nightly failure cannot be a passive dashboard event.

Rollback:

1. require legacy Required CI again;
2. disable PR Gate;
3. invoke legacy deployment if needed.

Target rollback time: under ten minutes.

## Acceptance metrics

### Speed

- Median actionable first signal under 90 seconds.
- p95 first signal under 5 minutes.
- Ordinary PR median under 8 minutes and p95 under 15.
- Affected contract PR under 20 minutes.
- No more than five required jobs for ordinary Flutter feature work.

### Change amplification

- Zero audit-registry changes in ordinary product PRs.
- Zero committed pass receipts or agent-performance metrics.
- Zero non-runtime generated doc churn in product PRs.
- Presentation edits select no backend or release-build lane.
- Docs edits run no Flutter, backend, emulator, or native build.

### Correctness

- V2 catches every deterministic reproduced failure in the historical sample.
- One generator command catches every registered stale downstream.
- Native changes select the relevant build.
- Contracts and security-sensitive paths retain their validation.
- Three consecutive full nightlies pass before legacy deletion.
- Escaped defects are measured alongside speed gains.

### Parallel development

- Zero active worktrees under OS temp.
- Zero shared/symlinked dependency installations.
- Zero stale registrations after task closure.
- Merged worktrees removed within 24 hours.
- Zero product-PR conflicts caused by generated audit evidence.

### Delivery

- Deployment consumes the exact validated artifact.
- Failed stages resume without source changes.
- Unchanged resource groups are not redeployed unless desired-state semantics
  require the group.
- Environment concurrency is leased.
- Partial state is visible and safely resumable.

### Harness quality

Do not replace readiness with another vanity score. Track externally:

- first-signal and PR wall time;
- merge-queue wait;
- deterministic and infrastructure failure rates;
- rerun and flaky-test rates;
- generated-churn ratio;
- worktree conflict/cleanup rates;
- deployment retry/resume rate;
- escaped defects;
- number and age of expiring waivers.

## What not to do

- Do not optimize 277 manifest entries individually.
- Do not add another scanner for the manual worktree protocol; build the broker.
- Do not replace JSONL ledgers with another tracked ledger.
- Do not create a permanent migration tracker for this work.
- Do not keep v1 required for weeks while v2 accumulates features.
- Do not remove executable privacy, payment, contract, or rules tests.
- Do not hide generated API changes from review.
- Do not blindly delete existing worktrees or branches.
- Do not reproduce the local debug token; remove and rotate it.
- Do not let a full-validation label become the routine path.
- Do not create one enormous globally contended v2 manifest.
- Do not measure success by rules, receipts, tools, or assertion counts.

## Decisions requested from Fable

Fable should respond to these as one architecture decision:

1. Should the recursive audit registry leave active trunk rather than be tuned?
2. Should rules/regressions resolve to tests or expiring local waivers?
3. Should front matter be the sole authored document metadata?
4. Should one directional component model drive checks, generation, and deploy?
5. Which compile-critical generated sources remain tracked, and why?
6. Can fresh clones build reproducibly and expose generated API diffs?
7. Should feature agents stop writing shared generated outputs?
8. Does Fable approve a 48-hour required-path cutover with v1 shadowed?
9. Which executable checks form the initial high-risk allowlist?
10. How should dynamic Flutter, asset, flavor, and Firebase edges be represented?
11. How should stacked, mutually dependent change sets merge atomically?
12. Where are authenticated SHA receipts retained, and for how long?
13. How should leases work across Codex, Claude, and possibly multiple machines?
14. What is the crashed-lease recovery and existing-worktree cleanup proof?
15. Which Firebase resources can deploy partially and which must remain grouped?
16. What automatic quarantine/revert follows a nightly regression?
17. What prevents the new CLI/manifests becoming another control-plane product?
18. Does Fable agree that transient deployment failure resumes the same artifact?

If the answers are broadly yes, the next artifact should be a small component
schema and implementation PR, not another design document.

## Evidence and reproduction commands

The main findings can be reproduced without mutating the repository:

    git status --short --branch
    git worktree list --porcelain
    git worktree prune --dry-run --verbose
    du -sh .claude/worktrees
    git branch --format='%(refname:short)' | wc -l
    wc -l docs/audit_registry/*
    git log --since='30 days ago' --pretty=format:%H \
      -- docs/audit_registry | sort -u | wc -l
    node tool/agent/check_agent_readiness.mjs
    node tool/agent/context_pack.mjs \
      --task agent-harness-rearchitecture-fable-review \
      --paths docs/plans/agent_harness_rearchitecture_fable_review.md
    node tool/ci/plan_ci.mjs \
      --paths lib/cross_paths/domain/cross_paths_feature_config.dart --json

Relevant implementation sources:

- AGENTS.md;
- CLAUDE.md;
- docs/agent_operating_model.md;
- docs/ai_first_workflow_guide.md;
- docs/audit_registry/README.md;
- docs/README.md;
- tool/agent/context_pack.mjs;
- tool/agent/check_agent_readiness.mjs;
- tool/run.mjs;
- tool/ci/plan_ci.mjs;
- tool/repository_root_manifest.json;
- .github/workflows/ci.yml;
- .github/workflows/flutter-ci.yml;
- .github/workflows/tools-ci.yml;
- .github/workflows/app-build-matrix.yml;
- .github/workflows/firebase-dev-deploy.yml;
- docs/release_operations.md;
- the installed catch-recursive-audit skill;
- local Claude and Codex configuration.

## Final recommendation

Treat the harness as a product with a latency budget and a strict boundary, not
as an ever-growing collection of proof mechanisms.

Cut ordinary PRs over to a small, directional, affected-only Harness v2 within
48 hours. Then collapse the recursive-audit meta-system, move derived evidence
outside Git, automate change-set/worktree lifecycle, centralize generation in
integration, and make delivery consume exact-artifact proof.

This preserves the hard-won safety properties while removing the structures
that have made safe development prohibitively slow.
