---
doc_id: standalone_host_product_and_crm_delivery_plan
version: 1.0.0
updated: 2026-08-10
owner: host_tooling
status: active
---

# Standalone Host Product And CRM Delivery Plan

## Decision

Catch for Hosts is a first-class operations, reputation, audience, publishing,
and commerce product. Its minimum useful workflow must not depend on Catch
having sold the ticket or on an attendee having a Consumer dating profile.

The Host product and the Consumer network share organizers, events, operational
attendees, and explicit identity links. They do not share an onboarding
requirement. Hosts can adopt the system one capability at a time and may remain
on any rung indefinitely.

## Product Promise

The minimum Host promise is:

> Bring the event and guest list you already have. Catch gives your team one
> private run sheet, a clean roster, check-in, Event Success tools, feedback,
> review handling, and turnout analytics. Guests do not need the Catch dating
> app or a dating profile.

The progressive promise is:

> When you are ready, add audience follow-up, a public event page, OTP
> reservations, payments, a claimed organizer identity, and finally Catch's
> identity-rich network features. Each unlock is optional and explains its
> benefit, required setup, and data boundary before activation.

## Capability Ladder

| Rung | Host outcome | Required adoption | Host-facing message |
| --- | --- | --- | --- |
| 0. Operate | Run an externally booked event | Host phone OTP, workspace, event, imported/manual roster | "Bring your guest list. Run the event here." |
| 1. Learn | Collect feedback, request reviews, respond publicly, improve the next event | Rung 0 plus attendee contact or event-scoped OTP where a private response is needed | "Close the loop after every event." |
| 2. Retain | Understand past and repeat attendance; message the audience that explicitly opted into each channel | Rung 1 plus a channel-specific permission ledger and delivery setup | "Turn attendees into a permissioned repeat audience." |
| 3. Publish | Acquire demand through a Catch public page and accept free/open reservations | Public organizer/event projection, publication eligibility, attendee phone OTP | "Publish once; registrations join the same roster." |
| 4. Transact | Sell tickets and manage refunds/payouts | Payment onboarding, supported policy, payout readiness | "Let Catch own checkout and payment operations." |
| 5. Establish identity | Own an existing public listing and reputation channel | Organizer claim and verification | "Claim your page and make your reputation portable." |
| 6. Use the network | Add profile review, compatibility, discovery, swiping, catches, and chat | Feature-specific Consumer profile and consent | "Unlock identity-rich participation for guests who choose it." |
| 7. Grow with Catch | Measure acquisition and use lawful first-party advertising activation | Separate Catch marketing consent, legal/policy approval, suppression and deletion controls | "Use only the audience that explicitly chose Catch marketing." |

Rung 2 is deliberately before Catch booking. A Host may build repeat business
from externally booked events, but an imported phone number is never treated as
WhatsApp, SMS, or Catch advertising permission.

## Identity And Consent Model

### Operational attendee

An imported or manually entered `eventAttendees/{attendeeId}` row can support
roster operations, check-in, source-aware counts, exports, and public aggregate
analytics. It does not create Firebase Auth, a Consumer account, or a public
profile.

### Event-scoped verified attendee

The public website uses phone OTP to create or reuse a Firebase Auth UID, then
links that UID to the operational attendee. The experience does not ask for a
password, account creation form, dating preferences, photos, or profile
approval. The UID supplies a stable, verified private boundary for reservation,
waitlist, self-service, feedback, and later account continuation.

This is "no profile setup," not literal anonymous booking. The product should
say "continue with phone" rather than claim that no identity exists.

### Consumer member

The Consumer account is created only when the person intentionally continues
into Consumer onboarding. The OTP attendee may reuse their verified UID and a
private onboarding draft seeded with their supplied name and phone. Host-entered
data must not silently populate public or dating-profile fields.

### Four separate permissions

| Permission | Purpose | Default |
| --- | --- | --- |
| Event service | Confirmation, changes, cancellation, check-in, safety and receipt messages for the requested reservation | Allowed only to the extent necessary for that event and channel policy |
| Organizer WhatsApp | Future organizer updates over WhatsApp | Off until explicit organizer-scoped opt-in |
| Organizer SMS | Future organizer updates over SMS | Off until explicit organizer-scoped opt-in |
| Catch marketing/ads | Catch campaigns, customer-list uploads, retargeting or lookalike activation | Off until a distinct Catch permission and policy/legal gate |

