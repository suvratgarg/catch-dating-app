# Catch Operations

`operations/` is the runtime boundary for durable, agent-assisted admin
workflows. It is intentionally separate from `tool/`: repository checks,
generators, migrations, and deploy helpers remain tools, while scheduled or
resumable business workflows live here.

The first reference workflow is `supply-intake`. It can project the existing
Event Intake and Organizer Intake artifacts into one exclusive work-item queue,
run deterministic review steps, create hash-bound promotion receipts, reconcile
expired events, and propose source-specific extraction rules. The shipped
runtime is **shadow-only**:

- network access is disabled;
- model calls are disabled;
- public writes are disabled;
- run projection reads reviewed local compatibility artifacts; the source
  extractors are not yet connected to an acquisition worker;
- organizer compatibility packets are filtered by their declared market, and
  Event Intake bridges fail planning when missing, market-mismatched,
  future-dated, older than 168 hours, or past their reviewed week end;
- promotion produces a review receipt, never an app, website, or Firestore
  mutation; and
- CN Traveller is discovery-only and requires an official source before any
  candidate can become publication-ready.

## Architecture

```text
operations/
  src/cli/                       stable JSON command surface
  src/admin-cli/                 stable admin-action JSON command surface
  src/admin/                     catalog, callable client, receipt storage
  src/platform/                  runs, leases, budgets, ledger, storage, models
  src/workflows/registry.mjs     workflow definitions and factories
  src/workflows/supply-intake/   the reference workflow and source profiles
  test/                          deterministic engine and workflow tests
```

## Admin action CLI

The admin action CLI gives agents the same callable operations that employees
use through the admin console. Its source of truth is
`contracts/admin/admin_action_catalog.json`; it does not copy callable business
logic or turn every request/response action into a durable workflow.

```sh
# Discover actions and the ergonomic sequence for a workflow.
node operations/src/admin-cli/main.mjs actions --pretty
node operations/src/admin-cli/main.mjs workflow events --pretty

# Validate one safe, schema-backed example for all workflows without effects.
node operations/src/admin-cli/main.mjs loop --all --pretty

# Reads execute live unless --dry-run is supplied.
node operations/src/admin-cli/main.mjs run overview.get --project PROJECT_ID

# Mutations remain dry-run until action and target are confirmed exactly.
node operations/src/admin-cli/main.mjs run events.update --example
node operations/src/admin-cli/main.mjs run events.update --example --apply \
  --confirm events.update --confirm-target example-event --project PROJECT_ID
```

Live invocations require `CATCH_ADMIN_ID_TOKEN` and
`CATCH_ADMIN_APP_CHECK_TOKEN` (or their explicit flags). Receipts persist only
hashes and bounded metadata. See `docs/operations_platform.md` for authority,
failure, and employee-monitoring behavior.

The file store is the local implementation of the runtime ports. It exists for
CLI, tests, migration parity, and local agents. The trusted Functions adapter
imports validated, immutable shadow projections into Firestore without changing
workflow decisions. State is
written to `operations/.state/` by default and is ignored by Git.

State-changing commands use deterministic ids or guarded replay, and every work
item has exactly one `primaryStage`. Completion, promotion, and reconciliation
repair interrupted companion actions from durable evidence. Heartbeat leases
use a live clock and monotonically increasing fencing tokens to stop superseded
workers from writing run state. The live lease clock is separate from the
deterministic workflow clock, including when `--now` is supplied. Local guards
prove sole ownership of the same directory before entering, preserve any live
owner, and recover dead-process ownership. Run ids are preflighted and
idempotency is serialized before run creation; replay repairs an interrupted
create without retaining a losing collision mapping. Checkpoints make
resumption explicit, with work-item
budget consumption reconstructed from durable inventory after a crash. Budgets
fail closed before network, model, or public-write allowances can be exceeded.
Each run is capped at 10,000 projected work items and fails planning with
`RUN_SHARD_REQUIRED` above that ceiling. Split larger market/source scopes into
multiple runs. The platform and workflow both enforce the same cap. The admin
callable uses a 200-item page and 120-request window: human exceptions are
hydrated eagerly through a server filter, while ordinary inventory advances
only through explicit lazy pages.

`src/workflows/supply-intake/manifest.json` is executable inventory, not prose.
Its schema-backed check discovers workflow directories and compares the
manifest with the executable registry, supported command subset, ordered stages
and lifecycles, explicit active/published/expired lifecycle semantics, complete
stage-closed transition graph, optional source-profile loader, executable
factory methods, disabled capabilities, workflow identity, and platform cap.
The boundary gate separately scans every `tool/` code subtree for operations
runtime imports and split durable-workflow signals so future admin flows do not
recreate orchestration under a new tooling folder.

## CLI

Run from the repository root or from this package. All commands emit a stable
JSON envelope on stdout; failures emit a JSON error envelope on stderr.

