# Catch Marketing Website

Vite + React marketing surface for `catchdates.com`.

## CI/CD

`.github/workflows/marketing-website.yml` validates marketing-site changes on
pull requests and deploys the production Firebase Hosting `marketing` target
after matching changes land on `main`.

The validation job checks generated design-token CSS, app-derived marketing
media, screenshot design-context drift, and the Vite production build.

The deploy job uses the repo's existing `prod` Firebase alias and Google Cloud
Workload Identity variables:

- `GCP_WORKLOAD_IDENTITY_PROVIDER`
- `GCP_SERVICE_ACCOUNT_EMAIL`

It deploys only `hosting:marketing`. If a marketing change also modifies the
waitlist Cloud Function, deploy Functions separately through the existing
Firebase deploy workflow.

## Analytics Setup

The site has a first-party analytics layer in `src/analytics.ts`.

- Set `VITE_GTM_ID` from `env.example` to load Google Tag Manager after consent.
- Configure GA4, Google Ads, Meta Pixel, LinkedIn Insight Tag, and other pixels in
  GTM against the pushed `dataLayer` events.
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
- `generate_lead`
