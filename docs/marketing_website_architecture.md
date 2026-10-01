---
doc_id: marketing_website_architecture
version: 0.11.0
updated: 2026-09-30
owner: marketing_website
status: active
---

# Marketing Website Architecture

This document owns the code organization and refactor target for the public
React marketing website in `website/`. Use `docs/web_surface_architecture.md`
for domains, deploy targets, CI/CD, and cross-surface hosting boundaries. Use
`design/website/routes.json` for the route-first contract and
`design/website/components.json` for the component-first registry.

## Organiser first content review

The public React root composes organiser acquisition content through the existing
site shell and semantic marketing primitives. Product, Solutions, Explore and
Resources are section links in this first review pass. The four product jobs
are presence/discovery, registration/guest management, live operations and
programme/logistics. Software actions lead to the current supported Host pilot,
labelled concept routes or a guided walkthrough. They do not imply that the
prototype's prices, integrations or workflow connections are available.

The previous consumer homepage is preserved as `VisitorDiscoveryPage` at
`/explore/`, including its app availability, member journey, waitlist and safety
sections. Discovery and featured organisers reuse their original section owners
on both routes, with authored acquisition copy overrides on the organiser root.
The consumer Marketing Home feature contract follows the preserved discovery
route. The new root is an editorial projection of existing Host acquisition;
it introduces no account or transaction authority.

Public organiser presence uses Events, About and Reviews anchor navigation.
Catch and external event cards precede About. When only historical source event
evidence exists, Events targets that evidence; it does not claim current booking
inventory. Canonical provider links, review gates and claim policies remain
unchanged. Detailed source facts stay in About; existing source links retain
their provenance labels rather than becoming unsupported contact widgets.

| Existing content | Canonical destination in this review pass |
|---|---|
| Original homepage's ten sections | Preserved at `/explore/`; discovery and featured-organiser owners also reused at `/`. |
| Supported Host workflow, playbooks, trust and beta application | Retained at `/host/`, linked from the organiser root. |
| All 49 prototype sections and nine views | Retained at their `/host/*` content-preview routes; unique console/tier/stack interactions remain labelled illustrative. |
| Workflow review examples and shared capability/pilot content | Retained at `/host/workflows/`; organiser product/solution sections link to the relevant views. |
| Directory, profiles and external events | Existing canonical owners, with clearer acquisition navigation and profile section order. |
| Forms, booking, offers, invites, household RSVP, runtime, rehearsal, assistance, legal and help | Existing routes and controllers retained without contract/permission changes. |

The four surfaces remain distinct: marketing explains adoption; public presence
represents an organiser; event and authorised guest pages serve event decisions;
the existing organiser workspace operates events. No new workspace is created.
`Get started free` currently begins the existing claim request with an explicit
notice that presence-management tools are in development. Sign-in is described
as claim sign-in, not access to a fictional dashboard.

Follow-ons need separate authority design and tests: web organiser profile
completion (claim approval requires `profileComplete`), listing editing and
event publishing, verified-owner replies with independent moderation, scoped
aggregate analytics, team permissions and postclaim activation. Instagram
control proof is not implemented; permission for marketing use is separate.
Prior prototype promises such as “Claiming unlocks owner replies”, “Claim to
respond”, and claim-to-publish/manage copy remain preserved in the test-only
source fixture and concept material. Public profile copy now accurately offers
ownership review and labels reply tools as planned.

## Current State

The website is already split out of the old monolithic shell:

- `website/src/App.tsx` is a compatibility re-export for the app entrypoint.
- `website/src/app/App.tsx` owns the React Router shell, metadata selection,
  page-level lifecycle hooks, and route-level lazy loading.
- `website/src/app/routeRegistry.ts` owns runtime route patterns.
- `website/src/features/eventRehearsal/` owns the no-login
  `/rehearse/:publicRehearsalId` synthetic guest phone. TanStack Query redeems
  and persists one deterministic browser slot, polls the Host virtual clock,
  caches returned guest mutations, and slows its cadence under the explicit
  low-bandwidth fault. `EventRehearsalPreview` is the provider-free Storybook
  and unit-test seam; it composes shared Event Runtime primitives with a
  persistent practice banner, bounded guest actions, fault notices, and a
  read-only completion state. Auth, OTP, production registration and private
  Host data are deliberately absent.
- `website/src/content/meta.json`, validated by
  `website/src/content/meta.schema.json` and
  the browser-safe `website/src/content/metaContract.ts`, owns static page
  metadata and the static labels used for generated organizer and event HTML.
  `website/src/app/pageMeta.ts` runtime-validates on client module load;
  `tool/marketing/website_meta_contract.mjs` adds filesystem reading for Node
  postbuild. Ajv parity tests run valid and invalid fixtures through both the
  JSON Schema and browser validator. Neither consumer owns a duplicate validator
  or copy of the strings.
- `website/scripts/postbuild.mjs` emits route-specific static HTML after Vite.
  Generated organizer routes include semantic profile content, Organization and
  breadcrumb JSON-LD. Generated event routes include read-only event details,
  source-aware registration handoff, event-scoped reviews, Event and breadcrumb
  JSON-LD, canonical/robots metadata, and organizer-derived freshness before
  React executes. `checkOrganizerBuildOutputs.mjs` fails builds that regress
  those crawlable outputs.
- Postbuild emits root `404.html`; the marketing Hosting target intentionally
  has no catch-all SPA rewrite, so unknown direct URLs reach Firebase's custom
  404 response with status 404. The route contract declares that status, the
  route checker compares it with `firebase.json`, and deployment performs a
  unique-path HTTP probe.
- `design/website/routes.json` records the public route contract, review
  states, and Storybook/manual state coverage.
- `design/website/components.json` records route and section ownership, CSS
  ownership, and Storybook coverage status. It is validated bidirectionally
  against referenced Storybook `parameters.catchComponent` declarations by
  `tool/marketing/check_website_components.mjs`.