```sh
# Inspect currently available legacy artifacts and create a deterministic plan.
node operations/src/cli/main.mjs plan \
  --market mumbai --through 2026-07-28

# Execute the plan into a local shadow inventory.
node operations/src/cli/main.mjs run \
  --market mumbai --through 2026-07-28

node operations/src/cli/main.mjs resume --run RUN_ID
node operations/src/cli/main.mjs queue --run RUN_ID --stage resolve
# Active work is the default; use --lifecycle all for terminal history.
node operations/src/cli/main.mjs queue --run RUN_ID --lifecycle all
node operations/src/cli/main.mjs status --run RUN_ID

# Export canonical run/work-item records for the admin/backend adapter.
node operations/src/cli/main.mjs export-admin --run RUN_ID

# Produce a hash-bound, non-applicable promotion receipt.
node operations/src/cli/main.mjs promote --run RUN_ID

# Create an immutable child run that expires ended work and flags stale evidence.
node operations/src/cli/main.mjs reconcile --run RUN_ID

# Evidence-to-rule lifecycle. Neither command deploys production code.
node operations/src/cli/main.mjs learn propose --source cntraveller
node operations/src/cli/main.mjs learn evaluate --proposal PROPOSAL_ID
node operations/src/cli/main.mjs learn canary --proposal PROPOSAL_ID
node operations/src/cli/main.mjs learn status
```

Useful common flags:

```text
--repo-root PATH    repository containing the legacy artifacts
--state-dir PATH    local durable state root
--now ISO_TIME      deterministic workflow-evidence clock for replay/tests;
                    lease ownership always uses the live system clock
--pretty            pretty-print the JSON envelope
```

`run` accepts `--plan PATH` to execute a previously captured plan. Without one,
it creates the same plan as `plan`. Repeating `run` for an identical plan returns
the original run rather than duplicating work.

`export-admin` validates every exported run and work-item record with full
draft-07/Ajv semantics against
`contracts/operations/run.schema.json` and `work_item.schema.json`, then writes
`operations/.state/exports/admin/<RUN_ID>.json` by default. Missing or invalid
contracts fail closed. The exported `items` are the canonical persistence
records; UI labels live in `normalizedPayload.title`, and human exceptions carry
the `human_review_required` task flag. Published and terminal records cannot
retain that flag, its blocker, or a human owner. Only completed runs can export;
the path is immutable, and later promotion receipts do not change the frozen
projection.

The export can then be validated without credentials and, after review,
imported into the server-owned admin projection:

```sh
# Dry run: parses contracts, authority, joins, totals, and hashes only.
npm --prefix functions run operations:import-projection -- \
  --file operations/.state/exports/admin/RUN_ID.json

# Internal Firestore apply: still cannot publish an event or organizer.
npm --prefix functions run operations:import-projection -- \
  --file operations/.state/exports/admin/RUN_ID.json \
  --apply --environment dev --project PROJECT_ID --confirm-run RUN_ID
```

Apply requires Application Default Credentials. It writes work items before the
run becomes discoverable, resets persistence revisions to zero while retaining
source revisions in reserved projection metadata, and treats a run snapshot as
immutable. The environment must match its configured Firebase project alias,
and production is detected from both the environment and project id. Replay
verifies every item, repairs missing items, rejects changed records, and enforces
the frozen work-item budget. An exact retry is a no-op; changed content requires
a new run id.

Completed local runs also carry a sorted inventory hash. `reconcile` binds that
hash and the source plan into a new run instead of editing the source snapshot,
so both exports remain immutable and independently importable.

## Queue model

Primary stages are exclusive and intentionally match the four Intake tabs:

```text
incoming -> verify -> resolve -> ready
```

Overlapping concerns such as `source_verification`, `possible_duplicate`, and
`official_source_required` are `taskFlags`, not stages. Publication, rejection,
expiry, cancellation, and takedown are `lifecycleStatus` outcomes; they never
become primary stages. The CLI and admin callable expose this same
persisted projection; the browser must not recreate the reducer.
The workflow contract also identifies which workflow-owned lifecycle values
mean active, published, and expired. Platform queues, canonical status mapping,
counters, and reconciliation cleanup consume those semantics instead of
hardcoding Supply Intake tokens.

## Model boundary

`GuardedModelRunner` accepts only a provider injected by a trusted runtime. It
hashes prompt inputs, validates cached and fresh output against JSON Schema,
enforces input size and budget caps, and records model/prompt versions. Cached,
schema-valid output may be replayed while calls are disabled; a cache miss fails
closed with `MODEL_DISABLED`. Enabled calls require explicit input-token,
output-token, and cost reservations, and provider-reported actual usage is
reconciled before output is accepted. The supply-intake workflow does not inject
a provider and therefore cannot call a model.

## Source learning

Learning is evidence-to-proposal, never self-modifying production code:

```text
observed failures -> proposal -> fixture replay -> shadow canary -> reviewed activation
```

The current learner supports code-owned CN Traveller mapping and Luma JSON-LD
candidates. It summarizes source-level work-item support and blocker/task-flag
frequencies, freezes the declared candidate plus fixture set, and evaluates
that candidate through an allowlisted deterministic interpreter. A deliberately
wrong mapping fails its fixture; mutable proposal evidence and unknown code fail
closed. Canary creation writes only a zero-traffic shadow record. It derives the
newest immutable evaluation, repairs a stale proposal pointer left by a crash,
and blocks when that newest record failed; it cannot fall back to an older pass.
Evaluation and canary work for one proposal are serialized.

There is no automatic rule discovery, live traffic comparison, activation,
deployment, source acquisition, or model provider in this package. Those are
explicit future capabilities, not implied by the learning commands.

Promotion eligibility reads only source-publication policy frozen into a
completed run plan. Promotion revalidates the plan and inventory hash before
deciding. Each
non-applicable receipt includes the policy snapshot and binds its blocked
status, non-applicability, blockers, and guardrails into its immutable id and
hash; replay validates both receipt and companion action before repairing an
interrupted write.

## Verification

```sh
npm --prefix operations test
npm --prefix operations run check
npm --prefix operations run manifests
```
