---
doc_id: marketing_website_architecture
version: 0.3.9
updated: 2026-07-01
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
- `design/website/routes.json` records the public route contract and review
  states.
- `design/website/components.json` records route and section ownership, CSS
  ownership, and Storybook coverage status. It is validated by
  `tool/marketing/check_website_components.mjs`.
- `website/src/features/host/HostPage.tsx` and
  `website/src/features/host/HostPreviewPage.tsx` own separate host route
  composition. Shared host sections live under
  `website/src/features/host/sections/**`, and host application form state lives
  under `website/src/features/host/application/**`.
- `website/src/features/host/HostPages.tsx` is a compatibility re-export only.
- `website/src/features/organizers/OrganizerSearchPage.tsx` now composes
  organizer-owned search sections from
  `website/src/features/organizers/sections/OrganizerSearchSections.tsx`; the
  controller remains the URL/search-param state owner.
- `website/src/shared/site/**` owns neutral site shell/display primitives:
  `SiteHeader`, `SiteFooter`, and `SectionHeader`.
- `website/src/components/site.tsx` still owns marketing and organizer-shaped
  display blocks, and re-exports the shared-site primitives for compatibility.
- `website/.storybook/**`, `website/src/stories/MarketingRoutes.stories.tsx`,
  `website/src/stories/HostSections.stories.tsx`, and
  `website/src/stories/OrganizerSearchSections.stories.tsx` provide the first
  component-first workbench for route-linked and section-linked review.
- Website CSS is split from the former `shared-core.css` aggregate into
  ordered ownership files under `website/src/styles/**`. `responsive.css`
  remains a mixed responsive layer until the next finer-grained CSS pass.
- TanStack Query is installed in both React apps. `website/src/shared/query/**`
  and `admin/src/shared/query/**` own query providers and query-key factories.
  Admin Data Quality is the first reference migration from manual loading state
  to `useQuery`.
- Feature folders exist under `website/src/features/**`.

The next refactor should focus on page and style decomposition, not another
top-level framework rewrite. The largest current files are page or style
aggregation points:

| File | Current role | Refactor pressure |
|---|---|---|
| `website/src/features/organizers/HostListingPage.tsx` | Route-level listing composition, share/save side effects, and ordered section assembly | Keep page-local sections under `features/organizers/sections/`; avoid moving listing-specific blocks into shared UI too early. |
| `website/src/features/host/HostPage.tsx` and `HostPreviewPage.tsx` | Route-specific host composition with shared section imports | Keep route files as tables of contents; move only neutral, cross-feature primitives out of host. |
| `website/src/features/claims/ClaimPage.tsx` | Claim lookup, selected listing, auth status, role/proof/submitted states | Split rendering sections after controller boundaries stabilize. |
| `website/src/components/site.tsx` | Marketing and organizer display blocks plus compatibility re-exports | Continue moving only neutral primitives with real cross-feature use; keep domain cards here until feature ownership is clearer. |
| `website/src/styles/responsive.css` | Mixed responsive selectors preserved from the former aggregate stylesheet | Split by feature only when visual output can be checked route-by-route. |

## Architecture Rules

1. Route-first before component-first.

   Public route behavior starts in `design/website/routes.json`. Any route,
   metadata, robots, sitemap, generated listing, or static-output change must
   update that contract and pass:

   ```sh
   node tool/run.mjs check marketing:website-routes
   ```

2. Component ownership follows the route contract.

   Component review starts from `design/website/components.json`. Route and
   section stories should attach `parameters.catchComponent.id` to a registry
   id, and any component marked Storybook-ready must pass:

   ```sh
   node tool/run.mjs check marketing:website-components
   ```

   Keep component entries route-linked through `routeIds`; do not create a
   parallel component inventory that cannot be traced back to public route
   review.

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

6. Generated data remains explicit.

   `website/src/generated/hostListings.json` is a generated projection. Feature
   code should read it through `features/organizers/data.ts` and typed selectors,
   not directly from pages outside the organizer feature.

7. Metadata and static output stay coupled.

   Client metadata in `pageMeta.ts`, route resolution in `App`, and postbuild
   output in `website/scripts/postbuild.mjs` must stay covered by the route
   contract. Legacy organizer routes must preserve canonical/noindex behavior
   before and after hydration.

8. Analytics and Firebase boundaries stay centralized.

   Consent, event IDs, attribution, GTM/dataLayer emission, and organizer
   analytics dispatch should go through shared analytics services. Feature
   controllers may decide when a business event happened, but should not
   duplicate low-level analytics mechanics.

