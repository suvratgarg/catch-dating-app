---
doc_id: web_surface_architecture
version: 0.6.0
updated: 2026-06-30
owner: web_platform
status: active
---

# Web Surface Architecture

## Decision

Use one apex domain with separate subdomains for distinct web products:

| Domain | Surface | Repo source | Firebase Hosting target |
|---|---|---|---|
| `catchdates.com` | Public marketing site, public host pages, SEO pages, legal/support pages, app-link files, and public lead capture | `website/` | `marketing` |
| `www.catchdates.com` | Redirect to `catchdates.com` | Firebase custom domain redirect | `marketing` |
| `app.catchdates.com` | Consumer app on Flutter web | `build/web` | `app` |
| `admin.catchdates.com` | Internal admin and analytics console | `admin/` | `admin` |

Keep the Flutter web app separate from the public website. The Flutter web app is
the consumer app surface and should continue sharing mobile app code. The
marketing and admin surfaces are web-native products and should use the same
React + TypeScript stack where practical.

## Current Stack

- Root `package.json` exposes npm workspace scripts for the web-native apps.
- `packages/web-config/` contains shared Vite, TypeScript, and token/base CSS
  plumbing for React web surfaces.
- `website/` is a Vite + React + TypeScript marketing app.
- `website/public/` contains Vite public assets, including `.well-known/`, fonts,
  app-sourced marketing screenshots, and the favicon.
- `website/dist/` is the deployable marketing build.
- `website/scripts/postbuild.mjs` writes route-specific static HTML after the
  Vite build for `/host/`, `/claim/`, `/organizers/`, canonical organizer
  listings, legacy organizer routes, `robots.txt`, and `sitemap.xml`.
- `admin/` remains the separate Vite + React + TypeScript admin app.
- `build/web` remains the Flutter web deploy artifact for `app.catchdates.com`.

Design-token CSS and web font copies are generated into
`packages/web-config/generated/` by `dart run tool/design_tokens.dart`, then
bundled by Vite through `packages/web-config/styles/catch-web.css`.

## Firebase Hosting Setup

`firebase.json` declares three Hosting targets:

- `marketing`: builds `website/` and deploys `website/dist`.
- `app`: deploys `build/web` for the Flutter web app.
- `admin`: builds `admin/` and deploys `admin/dist` with `X-Robots-Tag:
  noindex, nofollow`.

The production `.firebaserc` currently binds `marketing` to the existing default
Hosting site, `catch-dating-app-64e51`. Before deploying the `app` or `admin`
targets, create or choose actual Firebase Hosting site IDs and bind them:

```sh
firebase target:apply hosting marketing <marketing-site-id> --project <project-id>
firebase target:apply hosting app <app-site-id> --project <project-id>
firebase target:apply hosting admin <admin-site-id> --project <project-id>
```

Then attach custom domains in Firebase Hosting:

- `catchdates.com` and `www.catchdates.com` to the marketing site.
- `app.catchdates.com` to the app site.
- `admin.catchdates.com` to the admin site.

The existing default Hosting site can remain the marketing site if it is already
bound to `catchdates.com`; the app and admin surfaces should still be separate
Hosting sites.

## Marketing CI/CD

`.github/workflows/marketing-website.yml` is the marketing site's scoped
pipeline:

- pull requests validate generated web tokens, app-derived screenshot assets,
  marketing screenshot design context, and the Vite production build;
- pushes to `main` that touch marketing-site inputs deploy only
  `hosting:marketing` to the production Firebase project;
- deployment uses the checked `prod` Firebase alias plus the repo's existing
  Google Cloud Workload Identity environment variables.

The workflow intentionally does not deploy Cloud Functions. Backend production
changes, including `/api/join-waitlist`, still go through the guarded Firebase
deploy workflow so hosting and backend release risk stay independently
controlled.

## Marketing Website Audit And Remediation

The 2026-06-23 audit covered the React marketing app, public organizer pages,
generated listing pipeline, public callables used by the website, shared web
tooling, and the marketing deploy path. It used three read-only subagent slices:
UI/component architecture, data/contracts/API boundaries, and
delivery/SEO/performance.

Original verification run during the audit:

