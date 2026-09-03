# Host Customers + Messaging Restructure Spec (for Codex)

## Audience workflow completion (owner-approved 2026-09-03)

Goal: complete intake, customer linking, reusable group inspection, and the
first source-backed targeting jobs inside the existing Audience destination.
The earlier phases below remain historical implementation context.

### Scope and responsibilities

- People is the organizer's complete contact directory, including prospects,
  imported/manual contacts and accepted applicants. Application decisions
  remain attached to their applications; one person can have several.
- Responses owns intake and a discoverable application-review queue. Ordinary
  feedback and surveys do not acquire an artificial approval lifecycle.
- Accepting an application atomically approves it and creates or links an
  organizer contact. Preserve the original response, source and review note.
  A unique existing contact is reused; conflicting matches require duplicate
  resolution. Retries cannot create duplicate contacts.
- Generic application forms use their exact submitted response authority.
  Legacy native applications continue to require their participant data grant.
  Withdrawn or inaccessible evidence cannot be approved or used for targeting.
- Saved audiences own membership rules, exact member inspection, preview
  freshness, reach summaries and an explicit handoff to Inbox compose.
- Inbox owns content, approval, scheduling and dispatch. Event bookings,
  verified Consumer identity and marketing permission are separate authorities.

### Ordered implementation slices

1. Repair generic-form application access, expose the review queue under
   Responses, connect approval to People, and link the response/application/
   person records in both directions.
2. Make saved-audience detail an overview with members, rules, preview time,
   reach and Message this audience. Keep editing and archive explicit.
3. Extend the closed targeting vocabulary for applications by form/status,
   versioned filterable choice/boolean answers, and attendance at a named
   event. Resolve current organizer-scoped source facts on the server; do not
   copy private Consumer attributes or execute arbitrary queries.

### Exclusions

The owner deferred visual redesign and render matching. Use existing Catch
components for functional additions. This scope does not add spend targeting,
arbitrary nested expressions, static lists, broad CRM data migration, automatic
outreach, webhooks, new automation triggers or production deployment.

### Checks and acceptance

- Backend tests cover generic/legacy authority, withdrawal and cross-organizer
  denial, optimistic conflict, repeat approval, unique existing contact reuse,
  ambiguous endpoints and atomic approval/contact creation.
- Audience tests cover each new predicate, mixed all/any rules, source
  withdrawal, foreign source rejection and stable member pagination.
- Flutter tests cover queue discovery, approval/customer navigation, audience
  member inspection/edit/compose and filter authoring with server vocabulary.
- Regenerate schema DTOs, validators, localization and affected feature/screen
  contracts; run data-contract checks, focused analysis/tests and the registered
  CRM boundary checks selected from the current impact plan.
- Preserve each coherent slice in Git. Report source/check, PR/CI and deployment
  states separately. No source claim depends on screenshots alone.

Status: phases 0–6 and server-backed sort implemented after this change merges · updated 2026-08-16

Delivery state (verified against `origin/main`, 2026-08-16):

- **Phase 0** — shipped in #260. Re-authored against a newer base than the
  original commit; the merged implementation is the one to build on.
- **Phases 1–2** — shipped in #262 (filter summary, match counts, composer
  extraction, segment→campaign bridge, unified counts).
- **Phase 3** — shipped in #267 (contact memory).
- **Phases 4–6 and sort** — implemented by this change: Sends/scheduling,
  reviewed merge/unmerge including proposed exact endpoint candidates, inbound
  WhatsApp Inbox facets and service-window replies, and all three server-backed
  directory orderings.

The deep-link wire value remains `workspace=campaigns`, not `workspace=sends`;
the user-facing label is Sends. The later owner decision accepted the Most
attended Firestore index, so `listOrganizerContacts` now carries an explicit
ordering and ordering-bound cursor contract.
Scope: `lib/hosts/presentation/customers/`, `lib/hosts/presentation/inbox/`,
`lib/hosts/presentation/host_operations/host_audience.dart`,
`lib/hosts/data/host_crm_repository.dart`, `lib/core/widgets/catch_field*.dart`,
`functions/src/organizers/`, `contracts/`, `design/features/`, `lib/l10n/`,
`widgetbook/`, `test/`
Companion: [`standalone_host_product_and_crm_delivery_plan.md`](standalone_host_product_and_crm_delivery_plan.md)
— that document owns the CRM object model, segment definitions, consent model
and provider gates. This spec does not redefine any of them; it fixes the two
Flutter surfaces that sit on top and closes the specified follow-ons that the
delivery plan already named.
Origin: 2026-08-15 owner + Claude audit of the Host Customers and Host
Messaging tabs. Every finding below was verified against the repo; evidence is
cited inline.

