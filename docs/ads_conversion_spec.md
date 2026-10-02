---
doc_id: ads_conversion_spec
version: 0.1.6
updated: 2026-09-30
owner: marketing_website
status: active
---

# Ads Conversion Spec

This spec defines the first conversion map for Catch acquisition ads. It covers
website and app events that can be imported into GA4, Google Ads, Meta, TikTok,
Reddit, LinkedIn, and later MMP or server-side conversion pipelines.

## Current Instrumentation

Website:

- `website/src/analytics.ts` maintains consent and local compatibility events.
  Arbitrary GTM loading and external `window.gtag` forwarding are disabled.
- Analytics-only, all-consent and essential-only choices are distinct; the
  persistent Privacy choices control allows revocation. First-party organiser
  telemetry also requires analytics consent; it is not essential collection.
- Attribution is consented, tab-scoped and expires after 24 hours. Only five
  bounded UTM labels (`utm_source`, `utm_medium`, `utm_campaign`, `utm_content`,
  `utm_term`) are retained. Click IDs, raw queries, referrers and private or
  transactional paths are excluded. Revocation clears retained attribution.
- `website/src/features/organizers/analytics.ts` owns direct listing/event views
  and outbound clicks. It never mirrors organiser events to advertising tags.
  Views deduplicate per organiser/event/tab/UTC day after accepted ingestion.
- `recordOrganizerAnalyticsEvent` verifies public scope, suppresses known owner
  previews, rate-limits ingestion, and stores a scoped session hash rather than
  the browser session ID. Anonymous previews and bots remain measurement limits.
- `observeOrganizerProviders.ts` separately owns page lifecycle for controlled
  GA4 and Meta adapters. GA4 requires analytics consent; Meta requires marketing
  consent. Revocation/navigation destroys the isolated provider iframe. Only
  public page views and outbound booking clicks are exposed; no purchase API,
  answers, guest lists, identity, private paths or arbitrary scripts are exposed.
- Per-organiser settings use generated contracts, server-side manager authority,
  revision checks and server-only Firestore storage. Hosts can save disabled
  validated IDs. Public publication is blocked by code and response schema until
  Catch advertising policy and provider delivery are reviewed. Private, sensitive,
  unclaimed and unknown contexts fail closed.
- Provider tests use fake transport/scripts only. The opaque iframe intentionally
  prevents access to Catch storage/DOM; live cookie support, GA4 cookieless
  delivery and Meta page attribution are unverified activation requirements.
- Existing lead/local compatibility events retain `content_version:
  "website_copy_v2"`. The historical event map below is a planning inventory,
  not evidence that a vendor currently receives those events.
- Server-authoritative Host reporting reads retained form/payment/admission facts
  as separate observed stages. Form fees are not admission; provider clicks are
  not purchases. Free confirmation and linked cohort attribution require further
  contracts; frontend success pages never establish paid conversion authority.

App:

- `lib/core/analytics/app_analytics.dart` provides the vendor-neutral analytics
  facade.
- Collection is controlled by release/profile mode and environment flags in
  `AppConfig.shouldCollectObservability`.

Warehouse:

- `analytics/sql/README.md` documents GA4 export and direct event inputs for
  host and user analytics marts.

## Event Naming Rules

- Use lower snake case for new marketing and app events.
- Start with a letter.
- Keep GA4 event names at 40 characters or fewer.
- Avoid PII in event parameters.
- Keep platform-specific click ids in attribution payloads, not ad hoc event
  parameters.
- Prefer product outcome names over legacy activity-specific names.
- Historical `organizer_<eventName>` GA4 names remain in legacy SQL preparation
  for diagnosis; direct first-party events now own Host presence counts. Do not
  restore advertising mirrors to inflate those counts.

## Website Event Map

