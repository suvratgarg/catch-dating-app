---
doc_id: ads_conversion_spec
version: 0.6.0
updated: 2026-10-21
owner: marketing_website
status: active
---

# Ads Conversion Spec

Catch acquisition uses one typed contract in
`website/src/analytics/catchMeasurement.ts`, integrated through the existing
`website/src/analytics.ts` consent and lifecycle owner. The fixed Google and Meta
adapters in `website/src/shared/analytics/catchProviders.ts` accept synthetic destinations only. The production
controller has a disabled configured transport; no provider, credentials, tag,
customer list, spend, policy change, or backend deployment is enabled by default.

### Host server permission preparation

`functions/src/acquisition/consentHttp.ts` owns the separate
`/api/host-acquisition-consent` grant/withdrawal handshake. Its activation gate
is off. A new versioned purpose, a 32-byte random capability and a recent choice
are required; old intake analytics fields do not authorize server advertising.
Only a domain-separated capability hash is stored. Consent expires 30 days
after the original choice, and an exact retry cannot extend that expiry.
Withdrawal creates an irreversible tombstone for that capability, including
when it arrives before a delayed grant. Fresh permission uses a new capability.
The expiry worker transactionally rechecks at most 500 records every 15 minutes;
withdrawal tombstones outlive the grant and delivery windows.

The Meta policy prepares only a website `Lead` with the accepted Host receipt,
a canonical application URL, a hashed random browser identifier, browser user
agent and an optional real consented click. Contact details, answers, account
identifiers and guest information are excluded. Dispatch requires current
permission, at most five attempts and an age below 24 hours. Uncertain provider
outcomes are held for reconciliation. An HTTP 200 alone does not confirm receipt.
The accepting intake transaction can prepare a private delivery only for a new
Host receipt and current server advertising permission; the source gate remains
off. The worker reserves one attempt, rechecks the original Sales intent and
current permission immediately before dispatch, and clears browser context on
terminal outcomes. Withdrawal or deletion cannot retract a request already
sent to the provider. Explicit throttling may retry with backoff, up to five
attempts within 24 hours; timeouts and interrupted sends remain uncertain.
The expiry worker removes at most 500 expired delivery records per run.

The browser permission owner immediately stops local use on a changed choice,
persists pending withdrawal across reload, and will not grant fresh permission
until that withdrawal is acknowledged. It never queues conversion events.
The owner is connected to the browser consent and submission lifecycle. Its
separate activation mode invalidates prior Google-only choices. Only an
acknowledged current advertising grant can add the closed measurement packet to
a Host submission. Attribution retains the actual first observation time of a
Meta click; revisiting a URL does not refresh that click's timestamp.
Withdrawal clears queued browser context in bounded transactions.

`metaSender.ts` prepares a fixed Graph v26.0 Catch pixel endpoint, a ten-second
timeout, no redirects, no automatic network retry, and a bounded response body.
The disabled scheduled dispatcher examines at most 20 due entries per minute,
with current authority rechecked for each row. Its due-work index, exported
deployment binding, approved server credential and real destination receipt
remain unfinished; this is not a deployed delivery service.

### Host app permission preparation

The Host app denies collection by default, disables automatic screen reporting
and advertising storage/signals, and drops generic/private events and user IDs.
A device-local, versioned choice expires after 30 days and is separate from
website consent. Settings provides equally available allow and off actions.
Storage failure, old consent, expiry and withdrawal cannot grant permission;
withdrawal immediately closes the local event boundary and resets SDK data.
Environment and source release gates still override a granted choice. Native
collection is deactivated in this prepared release, which also overrides prior
persisted SDK grants before Dart starts. Activation requires a reviewed new
binary removing that native hold and opening the Dart gate; native upgrade
and withdrawal network acceptance must pass first. iOS vendor-ID and Android
advertising-ID collection are disabled.

Only coarse sign-in, onboarding and Host setup events are allowed. Event
creation is not organiser activation. Creation and publication diagnostics follow successful server responses;
replayed publications and operations spanning a consent change are excluded.
The private first-real-check-in milestone is prepared in `pilotActivation.ts`.
Admin or Admin Owner confirms a real event through the audited event editor,
with revision checks rejecting stale saves. The canonical roster trigger checks
current review, published event, organiser and check-in together before creating
one private organiser receipt. Check-ins before review, cancelled/private events,
replayed roster updates and undone check-ins are excluded. This operational
receipt does not grant advertising permission or export guest data. Its deployed
trigger, live acceptance, native upgrade/network checks and app-store privacy
declarations still require completion before measurement activation.
The two private pilot collections participate in the existing Sales privacy
inventory. A permanent organiser restriction blocks both new reviews and
activation receipts after cleanup. Direct browser reads and writes stay denied.

