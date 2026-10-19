---
doc_id: nextjs_website_implementation_spec
version: 0.1.0
updated: 2026-10-19
owner: marketing_website
status: proposed
---

# Next.js public website implementation

This is the bounded Group A implementation proposal, not a second permanent
architecture owner. On completion, reconcile the implemented decisions into
`docs/marketing_website_architecture.md` and `docs/web_surface_architecture.md`
and retire this proposal. The approved [decision brief](https://chatgpt.com/space/page_4d48e536e9908191b1ba53c6c47a6e38)
separates website delivery from Groups B–G. Implementation is authorized;
production cutover, new infrastructure spending and provider activation are not.

## Outcome and exclusions

Deliver the existing `catchdates.com` website through Next.js App Router,
TypeScript and React. Public pages must provide useful initial HTML, correct
metadata/statuses and current publication authorization. Retain Firestore,
existing Functions, Flutter, public content, visual identity, responsive
layouts and legitimate interactions. Preserve the existing `app.catchdates.com`
and `admin.catchdates.com` destinations and `.well-known` app associations.

Exclude PostgreSQL, general backend rewrites, new attendance/check-in/private
catch journeys, Host/admin rebuilds, payment-rule changes, new advertising
programs, new commercial promises and CMS adoption. Existing browser attendance,
forms, booking and OTP routes already in the repository must continue working;
retaining them does not decide broader browser/native product scope.

## Source baseline and implementation state

Inspected base: `954e09ffa6619161e9b1ea6fe86533c880c42460` on fetched
`origin/main`. All target behavior below is proposed until verified in code.
No Next.js runtime, infrastructure or production cutover is established by this
document. The isolated branch is `codex/nextjs-public-website`. The first source
module, `website/src/server/publicReadPolicy.ts`, implements publication gates,
bounded IDs/organizer paths and safe JSON-LD/HTTPS serialization policy. It is
not yet connected to a runtime data adapter or page; policy tests alone do not
establish server-rendered access isolation.

Source owners: `website/src/app/routeRegistry.ts`, `website/src/app/App.tsx`,
`design/website/routes.json`, `design/website/components.json`,
`website/src/content/meta.json`, `website/scripts/postbuild.mjs`,
`website/scripts/generateOrganizerListings.mjs`,
`website/src/features/organizers/publicCatchEventProjection.ts`,
`website/src/features/organizers/organizerPolicy.ts`,
`website/src/features/events/eventDetailModel.ts`,
`contracts/public/website_host_listing_projection.schema.json`, and the two
owning web architecture documents.

The baseline uses Vite, React Router, TanStack Query and Firebase Hosting.
Postbuild already supplies selected public HTML. Do not describe every existing
route as an empty SPA. Organizer records are materialized at deployment;
`features/organizers/data.ts` explicitly strips Catch event snapshots. Catch
events are instead read through a published-only Firestore subscription, bounded
at 401 documents, with cache/pending snapshots withheld and more than 400 rows
treated as unavailable. A stale build snapshot must not become event authority.

## Route inventory and target behavior

Definitions: **static** means authored content rendered at build; **live** means
request-time, uncached public projection; **private shell** means generic HTML
and existing browser-authenticated/callable behavior, never private SSR data.
Canonical origin is configured, never derived from an untrusted Host header.
Preserve trailing-slash canonical paths and query parameters on navigation.
All private shells are noindex and excluded from sitemap. Noindex is not access
control. Private identifiers never enter canonical, social metadata or JSON-LD.

| Existing URL / contract | Before | Target rendering and source | Auth, status, canonical and handoff |
|---|---|---|---|
| `/` (`home`) | Postbuild plus React home | Static existing organizer-first content; server-render current sections/chrome | Public 200, self canonical, indexed; Host, discovery, claim links retained |
| `/explore/` (`visitor_discovery`) | Postbuild plus live browser event feed | Static copy with live eligible Catch event projection; request-render route containing inventory | Public 200, self canonical, indexed; existing store availability, waitlist, filters and app handoffs |
| `/host/` | Postbuild plus React product page | Static existing product sections, capture assets, pricing/access copy and anchors | Public 200, self canonical, indexed; existing pilot/application and external-tool boundaries |
| `/host/apply/` | Postbuild application shell | Server-render initial five-stage form; existing client controller and HTTP contract | Public shell 200, self canonical, noindex; submission grants no workspace |
| `/organizers/` | Postbuild plus browser search | Live public organizer projection with server-rendered initial directory; client URL filters | Public 200, self canonical, noindex retained; no private follower/account data |
| Organizer `publicPage.canonicalPath` | Generated profile HTML plus React | Live filtered organizer and event content; existing profile sections | Public 200 only when authorized; record canonical and index policy; claim/review/follow actions retain current capability gates |
| Organizer `legacyPaths[]` | Generated duplicate body with noindex/canonical | Same live authorization/body initially, retaining alias contract | 200, noindex, canonical record path; never turn a hidden organizer into a redirect oracle |
| `/events/:eventId/` | Generated external evidence plus live browser Catch events | Live event plus live organizer authorization; substantive initial event HTML | Public 200 only when authorized; canonical event URL, existing index policy; native app, external source, free OTP or paid booking handoff from existing policy |
| `/claim/` | Postbuild and interactive flow | Static guidance plus client existing claim workflow | 200, noindex, self canonical; query `listing` retained; submission requires existing auth/App Check and never confers ownership |
| `/claim/:listing/` | Hosting rewrite to claim shell | Generic SSR guidance and existing lookup controller | 200 shell, noindex, canonical `/claim/`; not-found/already-claimed/pending/unavailable remain domain states |
| `/privacy/` | Published legal content/postbuild | Static exact `content/legal.json` content | Public 200, self canonical, indexed; no edits to legal assertions |
| `/terms/` | Published legal content/postbuild | Static exact legal content | Public 200, self canonical, indexed |
| `/help/` | Published help content/postbuild | Static exact support content | Public 200, self canonical, indexed; operator/contact links retained |
| `/join/:publicRuntimeId/` | Client dynamic runtime | Private shell and existing runtime controller | 200 generic shell; noindex; OTP/imported-roster/Host approval unchanged; no roster SSR |
| `/event-update/:linkId/` | Client dynamic assistance | Private shell; fragment credential parsed only in browser | 200 generic shell; noindex, generic canonical `/event-update/`; no marketing analytics or token forwarding |
| `/rehearse/:publicRehearsalId/` | Synthetic rehearsal client | Private shell and unchanged synthetic guest-slot logic | 200 shell, noindex; no production event access or new OTP requirement |
| `/invite/:inviteToken/` | Opaque invitation resolver | Private shell and existing bounded callable handoff | 200 shell, noindex; generic canonical; private invitation never appears in discovery |
| `/rsvp/:householdToken/` | Signed household RSVP client | Private shell and unchanged scoped callable | 200 shell, noindex, canonical `/rsvp/`; signed credential never in SSR props or telemetry |
| `/f/:publicFormId/` | Public respondent client | Generic form shell and existing sanitized version/identity workflow | 200 shell, noindex; immutable version, autosave, review, withdrawal, iframe and payment returns retained |
| `/offer/` | Private offer shell | Private shell; current credential capture/history cleanup | 200, noindex, canonical `/offer/`; phone verification/payment grants remain backend-owned |
| `/booking/:eventId/` | Booking management client | Private shell and existing authenticated booking controller | 200 shell, noindex, canonical `/booking/`; payment/refund/return behavior unchanged |
| `/demo/:invitationId/` | Private sales preview | Private shell and existing callable | 200 shell, noindex, canonical `/demo/`; synthetic-only and existing analytics exclusion |
| `/404/` and unknown URLs | Custom Hosting 404; React fallback | Next not-found route with existing presentation | Actual 404; noindex; no unknown-path 200 fallback |

Static legal route wildcards in the old client router must not broaden the
public contract: unknown children return 404 unless a documented Hosting
redirect already resolves them. Validate the exact deployed behavior before
changing a known alias. Malformed percent encodings and invalid event IDs fail
closed; they must not trigger arbitrary document reads.

Preserve every registered permanent redirect: `/host/preview{,/**}` to
`/host/`; `/host/overview{,/**}` to `/`; `/host/platform{,/**}` to
`/host/#features`; `/host/workflows{,/**}` to `/host/#how-it-works`;
`/host/{planners,mixers,clubs}{,/**}` to `/host/#use-cases`;
`/host/stack{,/**}` to `/host/#existing-tools`; `/host/directory{,/**}` to
`/organizers/`; `/host/claim{,/**}` to `/claim/`. Keep their contracted 301
status rather than silently replacing it with Next's default permanent 308.
Query strings must precede destination fragments. Preserve the existing
`/host/#founding-hosts` application compatibility behavior.

## Public reads and serialization boundary

Use a small `server-only` data-access module. No Admin SDK import may enter a
client dependency graph. Request parameters select a bounded route, not a
collection name, arbitrary URL or Firestore path. Use explicit collection,
document-ID, field-selection and result-count constraints. Do not forward
cookies, Authorization, App Check tokens or viewer identity into public reads.

The first reference route is an organizer profile, followed by a Catch event.
Before reading renderable rich fields, require a published, non-demo,
non-archived, non-suppressed organizer in a configured live market. Validate
canonical/legacy paths and the existing readiness/capability contract. Unknown
or malformed authority denies publication. `qa`, synthetic and `catchDemo`
records are permitted only in explicit local test fixtures, never as production
fallback. Event reads additionally require explicit `publicationState` equal
to `published`, `status` equal to `active`, valid organizer identity and a
currently readable organizer. No legacy missing-publication shortcut.

Admin SDK bypasses Firestore client rules. Therefore these checks run on every
server read; a successful Admin read is not publication authorization. Grant
the runtime read-only IAM, not deployment/write authority. IAM alone is not a
field filter. Prefer extracting the existing pure organizer projector from the
CLI into an importable leaf, with parity tests, instead of importing a module
whose initialization reads build files or exits the process.

Output allowlist (construct new objects; never spread raw database records):

| DTO | Permitted data |
|---|---|
| Organizer | Public ID/name/slug, canonical/legacy paths, live city/region/country labels, category, headline/description/source summary, public logo presentation, formats/facts, curated public event evidence, fit/missing-evidence notes, sanitized public source links, claim link/label, public capability/authority projection, public verification date and search text |
| Event | Public ID/organizer ID, title/activity, summary, public approved artwork, start/end/timezone/formatted date, published venue/itinerary fields validated by existing schemas, requirements/accessibility, price label/amount/currency, capacity totals and registration-mode hints already in the public event contract |
| Reviews | Only existing published, capability-authorized public review projection; no review drafts, reporter identifiers, moderation notes or private contact data |
| Metadata | Public title/description/canonical, approved image, public event dates/location/organizer and truthful breadcrumb/Organization/Event facts |

Nested objects must also be reconstructed or validated against schemas that
reject additional properties. In particular, do not serialize raw `ownership`,
`claim`, `provenance`, media objects or entire `publicProfile` objects. The
existing listing schema is the compatibility envelope, not authorization to
populate every optional field. Exclude owner/member UID arrays, phone/email,
private catches, attendees, registration answers, payment/customer credentials,
admin notes, tokens, storage metadata, unpublished media and source snapshots.
Server errors/logs include coarse operation/error class and a request ID only.
Never log the raw document, full request URL, query, private route identifier or
upstream response body. Hosting request-log treatment for signed path-token
routes is a release acceptance item because application log filtering alone
does not remove infrastructure access logs.

Existing callable/HTTP mutations remain authoritative and retain their Auth,
App Check, validation, consent and idempotency behavior. No new Server Actions
for bookings, claims or forms. A narrow public read endpoint is allowed only if
needed to serve the same safe DTO to existing client refresh behavior; it must
use the same authorization/projector, not create a second policy.

## Rendering, freshness and failures

Authored-only marketing/legal content can be prerendered. Any page that embeds
mutable organizer/event data is dynamically rendered, with no Full Route Cache,
Data Cache or CDN caching of its HTML/RSC/data response. Per-request deduplication
may share one validated read between metadata and body. Do not use a global Map
or stale-while-revalidate for publication decisions. Immutable hashed static
assets remain cacheable. No public page changes based on a viewer session.

Publication/edit/withdrawal target: a request whose authoritative read begins
after the Firestore commit must use that state; no intentionally stale response
is served. In-flight reads may reflect their prior snapshot. A rendered page
already on a screen cannot be recalled: client refresh must clear withheld data
and recheck on focus and at most every 30 seconds while visible, with a testable
expiry that prevents indefinite display after network failure. Never treat
already downloaded assets as retractable. Transaction-time price/capacity
validation remains in existing backend commands.

For live routes, missing/unauthorized/withdrawn records return the same 404.
Unavailable upstreams return a generic 503 (or explicitly tested framework
error response if a route cannot preserve 503), never a false not-found or a
successful stale snapshot. Resolve authorization before streaming commits
headers; verify the actual production status because a streamed not-found can
otherwise retain 200. Avoid loading boundaries above the publication decision.
Do not rebuild a sitemap from committed organizer JSON in production. Sitemap
entries must pass current public and indexing policy, be bounded/paginated, and
use real modification dates only. Preview/staging robots disallow indexing and
responses carry noindex; public crawlers remain allowed according to current
production robots policy.

## Runtime and delivery design

Candidate runtime: Next.js 16.4.2 (current official docs on 19 October 2026),
App Router, Node 24 as pinned by `tool/ci/toolchain.env`, existing React 19 and
TypeScript 6 subject to verified peer/build compatibility. Pin the tested
package version and root lockfile; do not claim compatibility from version
labels. Keep Storybook/Vitest tooling independently usable.

Prepare a standalone Node container, with monorepo tracing root and required
public/static assets included. Proposed hosting is a versioned Cloud Run
service behind the existing Firebase Hosting marketing target. It supports
dynamic rendering without migrating domains or buying another platform. Actual
service creation/cost limits require the final infrastructure review. Do not
activate Firebase framework-aware preview tooling or replace the current live
static deployment implicitly. Firebase App Hosting is an alternative, not a
second simultaneous deployment target.

Retain existing API rewrites, Firebase Auth helper routes, custom form-domain
resolution and app association files ahead of the website fallback. Validate
Cloud Run region support for the selected Hosting integration. Prepare a
separate preview configuration so committing Next.js work cannot automatically
send main-branch production traffic to an unaccepted runtime. Current marketing
workflow auto-deploy behavior must be adjusted deliberately before merge.

Public browser configuration uses an explicit allowlist. Map existing
`VITE_*` public inputs to validated Next public/runtime config; do not expose
all environment variables. ADC/service identity stays server-only. Production
must reject dev-project fallback and missing App Check/store-link configuration.
Staging must use its own Firebase identity/data and origin approvals; a
preview hostname does not imply Firebase Auth/App Check/payment compatibility.
Do not commit credential JSON. Separate build, read-only runtime and promoter
identities. Bind the build to a commit/image digest and environment manifest.

Verification starts with a production-mode local standalone process and
Firestore emulator/controlled fixture adapter. Fixture mode must be impossible
in production config. Deploy an existing authorized preview only when available;
otherwise report the exact missing project/service/identity/permission. Local
production-mode tests are not deployed acceptance. Production release needs
an accepted preview, named operations owner, reviewed service budget/region,
auth/provider origin checks and explicit user cutover approval.

Rollback switches Hosting to the previously retained static release or accepted
Cloud Run revision with its matching assets; never rebuild from moving main.
Retain the previous Hosting version, image digest and environment inputs before
promotion. No database rollback is needed because Group A changes no database
authority or business writes. Smoke-test status/canonicals, APIs, deep links,
auth and booking returns after either promotion or rollback.

Framework/platform basis: [Next self hosting](https://nextjs.org/docs/app/guides/self-hosting),
[standalone output](https://nextjs.org/docs/app/api-reference/config/next-config-js/output),
[server data security](https://nextjs.org/docs/app/guides/data-security),
[redirect status behavior](https://nextjs.org/docs/app/api-reference/config/next-config-js/redirects),
and [Firebase Hosting with Cloud Run](https://firebase.google.com/docs/hosting/cloud-run).
These describe supported mechanisms, not Catch's deployed configuration.

## Client migration and experience

Next route modules own metadata, path resolution, public reads and error/status
decisions. Reuse feature composition, authored content, tokens, shared primitives
and CSS. Move browser-only behavior into explicit client boundaries. Replace
Vite-only `import.meta.glob` route recovery and environment access with supported
Next equivalents; don't wrap the entire BrowserRouter SPA in one client-only
page and call that SSR. Keep TanStack Query for actual browser remote state and
mutations, scoped per browser/session. A server QueryClient must never be a
process singleton holding user state.

Preserve form drafts and pending-request navigation locks, same-tick duplicate
guards, validation, success/error/retry states, phone OTP, popup/redirect return
paths, App Check and existing storage semantics. Do not invent shared sessions
across subdomains. Preserve permitted attribution parameters and consent gates;
exclude private-route IDs/credentials from marketing lifecycle events. Keep
iframe resize/origin validation and custom-domain fail-closed behavior. Existing
optional permissions remain unchecked and independent of registration.

SSR content must remain visible without reveal-animation JavaScript. Match
desktop/mobile layouts using current screenshots and governed components.
Keyboard navigation, focus after routing/errors, labels, semantic landmarks,
contrast, reduced motion, touch targets and form pending states must be tested.
Provisional launch budgets: LCP <= 2.5 s, CLS <= 0.1 and INP <= 200 ms under
documented representative conditions; report measurements and their limitations.
Do not claim laboratory INP as field evidence. Initial route JS must not grow
beyond measured Vite baseline without explaining the functional cost. Lazy-load
auth/payment SDKs and private routes; no generated directory dump in every page.

## Work packages and acceptance

1. **A1 — Reference and contracts.** Reconcile source ownership; update route
   contracts first. Extract safe organizer projection; add one Next profile
   route with live Firestore read, canonical/social/structured metadata, real
   404/503 behavior and production runtime. Prove private/suppressed fixtures
   cannot appear in HTML/RSC/metadata, then add Catch event parity.
2. **A2 — Complete route inventory.** Migrate static pages, directory/discovery,
   all public profiles/events, shared chrome and retained private shells.
   Preserve every existing action and redirect. Eliminate competing public
   entrypoints from the deployable artifact while keeping a rollback release.
3. **A3 — Operational correctness.** Complete sitemap/robots/sharing, uncached
   publication lifecycle, client expiry, environment validation, CSP/iframe and
   provider handoffs, accessible responsive behavior and CI deployment wiring.
4. **A4 — Release candidate.** Run production build/runtime acceptance and
   browser tests, publish the exact commit/draft PR, validate an available
   preview, and prepare reviewed deployment/rollback inputs. Keep production
   traffic unchanged until explicit final approval.

Required acceptance scenarios:

- Request every inventoried route without JS; assert substantive intended
  public headings/body, title/description/canonical/robots and valid escaped
  JSON-LD. Verify no fabricated rating, price, availability or organizer claim.
- Test canonical/legacy/retired URLs with and without slash, query and fragment;
  exact HTTP status/Location; no duplicate indexable entrypoints.
- Publish, edit, unpublish, suppress, archive and remove fixtures across repeated
  HTML/RSC/data requests and two runtime instances. Verify cache headers,
  no cross-user leakage, no stale success on upstream failure, and visible-page
  refresh expiry. Test malformed nested fields and accidental secret sentinels.
- Inspect client bundles, serialized responses, metadata, JSON-LD and captured
  application logs for seeded private fields and server credentials.
- Exercise existing free/paid entry, booking return, refund-status view,
  external/native handoff, claim, waitlist, pilot application, forms and iframe
  with controlled provider fixtures. Real OTP/payment/provider proof remains a
  separate deployment acceptance item; mocks cannot certify live providers.
- Browser tests at mobile/desktop sizes, keyboard-only operation, back/forward,
  hash anchors, query filters, pending mutation locks, refresh, slow/offline and
  error recovery; axe and current visual baselines remain enforced.
- Build and run the standalone artifact, not only `next dev`. Assert no source
  checkout or omitted monorepo dependency is needed at runtime.

Derive final gates from the actual diff with
`node tool/harness/verify_local.mjs --base origin/main --list`. Run selected
registered checks through `node tool/run.mjs check`, including route/component,
copy/import/React boundaries, metadata, focused projector/runtime tests,
typecheck, build, Storybook/a11y/visual and deployment contract checks as
selected. Backend changes require their owning contract/function checks. Do not
waive scanners because their old implementation assumed Vite: update their
contract and known-bad tests together. Store run output in ignored artifacts/CI,
not a tracked evidence registry.

## Ownership dependencies and handoff

The guard currently permits this proposal path only. Source expansion requires
coordination with `admin-route-consolidation-20261018` (website package/shared
configuration and root lockfile), `xf-react-inventory-7d` (route/components,
architecture docs and marketing workflow), and any other exact file owner found
when expanding scope. Broad `website` ownership also overlaps research-preview
work that this task does not need; use exact paths rather than taking it over.
Do not clear another task's claims, copy its dirty files, or infer retirement
permission from age or merge status. Update this section when the handoff is
resolved, rather than leaving a permanent execution ledger.

Accountable implementation owner: this Next.js task. Existing claim owners
approve their path disposition; the merge-queue owner controls serial admission.
The user/operations owner reviews live cutover and provider/infrastructure
activation. Preserve coherent commits remotely and keep the guarded worktree
until accepted retirement. Report source, checks, exact-head CI, preview,
production and pending decisions independently.
