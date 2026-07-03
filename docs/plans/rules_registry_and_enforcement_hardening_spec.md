---
doc_id: rules_registry_and_enforcement_hardening_spec
version: 1.0.0
updated: 2026-07-02
owner: app
status: active
---

# Rules Registry & Enforcement Hardening — Implementation Spec

## 0. Context for the implementing agent (read this first)

Catch converts architecture rules into machine enforcement. The pieces already
exist and pass CI:

- `docs/audit_registry/rules.json` — the rule registry (~50 active rules, each
  with `enforcement` entries binding rules to tools, stages, and doc anchors).
- `tool/architecture/*.mjs` — architecture scanners with unit tests
  (`check_dependency_direction.mjs` is the reference implementation: exported
  scan functions, `--write-baseline` ratchet, stable finding keys, tests).
- `tool/check_enforcement_integrity.mjs` — the meta-gate (category `meta`)
  that validates rule→tool→doc→baseline integrity.
- `tool/tools_manifest.json` — tool inventory with `role`, `rules`,
  `vacuityProof`, `baseline` metadata on enforcement tools.
- `docs/audit_registry/agent_metrics.jsonl` — append-only receipts, including
  `enforcement_baseline` events the meta-gate cross-checks.

A staff review found the remaining defects: six rules with text problems, two
recent policy decisions with no rule home, sunset conditions that have silently
fired, two meta-gate loopholes, and five rules that are `manual` despite having
trivial mechanical detectors. This spec fixes all of them.

**Hard constraints:**

- Do NOT modify any file under `lib/` or `test/` (app code). All new scanner
  rules ratchet existing violations via baselines.
- Do NOT touch the web lane (`website/`, `admin/`, `tool/web/**`,
  `tool/marketing/**`, `WEB-*` rules) — it is dirty from a parallel lane.
- Edit `rules.json` surgically: preserve key order and untouched rules
  byte-for-byte. No wholesale reformatting.
- Every new scanner rule gets: a unit test with at least one known-bad fixture
  asserting findings > 0, one known-good fixture asserting findings == 0, a
  manifest mapping (`role`, `rules`, `vacuityProof`), and a rules.json
  `enforcement` entry. `node tool/run.mjs check --category meta` must pass at
  the end of every phase.
- Follow the required loop from `AGENTS.md`: readiness gate before handoff,
  pass receipt in `docs/audit_registry/passes.jsonl`, refresh
  `dart tool/audit_registry.dart refresh` after doc changes.
- Commit per phase with focused messages (existing style: `fix:`/`refactor:`/
  `feat:` + short lowercase summary).

Verification commands used throughout:

```sh
node tool/run.mjs check --category meta
node tool/run.mjs check --category audit
node --test tool/architecture/check_dependency_direction.test.mjs
node tool/check_enforcement_integrity.mjs
node tool/agent/check_agent_readiness.mjs
```

---

## Phase 1 — Rule text repairs in `docs/audit_registry/rules.json`

Replace the `instruction` fields exactly as written below. Bump the registry's
top-level `version` once (patch) for the whole phase. Do not change rule ids.

### 1.1 `DEAD-PUBLIC-SYMBOL-001` — add the Widgetbook carve-out

New instruction:

> Public symbols (widgets, getters, enum values) outside lib/labs and
> intentional in-dev features must have at least one live reference. Live
> references are: production lib/ code, route/config registration, and
> Widgetbook use cases or capture-catalog entries for components that have a
> widget-catalog or component-contract entry. Test-only references do not
> count as live. A symbol whose only live reference is Widgetbook and which
> has no catalog/contract entry is dead. Orphaned symbols left by superseded
> migrations must be deleted together with their dead tests.

### 1.2 `COPY-VERB-INTEGRITY-001` — narrow instruction to match its sunset

New instruction:

> High-traffic user-facing string surfaces — onboarding, booking/CTA flows,
> dashboard, event detail, chat, notifications, and catalog copy under
> contracts/ — must be covered by a copy snapshot/golden test. Any automated
> find-replace rename that can touch prose (e.g. run->event) must re-run the
> copy golden AND include a human review of the changed string literals before
> merge. Do not add goldens for every string in the app; the scope is the
> named high-traffic surfaces plus any string that has previously regressed.