All owner decisions are settled as of 2026-08-16; see §8. Everything in this
document is ratified.
Proposed renders for every affected screen accompany this spec.

---

## 0. Background — what the two surfaces are today

### 0.1 Customers (`/host/customers`)

[`HostCustomersScreen`](../../lib/hosts/presentation/customers/host_customers_screen.dart)
(1,051 lines, screen + eight widget classes + two label helpers in one file)
renders an organizer-scoped, server-paginated directory:

- 4-stat summary strip from `hostCrmSummaryProvider` plus a sources sentence.
- One `Export this audience` button (CSV via the share sheet, whole audience or
  the active segment).
- A name search that fires only on `onSubmitted`.
- 13 filter chips — `HostCustomerFilter.values`
  ([`host_customers_screen_state.dart:17`](../../lib/hosts/presentation/customers/host_customers_screen_state.dart#L17)) —
  in a single horizontal scroller.
- `Add customer`, which collects a display name and nothing else.
- Rows built from `CatchField.nav`.

[`HostCustomerDetailScreen`](../../lib/hosts/presentation/customers/host_customer_detail_screen.dart)
renders identity → Manage → conversation → attendance → revenue → event
history. Data flows through
[`HostCrmRepository`](../../lib/hosts/data/host_crm_repository.dart), the only
callable boundary.

### 0.2 Messaging (`/host/inbox`, nav label "Messaging")

[`HostInboxScreen`](../../lib/hosts/presentation/inbox/host_inbox_screen.dart)
holds two workspaces behind `HostMessagingWorkspaceRail`:

- **Inbox** — 1:1 Catch match threads for the selected organizer, scoped by
  event (default: the live or next event) or "General inquiries", split
  booked/prospective with participation status labels, plus an event-broadcast
  card feeding [`HostBroadcastComposerSheet`](../../lib/hosts/presentation/inbox/host_broadcast_composer_sheet.dart).
- **Campaigns** — [`HostCustomerMessagingPane`](../../lib/hosts/presentation/host_operations/host_audience.dart),
  a part file of `host_operations_screen.dart`, rendering WhatsApp sender setup
  followed by a single-draft campaign composer.

---

## 1. Product frame (owner-ratified)

The top-level split — Customers is people, Messaging is conversation — is
correct and matches how the delivery plan already describes the workspace. Four
seams inside it are not.

**Seam A — the segment and the send never meet.** A campaign is *pick people →
pick message → send*. The people live entirely in Customers; the composer lives
in Messaging with no directory, no counts, and no preview of who is in a
segment. A host looking at "12 at risk" in Customers has no way to act on it,
and a host in the composer picks `_hostCampaignEligibleSegments` chips
([`host_audience.dart:23`](../../lib/hosts/presentation/host_operations/host_audience.dart#L23))
blind. **This is the highest-value fix in this spec.**

**Seam B — infrastructure sits on top of a workflow.** WhatsApp connect / sync
templates / send test / disconnect is the first thing on Campaigns, on every
visit, forever, long after setup is finished.

**Seam C — "Inbox" over-promises.** It contains Catch in-app threads only. The
host's real channel with most guests is WhatsApp, and inbound WhatsApp is
invisible in the app (§2.5).

**Seam D — nothing remembers what was sent.** Broadcasts and campaigns both
evaporate (§2.3, §2.4). A CRM's product is memory.

Underneath all four: the CRM remembers *attendance* and remembers nothing the
host knows or said. No notes, no manual tags, no per-person message history.
The delivery plan already names these as specified follow-ons
("Host notes, custom tags and per-person campaign history remain specified
follow-ons"); this spec schedules them.

### 1.1 Host jobs and where they land

| Job | Expected destination | Today |
| --- | --- | --- |
| Who is coming, who has not confirmed | Events → Guests | ✅ |
| Remind everyone before the event | Messaging → broadcast | ✅ |
| Who is here, who is asking questions | Events → Live + Inbox scoped to tonight | ✅ keep |
| Who came, who no-showed, thank them | Events → Report, then Customers | ⚠ split, no follow-up loop |
| Find my regulars/lapsed and message them | Customers → message | ✗ Seam A |
| "Priya is vegetarian and brings friends" | Customer detail | ✗ no notes |
| "Someone asked about parking on WhatsApp" | Inbox | ✗ Seam C |

Three of seven land where a host would look. The phases below close the four
that do not, in value order.

---

## 2. Verified findings

Each finding was reproduced against the current source. Fix location is given
per finding; phase assignment is in §4.

### 2.1 `valid:` swallows the segment tag and the chevron on every healthy row

[`HostCustomerDirectoryRow`](../../lib/hosts/presentation/customers/host_customers_screen.dart#L451)
passes both `valueText: _preferredCustomerTag(...)` and
`valid: !contact.hasAmbiguousIdentity` to `CatchField.nav`. In
[`_buildTrailingSlot`](../../lib/core/widgets/catch_field_row_modes.dart#L356)
the `valid` branch returns **before** the `_isNavigation` branch that renders
`valueText` and the chevron. Observed result:

| Contact state | Renders |
| --- | --- |
| Healthy (the overwhelming majority) | green `checkCircle` in `t.success`, **no segment tag, no chevron** |
| Ambiguous identity | segment tag + chevron, **no warning marker** |

So the most CRM-valuable field on the row ("Regular", "At risk", "High impact
advocate") is hidden from every normal customer and shown only on broken ones,
and every normal row wears a success badge for the state of *not being a data
problem*. Confirmed in
[`artifacts/ui-captures/host-organizer-messaging/host_customers_populated/light.png`](../../artifacts/ui-captures/host-organizer-messaging/host_customers_populated/light.png).

**Fix:** stop using `valid:` for identity state. Ship a person row (§4.1) that
renders name, metadata, tag and disclosure in fixed slots, and shows the
ambiguity marker as a warning on the exception only.

### 2.2 `HostCustomerFilter.attended` is a client-side page filter

`filter.tag` returns `null` for `attended`
([`host_customers_screen_state.dart:33`](../../lib/hosts/presentation/customers/host_customers_screen_state.dart#L33)),
so `hostAudienceSegmentForCustomerFilter` sends no segment and the server
returns the unfiltered page; the screen then filters
`contact.attendedEventCount > 0` over the loaded page only
([`host_customers_screen.dart:357`](../../lib/hosts/presentation/customers/host_customers_screen.dart#L357)).
With pagination this silently under-reports, and `Load more` can return a page
that renders zero new rows. The filter is also redundant: `attended` ≡
`first_time_attendee ∪ repeat_attendee`.

**Fix:** delete `HostCustomerFilter.attended`. Every remaining filter maps to a
server segment.

### 2.3 There is no campaign list, and campaign state is local

The Flutter repository exposes upsert / preview / approve / dispatch / cancel /
`getCampaignReport(campaignId)` and no list. The backend has no
`listOrganizerCampaigns` callable
(`functions/src/organizers/organizerCampaigns.ts` exports five `onCall`
handlers; `dispatchOrganizerCampaign` lives in `organizerCampaignDispatcher.ts`).
The pane holds the campaign in `HostCampaign? _campaign` local `setState`
([`host_audience.dart:62`](../../lib/hosts/presentation/host_operations/host_audience.dart#L62))
and `_newCampaign()` clears it. Switching tabs, switching organizer, or
backgrounding the app loses the only handle on a dispatched campaign, because
`getCampaignReport` needs a `campaignId` the host can no longer obtain.

**Fix:** `listOrganizerCampaigns` callable + a Sends list (§4.4).

### 2.4 Event broadcasts are write-only

`eventBroadcasts` appears in Flutter exactly once, as the resource label on the
write path
([`event_repository.dart:728`](../../lib/events/data/event_repository.dart#L728)).
Nothing reads it back. A sent announcement produces a snackbar and then does not
exist anywhere in the product.

**Fix:** broadcasts join campaigns in the same Sends list (§4.4).

### 2.5 Inbound WhatsApp replies are received and discarded

[`processInbound`](../../functions/src/organizers/organizerWhatsappWebhook.ts)
resolves the contact, flips recipient state to `replied`, and writes
`lastInboundAt` / `lastReplyAt` onto `organizerContactChannelStates`. **The
message body is never persisted and never surfaced.** A guest who replies to a
campaign asking about parking reaches nobody.

**Fix:** Phase 5 (§4.6), the phase that makes the Messaging tab worth its slot.
Everything before it must not describe the Inbox as containing more than it
does (§6).

### 2.6 `Add customer` creates a permanently uncontactable record

> Note: in production `Add customer` does not complete at all — the callable is
> not deployed (§2.10). This finding describes the record it creates once that
> is fixed; both need addressing, and §2.10 first.

`createOrganizerContact` accepts `organizerId` + `displayName` only
([`host_crm_repository.dart:927`](../../lib/hosts/data/host_crm_repository.dart#L927),
mirrored by the callable). `mutateOrganizerContact` accepts
`displayNameOverride`, `whatsappAdminSuppressed`, `hidden` — no endpoints. So a
manually added person can never be phoned, messaged, matched or merged; they
exist only to inflate `contactCount`.

**Fix:** optional phone/email on create, and endpoint edits on mutate, both
server-normalized (§4.3). Adding an endpoint must run the existing resolution
order and may produce a *proposed* link, never an auto-merge.

### 2.7 Merge/unmerge is implemented server-side and unreachable

`mergeOrganizerContacts` and `unmergeOrganizerContacts` are exported and tested
(`functions/src/organizers/organizerContactMerges.ts`,
`organizerContactMerges.test.ts`). No Flutter caller exists. The directory
surfaces `hasAmbiguousIdentity` as a dead-end marker, and
`host_customers.feature.json` records the exclusion as deliberate ("Merge and
unmerge controls remain backend-only until a reviewed conflict-resolution UI
exists").

**Fix:** the reviewed conflict-resolution UI (§4.5).

### 2.8 Campaign scheduling is plumbed on both ends with no UI

`organizerCampaigns.ts` reads `data.scheduledAtMillis` and derives a
`scheduled` status; `HostCampaignDraft.scheduledAt` exists
([`host_crm_repository.dart:802`](../../lib/hosts/data/host_crm_repository.dart#L802)).
`_saveAndPreview` never sets it.

**Fix:** schedule control in the composer (§4.4).

### 2.9 Smaller confirmed defects

| # | Finding | Evidence |
| --- | --- | --- |
| a | `smsReachable` filter and campaign segment are offered for a channel with no sender adapter — it can only return people the host cannot message | delivery plan: "SMS has no sender adapter" |
| b | Search fires only on submit and renders as a label, not an input | `onSubmitted` only, [`host_customers_screen.dart:175`](../../lib/hosts/presentation/customers/host_customers_screen.dart#L175) |
| c | No sort control; server default is `lastSeenAt desc` (or `searchName` when searching) | `organizerContacts.ts:620` |
| d | No result count anywhere — segment size is unknowable without exporting | screen has no count render |
| e | Customer event-history rows are `CatchField.read`, so they do not open the event | [`host_customers_screen.dart:899`](../../lib/hosts/presentation/customers/host_customers_screen.dart#L899) |
| f | Tapping the person in a host thread opens the consumer dating profile | `_openOtherProfile` → `Routes.publicProfileScreen` ([`chat_screen.dart:196`](../../lib/chats/presentation/chat_screen.dart#L196)) |
| g | Campaigns workspace has no search action, so the shared header changes shape when switching workspaces | `showSearch` is `isInbox && …` ([`host_inbox_screen.dart:141`](../../lib/hosts/presentation/inbox/host_inbox_screen.dart#L141)) |
| h | ~60% of the first Customers viewport is chrome; two rows are visible on a phone | capture, §2.1 |

### 2.10 `Add customer` fails in production: the callable is not deployed

**Reported 2026-08-16 by the owner: the `Add customer` button does not work in
the Host app.** Diagnosed the same day.

This is **not** a code defect. The client, the payload schema, the handler and
the transaction are all correct, and the flow works against dev. The callable
simply **does not exist in production**.

Measured against the live Firebase projects, not the repo:

```
firebase functions:list --project catch-dating-app-64e51   # prod
```

Production has seven organizer-contact callables —
`listOrganizerContacts`, `getOrganizerContactDetail`, `mutateOrganizerContact`,
`exportOrganizerContacts`, `mergeOrganizerContacts`, `unmergeOrganizerContacts`,
`onOrganizerContactEventEdgeInviteAttributed` — and **not**
`createOrganizerContact`. Dev has it. That asymmetry is the whole bug: every
other Customers surface works, so the directory loads normally and only this one
action fails, which is why it reads as "the button is broken" rather than "the
backend is missing".

`HostAddCustomerSheet._submit` catches the resulting error and shows an error
snackbar
([`host_customers_screen.dart:525`](../../lib/hosts/presentation/customers/host_customers_screen.dart#L525)),
so the failure is surfaced but attributed to the form rather than to a missing
deployment.

**Two adjacent gaps found by the same measurement.** A full diff of deployed
functions between dev and prod shows nine repo functions missing from
production:

| Missing in prod | Host-visible effect |
| --- | --- |
| `createOrganizerContact` | `Add customer` fails — the reported bug |
| `startOrganizerContactConversation` | **Starting a conversation from a customer fails the same way**, not yet reported |
| `controlEventSuccessLive`, `controlEventSuccessSpatial`, `getEventSuccessSpatialLayout`, `onEventSuccessPlanLiveControlUpdated`, `publishEventSuccessRotationRound`, `recordEventSuccessUnitOutcomes`, `upsertEventSuccessLayout` | The Event Success live and spatial runtime is undeployed in production |

(The reverse direction — 32 functions in prod but not dev — is entirely
BigQuery export extensions, which is expected and not drift.)

**Fix.** Deploy the missing functions to production. That resolves the reported
bug immediately and the unreported conversation one with it.

**Then close the class, not the instance.** This is the second production
incident in two days caused by *deployed state diverging from repo state* — the
first was the LIVE-tab failure, where the deployed Firestore ruleset was missing
five `match` blocks the repo had. Both were invisible to every gate in CI,
because CI verifies the repository and never asks the live project what it
actually has.

The durable fix is a deployment-parity check that enumerates deployed callables
for an environment and diffs them against the repo's exports, failing when a
repo callable is absent — the same shape as
`tool/firebase/check_deploy_ref.mjs`, which now refuses to deploy from a ref
behind its remote. That guard prevents publishing *stale* config; this one would
catch config that was never published at all.

---

## 3. Target information architecture (ratified)

```
Events        unchanged — Setup / Guests / Live / Report
Customers     people + memory + segment→send entry
Messaging     Inbox (threads)  ·  Sends (campaigns + broadcasts, history)
Organizer     …existing… + Messaging setup (WhatsApp sender)
```

Three decisions this encodes, and the alternatives rejected:

1. **Campaigns stay in Messaging; entry moves to Customers.** Sends live with
   sends, so a host has one place to answer "what did I send". The rejected
   alternative — moving the composer wholesale under Customers — splits sent
   history across two tabs and makes event broadcasts and campaigns
   inconsistent with each other.
2. **The Campaigns workspace becomes Sends** — a history list first, composer
   second. Setup moves out.
3. **WhatsApp sender setup moves to Organizer.** The composer keeps a one-line
   status and a "fix this" link resolving to the moved surface, driven by the
   existing `campaign.blockers` values.

The event-scoped Inbox default (live event → next event → general,
[`resolveHostInboxScope`](../../lib/hosts/presentation/inbox/host_inbox_view_model.dart#L196))
is the strongest IA in either screen. Do not change it.

---

## 4. Phases

Phases are independently shippable and ordered by host value per unit of work.
Phase 0 is a defect pass with no backend change and no new copy surface.

### Phase 0 — Row and directory defects

No callable changes. No new ARB keys beyond sort labels.

1. Introduce `HostCustomerRow` (a real person row, not `CatchField.nav`) in
   `lib/hosts/presentation/customers/`:
   `CatchPersonAvatar` · name at `CatchTextStyles.fieldRowTitle` weight ·
   one supporting metadata line at `supporting`/`ink2` · segment tag as a
   right-aligned mono label · fixed chevron. Ambiguity renders as a warning
   affordance in the tag slot with the text of `hostCustomersNeedsReview`, and
   is tappable to §4.5 once that ships (inert before then).
   This resolves §2.1 and §2.9h together and is the row reused by §4.2.
2. Delete `HostCustomerFilter.attended` and its label branch (§2.2). Update
   `host_customers_screen_state_test.dart` fixtures.
3. Gate `smsReachable` out of `HostCustomerFilter.values` and
   `_hostCampaignEligibleSegments` behind a capability check on
   `HostCrmSummary.smsReadiness`; when unavailable it must not render (§2.9a).
4. Search: debounce at 300 ms, keep the field visible, drop the submit-only
   behaviour (§2.9b).
5. ~~Add sort as a header menu.~~ **Removed from Phase 0 (2026-08-15).** This
   item was incoherent: it asked for a sort control while §"Phase 0" forbids
   callable changes, and assumed `Last seen` and `Name` were "free" options.
   They are not. Verified against source:

   - `contracts/callables/list_organizer_contacts_payload.schema.json` accepts
     only `organizerId, limit, cursor, query, segmentId` — **there is no sort
     field**.
   - `functions/src/organizers/organizerContacts.ts` orders by `searchName`
     only when a search string is present, and by `lastSeenAt` otherwise.
     Ordering is implicit in whether the caller is searching.
   - `lib/hosts/data/host_crm_repository.dart` sends only query, segment and
     cursor.

   So an honest selector requires extending the callable and its pagination,
   and a client-side sort would re-introduce exactly the page-scoped defect
   that item 2 removes. Sort moves to **Phase 1**, where contract changes are
   already in scope, and lands alongside `matchCount` with cursor support for
   each ordering.
6. Header compression: stats become one row of three plus an overflow, `Export`
   becomes a header overflow-menu action, and the intro sentence moves into the
   empty state (§2.9h).
7. Event-history rows in customer detail become `CatchField.nav` routed to the
   event (§2.9e).

**Done when:** the capture set for `host_customers_populated` shows name-first
rows carrying visible segment tags, no success ticks, and four or more rows
above the fold at 1x text scale.

### Phase 1 — Result counts and the filter summary

1. `listOrganizerContacts` returns `matchCount` for the active segment +
   search. Prefer an aggregate `count()` on the same query; if that is not
   viable within the projection budget, return `matchCountCoverage` =
   `exact | atLeast` and render `37` versus `37+` accordingly. Never render an
   estimate as exact.
2. The 13-chip scroller becomes: one **active-filter summary row** —
   `At risk · 12 people` with a clear affordance — plus a filter sheet grouping
   the segments as **Attendance / Reliability / Advocacy / Reachable**, each
   chip carrying its own count. `All` is the null state of the summary row.
3. Contract: extend `list_organizer_contacts_response.schema.json`; regenerate.

### Phase 2 — The segment → send bridge (Seam A)

The summary row from Phase 1 gains its second half: **`Message these 12`**.

1. The action is enabled only when the active filter maps to a segment eligible
   for campaigns and the organizer has an active sender; otherwise it renders
   disabled with the blocker reason from `campaign.blockers` vocabulary.
2. It routes to the composer with `segments` pre-selected and the audience
   summary already populated, i.e. the composer must accept an initial draft.
   Extract the composer out of `host_audience.dart` into
   `lib/hosts/presentation/inbox/host_campaign_composer.dart` with an
   `initialSegments` parameter; `HostCustomerMessagingPane` is deleted, not
   wrapped.
3. Segment chips inside the composer carry the same counts as Phase 1, from the
   same source, so the two surfaces cannot disagree.
4. Route: `/host/inbox?workspace=sends&compose=1&segment=<wireValue>`, so the
   bridge is deep-linkable and testable at the router level.

**Done when:** a host filters to `At risk`, taps `Message these 12`, and lands
on a composer that already says 12.

### Phase 3 — Contact memory (notes, tags, history)

The phase that turns the directory into a CRM.

1. **Notes** — `organizerContactNotes`, organizer-scoped, author-stamped,
   append-with-edit, gated by `requireOrganizerManager` (the same authority
   every other organizer contact callable uses — **not** `audience.readPii`,
   which does not exist; see the correction table in §5), and **excluded from
   export** (§8.1, settled). Callables: `createOrganizerContactNote`,
   `mutateOrganizerContactNote`, and notes returned with contact detail
   (bounded, newest first, `notesTruncated` like `eventsTruncated`).
2. **Manual tags** (cap: 20 per organizer, 5 per contact — §8.2, settled) — a separate namespace from computed segments, and rendered
   differently, so an organizer-authored `Brings friends` can never be mistaken
   for the versioned `high_impact_advocate`. Organizer-level tag vocabulary
   with a cap of 20 per organizer and 5 per contact (§8.2, settled); assignment
   via `mutateOrganizerContact`, whose payload schema must be extended to accept
   them.
   Manual tags are filterable in Phase 1's sheet under a fourth group,
   **Your tags**.
3. **Per-person send history** — contact detail lists campaigns and broadcasts
   this person received, with delivery state, from
   `organizerCampaignRecipients` plus the Phase 4 broadcast index.
4. Customer detail restructures to: identity → **memory** (notes + tags) →
   activity (attendance, revenue, event history, sends) → controls (manage,
   consent, remove). Memory sits above activity because it is the part only the
   host can supply.

### Phase 4 — Sends (Seam D) and scheduling

1. `listOrganizerCampaigns(organizerId, cursor)` callable returning summary
   rows (id, name, status, segments, template, audience counts, delivery
   counts, `scheduledAt`, `dispatchedAt`).
2. A broadcast index readable by the host: either an organizer-scoped
   collection-group query over `eventBroadcasts` or a projection written on
   send — **settled: a projection written on send** (§8.3). Rows carry event,
   audience, recipient count, sent time,
   and the partial-failure flag already returned by
   `SendEventBroadcastCallableResponse`.
3. The **Sends** workspace replaces **Campaigns**: one reverse-chronological
   list mixing both kinds, each row typed (`Campaign` / `Announcement`), with
   a primary `New message` action. Tapping a row opens the existing report
   view; `getCampaignReport` keeps working because the id now comes from the
   list.
4. Composer gains a schedule control writing `scheduledAt` (§2.8), with the
   server's `scheduleInPast` blocker surfaced inline.
5. WhatsApp setup moves to `/host/organizer/:clubId/messaging`, reusing
   `_buildWhatsappSetup` unchanged (Seam B).

### Phase 5 — Merge review (§2.7)

**Revised 2026-08-15** after the implementing agent stopped and challenged the
original text. Four of its objections were verified correct against source and
the phase is respecified here. The original assumed the backend already produced
review-ready candidates; it does not.

**Corrections to the original text.** All confirmed by inspection:

| Original assumption | Reality |
| --- | --- |
| Resolution already computes shared events, source and confidence | `organizerContactMerges.ts` compares contact fields only — no shared-event, source or confidence computation exists |
| Candidates exist for every evidence kind | `organizerAudienceProjection.ts` produces candidates from **verified UID/phone only**; imported-phone and email proposed links are not surfaced |
| `Different people` just dismisses | No durable negative-decision contract exists, so a dismissed pair reappears on the next projection |
| Merge is `audience.readPii`-gated | `readPii` appears nowhere in `functions/` or `lib/`. It is delivery-plan vocabulary that was never implemented; contact detail uses organizer-manager authority |

**Ratified decisions:**

1. **Scope Phase 5 to candidates that already exist** — verified UID and
   verified phone. This delivers the reviewed conflict-resolution UI, retires
   the dead-end ambiguity affordance, and unblocks the feature contract's merge
   exclusion. Discovering candidates from *proposed* links (imported phone,
   normalized email — levels 3 and 4 of the delivery plan's resolution order)
   is real projection work and becomes **Phase 5b**, not a prerequisite.
2. **Durable negative decisions follow the repo's existing idiom.** Add
   `contracts/firestore/organizer_contact_merge_review_decisions.schema.json`,
   modelled on the six existing `*_review_decisions` schemas
   (`organizer_event_candidate_review_decisions`, `organizer_intake_review_decisions`,
   and peers). A `Different people` decision is durable and suppresses that pair
   from future candidate listings; it is reversible by the same manager.
3. **Evidence is computed for review, not assumed.** The candidate listing must
   compute shared events, endpoint-match kind and confidence at read time, or
   project them; either is acceptable, but the surface must never display an
   evidence field it did not actually derive.
4. **Unmerge lives on the survivor's detail screen**, listing active merge
   receipts newest-first, each individually reversible. This needs a read-back
   seam — `getOrganizerContactDetail` currently rejects merged aliases and
   returns no receipts.
5. **Authority is the existing organizer-manager gate.** Do not introduce a
   capability system in this phase. Delete `audience.readPii` from this spec's
   vocabulary; it describes an intention, not a mechanism.
6. Nothing auto-merges. Name-alone candidates are never offered.

### Phase 6 — Inbound WhatsApp threads (Seam C)

The phase that makes Messaging honest.

1. Persist inbound message bodies from `processInbound` into an
   organizer-scoped thread model, retained under the same access and retention
   controls as contact PII, retained **12 months** (§8.4, settled; time-based
   expiry only — per-thread and per-contact deletion are out of scope).
2. Surface them in the Inbox as a third scope alongside event and general, or
   as a **channel facet on existing threads** (§8.5, settled) rather than a third
   Inbox scope.
3. Replies are subject to the WhatsApp customer-service window; the composer
   must show the window state rather than failing at send time.
4. Only after this ships may Inbox copy stop qualifying what it contains (§6).

---

## 5. Backend and contract work, by phase

| Phase | Callable / schema | Kind |
| --- | --- | --- |
| 0 | none | — |
| 1 | `list_organizer_contacts_response`: `matchCount`, `matchCountCoverage` | extend |
| 2 | none (routing + composer extraction only) | — |
| 3 | `organizer_contact_notes` (firestore), `create/mutateOrganizerContactNote`, contact-detail response `notes[]`, `mutateOrganizerContact.tags` | new |
| 4 | `listOrganizerCampaigns`, broadcast index, composer `scheduledAtMillis` wiring | new + wire |
| 5 | `listOrganizerContactMergeCandidates` | new |
| 6 | inbound thread model + retention | new ⚠ |

Every new schema goes through `contracts/` and generated types, per the
delivery plan. No hand-built client writes.

---

## 6. Copy rules

- **Never call the Inbox complete before Phase 6.** Empty states say what the
  list holds: "Questions from guests with a Catch account appear here."
- Manual tags and computed segments never share a visual treatment or a
  sentence. Computed tags keep the rule-based copy the delivery plan mandates
  ("At risk" stays presentation copy for versioned `lapsed_regular`).
- Field titles are labels, not instructions: `Search` not `Add search by name`,
  `Campaign name` not `Add internal campaign name` (§2.9b). Sweep the two
  surfaces for the `Add …` pattern on inputs.
- Counts render as `12 people`, never `12 contacts`, in host-facing copy.
- A disabled `Message these 12` states the blocker, not the fact of being
  disabled.

---

## 7. Evidence and registry updates

- `design/features/host_customers.feature.json`: add `sort`, `filter_sheet`,
  `notes`, `tags`, `merge_review` dimensions as their phases land; the
  `actionScope.excluded` merge entry is deleted by Phase 5, and the high-spender
  exclusion stays.
- `design/features/host_inbox.feature.json`: `workspace` values become
  `inbox | sends`; add `sends` content states and the `scheduled` campaign
  state; move `campaign_workspace` binding to the extracted composer file.
- `test/ui_captures/catalog/screen_capture_catalog.dart`: new states for
  filtered directory with the send bridge, contact detail with notes, Sends
  list, merge review.
- Widgetbook: `host_operations_use_cases.dart` campaign cases follow the
  composer extraction in Phase 2.
- Each phase updates `design/features/feature_coverage.json` and adds test
  evidence entries alongside the existing per-state map.

---

## 8. Owner decisions — all settled 2026-08-16

1. **Notes in export** — ✅ **Excluded.** Host notes never leave via
   `exportOrganizerContacts`, and there is no opt-in. Notes are the host's
   private record of a person, not part of the contact dataset.
2. **Manual tag cap** — ✅ **20 per organizer, 5 per contact**, enforced
   server-side with a clear error. The cap is what keeps tags a vocabulary
   rather than a second notes field.
3. **Broadcast index** — ✅ **Projection written on send.** An organizer-scoped
   summary row is written when a broadcast is sent, rather than reading through
   a collection-group query over `eventBroadcasts`. More work at write time, but
   reads stay simple and cheap, no composite index or cross-organizer rules
   review is needed, and it matches the pre-launch preference for clean schemas
   over query-time reconstruction.
4. **Inbound WhatsApp retention** — ✅ **12 months.** No opinion recorded on the
   deletion axis, so implement time-based expiry and leave per-thread and
   per-contact deletion out until asked for.
5. **Inbound surfacing** — ✅ **Channel facet on existing threads.** Inbound
   WhatsApp appears as a channel on the Inbox threads that already exist, not as
   a third scope. One list to learn, and a reply stays next to the rest of that
   person's activity instead of being stranded in a separate queue.
6. **`Most attended` sort** — ✅ **Accept the new Firestore composite index**, so
   all three orderings ship. `Most attended` is the ordering a host actually
   wants for spotting regulars, and the index cost is small at current volumes.

   Note that this decision alone does not make sort buildable:
   `contracts/callables/list_organizer_contacts_payload.schema.json` accepts
   only `organizerId, limit, cursor, query, segmentId` and has **no sort
   field**. Shipping sort means extending that payload and giving each ordering
   its own cursor semantics.