- `dart tool/audit_registry.dart refresh`
- `npm --workspace catch-marketing run build`
- `node --test website/scripts/checkOrganizerBuildOutputs.test.mjs website/scripts/generateOrganizerListings.test.mjs website/scripts/postbuild.test.mjs`
- `node website/scripts/checkOrganizerBuildOutputs.mjs`
- `git diff --check -- website package.json packages/web-config firebase.json .github/workflows/marketing-website.yml contracts/callables/request_club_claim_payload.schema.json contracts/callables/create_public_club_review_payload.schema.json contracts/callables/list_public_club_reviews_payload.schema.json contracts/callables/record_organizer_analytics_event_payload.schema.json contracts/firestore/clubs.schema.json functions/src/clubs/clubClaims.ts functions/src/reviews/mutateReview.ts functions/src/analytics/organizerAnalyticsEvents.ts`

The original marketing build passed. It reported a single JS bundle of 484.71 KB
raw, 139.82 KB gzip, a 92.02 KB CSS bundle, and a 2.1 MB public source map. The
generated organizer output check reported 3 listing routes, 2 legacy routes, and
2 sitemap listing routes.

### Remediation Status 2026-06-25

Current verification:

- `npm --workspace catch-marketing run typecheck`
- `node --test website/scripts/checkOrganizerBuildOutputs.test.mjs website/scripts/postbuild.test.mjs website/scripts/generateOrganizerListings.test.mjs`
- `npm --workspace catch-marketing run build`
- `node website/scripts/checkOrganizerBuildOutputs.mjs`
- `find website/dist/assets -maxdepth 1 -type f -name '*.map' -print`
- `node tool/contracts/generate_schema_contracts.mjs --check`
- `npm --prefix functions run build`
- `node --test functions/lib/clubs/clubClaims.test.js functions/lib/reviews/mutateReview.test.js functions/lib/analytics/organizerAnalyticsEvents.test.js`

Current build output reports `index-BKnP8e8u.js` at 487.92 KB raw / 143.12 KB
gzip and `index-C-RDtpwQ.css` at 92.02 KB raw / 14.41 KB gzip. No public
`.map` artifact is emitted by default. The generated organizer output check
reports 3 listing routes, 2 legacy routes, and 2 sitemap listing routes.

| Original finding | Status | Evidence |
|---|---|---|
| Legacy organizer routes can hydrate from `noindex` to `index`. | Resolved | Route metadata now preserves legacy `noindex`; postbuild and output tests cover listing, legacy, and sitemap outputs. |
| `/claim/` has client-side metadata but no generated static route. | Resolved | `website/dist/claim/index.html` is emitted during postbuild and covered by build-output checks. |
| Public source maps are deployed with full source content. | Resolved | Public sourcemaps are opt-in through `CATCH_WEB_PUBLIC_SOURCEMAPS`; the current build emits no `.map` files. |
| The marketing app is not feature-first yet. | Resolved | `website/src/App.tsx` is a 66-line shell; pages, controllers, selectors, models, and styles live under feature folders. |
| Website types duplicate contract-owned backend schemas. | Resolved | Organizer listings and callable DTOs import generated contract types from `functions/src/shared/generated`. |
| Static website data can drift from Firestore API state. | Resolved | Generated listings include `publicApi`; claim/review/analytics clients disable public APIs when claim-target sync is not verified. |
| Public review and organizer analytics scope checks are too broad. | Resolved | `assertPublicOrganizerPageEligible` gates public reviews and organizer analytics by publish state, robots/index status, canonical path, and club state. |
| Approved cleaned event data is not yet an app event feed. | Closed as boundary | Public event evidence remains separate from app-bookable Catch events. An app feed import remains a separate product/data migration decision, not a marketing-site side effect. |
| The website has repeated hand-rolled primitives. | Resolved | Shared primitives now cover buttons, links, fields, checkbox fields, form status, rails, chips, choice cards, metric cards, and auth rows; feature/site screens have no native form/action controls outside primitives. |
| Controller seams are missing for complex flows. | Resolved | Feature-owned controllers now cover organizer directory, claim flow, listing claims, listing reviews, host application, and waitlist submission. |
| Search and listing selectors need scalable selectors before inventory grows. | Resolved | Organizer filtering, URL state, cached search text, future-event lookup, profile strength, and summary counts live in selectors/controllers. |
| Marketing workflow path filters miss helper scripts used by deploy. | Resolved | `.github/workflows/marketing-website.yml` watches `tool/env/check_web_hosting_env.mjs`, `tool/firebase_with_env.sh`, and `tool/marketing/**`. |
| Generated listing drift is masked by build-time regeneration. | Resolved | CI runs `npm --workspace catch-marketing run check:organizer-listings` before the marketing build. |
| Above-fold media is heavy. | Resolved | The homepage/host hero use responsive JPEG variants under `website/public/assets/marketing/` instead of the original PNG. |
| Direct organizer analytics is not consent-gated. | Resolved | Organizer analytics suppresses session id creation, callable writes, and dataLayer mirrors until analytics consent is accepted; `docs/ads_conversion_spec.md` records the rule. |

