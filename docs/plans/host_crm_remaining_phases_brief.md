---
doc_id: host_crm_remaining_phases_brief
version: 1.0.0
updated: 2026-08-16
owner: host_crm
status: ready
---

# Host CRM — remaining work brief

A self-contained implementation brief for the work left in
[`host_customers_and_messaging_restructure_spec.md`](host_customers_and_messaging_restructure_spec.md),
written to be handed to an implementing agent directly.

**Read the spec for intent. Read this document for what is actually true of the
code**, which owner decisions are settled, and which spec statements are stale.
Where the two disagree, this document wins — every claim here was verified
against `origin/main` on 2026-08-16.

**Standing instruction for every work item below: if an instruction does not
survive your own reading of the code, stop and say so rather than implementing
it.** That clause has caught four specification errors in this programme so far.
Report pre-existing failures rather than working around them.

---

## 0. Delivery state

| Phase | Status |
| --- | --- |
| 0 — Row and directory defects | Shipped (#260) |
| 1 — Match counts, filter summary | Shipped (#262) |
| 2 — Segment → send bridge | Shipped (#262) |
| 3 — Contact memory | Shipped (#267) |
| **P0 — Production signing key** | Complete; prod secret version 1 and deploy parity verified 2026-08-16 |
| **4 — Sends and scheduling** | Implemented in this change |
| **5 — Merge review** | Implemented in this change |
| **5b — Proposed-link candidates** | Implemented in this change |
| **6 — Inbound WhatsApp** | Implemented in this change |
| **Sort control** | Implemented in this change with the approved composite index |

P0 was completed first. The production key now exists and the repo-to-production
function/secret parity gate passes; the remaining phase source changes still
follow the ordinary merge and deployment workflow.

---

## P0 — Unblock production function deploys

### The failure

Any `firebase deploy --only functions:…` against production aborts with:

```
Error: In non-interactive mode but have no value for the secret:
EVENT_VENUE_SESSION_SIGNING_KEY
```

`EVENT_VENUE_SESSION_SIGNING_KEY` is declared at
[`functions/src/events/venueSessions.ts:39`](../../functions/src/events/venueSessions.ts#L39),
introduced by #253 on 2026-08-14. Firebase loads and analyses the **entire**
codebase to decide what to deploy — `--only` narrows what is uploaded, not what
is analysed — and resolving `defineSecret()` params requires every declared
secret to exist in the target project. It does not exist in prod.

### Confirmed impact

Nine functions present in dev are missing from prod, and they are exactly the
functions introduced on or after 2026-08-14:

| Missing in prod | Host-visible effect |
| --- | --- |
| `createOrganizerContact` | **`Add customer` fails** (spec §2.10) |
| `startOrganizerContactConversation` | Starting a conversation from a customer fails identically |
| `controlEventSuccessLive`, `controlEventSuccessSpatial`, `getEventSuccessSpatialLayout`, `onEventSuccessPlanLiveControlUpdated`, `publishEventSuccessRotationRound`, `recordEventSuccessUnitOutcomes`, `upsertEventSuccessLayout` | Event Success live and spatial runtime is undeployed |

This was one blocker, not nine independent misses.

### The fix

**The secret must be set by the repository owner** — an implementing agent must
not handle secret values.

```sh
firebase functions:secrets:set EVENT_VENUE_SESSION_SIGNING_KEY \
  --project catch-dating-app-64e51
```

It signs venue-session tokens, so it wants a long random string. It does **not**
need to match dev; a distinct value per environment is correct.

Then deploy. Deploy from a checkout that is level with `origin/main` —
`tool/deploy_firebase_targets.sh` now refuses a ref behind its remote, but the
`firebase_with_env.sh` path does not:

```sh
npm --prefix functions ci && npm --prefix functions run build
./tool/firebase_with_env.sh prod deploy --only functions --non-interactive
```

Verify by asking the live project, not the repo:

```sh
firebase functions:list --project catch-dating-app-64e51 | grep createOrganizerContact
```

### Then close the class — build the parity gate

This is the **second** production incident in two days caused by deployed state
diverging from repo state; the first was a deployed Firestore ruleset missing
five `match` blocks. Both were invisible to CI, which verifies the repository and
never asks the live project what it has.

Build `tool/firebase/check_deploy_parity.mjs`, modelled on the existing
[`check_deploy_ref.mjs`](../../tool/firebase/check_deploy_ref.mjs):

1. Enumerate deployed callables/triggers for an environment.
2. Diff against the repo's exports in `functions/src/index.ts`.
3. **Fail when a repo export is absent from the environment.**
4. Ignore extras in the environment — installed extensions legitimately add
   ~32 `ext-bq-*` functions in prod that do not exist in the repo.
5. Additionally assert that every `defineSecret()` name in `functions/src`
   exists in the target project. **A function-list diff alone would have
   reported this incident's symptom and missed its cause.**

Register it in `tool/tools_manifest.json` with a `vacuityProof`, following the
`firebase:check-deploy-ref` entry.

---

## Phase 4 — Sends (Seam D) and scheduling

Spec §4 "Phase 4". Nothing remembers what was sent; a CRM's product is memory.

1. **`listOrganizerCampaigns(organizerId, cursor)`** returning summary rows: id,
   name, status, segments, template, audience counts, delivery counts,
   `scheduledAt`, `dispatchedAt`.

2. **Broadcast index — settled: a projection written on send** (§8.3). Write an
   organizer-scoped summary row when a broadcast is sent. Do **not** use a
   collection-group query over `eventBroadcasts`: it needs a composite index and
   a cross-organizer rules review, and the projection keeps reads cheap and the
   schema clean, which is the pre-launch preference.

   Rows carry event, audience, recipient count, sent time, and the
   partial-failure flag already returned by `SendEventBroadcastCallableResponse`.

   **Phase 3 left a typed send-history seam ready to gain broadcast rows.** Find
   it before designing a new one — Phase 3 deliberately shipped campaign history
   only, with the boundary already typed for this.

3. **The Sends workspace replaces Campaigns**: one reverse-chronological list
   mixing both kinds, each row typed (`Campaign` / `Announcement`), with a
   primary `New message` action. Tapping a row opens the existing report view;
   `getCampaignReport` keeps working because the id now comes from the list.

4. **Composer scheduling** writing `scheduledAt` (§2.8), with the server's
   existing `scheduleInPast` blocker surfaced inline rather than at send time.

5. **WhatsApp setup moves** to `/host/organizer/:clubId/messaging`, reusing
   `_buildWhatsappSetup` unchanged (Seam B).

**Stale in the spec:** it calls the deep-link workspace `sends`. The code's enum
and routes use **`workspace=campaigns`**, and Phases 1–2 shipped against that.
Renaming the user-facing workspace to "Sends" does not require renaming the enum
value; if you do rename it, that is a routing migration with its own deep-link
compatibility surface — decide deliberately, do not do it incidentally.

---

## Phase 5 — Merge review

Spec §4 "Phase 5", already revised 2026-08-15 after an implementing agent
challenged it and four of its objections were verified correct. **Read that
revision — it is accurate.** Summary of the binding decisions:

1. **Scope to candidates that already exist** — verified UID and verified phone.
   `organizerAudienceProjection.ts` produces candidates from verified UID/phone
   only. Imported-phone and normalized-email proposed links are **Phase 5b**,
   not a prerequisite.
2. **Durable negative decisions** via
   `contracts/firestore/organizer_contact_merge_review_decisions.schema.json`,
   modelled on the six existing `*_review_decisions` schemas. A `Different
   people` decision must suppress that pair from future listings and be
   reversible by the same manager. Without this a dismissed pair reappears on
   the next projection.
3. **Evidence is computed, never assumed.** `organizerContactMerges.ts` compares
   contact fields only — it computes no shared-event, source or confidence data
   today. Compute at read time or project it, but **never display an evidence
   field you did not derive.**
4. **Unmerge lives on the survivor's detail screen**, listing active receipts
   newest-first, each individually reversible. This needs a read-back seam:
   `getOrganizerContactDetail` currently rejects merged aliases and returns no
   receipts.
5. **Nothing auto-merges.** Name-alone candidates are never offered.

**Authority:** the existing organizer-manager gate, `requireOrganizerManager`
from `functions/src/shared/organizerManagerAuthority.ts`. **`audience.readPii`
does not exist** anywhere in `functions/`, `lib/` or `contracts/` — it is
delivery-plan vocabulary that was never implemented. Do not introduce a
capability system for this phase.

---

## Phase 6 — Inbound WhatsApp threads

Spec §4 "Phase 6". Makes Messaging honest: "Inbox" currently contains Catch
in-app threads only, while the host's real channel with most guests is WhatsApp.

1. **Persist inbound bodies** from `processInbound` into an organizer-scoped
   thread model, under the same access controls as contact PII.
2. **Retention: 12 months** (§8.4, settled). Time-based expiry only —
   per-thread and per-contact deletion were explicitly left out of scope.
3. **Surface as a channel facet on existing Inbox threads** (§8.5, settled), not
   as a third scope. A reply then sits next to the rest of that person's
   activity instead of in a separate queue.
4. **Replies are subject to the WhatsApp customer-service window.** The composer
   must show the window state, not fail at send time.
5. Only after this ships may Inbox copy stop qualifying what it contains (§6).

---

## Sort control

**Settled: accept the new Firestore composite index** (§8.6), so all three
orderings ship — `Last seen`, `Most attended`, `Name`.

**This is larger than a flag.** `contracts/callables/list_organizer_contacts_payload.schema.json`
accepts only `organizerId, limit, cursor, query, segmentId` — **there is no sort
field at all.** Shipping sort means:

1. Extending that payload schema and its generated types.
2. Giving **each ordering its own cursor semantics**. The existing cursor
   encodes `{plan, value, contactId, segmentId}` and `assertCursorPlan` rejects
   a cursor whose plan does not match the request — a cursor is not portable
   across orderings, and a naive implementation will paginate incorrectly rather
   than error.
3. The composite index for `Most attended`.
4. `Name` maps to the existing `searchName` ordering; `Last seen` to the current
   `lastSeenAt desc` default.

---

## Working conventions

These are not style preferences. Each one corresponds to a specific failure in
this programme.

### Derive the gate list; do not recall it

```sh
node tool/harness/verify_local.mjs --base origin/main --list
```

Prints exactly the CI gates your change touches, read out of
`.github/workflows/`. **Run this instead of working from any gate list, including
the one in a prompt.** Phases 1–2 failed CI four times on gates omitted from a
hand-written list — l10n key usage, design parity matrix, route inventory. Phase
3 used this tool and passed all of them first time.

Read its "NOT covered locally" footer: matrix-driven lanes are not covered. For
the tools lane run `node tool/run.mjs affected-tools --base origin/main --check`,
and if that reports "selected full mode" — which any control-plane change forces
— run `node tool/run.mjs check` instead.

Gates that have specifically bitten this programme:

```sh
node tool/copy/check_l10n_key_usage.mjs --check        # orphaned ARB keys
node tool/design/check_design_parity_matrix.mjs --check # new screen states must be registered
node tool/ui_capture/check_route_inventory.mjs --check
node tool/test/check_flutter_test_size.mjs             # ratchets oversized specs
```

New screen states declared in `design/features/*.feature.json` must also be
added to `docs/design_parity/state_matrix.json`, or three CI lanes fail at once.

### Analysis

CI's analyzer gate is `node tool/ci/check_flutter_workspace_analysis.mjs`
(`--fatal-infos` across eight packages). **A clean `flutter analyze` proves
nothing** — it does not promote info-level Catch lints to failures.

`bash tool/check_catch_ui_lints.sh` seeds deliberately-violating probe fixtures
and asserts the rules fire. **It never analyses `lib/`**, so it passes regardless
of whether your code is clean. Run `rm -rf tool/catch_ui_lints_probe` before
analyzing if a previous run was killed.

### Contracts and generated output

Every new schema goes through `contracts/` and generated types. No hand-built
client writes, no hand-edited generated files. `design/features/*.feature.json`
is hand-authored; `design/features/generated/` comes from
`node tool/design/build_feature_contracts.mjs`.

Firestore rules changes need matching emulator specs, including that one
organizer cannot read another's data.

### Git

- **Commit each coherent piece as it builds** — schema, then callables, then
  rules, then client. Committed work survives an interrupted run.
- **Stage explicit paths.** `git add -u` has silently dropped new files here.
- **Branch from the previous phase's branch if it has not merged yet**, not from
  a stale base. When it does merge (squashed), rebase with
  `git rebase --onto origin/main <previous-phase-branch>` — a plain rebase will
  replay already-merged commits and conflict against their squashed form.

### Naming already established by Phase 3

- Manual tags use **`manualTags` / `manualTagIds`**. The spec says
  `mutateOrganizerContact.tags`, which is unusable: `HostCustomerTag` is a
  client-side enum of *computed* segments and already owns that word. The two
  namespaces must stay distinct in code, not merely visually.
- The notes collection is the contract-named **`organizer_contact_notes`**.