| Event | Primary conversion? | Source | Required parameters | Ad-platform use |
| --- | --- | --- | --- | --- |
| `page_view` | No | `trackPageView` | `page_name`, `page_path`, `page_location`, `page_title`, `content_version` | Retargeting and funnel denominator. |
| `city_selected` | No | Waitlist form city field | `city`, `form_variant` when available | Audience learning. |
| `role_selected` | No | Waitlist form role field | `role`, `form_variant` when available | Audience learning. |
| `waitlist_started` | No | Waitlist form focus | `form_variant` | Lead-start funnel. |
| `waitlist_submit_attempt` | No | Waitlist form submit | `city`, `event_id`, `form_variant`, `role` | Debug and drop-off. |
| `waitlist_submitted` | Yes | Waitlist success | `already_joined`, `city`, `event_id`, `form_variant`, `role` | Consumer lead conversion. |
| `host_lead_started` | No | Host form focus | `form_variant` | Host lead-start funnel. |
| `host_lead_submit_attempt` | No | Host form submit | `city`, `event_id`, `form_variant`, `role` | Debug and drop-off. |
| `host_lead_submitted` | Yes | Host form success | `already_joined`, `city`, `event_id`, `form_variant`, `role` | Host lead conversion. |
| `generate_lead` | Yes | Waitlist/host form success | `city`, `event_id`, `form_variant`, `lead_type` | Cross-platform standard lead conversion. |
| `host_operating_application_started` | No | Detailed host application | `step` or page context when available | Host application funnel. |
| `host_operating_application_submitted` | Yes | Detailed host application success | `event_id`, host application fields already stored server-side | Qualified host lead conversion. |
| `store_cta_click` | No | App store CTA | `platform`, `placement`, `store_href`, `page_path` | Store-intent audience. |
| `store_cta_pending` | No | App store CTA without live URL | `platform`, `placement`, `page_path` | Launch readiness signal. |
| `claim_flow_submitted` | Yes | Claim page flow | `club_id`, `claim_role` when available | Organizer claim conversion. |
| `listing_claim_submitted` | Yes | Organizer listing claim flow | `club_id`, `claim_role` when available | Organizer claim conversion. |
| `listing_public_review_submitted` | No | Organizer listing reviews | `club_id`, `rating` when available | Review contribution signal. |
| `organizer_listingView` | No | Direct organizer analytics callable (no ad mirror) | `club_id`, `page_path`, `source` | Organizer page denominator. |
| `organizer_claimClick` | No | Organizer claim CTA | `club_id`, `page_path`, `source` | Claim-intent retargeting. |
| `organizer_outboundClick` | No | Organizer external links | `club_id`, `page_path`, `platform` | Host demand proof. |
| `cta_click` | No | Shared CTA helper | `cta_label`, `cta_href`, `page_path`, `content_version` | Debug and audience learning. |

All website events inherit `content_version` from `trackMarketingEvent`; event
rows do not repeat it unless the version is especially relevant to the row's
measurement role.
Both website CTA wrappers delegate their payload shape to
`marketingCtaClickParameters`; the pretypecheck analytics contract asserts
`cta_label`, `cta_href`, and `page_path` exactly and rejects a `cta_id` field.

## Website Copy v2 Launch Measurement Set

Use `content_version = website_copy_v2` to segment the migration launch. The
initial readout covers:

- store CTA click-through rate;
- event-browse click-through rate;
- member waitlist completion;
- host-application start and completion;
- organizer-claim conversion; and
- indexing guardrails for canonical, noindex, sitemap, and 404 behavior.

This is an observational launch readout, not an A/B testing framework.

## App Event Map

| Event | Primary conversion? | Source | Required parameters | Ad-platform use |
| --- | --- | --- | --- | --- |
| `first_open` | No | Firebase automatic or app bootstrap | environment/platform from base parameters | App install denominator. |
| `phone_verified` | Yes | Auth/onboarding success | `auth_method` when available | Activation quality. |
| `profile_completed` | Yes | Onboarding/profile readiness | profile-completion state, no PII | User quality conversion. |
| `club_joined` | No | Club membership action | `club_id` | Early intent. |
| `event_viewed` | No | Event detail/open | `event_id`, `activity_kind` when available | Event funnel denominator. |
| `event_booking_started` | No | Booking CTA/order start | `event_id`, `activity_kind` when available | Booking-start funnel. |
| `event_booked` | Yes | Successful booking/payment/waitlist decision | `event_id`, `activity_kind`, admission status when available | Booking conversion. |
| `event_booking_failed` | No | Booking failure | non-PII error code/category | Debug and quality guardrail. |
| `event_attended` | Yes | QR/self/host check-in | `event_id`, `activity_kind` when available | Highest-quality consumer conversion. |
| `post_event_reaction_sent` | No | Post-event interest/reaction | `event_id` | Post-event engagement. |
| `match_created` | Yes | Match creation | match context without PII | Dating outcome conversion, use carefully. |
| `host_club_created` | Yes | Host club creation | `club_id` | Host activation conversion. |
| `host_event_created` | Yes | Host event creation | `event_id`, `club_id` when available | Host activation conversion. |

