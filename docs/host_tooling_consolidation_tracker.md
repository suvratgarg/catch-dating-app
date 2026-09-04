---
doc_id: host_tooling_consolidation_tracker
version: 1.4.0
updated: 2026-09-05
owner: host_tooling
status: active
---

# Host Tooling Consolidation Tracker

This tracker owns only unresolved Host tooling decisions that are not owned by the [standalone Host product plan](plans/standalone_host_product_and_crm_delivery_plan.md) or the [generated Audience responsibility README](../lib/hosts/audience/README.md). Completed implementation history belongs in Git and CI, not in this live document.

## Canonical ownership and durable constraints

- Audience is the canonical Host destination at `/host/audience`. People, Audiences, Forms, and Responses are peer modes; legacy `/host/customers` and `/host/forms` paths redirect into Audience. The generated README is the source for routes, code owners, handoffs, and exclusions.
- Host Event Manage remains the single per-event operations workspace for setup, live attendance/Event Success, report, cancellation, and unused-event deletion. Today and creation success are discovery/handoff surfaces; Event Detail does not grow a second Host operations section.
- Organizer owns organizer identity, settings, team, and payment-account configuration. Use `lib/hosts/organizer/README.md` for current route and code ownership; keep these controls out of Audience and event-specific runtime screens.
- The Host web target shares the Host Flutter product. Do not create a parallel React Host dashboard.
- Source implementation, merged source, deployed Functions/Hosting, configured providers, released clients, and user availability are separate states. This tracker never treats a source or test receipt as deployment proof and never recreates retired audit registries.

## Remaining decisions

| Decision | Current source-backed boundary | Close when |
| --- | --- | --- |
| `HOST-PUBLISHED-EDIT-POLICY-001` — published-event media/title policy | The edit screen supports pre-activity event name and policy fields; photo replacement is not exposed. Decide whether post-publication title changes beyond that existing pre-activity path and photo replacement are allowed, with attendee notice, title history, moderation/storage, and participant-activity rules. | Product policy, copy, moderation/storage behavior, and focused/runtime proof agree. |
| `HOST-EVENT-SUCCESS-SERVER-FREEZE-001` — post-activity setup freeze | The client repository rejects saving a non-`setup` or `frozenAt` plan, while live control sets `frozenAt` server-side. Decide whether server/rules enforcement must also block setup rewrites after bookings or other participant activity while continuing to permit live-step mutations. | A callable/rules boundary and tests prove the intended freeze and live-step exception. |
| `HOST-MANAGE-UNSAVED-STARTED-EDITOR-001` — started event with no saved guide | Host Manage still keeps the disabled setup editor visible for inspection when an event has started without a saved guide. | Setup/live/report states have complete focused coverage and the UI is reduced to the locked notice plus attendance/report surfaces. |
| Club archive/delete UX | `archiveOrganizer` and `deleteOrganizer` are implemented in `functions/src/organizers/mutateOrganizer.ts`; the Host-facing product policy remains to be decided. | Decide host visibility, archived browse/search behavior, never-used deletion guardrails, and exact owner/admin policy. |
| Host-owned event tiles in non-Host contexts | Preserve a clear handoff into the canonical event-management route; decide the entry points for host-owned tiles outside the Host app. | Decide whether inline Manage is permitted or whether opening detail remains the only non-Host-context entry. |
| Past-event navigation | Decide the boundary between the Today overview and durable past-event inventory in Events. | Decide the history volume, retention/filter model, and when a dedicated past-events destination is warranted. |

The create-event/Event Success atomicity decision is resolved in source: `functions/src/events/mutateEvent.ts` creates the event and optional `eventSuccessPlans` document in one transaction, covered by `mutateEvent.test.ts`. It is not an active decision here.

When a decision closes, update its owning product/architecture document and source-backed contracts in the same change. Preserve execution evidence through Git and CI; do not append historical checklists or verification logs here.
