---
doc_id: ads_launch_tracker
version: 0.1.0
updated: 2026-06-22
owner: marketing_website
status: active
---

# Ads Launch Tracker

This tracker turns the channel strategy in
[`marketing_channel_targeting_architecture.md`](marketing_channel_targeting_architecture.md)
into the first execution plan for paid acquisition. "Ads" means acquisition
ads for hosts, waitlists, bookings, organizer claims, and app installs. It does
not mean in-app ad monetization.

## Launch Principle

Do not start by spending broadly. Start by proving one audience, one targeting
primitive, one promise, one destination, and one conversion event.

The first paid motion should optimize for first-party demand that Catch can
inspect:

- host leads;
- member waitlist submissions;
- organizer claim submissions;
- app funnel events only after event naming and store pages are ready.

## Phase Status

| Phase | Status | Goal | Exit gate |
| --- | --- | --- | --- |
| P0 Measurement readiness | In progress | Make website and app conversions reliable enough for ad-platform learning. | GTM/GA4 receives consented test events for page view, lead start, lead submit, and organizer claim paths. |
| P1 Destination readiness | Pending | Route each campaign to a specific city, format, host vertical, or organizer page. | Every launch destination defines audience, promise, proof, CTA, policy risk, and tracking event. |
| P2 Policy readiness | Pending | Keep dating/singles campaigns from blocking safer social-event and host-tooling campaigns. | Direct dating copy is approved or deferred; safer social-event copy is ready. |
| P3 First campaign cells | Pending | Learn from small controlled tests before scale. | Each campaign cell has one channel primitive, one UTM pattern, one conversion action, and a stop rule. |
| P4 Scale readiness | Pending | Use first-party data only after consent and lead quality are understood. | Seed audiences are reviewed, legal/policy use is approved, and early conversion quality is known. |

## P0 Measurement Readiness

### Website Events

Current code already captures UTMs and click ids in `website/src/analytics.ts`
and emits lead events from `website/src/App.tsx`.

Required website conversion events:

- `page_view`
- `city_selected`
- `waitlist_started`
- `waitlist_submitted`
- `host_lead_started`
- `host_lead_submitted`
- `generate_lead`
- `store_cta_click`
- `store_cta_pending`
- `claim_flow_submitted`
- `listing_claim_submitted`
- `listing_public_review_submitted`
- `organizer_claimClick`
- `organizer_outboundClick`

Setup tasks:

- [ ] Create the production GTM container and set `VITE_GTM_ID` in the marketing website environment.
- [ ] Configure GA4 event tags for the website events above.
- [ ] Configure Google Ads conversion actions for `host_lead_submitted`, `waitlist_submitted`, and `generate_lead`.
- [ ] Configure Meta, TikTok, Reddit, and LinkedIn tags only through consent-aware GTM triggers.
- [ ] Use the client `event_id` for dedupe where a platform supports browser/server pairing.
- [ ] Validate first-touch and last-touch attribution are stored on `launchWaitlist` and `marketingConversionEvents`.
- [ ] Decide whether server-side conversion forwarding is needed after the first website-only tests.

### App Events

App campaigns should not optimize until the app event names match the current
event-platform model.

Required app conversion events:

- `first_open`
- `phone_verified`
- `profile_completed`
- `club_joined`
- `event_viewed`
- `event_booking_started`
- `event_booked`
- `event_booking_failed`
- `event_attended`
- `post_event_reaction_sent`
- `match_created`
- `host_club_created`
- `host_event_created`

Setup tasks:

- [ ] Rename stale run-booking analytics constants to event-booking constants.
- [ ] Wire missing funnel events where product actions already exist.
- [ ] Mark only meaningful events as GA4 key events.
- [ ] Import Firebase/GA4 conversions into Google Ads after DebugView verification.
- [ ] Defer Google App campaigns and Apple Ads until store pages match the active launch markets and formats.

## P1 Destination Readiness

The website should become a campaign router, not a single generic destination.

Priority destinations:

| Destination | Audience | Conversion | Initial channels |
| --- | --- | --- | --- |
| `/host/` | Founding hosts and event operators | `host_lead_submitted` | LinkedIn, Google Search, Instagram, outbound |
| `/organizers/` and listing pages | Claimable organizer profiles | `listing_claim_submitted` | Retargeting, direct outreach, search |
| `/city/{city}` | Launch-city members | `waitlist_submitted` | Google Search, Meta/Instagram, Reddit |
| `/formats/social-run` | Active-social members and hosts | `waitlist_submitted` or `host_lead_submitted` | Google Search, Instagram, creator posts |
| `/formats/racket-sports` | Pickleball, padel, tennis, badminton audiences | `waitlist_submitted` or `host_lead_submitted` | Google Search, Instagram, TikTok organic |
| `/for/new-to-city` | People seeking social context | `waitlist_submitted` | Reddit, Quora, Google Search |

