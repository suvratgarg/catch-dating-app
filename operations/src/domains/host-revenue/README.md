# Offline host revenue preflight

Run the synthetic normalized fixture from the repository root:

```sh
npm --silent --prefix operations run revenue:preflight -- --input "$PWD/operations/src/domains/host-revenue/fixtures/normalized-review.json" --policy "$PWD/operations/src/domains/host-revenue/fixtures/example-policy.json" --pretty
```

The command writes one JSON report to stdout and errors to stderr. It reads only the named local JSON file and the explicitly named policy file. It has no database, network, model, credential, publication, payment, or send path. `effectsApplied=false` and `runtimeAuthority=read_only` are report invariants. All outreach eligibility is `not_assessed` or `blocked`; a score never grants contact authority.

The input is a **reviewed normalized export**, not a raw Google Sheet or provider payload. Its root has `schemaVersion: 1` and `rows` (at most 500; file at most 1 MiB). Every row supplies a stable `sourceRowId`, a `sourceRef` (`sourceId`, `documentId`, `location`), exactly one `organizerId` or unresolved `candidateId`, one or more `cohortIds`, `marketId`, `workflowIds`, `eventTypeIds`, `identityKeys`, `evidenceRefs`, `qualification`, all seven configured `factors`, and `historicalScores`. `sourceRowId` is a globally unique normalized key such as `pipeline:us:12`, not a bare row number; it must stay the same across repeated exports of the same source row. A future normalizer must establish that key before this preflight. Empty arrays represent known absence; unknown factor ratings require `{ "state": "unknown", "reason": "..." }`. A known factor requires an integer 0–5 and at least one local evidence ID. See the fixture for the full shape.

Qualification identifies first-party identity evidence, recurrence evidence, and operating signals by IDs in `evidenceRefs`. The research minimum requires two distinct `signalId` values backed by independent `sourceRootId` values, so repeating a signal or copying one source cannot inflate coverage. A missing or contradictory evidence reference makes the row invalid. First-party identity, recurrence, and those two operating signals are only evidence sufficiency findings; no contact policy is assessed here.

The report retains input order, source pointers, overlapping cohort memberships and original historical score objects. A historical model is recognized only by the explicitly supplied private policy, and historical scores remain incomparable with the current model. Unknown versions are flagged for review. Duplicate source rows, organizer IDs and explicit identity keys are reported without merging records.

The checked example policy and input are synthetic test data, not commercial strategy. Real scoring weights, historical crosswalks, cohort definitions and source exports must be supplied from private storage. There is no built-in business policy fallback. Trusted adapters use `createRevenuePreflight(policy)` to obtain isolated validators and evaluators; each report includes a policy content hash as well as model/version. Configuration is bounded, validated, cloned and frozen. The command reads both files as bounded regular files without following symlinks. Never commit private policy or normalized prospect exports.

Invalid rows show a source pointer and reasons. The command exits nonzero for an unreadable file, oversized file, malformed JSON, or invalid root envelope; per-row errors remain in a machine-readable report. The current seven-factor policy is shadow only. No historical score is normalized, ranked with it, or used as outreach authority.
