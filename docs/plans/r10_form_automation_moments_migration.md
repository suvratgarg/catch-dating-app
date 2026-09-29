---
doc_id: r10_form_automation_moments_migration
version: 0.2.0
updated: 2026-09-29
owner: program_operations
status: decision-brief
---

# R10 — formAutomation → triggered-Moments migration: decision brief

Decision 9 of the program-operations rollout approved migrating
`organizerFormAutomations` onto triggered Moments. This document is the
handoff brief: measured engine shapes, the corrected overlap analysis,
the options with concrete implementation plans, and the decision that
unblocks code. Pick an option and this document becomes the build spec.

## v0.2.0 corrections — what the source actually does

Two claims from v0.1.0 needed measuring against the code:

- **`notifyTeam` is not a channel send.** `notifyAutomationTeam`
  (`organizerFormAutomations.ts:1095`) writes `activities` docs through
  `createActivityForActiveUserIfAbsent` — an in-app feed entry titled
  "An organizer automation was triggered." No push/SMS/WhatsApp touches
  any delivery pipeline. Bridging it through Moments would change the
  user-visible behavior (feed entry → channel message), not just the
  plumbing.
- **`campaignHandoff` already rides a delivery pipeline.**
  `prepareAutomatedOrganizerCampaign` creates an `organizerCampaigns`
  doc, and the campaigns path (`organizerCampaigns.ts`) already enforces
  consent: `channelState.suppressionStatus === "optedOut"` and
  household `messagingConsent` exclusions are applied at recipient-row
  build time (`organizerCampaigns.ts:1046–1315`), with
  `deliveryCounts` journaled per campaign.

So the honest gap is narrower than "automation sends bypass Moments'
consent machinery": campaigns consent exists. What automations/campaigns
lack relative to Moments is the **unified send journal**
(`organizerMomentSends`), **quiet hours**, **per-endpoint daily cap**,
**replan/self-healing**, **travel-aware lead times**, and the
**staff-attention projection**.

## The two engines as built

### `organizerFormAutomations` (event-scoped CRM pipeline)

`functions/src/organizers/organizerFormAutomations.ts` (~1700 lines)
plus `organizerAutomationSource.ts`, `organizerAutomationCampaign`,
`organizerAutomationExecution`, `organizerAutomationWebhook`, and the
`organizerFormAutomationRules`/`organizerFormAutomationRuns`
collections.

- **Scope:** organizer (dating-event product), not program.
- **Triggers** (`automationTrigger` enum,
  `contracts/shared/organizer_form_operations_common.schema.json`):
  `responseSubmitted`, `responseWithdrawn`, `answerMatches`,
  `applicationAccepted`, `eventAttended`. Dispatch is edge-detection in
  the mutation handlers — `dispatchOrganizerFormAutomations`,
  `dispatchOrganizerApplicationAutomations`,
  `dispatchOrganizerAttendanceAutomations` compare before/after docs and
  enqueue a run per matching enabled rule.
- **Actions** (`automationActionKind` enum): `notifyTeam`,
  `addOrganizerTag`, `createCrmContact`, `addApplicationQueue`,
  `proposeEventAttendee`, `signedWebhook`, `campaignHandoff`. **Only
  `notifyTeam` and `campaignHandoff` produce messaging** — the rest are
  CRM/ops state changes and outbound webhooks.
- **Scheduling:** `delayMinutes` per rule; runs land in
  `organizerFormAutomationRuns` with `dueAt`, drained by
  `processDueOrganizerAutomations` (100-run sweeps, 180s deadline).
  Per-action results journal onto `run.actionResults`.

### `organizerMoments` triggered initiation (program-scoped messaging)