Each new destination must document:

- audience;
- channel source;
- targeting primitive;
- promise;
- proof needed;
- conversion action;
- tracking event;
- policy risk;
- allowed and disallowed copy.

## P2 Policy Readiness

Run two copy families in parallel so one policy issue does not block all
acquisition.

### Safer Social-Event Family

Use before dating permissions are complete.

Allowed angles:

- "Meet people offline through hosted city events."
- "Join social runs, racket rotations, dinners, and quiz nights."
- "A better way to find your next weekend plan."
- "For hosts who want turnout, check-in, and repeat community."

Avoid:

- romantic promises;
- "lonely" targeting;
- sexualized imagery;
- implying the user has a personal problem.

### Direct Singles/Dating Family

Use only after platform approval and age targeting are clean.

Allowed angles:

- "Curated singles events that become real dating context."
- "Meet at the event first. Match after you both show up."
- "Singles runs, dinners, racket rotations, and mixers in your city."

Requirements:

- 18+ targeting;
- adult-looking creative;
- app store and landing page consistency;
- platform policy review before spend.

## P3 First Campaign Cells

Do not combine all targeting into one campaign. Each cell tests one learning
question.

| Cell | Channel | Targeting primitive | Destination | Conversion | Learning question |
| --- | --- | --- | --- | --- | --- |
| Host search | Google Search | Exact/phrase host intent keywords | `/host/` | `host_lead_submitted` | Are hosts already searching for event operating help? |
| City demand | Google Search | Exact/phrase city + social event keywords | `/city/{city}` | `waitlist_submitted` | Which launch-city terms show intent? |
| Format demand | Google Search | Activity + social/singles keywords | `/formats/{format}` | `waitlist_submitted` | Which format converts before broad city spend? |
| Host professional | LinkedIn | Role/function/company-size targeting | `/host/` or host vertical | `host_lead_submitted` | Which host segment replies with quality? |
| Social proof | Meta/Instagram | Geo + interest/engagement signal | City or format page | `waitlist_submitted` | Which creative hook earns real lead intent? |
| Organizer claim | Retargeting/direct | Listing visitors and contacted organizers | Organizer listing | `listing_claim_submitted` | Does public proof make organizers claim? |

## UTM Contract

Use the pattern from the channel architecture doc:

```text
utm_source={platform}
utm_medium={paid_social|paid_search|organic_social|community|partner|outbound|offline}
utm_campaign={geo}_{audience}_{format}_{objective}
utm_content={creative_hook}_{asset_type}_{variant}
utm_term={keyword_or_targeting_group}
```

Examples:

```text
utm_source=google
utm_medium=paid_search
utm_campaign=mumbai_consumer_socialrun_waitlist
utm_content=showupfirst_text_v1
utm_term=social_run_mumbai
```

```text
utm_source=linkedin
utm_medium=paid_social
utm_campaign=nyc_host_singlesevents_lead
utm_content=lessops_text_v1
utm_term=event_manager_founder
```

## First Spend Gate

Do not launch paid spend until:

- [ ] GTM and GA4 receive consented test events.
- [ ] Google Ads receives at least one test conversion from the website.
- [ ] Waitlist conversion documents include attribution and event metadata.
- [ ] Campaign URLs use the UTM contract above.
- [ ] Each ad has one destination and one conversion action.
- [ ] Dating/singles copy has either policy approval or is replaced by safer social-event copy.
- [ ] A daily stop rule exists for each cell.

## Stop Rules

Pause a cell when:

- tracking breaks or conversions cannot be reconciled to Firestore/GA4;
- the destination does not match the ad promise;
- lead quality is visibly wrong for the target audience;
- comments or review feedback show policy-risky interpretation;
- spend is optimizing toward cheap low-intent leads instead of qualified host or attendee demand.

## Reporting Cadence

Weekly reporting should answer:

- Which audience converted?
- Which targeting primitive produced the lead?
- Which destination was used?
- Which promise/creative hook was shown?
- Was the lead useful after inspection?
- What should be killed, rewritten, or scaled next?