The original findings are retained below for traceability. They describe the
June 23 audit baseline, not the current implementation unless reflected in the
remediation table above.

### Original Strengths

- The repo keeps marketing, admin, and Flutter web as separate deployable
  products. This remains the correct boundary.
- `packages/web-config/` already centralizes shared Vite, TypeScript, generated
  token CSS, font assets, and browser baseline styles for React web surfaces.
- `website/scripts/postbuild.mjs` writes route-specific HTML, canonical tags,
  robots metadata, `robots.txt`, and `sitemap.xml`.
- `website/scripts/checkOrganizerBuildOutputs.mjs` validates generated listing
  routes, legacy routes, robots metadata, and sitemap inclusion.
- The backend claim, public review, and organizer analytics callables validate
  generated contract schemas and enforce App Check through
  `functions/src/shared/callableOptions.ts`.
- The host application flow is already progressive-disclosure in UI behavior:
  one active step renders at a time, and submission waits until required steps
  are complete.

### Original P0 Findings

1. Legacy organizer routes can hydrate from `noindex` to `index`.

   `postbuild.mjs` writes legacy listing routes with `noindex, follow`, but the
   client resolves a legacy path back to the listing and reapplies
   `listing.indexing`. Current intake listings have canonical `index, follow`
   and legacy paths, so a crawler or previewer that runs JavaScript can observe
   the legacy page as indexable after hydration.

   Evidence:

   - `website/scripts/postbuild.mjs` writes legacy route metadata.
   - `website/src/App.tsx` resolves `listing.legacyPaths` in
     `getHostListingForPath`.
   - `website/src/App.tsx` builds hydrated listing metadata from
     `pageMetaForListing`.
   - `website/dist/organizers/indore/afterfly-run-club/index.html` is static
     `noindex, follow`, while `website/src/generated/hostListings.json` marks
     the canonical listing `index, follow`.

2. `/claim/` has client-side metadata but no generated static route.

   `pageMeta.claim` defines `noindex, follow`, but `postbuild.mjs` only writes
   `/`, `/host/`, `/organizers/`, listing routes, and legacy routes. Firebase
   falls unknown marketing paths through to root `index.html`, so `/claim/` can
   expose homepage metadata to crawlers, link unfurlers, or no-JS clients.

   Evidence:

   - `website/src/App.tsx` defines claim metadata.
   - `website/scripts/postbuild.mjs` omits `/claim/`.
   - `firebase.json` rewrites `**` to `/index.html`.
   - Fresh build output had no `website/dist/claim/index.html`.

3. Public source maps are deployed with full source content.

   Shared Vite config sets `sourcemap: true`, Firebase deploys `website/dist`,
   and the generated public JS references a `.js.map` file. The map contains
   source content for app code and dependencies. This is useful for debugging
   but should not be the default public production posture.

   Evidence:

   - `packages/web-config/vite-react.ts` enables sourcemaps.
   - `website/dist/assets/index-*.js` contains `sourceMappingURL`.
   - `website/dist/assets/index-*.js.map` is about 2.0 MB and includes
     `sourcesContent`.

### Original P1 Findings

4. The marketing app is not feature-first yet.

   `website/src/App.tsx` is 6,235 lines and owns routing, page composition,
   organizer/listing types, static content, filtering, form orchestration,
   metadata hooks, local storage helpers, analytics helpers, and URL helpers.
   `website/src/styles.css` is 5,155 lines and mixes global primitives,
   homepage, host page, organizer directory, claim, listing review, and host
   application styles.

   Target structure:

   ```text
   website/src/app/
   website/src/features/home/
   website/src/features/host/
   website/src/features/organizers/
   website/src/features/claims/
   website/src/features/reviews/
   website/src/features/waitlist/
   website/src/shared/ui/
   website/src/shared/lib/
   website/src/shared/firebase/
   website/src/shared/analytics/
   ```

5. Website types duplicate contract-owned backend schemas.

   `website/src/App.tsx` hand-defines `HostListing` and casts
   `hostListingsJson as HostListing[]`. `website/src/firebase.ts` hand-defines
   callable payload and response types that Functions already validate through
   generated contract validators. This creates a real drift risk between
   website, admin intake, Functions, and app consumers.

   Target: generate or expose shared TypeScript DTOs for website/admin clients,
   including public listing projections and callable request/response types.
   The website should consume generated types, not local copies.

