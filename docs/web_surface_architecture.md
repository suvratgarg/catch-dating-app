---
doc_id: web_surface_architecture
version: 0.7.150
updated: 2026-07-14
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
- `packages/web-ui/` is the pure presentational React workspace. It has no
  Firebase, router, query, or feature dependencies; both apps consume its
  structural controls through surface-owned adapters so class names and visual
  variants remain local.
- `docs/audit_registry/web_shared_primitive_adoption.json` is the active
  cross-surface compatibility and improvement queue. The non-vacuous
  `web:shared-ui-adoption` gate classifies every exact-name primitive overlap,
  every package export, the shared focus contract, and package CI coverage.
- The adopted package layer now owns compatible native behavior for buttons,
  checkboxes, text/select/textarea controls, labelled toggle groups, badges,
  empty states, and named keyboard-scrollable data tables. Website/admin
  adapters still own density, visual classes, domain tones, option mapping, and
  feature composition. `ToggleGroupControl`/`ToggleButtonControl` remain the
  reference implementation for this split.
- Cross-stack labels deliberately separate hierarchy from status:
  `catch.ui_label` binds `CatchSectionLabel`, website `UiLabel`, admin
  `AdminEyebrow`, and web-ui `UiLabel`; `catch.badge` binds status adapters and
  `BadgeControl`. The lexicon test rejects future semantic collapse.
- `website/` is a Vite + React + TypeScript marketing app.
- `website/src/app/App.tsx` uses React Router for the client route shell and
  `website/src/app/routeRegistry.ts` for runtime route patterns; the route
  contract and postbuild output remain the public SEO source of truth.
- `website/src/content/meta.json` is the validated static metadata source read
  by both `website/src/app/pageMeta.ts` and `website/scripts/postbuild.mjs`.
- `website/src/shared/ui/**`, `website/src/shared/site/**`, and
  `admin/src/shared/ui/**` are the React shared primitive owners. Feature,
  app, and story code must compose these primitives rather than hand-rolling
  native interactive controls.
- `design/web-ui/components.json` registers extracted package primitives and
  binds them back to `design/components/catch.components.json`. Imports use
  `@catch/web-ui`; deep package imports are blocked by both app boundary gates.
- `tool/web/check_react_ui_primitives.mjs` enforces the first React primitive
  guard for `website/`, `admin/`, and `webui`.
- `tool/web/check_storybook_visuals.mjs` resolves registry entries marked
  `ready` against built Storybook indexes and compares fixed desktop/mobile
  captures under `design/visual_baselines/<surface>/<platform>/`. Repeatable
  `--component <registry-id>` filters isolate task-owned checks and baseline
  updates while another surface refactor is dirty. Platform ownership is part
  of the contract because `system-ui` is intentionally stack-native: Darwin
  and Linux captures never compare against one another. React CI pins the
  blocking Linux capture to Ubuntu 24.04 and uploads actual plus diff images on
  failure; manual baseline-capture runs upload review artifacts before commit.
- `web:admin-bundle-budget` reads the built Vite manifest and ratchets both the
  admin entry chunk and largest async chunk. Query/API controllers belong
  behind lazy route wrappers; importing one into `admin/src/app/App.tsx` is a
  performance-boundary regression even when its view remains lazy.
- `tool/web/react_controller_test_targets.json` classifies every feature
  controller/mutation hook as `required`, `planned`, or an explained `exempt`.
  `web:react-controller-test-targets` rejects unclassified hooks and required
  targets whose named behavior suite is missing, while aggregate coverage stays
  informational rather than becoming a brittle percentage gate.
- Admin Storybook uses named feature chunks plus a separate generated-intake
  data chunk. `web:admin-storybook-bundle-budget` ratchets Catch-authored chunks
  independently of Storybook, axe, and other framework/vendor runtime; route
  coverage remains registry-complete rather than being removed to hit a budget.
- Admin feature route/workspace entries stay below 900 lines and feature-private
  panel modules below 1,200 lines through `web:admin-feature-ui-size`. Large
  workflows use lower-case module APIs so route/workspace exports remain the
  only public feature component boundary enforced by `web:admin-feature-exports`.
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

