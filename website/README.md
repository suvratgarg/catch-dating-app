# Catch Marketing Website

Vite + React marketing surface for `catchdates.com`.

## CI/CD

`.github/workflows/marketing-website.yml` validates marketing-site changes on
pull requests and deploys the production Firebase Hosting `marketing` target
after matching changes land on `main`.

The validation job checks generated design-token CSS, app-derived marketing
media, screenshot design-context drift, route-contract drift, unit/a11y tests,
registry-backed Storybook visual baselines, and the Vite production build.

The marketing target serves generated static routes and keeps only the
explicit `/host/**`, `/claim/**`, and API rewrites. It deliberately has no
catch-all rewrite, allowing the generated `dist/404.html` to retain Firebase's
HTTP 404 status. The route checker enforces that configuration and the deploy
workflow probes a unique unknown production URL after deployment. The local
Hosting emulator uses port 5050 because macOS commonly reserves port 5000.
The retired `/host/preview{,/**}` family is a contract-backed permanent Hosting
redirect to `/host/`; there is no client route or duplicate page owner.

Organizer listing pages include a Firebase-backed claim form. Production builds
must set the Firebase web config and `VITE_WEBSITE_APPCHECK_SITE_KEY` from
`env.example`; local development falls back to the checked-in dev Firebase web
app config. Claim submission, public reviews, and host-visible organizer
analytics still need an App Check site key because the callable endpoints
enforce App Check.

Production organizer projection deliberately excludes `catchDemo` records.
`src/generated/hostListings.demo.json` is the separate demo-inclusive
Storybook/sales fixture and is checked independently. Home discovery further
filters production data to future Catch-bookable events in configured live
market cities; external events remain visible only on organizer listings.

Firebase Hosting deploys run
`node tool/env/check_web_hosting_env.mjs marketing` before building. Production
deploys should also validate
`--expected-project-id catch-dating-app-64e51` in CI or an equivalent manual
preflight, so the marketing site cannot ship with missing App Check or Firebase
config. Production marketing deploys also require an explicit store-link state:
`VITE_STORE_LINKS_MODE=prelaunch` requires both store URLs to remain empty and
serves the existing coming-soon/waitlist CTA, while `live` requires official
HTTPS `VITE_APP_STORE_URL` and `VITE_PLAY_STORE_URL` product links. The deploy
workflow defaults an unset GitHub Environment mode to `prelaunch`; set
`VITE_STORE_LINKS_MODE=live` in `prod-hosting` only when both listings exist.

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

## Content Contracts

Static marketing-authored content lives under `src/content/`. The copy scanner
has an empty migration baseline and blocks new authored strings outside this
directory. `src/content/generated.ts` is the mechanically centralized legacy
projection from the completed migration; new edits belong in page-owned files
such as `host.ts`, `site.ts`, and `marketing.ts`, not new generated keys.
`src/content/meta.json` is validated against
`src/content/meta.schema.json` through the shared browser-safe
`src/content/metaContract.ts`; both the client metadata adapter and static
postbuild execute that validator, and tests assert parity with the JSON Schema
over valid and invalid fixtures. `src/content/markets/in.ts` owns India-specific
cities, currency, geo labels, and comparison columns; features read it through
`src/content/markets/index.ts`. Keep route-specific page copy in direct
page-specific modules; do not add a new global content barrel that would pull
unrelated copy into lazy route chunks.
`src/content/interpolate.ts` is the sole template formatter and rejects both
missing and extra values at runtime while literal templates infer exact keys at
compile time. The copy ratchet scans production TypeScript and TSX, including
visible single-word, accessibility, and interpolated template strings.
Its baseline/allowlist registries are exact and fail on malformed, duplicate,
overlapping, or stale entries, forcing the debt count to shrink with migration.
The market pack uses stable structured city records with `live`/`waitlist`
status and one explicit featured-city id. Event-live and form options derive
from those records instead of parallel city lists. `npm run check:market-pack`
validates semantic references, timezones, ISO currency, and current India
option order before TypeScript runs. Site-wide app-store labels live in
`src/content/site.ts`; `useAppDownloadCtas.ts` remains the adapter that reads
environment URLs and combines them with that plain content data.

`src/content/legal.json` owns the published `/privacy/`, `/terms/`, and `/help/`
documents and confirmed operator/contact facts. `src/content/legal.ts` exposes
that data to the route, while `src/content/site.ts` owns the public mailto and
site-wide footer links. `npm run check:published-legal-content` rejects missing
routes, empty sections, or placeholder text before TypeScript runs.

Website analytics events inherit `content_version: "website_copy_v2"` from
the central adapter. `npm run check:analytics-contract` verifies the immutable
payload field and the unset, essential-only, and accepted consent-banner
states; it runs automatically before typecheck.

```sh
node --test ../tool/marketing/website_meta_contract.test.mjs
npm run check:routes
```

## Component Workbench

Storybook is the marketing website's Widgetbook-equivalent workbench. Stories
should attach route contract metadata from `design/website/routes.json` through
`parameters.catchRoute`, including the route id, path, and review states.
Component ownership and Storybook coverage are tracked in
`design/website/components.json`; update that registry when route or section
stories move.

Storybook accessibility is a real Chromium/axe CI gate, not just the addon
panel. The project default is `a11y.test = "error"`; 26 pre-existing findings
are explicitly classified as `todo` under stable debt id `WEB-A11Y-001` in
`design/website/a11y.todo.json`. `npm run check:a11y-debt` rejects any new,
missing, duplicate, or stale todo annotation, so new stories remain blocking
and the legacy set can only shrink deliberately. All stories share the runtime
`WebsiteQueryProvider` through the global preview decorator.

```sh
npm run check:components
npm run storybook
npm run build:storybook
npm run test:storybook:a11y
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

- Production deploys use `GTM-K7KLNQXP` unless the `prod-hosting`
  `VITE_GTM_ID` variable explicitly overrides it. The environment gate requires
  a valid container id, and the browser loads GTM only after analytics consent.
- `.github/workflows/website-production-observability.yml` probes the public
  launch routes every 15 minutes without a paid monitoring service. The same
  status, canonical-metadata, and content checks run immediately after a
  marketing deployment.
- Browser errors and unhandled promise rejections emit only a coarse
  `client_error` event after analytics consent. Error messages, stacks, query
  strings, and user identifiers are deliberately excluded.
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
- `client_error`
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
