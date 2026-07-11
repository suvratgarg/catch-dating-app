---
doc_id: marketing_website_architecture
version: 0.4.145
updated: 2026-07-11
owner: marketing_website
status: active
---

# Marketing Website Architecture

This document owns the code organization and refactor target for the public
React marketing website in `website/`. Use `docs/web_surface_architecture.md`
for domains, deploy targets, CI/CD, and cross-surface hosting boundaries. Use
`design/website/routes.json` for the route-first contract and
`design/website/components.json` for the component-first registry.

## Current State

The website is already split out of the old monolithic shell:

- `website/src/App.tsx` is a compatibility re-export for the app entrypoint.
- `website/src/app/App.tsx` owns the React Router shell, metadata selection,
  page-level lifecycle hooks, and route-level lazy loading.
- `website/src/app/routeRegistry.ts` owns runtime route patterns.
- `website/src/app/pageMeta.ts` owns client-side page metadata.
- `website/scripts/postbuild.mjs` emits route-specific static HTML after Vite.
  Generated organizer routes include semantic profile content, Organization and
  breadcrumb JSON-LD, canonical/robots metadata, and `lastVerifiedAt` sitemap
  dates before React executes. `checkOrganizerBuildOutputs.mjs` fails builds
  that regress those crawlable outputs.
- `design/website/routes.json` records the public route contract, review
  states, and Storybook/manual state coverage.
- `design/website/components.json` records route and section ownership, CSS
  ownership, and Storybook coverage status. It is validated bidirectionally
  against referenced Storybook `parameters.catchComponent` declarations by
  `tool/marketing/check_website_components.mjs`.
- `tool/marketing/check_website_routes.mjs` validates route URL, metadata,
  static output, generated listing coverage, and referenced Storybook
  `parameters.catchRoute` declarations.
- `tool/web/check_react_ui_primitives.mjs` prevents feature/app/story code from
  hand-rolling native interactive controls outside shared primitive owners.
- `tool/web/check_react_component_governance.mjs` prevents React app/feature
  code from hand-rolling governed component families. Its generated reader
  snapshot lives at `docs/audit_registry/react_component_governance_families.json`
  and documents the known-family blocklist limitation.
- Shared route/page shell presentation lives in `website/src/shared/site` as
  `PageShell` and `WebsitePageMain`. `website/src/app/App.tsx` owns React
  Router, route metadata, lifecycle hooks, and page-class selection, but
  configures `PageShell` instead of rendering raw `page-shell` markup. Ordinary
  route files use `WebsitePageMain`; routes with their own visual shell keep
  using shared route-specific mains such as `ClaimFlowMain` and
  `HostPreviewMain`. Raw `page-shell` wrappers and raw `<main>` tags are
  blocked by `web:react-component-governance`.
- `website/src/features/host/HostPage.tsx` and
  `website/src/features/host/HostPreviewPage.tsx` own separate host route
  assembly. Shared and route-specific host sections live under
  `website/src/features/host/sections/**`; the Host route section set lives in
  `website/src/features/host/sections/HostPageSections.tsx`, and the Host
  Preview route-specific section set lives in
  `website/src/features/host/sections/HostPreviewSections.tsx`.
  Host application form state lives under `website/src/features/host/application/**`.
- Shared Host Preview route shells live in
  `website/src/shared/ui/primitives.tsx` as `HostPreviewMain`,
  `HostPreviewHero*`, `HostPreviewOfferShell`, `HostPreviewSection`,
  `HostPreviewApplyShell`, `HostPreviewHeroStores`,
  `HostPreviewFormatRail`, `HostPreviewChipRow`, and the existing
  `HostPreview*` product modules. Host Preview sections configure those
  primitives; they do not render raw route, hero, offer, section, modifier,
  apply, store-slot, format-rail, or chip-row shells directly.
- Shared Host Page route shells live in
  `website/src/shared/ui/primitives.tsx` as `HostHero*` and
  `HostPageSection`; `CaptureGrid` owns the host capture-grid modifier.
  Host sections configure those primitives; they do not render raw host hero,
  evidence, surface, fill-room, proof-ledger, or capture-grid modifier shells
  directly.
- Shared Host Application flow shells live in
  `website/src/shared/ui/primitives.tsx` as `HostApplication*` and
  `OperationalNote`. `HostApplicationFlow.tsx` owns the form state and field
  choices, but configures shared flow shells instead of rendering raw
  `host-application*`, `submitted-panel__mark`, or `operational-note` markup.
- Shared Host feature section shells live in
  `website/src/shared/ui/primitives.tsx` as `HostFeatureSection`,
  `HostFeatureGrid`, `HostFeatureRail`, `HostCreateFlowCapture`,
  `HostComparisonTable*`, `PrivacyGuardrail`, and `PhoneCaptureShell`.
  `CreateEventWalkthrough`, `EventSuccessShowcase`, `HostComparisonSection`,
  and `CaptureFrames` own state, content, and capture selection, but configure
  shared section shells instead of rendering raw `host-create-flow*`,
  `event-success-*`, `host-comparison*`, `comparison-table*`,
  `privacy-guardrail`, or `phone-capture*` markup.