`functions/src/moments/` — unified messaging engine with send journal,
consent/quiet-hours policy, replan/self-healing, and travel-aware lead
times (#456).

- **Scope:** `initiation.kind === "triggered"` is **program-only**
  (`momentModel.ts` rejects `triggeredRequiresProgramScope`).
- **Trigger kinds:** `lateArrivalAtHotel`, `flightDisrupted` — both
  logistics facts evaluated in `ingestTravelLegEvent`.
- **Payload:** a moment is one message (template + audience +
  conditions). There is **no action/CRM concept** — a triggered moment
  sends a message and nothing else.
- **Subject binding:** `audience.kind === "subject"` is legal only
  with `triggered`; the triggering fact names the recipient.

## Where they actually overlap

Only the "fire a message when a fact lands" axis — and even that is
thinner than it looks: `notifyTeam` writes activity-feed docs, and
`campaignHandoff` creates a draft that a human later approves and sends
through `organizerCampaigns`. There is **no direct-send action** in the
automation engine today. The overlap is really *delivery semantics
drift*: three partially-overlapping delivery paths now exist
(campaigns, Moments, activity feed) with different journals, quiet-hour
behavior, and retry models.

## Decision matrix

| Capability | Campaigns path | Moments path | Automations |
|---|---|---|---|
| Consent/opt-out | yes (`suppressionStatus`, `messagingConsent`) | yes (`momentPolicy`) | n/a (delegates) |
| Send journal | per-campaign `deliveryCounts` | `organizerMomentSends` + run rows | `run.actionResults` |
| Quiet hours | no | yes | no |
| Per-endpoint daily cap | no | yes | no |
| Replan / self-healing | no | yes | no |
| Staff-attention projection | no | yes | no |
| Scope | event (organizer) | program (+event for scheduled) | event (organizer) |
| Trigger vocabulary | manual/reviewed send | `lateArrivalAtHotel`, `flightDisrupted` | 5 form/CRM edge kinds |
| CRM/action kinds | — | none (message only) | 7 action kinds |

## Options

### A. Messaging-consequence bridge (bounded)

Keep `organizerFormAutomations` as the CRM/trigger engine. Where an
action produces organizer- or guest-facing messaging, dispatch through
the Moments pipeline instead of the automation's own path.

**What this means concretely after measuring:**

- `notifyTeam` stays an activity write (it is not a channel message —
  moving it would be a product change, not a migration). **Nothing to
  bridge here unless product wants notifyTeam to become a real send.**
- `campaignHandoff` already lands in `organizerCampaigns`, which enforces
  consent. The bridge value is quiet hours + send journal + daily cap,
  delivered by having the campaigns send path journal into
  `organizerMomentSends` (or a shared `organizerMessageSends` contract)
  and consult `momentPolicy`'s quiet-hours/daily-cap check before
  dispatch — a seam inside `organizerCampaigns`, not a new Moments
  trigger kind.
- The literal v0.1.0 "enqueueMomentSend(fact)" seam is only needed if a
  future automation action sends directly to a guest without a campaign
  review step. Worth building then, not now.

**Slices:** (1) shared send-journal contract + campaigns journals into
it; (2) campaigns dispatch consults quiet-hours/daily-cap;
(3) optional `enqueueMomentSend` seam when a direct-send action kind is
added. Each lands independently.

### B. Full unification (the literal reading of decision 9)

Moments gains event scope, the five automation trigger kinds, subject
sources that resolve form responses/applications/attendance edges, and
non-messaging action kinds (or a generic "action" concept on moment
runs). Existing `organizerFormAutomationRules` docs migrate to moment
docs; the runs collection and its journaling merge.

- Large blast radius: `functions/src/index.ts`, moment contracts,
  generated outputs, rules, plus a live data migration of rules+runs.
- CRM actions inside Moments means the messaging engine grows an
  action-execution framework — arguably recreating the automation
  engine inside it.
- Requires a product answer on scope direction: Moments gains event
  scope, or automations move to program scope (automations serve events
  today — this is a product change, not plumbing).

### C. Status quo / defer

Automations work and are deployed, and the measured gap is smaller than
v0.1.0 stated: consent is already enforced on the campaigns path, and
`notifyTeam` never claimed to be a channel send. Defer until quiet
hours/daily caps on campaign sends become a real complaint, or a
direct-send action kind is proposed.

## The ask — the decision to record

1. **Option A, B, or C?** Recommendation: **A, sliced as above** — it
   captures the decision-9 intent (one delivery journal/policy for
   messaging) without pretending CRM actions are messages, and without
   a data migration.
2. If A: is journaled parity the bar (campaigns log into the shared
   journal + honor quiet hours), or must sends *render* through Moments
   templates too (deeper unify)?
3. If B: scope direction (Moments gains event scope vs automations move
   to program scope), CRM-action home, and whether live
   `organizerFormAutomationRules`/`Runs` docs migrate or cutover is
   new-rules-only.

## Implementation briefs (for the chosen option)

### If A (recommended)

- **PR 1 — shared send journal.** Contract
  `contracts/firestore/organizer_message_sends.schema.json` (or reuse
  `organizer_moment_sends` with a `source` discriminator), generated
  outputs via `tool/contracts/generate_schema_contracts.mjs`, and
  `organizerCampaigns` dispatch journaling each send row. Tests:
  journal row written per recipient; suppression rows journal as
  skipped.
- **PR 2 — campaigns honor quiet hours + daily cap.** Extract
  `momentPolicy`'s quiet-hours/daily-cap evaluation into a shared
  helper (`functions/src/moments/` already exports policy helpers —
  verify visibility, otherwise lift into `functions/src/shared/`),
  consult it in the campaigns dispatch path, and add `deferredUntil`
  handling mirroring `momentRunner.ts:424–431`.
- **PR 3 (optional) — `enqueueMomentSend` seam** only when a
  direct-send automation action is added.

### If B

Needs a design pass first: moment document schema gains event scope +
trigger kinds, `momentModel`'s `triggeredRequiresProgramScope` relaxes,
`audience.kind` gains form-response/application/attendance resolvers,
moment runs gain an `actions` array, Firestore rules + indexes for the
new collections, a one-shot migration function for
`organizerFormAutomationRules`→`organizerMoments` and
`Runs`→`organizerMomentRuns`, plus disabling the old dispatchers
(`dispatchOrganizerFormAutomations` et al.) behind a flag during
cutover. Estimate multiple PRs; do not start until scope direction is
decided.