- `design/features/feature_coverage.json` classifies every marketing route as a
  contracted, grouped, planned, or explicitly excluded feature projection.
  Shared product outcomes may target a cross-runtime identity such as
  `feature.explore` or `feature.organizer_detail`; route metadata, static output,
  React components, actions, and evidence remain owned by the website runtime.
  Organizer Search is the first live projection: the feature compiler resolves
  its three real route states, controller actions, route/section Storybook
  previews, focused controller tests, and public listing projection schema into
  the same generated `feature.explore` artifact as Flutter Explore. The removed
  `saved-organizers` route state belongs to organizer detail storage and was not
  an Organizer Search state.
- All stateful marketing route authorities are now compiled. Marketing Home
  owns public discovery handoffs, store availability, Host routing, and member
  waitlist conversion. Host Acquisition owns the standalone-tooling narrative,
  external-booking setup walkthrough, live-module catalog, explicit
  current-versus-coming-later boundary, and the five-stage beta application.
  Organizer Claim binds both the
  canonical workspace and dynamic lookup route so known, not-found, pending,
  already-claimed, and unavailable authority states remain exact. Privacy,
  Terms, Help, and 404 stay explicitly excluded as static/fallback surfaces;
  the legacy organizer-listing route stays grouped because its difference is
  static canonical/noindex policy rather than an independent workflow.
- Marketing mutations use the frozen-snapshot variant of
  `ARCH-PENDING-SNAPSHOT-001`. Waitlist, Host application, canonical Claim,
  and listing Claim register one active request, disable their complete native
  form boundary, guard controller entry points against same-tick duplicates,
  and temporarily block sibling forms, shared route links, and browser exit.
  This keeps the visible draft, auth session, step, and submitted payload
  identical until the request settles.
- Marketing Home and Host Acquisition bind their remote lead mutation to the
  shared `contracts/http/join_waitlist_request.schema.json` and
  `join_waitlist_response.schema.json` contracts. The generator projects the
  same types into website and Functions code, while both boundaries reject
  malformed payloads and responses.
- `website/src/generated/hostListings.json` is production-only and excludes
  `dataOrigin: "catchDemo"` plus Firestore organizer records that do not
  resolve to a `live` city in the active market pack. Legacy scraped seed
  directories and their CLI inputs are retired; production materialization
  reads canonical `organizers/{id}` documents only. Multi-market organizer
  listings expose only their live-market projection in production. Storybook reads the explicit demo-inclusive
  `hostListings.demo.json` projection through `stories/fixtures/hostListings.ts`.
  The production read-only snapshot stage regenerates `hostListings.json` from
  canonical Firestore organizer documents and passes only the validated listing
  outputs to the uncredentialed exact build; promotion never rematerializes
  them. The committed JSON is a static build projection, never the operational
  source of truth. The pretypecheck gate validates both outputs.
- Public event pages are the acquisition boundary for standalone Host events.
  A capability-eligible event may offer phone-OTP RSVP/waitlist without asking
  for Consumer dating-profile setup. The mutation is server-owned, links or
  creates an `eventAttendees` record with `webOtp` source, and returns only the
  attendee's event-scoped state. The website never reads a private roster or
  writes `eventParticipations` directly. A first registration may seed a private
  onboarding draft with the attendee-supplied name and verified phone for an
  intentional later Consumer onboarding continuation; this does not create a
  profile. Optional organizer WhatsApp and SMS permissions are independent,
  unchecked by default, and organizer-scoped. Event registration, imported
  contact data, and account prefill do not grant either channel or Catch
  advertising permission. Catch ticketing and profile-dependent
  Consumer features remain separately gated capabilities. The read-only
  production materializer publishes only explicitly OTP-enabled events and
  obtains capacity totals through Firestore `count()` aggregation; it never
  downloads attendee rows or contact fields into the website build.
- Public Forms at `/f/:publicFormId/` are a standalone respondent product
  surface rather than a marketing conversion form. The route lazy-loads its
  controller and governed primitives, resolves only a server-sanitized active
  version, and supports version-bound autosave, explicit review, submission
  receipts, withdrawal, source-link attribution, and iframe presentation.
  Identity policy can require verified phone, email magic link, or a Catch
  account without requiring Consumer app installation. File and signature
  controls stay unavailable until their secure upload and consent tranche is
  complete; the UI does not pretend that placeholder inputs are functional.
- Organizer website URLs come from the canonical document's
  `publicPage.canonicalPath`; the Firestore `organizers/{organizerId}` auto-id
  is an internal identity and is not a URL convention. Route reservations make
  slugs unique independently of document creation.
- Organizer listings consume the canonical `supplyCapabilities` projection.
  Unclaimed supply never renders Catch booking, payment, waitlist, or direct
  host-contact actions; it remains claimable, and review eligibility begins
  only after an event ends. Missing or invalid capabilities fail closed. The
  generated static projection derives legacy records conservatively while the
  production backfill completes, but React does not re-infer policy from
  provenance or claim copy.
- `design/public_surface_behavior.json` is the cross-surface authority and
  action matrix described by
  `docs/web_surface_architecture.md#public-viewer-and-listing-authority-matrix`.
  Website listing policy must consume canonical ownership, claim,
  verification, publication, independent claim/review-target/read/write
  capability fields, and runtime availability; it must not infer an enabled
  action from provenance or sign-in state. Published-but-suppressed records and
  review capabilities without a verified canonical target fail closed. The
  strict checker plus
  `website/src/features/organizers/publicSurfaceBehavior.test.ts` prove every
  registered website row against production policy and presentation adapters.
- Home event discovery applies the pure `homeEventEligibility.ts` selector:
  only future Catch events in market-pack live cities are eligible. External
  events remain listing-page evidence, and city aliases normalize at this
  boundary. The selector receives `now` explicitly and has focused tests.
- `tool/marketing/check_website_routes.mjs` validates route URL, metadata,
  static output, generated listing coverage, and referenced Storybook
  `parameters.catchRoute` declarations.
- `tool/web/check_react_ui_primitives.mjs` prevents feature/app/story code from
  hand-rolling native interactive controls outside shared primitive owners.
- `tool/web/check_react_component_governance.mjs` prevents React app/feature
  code from hand-rolling governed component families. Its `--families-json`
  output is generated on demand and documents the known-family blocklist
  limitation; it is not a checked-in reader snapshot.