- Shared app capture card shells live in
  `website/src/shared/ui/primitives.tsx` as `CaptureCard`.
  Home and Host sections pass capture manifests and fallback labels to that
  primitive instead of rendering raw `capture-card` figure shells.
- Shared product module grid shells live in
  `website/src/shared/ui/primitives.tsx` as `ProductModuleGrid`. Host fill-room
  sections pass module content into that primitive instead of rendering raw
  `product-module-grid` or `product-module-card` shells.
- Shared listing event action cards live in
  `website/src/shared/ui/primitives.tsx` as `EventActionCard`. Organizer
  listing event sections own the event-card content and analytics callback, but
  configure the shared card instead of rendering raw `event-action-card` shells.
- Shared identity display shells live in
  `website/src/shared/ui/primitives.tsx` as `ActivityMark` and
  `ProfileStrength`. Organizer adapters compute listing activity/status data,
  but route visual marks and strength meters through shared UI instead of
  rendering raw `activity-mark` or `profile-strength` shells.
- Shared process status panels live in
  `website/src/shared/ui/primitives.tsx` as `ProcessStatusPanel`. Claim route
  sections own state-specific copy and CTA analytics callbacks, but configure
  the shared panel instead of rendering raw `process-status-panel` shells.
- Shared Event Success grids are configured through
  `EventSuccessModuleGrid` and `ListingSuccessMetricGrid`.
  `SuccessGrid` is an internal implementation detail; feature sections pass
  module or metric arrays instead of composing `SuccessGrid` children directly.
- `website/src/features/host/HostPages.tsx` is a compatibility re-export only.
- `website/src/features/home/HomePage.tsx` is now a thin home route shell.
  Visible Home route sections live in
  `website/src/features/home/sections/HomePageSections.tsx`, with route and
  section Storybook coverage registered in `design/website/components.json`.
- Shared Home and marketing section shells live in
  `website/src/shared/ui/primitives.tsx` as `HomeHero*`,
  `MarketingSection`, `MarketingSectionCopy`, `MarketingFormatCard`,
  `MarketingInfoCardGrid`, `HostComparisonSummaryCards`, `MarketingLoopList`,
  `FeaturedOrganizerCardGrid`, and `LiveMeter`. Feature sections configure
  those primitives with item arrays and route-specific copy; they do not render
  the raw marketing section, loop-list, or reveal-article info-card shells
  directly.
- Shared marketing consent banner presentation lives in
  `website/src/shared/ui/primitives.tsx` as `MarketingConsentBannerShell`.
  `website/src/features/marketing/MarketingConsentBanner.tsx` owns consent
  state and analytics choices, but configures the shared shell instead of
  rendering raw `consent-banner` markup.
- Featured organizer cards use `FeaturedOrganizerCardGrid`; Home featured
  organizers and listing recommendations provide card item config through
  `featuredOrganizerCardItemForListing` rather than rendering feature-owned
  mini-card shells.
- Shared app-download CTA presentation lives in
  `website/src/shared/ui/primitives.tsx` as `AppDownloadCtaGroup`, with
  `AppDownloadCtas*` and `StoreButton*` kept as shared implementation helpers.
  `website/src/features/marketing/useAppDownloadCtas.ts` owns store-link
  analytics configuration only. Route sections pass placement, variant, and
  optional initial status into `AppDownloadCtaGroup`; they must not recreate the
  deleted `AppDownloadCtas.tsx` feature component or render raw
  `app-download-ctas` / `store-button` structure directly.
- Shared waitlist form presentation lives in
  `website/src/shared/ui/primitives.tsx` as `WaitlistFormShell`.
  `website/src/features/waitlist/WaitlistForm.tsx` owns controller-driven form
  state, field choices, and submission behavior, but configures the shared form
  shell instead of passing raw `waitlist-form` classes through a generic
  primitive.
- Shared UI label shells live in `website/src/shared/ui/primitives.tsx` as
  `UiLabel`, with the base `.ui-label` style owned by `site-shell.css`.
  Route sections and legacy website display components configure `UiLabel`
  instead of rendering raw uppercase label spans directly.
- `website/src/features/organizers/OrganizerSearchPage.tsx` now composes
  organizer-owned search sections from
  `website/src/features/organizers/sections/OrganizerSearchSections.tsx`; the
  controller remains the URL/search-param state owner.
- `website/src/features/organizers/HostListingPage.tsx` now uses
  `website/src/features/organizers/useHostListingPageController.ts` for
  listing-derived nav, claim CTA, save/share state, local persistence, and
  listing analytics, and
  `website/src/features/organizers/sections/HostListingSections.tsx` for the
  ordered route-section assembly. The visible listing sections retain their own
  Storybook/component-registry entries.