## React Surface Governance

Treat the marketing website and admin console as sibling React products, not as
isolated one-off apps. Cross-surface React architecture work should route
through `docs/agent_skills/catch-react-surface-refactor.md`.

- Use React Router for URL routing and URL-owned state. Route shells should own
  routing, path/search-param extraction, guards, metadata, lifecycle, and
  providers; feature pages should own composition; controllers may consume
  explicit route-state objects, but should not parse `window.location` or call
  router hooks directly.
- Use TanStack Query for true remote reads and mutations. Generated/static data
  stays as typed imports until there is a real remote boundary.
- Keep shared UI primitives centralized. Feature, app, and Storybook code must
  not render raw `<button>`, `<a>`, `<input>`, `<select>`, or `<textarea>`
  controls. Add missing neutral controls to the owning shared primitive module
  instead of styling them per screen.
- Shared keyboard focus behavior starts in
  `packages/web-config/styles/catch-web.css`. Surface CSS may style a composite
  wrapper with `:focus-within`, but it must not remove a native outline without
  an equally visible token-backed replacement.
- Keep governed component families centralized. Feature, app, and Storybook code
  must not pass `className` directly outside shared primitive owner files. Run
  `node tool/run.mjs check web:react-classname-boundaries` before handoff. The
  scanner-owned family registry is `tool/web/check_react_component_governance.mjs`;
  the generated reader snapshot is
  `docs/audit_registry/react_component_governance_families.json`. Run
  `node tool/run.mjs check web:react-component-governance` before handoff. This
  scanner is a known-family blocklist, so reviewers must add new repeated shell
  families to the scanner when drift repeats instead of relying on prose.
  Marketing website feature components exported from `website/src/features/**/*.tsx`
  must also be declared in `design/website/components.json` or made private; run
  `node tool/run.mjs check marketing:website-components` when touching website
  route, section, flow, or supporting-component exports.
  Admin feature UI may export route/workspace entry components, but reusable
  panels, cards, lists, badges, and sections must live in `admin/src/shared/ui`
  or stay private. Run `node tool/run.mjs check web:admin-feature-exports`
  when touching admin feature UI exports. Admin route/workspace entries, shared
  admin primitives, and admin feedback providers must also be declared in
  `design/admin/components.json`; run
  `node tool/run.mjs check web:admin-components` when touching those exports.
  Admin registry entries marked `preview.status: "ready"` must point at
  Storybook exports under `admin/src/stories`; run
  `node tool/run.mjs check web:admin-storybook` whenever admin preview coverage
  changes.
  Cross-surface extractions and explicit keep decisions are checked separately
  by `node tool/run.mjs check web:shared-ui-adoption`; adding a new shared
  package export or same-named website/admin primitive without a tracker entry
  fails that gate. Marking a candidate adopted also requires both surface
  adapters to import and use a classified package symbol.

## Admin Console Route and Information Architecture

The admin shell has one product identity, `Catch Admin`, and one plain route
title in the global top bar. Prototype labels such as `sample console`, route
kickers, and decorative subtitles are not production chrome. The production
environment badge is omitted; Development, Local, or Staging is shown only when
the non-production context changes operator risk. Account identity, roles,
local-data context, and sign-out live in the account disclosure.

Operational directories and record review use URL-owned master-detail routes.
Canonical list/workspace roots are `/overview`, `/safety`, `/access`, `/growth`,
`/organizers`, `/organizers/claims`, `/events`, `/events/readiness`,
`/events/external`, `/users`, `/finance`, `/quality`, and `/admin-roles`.

Intake owns `/intake/organizers`, `/intake/events`, and `/intake/operations`.
Marketing owns `/marketing` (default Posts), `/marketing/posts`,
`/marketing/new`, `/marketing/events`, `/marketing/media`,
`/marketing/activity`, and `/marketing/diagnostics`; draft composition uses
`/marketing/drafts/{draftId}/{source|copy|compliance|export}`.