- `design/web-ui/shared_primitive_adoption.json` owns the audited
  marketing/admin compatibility queue. Website buttons, fields, choice chips,
  choice cards, empty states, status badges, and data tables adapt the
  compatible `@catch/web-ui` native semantics; visual classes, authored labels,
  domain variants, and feature composition remain website-owned.
- Shared route/page shell presentation lives in `website/src/shared/site` as
  `PageShell` and `WebsitePageMain`. `website/src/app/App.tsx` owns React
  Router, route metadata, lifecycle hooks, and page-class selection, but
  configures `PageShell` instead of rendering raw `page-shell` markup. Ordinary
  route files use `WebsitePageMain`; routes with their own visual shell keep
  using shared route-specific mains such as `ClaimFlowMain`. Raw `page-shell`
  wrappers and raw `<main>` tags are
  blocked by `web:react-component-governance`.
- `website/src/features/host/HostPage.tsx` is the single canonical host route.
  `/host/preview{,/**}` is retired at Firebase Hosting with a permanent redirect
  to `/host/`. Host sections live under `website/src/features/host/sections/**`;
  `HostPageSections.tsx` owns the core sequence, `HostSupportingSections.tsx`
  owns offer/trust/FAQ, and `PlaybookShowcase.tsx` owns the stage rail and
  deep-linkable module catalog. The public route starts with an external guest
  list and a no-download attendee runtime; Catch-native booking, member
  profiles, chats, and network effects stay below the explicit coming-later
  boundary.
  Host application form state lives under `website/src/features/host/application/**`.
- The remaining legacy-named `HostPreview*` Storybook and offer/trust/FAQ
  primitives are internal implementation details in the host primitive family;
  no preview route or preview feature owner remains. New public concepts use
  Host or Playbook names and must not recreate the retired route boundary.
- Shared Host Page route shells live in
  `website/src/shared/ui/primitives/` as `HostHero*` and
  `HostPageSection`; `CaptureGrid` owns the host capture-grid modifier.
  Host sections configure those primitives; they do not render raw host hero,
  evidence, surface, fill-room, proof-ledger, or capture-grid modifier shells
  directly.
- Shared Host Application flow shells live in
  `website/src/shared/ui/primitives/` as `HostApplication*` and
  `OperationalNote`. `HostApplicationFlow.tsx` owns the form state and field
  choices, but configures shared flow shells instead of rendering raw
  `host-application*`, `submitted-panel__mark`, or `operational-note` markup.
- Shared Host feature section shells live in
  `website/src/shared/ui/primitives/` as `HostFeatureSection`,
  `HostFeatureGrid`, `HostFeatureRail`, `HostCreateFlowCapture`,
  `HostComparisonTable*`, `PrivacyGuardrail`, and `PhoneCaptureShell`.
  `CreateEventWalkthrough`, `EventSuccessShowcase`, `HostComparisonSection`,
  and `CaptureFrames` own state, content, and capture selection, but configure
  shared section shells instead of rendering raw `host-create-flow*`,
  `event-success-*`, `host-comparison*`, `comparison-table*`,
  `privacy-guardrail`, or `phone-capture*` markup.
- Shared app capture card shells live in
  `website/src/shared/ui/primitives/` as `CaptureCard`.
  Home and Host sections pass capture manifests and fallback labels to that
  primitive instead of rendering raw `capture-card` figure shells.
- Shared product module grid shells live in
  `website/src/shared/ui/primitives/` as `ProductModuleGrid`. Host fill-room
  sections pass module content into that primitive instead of rendering raw
  `product-module-grid` or `product-module-card` shells.
- Shared listing event action cards live in
  `website/src/shared/ui/primitives/` as `EventActionCard`. Organizer
  listing event sections own the event-card content and analytics callback, but
  configure the shared card instead of rendering raw `event-action-card` shells.
- Shared organizer identity display shells use `ActivityMark` and
  `StatusBadge`. The listing-strength heuristic remains available only for
  internal ordering; public organizer cards, directory results, and listing
  diagnostics must not render it as a percentage or quality score. The shared
  `ProfileStrength` meter remains a host-application completeness primitive,
  not an organizer reputation signal.
- Shared process status panels live in
  `website/src/shared/ui/primitives/` as `ProcessStatusPanel`. Claim route
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
  `website/src/shared/ui/primitives/` as `HomeHero*`,
  `MarketingSection`, `MarketingSectionCopy`, `MarketingFormatCard`,
  `MarketingInfoCardGrid`, `HostComparisonSummaryCards`, `MarketingLoopList`,
  `FeaturedOrganizerCardGrid`, and `LiveMeter`. Feature sections configure
  those primitives with item arrays and route-specific copy; they do not render
  the raw marketing section, loop-list, or reveal-article info-card shells
  directly.
- Shared marketing consent banner presentation lives in
  `website/src/shared/ui/primitives/` as `MarketingConsentBannerShell`.
  `website/src/features/marketing/MarketingConsentBanner.tsx` owns consent
  state and analytics choices, but configures the shared shell instead of
  rendering raw `consent-banner` markup.
- Featured organizer cards use `FeaturedOrganizerCardGrid`; Home featured
  organizers and listing recommendations provide card item config through
  `featuredOrganizerCardItemForListing` rather than rendering feature-owned
  mini-card shells.
- Shared app-download CTA presentation lives in
  `website/src/shared/ui/primitives/` as `AppDownloadCtaGroup`, with
  `AppDownloadCtas*` and `StoreButton*` kept as shared implementation helpers.
  `website/src/features/marketing/useAppDownloadCtas.ts` owns store-link
  analytics configuration only. Route sections pass placement, variant, and
  optional initial status into `AppDownloadCtaGroup`; they must not recreate the
  deleted `AppDownloadCtas.tsx` feature component or render raw
  `app-download-ctas` / `store-button` structure directly.
- Shared waitlist form presentation lives in
  `website/src/shared/ui/primitives/` as `WaitlistFormShell`.
  `website/src/features/waitlist/WaitlistForm.tsx` owns controller-driven form
  state, field choices, and submission behavior, but configures the shared form
  shell instead of passing raw `waitlist-form` classes through a generic
  primitive.
