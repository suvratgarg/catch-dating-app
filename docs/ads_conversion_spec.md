---
doc_id: ads_conversion_spec
version: 0.2.0
updated: 2026-10-02
owner: marketing_website
status: active
---

# Ads Conversion Spec

Catch acquisition uses one typed contract in
`website/src/analytics/catchMeasurement.ts`, integrated through the existing
`website/src/analytics.ts` consent and lifecycle owner. The fixed Google and Meta
adapters in `website/src/shared/analytics/catchProviders.ts` accept synthetic destinations only. The production
controller has no transport; no provider, credentials, tag, customer list, spend,
policy change, or backend deployment is enabled by this implementation.

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
| `page_view` | `page_view` | `PageView` | No | Allowlisted acquisition SPA visit; one per lifecycle visit, no replay on consent. |
| `cta_click` | `cta_click` | `CatchCtaClick` | No | Existing shared CTA helper; only a same-origin, allowlisted destination. Label and raw URL stay local. |
| `acquisition_start` | `acquisition_start` | `CatchAcquisitionStart` | No | First form interaction in member waitlist, host lead or host operating application; first explicit claim lookup/selection, role-step interaction or sign-in initiation in the canonical claim controller. |
| `lead_accepted` | `generate_lead` | `Lead` | Yes, organizer only | Validated successful `/api/join-waitlist` response with `ok: true`, `alreadyJoined: false`, and unchanged submission-time permission. |
| `organizer_signup` | `sign_up` | `CompleteRegistration` | Yes | Unwired: organizer-account-created authority with `isNewAccount: true`; ordinary sign-in/OTP is rejected. |
| `claim_approved` | `claim_approved` | `CatchClaimApproved` | Yes | Unwired: canonical claim decision with `status: approved`; pending submission is rejected. |
| `organizer_activated` | `organizer_activated` | `CatchOrganizerActivated` | No initially | Unwired: first public event publication authority; a draft/event-created click is rejected. |
| `purchase` | `purchase` | `Purchase` | Yes | Unwired: settled Catch organizer payment authority, positive INR amount and opaque stable transaction ID; click/redirect/pending/free outcomes are rejected. |

The eight events support four candidate advertising outcomes: accepted organizer
lead, new organizer signup, approved claim, and confirmed organizer purchase.
Which outcomes become bidding goals needs separate activation review. First
activation is a quality signal initially. Current wiring supplies three diagnostic
events (including claim start) and accepted leads; the remaining four outcomes are contract seams, not
claims that providers already receive them.

`member_waitlist` is tagged `audience: attendee` and sent to synthetic GA4 only.
`host_lead`, `host_application` and `claim` belong to organizer acquisition.
Attendee booking and consumer paid conversion remain separate follow-ons.
No app profile, matching, singles/dating interest, or attendance data enters this
contract. App-side conversion inventories from older versions of this document
were planning proposals and are not an approved advertising export.

## Consent and lifecycle

The persistent `catch_marketing_consent_v2` receipt records version 2, choice,
analytics/marketing booleans and update time. The banner offers essential only,
analytics, and explicit analytics plus marketing, with a persistent Privacy choices
control for withdrawal. Advertising remains disabled regardless of the choice.
Legacy version-1 choices, including `accepted`, can retain analytics permission
but never become marketing permission; the banner requires a fresh choice.
Malformed or unknown versioned receipts fail closed.

Unset/essential permission starts no measurement session. Analytics alone allows
synthetic Google analysis with advertising denied. Explicit marketing permits
synthetic organizer Google Ads and Meta events. Revocation/downgrade destroys
sessions immediately. Sibling-tab receipt changes refresh the banner and controller.
Every SPA lifecycle update runs the shutdown check, including entry into private
routes; returns to an acquisition route create a new visit without replaying old
views. Events before consent and failed delivery are dropped, not queued.

An accepted lead uses the permission captured when that request began. Accepting
mid-request cannot convert earlier activity; revoke/reaccept invalidates the old
receipt even within the same millisecond. HTTP consent remains analytics-only in
the existing closed wire schema, with no new fields or backend permissions. Its
historical `marketingAnalytics.consent` is not a versioned server advertising
permission. Server forwarding requires a separately reviewed versioned handoff.

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

Campaign retention is tab-scoped, expires after 24 hours and clears on denial or
entry into an unapproved route. Only the closed, reviewed source/medium/campaign/
content vocabularies in `approvedCampaignLabels` persist; unknown labels, search
terms and click IDs are discarded. Host-to-`/claim` retains the approved touch.
New campaigns require a reviewed vocabulary change. There is no click-ID,
URL-passthrough, customer-matching or cross-device attribution implementation.

## Outcome deduplication

Waitlist and host application controllers call `trackAcceptedMarketingLead` only
after a parsed HTTP success. Local form-specific successes and `generate_lead`
remain compatible but cannot enter the outbound adapters. The outbound contract
maps one `lead_accepted` to one `generate_lead` per destination. Refreshed/already
joined records are not new acquisition conversions. Host application retries
retain their request event ID and submission permission.

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
first publication/activation receipt, settled organizer purchase receipt, and
versioned server marketing permission. Wire only those authorities when supplied;
do not infer them from login, pending claims, form success or a purchase page.