- Shared organizer listing shells live in
  `website/src/shared/ui/primitives.tsx` as `ListingSection`,
  `ListingSectionIntro`, `ListingFactGrid`, `ListingNoteGrid`,
  `ListingFormatRow`, `ListingDiagnostics*`, `ListingEventDownloadPanel`,
  `ListingEventEvidenceList`, `ListingReview*`, and `ListingSourceLedger`.
  Organizer sections configure those primitives; they do not render raw
  `listing-*` structural shells or revealed intro wrappers directly.
- `ListingFactsSection.tsx` and `ListingFitSection.tsx` own listing copy and
  section conditions, but configure `ListingFactGrid` and `ListingNoteGrid`
  instead of composing listing grid/card shells directly.
- `ListingEventsSections.tsx` owns event data selection, app-download placement,
  and outbound analytics behavior, but configures `ListingEventDownloadPanel`
  and `ListingEventEvidenceList` instead of composing event download/card/meta
  shells directly.
- `ListingSourcesSection.tsx` owns source data and analytics event selection,
  but configures `ListingSourceLedger` instead of composing ledger rows or
  `source-link` anchors directly.
- Shared organizer listing hero shells live in
  `website/src/shared/ui/primitives.tsx` as `ListingHeroShell`,
  `ListingHeroInner`, `ListingHeroCopy`, `ListingHeroEyebrow`,
  `ListingHeroMetrics`, and `ListingHeroShareStatus`. `ListingHeroSection`
  owns listing data, CTAs, analytics, and diagnostics, but configures shared
  hero shells instead of rendering raw `listing-hero*`, `listing-panel__metrics`,
  or `listing-share-status` markup.
- Shared organizer listing review shells live in
  `website/src/shared/ui/primitives.tsx` as `ListingReviewSummary`,
  `ListingReviewWorkspace`, `ListingReviewLanes`, `ReviewSignalLane`,
  `ReviewSignalCard`, `OwnerResponsePrompt`, `ListingReviewEmptyState`,
  `ListingReviewForm`, and `ListingReviewCheckbox`. `ListingReviewsSection`
  owns review controller state, copy, submission behavior, and analytics
  callbacks, but configures shared review shells instead of rendering raw
  `review-signal-*`, `owner-response-prompt`, `listing-owner-response`, or
  `listing-review-*` form/state markup.
- Shared organizer listing claim shells live in
  `website/src/shared/ui/primitives.tsx` as `ClaimMissingEvidenceList` and
  `ClaimRequestForm`, alongside the existing `ClaimBand*` and
  `ClaimRequestPanel*` primitives. `ListingClaimSections.tsx` owns claim
  controller state, auth actions, copy, and analytics, but configures shared
  claim list/form shells instead of rendering raw `missing-list` or
  `claim-request-form` markup.
- Shared organizer search result shells live in
  `website/src/shared/ui/primitives.tsx` as `OrganizerResultCard*` and
  `OrganizerEventHighlights`. Organizer search sections configure those
  primitives; they do not render raw result-card, topline, highlight, or footer
  shells directly.
- Shared organizer search section shells live in
  `website/src/shared/ui/primitives.tsx` as `OrganizerSearchSection`,
  `OrganizerSearchStats`, `OrganizerResultSummary`, and
  `DirectoryClaimPressure*`. Organizer search sections own controller-driven
  filters, result mapping, and claim links, but configure shared section shells
  instead of rendering raw `organizer-search-*`, `organizer-result-summary`,
  `directory-claim-pressure*`, or `organizer-results` markup.
- Shared claim-flow route shells live in
  `website/src/shared/ui/primitives.tsx` as `ClaimFlowMain`,
  `ClaimFlowHero`, `ClaimFlowWorkspace`, `ClaimFlowPanel`,
  `ClaimFlowStage`, `ClaimListingResults`, `ClaimResultButton`,
  `SelectedListingCard`, `VerificationMethodGrid`, `OwnerUnlockBoard`, and
  `AuthStatusRow` variants.
  `ClaimPage.tsx` owns site chrome and route-level branching, while
  `ClaimPageSections.tsx` configures those primitives instead of rendering raw
  `claim-flow`, `claim-flow__*`, or `claim-auth-row*` shells directly.
- `website/src/features/claims/ClaimPage.tsx` now keeps route shell and
  controller selection only. Claim URL parsing lives in
  `website/src/features/claims/claimRouting.ts` and is injected from the React
  Router shell in `website/src/app/App.tsx`; the claim controller must not read
  `window.location` or import organizer routing helpers. Claim hero,
  URL-state panels, and form workspace rendering live in
  `website/src/features/claims/sections/ClaimPageSections.tsx`, with route and
  section Storybook coverage registered in `design/website/components.json`.
- `website/src/shared/site/**` owns neutral site shell/display primitives:
  `SiteHeader`, `SiteFooter`, and `SectionHeader`.
- The legacy `website/src/components/site.tsx` barrel is retired. New website
  code must import neutral site primitives from `website/src/shared/site/**`,
  governed visual primitives from `website/src/shared/ui/primitives.tsx`, and
  domain adapters from their owning feature folder.