- Shared UI label shells live in `website/src/shared/ui/primitives/` as
  `UiLabel`, with the base `.ui-label` style owned by `site-shell.css`.
  Route sections and legacy website display components configure `UiLabel`
  instead of rendering raw uppercase label spans directly. `UiLabel` maps to
  `catch.ui_label` for hierarchy; status-oriented `StatusBadge` remains mapped
  to `catch.badge`.
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
  `website/src/shared/ui/primitives/` as `ListingSection`,
  `ListingSectionIntro`, `ListingFactGrid`, `ListingNoteGrid`,
  `ListingFormatRow`, `ListingDiagnostics*`, `ListingEventDownloadPanel`,
  `ListingEventEvidenceList`, `ListingReview*`, and `ListingSourceLedger`.
  Organizer sections configure those primitives; they do not render raw
  `listing-*` structural shells or revealed intro wrappers directly.
- `ListingFactsSection.tsx` owns the compact About and organizer-format
  presentation beneath the polaroid; `ListingFitSection.tsx` owns lower-page
  positioning notes and configures `ListingNoteGrid` instead of composing
  listing grid/card shells directly.
- `ListingEventsSections.tsx` owns event data selection, app-download placement,
  and outbound analytics behavior, but configures `ListingEventDownloadPanel`
  and `ListingEventEvidenceList` instead of composing event download/card/meta
  shells directly.
- `ListingSourcesSection.tsx` owns source data and analytics event selection,
  but configures the compact `ListingRailLinkList` so sources remain visible in
  the sticky action rail without feature-owned anchor shells.
- Shared organizer profile shells live in
  `website/src/shared/ui/primitives/` as `ListingProfileLayout`,
  `ListingProfilePrimary`, `ListingProfileRail`, `ListingPolaroid`,
  `ListingStatusLedger`, and the `ListingRail*` slots. `ListingHeroSection`
  owns listing data and the Catch polaroid presentation, while
  `ListingHeroRailSection` owns capability-aware claim, save, share, and
  ownership presentation. Organizer profiles use a white-mat polaroid with a
  mono location caption and upright Archivo identity; event notches,
  perforation, and ticket-stub typography remain exclusive to Event Detail.
- Shared organizer listing review shells live in
  `website/src/shared/ui/primitives/` as `ListingReviewSummary`,
  `ListingReviewWorkspace`, `ListingReviewLanes`, `ReviewSignalLane`,
  `ReviewSignalCard`, `OwnerResponsePrompt`, `ListingReviewEmptyState`,
  `ListingReviewForm`, and `ListingReviewCheckbox`. `ListingReviewsSection`
  owns review controller state, copy, submission behavior, and analytics
  callbacks, but configures shared review shells instead of rendering raw
  `review-signal-*`, `owner-response-prompt`, `listing-owner-response`, or
  `listing-review-*` form/state markup.
- Shared organizer listing claim shells live in
  `website/src/shared/ui/primitives/` as `ClaimMissingEvidenceList` and
  `ClaimRequestForm`, alongside the existing `ClaimBand*` and
  `ClaimRequestPanel*` primitives. `ListingClaimSections.tsx` owns claim
  controller state, auth actions, copy, and analytics, but configures shared
  claim list/form shells instead of rendering raw `missing-list` or
  `claim-request-form` markup.
- Shared organizer search result shells live in
  `website/src/shared/ui/primitives/` as `OrganizerResultCard*` and
  `OrganizerEventHighlights`. Organizer search sections configure those
  primitives; they do not render raw result-card, topline, highlight, or footer
  shells directly.
- Shared organizer search section shells live in
  `website/src/shared/ui/primitives/` as `OrganizerSearchSection`,
  `OrganizerSearchStats`, `OrganizerResultSummary`, and
  `DirectoryClaimPressure*`. Organizer search sections own controller-driven
  filters, result mapping, and claim links, but configure shared section shells
  instead of rendering raw `organizer-search-*`, `organizer-result-summary`,
  `directory-claim-pressure*`, or `organizer-results` markup.
- Shared claim-flow route shells live in
  `website/src/shared/ui/primitives/` as `ClaimFlowMain`,
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
  governed visual primitives from `website/src/shared/ui/primitives/`, and
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
  waitlist submission, and host application submission follow the same website
  mutation convention and frozen-snapshot pending boundary. TanStack mutation
  state drives the visible disabled boundary; a synchronous controller ref
  prevents a duplicate before React can publish that state.
- Feature folders exist under `website/src/features/**`.
- `website/src/features/events/**` owns the generated event-detail route,
  event projection normalization, and event-scoped review filtering. It
  composes organizer authority, review presentation, and app-download adapters
  without introducing website booking, checkout, or sign-in state. The route
  uses the shared event-detail primitives for a ticket plus organizer/action
  rail at wide viewports and a single-column, app-aligned stack on mobile;
  shared Catch tokens own its type, color, spacing, radius, and activity accent.
- `website/src/styles/catch-language.css` is the single design-language layer,
  imported in `styles.css` immediately after `base.css`. It owns the motion
  duration/easing tokens, the Archivo `font-stretch: 78%` voice axis, the
  `.catch-kicker`/`.catch-data` helpers, the `.catch-dark` dark-surface
  variable remap (including derived `color-mix` values and focus ring), the
  `[data-activity]` pigment map, and the warm matte photo grade. Route
  stylesheets consume the generated `--catch-*` tokens and these helpers rather
  than re-declaring design values. The former `organizer-public.css` aggregate
  was folded into `home.css`, `organizers.css`, and `flows.css` and deleted.
- Home and Host heroes are dark "wow" surfaces: their shells add `.catch-dark`,
  `SiteHeader` accepts a `tone="dark"` prop so chrome reads correctly over them,
  and hero stages show real app captures in the shared phone-capture frame
  instead of invented product mock panels or metrics. `SiteHeader` also owns
  the mobile menu dialog; its labels arrive via the required `menuCopy` prop
  from `content/site.ts` (`siteMenuCopy`) so shared chrome never imports
  route-specific content.