URL-owned detail families are `/safety/{targetPath}`, `/access/{uid}`,
`/organizers/{clubId}`, `/organizers/claims/{requestId}`, `/events/{eventId}`,
`/events/readiness/{actionId}`, `/events/external/{candidateId}`,
`/growth/signals/{signalId}`, `/finance/issues/{issueId}`,
`/quality/signals/{signalId}`, and `/admin-roles/{uid}`. A missing direct record
stays unavailable; controllers must never auto-select another row to make a
deep link appear valid.

Route shells own path and search-param parsing. Feature controllers accept
explicit selected ids and navigation callbacks, while repositories keep remote
sources independent where partial results are useful. Overview, Growth,
Finance, and Data quality therefore retain successful source data when another
query fails and expose retry at the smallest truthful source boundary.

Loaded lists must disclose their scope. A returned preview, local search result,
or 50-row assignment register is not a complete directory. Dates and ranges
apply only to endpoints that accept them. Evidence labels distinguish sourced,
inferred, unknown, generated-at, loaded-at, and session-only state. Diagnostics,
command material, unsupported actions, and source paths use secondary disclosure
instead of occupying the primary task flow.

Mutation interfaces may reuse the shared sticky decision footer only when the
owning callable has validation, authorization, pending, success, and receipt
behavior. The UI must not imply direct social publishing, money movement,
canonical intake promotion, rollback, scheduler execution history, or broad
member/Auth search without dedicated contracts.

## Admin Intake Operations Projection

`/intake/operations` is the third Intake workspace, labelled Automation. It is
a read-only projection of canonical `operationRuns` and `operationWorkItems`;
it does not derive execution state from the older Event or Organizer Intake tab
filters. The UI displays the same exclusive Incoming, Verify, Resolve, and
Ready stage values persisted by the operations worker, with task flags and
blockers rendered as overlapping review concerns.

The feature follows the standard repository/controller/workspace split under
`admin/src/features/intake/operations/`. Live data crosses only
`adminListIntakeOperations`; sample mode uses a contract-shaped fixture. The
browser offers refresh, search, stage/entity filters, and hash-bound evidence
inspection, but intentionally exposes no Run, model, deploy-rule, or Publish
action. Those capabilities require separate trusted-worker and policy
boundaries rather than a browser toggle.

The callable orders runs by persisted `updatedAt` plus document id and reads
whole-run stage, work-item, and human-review aggregates from the imported run
metadata and fails closed when they are absent or inconsistent. The controller
pins that run, loads one ordinary page, and drains only the server-filtered
human-exception cursor before rendering. Every counted active exception can be
opened immediately; ordinary items advance through **Load 200 more**, preserve
already-loaded exceptions, and cannot overwrite a newer refresh. Published and
terminal history is excluded from the active stage rail. Run pagination is
separate: `loadedRunCount`, `nextRunCursor`, `nextWorkItemCursor`, and the
workspace copy describe loaded pages rather than a false persisted total. The
query disables automatic retry so the 10,000-item/200-page/120-per-minute
capacity contract remains bounded. The separate apply-guarded importer is a
trusted operator, not a browser route or callable.

An exception is resolved in the owning Event or Organizer Intake surface. The
Automation workspace does not write an `OperationDecision` or resume the same
run; a later Supply Intake run can see that decision only after the owning
compatibility artifact is regenerated. Reconciliation creates a separate
immutable child run for expiry and stale-evidence changes rather than editing an
already imported run.

## Admin Callable Validation Boundary

`admin/src/shared/api/adminApi.ts` owns the single live Firebase callable
boundary for the admin React surface. Its local `httpsCallable` wrapper always
validates request payloads before network invocation and validates response
payloads in development or when `VITE_ADMIN_VALIDATE_RESPONSES=true`.

`admin/scripts/generateCallableValidators.mjs` discovers every callable name in
that API module, compiles the applicable `contracts/callables/**` and
`contracts/callable_responses/**` schemas plus their references, and writes the
committed typed registry under `admin/src/generated/validators/`. Callables
without a dedicated JSON contract receive an explicit top-level object
validator and remain listed separately from strict schema coverage; they must
not disappear from the registry or be described as strictly validated.

