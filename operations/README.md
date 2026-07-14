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
- promotion produces a review receipt, never an app, website, or Firestore
  mutation; and
- CN Traveller is discovery-only and requires an official source before any
  candidate can become publication-ready.

## Architecture

```text
operations/
  src/cli/                       stable JSON command surface
  src/platform/                  runs, leases, budgets, ledger, storage, models
  src/workflows/supply-intake/   the reference workflow and source profiles
  test/                          deterministic engine and workflow tests
```

The file store is a local implementation of the runtime ports. It exists for
CLI, tests, migration parity, and local agents. A production backend may replace
it with Firestore/Object Storage without changing workflow decisions. State is
written to `operations/.state/` by default and is ignored by Git.

Every state-changing command is idempotent, every work item has exactly one
`primaryStage`, and every mutation appends an immutable action receipt. Leases
prevent concurrent workers from processing the same run. Checkpoints make
resumption explicit. Budgets fail closed before network, model, or public-write
allowances can be exceeded.

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
node operations/src/cli/main.mjs status --run RUN_ID

# Export canonical run/work-item records for the admin/backend adapter.
node operations/src/cli/main.mjs export-admin --run RUN_ID

# Produce a hash-bound, non-applicable promotion receipt.
node operations/src/cli/main.mjs promote --run RUN_ID

# Expire ended work and flag stale evidence.
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
--now ISO_TIME      deterministic clock override for replay/tests
--pretty            pretty-print the JSON envelope
```

`run` accepts `--plan PATH` to execute a previously captured plan. Without one,
it creates the same plan as `plan`. Repeating `run` for an identical plan returns
the original run rather than duplicating work.

`export-admin` validates every exported run and work-item record against
`contracts/operations/run.schema.json` and `work_item.schema.json`, then writes
`operations/.state/exports/admin/<RUN_ID>.json` by default. Missing or invalid
contracts fail closed. The exported `items` are the canonical persistence
records; UI labels live in `normalizedPayload.title`, and human exceptions carry
the `human_review_required` task flag.

## Queue model

Primary stages are exclusive and intentionally match the four Intake tabs:

```text
incoming -> verify -> resolve -> ready
```

Overlapping concerns such as `source_verification`, `possible_duplicate`, and
`official_source_required` are `taskFlags`, not stages. Publication, rejection,
expiry, cancellation, and takedown are `lifecycleStatus` outcomes; they never
become primary stages. The CLI and future admin API should expose this same
persisted projection; the browser must not recreate the reducer.

## Model boundary

`GuardedModelRunner` accepts only a provider injected by a trusted runtime. It
hashes prompt inputs, validates cached and fresh output against JSON Schema,
enforces input size and budget caps, and records model/prompt versions. Cached,
schema-valid output may be replayed while calls are disabled; a cache miss fails
closed with `MODEL_DISABLED`. The supply-intake workflow does not inject a
provider and therefore cannot call a model.

## Source learning

Learning is evidence-to-proposal, never self-modifying production code:

```text
observed failures -> proposal -> fixture replay -> shadow canary -> reviewed activation
```

The learner groups receipts by source, template fingerprint, task, field, and
failure reason. A proposal includes a frozen candidate rule and fixture set.
Evaluation records precision/recall against gold fixtures. Canary creation only
authorizes shadow comparison; activation and deployment remain separate,
human-reviewed operations.

## Verification

```sh
npm --prefix operations test
npm --prefix operations run check
```
