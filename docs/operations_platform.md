---
doc_id: operations_platform
version: 1.1.2
updated: 2026-07-14
owner: operations_platform
status: active
---

# Operations Platform

## Purpose

`operations/` is Catch's runtime boundary for durable, resumable business
workflows that may be performed by people, deterministic workers, or bounded
agents. Supply Intake is the reference workflow. Future admin-console workflows
may reuse the platform primitives, but they should only become operations when
they need durable work items, retries, leases, budgets, decisions, or receipts.

This boundary keeps three concerns separate:

| Surface | Owns | Does not own |
|---|---|---|
| `operations/` | Workflow plans, runs, work items, leases, checkpoints, action receipts, inference budgets, source profiles, learning evaluations, and blocked promotion evidence | Repository linting, schema generation, release deployment, or React presentation |
| `tool/` | Repository checks, generators, migrations, deploy helpers, data repair, and compatibility producers consumed by operations adapters | Long-running business workflow state or agent orchestration |
| `tool/remote_ops_manifest.json` | Inventory and preconditions for commands that can read or mutate external systems | Workflow queues, run state, or autonomous scheduling |

The existing organizer-intake, host-discovery, and event-guide tools remain
compatibility producers while Supply Intake adopts their artifacts. New
orchestration belongs in `operations/`; do not extend those legacy folders with
another workflow engine.
`operations-tool-boundary-v2` scans every code file under `tool/` for direct
operations-runtime imports and for durable-workflow signals aggregated by tool
subtree. File-count ceilings remain as an additional ratchet for the three
known legacy artifact producers.

## Reference Layout

```text
operations/
  src/cli/                         stable JSON command surface
  src/platform/                    reusable execution and persistence ports
  src/workflows/registry.mjs       workflow inventory and factories
  src/workflows/supply-intake/     reference business workflow
  test/                            engine, adapter, safety, and replay tests

contracts/operations/              canonical persisted-record JSON Schemas
functions/src/operations/          trusted persistence and worker-side adapters
functions/scripts/operations/      trusted, apply-guarded projection operators
functions/src/admin/               admin-authenticated read/decision adapters
admin/src/features/intake/         task-first human-review presentation
```

Only platform primitives and generic token validation belong in
`operations/src/platform`. Each workflow owns its stage order, lifecycle and
entity vocabulary, transition graph, candidate selection, source policy,
extractors, reconciliation policy, and publication eligibility. The registry
binds those definitions to a manifest, executable factory, and supported CLI
command subset. Lifecycle meaning is explicit: each descriptor and frozen plan
maps its workflow-owned statuses into active, published, and expired semantic
groups. Generic queues, canonical projections, counters, terminal cleanup, and
reconciliation summaries use that mapping rather than Supply Intake strings.

## When A Feature Is An Operation

A feature should use the operations platform when at least one of these is true:

- work survives a process restart or spans multiple attempts;
- more than one worker can contend for the same item;
- an external or model budget must be enforced;
- a human decision must be joined back to an automated run;
- the result can cause a public, financial, safety, access, or data mutation;
- replay, reconciliation, or a durable audit receipt is required.

Read-only dashboards and ordinary request/response mutations should keep their
existing feature/controller/API architecture. Do not force every admin feature
into a universal workflow DSL.

## Canonical Runtime Records

The canonical schemas live under `contracts/operations/`. The minimum durable
record set is:

- `OperationRun`: workflow/version, execution mode, status, budgets,
  checkpoints, counters, and terminal summary;
- `OperationWorkItem`: one source entity, one exclusive primary stage, task
  flags, blockers, decision provenance, lease state, and lifecycle status;
- `OperationActionReceipt`: immutable, hash-bound evidence for every attempted
  state transition or side effect;
- `OperationDecision`: deterministic, model, agent, or human judgment with
  input/output hashes and policy versions;
- `OperationLease`: bounded ownership with expiry and compare-and-set renewal;
- `OperationPublicationPlan`: proposed writes and preconditions, separate from
  their execution;
- `OperationRuleProposal` and `OperationRuleEvaluation`: the source-learning
  lifecycle and its fixture/canary evidence.