- `website/.storybook/**`, `website/src/stories/MarketingRoutes.stories.tsx`,
  `website/src/stories/HomeSections.stories.tsx`,
  `website/src/stories/HostSections.stories.tsx`, and
  `website/src/stories/ClaimSections.stories.tsx`,
  `website/src/stories/OrganizerSearchSections.stories.tsx`, and
  `website/src/stories/OrganizerListingSections.stories.tsx` provide the first
  component-first workbench for route-linked and section-linked review.
- Website CSS is split from the former `shared-core.css` aggregate into
  ordered ownership files under `website/src/styles/**`. `responsive.css`
  remains a mixed responsive layer until the next finer-grained CSS pass.
- TanStack Query is installed in both React apps. `website/src/shared/query/**`
  and `admin/src/shared/query/**` own query providers and query-key factories.
  Admin Data Quality is the first admin reference migration from manual loading
  state to `useQuery`; Admin Role Management now uses query keys for assignment
  reads and exact-uid role loads, with exact-user pending state derived from
  query fetching plus an explicit save mutation and assignment cache
  invalidation. User Analytics report reads now use payload-scoped query
  keys while lookup inputs, range controls, and the active report handoff remain
  controller-owned. Marketing Ops bridge loading now uses a shared query key and
  updates that cache after draft creation and local review decisions; review and
  draft-create pending rows are derived from TanStack mutation state. Event
  Intake dashboard bridge loading now uses the same query-cache pattern while
  review decisions and local source/candidate edits update the bridge cache;
  review-decision pending rows are derived from TanStack mutation state.
  Organizer Intake decision, curation, event-candidate, policy-gap, and
  location-resolution pending rows are also derived from named mutation keys
  instead of local in-flight maps.
  Finance Ops overview loading now uses the finance query key while issue
  filters and selected issue state remain local to the controller. Growth KPI
  snapshot loading now uses range-scoped query keys while stage/search filters
  and selected signal state remain local to the controller. Overview dashboard
  loading now uses separate overview and analytics query keys keyed by mode,
  role access, and analytics payload while filter form state remains
  controller-local. Safety Triage queue and detail reads now use explicit query
  keys while filters, selection, review notes, assignment notes, and recent
  session receipts remain local to the controller. Event Publishing canonical
  list, external supply list, supply readiness, and selected-detail reads now
  use explicit query keys while query inputs, filters, active view, selected
  external row, and edited event form state remain local to the controller.
  Listing public reviews are the first website reference migration for remote
  reads, mutations, cache updates, and invalidation. Claim request submission,
  waitlist submission, and host application submission now follow the same
  website mutation convention.
- Feature folders exist under `website/src/features/**`.

The next refactor should focus on page and style decomposition, not another
top-level framework rewrite. The largest current files are page or style
aggregation points:

| File | Current role | Refactor pressure |
|---|---|---|
| `website/src/features/home/HomePage.tsx` | Thin home route shell that wires site chrome to `HomePageSections` | Keep route assembly here; move future Home section edits into `features/home/sections/` and only promote neutral, repeated shells to shared UI. |
| `website/src/features/organizers/HostListingPage.tsx` | Thin listing route shell that wires site chrome to `useHostListingPageController` and `HostListingSections` | Keep page-local sections under `features/organizers/sections/`; avoid moving listing-specific blocks into shared UI too early. |
| `website/src/features/host/HostPage.tsx` and `HostPreviewPage.tsx` | Route-specific host assembly with shared and route-specific section imports | Keep route files as tables of contents; move section bodies under `features/host/sections/` before extracting only neutral, cross-feature primitives. |
| `website/src/features/claims/ClaimPage.tsx` | Thin claim route shell using injected `ClaimRouteState`, `useClaimFlowController`, and `ClaimPageSections` | Keep route URL parsing in `features/claims/claimRouting.ts` and the React Router shell; keep auth/submission behavior in the controller; keep visible route sections in `features/claims/sections/`. |
| `website/src/shared/ui/primitives.tsx` | Governed visual primitives used by website feature sections | Keep repeated shell markup here, but keep state, analytics, and domain mapping in feature controllers/adapters. |
| `website/src/styles/responsive.css` | Mixed responsive selectors preserved from the former aggregate stylesheet | Split by feature only when visual output can be checked route-by-route. |

## Architecture Rules

1. Route-first before component-first.

   Public route behavior starts in `design/website/routes.json`. Any route,
   metadata, robots, sitemap, generated listing, or static-output change must
   update that contract and pass:

   ```sh
   node tool/run.mjs check marketing:website-routes
   ```

   Route stories with `review.stateCoverage.storybook` must declare matching
   `parameters.catchRoute.id`, `reviewStates`, and `stateCoverage` entries.
   Manual-only route states stay in `stateCoverage.manual`; do not mark a route
   `ready` unless it has at least one Storybook-backed state.