6. Static generated website data can drift from Firestore API state.

   The website renders from `website/src/generated/hostListings.json`, but
   claim, review, and organizer analytics callables require backing Firestore
   club docs. Current organizer-intake sync preview shows 2 claim targets and
   2 writes needed. That means pages can be generated before the public APIs
   they call are backed by remote documents.

   Target: the generator or CI should fail public API-enabled listing output
   unless the corresponding Firestore claim target sync has been verified for
   the target environment, or the page renders an intentionally disabled API
   state.

7. Public review and organizer analytics scope checks are too broad.

   Public review writes are App Check/IP limited, but the server-side guard only
   checks that the club exists and is not archived. Organizer analytics validates
   club/event existence and event ownership, but does not verify canonical page
   path, publish status, or whether the page is public/indexable. This allows
   review or metric pollution against any non-archived club id if the caller has
   a valid App Check token.

   Target: public website callables should enforce public-page eligibility:
   publish status, claim/listing state, canonical path, and public review or
   analytics enablement.

8. Approved cleaned event data is not yet an app event feed.

   `external_events` are reviewed external evidence, not Catch-bookable events.
   Admin event-intake approval is still blocked from import by policy, and the
   website organizer-intake projection currently emits empty `eventEvidence`.
   Approved organizer records can feed the website today; app discoverability
   requires the Firestore claim-target sync and a separate app visibility gate.

   Target: keep "public event evidence" and "bookable Catch event" separate.
   If event intake should become consumable by the app, define an explicit
   import path into canonical `events`, with booking/payment/waitlist policy,
   host ownership, and provenance preserved.

### Original P2 Findings

9. The website has repeated hand-rolled primitives.

   `website/src/components/site.tsx` contains useful canonical website
   components, but `App.tsx` wraps some of them again and still hand-rolls step
   rails, fields, form status, choice chips, auth rows, cards, panels, and
   repeated button variants. The local `SiteHeader` adapter ignores caller
   props and always renders canonical nav/actions, which makes page-level header
   props misleading.

   Target shared primitives:

   - `Button`
   - `Field`
   - `SelectField`
   - `TextAreaField`
   - `FormStatus`
   - `StepRail`
   - `ChoiceChip`
   - `ChoiceCard`
   - `MetricCard`
   - `StatusBadge`
   - `SectionHeader`
   - `PageShell`
   - `AuthStatusRow`

10. Controller seams are missing for complex flows.

    No external state manager is needed at this point. The right next step is
    feature-owned hooks/controllers, matching the admin direction:

    - `useOrganizerDirectoryController`
    - `useClaimFlowController`
    - `useListingClaimController`
    - `useListingReviewsController`
    - `useHostApplicationController`
    - `useWaitlistFormController`
    - `organizerAnalyticsService`
    - `savedOrganizerStorage`

    These should own URL parsing, validation decisions, mutation orchestration,
    analytics side effects, and local persistence. UI components should render
    controller state and dispatch explicit actions.

11. Search and listing selectors are fine at 3 listings but need scalable
    selectors before the directory grows.

    Organizer search recomputes search text per listing during filtering,
    counts iterate `hostListings` multiple times, review sections repeatedly
    filter/reduce/map reviews during render, and `nextFutureCatchEvent` sorts
    to find one earliest event. These are not current performance incidents, but
    they will become visible as approved organizer inventory grows.

12. Marketing workflow path filters miss helper scripts used by deploy.

    `.github/workflows/marketing-website.yml` executes
    `tool/env/check_web_hosting_env.mjs` and `tool/firebase_with_env.sh`, but
    those paths are not listed as workflow triggers. Changes to deploy helpers
    may not run the marketing workflow.

13. Generated listing drift is masked by build-time regeneration.

    `pretypecheck` runs `generate:organizer-listings`, so stale checked-in
    `hostListings.json` can be silently corrected during build. CI should also
    run `node website/scripts/generateOrganizerListings.mjs --check` before any
    mutating generation step, or move the generated listing file out of
    checked-in source.

14. Above-fold media is heavy.

    The home hero uses `website/public/assets/marketing/catch-hero-event.png`,
    currently about 1.7 MB in source and about 2.1 MB in the built output. The
    page should use responsive image variants, modern formats, explicit
    dimensions, and a deliberate preload/fetch priority strategy.

15. Direct organizer analytics is not consent-gated.

    The GTM layer waits for consent, but host-visible organizer analytics calls
    can create a local session id and call the Firebase analytics callable
    independent of the consent banner. Decide whether this is essential
    first-party operational telemetry or marketing analytics; then encode that
    rule in `docs/ads_conversion_spec.md`, client code, and server retention.

### Original Refactor Order