Identifiers and idempotency keys must be deterministic for identical inputs.
Retries may append receipts but must not duplicate work items or external
effects. Persisted timestamps use UTC ISO-8601 strings at JSON boundaries and
Firestore timestamps inside trusted repositories.

The local reference runtime preflights requested run ids, reserves a serialized
plan idempotency mapping before it creates the run, and removes only its exact
mapping if a concurrent run-id collision wins. It then repairs a missing or
incomplete run on replay. It
reconstructs work-item budget consumption from durable inventory before
resuming checkpoints. Lease guards verify directory identity and sole ownership
before entering, retain a guard if any recorded owner is live, and can
quarantine a guard orphaned by a dead process. Recovery first installs a unique
marker and then rechecks directory identity and every owner, so an acquirer
that appears during stale inspection cannot be quarantined. Lease heartbeats always use the
live lease clock; deterministic `--now` affects workflow evidence only and can
never freeze ownership expiry. Promotion replay similarly validates an
immutable, safety-outcome-bound receipt and repairs its companion audit action
when an interruption occurs. Completed runs bind their sorted work-item
inventory into a durable hash; post-run commands reject cardinality, budget,
join, counter, or content drift. Completion, promotion, and reconciliation
replay validate deterministic action identities and repair a missing companion
action after interruption. Reconciliation never edits its completed source: it
creates a lineage-bound immutable child run with new work-item ids, so an
already imported Firestore snapshot remains replayable. Every entry point binds
persisted mode, capabilities, budget, plan, and workflow contract back to
frozen evidence.

## Supply Intake Stage Contract

Supply Intake exposes the same inventory to its CLI, persistence adapter, and
admin UI. A work item has exactly one primary review stage:

```text
incoming -> verify -> resolve -> ready
```

Publication, rejection, expiry, cancellation, and takedown are lifecycle
outcomes, not overlapping review stages. Concerns such as
`possible_duplicate`, `official_source_required`, `missing_location`, and
`human_review_required` are task flags or blockers. The browser must render the
persisted projection rather than independently reconstructing stage membership.
Supply Intake declares `active` as active, `published` as published, and
`expired` as expired; those literal values are workflow vocabulary, not a
generic platform requirement.

The Event and Organizer Intake tabs remain the human-review surfaces. The
operations projection adds run health and exception inventory without replacing
their source evidence or backed decision callables.

### Admin projection bridge

`export-admin` emits one canonical, hash-bound run snapshot. The trusted
`operations:import-admin-projection` operator validates that snapshot again,
requires shadow mode and zero network/model/public-write/rule-deploy authority,
and writes only `operationRuns` and `operationWorkItems`. Dry run needs no cloud
credentials. Apply requires an explicit environment, the exact Firebase
project configured for that environment, project-aware production confirmation,
and matching run-id confirmation plus Application Default Credentials.

Work items are created before the run record, so a new run is not discoverable
half-imported. Firestore persistence revisions start at zero; the local source
revision and whole-export hash remain in reserved projection metadata. Imported
run snapshots are immutable: replay verifies the run and every expected item,
repairs missing items, rejects changed records, and enforces the frozen
`maxWorkItems` budget. Only completed Supply Intake shadow snapshots can be
exported or imported. Post-run promotion evidence does not change the frozen
run action counter or canonical export, and a changed export at the same path
fails instead of overwriting prior evidence. Changed content must use a new run
id. The importer
cannot write events, organizers, public pages, publication plans, or any
source/provider state.

`reconcile` follows that immutability rule locally. It creates a new completed
run whose plan binds the source run, source plan hash, source inventory hash,
and UTC reconciliation window. That child can be exported and imported without
conflicting with the prior snapshot.

One run is capped at 10,000 work items. Planning fails with
`RUN_SHARD_REQUIRED` before execution when the projected market/source scope is
larger; callers must split the input into multiple runs rather than creating an
unbounded queue. The platform run assertion, workflow plan assertion, JSON
Schema, Functions validator, importer, and pagination capacity tests enforce
the same 1-to-10,000 bound. At 200 items per request, a maximum exception lane
requires at most 50 reads. The callable allows 120 reads per minute, the query
does not automatically retry, and the contract proves that one complete
exception hydration plus a complete lazy ordinary drain remains inside that
window.