## Key Events To Import First

Website-first import order:

1. `host_lead_submitted`
2. `waitlist_submitted`
3. `generate_lead`
4. `listing_claim_submitted`
5. `host_operating_application_submitted`

App import order, after DebugView verification:

1. `phone_verified`
2. `profile_completed`
3. `event_booked`
4. `event_attended`
5. `host_event_created`

Do not import every debug or start event as a bid target. Start events are
funnel diagnostics, not optimization goals.

## Consent And Audience Rules

- Arbitrary GTM and custom JavaScript are outside the controlled integration
  scope. Any future marketing adapter must require marketing consent.
- Analytics-only behavior should respect the current Consent Mode defaults.
- Organizer listing analytics is not essential telemetry. Public organizer page
  views, search appearances, saves, source clicks, event-card clicks, and claim
  clicks are recorded only after accepted analytics consent. Essential-only or
  unset consent must not create a local organizer analytics session id, call the
  organizer analytics callable. Organiser events are never mirrored to dataLayer.
- Server-side organizer analytics retention starts only after a consented client
  event reaches `recordOrganizerAnalyticsEvent`; the server hashes the
  browser-generated session id with organiser and UTC-day scope before writing
  `session_hash` to BigQuery and stores no raw session id.
- Do not upload first-party data to ad platforms without explicit legal and
  policy review.
- Do not build dating/singles lookalike or custom audiences until platform
  policies and consent basis are documented.
- Do not send PII, internal profile scores, private match details, or sensitive
  dating attributes to ad platforms.
- A name or phone captured for public event OTP, reservation service,
  operational check-in, account-continuation prefill, or organizer WhatsApp/SMS
  permission is not Catch advertising permission. It must not enter a customer
  list, enhanced conversion, retargeting, or lookalike export unless a separate
  Catch marketing permission, lawful basis, platform-category approval,
  suppression, retention, and deletion-propagation contract is active.
- Organizer channel permission is organizer-scoped. It cannot be pooled across
  organizers or reused by Catch for performance marketing.

## Dedupe Contract

Website lead events include a generated `event_id` in the dataLayer and in the
server payload. Use it for ad-platform dedupe where possible.

Server-side conversion forwarding should use:

- `event_id` from `marketingAnalytics.eventId`;
- conversion name from the normalized form variant;
- conversion timestamp from the server write;
- click ids from first-touch or last-touch attribution;
- consent state from `marketingAnalytics.consent`.

## Verification Checklist

Local automated gates:

- [ ] Validate generated callable/storage contracts and cross-organiser manager
  authority, revision fencing and explicit Firestore client deny rules.
- [ ] Verify essential/unset/invalid consent creates no analytics identifier or
  provider request; analytics-only never starts Meta; revocation removes tags.
- [ ] Verify public organiser/event rendered views deduplicate, wrong scope and
  private/unclaimed/unknown advertising contexts fail closed, and external clicks
  never become purchase or free-registration conversions.
- [ ] Verify populated, zero, missing and denied states in the existing Host tab,
  with partial/current-state stage captions rather than cohort conversion rates.

Before separately authorised live activation:

- [ ] Approve advertising policy, consent text, sensitive-category exclusions,
  retention/deletion rules and allowable provider attribution.
- [ ] Verify isolated runtime delivery with provider-owned test IDs in a reviewed
  staging setup; confirm cookieless GA4 limitations and Meta public-path reporting.
- [ ] Review any publication schema/gate change together with authority tests.
- [ ] Apply reviewed warehouse DDL/refresh changes and verify exact deployed
  schedule/source, freshness and complete source exports before claiming counts.
- [ ] Define server-authoritative conversion receipts and per-organiser sharing
  permission before forwarding paid/free booking outcomes to advertising vendors.

No live credentials, provider transmission or deployment is part of the current
local implementation or automated fake-provider tests.

## Open Decisions

- Which launch city is the first consumer paid test?
- Which host market is first for abroad acquisition?
- Which platforms will receive dating/singles approval requests first?
- Is a server-side conversion pipeline required before Meta/TikTok tests, or can the first tests stay browser-only?
- Which app store pages and custom product pages are live enough for Apple Ads and Google App campaigns?
