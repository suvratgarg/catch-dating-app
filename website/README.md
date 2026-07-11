# Catch Marketing Website

Vite + React marketing surface for `catchdates.com`.

## CI/CD

`.github/workflows/marketing-website.yml` validates marketing-site changes on
pull requests and deploys the production Firebase Hosting `marketing` target
after matching changes land on `main`.

The validation job checks generated design-token CSS, app-derived marketing
media, screenshot design-context drift, route-contract drift, and the Vite
production build.

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

The production deploy job also runs a read-only claim-target sync against the
selected Firebase project and writes a temporary readiness receipt. Organizer
listing generation accepts that receipt only when its project id and exact
claim-target-plan SHA-256 match, so claim CTAs cannot be enabled from the
checked-in empty fixture or from a stale environment snapshot. This preflight
does not write Firestore. The reviewed organizer promotion pipeline uses the
same receipt handoff in `--claim-sync firestore` mode.

The deploy job uses the repo's existing `prod` Firebase alias and Google Cloud
Workload Identity variables:

- `GCP_WORKLOAD_IDENTITY_PROVIDER`
- `GCP_SERVICE_ACCOUNT_EMAIL`

It deploys only `hosting:marketing`. If a marketing change also modifies the
waitlist Cloud Function, deploy Functions separately through the existing
Firebase deploy workflow.

## Route Contracts

Route-first website review is owned by `design/website/routes.json`. Update that
contract before changing public routes, page metadata, static postbuild output,
organizer listing route families, sitemap inclusion, robots tags, or planned
review states.

```sh
npm run check:routes
```

`npm run typecheck` runs the generated organizer listing check and the route
contract check before TypeScript.

## Component Workbench

Storybook is the marketing website's Widgetbook-equivalent workbench. Stories
should attach route contract metadata from `design/website/routes.json` through
`parameters.catchRoute`, including the route id, path, and review states.
Component ownership and Storybook coverage are tracked in
`design/website/components.json`; update that registry when route or section
stories move.

```sh
npm run check:components
npm run storybook
npm run build:storybook
```

The checked-in starter stories live in `src/stories/MarketingRoutes.stories.tsx`
and cover `/`, `/host/`, `/host/preview/`, and `/organizers/` with mocked
app-capture assets where relevant. Host route section stories live in
`src/stories/HostSections.stories.tsx`; organizer search section stories live in
`src/stories/OrganizerSearchSections.stories.tsx`.
Storybook writes its static build to `storybook-static/`, which is ignored.

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

Claim conversion events use the ads contract keys `club_id` and `claim_role`.
Consent-based marketing events are still recorded for public organizer pages
whose App Check-protected host analytics callable is disabled; only the
callable dispatch is suppressed in that state.