### Catch Host pilot destination configuration

`analytics/catchLiveTransport.ts` owns the prepared, default-disabled Google
transport. Its fixed destinations are GA4 `G-HZFG0DL2DK` (property
`559735544`) and Ads `AW-18526407471/dUL7CNKBn6MdEK-WioJF` (customer
`1016806229`, conversion action `7858536658`, accepted organiser lead).
The Ads action is secondary, counts one conversion per click, and has no
assigned monetary lead value. Account configuration is not proof of event receipt.

The runtime is a separate opaque-origin iframe with only `allow-scripts` and
`no-referrer`. It cannot read the parent DOM, storage or diagnostic bus.
Lifecycle destruction removes the frame and cancels its bounded initial-load
queue. It supplies explicit canonical page context, disables automatic views,
Google signals, personalization and URL passthrough. A fresh version-4 consent
receipt may supply a random client identifier with a 30-day maximum lifetime and an inactivity-bound session identifier; the opaque
frame still cannot read or write parent cookies/storage. Google ad storage and
personalisation remain denied; analytics storage permission follows the explicit
analytics choice and ad-user-data permission follows the marketing choice.
Only the four currently wired events are supported; only accepted organiser
leads with marketing permission emit the Ads destination. Meta's Catch Acquisition
dataset exists, but this source has no configured live Meta transport yet.

The exact isolated Next preview origin is allowed to exercise GA4 with
`debug_mode: true` and `traffic_type: internal`; Ads conversion sends are hard
blocked on that origin. Production stays disabled. No arbitrary preview host,
localhost or query flag can activate the transport.

The prepared browser context is Host-scoped in first-party storage for at most 30 days and is created
only when that transport is enabled and a fresh version-4 choice permits analytics.
The random analytics session ID rotates after 30 minutes of inactivity while the
client and attribution context have a fixed 30-day lifetime. Marketing permission additionally permits validated gclid/gbraid/wbraid/fbclid.
Google receives only Google click identifiers, rebuilt into the canonical page
location; Meta identifiers are not forwarded by this transport. GA4 campaign
labels also map to its documented campaign_source/medium/name/content fields.
Source preparation does **not** establish provider receipt or ad-click attribution.
Do not enable automated conversion bidding or claim campaign-level conversion
proof from a successful form submission or a synthetic network test. Before changing the `enabled`
gate, validate actual provider receipt and isolation, revise consent copy (which
currently says integrations are disabled), require a fresh consent receipt,
and review an explicit attribution design. A production deployment and ad
launch remain separate steps.

## Boundary and current delivery

The local `dataLayer` is a compatibility diagnostic bus, not an advertising export.
Do not attach GTM to it or forward/replay it: it contains local search, city,
raw CTA, claim and review diagnostics that are outside the outbound contract.
`VITE_GTM_ID`, including the historical GTM-K7KLNQXP fallback, cannot load a tag.
An external `window.gtag` is never called. A second tag stack is unnecessary.

Catch-owned acquisition and organizer-owned public-page tracking are separate.
Organizer publication remains hard-disabled with false/null public settings;
its existing controlled adapters, authority checks and server contracts are
unchanged. First-party organizer reporting still requires analytics consent.
Public attendee events, private forms, booking, offer, OTP, profiles and service
messaging never authorize Catch advertising. App observability and warehouse
reporting are separate sources, not inputs to these advertising adapters.

## Version 1 outbound event map

Each event has a fixed name and a rebuilt parameter allowlist. The synthetic
Google adapter emits GA4 analysis; selected organizer outcomes also map to a
separate Google Ads destination only with marketing permission. Meta requires
marketing permission and excludes attendee and brand events. Diagnostic/start
signals are not optimization outcomes.