9. CSS ownership follows component ownership.

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
  `window.history` or `popstate` listeners.
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
    host/
      HostPage.tsx
      HostPreviewPage.tsx
      hostContent.ts
      application/
        HostApplicationFlow.tsx
        applicationModel.ts
        useHostApplicationController.ts
      sections/
    organizers/
      pages/
        OrganizerSearchPage.tsx
        HostListingPage.tsx
      components/
      data/
        generatedListings.ts
        publicDiscovery.ts
      controllers/
        useOrganizerDirectoryController.ts
      routing.ts
      selectors.ts
      types.ts
    claims/
      ClaimPage.tsx
      claimModel.ts
      useClaimFlowController.ts
      useListingClaimController.ts
      sections/
    reviews/
      reviewModel.ts
      useListingReviewsController.ts
      components/
    waitlist/
      WaitlistForm.tsx
      useWaitlistFormController.ts
    marketing/
      AppDownloadCtas.tsx
      MarketingConsentBanner.tsx
      content.ts
      tracking.ts
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
   behavior, reviews, save/share, event cards, and public API state. Keep it as
   a route-level table of contents that assembles page-local sections:

   - `ListingHeroSection`
   - `ListingFactsSection`
   - `ListingEventsSection`
   - `ListingClaimSection`
   - `ListingReviewsSection`
   - `ListingSourcesSection`
   - `ListingDiagnosticsPanel`

   The page should continue to read as a table of contents, with business logic
   staying in selectors/controllers.

3. Keep `HostPages` split.

   `/host/` and `/host/preview/` now live in route-specific files. Shared host
   sections live under `features/host/sections/`, the host application flow
   lives under `features/host/application/`, and `HostPages.tsx` remains only as
   a compatibility barrel.

4. Keep shared site primitives split.

   `SiteHeader`, `SiteFooter`, and `SectionHeader` now live in `shared/site`.
   Keep using direct `shared/site` imports for new page code. Do not turn
   one-off host/listing/product sections into shared primitives.

5. Keep CSS split by ownership.

   The former `shared-core.css` aggregate has been split into ordered files
   imported from `styles.css`. Keep class names stable so visual diffs point to
   ownership mistakes, not naming churn. Treat `responsive.css` as the next
   temporary aggregate to reduce.

6. Keep the component-first workbench route-linked.

   Storybook is the React equivalent to Widgetbook for the marketing website.
   Stories should use `design/website/routes.json` route ids and
   `design/website/components.json` component ids. `MarketingRoutes.stories.tsx`
   covers `/`, `/host/`, `/host/preview/`, and `/organizers/`.
   `HostSections.stories.tsx` and `OrganizerSearchSections.stories.tsx` cover
   the first section layers. Add route plus section stories before smaller
   reusable component atoms.

7. Keep server-state conventions explicit.

   TanStack Query providers and query-key factories now exist in both React
   apps. Continue with focused controller migrations: one query or mutation
   family at a time, with explicit invalidation after successful mutations.

## Next Implementation Batch

The next code refactor should be small:

1. Extend route plus section Storybook coverage to one generated organizer
   listing route, using `/organizers/` and Host as the reference exhibits.
2. Migrate one website callable boundary, preferably public listing reviews or
   claim submission, to TanStack Query mutations and explicit invalidation.
3. Migrate one more admin read controller with repeated manual loading state,
   using Admin Data Quality as the reference.
4. Keep generated/static website data as plain imports; use TanStack Query only
   for true remote reads and mutations.

Run:

   ```sh
   node tool/run.mjs check marketing:website-routes
   node tool/run.mjs check marketing:website-components
   npm --workspace catch-marketing run typecheck
   npm --workspace catch-marketing run build:storybook
   npm --workspace catch-marketing run build
   node website/scripts/checkOrganizerBuildOutputs.mjs
   ```

The next useful proof is applying the convention to one mutation path and one
additional admin read path without changing the surrounding UI contracts.

## Open Decisions

- Decide whether the mixed organizer canonical route family should be preserved
  short term or migrated toward city-scoped canonical paths only.
- Decide whether marketing content should remain TypeScript-owned or move to a
  content file format that non-engineering workflows can edit.
- Decide which route review states are required for launch versus acceptable as
  manual review notes.
- Decide whether React Hook Form is worth adding during a specific long-form
  refactor after routing and server-state conventions are in place.