Run `node tool/run.mjs check web:admin-callable-validators`. Admin
`pretypecheck` runs the same drift check, so a callable or schema change cannot
ship with stale validators. Validation failures use
`AdminCallableValidationError` and include callable name, direction, and the
first failing JSON instance path.

## Marketing Route Contract

Public website route ownership starts in `design/website/routes.json`. The
contract records each route family, page key, source component, metadata key or
factory, static-output behavior, robots/indexing intent, sitemap inclusion, and
the review states that need visual coverage.

Run the route gate before component-first or visual-review work:

```sh
node tool/run.mjs check marketing:website-routes
```

The checker compares the route contract with `website/src/app/App.tsx`,
`website/src/app/routeRegistry.ts`, `website/src/content/meta.json`,
`website/src/app/pageMeta.ts`, `website/scripts/postbuild.mjs`, generated
organizer listings, and source component paths. It also validates the metadata
content contract and is wired into
`npm --workspace catch-marketing run typecheck` and the marketing GitHub
workflow so public-route changes cannot ship as prose-only decisions.

Component-first review is the next layer, not a replacement for route review.
When the website gets a Storybook/Widgetbook-equivalent workbench, its stories
should attach state coverage to the route ids in `design/website/routes.json`
instead of creating a separate website inventory.

## Firebase Hosting Setup

`firebase.json` declares three Hosting targets:

- `marketing`: builds `website/` and deploys `website/dist`.
- `app`: deploys `build/web` for the Flutter web app.
- `admin`: builds `admin/` and deploys `admin/dist` with `X-Robots-Tag:
  noindex, nofollow`.

The production `.firebaserc` binds each target to a distinct checked Hosting
site:

- `marketing` -> `catch-dating-app-64e51`
- `app` -> `catchdates-app`
- `admin` -> `catchdates-admin`

The admin build is deployed at `https://catchdates-admin.web.app`. On
2026-07-12, Cloudflare began serving the Firebase-required DNS-only CNAME for
`admin.catchdates.com` plus its ACME TXT proof. Firebase Hosting detected the
records and began ownership/certificate reconciliation. Do not call the custom
domain live until Firebase reports active ownership and certificate state and a
normal HTTPS request succeeds.

Custom-domain ownership remains:

- `catchdates.com` and `www.catchdates.com` to the marketing site.
- `app.catchdates.com` to the app site.
- `admin.catchdates.com` to the admin site.

## Marketing CI/CD

`.github/workflows/marketing-website.yml` is the marketing site's scoped
pipeline:

- pull requests validate generated web tokens, app-derived screenshot assets,
  marketing screenshot design context, the Vite production build, and all
  Storybook stories through a Playwright Chromium axe gate;
- pushes to `main` that touch marketing-site inputs deploy only
  `hosting:marketing` to the production Firebase project;
- generated public routes are served as static files; only explicit host,
  claim, and API rewrites remain, so unknown paths use `dist/404.html` with an
  actual HTTP 404 instead of the root SPA shell;
- the deploy job probes a unique unknown `catchdates.com` URL and fails unless
  the response status is 404;
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

   This finding is being closed through the React component-governance loop. The
   legacy `website/src/components/site.tsx` barrel has been retired: neutral site
   chrome belongs in `website/src/shared/site/**`, governed visual primitives
   belong in `website/src/shared/ui/primitives/`, and organizer/claim/host
   domain adapters belong in their feature folders. The component-governance
   scanner now blocks recreating or importing the retired barrel.

   Shared primitive families now include:

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
   - `WebsitePageMain`
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
- shared display primitives: `StatusBadge`, `SectionHeader`;
- shared identity display primitives: `ActivityMark` and `ProfileStrength`
  under `website/src/shared/ui/primitives/`;
- shared process status panel primitive: `ProcessStatusPanel` under
  `website/src/shared/ui/primitives/`;
- shared app-capture primitive: `CaptureCard` under
  `website/src/shared/ui/primitives/`;
- public discovery primitives: `PublicSearchBar`, `PublicEventCard`;
- host/product blocks including `ProductModuleGrid`, listing event blocks
  including `EventActionCard`, and listing/claim/review
  primitives owned by the website
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