2. Component ownership follows the route contract.

   Component review starts from `design/website/components.json`. Route and
   section stories must attach `parameters.catchComponent.id`, `routeIds`, and
   `states` to registered component coverage, and any component marked
   Storybook-ready must pass:

   ```sh
   node tool/run.mjs check marketing:website-components
   ```

   Keep component entries route-linked through `routeIds`; do not create a
   parallel component inventory that cannot be traced back to public route
   review. The checker validates both directions: ready registry entries must
   point to matching story exports, and referenced stories must point back to
   known ready component ids, valid route ids, and registered state names.

   Storybook stories that render query-backed sections must wrap those sections
   in `WebsiteQueryProvider` so the workbench matches the runtime root.

3. The app shell resolves routes and lifecycle only.

   `App` should choose the route, metadata, page class, page-level captures, and
   shell lifecycle hooks. It should not own page content, feature state, form
   mutation logic, analytics payload assembly, or generated-listing selectors.

4. Page components compose sections; controllers own state.

   Page files should mostly assemble feature sections. Hooks/controllers own URL
   state, forms, local persistence, Firebase calls, analytics side effects, and
   mutation status.

5. Feature folders own domain-specific UI.

   Do not promote a component to shared UI because it is visually reusable once.
   Shared UI is for neutral primitives with stable semantics across multiple
   features. Domain blocks such as listing diagnostics, host product sections,
   claim proof panels, and review lanes stay feature-owned until reuse is real.

6. Interactive controls go through shared primitives.

   Feature, app, and Storybook code must not render raw `<button>`, `<a>`,
   `<input>`, `<select>`, or `<textarea>` elements. Use the website shared UI
   primitives, add a new primitive there when the concept is genuinely missing,
   or add a temporary `react-ui-primitive-allow: <debt-id>` comment with a
   removal plan. The gate is:

   ```sh
   node tool/run.mjs check web:react-ui-primitives
   ```

7. Governed component families and class names go through shared primitives.

   Website and admin code must not hand-roll governed component shells in
   feature, app, or Storybook code. Feature code also must not pass `className`
   directly; class ownership belongs in `website/src/shared/ui`,
   `website/src/shared/site`, or `admin/src/shared/ui`. The class-name gate is:

   ```sh
   node tool/run.mjs check web:react-classname-boundaries
   ```

   The canonical governed-family list is generated by
   `node tool/web/check_react_component_governance.mjs --families-json` and
   checked in at
   `docs/audit_registry/react_component_governance_families.json`. This is a
   known-family blocklist: passing the scanner does not classify novel shell
   families automatically, so repeated new shell drift must become a scanner
   family before handoff. The gate is:

   ```sh
   node tool/run.mjs check web:react-component-governance
   ```

   Exported website feature components are also governed. Any uppercase
   component exported from `website/src/features/**/*.tsx` must be declared in
   `design/website/components.json` as a route, section, flow, or supporting
   component, or made private. The component registry gate is:

   ```sh
   node tool/run.mjs check marketing:website-components
   ```

8. Generated data remains explicit.

   `website/src/generated/hostListings.json` is a generated projection. Feature
   code should read it through `features/organizers/data.ts` and typed selectors,
   not directly from pages outside the organizer feature.

9. Metadata and static output stay coupled.

   Client metadata in `pageMeta.ts`, route resolution in `App`, and postbuild
   output in `website/scripts/postbuild.mjs` must stay covered by the route
   contract. Legacy organizer routes must preserve canonical/noindex behavior
   before and after hydration. Firebase Hosting must route `/claim/**` to the
   generated `/claim/index.html` shell so direct claim lookup links do not fall
   through to root metadata.

10. Analytics and Firebase boundaries stay centralized.

   Consent, event IDs, attribution, GTM/dataLayer emission, and organizer
   analytics dispatch should go through shared analytics services. Feature
   controllers may decide when a business event happened, but should not
   duplicate low-level analytics mechanics.

11. CSS ownership follows component ownership.

   Global CSS defines tokens, resets, shell utilities, and shared primitives.
   Feature CSS belongs beside feature concepts, even if it remains imported from
   a central stylesheet during the migration. Avoid adding unrelated rules to
   broad compatibility files such as `responsive.css`.

## React Dependency Decisions

The React apps should use maintained ecosystem primitives for routing and
server state instead of growing custom pathname, query-string, loading, retry,
and mutation machinery.

| Need | Flutter app analogue | React decision | Scope |
|---|---|---|---|
| URL routing, dynamic path params, search params, links, back/forward behavior | `go_router` | Add `react-router` | `website/` and `admin/` |
| Firebase/server reads, callable mutations, cache invalidation, loading/error states, retry/dedupe | Riverpod async providers and repositories | Add `@tanstack/react-query` | `website/` and `admin/` |
| Cross-feature client-only state | Riverpod client state providers | Keep local React state, `useReducer`, and narrow context first | Add a store only when a real shared client state appears |
| Long form state and validation | Form models plus generated validation contracts | Defer form library selection | Re-evaluate when refactoring host application, claim flow, or admin intake forms |

### Router Direction

Use React Router as the default router for both React apps.

