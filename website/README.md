# Catch Marketing Website

Vite + React marketing surface for `catchdates.com`.

## CI/CD

`.github/workflows/marketing-website.yml` validates marketing-site changes on
pull requests and deploys the production Firebase Hosting `marketing` target
after matching changes land on `main`.

The validation job checks generated design-token CSS, app-derived marketing
media, screenshot design-context drift, and the Vite production build.

Organizer listing pages include a Firebase-backed claim form. Production builds
must set the Firebase web config and `VITE_WEBSITE_APPCHECK_SITE_KEY` from
`env.example`; local development falls back to the checked-in dev Firebase web
app config. Claim submission, public reviews, and host-visible organizer
analytics still need an App Check site key because the callable endpoints
enforce App Check.

Firebase Hosting deploys run
`node tool/env/check_web_hosting_env.mjs marketing` before building. Production
deploys should also validate
`--expected-project-id catch-dating-app-64e51` in CI or an equivalent manual
preflight, so the marketing site cannot ship with missing App Check or Firebase
config.

The deploy job uses the repo's existing `prod` Firebase alias and Google Cloud
Workload Identity variables:

- `GCP_WORKLOAD_IDENTITY_PROVIDER`
- `GCP_SERVICE_ACCOUNT_EMAIL`

It deploys only `hosting:marketing`. If a marketing change also modifies the
waitlist Cloud Function, deploy Functions separately through the existing
Firebase deploy workflow.

## Analytics Setup

The site has a first-party analytics layer in `src/analytics.ts` and records
host-visible organizer metrics through `recordOrganizerAnalyticsEvent` in
`src/firebase.ts`.

- Set `VITE_GTM_ID` from `env.example` to load Google Tag Manager after consent.
  GTM is optional for Hosting deploys until the production container exists; the
  site skips GTM when the variable is unset.
- Configure GA4, Google Ads, Meta Pixel, LinkedIn Insight Tag, and other pixels in
  GTM against the pushed `dataLayer` events.
- Set `VITE_WEBSITE_APPCHECK_SITE_KEY` and the Firebase web config in
  production so organizer listing views, saves, contact clicks, claim clicks,
  outbound clicks, and event views can be accepted by the App Check-protected
  callable and written to BigQuery.
- The waitlist form sends attribution and an event ID to `/api/join-waitlist`.
- The Cloud Function stores attribution on `launchWaitlist` and writes a
  `marketingConversionEvents/{eventId}` record for later server-side conversion
  review or CAPI wiring.

Primary web events:

- `page_view`
- `cta_click`
- `city_selected`
- `role_selected`
- `waitlist_started`
- `waitlist_submit_attempt`
- `waitlist_submitted`
- `host_lead_started`
- `host_lead_submit_attempt`
- `host_lead_submitted`
- `listing_claim_sign_in_started`
- `listing_claim_signed_in`
- `listing_claim_submit_attempt`
- `listing_claim_submitted`
- `generate_lead`
- `organizer_listingView`
- `organizer_searchAppearance`
- `organizer_eventView`
- `organizer_organizerSave`
- `organizer_eventSave`
- `organizer_contactClick`
- `organizer_claimClick`
- `organizer_outboundClick`
