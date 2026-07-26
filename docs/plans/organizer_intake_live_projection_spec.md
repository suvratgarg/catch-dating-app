---
doc_id: organizer_intake_live_projection_spec
version: 1.1.0
updated: 2026-07-26
owner: admin_operations
status: active
---

# Organizer Intake — Live Projection Spec (for Codex)

Scope: `admin/src/features/intake/organizer/`,
`operations/src/workflows/supply-intake/`, `contracts/operations/`,
`launchBoards/catch-pilot-launch-2026-07`, `admin/README.md`,
`operations/README.md`.

Read first per `AGENTS.md` routing (this task spans two rows):
`docs/operations_platform.md` + `contracts/operations/README.md` +
`operations/src/workflows/supply-intake/manifest.json` for the durable-workflow
side, and `docs/web_surface_architecture.md` for the admin React side.

---

## 0. The defect

The Organizers tab (`/intake/organizers`) has two data modes
(`admin/src/features/intake/organizer/controllers/loadOrganizerIntakeBridge.ts`):

- **sample mode** reads typed synthetic operation records;
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
5. Sample mode behavior must not change at all. Operational JSON was retired
   before this implementation; do not restore a generated sample bridge.

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
- Add a new `LAUNCH-SUPPLY-012` issue to the canonical Firestore board
  `launchBoards/catch-pilot-launch-2026-07` for this defect (P1, workstream
  `supply`), and move it to `fixed` only after the authenticated live console is
  verified — same bar `LAUNCH-SUPPLY-011` is held to. Repository launch-board
  JSON is retired and must not be restored.
- Update the live-mode paragraph in `admin/README.md` (it currently states the
  generated bridge is "sample/Storybook diagnostics only", which stays true, but
  the packet path becomes live) and the Organizer Intake note in
  `operations/README.md`.