The next refactor should focus on page and style decomposition, not another
top-level framework rewrite. The largest current files are page or style
aggregation points:

| File | Current role | Refactor pressure |
|---|---|---|
| `website/src/features/home/HomePage.tsx` | Thin home route shell that wires site chrome to `HomePageSections` | Keep route assembly here; move future Home section edits into `features/home/sections/` and only promote neutral, repeated shells to shared UI. |
| `website/src/features/organizers/HostListingPage.tsx` | Thin listing route shell that wires site chrome to `useHostListingPageController` and `HostListingSections` | Keep page-local sections under `features/organizers/sections/`; avoid moving listing-specific blocks into shared UI too early. |
| `website/src/features/host/HostPage.tsx` | Canonical host assembly with core, supporting, and Playbook section imports | Keep the route file as a table of contents; section bodies stay under `features/host/sections/`. |
| `website/src/features/claims/ClaimPage.tsx` | Thin claim route shell using injected `ClaimRouteState`, `useClaimFlowController`, and `ClaimPageSections` | Keep route URL parsing in `features/claims/claimRouting.ts` and the React Router shell; keep auth/submission behavior in the controller; keep visible route sections in `features/claims/sections/`. |
| `website/src/shared/ui/primitives/` | Family-split governed visual primitives used by website feature sections | Keep repeated shell markup in the relevant family module; state, analytics, and domain mapping stay in feature controllers/adapters. |
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

   Static metadata is read from `website/src/content/meta.json`; both the
   client and postbuild readers must pass the same validated contract.

2. Marketing-authored copy belongs to the content layer.

   `web:website-copy-ownership` scans production `.ts` and `.tsx` and blocks
   new visible JSX text (including single-word labels), accessibility copy,
   copy-bearing prop/data literals, and validation/status messages outside
   `website/src/content/**`. The current component copy is recorded as
   migration debt in `tool/web/website_copy_baseline.json`.
   Move entries into direct page-specific content imports and shrink that
   baseline; permanent technical exceptions belong in the reasoned allowlist.
   The gate rejects malformed, duplicate, overlapping, or stale registry
   entries, so completed migration debt cannot remain hidden in an inflated
   baseline and allowlist exceptions cannot survive without a live finding.

   ```sh
   node tool/run.mjs check web:website-copy-ownership
   ```

   Templates use `content/interpolate.ts`. Its runtime contract rejects
   missing, extra, and misspelled tokens and is shared by client metadata and
   Node postbuild validation. Literal templates infer exact token keys at
   compile time; `interpolate.typecheck.ts` proves missing and extra keys fail.
   Copy-bearing template expressions are included in the ownership ratchet.

3. Component ownership follows the route contract.

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
   in `WebsiteQueryProvider` so the workbench matches the runtime root. The
   global Storybook preview now provides that runtime boundary for every story.

   Accessibility runs through the Storybook Vitest addon in Playwright
   Chromium with axe failures blocking by default. Existing visual findings
   are exact, reasoned `todo` entries under `WEB-A11Y-001` in
   `design/website/a11y.todo.json`; the pretypecheck debt scanner rejects new,
   missing, duplicate, or stale annotations. The CI runner therefore blocks
   regressions while allowing the legacy set to shrink without silently
   disabling accessibility analysis.

4. The app shell resolves routes and lifecycle only.

   `App` should choose the route, metadata, page class, page-level captures, and
   shell lifecycle hooks. It should not own page content, feature state, form
   mutation logic, analytics payload assembly, or generated-listing selectors.

5. Page components compose sections; controllers own state.

   Page files should mostly assemble feature sections. Hooks/controllers own URL
   state, forms, local persistence, Firebase calls, analytics side effects, and
   mutation status.

6. Feature folders own domain-specific UI.

   Do not promote a component to shared UI because it is visually reusable once.
   Shared UI is for neutral primitives with stable semantics across multiple
   features. Domain blocks such as listing diagnostics, host product sections,
   claim proof panels, and review lanes stay feature-owned until reuse is real.

7. Interactive controls go through shared primitives.

   Feature, app, and Storybook code must not render raw `<button>`, `<a>`,
   `<input>`, `<select>`, or `<textarea>` elements. Use the website shared UI
   primitives, add a new primitive there when the concept is genuinely missing,
   or add a temporary `react-ui-primitive-allow: <debt-id>` comment with a
   removal plan. The gate is:

   ```sh
   node tool/run.mjs check web:react-ui-primitives
   ```

8. Governed component families and class names go through shared primitives.

   Website and admin code must not hand-roll governed component shells in
   feature, app, or Storybook code. Feature code also must not pass `className`
   directly; class ownership belongs in `website/src/shared/ui`,
   `website/src/shared/site`, or `admin/src/shared/ui`. The class-name gate is:

   ```sh
   node tool/run.mjs check web:react-classname-boundaries
   ```

   The canonical governed-family list is printed on demand by
   `node tool/web/check_react_component_governance.mjs --families-json`. This is a
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

9. Generated data remains explicit.

   `website/src/generated/hostListings.json` is a generated projection. Feature
   code should read it through `features/organizers/data.ts` and typed selectors,
   not directly from pages outside the organizer feature.

10. Metadata and static output stay coupled.

   Client metadata in `pageMeta.ts`, route resolution in `App`, and postbuild
   output in `website/scripts/postbuild.mjs` must stay covered by the route
   contract. Legacy organizer routes must preserve canonical/noindex behavior
   before and after hydration. Firebase Hosting must route `/claim/**` to the
   generated `/claim/index.html` shell so direct claim lookup links do not fall
    through to root metadata.

    Website analytics payloads are also version-coupled to the copy migration:
    `trackMarketingEvent` appends the immutable `website_copy_v2` content
    version, and the pretypecheck analytics contract covers page events plus
    unset, essential-only, and accepted consent presentation states. Both CTA
    wrappers use the same tested `marketingCtaClickParameters` builder, keeping
    the existing `cta_label`/`cta_href` transport exact.

11. Analytics and Firebase boundaries stay centralized.

   Consent, event IDs, attribution, GTM/dataLayer emission, and organizer
   analytics dispatch should go through shared analytics services. Feature
   controllers may decide when a business event happened, but should not
   duplicate low-level analytics mechanics.

