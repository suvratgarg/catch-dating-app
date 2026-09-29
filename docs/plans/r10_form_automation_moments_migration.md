---
doc_id: r10_form_automation_moments_migration
version: 0.1.0
updated: 2026-09-28
owner: program_operations
status: draft-for-review
---

# R10 — formAutomation → triggered-Moments migration: scoping question

Decision 9 of the program-operations rollout approved migrating
`organizerFormAutomations` onto triggered Moments. Inspecting both
implementations shows the two engines do not overlap as cleanly as
"migration" implies — this document lays out the real shapes, the
options, and the specific questions that need an answer before code.

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

Only the "fire a message when a fact lands" axis. Form automations are
primarily a **CRM pipeline with some messaging consequences**; triggered
moments are a **messaging engine with no CRM vocabulary**. The overlap
is precisely `notifyTeam`/`campaignHandoff` — and even those differ:
`campaignHandoff` creates a campaign draft for later review, not an
immediate moment send.

## Options

### A. Messaging-consequence bridge (bounded)

Keep `organizerFormAutomations` as the CRM/trigger engine. Where an
action produces organizer- or guest-facing messaging
(`notifyTeam`, `campaignHandoff`, future direct-message actions),
dispatch that message **through the Moments pipeline** instead of the
automation's own send path: template resolution, consent policy, quiet
hours, send journal, and retry semantics become shared automatically.

- Moments gains an initiation-adjacent "externally triggered send" path
  or a thin `enqueueMomentSend(fact)` entry point — no new scope or
  action kinds required.
- CRM actions (`addOrganizerTag`, `createCrmContact`, queues, webhooks)
  stay where they belong.
- Unifies *delivery semantics* (the user-visible win) without
  pretending tag/webhook actions are messages.

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
- Most paths involved are currently claimed by concurrent worktrees,
  so this cannot start immediately regardless.

### C. Status quo / defer

Automations already work and are deployed. The only real gap is that
their message sends bypass Moments' consent/journal/policy machinery.
If that gap isn't hurting, do nothing until B is designed properly.

## The ask

The product intuition is "one messaging engine, different triggers."
That is Option A's shape — but it treats *message delivery* as the
shared engine while triggers/actions stay in their owning domains,
which is the opposite direction from "migrate automations into
moments." Is that the intent? Specifically:

1. Should `notifyTeam`/`campaignHandoff` sends flow through Moments'
   send journal + consent + quiet hours (A), or does decision 9 mean a
   full engine merge (B)?
2. If B: do CRM action kinds become moment-run action kinds, or a
   separate `organizerMomentActions` concept? And does Moments gain
   event scope, or do form automations move to program scope (a product
   change — automations serve events, not multi-day programs)?
3. Is migrating live `organizerFormAutomationRules`/`Runs` documents
   in scope, or is the cutover new-rules-only?

## Suggested next step

If A: the concrete slice is a `program`-independent "external fact →
moment send" entry point in `momentRunner.ts` plus wiring the two
messaging action kinds to it — ~1 PR for the seam + 1 for adoption +
contract additions. If B, this needs a real design pass first and is
fenced by active worktree claims either way.