1. Fix production delivery hardening first:
   legacy route hydration metadata, `/claim/` static HTML, source-map posture,
   marketing workflow path filters, and generated listing drift checks.

2. Add contract-backed website DTOs:
   public listing projection type, callable payload/response types, and a
   generator check that validates `hostListings.json` against the DTO/schema.

3. Extract feature-first folders without changing behavior:
   app routing/meta shell, organizer data/routing/search, listing page,
   claims, reviews, host application, waitlist, and shared UI primitives.

4. Add controllers/hooks:
   move URL parsing, validation, mutation orchestration, analytics, and local
   persistence out of page components.

5. Harden public callables:
   enforce public-page publish/canonical eligibility for reviews and analytics,
   and decide the exact app visibility boundary for approved intake records.

6. Optimize public performance:
   responsive hero assets, conditional Firebase loading, precomputed search
   index, selector memoization, and source-map/dependency splitting decisions.

### Consolidation Decision

Do not merge `website/` and `admin/` into one React runtime. Keep them as
separate deployable apps because the website is public, SEO-sensitive,
anonymous/lead-oriented, and cacheable, while admin is private, role-gated,
dense, and privileged.

Do consolidate shared layers:

- generated contracts and DTOs;
- design tokens and web config;
- neutral React primitives in a future `packages/web-ui`;
- safe callable client helpers;
- media/token/build validators.

## Website Component And Organizer Functionality

The completed website mockup functionality tracker is folded into this
architecture doc. The production website should use Catch tokens, canonical
React website components, generated public projections, and existing Firebase
callable boundaries. Prototype-only globals, fabricated organizer data, hash
routing, and image-slot editing utilities must not be imported.

Current canonical component layer under `website/src/components/` includes:

- site shell: `SiteHeader`, `SiteFooter`;
- shared display primitives: `ActivityMark`, `StatusBadge`, `ProfileStrength`,
  `CaptureCard`, `SectionHeader`;
- public discovery primitives: `PublicSearchBar`, `PublicEventCard`;
- host/product blocks and listing/claim/review primitives owned by the website
  feature folders.

Implemented website behavior:

- Homepage discovery can render real event/search data from generated organizer
  projections.
- Directory filters are URL-backed for query, city, format, status, upcoming,
  rating, and sort.
- Organizer listing pages support event-aware search results, claim pressure,
  verified/public review grouping, owner response pressure, Catch-created event
  CTAs/deep links, and share behavior.
- Claim surfaces show pending, already-claimed, not-found, and "while you wait"
  states.
- `/host/` uses reusable host product blocks for paid checkout, waitlist
  offers, balanced cohorts, active-step create-event walkthrough, and
  Event Success copy aligned with product/privacy constraints.

Deferred website decisions:

- Decide whether fabricated prototype organizers become real seed listings,
  demo-only fixtures, or stay excluded.
- Decide whether the public website should call a live public event projection
  callable or keep public events inside generated static JSON.
- Add an Instagram DM code-verification backend path before promising that as
  an automated claim option.
- Add new marketing capture slots only through
  `tool/marketing/capture_manifest.json` and the existing sync/export pipeline.
- Replace proxy host-create step captures with exact create-event step
  screenshots once the UI capture catalog has those fixtures.

## Future Host Dashboard

A future host dashboard still fits this architecture. Prefer:

| Domain | Surface | Stack | Permission model |
|---|---|---|---|
| `hosts.catchdates.com` | Authenticated host portal for club/event management, scoped analytics, payout readiness, and event operations | React + TypeScript | Server-side Functions authorize host ownership per club/event |

Do not put host tools under `admin.catchdates.com`. Hosts are external operators,
not internal admins. Keep `/host/` on `catchdates.com` as the public host
marketing/acquisition page, and use `hosts.catchdates.com` only for authenticated
host workflows once that product exists.

Host portal APIs should follow the same server-owned pattern as admin APIs:

- the browser client never receives service-account credentials;
- Functions validate Firebase Auth and host ownership;
- mutations write audit or activity records where operationally useful;
- analytics responses are scoped to clubs/events the signed-in host can manage.

## Why Subdomains Instead Of Paths

Subdomains keep each surface independently deployable and reduce routing
conflicts:

- Flutter web can own `app.catchdates.com/**` without sharing a catch-all with
  the marketing site.
- Marketing can own SEO pages, `/host/`, `.well-known/`, and public Functions
  rewrites.
- Admin can use separate security headers, App Check settings, auth behavior,
  and release cadence.
- A future host portal can be added without overloading either the consumer app
  or the internal admin console.