- In `website/`, React Router owns the route shell in `website/src/app/App.tsx`
  and route patterns in `website/src/app/routeRegistry.ts`. It must not replace
  `design/website/routes.json`, route-contract checks, or postbuild static HTML
  output; those remain the SEO/deploy source of truth. Organizer-directory
  search/filter URL state is router-owned through `useSearchParams`, not manual
  `window.history` or `popstate` listeners. Claim lookup URL state is parsed by
  `features/claims/claimRouting.ts` from React Router location/params and passed
  into `ClaimPage`/`useClaimFlowController` as `ClaimRouteState`; claim
  controllers must not default to global browser location.
- In `admin/`, React Router should replace `activeNav` as the primary section
  source of truth. Admin screens should be URL-addressable, refresh-safe, and
  compatible with lazy route modules and role guards.
- Prefer React Router before TanStack Router for the first migration because the
  current need is route ownership and URL correctness, not a fully typed router
  framework. Revisit TanStack Router only if search-param-heavy workflows become
  central enough that typed, validated search state is worth a larger routing
  stack decision.

### Server-State Direction

Use TanStack Query as the default async/server-state layer for both React apps.

- Providers are wired at both React roots. Query-key factories live under
  `shared/query/queryKeys.ts` in each app.
- `admin/src/features/data-quality/controllers/useDataQualityController.ts` is
  the reference migration: it uses `useQuery`, preserves the existing
  controller return shape, and keeps UI-local filters/selection in React state.
- In `admin/`, start with the repeated controller pattern: `useEffect`,
  `isLoading`, `error`, manual refresh, callable invocation, and post-mutation
  reloads. Convert one small controller first, then reuse the query-key and
  mutation conventions.
- In `website/`, keep generated/static data as plain imported data. Use TanStack
  Query only for real async boundaries such as claim lookup/submission, review
  submission, waitlist/host form mutations, and remote manifests or callable
  reads.
- Query keys should live with the feature or shared API client that owns the
  remote contract. Mutation invalidation should name the affected query keys
  explicitly.
- Claim request mutations use `websiteQueryKeys.claims.request`, then
  invalidate `websiteQueryKeys.claims.lookup` and
  `websiteQueryKeys.claims.requests` after successful submission.

### Store And Form Libraries

Do not add Redux, Zustand, Jotai, or another general client-state store in the
first pass. After React Router owns URL state and TanStack Query owns server
state, the remaining state in these apps is mostly view-local UI state that
React state, reducers, and narrow contexts can handle.

Do not add React Hook Form in the first pass. It is a plausible later tool for
the host application, claim proof, and admin intake forms, but the current
brittleness is routing and async server state. Pick a form library only during a
specific form refactor, with validation tied back to existing data contracts.

## Target Feature Structure

This is the target shape for new work and the migration map for existing files.
Do not move everything mechanically in one pass; move sections when the owning
page is being refactored and can be verified.

```text
website/src/
  app/
    App.tsx
    routeRegistry.ts
    pageMeta.ts
    usePageLifecycle.ts
  features/
    home/
      HomePage.tsx
      homeContent.ts
      sections/
        HomePageSections.tsx
    host/
      HostPage.tsx
      HostPreviewPage.tsx
      hostContent.ts
      application/
        HostApplicationFlow.tsx
        applicationModel.ts
        useHostApplicationController.ts
      sections/
        HostPageSections.tsx
        HostPreviewSections.tsx
    organizers/
      OrganizerSearchPage.tsx
      HostListingPage.tsx
      useOrganizerDirectoryController.ts
      useHostListingPageController.ts
      components/
      data/
        generatedListings.ts
        publicDiscovery.ts
      sections/
        OrganizerSearchSections.tsx
        HostListingSections.tsx
        ListingHeroSection.tsx
        ListingFactsSection.tsx
        ListingEventsSections.tsx
        ListingClaimSections.tsx
        ListingReviewsSection.tsx
        ListingSourcesSection.tsx
        ListingFitSection.tsx
      routing.ts
      selectors.ts
      types.ts
    claims/
      ClaimPage.tsx
      claimModel.ts
      useClaimFlowController.ts
      useListingClaimController.ts
      sections/
        ClaimPageSections.tsx
    reviews/
      reviewModel.ts
      useListingReviewsController.ts
      components/
    waitlist/
      WaitlistForm.tsx
      useWaitlistFormController.ts
    marketing/
      MarketingConsentBanner.tsx
      content.ts
      tracking.ts
      useAppDownloadCtas.ts
  shared/
    analytics/
    firebase/
    forms/
    lib/
    site/
      SiteHeader.tsx
      SiteFooter.tsx
      SectionHeader.tsx
    ui/
      Button.tsx
      Field.tsx
      FormStatus.tsx
      primitives.ts
  generated/
    hostListings.json
  styles/
    base.css
    site-shell.css
    site-footer.css
    home.css
    host-foundation.css
    host.css
    organizers.css
    organizer-public.css
    flows.css
    reveal.css
    responsive.css
```

### Import Boundaries

- `app/**` may import feature pages, route metadata, lifecycle hooks, analytics,
  and generated route contracts.
