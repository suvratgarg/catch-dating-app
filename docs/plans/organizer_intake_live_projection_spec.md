---
doc_id: organizer_intake_live_projection_spec
version: 2.1.0
updated: 2026-07-27
owner: admin_operations
status: active
---

# Supply Intake Spec (for Codex)

Two parts. **Part I** (§0–§6) is a bounded defect fix in the admin live
projection — independently shippable, no product decisions required. **Part II**
(§7–§19) is the owner-specified product model for the whole supply loop:
recurring acquisition, extraction, attribution, visibility, and the
self-improving rule loop. Part I is a prerequisite for nothing in Part II, but
it is the cheapest thing on this page and should ship first.

Implementation state (2026-07-27): Part I and the executable portions of
Part II phases A–G are implemented and covered by Operations, callable,
contract, Admin, and rules tests. `organizer_intake` + `operations` is the
ratified single spine; repository operational JSON producers are retired.
The acquisition and model ports remain fail-closed until the owner selects the
providers, ToS posture, and spend limits listed in §18. The app-side passed-event
review affordance remains the explicitly named app-team dependency from §18;
the backend capability and review timing policy are implemented.

---

# Part I — Live projection defect

Scope: `admin/src/features/intake/organizer/`,
`operations/src/workflows/supply-intake/`, `contracts/operations/`,
`operations/launch/pilot_launch_board.json`, `admin/README.md`,
`operations/README.md`.

Read first per `AGENTS.md` routing (this task spans two rows):
`docs/operations_platform.md` + `contracts/operations/README.md` +
`operations/src/workflows/supply-intake/manifest.json` for the durable-workflow
side, and `docs/web_surface_architecture.md` for the admin React side.

---

## 0. The defect

The Organizers tab (`/intake/organizers`) has two loaders
(`admin/src/features/intake/organizer/controllers/loadOrganizerIntakeBridge.ts`):

- **sample mode** reads the checked-in generated bridge and renders everything;
- **live mode** calls `adminListIntakeOperations` and *hand-assembles* a bridge.

The live branch only reads work items whose
`normalizedPayload.intake.recordType === "organizer_search_candidate"`.
Everything else is hardcoded:

```ts
summary: {reviewItems: 0, evidenceReview: 0, promotionReview: 0,
          approvedPublic: 0, appDiscoverable: 0, ...},
publicationReviewPackets: emptyPublicationPackets(),   // packets: []
items: [],
diagnosticsBridge: null,
```

Two distinct problems follow.

**P1 — the live console misreports missing data as zero data.** With no
organizer rows and no packets, Verify/Resolve/Ready render as ordinary empty
queues and the counters read `0`. An operator sees "no organizers to review,
nothing blocked" when the truth is "this screen cannot see organizer review
work." Silent under-reporting of a review queue is the actual harm here.

**P2 — the publication packets are already in the durable projection and are
being dropped.** `operations/src/workflows/supply-intake/workflow.mjs` already
emits one work item per organizer publication packet
(`workItemForOrganizer`, `reviewOrganizer`), correctly market-filtered, correctly
staged into `verify`/`resolve`/`ready` with blockers and task flags. But its
`adminProjection` carries only `{recordType: "organizer_publication_packet",
entityId}` — the packet body lives in `item.raw`, which is **not** part of the
canonical exported record (`contracts/operations/work_item.schema.json`) and
never reaches Firestore. `read-models.mjs` copies `adminProjection` into
`normalizedPayload.intake` verbatim, so the admin has an entity id and nothing
to render.

So the fix is not "write a new pipeline". It is: carry a bounded packet
projection on the work item that already exists, read it in the admin live
loader, and stop lying in the meantime.

---

## 1. Phase 1 — Honest live state (ship first, independently)

Goal: the live console must distinguish "nothing to review" from "not available
here". No new data required.

1. In `loadOrganizerIntakeBridge.ts`, stop emitting fabricated `0` counters for
   sections the live projection does not supply. Add an explicit availability
   descriptor to `OrganizerIntakeLoadResult`, e.g.
   `availability: {searchCandidates: true, publicationPackets: boolean,
   canonicalItems: boolean, diagnostics: false}`, derived from what the response
   actually contained — never a constant.