Full-run stage and human-review aggregates travel on the run metadata so the
admin rail remains accurate when a work-item response is paginated. A selected
run without authoritative aggregates fails closed; active plus terminal must
equal total inventory, stage totals must equal active inventory, and human
review cannot exceed active inventory. The controller loads one ordinary page,
then drains only the run-pinned, server-filtered `human_review_required` lane so
every counted exception is inspectable. Its ordinary cursor remains available
through explicit **Load 200 more** pages. Cursor loops, cross-run pages, summary
changes, and cardinality mismatches fail closed. Published and terminal history
does not appear in active stage queues, and terminal records cannot retain a
human-review owner, flag, or blocker. Run pagination remains explicit
loaded-page state. Both item lanes order by document id; runs order by
`updatedAt` and document id rather than treating lexical ids as time.

## Execution And Authority Lanes

Every run declares an execution mode and fails closed when it requests a
capability that mode does not grant.

| Lane | Allowed | Default |
|---|---|---|
| Shadow | Local/replay inputs, deterministic reducers, cached schema-valid model output, review queues, plans, and receipts | Enabled |
| Assisted | Approved source fetches and bounded model calls through injected providers; no public writes | Disabled until source/model policy exists |
| Publication | Execution of a reviewed publication plan by a separately authorized worker | Disabled until write policy, IAM, and rollback/takedown paths exist |

React clients never receive worker credentials and never invoke source or model
providers directly. Admin callables require the existing role, App Check, input
validation, rate-limit, and audit-log boundaries. Workers use separate service
identities and may only access the collections and side effects required by
their workflow role.

## Target Deterministic-First Decision Order

Supply Intake resolves each task in this order:

1. exact identifiers, canonical URLs, schema checks, source policy, and other
   deterministic rules;
2. previously activated source-specific declarative rules;
3. cached, hash-matched, schema-valid inference;
4. bounded model inference when the run grants a model budget;
5. human review when confidence, conflict, rights, policy, or publication risk
   remains unresolved.

The target human-escalation rate is an operational SLO, not an unsafe bypass.
Measure it alongside sampled precision, stale/incorrect listing rate, and
correction/takedown latency. Promotion thresholds must be calibrated in shadow
runs before the system is allowed to optimize for a sub-one-percent exception
rate.

The shipped Supply Intake run currently performs only step 1 over reviewed,
local compatibility artifacts. It does not fetch sources, consume activated
learning rules, invoke the guarded model runner, or join live Event/Organizer
admin decisions directly. A backed human decision appears in a later run only
after the owning legacy artifact is regenerated. Cache, model, and provider
ports are safe scaffolding rather than active execution paths.

## Source Learning

The learning loop turns repeated inference into reviewed, testable behavior:

```text
receipts -> recurring pattern -> rule proposal -> fixture replay
         -> shadow canary -> reviewed activation -> drift monitoring
```

The current learner supports two code-owned candidate families: CN Traveller
editorial-card mappings and Luma JSON-LD events. Proposal generation freezes
source-level support plus blocker/task-flag frequencies and a versioned
candidate already declared in code. Evaluation compiles that exact frozen
candidate through an allowlisted interpreter and replays a small gold fixture
set; it cannot pass by running an unrelated shipped extractor. Unknown code,
unsafe paths, mutated proposal evidence, and unsupported versions fail closed.
A canary record has zero traffic and cannot activate or deploy anything.

This is a safe learning-lifecycle scaffold, not autonomous algorithm discovery.
There is no inference-backed proposal generator, held-out corpus service,
production traffic comparator, drift monitor, activation worker, code writer,
pull-request creator, or deployment path. A source-specific code parser remains
a normal reviewed code change with tests and CI; the runtime never writes or
deploys arbitrary executable code.

Canary creation derives the newest evaluation from append-only evidence rather
than trusting the proposal pointer. It repairs a stale `latestEvaluationId`
after an interrupted evaluation write. A newer failed evaluation blocks
advancement even if an older evaluation passed; the runtime never searches
backward for a convenient passing result. Evaluation and canary operations for
one proposal are serialized under the same local guard.