- Feature pages may import their own feature modules, `shared/**`, and explicitly
  named cross-feature controllers only when the product flow requires it.
- `features/claims/**` may depend on organizer listing models because the claim
  flow selects an organizer.
- `features/organizers/**` may depend on claim and review controllers for the
  listing page until those panels move behind local adapter components.
- `shared/**` must not import from `features/**`.
- `generated/**` should be read through a typed feature-owned adapter.

## Recommended Refactor Order

1. Keep the route shell stable.

   React Router now lives in `website/src/app/App.tsx`, route patterns live in
   `website/src/app/routeRegistry.ts`, and `website/src/App.tsx` is only a
   compatibility re-export. Preserve public output, canonical/noindex behavior,
   metadata, lazy route chunks, and postbuild HTML before moving deeper URL state
   or adding component-first review.

2. Keep `HostListingPage` decomposed.

   `HostListingPage` crosses generated listings, legacy metadata, claim CTA
   behavior, reviews, save/share, event cards, and public API state. Keep the
   route file as site chrome plus `HostListingSections`, with
   `useHostListingPageController` owning listing-derived nav, save/share state,
   local persistence, and analytics side effects.

   `HostListingSections` should remain the route-level table of contents for
   page-local sections:

   - `ListingHeroSection`
   - `ListingFactsSection`
   - `ListingCatchEventsSection`
   - `ListingExternalEventsSection`
   - `ListingEventEvidenceSection`
   - `ListingReviewsSection`
   - `ListingEventSuccessSection`
   - `ListingFitSection`
   - `ListingSourcesSection`
   - `ListingMissingEvidenceSection`
   - `RecommendedOrganizersSection`

   The page should continue to read as a table of contents, with business logic
   staying in selectors/controllers and visible sections retaining their
   component-registry and Storybook coverage.

3. Keep `HostPages` split.

   `/host/` and `/host/preview/` now live in route-specific files. Shared host
   sections live under `features/host/sections/`, the host application flow
   lives under `features/host/application/`, and `HostPages.tsx` remains only as
   a compatibility barrel.

4. Keep shared site primitives split.

   `SiteHeader`, `SiteFooter`, and `SectionHeader` now live in `shared/site`.
   Keep using direct `shared/site` imports for new page code. Do not turn
   one-off host/listing/product sections into shared primitives. Do not recreate
   the retired `website/src/components/site.tsx` barrel; import from the
   canonical shared or feature owner directly.

5. Keep CSS split by ownership.

   The former `shared-core.css` aggregate has been split into ordered files
   imported from `styles.css`. Keep class names stable so visual diffs point to
   ownership mistakes, not naming churn. Treat `responsive.css` as the next
   temporary aggregate to reduce.

6. Keep `ClaimPage` decomposed.

   `ClaimPage` owns only site chrome, `useClaimFlowController`, and the
   route-level branch between URL-state rendering and the interactive workspace.
   React Router owns the URL inputs in `App.tsx`, and `claimRouting.ts` owns the
   typed `ClaimRouteState` parser that the route shell passes into `ClaimPage`.
   It must wrap visible claim route content with `ClaimFlowMain`; do not render
   the raw `claim-flow` route shell or claim auth-row modifier in feature code.
   Keep visible rendering in `ClaimPageSections.tsx`:

   - `ClaimHeroSection`
   - `ClaimUrlStateSection`
   - `ClaimWorkspaceSection`

   Storybook section coverage should use a mock controller for
   `ClaimWorkspaceSection` so auth and Firebase side effects stay out of the
   section workbench. Keep mutation, auth, validation, and query invalidation in
   `useClaimFlowController`.

7. Keep the component-first workbench route-linked.

   Storybook is the React equivalent to Widgetbook for the marketing website.
   Stories should use `design/website/routes.json` route ids and
   `design/website/components.json` component ids. `MarketingRoutes.stories.tsx`
   covers `/`, `/host/`, `/host/preview/`, `/claim/`, `/organizers/`, `/404/`,
   and the generated organizer listing family. Its `parameters.catchRoute`
   blocks are route-contract evidence, so keep `reviewStates` and
   `stateCoverage` synchronized with `routes.json`. `HostSections.stories.tsx`
   covers the shared host sections plus the Host Preview route section layer.
   `ClaimSections.stories.tsx`, `OrganizerSearchSections.stories.tsx`, and
   `OrganizerListingSections.stories.tsx` cover the first claim/organizer
   section layers. Add
   route plus section stories before smaller reusable component atoms.

