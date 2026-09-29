---
doc_id: r11_program_retention_policy
version: 0.1.0
updated: 2026-09-29
owner: program_operations
status: draft-for-review
---

# R11 — program retention / anonymization policy proposal

The rollout spec lists "retention / anonymization on archive" as R11's
last gap. This document proposes the policy for review before code —
what gets scrubbed, when, who can trigger it, and what must survive.
Nothing here is implemented; `organizerPrograms.status` already carries
an `archived` enum value, so the lifecycle hook exists.

## Principles

- **Operational truth survives, identity does not.** Counts, statuses,
  journals, and reports must still answer "how many guests checked in at
  the Sangeet" after anonymization — they lose the ability to answer
  "which guest was Nisha Rao."
- **Anonymization is one-way.** Scrubbed fields are nulled or
  tombstoned, never encrypted-for-later — the point is that a leaked
  backup after archive is a spreadsheet of counts, not a guest list.
- **CRM stays CRM.** `programGuests.contactId` points into the
  organizer's CRM store; retention scrubs the program-local copies, not
  the organizer's contact records (those have their own lifecycle).

## Trigger

`archiveProgram(programId)` callable, organizer owner/manager only:

1. Sets `organizerPrograms.status = "archived"` and
   `archivedAt` (new field).
2. Disables further mutations on program-scoped collections (rules +
   callable guards check status).
3. Kicks the anonymization sweep immediately — the policy proposal is
   that archive IS the anonymization point, not a delayed job. A
   scheduled fallback sweep (e.g. daily, programs where
   `endsAt` < now − 30 days and `status == "completed"`) is proposed as
   the safety net for organizers who never archive.

Alternative considered: separate "archive" (reversible) from
"anonymize" (irreversible). Rejected — two terminal states nobody
remembers to trigger is a policy that never executes. Archive prompts
the user once, irreversibly, after an explicit confirm.

## Field-level proposal

### Scrub (identity fields → null/tombstone)

| Collection | Fields scrubbed | Replacement |
|---|---|---|
| `programGuests` | `displayName`, `phoneE164`, `email`, `externalReference`, `contactId` | `displayName: "Guest <shortId>"`, others null; `anonymizedAt` set |
| `programHouseholds` | `primaryContactName`, `primaryPhoneE164`, `primaryEmail` | null; `anonymizedAt` set |
| `programStaffInvites` | `displayName`, `phoneE164` | null; `anonymizedAt` set |
| `programStaffGrants` | `displayName`, `phoneLastFour` | null; `anonymizedAt` set |
| `programFunctionGuests` | `responseNote` | null (free text, may carry PII) |
| `programStays` | `notes`, `roomLabel` | `notes` null; `roomLabel` scrubbed (room numbers tied to identities are a soft identifier) |
| `programDoorJournal` | `note` | null; action/partySize/functionId survive |
| `programTravelLegs` | `arrivalTerminal` detail stays — no PII fields; `manualCurbNote` | scrub free-text note fields only |

### Keep (operational truth)

- All `guestId`/`householdId`/`staffUid` document ids — anonymous
  references, required for joins and counts.
- `programFunctionGuests` RSVP/attendance statuses and counts —
  the attendance report must still reconcile post-archive.
- `programDoorJournal` action/partySize/functionId — door counts are
  the audit trail.
- `programTravelLegs` carrier/flight/status fields — flight numbers
  are itinerary facts, not identities; needed for "did the pickup
  happen" reconciliation.
- `organizerMomentSends`/`organizerMomentRuns` — `recipientKey` is a
  prefixed opaque id (`guest:|household:|uid:|contact:`); journal rows
  stay for delivery auditing, no scrub needed.
- `organizerPrograms` itself — title/dates/status/capabilities stay.

### Delete (documents whose only value was live operation)

- `programStaffInvites` with `status == "pending"`/`"expired"` —
  unclaimed invites carry a phone number for no live purpose. Proposed:
  delete outright at archive rather than scrub.
- Flight-alert leases/subscriptions on `programTravelLegs`
  (`flightAlertSubscriptionId`, `flightAlertLease`) — cancel provider
  subscriptions at archive; scrub the lease fields.

## What needs a product answer

1. **Grace period.** Should archive be immediate-anonymize (proposed),
   or archive now → anonymize at +N days (allows a "wedding recap"
   window where the planner still sees names)? If a window: proposed
   default is 14 days.
2. **Export before archive.** Attendance CSV export (#460) and trip
   reconciliation export (#471) already exist. Should archive require
   (or offer) a final export download in the confirm flow?
3. **`contactId` treatment.** Scrub the program-local pointer but keep
   CRM contact untouched (proposed), or keep `contactId` so post-event
   CRM follow-up stays linked? Keeping it means anonymized guests are
   still one join away from identity — that's fine if the threat model
   is "leaked program docs," not "revoke organizer access."
4. **Hard delete.** Is there a second stage — program deletion
   (whole-tree delete) at archive + N months — or is anonymized
   retention indefinite? Proposed: indefinite anonymized retention;
   organizer can delete the program entity separately if offered later.
5. **`archived` vs `completed`.** `completed` exists as a distinct
   status — should completion alone start the anonymization clock, or
   only explicit archive? Proposed: only `archived` anonymizes;
   `completed` stays fully readable (it is the natural post-event
   review state).

## Implementation shape (once policy is approved)

- One callable `archiveProgram` + one scheduled sweep + one internal
  `anonymizeProgram` worker: chunked writes over the collections above,
  idempotent (`anonymizedAt` marker guards re-entry), durable-ops
  journal entry per phase.
- Contract additions: `archivedAt`/`anonymizedAt` optional fields on
  the listed collections; `archive_program_payload` callable schema.
- Rules: program-scoped writes rejected when
  `organizerPrograms.status == "archived"`; staff reads continue
  (anonymized data is what they should see anyway).
- Tests: anonymize is idempotent; counts-only surfaces reconcile
  identically pre/post archive; pending invites deleted; free-text
  fields scrubbed; CRM contact docs untouched.