CN Traveller starts discovery-only: an editorial mention can seed a candidate
and source attribution, but an official event or organizer source is required
before publication readiness. Luma may supply stable provider identifiers, but
network acquisition remains disabled until source cadence, terms, and spend
policy are approved.

## Promotion, Publication, And Reconciliation

The canonical `OperationPublicationPlan` schema and backend reducer exist, but
the shipped local runtime does not create one. `promote` requires a completed,
inventory-hash-bound run and emits only a hash-bound, non-applicable review
receipt with `applyAllowed: false`. It cannot publish or mutate an event,
organizer, website, or app record.

Eligibility is evaluated only from the source-publication policy frozen into
the run plan. The promotion receipt includes that complete policy snapshot and
its `promotionPolicyHash`, so later edits to a live source profile cannot change
an old run's candidate set or erase the policy evidence used. Promotion
revalidates the persisted plan and its hashes at receipt time. The receipt id
and receipt hash also bind its blocked status, `applyAllowed: false`, blockers,
and guardrails; existing receipt and companion-action content is validated on
every replay and cannot be overwritten through the store.

A future publication-plan builder and separately authorized worker must:

- revalidate source freshness, schema, dedupe, rights, and policy at apply time;
- compare target versions before writing;
- append one receipt per attempted action;
- make retries idempotent;
- keep Catch-hosted/bookable events distinct from read-only external supply;
- support update, cancellation, expiry, correction, and takedown, not only
  first-time creation.

Reconciliation is a first-class recurring child run rather than an in-place
mutation. Event velocity is measured as fresh future inventory, not cumulative
historical output.

## Adding Another Workflow

Before a second admin workflow adopts this platform:

1. define its authority, stages, terminal outcomes, idempotency keys, budgets,
   receipts, and human-decision seam;
2. reuse run/lease/receipt/persistence primitives without copying Supply Intake
   domain stages;
3. add a registry descriptor and executable workflow factory, then declare only
   the CLI commands that workflow actually implements;
4. add a workflow manifest, schema fixtures, and replay tests;
   `npm --prefix operations run manifests` must discover every workflow folder,
   bind manifest to registry metadata, require a source loader only for a
   non-empty source inventory, prove the transition graph is complete and
   stage-closed, validate disjoint active/published/expired lifecycle semantics,
   instantiate the factory, prove command-required methods exist, and enforce
   the platform authority ceiling;
5. project the canonical backend state through the owning admin feature rather
   than creating a parallel dashboard source of truth;
6. register only stable entrypoints in `tool/tools_manifest.json`; keep the
   implementation inside `operations/`.

## Activation Checklist

Shadow implementation can ship before these owner decisions. Assisted or
publication modes cannot:

- source allowlist, terms, cadence, robots/API policy, and spend caps;
- source acquisition/normalization workers and raw-artifact storage;
- model provider/model, per-run and monthly budgets, retention, and eval
  thresholds;
- raw-artifact object storage, retention, deletion, and access policy;
- worker and publisher service identities plus least-privilege IAM;
- auto-publish, sampled review, correction, takedown, and incident policy;
- a durable decision bridge from Event/Organizer Intake into a new operations
  run, without relying on manually regenerated compatibility artifacts;
- launch-market density/freshness targets and quality guardrails;
- public event directory/detail projection and organizer outreach ownership.

## Verification

At minimum, changes to the platform run:

```sh
npm --prefix operations test
npm --prefix operations run check
npm --prefix functions run build
node tool/contracts/validate_schema_contracts.mjs
node tool/run.mjs check --manifest-only
node tool/check_repository_root_hygiene.mjs
node tool/agent/check_agent_readiness.mjs
```

Add focused Functions/admin/data-contract checks when persistence, callables,
or UI projections change. Cleanup and refactor passes also refresh and stamp the
audit registry. `Tools CI / Operations platform` installs from
`operations/package-lock.json` and runs the full package check whenever
`operations/**` or `contracts/operations/**` changes, so this safety boundary is
enforced on pull requests rather than remaining a local convention.