### 1.3 `DESIGN-PRIMITIVES-001` — stop hardcoding the primitive list

New instruction:

> Before creating local card, sheet, empty-state, rail, row, badge, skeleton,
> or section UI, check docs/widget_catalog.md and the existing Catch*
> primitives under lib/core/widgets for an owner. Do not duplicate an existing
> primitive shell; extend the primitive or propose a variant through catalog
> review.

### 1.4 `FN-DOC-001` — remove the point-in-time snapshot

In the instruction, delete the parenthetical `(currently omits the Stripe
surface and ~30 exports)`. Keep everything else verbatim.

### 1.5 Split `ASYNC-UI-001` into three rules

Keep `ASYNC-UI-001` with this narrowed instruction:

> Presentation widgets should route AsyncValue, Future, and Stream
> loading/error branches through CatchAsyncValueView, CatchAsyncValueSliver,
> or a feature-owned typed display-state adapter. View-models may call
> AsyncValue.when when they return non-widget display state. Empty states stay
> in successful data callbacks. Data-load errors must use Catch error
> primitives with retry unless retry is impossible or unsafe.

Add `ASYNC-ENRICHMENT-001` (status `active`, same `applies_to` as
ASYNC-UI-001, `introduced_in` this spec's doc_id):

> Optional enrichment reads may fail silently only when the primary surface
> remains correct and no primary CTA, paid action, safety action, or host
> operation depends on the enrichment. Silent enrichment failures should still
> log through error context when diagnosis matters. Anything a primary action
> depends on is not enrichment and must surface its error.

Add `ASYNC-LOADING-PRESENTATION-001` (same applies_to):

> When credible initial or fallback data is available (route extra, cached
> value, optimistic snapshot), render it ahead of blocking loading skeletons.
> Loading states should use skeletons that resemble the eventual UI shape when
> that shape is known; use compact spinners or loading copy only for tiny
> inline metadata, unknown one-off work, or platform/plugin actions.

Copy ASYNC-UI-001's `sunset_when` items to whichever of the three rules each
item describes (skeleton items go to ASYNC-LOADING-PRESENTATION-001,
enrichment items to ASYNC-ENRICHMENT-001). Move any `enforcement` entries the
same way; if an entry covers all three, duplicate it.

### 1.6 Add `kind` to every rule

Add a `"kind"` field to every rule (including WEB-* — this is metadata only,
not a web-lane change): one of `"contract"` (invariant about code/artifacts),
`"scar"` (generalized from a specific audited incident), `"process"` (how work
is done), `"product-marker"` (in-development preservation flag).

Assignments: `AUDIT-REGISTRY-001, DOC-HYGIENE-001, AGENT-HARNESS-001,
AGENT-DELEGATION-001, CODEGEN-001, FIRESTORE-RULES-TEST-001, DEBUG-LOOP-001`
→ `process`. `EVENT-POLICY-INDEV-001, EVENT-SUCCESS-INDEV-001` →
`product-marker`. Everything introduced by `deep_semantic_audit_2026_06` →
`scar`. Everything else (including EXHIBIT-FRESHNESS-001, WEB-*, the two new
ASYNC rules, and the Phase 2 rules) → `contract`.

---

## Phase 2 — New rules for undocumented enforced policy

Two scanners currently enforce policy no rule states. Add both rules.

### 2.1 `DEPENDENCY-DIRECTION-001` (kind `contract`)

```
applies_to: ["lib/**", "tool/architecture/check_dependency_direction.mjs",
             "tool/architecture/dependency_direction_baseline.json"]
```

Instruction:

> Layer imports follow the declared dependency direction. lib/*/domain/** must
> not import Flutter, Riverpod, Firebase, routing, or platform plugin
> packages; Timestamp/serialization handling routes through
> core/firestore_converters, and the existing direct imports are ratcheted
> debt in tool/architecture/dependency_direction_baseline.json — new domain
> code must not add them. lib/*/data/** and lib/*/domain/** must not import
> feature presentation code. Feature presentation must not import sibling
> feature presentation internals; the one sanctioned seam is a sibling
> feature's public controller (presentation/*_controller.dart) imported from a
> route screen (*_screen.dart) or another controller. Widgets, bodies, state
> adapters, and view models are feature internals — when another feature needs
> a read model, expose a narrow public provider/contract instead.

Enforcement entries: `audit:dependency-direction` (stage `scanner-ratchet`)
and `audit:adopted-architecture-boundaries` (stage `scanner-gate`), docAnchor
`docs/app_architecture.md#dependency-direction`. **Re-point those two tools'
manifest `rules` arrays and the two existing enforcement entries currently
attached to `PROVIDER-SEAM-001` to this new rule.** `PROVIDER-SEAM-001` keeps
only its original meaning (screens use the feature's view-model/controller
seam instead of reaching to a lower-level repository provider) at stage
`manual`.

### 2.2 `MUTATION-KEY-GRAIN-001` (kind `contract`)

```
applies_to: ["lib/**/presentation/**"]
```

Instruction:

> Mutation state cardinality must match UI interaction grain. Route-level
> single actions (book, cancel, submit, delete for the route's single subject)
> may use static Mutation fields. Repeated row/list actions — attendance,
> waitlist offers, join-request decisions, any per-entity action rendered N
> times on one surface — must key mutation state per target
> (mutation(key) family instances) so one row's pending/error state cannot
> affect sibling rows. Keys are typed Dart records with value equality, not
> concatenated strings. Reference implementation:
> lib/hosts/presentation/host_event_booking_controller.dart.

Enforcement: stage `manual`, docAnchor
`docs/app_architecture.md#controller-and-view-model-contract` (Phase 5 adds
the doc paragraph — do Phase 5 before running the meta-gate on this).

---

## Phase 3 — Meta-gate hardening (`tool/check_enforcement_integrity.mjs`)

### 3.1 Structured sunset signals

Extend the rule schema with an optional `sunset_signals` array; each entry is
one of:

```jsonc
{"type": "tool-exists", "tool": "<manifest tool id>"}
{"type": "baseline-empty", "baseline": "<repo path>", "countKey": "<maxCounts key or 'allowedFindings'>"}
{"type": "manual"}
```

Meta-gate behavior: for every **active** rule, evaluate each non-`manual`
signal. `tool-exists` is satisfied when the manifest id exists. Wait — a tool
existing at spec-time means the signal fires immediately; that is the point:
these signals mark sunsets that HAVE fired. `baseline-empty` is satisfied when
the referenced count is 0 (or the allowedFindings array is empty). If any
signal is satisfied and the rule has no `sunset_review` object
(`{"date": "YYYY-MM-DD", "decision": "keep"|"graduate"|"retire", "note": "..."}`),
the meta-gate FAILS with the rule id and the satisfied signal.

Populate now:

- `MUTATION-ERROR-SURFACE-001`: signal `tool-exists:
  audit:mutation-error-surfaces` + `sunset_review` `{decision: "keep", note:
  "scanner shipped 2026-07-02; rule stays active until the per-mutation
  analyzer diagnostic replaces the file-level heuristic"}`.
- `AUDIT-REGISTRY-001`: signal `tool-exists: meta:enforcement-integrity` +
  `sunset_review` `{decision: "keep", note: "meta-gate automates registry
  integrity; pass-stamping discipline remains manual"}`.
- `STREAM-LIFECYCLE-001`: signal `tool-exists: audit:dependency-direction`
  (satisfied after Phase 4 adds the timeout rule) + review decision `keep`.
- `ROUTE-STRING-001`, `IMAGE-NETWORK-PRIMITIVE-001`: `tool-exists` signals for
  their scanners + review decision `keep`.
- All other rules: add `sunset_signals: [{"type": "manual"}]` so the field is
  universally present and the meta-gate can require it.

Meta-gate also FAILS if an active rule lacks `sunset_signals` or `kind`.

### 3.2 Close the role loophole

FAIL when a manifest tool matches ANY of these and lacks `role`:

- `path` matches `tool/*.sh`, `tool/architecture/**`, `tool/audit/**`, or
  `tool/check_*.mjs`; or
- any entry in `checks` is a real run — i.e. not matching
  `node --check`, `bash -n`, `node --test`, `dart analyze`, or the
  `python3 ... ast.parse` idiom.

Exempt paths for now (dirty web lane): `tool/web/**`, `tool/marketing/**`,
`tool/admin/**`, `tool/design/**`, `tool/contracts/**`, `tool/data/**`,
`tool/firebase/**`, `tool/env/**`, `tool/ci/**`, `tool/agent/**`,
`tool/migrations/**`. Add roles to any currently-unlabeled tool the new check
catches (expected: few or none — investigate each; `role: "finder"` for
report-only tools, with `vacuityProof` not required for finders).

### 3.3 Growth guard for `allowedFindings` baselines

Currently only `maxCounts` baselines are receipt-checked. Extend: when a
`tool.baseline` JSON contains `allowedFindings`, require the latest
`enforcement_baseline` receipt in `agent_metrics.jsonl` for that baseline path
to carry `{"counts": {"allowedFindings": <N>}}` matching the file's current
array length. FAIL on mismatch or missing receipt. Append the initial receipt
for `tool/architecture/dependency_direction_baseline.json` with its
post-Phase-4 count as part of this work (one JSON line; copy the existing
receipt shape).

### 3.4 Tests

Extend `tool/check_enforcement_integrity.test.mjs` with fixture-driven cases:
satisfied signal without review → fails; satisfied signal with review →
passes; role-less gate tool in a covered path → fails; allowedFindings count
drift without receipt → fails; matching receipt → passes. Keep the existing
tests green.

---

## Phase 4 — Promote the cheap mechanical rules to scanner stage

Extend `tool/architecture/check_dependency_direction.mjs` (same file — these
are all dependency/shape rules over lib/) with three new finding rules. For
source-pattern rules the baseline key is FILE-LEVEL: `rule|path` (documented
limitation: a grandfathered file can gain another violation of the same rule
silently; acceptable for ratchet stage). Import-pattern rules keep
`rule|path|import` keys.

### 4.1 `domainClockAccess` (enforces `INJECTED-CLOCK-001`)

Flag `DateTime\s*\.\s*now\s*\(` in files matching `lib/*/domain/**`. Reason
text: "domain time predicates must accept an injected clock instead of calling
DateTime.now() internally".

### 4.2 `dataStreamTimeout` (enforces `STREAM-LIFECYCLE-001`)

Flag `\.timeout\s*\(` in files matching `lib/*/data/**`. Honor the existing
override comment format on the same or previous line:
`// architecture:allow stream-timeout -- reason: <...>` (skip the finding).
Reason text: "realtime Firestore streams must not be idle-timed-out; annotate
non-Firestore protocol deadlines with architecture:allow stream-timeout".

### 4.3 `presentationPluginImport` (enforces `EXTERNAL-SIDE-EFFECT-001`)

Define a `pluginPackages` set — the existing `disallowedDomainPackages` minus
`flutter`, `flutter_riverpod`, `hooks_riverpod`, `riverpod`, `go_router`,
`firebase_core`, `firebase_auth`, `cloud_firestore`, `firebase_functions`,
`firebase_storage` (those are governed by other rules). Flag imports of
`pluginPackages` members in `lib/*/presentation/**` files EXCEPT files ending
`_controller.dart` or `_service.dart`. Key: `rule|path|import`.

### 4.4 Rollout mechanics

1. Add the rules + unit tests (bad fixture, good fixture, exemption fixture
   for each — extend `check_dependency_direction.test.mjs`).
2. Run `--write-baseline`; commit the regenerated baseline.
3. Append the `enforcement_baseline` receipt (per 3.3).
4. Add enforcement entries: `INJECTED-CLOCK-001`, `STREAM-LIFECYCLE-001`,
   `EXTERNAL-SIDE-EFFECT-001` each gain
   `{tool: audit:dependency-direction, stage: scanner-ratchet, docAnchor: <the
   rule's existing anchor>}`. Update the manifest tool's `rules` array.
5. Update the tool's `--help` text to list the new rules.

### 4.5 Functions-lane scanners (separate commits; skip only if instructed)

Two new node scanners, same structure/testing/manifest pattern as the
architecture scanners, category `audit`, role `gate`:

- `tool/audit/check_fn_rate_limits.mjs` (enforces `FN-RATE-001`): extract
  every string literal passed to `checkRateLimit(` under `functions/src/**`
  and every key of the `RATE_LIMITS` map; FAIL listing actions without an
  explicit entry. Locate the map by grepping `RATE_LIMITS` — inspect the
  actual shape before writing the parser and adjust; keep the extraction
  regex-based, no TS compiler dependency.
- `tool/audit/check_fn_readme_inventory.mjs` (enforces `FN-DOC-001`): diff
  exported names in `functions/src/index.ts` (regex `export\s+(?:const|function)\s+(\w+)`
  plus `export\s*{([^}]*)}` re-exports) against function names listed in
  `functions/README.md`; FAIL on exports missing from the README. If the
  README currently omits exports, ratchet with an `allowedFindings` baseline
  (`tool/audit/fn_readme_inventory_baseline.json`) rather than fixing ~30 doc
  entries in this pass.

---

## Phase 5 — Doc and registry sync

1. `docs/app_architecture.md`:
   - Add a **Mutation key grain** paragraph to the Controller And View-Model
     Contract section stating MUTATION-KEY-GRAIN-001's content (route-level
     static mutations vs keyed record-key mutations for row actions, with the
     host booking controller named as reference).
   - In Dependency Direction, add the domain-serialization clause: domain must
     not import Firebase; Timestamp converters route through
     `core/firestore_converters`; existing direct imports are ratcheted debt;
     the long-term target is no Firebase API calls or Firebase types in
     domain signatures (full DTO purity is explicitly NOT the target).
   - Sweep the one remaining stale pre-refactor snippet: search for
     `isHost: vm.isHost` and `_eventDetailCompanionState(` outside
     exhibit-marker blocks; update to the current reference shape.
   - Bump doc version; run `dart tool/audit_registry.dart refresh`.
2. `docs/audit_registry/backlog.json`: add a debt entry (follow the existing
   schema exactly) — id `DEBT-AUTH-LOADING-STATE-001`: "CalendarScreen and
   SavedEventsScreen conflate uidProvider loading with signed-out and render
   the signed-out/empty state while auth resolves
   (`ref.watch(uidProvider).asData?.value == null`). Distinguish auth-loading,
   signed-out, and signed-in-empty."
3. `tool/README.md`: add a "Where enforcement lives" section: analyzer
   diagnostics → `packages/catch_ui_lints` (probe-tested via
   `tool/check_catch_ui_lints.sh`); repo scanners with registry awareness →
   `tool/architecture/*.mjs` (node + `.test.mjs`); Dart-classification
   scanners → `tool/audit/*.dart`; meta-gates that validate other tools →
   `tool/` root; anything needing the Flutter toolchain gates in
   `flutter-ci.yml` direct steps, pure node/bash gates run via
   `tools-ci.yml` categories. New scanners MUST ship with manifest `role`,
   `rules`, `vacuityProof`, and a test containing a known-bad fixture.

---

## Phase 6 — Verification & receipts (definition of done)

All of the following, in order, must pass and be reported in the final
summary:

```sh
node --test tool/architecture/check_dependency_direction.test.mjs
node --test tool/check_enforcement_integrity.test.mjs
node tool/run.mjs check --category meta
node tool/run.mjs check --category audit
node tool/run.mjs check --manifest-only
node tool/agent/check_agent_readiness.mjs        # must be 100/100
git diff --check
```

Then:

- Stamp a pass receipt in `docs/audit_registry/passes.jsonl` (id
  `2026-07-XX-rules-registry-hardening`) listing: rules edited, rules added,
  scanner rules added, meta-gate checks added, baselines regenerated with
  counts, and the backlog entry id.
- Final summary must report: per-phase commit SHAs, the new baseline counts
  per rule (domainClockAccess / dataStreamTimeout / presentationPluginImport
  file counts), any tool the role-loophole check caught, and any deviation
  from this spec with the reason.

**Explicitly out of scope** (do not attempt): analyzer-lint promotion of any
rule; retiring `check_sizing.sh` / `check_ui_local_constant_wrappers.sh`;
`DEAD-PUBLIC-SYMBOL` reference-analysis scanner; web-lane anything; edits to
`lib/` or `test/`; exhibit generation-from-source (a `sunset_when` on
EXHIBIT-FRESHNESS-001 already tracks it).