12. CSS ownership follows component ownership.

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
  content/
    README.md
    legal.ts
    meta.json
    meta.schema.json
    site.ts
    types.ts
    markets/
      types.ts
      in.ts
      index.ts
  features/
    home/
      HomePage.tsx
      homeContent.ts
      sections/
        HomePageSections.tsx
    host/
      HostPage.tsx
      application/
        HostApplicationFlow.tsx
        applicationModel.ts
        useHostApplicationController.ts
      sections/
        HostPageSections.tsx
        HostSupportingSections.tsx
        PlaybookShowcase.tsx
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
    catch-language.css
    site-shell.css
    site-footer.css
    home.css
    host-foundation.css
    host.css
    organizers.css
    flows.css
    reveal.css
    responsive.css
```

### Import Boundaries

- `app/**` may import feature pages, validated content, route metadata,
  lifecycle hooks, analytics, and generated route contracts.
- `content/**` contains authored data and browser-safe pure contract helpers;
  it may import only other content modules and must not contain JSX or read
  `import.meta.env`. The import-boundary scanner enforces those source rules.
  Route features may read their page-specific content directly; do not add a
  global content barrel that pulls unrelated route copy into lazy chunks.
- `content/site.ts` owns site-wide authored labels such as app-store CTA copy.
  The feature hook owns `import.meta.env` reads and joins destinations to copy;
  environment access never belongs in the content layer.
- `content/legal.json` owns the published `/privacy/`, `/terms/`, and `/help/`
  content plus confirmed operator and grievance facts; `content/legal.ts`
  exposes its typed runtime contract. `content/site.ts` owns the public contact
  destination and site-wide legal footer links. A pretypecheck contract rejects
  placeholders, incomplete sections, or missing route registration.
  Native Settings remains fail-closed: Privacy, Terms, and Help rows render only
  when `CATCH_PRIVACY_POLICY_URL`, `CATCH_TERMS_URL`, and `CATCH_HELP_URL`
  contain valid owner-approved destinations. Privacy and Terms are separate
  documents and must never alias the same route.
- `content/markets/index.ts` selects the active market pack. City lists,
  currency, geo-adaptive labels, India-specific comparison columns, and example
  event name/venue/city/currency belong in that pack rather than page or
  shared-UI modules. Host create-flow fixtures and application defaults read
  those values through `@content/markets`.
- Market cities are structured by stable id, slug, aliases, IANA timezone, and
  `live`/`waitlist` status. Country/store availability, locale, ISO currency,
  and featured city are pack-level contracts; event-live and form options are
  derived from the city records rather than parallel city lists.
  `check:market-pack` validates references and formatting; Home eligibility
  resolves generated listing labels/aliases back to city ids.
- Feature pages may import their own feature modules, `shared/**`, and explicitly
  named cross-feature controllers only when the product flow requires it.
- `features/claims/**` may depend on organizer listing models because the claim
  flow selects an organizer.
- `features/events/**` may depend on organizer listing policy and models,
  review presentation, and marketing app-download adapters because event
  details inherit organizer authority while keeping registration source-aware.
- `features/organizers/**` may depend on claim and review controllers for the
  listing page, and on the event projection for event-card deep links and the
  executable public-surface behavior harness, until those panels move behind
  local adapter components.
- `shared/**` must not import from `features/**` or route-specific `content/**`.
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
   deliberate exception has an owner, expiry, and removal plan.

10. Keep React primitive enforcement active.

   Website and admin code now share the first React UI primitive scanner:
   `node tool/run.mjs check web:react-ui-primitives`. Expand it before adding
   new local button/link/input/select/textarea variants in feature code.

11. Keep React component-family enforcement active.

   Website and admin code share `node tool/run.mjs check web:react-classname-boundaries` plus `node tool/run.mjs check web:react-component-governance`. The class-name scanner blocks feature/app/story `className` usage outside shared primitive owner files. The component scanner emits its current family view on demand with `node tool/web/check_react_component_governance.mjs --families-json`; no generated family snapshot is tracked. This is a known-family blocklist: passing it does not classify novel shells, so repeated new component drift must become a scanner family before handoff.

12. Keep cross-surface primitive decisions classified.

   Run `node tool/run.mjs check web:shared-ui-adoption`. The tracker
   distinguishes adopted package semantics from deliberate surface-specific
   families; package exports, exact-name cross-app overlap, and adopted
   adapters cannot drift outside that decision record.

13. Keep controller behavior-test targets explicit.

   `tool/web/react_controller_test_targets.json` classifies every marketing and
   admin feature controller/mutation hook. Run `node tool/run.mjs check
   web:react-controller-test-targets`; required targets need named importing
   behavior suites, while aggregate coverage remains an informational report.

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

## Workflow-led marketing consolidation

The canonical implementation is the existing React application in `website/`,
on `codex/marketing-foundation-content-20260930`, based on `e16429978bee48b9e193dc9a17d732f703e69033`.
The reference source is the clean `feat/host-site-redesign` worktree at
`1d1508fbf783f427a863c640ee38be8736e69db8`, in
`website/research-preview/host-redesign/`. That source/history stays intact;
no static CSS, token namespace, imperative script or backend endpoint is promoted.

`content/prototypeContent.ts` preserves all nine source pages, 49 sections,
681 exact original text nodes and per-file SHA-256 provenance. Original wording
is reference-only. Display projections retain every unique concern with explicit
concept notices, readable bodies, FAQ answers and capability lists.
`features/host/concepts/HostConceptPage.tsx` composes those projections using
the existing site shell, responsive section/grid/action/choice/field/disclosure
owners. Persona views change content, never domain authority or data providers.
`content/hostConceptNavigation.ts` owns destinations; prototype filenames are
mapped to canonical routes and valid anchors. Source dead sample anchors are not
invented as real event links. Source `#waitlist` now points to the existing home
waitlist; directory GET search opens the real `/organizers/?q=...` owner.

`features/host/HostContentReview.tsx` now also owns `/host/workflows/`.
Its proposed order is recognisable problem → concrete workflow → independent
application/membership/eligibility/payment/admission decisions → shared
capabilities → supported first step and data boundary → guided contact action.
All examples remain fictional. Afterfly-like membership approval is distinct
from event eligibility; weddings have a household/function story, not a forced
community admission funnel. Current live Host content, consumer root and all
transactional owners remain available. There is no universal pricing tariff or
unverified customer proof.

### Complete route and interaction parity

| Prototype source | Canonical route / owner | Content and interaction treatment |
|---|---|---|
| `index.html` | `/host/overview/` · HostConceptPage | Consumer/social opener, sample events, organiser entrances, cumulative adoption story and claim pressure retained as concepts. One shared fictional console replay; original consumer content and waitlist remain owned by `/explore/` in the local organiser-first review. |
| `host.html` | `/host/platform/` · HostConceptPage | Booking coexistence, all capability groups, Programs, pilot, FAQ retained. Shared tier selection and stack model; native FAQ disclosure. |
| `planners.html` | `/host/planners/` · same composition | Run-of-show, household/functions, travel/logistics, lifecycle messages, hands-on pilot and FAQ. Availability and enrichment claims remain illustrative. |
| `mixers.html` | `/host/mixers/` · same composition | Promotion attribution, pricing/admission concepts, revenue, first-ten-minutes tools, community, pilot and FAQ. No new demographic authority or tariff. |
| `clubs.html` | `/host/clubs/` · same composition | Application, review, repeat records, live coordination, payment and community concepts. No inference that attendance establishes durable membership. |
| `directory.html` | `/host/directory/` + `/organizers/` | All six fictional samples/statuses retained separately from real listings. Shared search field/GET form forwards to existing directory controller, preserving low-friction public entry. |
| `claim.html` | `/host/claim/` + `/claim/` | All explanatory/state examples retained. Existing claim controller owns identity, proof, pending/frozen requests and actual submit. No authentication-to-ownership shortcut. |
| `apply.html` | `/host/apply/` + `/host/#founding-hosts` | Authored concerns/stages retained. Source has an explicit form mount, not submission code; handoff reuses canonical five-stage intake/validation. Walkthrough contact remains separate from intake. |
| `stack.html`, `stack-data.js` | `/host/stack/` + platform embed | All 37 tools/8 groups, filter, selection, receipt totals/details and tier precedence retained in one pure model/content owner. Program > no-platform or three replacement groups > alongside. Network suffix illustrative. No connection, purchase or import created. |
| `concept.js` tiers | prototypePresentationModel + shared choice controls | Three selectable adoption levels; synchronized model indices, native keyboard buttons, fine-pointer hover, pinned manual choice and 4.2s hidden/reduced-motion-safe rotation. Ring styling is not duplicated. |
| `concept.js` console | same presentation model + fictional fixtures | 1.6s progressive rows, check-in tally, source replay reset semantics, hidden pause, immediate reduced-motion rows; added explicit pause/replay controls. No production data. |
| source native FAQ / reveal / navigation | existing FAQ/site/lifecycle owners | Native keyboard disclosures (first item open), canonical responsive mobile menu and existing reduced-motion reveal/focus behavior. Source lacked a mobile menu; no duplicate imperative handlers. |

All new concept routes have centralized metadata, self-canonical static outputs,
Hosting rewrites and `noindex, follow`; content claims and route retirement are
still owner decisions. No deploy occurred. Existing analytics/consent and private
route exclusions remain canonical; new public concept navigation has ordinary
route analytics only if existing consent permits it. Sensitive credentials and
synthetic tool selections are not forwarded as lead data.

### Source section ledger

Every row below is a retained React section ID; interactive tier content is
reachable through native choices rather than always expanded. Source hashes and
exact wording are in the typed catalog, not generated contract files.

| Source file / section | Canonical destination | Preserved concern |
|---|---|---|
| `index.html#section-1` | `/host/overview/#section-1` | The room before the match. |
| `index.html#section-2` | `/host/overview/#section-2` | Happening on Catch. |
| `index.html#section-3` | `/host/overview/#section-3` | Built around the way you host. |
| `index.html#section-4` | `/host/overview/#section-4` | One system. Three levels of commitment. |
| `index.html#section-5` | `/host/overview/#section-5` | Your organizer page may already exist. |
| `index.html#attend` | `/host/overview/#attend` | Here for the events, not the tooling? |
| `host.html#section-1` | `/host/platform/#section-1` | Your booking tool stops at the sale. That's where we start. |
| `host.html#tiers` | `/host/platform/#tiers` | Every feature is honest about what it needs. |
| `host.html#section-3` | `/host/platform/#section-3` | Grouped by the job it does. |
| `host.html#section-4` | `/host/platform/#section-4` | Tell us your pile. We'll tell you the fit. |
| `host.html#section-5` | `/host/platform/#section-5` | Your organizer page may already exist. |
| `host.html#pilot` | `/host/platform/#pilot` | Pilot Catch on your next event. |
| `host.html#section-7` | `/host/platform/#section-7` | Fair questions. |
| `planners.html#section-1` | `/host/planners/#section-1` | The run of show is not a spreadsheet of spreadsheets. |
| `planners.html#section-2` | `/host/planners/#section-2` | One record from save-the-date to departure. |
| `planners.html#logistics` | `/host/planners/#logistics` | The logistics layer. |
| `planners.html#section-4` | `/host/planners/#section-4` | Every message has a place in the timeline. |
| `planners.html#section-5` | `/host/planners/#section-5` | We run the first one with you. |
| `planners.html#section-6` | `/host/planners/#section-6` | Fair questions. |
| `mixers.html#section-1` | `/host/mixers/#section-1` | Fill the room. Balance the room. Get paid for both. |
| `mixers.html#demand` | `/host/mixers/#demand` | Know which promotion actually worked. |
| `mixers.html#section-3` | `/host/mixers/#section-3` | A balanced room is a pricing feature, not a compromise. |
| `mixers.html#section-4` | `/host/mixers/#section-4` | Revenue you can actually read. |
| `mixers.html#section-5` | `/host/mixers/#section-5` | The first ten minutes decide the event. |
| `mixers.html#section-6` | `/host/mixers/#section-6` | Events that build your audience, not just fill it. |
| `mixers.html#pilot` | `/host/mixers/#pilot` | Pilot Catch on your next event. |
| `mixers.html#section-8` | `/host/mixers/#section-8` | Fair questions. |
| `clubs.html#section-1` | `/host/clubs/#section-1` | The weekly event, without the weekly scramble. |
| `clubs.html#section-2` | `/host/clubs/#section-2` | The ops that repeat, automated. |
| `clubs.html#live` | `/host/clubs/#live` | Pairings and pace groups, settled before the warm-up ends. |
| `clubs.html#section-4` | `/host/clubs/#section-4` | An attendance record that becomes a community. |
| `clubs.html#pilot` | `/host/clubs/#pilot` | Pilot Catch on your next event. |
| `clubs.html#section-6` | `/host/clubs/#section-6` | Fair questions. |
| `directory.html#section-1` | `/host/directory/#section-1` | Organizers already on the record. |
| `directory.html#section-2` | `/host/directory/#section-2` | Find your page. |
| `directory.html#section-3` | `/host/directory/#section-3` | Prototype content |
| `claim.html#section-1` | `/host/claim/#section-1` | This page is yours. Prove it. |
| `claim.html#how` | `/host/claim/#how` | Three steps. One review. |
| `claim.html#section-3` | `/host/claim/#section-3` | Your page, working for you. |
| `claim.html#section-4` | `/host/claim/#section-4` | Where a claim can land. |
| `claim.html#section-5` | `/host/claim/#section-5` | Found your page? Start there. |
| `claim.html#section-6` | `/host/claim/#section-6` | Fair questions. |
| `apply.html#section-1` | `/host/apply/#section-1` | Request a free pilot. |
| `apply.html#section-2` | `/host/apply/#section-2` | Five quick steps. |
| `apply.html#section-3` | `/host/apply/#section-3` | Application in. |
| `stack.html#section-1` | `/host/stack/#section-1` | Map your stack. Keep what works. |
| `stack.html#section-2` | `/host/stack/#section-2` | What do you run today? |
| `stack.html#section-3` | `/host/stack/#section-3` | Five fractures every duct-taped stack shares. |
| `stack.html#section-4` | `/host/stack/#section-4` | Bring the pile. We'll map it on the call. |

### Existing application parity retained

| Existing route family | Canonical source and preserved behavior |
|---|---|
| `/` | HomePage: organiser-first content, four product/solution groupings, reused discovery and truthful claim/walkthrough actions. |
| `/explore/` | VisitorDiscoveryPage: original consumer copy/discovery, download pending state, waitlist and consent; no retirement. |
| `/host/` (legacy preview redirects) | HostPage: supported live workflow, setup/playbook/comparison/trust/FAQ, beta offer and existing five-stage application controller; unchanged contracts. |
| `/organizers/`, generated organiser canonical/legacy paths | Directory/search/listing controllers, generated publication policy, filters/empty/loading states, corrections/reviews and provenance retained. |
| `/claim/`, `/claim/:listing` | Claim route resolution, Google identity/existing shared Auth session, proof/submission/pending protection retained; claim approval is privileged and scoped. |
| `/events/:eventId`, `/booking/:eventId`, `/offer/` | Event content, external source handoff, phone OTP, exact quote/payment/admission/recovery and private approved-application offer authority unchanged. |
| `/f/:publicFormId` | Public projection, policy-specific anonymous/verified entry, version-bound draft, local answer retention, files, review, idempotent submission/withdrawal/attribution retained. |
| `/join/:publicRuntimeId`, `/event-update/:linkId`, `/invite/:inviteToken` | Existing roster-bound guest runtime, bearer-scoped assistance, opaque invitation resolver and analytics exclusions retained. |
| `/rsvp/:householdToken`, `/rehearse/:publicRehearsalId`, `/demo/:invitationId` | Household/function scopes, synthetic rehearsal boundary and private sales demo retained. |
| `/privacy/`, `/terms/`, `/help/`, unknown routes | Published legal/help bodies, metadata/static output and actual 404 policy retained; no prototype legal text replaces approved content. |

### Shared platform boundaries

Marketing and admin already use React 19, TypeScript 6, Vite, TanStack Query,
Firebase, generated Catch tokens and `@catch/web-ui`. Their step rails now consume
the same `ButtonControl` non-submitting/disabled semantics, retaining surface
callbacks/classes and selected `aria-current="step"`. Existing package controls
own fields, toggles, tables, badges and empty states. Marketing `<dl>` facts,
admin operational summaries, pending-operation leases and domain validation
remain surface-owned because their contracts differ. No privileged admin imports
enter the public bundle, and no new Firebase/callable/repository tier is added.

Identity/claim/provider configuration inventory and public event dual-entry
boundaries are maintained in `docs/web_surface_architecture.md`. A shared Firebase
project is not proof of cross-origin sessions, linked providers, organiser
ownership or global roles. Public form entry remains low friction according to
its actual identity policy; existing required OTP boundaries remain unchanged.

### Remaining product and authority decisions

The organiser-first root is approved for this local review; publication remains pending user review. Content retirement, commercial tier availability, universal tariff, direct integration claims, customer proof and broad programme launch remain unapproved. Preserve source copy for review. Basic forms, member
approval, CRM history, QR and referral/UTM features must not be called unique
without competitive proof; workflow/operational differences need reachable
end-to-end evidence. Conditional pricing or network concepts never override
server authority. The migration adds presentation and honest local demos, not
missing network/account/permission/payment products.

## Open Decisions

- Decide whether the mixed organizer canonical route family should be preserved
  short term or migrated toward city-scoped canonical paths only.
- Static marketing-authored content uses typed TypeScript modules or validated
  JSON under `website/src/content/**`. Metadata is the first migrated owner;
  visible page-copy extraction remains incremental and must preserve route lazy
  loading through direct page-specific imports. A CMS remains deferred until a
  real non-engineering publishing workflow is approved.
- Decide which route review states are required for launch versus acceptable as
  manual review notes.
- Decide whether React Hook Form is worth adding during a specific long-form
  refactor after routing and server-state conventions are in place.