Checkboxes are separate, optional, unbundled, and unchecked by default.
Importing data, booking an event, or opting into one channel cannot infer any
other permission. STOP/unsubscribe and self-service withdrawal must update the
same server-owned ledger and suppress future sends immediately.

## Surface Responsibilities

| Surface | Owns | Does not own |
| --- | --- | --- |
| Host Flutter app/web | Workspace, events, roster import/manual entry, check-in, Event Success runtime, feedback/review inbox, CRM segments, campaign composer, analytics, publication/payment/claim readiness | Consumer dating profile or a separate React Host dashboard |
| Marketing React website | Crawlable organizer/event pages, phone-OTP reservation, confirmation/change/cancel entry, optional organizer channel permissions, account-continuation CTA | Private roster, campaign management, or Host runtime |
| Consumer Flutter app | Intentional profile completion, identity-rich booking, profile approval, compatibility, discovery, swiping, catches, chat | Basic prerequisite for Host operations or OTP reservation |
| Admin React app | Consent disputes, import/link support, publication and message-template moderation, provider/webhook failures, refunds and deletion support | Routine Host operations |

## Implemented Foundation

The current foundation provides:

- a unified private operational roster for imported, manual, Catch-booked, and
  web-OTP sources;
- CSV/XLSX/manual import, idempotent import receipts, check-in, and independent
  Host turnout/source analytics;
- public phone-OTP registration for explicitly published, future, free,
  open-admission events, including transactional capacity and waitlist state;
- an onboarding-draft seed containing the attendee-supplied name and verified
  phone for an intentional later Consumer onboarding continuation;
- optional organizer-scoped WhatsApp and SMS grants collected independently at
  registration;
- a server-only communication-preference ledger and privacy-bounded Host CRM
  summary for contacts, past/repeat attendees, linked accounts, imports, and
  channel-reachable audiences;
- current-event in-app broadcast delivery through Activity and eligible push;
- public organizer reviews and owner responses on the marketing website;
- account deletion of onboarding drafts and organizer communication grants.

The CRM summary is not a campaign sender. WhatsApp and SMS remain visibly
`provider setup required` until their delivery and compliance gates below are
complete.

## Feature-Complete CRM

### Audience workspace

- deduplicated contact timeline across events, with source provenance;
- past attendee, repeat attendee, lapsed attendee, event/source/status, tag and
  channel-permission segments;
- private notes and tags with organizer-team audit history;
- identity merge/unmerge support with a clear imported-versus-verified state;
- CSV export and deletion/suppression handling;
- counts available before PII is revealed; only authorized managers may open
  contact detail.

### Campaign composer

- choose service or marketing message class before composing;
- choose one organizer and one or more eligible segments;
- show reachable, excluded, opted-out, invalid, duplicate, and unsupported
  counts before send;
- preview each channel, approved template variables, sender identity, schedule,
  frequency cap, and estimated cost;
- require an idempotency key and freeze the resolved audience at approval/send;
- record per-recipient channel delivery, failure, retry, reply, opt-out, and
  suppression receipts without exposing them to unrelated clients;
- add test-send, draft, approval, schedule, cancel, and post-campaign report;
- prevent free-form Host copy from bypassing template or moderation policy.

### Channel adapters

**In-app:** extend the existing event broadcast from current-event Consumer
participations to organizer-scoped, permissioned linked attendees and followers.
Preserve notification preferences and Activity as the durable user-visible
receipt.

**WhatsApp:** use an organizer/platform-owned WhatsApp Business integration,
approved business-initiated templates, webhook status/replies, STOP handling,
quality/frequency protections, and a clear decision about whether Catch or each
Host owns the sender identity.

**SMS in India:** select a provider, register the Principal Entity and sender
headers, approve consent/content templates where required, map each message to
the correct template, ingest delivery/STOP signals, and maintain suppression.

The scheduled campaign dispatcher, leases, retries, and delivery receipts
should use the Operations platform once the provider contracts exist. The
current aggregate summary remains an ordinary callable because it is bounded,
synchronous, and side-effect free.

## Feature-Complete Booking Without A Consumer Profile

Profile-independent reservation logic includes:

- free registration, capacity, waitlist position/state, promotion, cancellation
  and duplicate prevention;
- attendee confirmation code and signed self-service link;
- add-to-calendar, reminders, location/change/cancellation service messages;
- ticket type, quantity and companion inventory where policy does not require
  identity-rich approval;
- paid checkout using the verified phone identity, with payment, refund,
  receipt and payout linkage independent of a dating profile;