| Contract event | GA4 name | Meta name | Google Ads selected outcome | Current authoritative source |
| --- | --- | --- | --- | --- |
| `page_view` | `page_view` | `PageView` | No | Allowlisted acquisition SPA visit; one per lifecycle visit; first consent starts the current visit without replaying earlier pages. |
| `cta_click` | `cta_click` | `CatchCtaClick` | No | Existing shared CTA helper; only a same-origin, allowlisted destination. Label and raw URL stay local. |
| `acquisition_start` | `acquisition_start` | `CatchAcquisitionStart` | No | First form interaction in member waitlist, host lead or host operating application; first explicit claim lookup/selection, role-step interaction or sign-in initiation in the canonical claim controller. |
| `lead_accepted` | `generate_lead` | `Lead` | Yes, organizer only | Validated successful `/api/join-waitlist` response with `ok: true`, authoritative `hostLead.isNew: true` with a stable server event ID, and unchanged submission-time permission. Member waitlist compatibility still uses `alreadyJoined: false`. |
| `organizer_signup` | `sign_up` | `CompleteRegistration` | Yes | Unwired: organizer-account-created authority with `isNewAccount: true`; ordinary sign-in/OTP is rejected. |
| `claim_approved` | `claim_approved` | `CatchClaimApproved` | Yes | Unwired: canonical claim decision with `status: approved`; pending submission is rejected. |
| `organizer_activated` | `organizer_activated` | `CatchOrganizerActivated` | No initially | Unwired: first published non-test event with a successful real check-in; a draft/event-created click is rejected. |
| `purchase` | `purchase` | `Purchase` | Yes | Unwired: settled Catch organizer payment authority, positive INR amount and opaque stable transaction ID; click/redirect/pending/free outcomes are rejected. |

The eight events support four candidate advertising outcomes: accepted organizer
lead, new organizer signup, approved claim, and confirmed organizer purchase.
Which outcomes become bidding goals needs separate activation review. First
activation is a quality signal initially. Current wiring supplies three diagnostic
events (including claim start) and accepted leads; the remaining four outcomes are contract seams, not
claims that providers already receive them.

The current Host-only scope rejects `member_waitlist` and the consumer homepage
at the measurement boundary; neither is sent to the acquisition property.
`host_lead`, `host_application` and `claim` belong to organizer acquisition.
Attendee booking and consumer paid conversion remain separate follow-ons.
No app profile, matching, singles/dating interest, or attendance data enters this
contract. App-side conversion inventories from older versions of this document
were planning proposals and are not an approved advertising export.

## Consent and lifecycle

The persistent `catch_marketing_consent_v4` receipt records version 4, choice,
analytics/marketing booleans, update time and the measurement mode (disabled,
Google preview, Google live or Host server live). A mode change requires a fresh choice; permission
chosen while integrations were disabled cannot silently activate providers. The banner offers essential only,
analytics, and explicit analytics plus marketing, with a persistent Privacy choices
control for withdrawal. Advertising remains disabled regardless of the choice.
Legacy version-1, version-2 and version-3 choices, including `accepted`, can retain local
analytics permission but never authorize the live transport or marketing;
the banner requires a fresh choice.
Malformed or unknown versioned receipts fail closed.

Unset/essential permission starts no measurement session. Analytics alone allows
synthetic Google analysis with advertising denied. Explicit marketing permits
synthetic organizer Google Ads and Meta events. Revocation/downgrade destroys
sessions immediately. Sibling-tab receipt changes refresh the banner and controller.
Every SPA lifecycle update runs the shutdown check, including entry into private
routes; returns to an acquisition route create a new visit without replaying old
views. First analytics consent starts a current-page view, not historical replay. Events before consent and failed delivery are dropped, not queued.

An accepted lead uses the permission captured when that request began. Accepting
mid-request cannot convert earlier activity; revoke/reaccept invalidates the old
receipt even within the same millisecond. The historical HTTP consent remains analytics-only. Its
historical `marketingAnalytics.consent` is not a versioned server advertising
permission. The prepared, disabled `hostMeasurement` packet uses the separate versioned
server permission handshake described above.