2. Counters that cannot be derived must be `null`, not `0`. Widen the workbench
   bridge summary type accordingly. Any UI that renders a null counter shows
   `—`, never `0`.
3. `organizerIntakeWorkbench.tsx`: when `availability.canonicalItems` is false,
   the Verify/Resolve/Ready stages and the entity queue must render an explicit
   unavailable state ("Organizer publication review is not available from the
   live projection yet — N discovery candidates loaded from run <runId>"), not
   the generic "no items match this filter" empty state. Incoming keeps showing
   candidates as it does today.
4. Add a one-line note where the Diagnostics buttons are conditionally hidden
   (`diagnosticsBridge` guard) stating diagnostics is sample/Storybook-only.
5. Sample mode behavior must not change at all.

Acceptance for Phase 1: with zero packet work items, the live tab reads
"50 candidates loaded · publication review unavailable", and no stage shows a
misleading `0`.

---

## 2. Phase 2 — Project the publication packet

### 2.1 Workflow (`operations/src/workflows/supply-intake/workflow.mjs`)

Add `organizerPacketProjection(packet)` mirroring the existing
`organizerCandidateProjection`, and set it on `workItemForOrganizer`'s
`adminProjection`. Carry **exactly** the fields the workbench row, detail pane,
and approval gate need:

- `packetId`, `entityId`, `canonicalHostId`, `displayName`, `status`, `priority`
- `markets`: `[{slug, displayName}]` from `identity.geography.markets`
- `blockers`, `dataBlockers`, `evidenceBlockers`
- `approvalChecklist` (the six booleans, verbatim)
- `evidenceSummary`: `records`, `manualReportsWithoutArtifacts`,
  `unresolvedLocalRefs`, `missingSurfaceEvidence`, `rawProviderArtifactRefs`,
  `firestoreForbiddenArtifactRefs`, `riskFlags`
- `publicPresence`: `canonicalPath`, `claimTargetPath`, `indexStatus`,
  `appVisibility`, `projectionStatus`
- `adminDecision`: `allowedDecisions`, `defaultAppVisibility`,
  `currentDecision` reduced to `{decision, decidedAt, appVisibility}`
- `nextActions`

**Deliberately excluded** (they belong to diagnostics, and the projection must
stay bounded): `evidenceReview.records`, `publicDraft` copy, `curation` detail,
the `gates` array, and `adminDecision.command` (a local-CLI affordance that must
not drive a production console).

Bounds are mandatory, not advisory: cap `riskFlags` and `nextActions` at 12
entries each, `markets` at 8, truncate every string field, and reject nested
arrays of objects. Add an assertion/test that the projection contains no raw
provider payload content — that prohibition is a standing rule of this pipeline,
not a preference.

### 2.2 Admin live loader

Map `organizer_publication_packet` work items into **both**
`workbench.items` (as `OrganizerIntakeItem`) and
`workbench.publicationReviewPackets.packets`, keyed by `entityId` so
`publicationPacketByEntity` resolves. Derive every summary counter from the
loaded items (`reviewItems`, `blocked`, `approvedPublic`, `appDiscoverable`,
`evidenceReview`, packet `summary.*`). Set `availability.publicationPackets` and
`availability.canonicalItems` from the response.

Reuse the existing pagination and validation discipline: the
`isOrganizerCandidate`-style shape guard must have a packet equivalent that
throws on an invalid projection rather than silently rendering a partial row.

### 2.3 What must NOT change

- `handleDecision`'s approval gate stays exactly as is. `publicationPacketReady`
  must still require `ready_for_manual_publication_review`, zero data blockers,
  zero evidence blockers, and a fully-true checklist; the manual-report
  acknowledgement path stays.
- The tool-side generator re-validation (`organizer_intake.mjs` reconstructs the
  pre-approval packet and rejects an exported `approve_public` whose packet
  would still be blocked) remains the authority. Do not weaken it because the
  console now shows a packet.
- No new callables. The five organizer callables are sufficient.

---

## 3. Non-goals

This change does not publish a listing, index a route, sync claim targets, make
an organizer app-discoverable, enable a crawl, or import an event. It does not
move diagnostics to live mode. It does not add a candidate→entity scaffolder
(`LAUNCH-SUPPLY-004` stays open), fix Meetup/Linktree dedupe
(`LAUNCH-SUPPLY-007`), or add freshness/closure fields (`LAUNCH-SUPPLY-008`).

---

## 4. Expected data — do not "fix" this

With current artifacts, an organizer-scoped Mumbai+Indore run projects exactly
**one** packet work item: `afterfly` (Indore). `bhag` is a Delhi entity and is
correctly excluded by `organizerPacketSupportsMarket`. If Verify/Ready shows one
organizer and not two, that is correct. Do not widen the market filter to make
the number look better.

**Gotcha:** extending `adminProjection` changes exported record content. An
already-exported run id cannot be re-exported with new content — replay rejects
changed records by design. Create a **new run** for verification; do not force a
re-export of an existing run id.

---

## 5. Verification

```sh
npm --prefix operations test
npm --prefix operations run check
node tool/organizer_intake/check_admin_review_bridge.mjs
node tool/run.mjs check web:react-architecture-boundaries
node tool/run.mjs check web:admin-feature-ui-size
node tool/agent/check_agent_readiness.mjs
```

Plus the admin typecheck/test loop, `web:admin-bundle-budget` after the admin
production build, and the Functions intake-operations tests if
`functions/src/operations/models.ts` changes.

New regression tests required:

1. Live loader, zero packet work items → availability flags false, counters
   null, **no zeros**.
2. Live loader, one packet work item → one `items` entry, one packet, approve
   gate passes when the checklist is complete and fails when it is not.
3. Workflow test asserting the bounded projection field set and every cap.
4. Workflow test asserting no raw provider payload content in the projection.
5. Workbench test asserting the unavailable state renders instead of an empty
   queue when `availability.canonicalItems` is false.

---

## 6. Handoff

- Branch from current HEAD; push a `chore(wip)` snapshot before ending a dirty
  session (`AGENTS.md` non-negotiables).
- Ship Phase 1 as its own commit/PR — it is small, independently valuable, and
  removes the misleading production state immediately.
- Add a new `LAUNCH-SUPPLY-012` issue to
  `operations/launch/pilot_launch_board.json` for this defect (P1, workstream
  `supply`), and move it to `fixed` only after the authenticated live console is
  verified — same bar `LAUNCH-SUPPLY-011` is held to.
- Update the live-mode paragraph in `admin/README.md` (it currently states the
  generated bridge is "sample/Storybook diagnostics only", which stays true, but
  the packet path becomes live) and the Organizer Intake note in
  `operations/README.md`.

---

# Part II — Supply acquisition, attribution, and publication

Owner-specified product model, recorded 2026-07-26. Part II is large. It is
phased in §9–§16 so each phase is independently shippable and verifiable. Do not
attempt it as one change.

## 7. The product model (authoritative)

The purpose of the supply pipeline is to bootstrap the marketplace: scrape real
events and organizers in the launch markets, publish them, and use those
listings to drive a claim loop that converts scraped entities into real hosts.
A listing that is never published bootstraps nothing — that is the reason the
system exists.

**R1 — Acquisition is recurring and programmatic.** Events and organizers are
acquired on a repeating cadence from search engines and platform sources (Luma,
Partiful, District, BookMyShow, Sort My Scene, Urbanaut, Meetup, and similar).
Manual capture does not scale and is not the target state.

**R2 — Deterministic-first extraction.** LLM extraction is a bootstrap for
unstructured or unknown sources only. Every source that proves stable must
migrate to a code-owned deterministic extractor ("if the URL is Luma, destructure
the page this way and map this value to this field"). Token cost is a hard
constraint, so LLM usage must trend down per source over time, not up.

**R3 — Never re-run fresh work.** Completed queries and completed source fetches
are tracked with the time they were performed, and re-planning must skip
anything still inside its freshness window. Freshness is per work-kind, not one
global constant.

**R4 — Events require organizer attribution.** An organizer may exist with no
events. An event may only be created when attributed to an organizer listing
that already exists. Encountering an event whose organizer is not in inventory
does not discard the event: it becomes an explicit to-do in the event crawl and
a discovery lead for the organizer loop.

**R5 — Visibility is granted by admin approval, not by claim.** A scraped entity
becomes visible when an admin manually approves it. Claim is not a precondition.
Claimed entities are always visible.

**R6 — Web visibility and app visibility are independent switches.** They are
separate atomic toggles and may carry different policies and different review
gates. Neither implies the other.

**R7 — An unclaimed entity is not bookable.** It is claimable, and it is
reviewable only once the event has passed. No booking, payment, waitlist, or
host-contact affordance on unclaimed supply.

**R8 — Events inherit a visibility ceiling from their organizer.** Effective
event visibility is `min(event switch, organizer switch)` per surface. An event
can never be more visible than the organizer it is attributed to.

**R9 — The loop is self-improving.** The CLI exists so an agent can run the
pipeline, read real results, and propose extraction improvements. The admin GUI
exists so humans supply the signal that guides those proposals. Human review
decisions are training input, not just record-keeping.

## 8. Current state against the model

Read this before building anything. Most of the skeleton exists; the gaps are at
the edges.

| Rule | State | Evidence |
|---|---|---|
| R1 acquisition | **Missing.** Nothing fetches. Every capture script consumes a payload file a human already downloaded. Network is disabled at the workflow manifest. | `capture_search_results.mjs`, `capture_luma_events.mjs`, `LAUNCH-SUPPLY-006` |
| R2 deterministic extraction | **Partly built.** `lib/platform_adapters.mjs` classifies Luma, Instagram, Partiful, District, BookMyShow, Sort My Scene, LinkedIn, press, first-party. Code-owned extractors with replay fixtures exist for Luma and CN Traveller. Urbanaut absent; Meetup/Linktree collapse to domain-only keys. | `operations/src/workflows/supply-intake/sources/`, `LAUNCH-SUPPLY-007` |
| R2 LLM | **Scaffolded, disabled.** `GuardedModelRunner` has prompt hashing, cache reuse, schema validation and spend caps, but supply-intake injects no provider. `llm_source_resolution.mjs` refuses `--call-model` by design. | `operations/src/platform/model/guarded-model-runner.mjs` |
| R3 freshness | **Partly built, wrong storage.** `plan_search_runs.mjs` keys queries as `source\|query\|city\|category\|candidate`, reads completed runs from `tool/host_discovery/runs/*.json`, and skips anything within `freshForDays: 90`. Capture is bound to the plan — an unplanned `runKey` is refused. But the ledger is committed JSON, the TTL is one global number, and there is no per-source (as opposed to per-query) cadence. | `tool/host_discovery/plan_search_runs.mjs`, `search_capture_core.mjs:64` |
| R4 attribution | **Enforced, but only by construction.** `--entity` and `--surface` are required at capture; ingest hard-fails without `entityId`/`surfaceId`. Consequence: an orphan event **cannot be represented at all**, so no to-do is ever created and the lead is lost. | `capture_luma_events.mjs:27`, `event_source_ingest_core.mjs:475` |
| R5 visibility by approval | **Supported everywhere except the UI.** The backend permits `approve_public` with `appVisibility: "discoverable"`; only `hold`/`suppress` are forced hidden. The console hardcodes `hidden` into every payload. | `functions/src/admin/organizerIntake.ts:152`, `useOrganizerIntakeController.ts:245`, `pending_input_request_core.mjs:228`, `pending_decision_answer_plan_core.mjs:156` |
| R5 claimed ⇒ visible | **Done.** | `functions/src/clubs/clubClaims.ts:350` |
| R6 independent switches | **Already true in behavior, not in control.** A native club is created `discoverable` + `noindex` (app-visible, web-invisible); a scraped organizer is published + indexed + `hidden` (the inverse). But web publication is an implicit side effect of `approve_public`, not a switch. | `createClub.ts:192,211` |
| R7 not bookable | **Not modeled.** No unclaimed-supply affordance policy exists in the app. | — |
| R8 ceiling | **Not modeled.** | — |
| R9 self-improving | **Half built.** `learn propose → evaluate (fixture replay) → canary (zero traffic) → reviewed activation` exists and nothing auto-activates. But the learner reads work-item blocker and task-flag frequencies — **not** human decisions or field corrections. | `operations/src/cli/main.mjs`, `supply-intake/learning.mjs` |

## 9. Phase A — Durable, per-kind freshness ledger

Keep `plan_search_runs.mjs`'s design (the `runKey` composition and plan-bound
capture are the good parts). Change where it stores state and how the window is
chosen.

1. Move the completed-work ledger out of committed JSON into durable storage
   owned by the operations platform, so a scheduled worker can append to it.
   Model it as run-scoped records, consistent with the existing immutable-run
   discipline — not a mutable global table.
2. Replace the single `freshForDays: 90` with a per-kind freshness policy, in
   config, validated by schema. Kinds needed at minimum: city discovery sweep,
   candidate verification, known-organizer event refresh, event detail refresh
   before publication. Defaults proposed in §18; the owner tunes them.
3. Add a **per-source** cadence ledger alongside the per-query one: a known
   organizer's Luma page must not be refetched more often than its policy
   allows. `event_crawl_plan.json` already enumerates crawl-capable surfaces;
   give each surface a `lastFetchedAt` and a cadence, and keep the existing
   `manualOnly` + `disabled` defaults until Phase B lands.
4. Reconcile the three unrelated freshness clocks — the query TTL, the event
   guide's `<city>/<week>/` folders, and the operations 168-hour evidence
   staleness — onto one documented model. They currently answer different
   questions with different units and no shared authority.

Ships independently. No network required.

## 10. Phase B — Acquisition port

The provider decision is the owner's (§18) and must not block the code.

1. Define an acquisition port with one method shape: given a planned `runKey`,
   return a raw payload plus provenance. Implement two adapters — the existing
   **manual file capture** (today's behavior, unchanged) and a **provider
   adapter** behind config.
2. The port is injected by a trusted runtime exactly as `GuardedModelRunner`'s
   provider is. The workflow must not construct a fetcher itself, and the React
   admin must never fetch a source.
3. Every fetch consumes budget through the existing budget mechanism and fails
   closed. Per-run request caps and a monthly ceiling are mandatory, not
   optional.
4. Raw payloads stay out of Firestore. `plan_raw_artifact_storage.mjs` already
   holds this line; do not relax it.
5. Enabling the provider adapter is a policy-gap decision recorded through the
   existing policy-gap flow, not a code default.

## 11. Phase C — Orphan events and organizer leads

This implements R4's second half, which does not exist today.

1. Allow an event candidate to be captured **without** an organizer, in an
   explicit orphan state — evidence-bound, blocked on
   `organizer_not_in_inventory`. Relax the hard `entityId` requirement in
   capture/ingest for this state only; every other consumer keeps requiring
   attribution.
2. An orphan event appears in the event crawl's to-do queue and in the admin
   Intake queue as human work.
3. An orphan event **seeds an organizer discovery candidate** from the event's
   host/organizer field, feeding the organizer loop. This is the highest-signal
   organizer lead available — strictly better than a generic city search query —
   and is currently thrown away.
4. When the organizer entity later exists, the orphan auto-attributes and its
   blocker clears. Attribution must be reviewable, not silent: record what
   matched and why, reusing the existing source-mention resolution scorecard
   rather than inventing a second matcher.
5. An orphan event is never publishable on any surface.

## 12. Phase D — Three atomic visibility switches

Today `approve_public` implicitly publishes and indexes the website while
pinning app visibility hidden. Separate *approving the record* from *exposing it
on a surface*.

1. The model already has three fields: `publishStatus` (page exists),
   `indexStatus` (indexed/noindex), `appVisibility` (discoverable/hidden). Expose
   all three as independent admin-controlled switches. Do not collapse them.
2. Approval decides the entity is real and safe. Each switch is then set
   explicitly. `suppress` sets all switches off; that guardrail stays.
3. Remove the hardcoded `appVisibility: "hidden"` from the console payload and
   from both generated-payload defaults (see §8 row R5). The backend already
   accepts `discoverable` on `approve_public`.
4. Gates differ per surface and must be separately checked:
   - **Web**: identity, owner-safe copy, canonical path, claim target present,
     takedown path, no impersonation. Cheap and reversible via noindex.
   - **App**: everything above, plus is the organizer actually still operating,
     is the event time and place accurate, and does the unclaimed-supply
     affordance policy (§13) hold.
5. Implement R8 as a derived constraint in code, not a convention: effective
   event visibility per surface is `min(event switch, organizer switch)`. A
   reviewer must not be able to publish an event above its organizer's ceiling.
6. Claimed entities remain always-visible; do not let an intake decision
   downgrade a claimed entity.

## 13. Phase E — Unclaimed-supply affordances and event publication authority

1. Encode R7 as a capability set on the entity, checked by the app and website,
   not as scattered conditionals: unclaimed ⇒ `bookable: false`,
   `claimable: true`, `reviewable: only when the event's end time has passed`.
   Booking, payment, waitlist and host-contact affordances must be absent, not
   merely hidden.
2. Build the external-event publication authority and writer that
   `LAUNCH-SUPPLY-003` describes: market identity, idempotent writes, takedown,
   dry-run receipts. Until it exists, R5 cannot be satisfied for events at all —
   approved candidates stay `blocked_by_policy`.
3. Resolve or explicitly waive the existing import blockers per event:
   `missing_exact_coordinates`, `missing_end_time`, `missing_location_detail`,
   `requires_event_defaults_policy`, `requires_owner_safe_copy_review`,
   `duplicate_normalized_event_key`. Waivers are policy decisions recorded
   through the policy-gap flow, never code defaults.
4. The app-side review affordance for passed events on unclaimed entities is an
   app dependency outside this spec's scope. Name it in the handoff; do not
   stub it here.

## 14. Phase F — Close the feedback loop

R9's missing wire. Today a reviewer's correction dies as a one-off record.

1. Capture reviewer **field-level corrections**, not just decisions: when a
   human edits an extracted value, record the source, the field, the extracted
   value, and the corrected value.
2. Aggregate corrections per source profile and feed them to the existing
   learner as proposal input, alongside today's blocker/task-flag frequencies.
   "Reviewers corrected the venue field on 12 Luma listings" is a rule proposal.
3. The proposal path does not change: `propose → evaluate against fixtures →
   zero-traffic canary → reviewed activation`. Nothing auto-activates, and a
   proposal that fails its fixture stays failed. Do not add an auto-promote
   shortcut.
4. Every correction that produces a rule proposal must also produce a fixture,
   so the corpus grows with the corrections.

## 15. Phase G — LLM placement and cost discipline

1. Inject a provider into the existing `GuardedModelRunner` — do not write a
   second model path. Its hashing, cache reuse, schema validation, token
   reservations and spend reconciliation are the cost controls.
2. Placement is **extraction fallback only**: unknown or unstable sources, and
   ambiguous identity clusters that the deterministic scorecard cannot resolve.
   Not copy generation, not ranking, not anything on a per-user path.
3. Every LLM-extracted field must emit a rule-proposal candidate (§14). An LLM
   extraction that never becomes a deterministic rule is a cost leak; report
   per-source LLM dependence as a metric that is expected to decline.
4. Hard monthly ceiling, enforced by the budget mechanism, failing closed.

## 16. Convergence — one spine

There are currently two organizer corpora (`tool/host_discovery/` and
`organizer_intake/search_result_batches/`) and two event paths
(`tool/marketing/event_guide/` weekly city bridge and organizer_intake's event
candidates). `LAUNCH-SUPPLY-009` already reports the two organizer paths
colliding on candidate caps.

Recommendation for ratification (§18): **`organizer_intake` + `operations` is the
spine.** Absorb `host_discovery`'s query planner — its freshness design is the
best part of the system and should survive the move in Phase A — and retire its
separate corpus and cap. Fold the event guide's weekly bridge into the same
run/work-item model rather than maintaining a parallel week-folder pipeline.
Do not begin convergence before Phase A lands; the planner must have a durable
home first.

## 17. Invariants that must not be weakened

- No raw provider payload in Firestore, ever.
- The React admin never fetches a source and never calls a model.
- No auto-activation of a learned rule; fixture replay and canary stay
  mandatory.
- Approval gates stay: the generator's independent re-validation of a
  pre-approval packet remains the authority over any exported decision.
- Publication, indexing, app visibility, crawling and event import each stay
  separately gated. Widening one must never widen another implicitly.
- Runs stay immutable; changed content requires a new run id.

## 18. Owner decisions still required

Codex must not invent answers to these. Build the pluggable seam, default to the
safe state, and surface the decision through the existing policy-gap flow.

1. **Acquisition provider and ToS posture.** Official platform APIs, a paid
   search API, or a headless crawler — and whether direct page scraping of
   Luma/Partiful/BookMyShow is acceptable. *Recommendation: official APIs plus a
   paid search API; no unpermitted headless crawling until the owner rules.*
2. **LLM provider and monthly ceiling.** *Recommendation: extraction fallback
   only, with a fixed monthly cap and a declining per-source LLM-dependence
   metric.*
3. **Freshness windows per kind.** *Proposed defaults: city discovery sweep 30
   days; candidate verification 90 days; known-organizer event refresh 24 hours;
   event detail refresh before publication 6 hours.*
4. **Ratify the single spine (§16).**
5. **App-side review affordance** for passed events on unclaimed entities —
   app-team dependency, not built here.

## 19. Verification

Per phase, in addition to the Part I loop:

```sh
npm --prefix operations test
npm --prefix operations run check
npm --prefix operations run manifests
node tool/organizer_intake/check_admin_review_bridge.mjs
npm --prefix functions run build
npm --prefix functions test
node tool/check_remote_ops_manifest.mjs --check
node tool/agent/check_agent_readiness.mjs
```

The former `check_promotion_bridge.mjs` and
`pending_work_coverage.mjs --require-covered` commands are intentionally not
part of the live verification loop. They validate repository JSON produced by
the retired projection pipeline. Reintroducing those artifacts would violate
the Firestore-backed Operations boundary; equivalent live coverage is enforced
by the Operations workflow checks, callable contract tests, and
`check_admin_review_bridge.mjs`.

Phase-specific gates, all of which need new tests:

- **A**: a planned query inside its window is skipped and cites the run that
  covered it; a per-source cadence blocks an early refetch; the ledger survives
  a simulated worker restart.
- **B**: the manual adapter's behavior is byte-identical to today; the provider
  adapter fails closed with no config; budget exhaustion stops fetching.
- **C**: an orphan event is capturable, non-publishable, appears as a to-do,
  seeds an organizer lead, and auto-attributes with a recorded match rationale.
- **D**: each switch flips independently; an event cannot exceed its organizer's
  ceiling on either surface; a claimed entity cannot be downgraded by an intake
  decision; `suppress` clears all switches.
- **E**: an unclaimed entity exposes no booking path; review is refused before
  the event's end time and permitted after.
- **F**: a recorded correction produces a proposal and a fixture; a wrong
  proposal fails replay and cannot canary.
- **G**: a cache hit replays without a call; a cap breach fails closed.

Update `operations/launch/pilot_launch_board.json` as phases land — several
`LAUNCH-SUPPLY` issues (003, 004, 006, 007, 009, 010) are closed or materially
advanced by this work, and each should move only after live verification.