- event-scoped questions, waivers and preference-light Event Success inputs;
- self check-in and private feedback/review invitation.

Profile-dependent gates remain separate:

- profile review/approval based on photos or dating identity;
- reciprocal compatibility or cohort balancing using private preferences;
- swiping, catches, match chat and cross-event discovery;
- safety or membership policies whose proof depends on a completed account.

Paid OTP booking is architecturally valid, but it is not yet implemented on the
public website. The first public policy remains free and open admission so paid,
approval, invite, membership and profile-balanced flows fail closed.

## Remaining Delivery Tranches

### Tranche A: complete standalone operations

1. Migrate profile-independent Event Success assignments, feedback, and private
   attendee actions from UID-only keys to attendee IDs with optional linked UIDs.
2. Add guest-facing signed link/OTP entry for run-of-show actions, feedback,
   review invitations, reservation lookup/change/cancel, and reminders.
3. Add Host review/feedback inbox filters and response-rate analytics.
4. Add retention schedules, consent-history visibility, privacy export/delete,
   and Admin link/dispute tools.

### Tranche B: permissioned retention CRM

1. Build contact timeline, tags, notes, saved segments, suppression, and campaign
   draft/report schemas.
2. Extend in-app messaging to repeat-audience segments.
3. Choose WhatsApp ownership/provider model and India SMS provider/DLT assets.
4. Implement adapters, approved-template registry, webhook ingestion,
   unsubscribe/STOP, cost guards, delivery receipts, and campaign scheduling.
5. Add message limits, abuse review, host role permissions and Admin support.

### Tranche C: public reservation completeness

1. Add confirmation/change/cancel pages, transactional notifications, calendar,
   waitlist offers with expiry, and no-show/attendance reconciliation.
2. Add configurable event questions, ticket types and policy-aware admission.
3. Add paid OTP checkout, refunds, receipts, payouts and payment-support tools.
4. Keep invite, membership, manual approval and profile requirements explicit
   capability gates rather than inferred failures.

### Tranche D: reputation, identity and network depth

1. Finish claim verification, public organizer editing, verified response state
   and reputation analytics.
2. Add payment readiness and claim readiness as contextual next-step cards.
3. Offer intentional Consumer onboarding using the private draft, with an exact
   review/edit step before creating profile fields.
4. Unlock profile-dependent modules only after their specific profile, consent,
   event and safety requirements pass.

### Tranche E: lawful Catch growth activation

1. Define a separate Catch marketing permission, purpose, retention period,
   withdrawal path and deletion propagation.
2. Complete legal and platform-policy review for dating-category customer lists,
   retargeting and lookalikes.
3. Build hashed export/server-side activation only after consent and suppression
   checks; never give Hosts raw cross-organizer audiences.
4. Audit every outbound audience by purpose, platform, terms version, source,
   count and operator.

## Host UX Rules

- Start with "Import guest list" and "Create event" as equal paths. Do not make
  public listing, ticketing, or claim setup precede operations.
- Every locked capability names the outcome first, then the smallest required
  setup: "Collect payments - finish payout setup," not "Account incomplete."
- Show each event's integration mode and attendee-source mix.
- Never use one ambiguous "marketing consent" badge. Show In-app, WhatsApp,
  SMS, and Catch marketing separately.
- A campaign composer shows reachable audience before copy entry and explains
  exclusions without revealing people the Host is not authorized to inspect.
- OTP attendees see what was saved, why, how to edit/delete it, and that a
  dating profile has not been created.
- Consumer-app benefits are an optional upgrade, never a warning that makes the
  standalone product feel incomplete.

## Acceptance Criteria

The standalone Host strategy is feature-complete when:

- an organizer can operate, measure, collect feedback and respond to reviews
  for an event whose entire booking history originated elsewhere;
- an imported attendee can complete every profile-independent event action via
  signed link or phone OTP without installing the Consumer app;
- free and paid eligible reservations support confirmation, waitlist,
  cancellation, change, reminders, receipts and support without dating-profile
  setup;
- a Host can build a cross-event audience, but send only to recipients with the
  exact channel permission and required regulatory/provider eligibility;
- every outbound send is idempotent, moderated, rate-limited, auditable,
  suppressible and reflected in delivery analytics;
- OTP-supplied private data can prefill an intentional account flow, but is not
  published, treated as a dating profile, or uploaded to advertising systems
  without a separate lawful Catch marketing gate;
- each surface keeps its authority boundary and no parallel Host dashboard or
  event model is introduced.