8. Keep server-state conventions explicit.

   TanStack Query providers and query-key factories now exist in both React
   apps. Continue with focused controller migrations: one query or mutation
   family at a time, with explicit invalidation after successful mutations.
   `Admin Data Quality`, `Organizer Publishing`, organizer intake mutations,
   public claims/reviews, website waitlist and host application submissions,
   `Access Review`, `Admin Role Management`, `User Analytics`, `Marketing Ops`,
   `Event Intake`, `Finance Ops`, `Growth KPI`, `Overview`, `Safety Triage`,
   and `Event Publishing` are the current reference adopters.
   `Access Review` keeps local
   form/filter/recent-decision state in the controller, but list/detail reads
   and the approve/deny mutation now use query keys, query state, and explicit
   invalidation. `Admin Role Management` keeps editable selected-role state in
   the controller while assignment reads, exact-uid role loads, exact-user
   pending state, and role-save invalidation go through TanStack Query. `User
   Analytics` keeps lookup/range
   form state local, but submitted report reads are cached by normalized payload
   so user id, preset/custom dates, and granularity do not collide. `Marketing
   Ops` keeps studio
   tab/composer/local-edit state local, while the bridge read and post-write
   bridge replacement use the shared query cache. `Event Intake` keeps
   tab/notes/local source and candidate edits in the controller, while the
   dashboard bridge read and review-decision cache updates use the shared query
   cache. `Finance Ops` keeps filter/selection state local, while finance
   signals are derived from the query-cached overview snapshot. `Growth KPI`
   keeps range, stage, search, and selection state local while overview and host
   analytics signals come from the range-scoped query snapshot. `Overview`
   keeps range, granularity, date, club, and event filters local while the
   overview snapshot and role-scoped host analytics payload use separate query
   keys. `Safety Triage` keeps queue/search filters, selection, decision notes,
   assignment notes, and recent session receipts local while the queue snapshot,
   selected detail, assignment mutation, and decision mutation use shared query
   keys and mutation pending state. `Event Publishing` keeps query inputs,
   filters, active view, selected external row, and edited event form state
   local while canonical list, external list, supply readiness, selected detail,
   save mutation, and external publish mutation use shared query keys and
   mutation pending state. Organizer Intake, Event Intake, and Marketing Ops
   row-level pending state is derived from TanStack mutation state through named
   mutation keys. `web:react-query-state` ratchets manual
   loading/saving/submitting/in-flight state in feature controllers and feature
   `use*` hooks against `tool/web/react_query_state_baseline.json`; new
   server-state work should keep that baseline empty.

9. Keep React query-state enforcement active.

   Website and admin code now share `node tool/run.mjs check
   web:react-query-state`. The scanner is a baseline-backed ratchet for manual
   async state in feature controllers and feature `use*` hooks. The baseline is
   empty for both React apps. The gate fails new unbaselined
   loading/saving/submitting/in-flight state. Refresh the baseline only when a
   deliberate exception has an audit pass and a removal plan.

10. Keep React primitive enforcement active.

   Website and admin code now share the first React UI primitive scanner:
   `node tool/run.mjs check web:react-ui-primitives`. Expand it before adding
   new local button/link/input/select/textarea variants in feature code.

11. Keep React component-family enforcement active.

   Website and admin code share `node tool/run.mjs check web:react-classname-boundaries` plus `node tool/run.mjs check web:react-component-governance`. The class-name scanner blocks feature/app/story `className` usage outside shared primitive owner files. The component scanner-owned family registry is emitted by `node tool/web/check_react_component_governance.mjs --families-json` and checked in at `docs/audit_registry/react_component_governance_families.json`. This is a known-family blocklist: passing it does not classify novel shells, so repeated new component drift must become a scanner family before handoff.

## Next Implementation Batch

The next code refactor should be small:

1. Add generated listing section states when new generated fixtures expose
   external events or event-evidence sections.
2. Move claim lookup reads to TanStack Query only if/when the lookup becomes a
   real remote read instead of generated-data URL resolution.
3. Migrate one more admin read or mutation controller with repeated manual
   loading state, using Admin Data Quality, Access Review, Admin Role
   Management, User Analytics, Marketing Ops, Event Intake, Finance Ops, Growth
   KPI, Overview, Safety Triage, and Event Publishing as references. Run a small
   inventory before choosing another admin async candidate so the next migration
   is driven by remaining manual load or mutation state rather than stale
   candidate prose.
4. Keep generated/static website data as plain imports; use TanStack Query only
   for true remote reads and mutations.

Run:

   ```sh
   node tool/run.mjs check marketing:website-routes
   node tool/run.mjs check marketing:website-components
   node tool/run.mjs check web:react-ui-primitives
   node tool/run.mjs check web:react-component-governance
   node tool/run.mjs check web:react-query-state
   npm --workspace catch-marketing run typecheck
   npm --workspace catch-marketing run build:storybook
   npm --workspace catch-marketing run build
   node website/scripts/checkOrganizerBuildOutputs.mjs
   ```

The next useful proof is applying the same convention to one additional admin
read or mutation family without changing the surrounding UI contracts.

## Open Decisions

- Decide whether the mixed organizer canonical route family should be preserved
  short term or migrated toward city-scoped canonical paths only.
- Decide whether marketing content should remain TypeScript-owned or move to a
  content file format that non-engineering workflows can edit.
- Decide which route review states are required for launch versus acceptable as
  manual review notes.
- Decide whether React Hook Form is worth adding during a specific long-form
  refactor after routing and server-state conventions are in place.