Consent Mode compatibility records stay local. Before any real Google transport,
review and apply default/update semantics for `analytics_storage`, `ad_storage`,
`ad_user_data`, and `ad_personalization` on that controlled destination, including
deny/revoke and signals/personalization behavior. Existing organizer GA4's denied
storage/signals behavior does not establish remarketing readiness. Google's
[consent implementation guide](https://developers.google.com/tag-platform/security/guides/consent)
requires consent defaults before measurement and updates when choices change.

## Payload and attribution

Only exact acquisition routes in `acquisitionRoute` qualify, including `/claim`
and `/claim/`; dynamic `/claim/:id`, organizer/event detail, form, booking, offer,
private Host work and demo routes fail closed. Page location uses the fixed Catch
origin, route name is a closed enum, and title is fixed to Catch. Referrer is
omitted. Search/hash, arbitrary hosts, CTA text, proof URLs, names, email, phone,
private answers, reviews, guest lists, organizer/request IDs and sensitive dating
attributes are never outbound parameters. Receipt IDs must be opaque generated
measurement IDs, not business identifiers. Purchase amount/currency are accepted
only for the settled organizer authority.

Campaign retention uses first-party local storage, expires after 30 days and clears on denial or
entry into an unapproved route. Only the closed, reviewed source/medium/campaign/
content vocabularies in `approvedCampaignLabels` persist in the existing HTTP
attribution payload; unknown labels and search terms are discarded. Separately,
`catchMeasurement.ts` owns the browser-only identifier context under a fresh
version-4 choice. Click identifiers are excluded for analytics-only choices,
clear on a changed consent revision/private route, and never enter the diagnostic
bus or existing lead HTTP payload. Storage failures drop the context. Host-to-`/claim` retains the approved touch.
New campaigns require a reviewed vocabulary change. There is no URL-passthrough, customer-matching, cross-device implementation or
deployed Meta delivery. The versioned server handoff is prepared and disabled. The preview and deterministic tests are acceptance
steps, not proof of a paid click being attributed.

## Outcome deduplication

Waitlist and host application controllers call `trackAcceptedMarketingLead` only
after a parsed HTTP success. Local form-specific successes and `generate_lead`
remain compatible but cannot enter the outbound adapters. The outbound contract
maps one `lead_accepted` to one `generate_lead` per destination. Host acquisition uses the backend `hostLead` receipt independently of the email-level
`alreadyJoined` flag: a prior attendee may make their first Host enquiry. The receipt
is written atomically with the private Sales intent and retained on the waitlist
record; exact request retries return the same receipt, while later submissions
retain the ID with `isNew: false`. Existing Host roles and legacy Host intents are
not reclassified as new acquisition. A legacy response without a receipt cannot
authorise a Host conversion. Host application retries
retain their request event ID and submission permission.
The waitlist controller also suppresses success measurements when its submitted
honeypot is populated: the server deliberately returns an opaque success without
storing those submissions. The Host operating application always submits an empty
honeypot.

A receipt ID is consumed once across business event names; purchase also consumes
its transaction ID. The tab-local bounded dedupe set is never cleared to replay
old conversions. It drops additional identified events if full. It is not a
server idempotency store. CAPI/cross-device delivery later needs stable server
IDs, event timestamps, browser/server dedupe, current consent and deletion rules.

## Verification and separate activation approvals

The focused suites exercise consent accept/deny/revoke, legacy isolation,
submission-time permission, private-route shutdown, SPA returns, `/claim`
continuity, closed labels and payloads, one outcome across aliases, new-account
versus sign-in, approval versus pending, attendee separation, provider failures
and settled purchase semantics. Consent UI also needs rendered mobile/desktop,
theme and large-text checks, plus the applicable registered website checks and
final-tree generators.

Before live activation, approve the exact Catch GA4 property/Google Ads conversion
labels/Meta dataset and transport, consent copy and lawful/policy basis, eligible
routes/categories, retention/deletion behavior, and a reviewed synthetic staging
validation. Verify provider delivery, consent changes, URL/title/referrer isolation,
SPA shutdown, dedupe and network payloads before enabling real destinations.
GTM is optional only if a controlled integration needs it; it must never consume
the existing bus wholesale. CAPI and customer matching are later steps. Organizer
pixels require their own publication and policy approval and stay disabled.

Missing server/app handoffs: organizer creation receipt, approved claim receipt,
first real event check-in/activation receipt, settled organizer purchase receipt, and
live acceptance of the prepared server marketing permission. Wire only those authorities when supplied;
do not infer them from login, pending claims, form success or a purchase page.

## GA4 organiser key event

Property 559735544 defines `host_lead_accepted` from `generate_lead` with
`audience = organizer`, copying the source parameters. It counts once per event,
without a default monetary value. The source suppresses repeated Host acquisitions using server receipts. This Analytics key event is not imported as a second Ads
conversion: the prepared direct Ads action remains the sole candidate to avoid
double-counting. Sales qualification and pilot activation are later outcomes.
