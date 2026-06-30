---
doc_id: ads_conversion_spec
version: 0.1.2
updated: 2026-06-30
owner: marketing_website
status: active
---

# Ads Conversion Spec

This spec defines the first conversion map for Catch acquisition ads. It covers
website and app events that can be imported into GA4, Google Ads, Meta, TikTok,
Reddit, LinkedIn, and later MMP or server-side conversion pipelines.

## Current Instrumentation

Website:

- `website/src/analytics.ts` captures first-touch and last-touch attribution.
- The tracked keys include `utm_source`, `utm_medium`, `utm_campaign`,
  `utm_content`, `utm_term`, `gclid`, `gbraid`, `wbraid`, `fbclid`, `ttclid`,
  `msclkid`, `li_fat_id`, and `rdt_cid`.
- GTM loads only when `VITE_GTM_ID` is set and the visitor accepts analytics or
  marketing consent.
- `website/src/App.tsx` emits waitlist, host lead, claim, review, store CTA,
  organizer, and generic CTA events into `dataLayer`.
- Direct organizer analytics is classified as analytics/marketing telemetry.
  `website/src/features/organizers/analytics.ts` suppresses the Firebase
  callable, local organizer session id, and `dataLayer` mirror until the visitor
  accepts analytics consent.
- `functions/src/waitlist/joinWaitlist.ts` normalizes marketing attribution and
  analytics metadata into Firestore.

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
- Preserve the existing `organizer_<eventName>` GA4 compatibility names until
  the host analytics mart is migrated, because `analytics/sql` currently maps
  exact names such as `organizer_claimClick` and `organizer_outboundClick`.

## Website Event Map

| Event | Primary conversion? | Source | Required parameters | Ad-platform use |
| --- | --- | --- | --- | --- |
| `page_view` | No | `trackPageView` | `page_name`, `page_path`, `page_location`, `page_title` | Retargeting and funnel denominator. |
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
| `organizer_listingView` | No | Direct organizer analytics callable mirror | `club_id`, `page_path`, `source` | Organizer page denominator. |
| `organizer_claimClick` | No | Organizer claim CTA | `club_id`, `page_path`, `source` | Claim-intent retargeting. |
| `organizer_outboundClick` | No | Organizer external links | `club_id`, `page_path`, `platform` | Host demand proof. |
| `cta_click` | No | Shared CTA helper | `cta_id`, `href`, `page_path` | Debug and audience learning. |

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

- GTM tags that set ad storage or marketing cookies must require accepted
  marketing consent.
- Analytics-only behavior should respect the current Consent Mode defaults.
- Organizer listing analytics is not essential telemetry. Public organizer page
  views, search appearances, saves, source clicks, event-card clicks, and claim
  clicks are recorded only after accepted analytics consent. Essential-only or
  unset consent must not create a local organizer analytics session id, call the
  organizer analytics callable, or mirror organizer events into the dataLayer.
- Server-side organizer analytics retention starts only after a consented client
  event reaches `recordOrganizerAnalyticsEvent`; the server hashes the
  browser-generated session id before writing `session_hash` to BigQuery and
  stores no raw session id.
- Do not upload first-party data to ad platforms without explicit legal and
  policy review.
- Do not build dating/singles lookalike or custom audiences until platform
  policies and consent basis are documented.
- Do not send PII, internal profile scores, private match details, or sensitive
  dating attributes to ad platforms.

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

Before launch:

- [ ] In a local or staging build with `VITE_GTM_ID`, accept all consent and submit one member waitlist lead.
- [ ] Confirm `waitlist_started`, `waitlist_submitted`, and `generate_lead` are visible in the GTM preview and GA4 DebugView.
- [ ] Submit one host lead and confirm `host_lead_started`, `host_lead_submitted`, and `generate_lead`.
- [ ] Submit one organizer claim and confirm `listing_claim_submitted` or `claim_flow_submitted`.
- [ ] Confirm Firestore stores marketing attribution and analytics metadata for the lead.
- [ ] Confirm Google Ads receives a test conversion before real spend.
- [ ] Confirm no tag fires when the visitor chooses essential-only consent, except consent/default analytics behavior allowed by the consent policy.
- [ ] Confirm organizer listing views, source clicks, saves, and search
  appearances do not call `recordOrganizerAnalyticsEvent` or push
  `organizer_*` dataLayer events before accepted analytics consent.

## Open Decisions

- Which launch city is the first consumer paid test?
- Which host market is first for abroad acquisition?
- Which platforms will receive dating/singles approval requests first?
- Is a server-side conversion pipeline required before Meta/TikTok tests, or can the first tests stay browser-only?
- Which app store pages and custom product pages are live enough for Apple Ads and Google App campaigns?
