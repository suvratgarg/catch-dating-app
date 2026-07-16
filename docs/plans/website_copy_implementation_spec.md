# Marketing Website Copy v2 — Implementation Spec (for Codex)

Status: implemented locally; owner-gated destinations/entitlements remain dormant · 2026-07-12
Copy source of truth: [`docs/plans/website_copy_deck.md`](website_copy_deck.md) ("the deck")
Surface: `website/` (Vite + React, Firebase Hosting target `marketing`, catchdates.com)

This spec is self-contained on *structure*: every file, export, component
change, route change, and verification gate is defined here. String *values*
are transcribed verbatim from the deck at the sections referenced in the
mapping tables — do not paraphrase, do not "improve" copy, do not invent
strings. Where a string is missing from the deck, stop and flag it; do not
write copy.

---

## 0. Goals and non-goals

Goals:
1. Every user-visible string on the marketing site lives in one directory
   (`website/src/content/`) editable by a non-engineer via the GitHub web UI.
2. Implement the deck's copy and page reorganization: live-in-India posture,
   merged host page with the Playbook flagship, honest data rules.
3. India market pack now; adding a country later = adding a pack, not
   touching pages.
4. A CI gate that prevents copy from ever leaking back into components.

Non-goals (do NOT do in this pass):
- No visual redesign; reuse existing primitives and CSS variables.
- No CMS, no i18n runtime library, no runtime geo-detection.
- No changes to the organizer listing generation pipeline, claim callables,
  waitlist function, or analytics transport.
- No legal copy authorship (see §8 — owner-gated).
- No app (Flutter) changes. In-app "Event success" → "Playbook" string sweep
  is a separate follow-up, not this spec.

Ordering constraint from `website/README.md`: update the route contract
`design/website/routes.json` BEFORE changing public routes, page metadata, or
postbuild output (§6).

---

## 1. Content infrastructure (Phase 0 — build this first)

### 1.1 Decision: typed TS content modules + one JSON meta file

All strings move to `website/src/content/`. Rationale (recorded for future
sessions): TS modules give type-checked content (a missing field fails
`npm run typecheck`, which already runs the whole governance suite), inline
comments as editor guidance, and zero new tooling. A headless CMS is the
deliberate later escalation if marketing needs publish-without-PR; the
schemas below map 1:1 onto CMS models, so nothing here is throwaway. Page
metas are pure JSON because `scripts/postbuild.mjs` (plain node) must read
them too — this **removes the current duplication** where metas are
hardcoded in both `src/app/pageMeta.ts` and `scripts/postbuild.mjs`.

### 1.2 Directory layout

```
website/src/content/
  README.md          — editing guide for marketing (see §1.6)
  types.ts           — every content interface; no values
  site.ts            — global chrome: nav, footer, consent banner, shared
                       form microcopy, store CTA microcopy, 404
  home.ts            — home page sections (deck §1)
  host.ts            — host page sections incl. Playbook catalog (deck §2)
  organizers.ts      — directory, listing, claim strings (deck §3–5)
  meta.json          — per-route page metas (deck §1.14, §2.14, §3–6)
  markets/
    types.ts         — MarketPack interface
    in.ts            — India pack (the only pack in v1)
    index.ts         — `export const activeMarket = inMarket;`
```

Rules:
- Content files export **plain data only** (strings, arrays, objects). No
  JSX, no functions, no imports except from `./types` / `./markets`. Rich
  emphasis is a component concern (e.g. the pull-quote component bolds its
  own text) — if a string seems to need inline markup, split the field.
- `import.meta.env` reads (store URLs) stay OUT of content files; the
  `useAppDownloadCtas` hook merges env URLs with content labels.
- Components may import content **only from `../../content/...`** (or a
  path alias `@content/`); nothing else imports content, and content imports
  nothing else. Add this to `tool/web/check_website_import_boundaries.mjs`.

### 1.3 MarketPack interface (`content/markets/types.ts`)

```ts
interface MarketCity {
  id: string;                       // stable, e.g. "in-mumbai"
  slug: string;                     // URL-safe city slug
  label: string;                    // public display label
  aliases: string[];                // e.g. Delhi NCR, Bengaluru
  timezone: string;                 // IANA timezone
  status: "live" | "waitlist";
}

export interface MarketPack {
  id: string;                       // extensible pack id, currently "in"
  countryCode: string;              // "IN"
  appStoreCountryCodes: string[];   // store-availability contract
  locale: string;                   // "en-IN"
  currencyCode: string;             // "INR"
  currencySymbol: string;           // "₹"
  cities: MarketCity[];
  featuredCityId: string;
  otherCityOptionLabel: string;
  heroEyebrowTemplate: string;      // interpolates the live-city source
  heroTicketLabelTemplate: string;  // interpolates the featured city
  downloadBodyTemplate: string;     // interpolates the live-city source
  comparisonColumns: string[];
  exampleEvent: {
    name: string; venue: string; cityId: string;
    timezone: string; currencyCode: string;
  };
}
```

`markets/index.ts` derives event-live cities from `status === "live"`, derives
waitlist/host options from all configured cities, and derives the featured city
and geo-adaptive rendered strings from this single pack. Pages never
hardcode a city, currency, timezone, or India-specific competitor. The
`check:market-pack` semantic test rejects duplicate/dangling city contracts,
invalid timezones/currency formatting, and current India option drift.

### 1.4 Content types (`content/types.ts`)

Define interfaces matching the deck's shapes. Reuse/relocate the existing
shapes from `features/marketing/content.ts` where they fit. Minimum set:

```ts
export interface SectionCopy { eyebrow?: string; title: string; body?: string; }
export interface Card { title: string; body: string; label?: string; }
export interface LoopStep { step: string; title: string; body: string; }
export interface FaqItem { question: string; answer: string; }
export interface PlaybookStage {
  id: string; label: string; sub: string;
  guestLine: string; hostLine: string;
}
export interface PlaybookModule {
  id: string;                 // internal id, e.g. "live_reveal"
  anchor: string;             // "playbook-countdown-reveals"
  publicName: string;         // "Countdown reveals"
  stageId: string;
  chip?: "NEW POWER" | "OFF YOUR PLATE";   // absent for safety layer
  oneLiner: string;
  more: string;               // expanded body
  fits: string;               // "Dinners, mixers, quiz nights, pickleball."
}
```

### 1.5 Migration of `features/marketing/content.ts`

Dissolve it. Everything it exports either (a) moves to `content/*.ts` with
deck-v2 values, or (b) is deleted because the section is removed (see §4/§5).
`storeCtas` splits: labels/kickers → `content/site.ts`; env URL merging stays
in `useAppDownloadCtas`. Update all imports. Delete the file at the end of
Phase 2; the build must not compile with it present (prevents drift).

### 1.6 `content/README.md` (write this file, ~20 lines)

For marketing editors: which file owns which page, "edit only text between
quotes", how to preview (open a PR; CI builds it), the banned-words list from
deck §0.6, and the two hard rules: never write "Event Success" or "crush" in
public strings; never add city/currency to a page file (market pack only).

### 1.7 Copy-ownership gate: `tool/web/check_website_copy_ownership.mjs`

New checker, wired into `website/package.json` `pretypecheck` as
`check:copy`. Behavior:

- Scans `website/src/**/*.tsx` EXCLUDING `src/content/`, `src/stories/`,
  `*.test.*`.
- Uses the TypeScript compiler API (already a devDependency) to flag:
  1. `JsxText` nodes containing ≥ 2 consecutive alphabetic words;
  2. string literals (≥ 2 words) passed to copy-carrying props:
     `title, body, label, eyebrow, description, placeholder, question,
     answer, ctaLabel, kicker, note, heading, emptyBody, fallbackStep`.
- Baseline file `tool/web/website_copy_baseline.json`: PR 1 lands the
  checker BLOCKING with a generated baseline of all current violations
  (each entry: file, exact string). The baseline is a ratchet — no additions
  ever; each subsequent PR must shrink it for the files it touches; PR 5
  requires it empty and deletes it. A separate
  `tool/web/website_copy_allowlist.json` holds permanent justified
  exceptions (file, exact string, reason — e.g. a technical token); expect
  it to stay near-empty. (Resolves the §11.4 contradiction: ratchet model
  chosen over delayed enforcement.)
- Exit non-zero with file:line and the offending text.
- Follow the house style of the sibling `check_react_*` checkers (arg
  parsing, `--check` flag, error formatting).

This is the enforcement that makes "strings in one place" stay true.

---

## 2. Phase 1 — P0 credibility fixes

These land with or before the copy swap; none depend on Phase 2 layout work.

| # | Fix | Where |
|---|-----|-------|
| 1 | Real store links: set `VITE_APP_STORE_URL` / `VITE_PLAY_STORE_URL` in `env.example` docs + CI env for the marketing deploy. Fallback microcopy when unset at build: "Coming to {store} soon." (content/site.ts). Remove "Store listings are not public yet..." copy everywhere. | env, `useAppDownloadCtas`, site.ts |
| 2 | Home discovery events: render only events with `start > now` in `activeMarket.liveCities`. Empty ⇒ empty-state copy from deck §1.6 ("New events drop every week…") + store CTAs. Purge fixture events that violate deck §8 (NY/$14, past dates, 4:30 AM, "sales report" description) from `publicDiscoveryData.ts` / fixtures. | features/organizers/publicDiscoveryData, HomeDiscoverySection |
| 3 | Replace `hostEvidenceMetrics` with the coherent funnel from deck §2.9 (240 → 38 → 20 → 18 → 12 → 7 → ★4.8/15) and caption it "Illustrative example". | content/host.ts |
| 4 | Humanize organizer category labels via a display map (`eventOrganizer` → "Event organizer", `brand` → "Brand", …) in content/organizers.ts; unknown values fall back to sentence-cased. | organizers selectors/cards |
| 5 | Profile-strength percentage: REMOVE from all public cards (§11.7 accepted — it is an internal weighted heuristic, not a public quality score). It may keep ordering featured organizers internally. | featuredOrganizerCardItem, listing cards |
| 6 | Footer: add links Privacy · Terms · Contact per §8 targets. | site.ts, SiteFooter usage |
| 7 | Delete the seven internal-language strings (deck audit): "The mockup split these…", "This is the pressure mechanic from the prototype…", "The page should answer operational concerns…", "App-created clubs should show…", "The public website now treats…", "Thin pages should stay out of search…", "…backend callables are host-authenticated." All are replaced by deck copy in Phase 2, but if Phase 2 is split across PRs, these strings must not survive PR 1. | grep gate §9 |

---

## 3. Route & information-architecture decisions (ratified — implement as stated)

| # | Decision | Rationale |
|---|----------|-----------|
| R1 | Merge `/host/preview` into `/host`. Single host page per deck §2. | Two near-duplicate pages split SEO and confuse the funnel. |
| R2 | `/host/preview{,/**}` → 301 to `/host/` via `firebase.json` hosting `redirects` on the `marketing` target; also remove the SPA route. | Firebase-layer redirect covers deep links and crawlers. |
| R3 | Home + host section order exactly per §4/§5 below. | Deck narrative order. |
| R4 | Organizer directory/search stays `noindex, follow`; listing-page indexing rules unchanged. | Deliberate evidence-before-indexing strategy — not this pass's call to change. |
| R5 | No new routes except `/legal/*` placeholders (§8, owner-gated). 404 copy per deck §6. | Scope control. |
| R6 | Playbook modules are anchors on `/host` (accordion cards), NOT subpages. | Thin-content SEO + maintenance drag. Anchor format: `/host/#playbook-first-hello`. |

Contract sequencing (per website/README.md):
1. Edit `design/website/routes.json`: bump `version`, update `updated`,
   remove the `host_preview` route entry, note the redirect in the host
   route's `notes`, adjust `review.states` for the reorganized pages.
2. Then update `routeRegistry.ts` (drop `host_preview`, `isHostPreviewPath`),
   `pageMeta.ts`, `App.tsx`, and `scripts/postbuild.mjs` together.
3. `npm run check:routes` must pass before proceeding.

### 3.1 pageMeta/postbuild unification

- `pageMeta.ts` becomes a thin reader of `content/meta.json`.
- `scripts/postbuild.mjs` deletes its hardcoded `routeMetas` and reads
  `../src/content/meta.json` (adds `canonical` from `baseUrl` + path).
- `meta.json` values: deck §1.14 (home), §2.14 (host), §3 (organizers),
  §5 (claim), §6 (404). Listing-page meta template (deck §4) stays in
  `pageMetaForListing`, title pattern from content.

---

## 4. Phase 2a — Home page (`features/home/`)

Section order (top to bottom) with deck mapping. Components keep their
file/module structure; each becomes copy-free (imports from `content/home.ts`
+ `content/site.ts` + `activeMarket`).

Order amended per §11.7 review (events promoted to position 2 — the social
object appears before explanation; consumer FAQ added):

| Order | Section (component) | Deck | Content export |
|-------|--------------------|------|----------------|
| 1 | Hero (`HomeHeroSection`) — CTA1 "Get the app" (store badges), CTA2 "Browse events near you" → `#events`, plus a quiet text link "Run events? Host on Catch →" (`home_hero_host_link`) | §1.1 | `home.hero`, `market.heroEyebrow`, `market.heroTicketLabel` |
| 2 | Events near you (`HomeDiscoverySection`, real-data rules §2.2; the honest empty state is acceptable in this slot) | §1.6 | `home.events` |
| 3 | How it works (`HomeMemberLoopSection` renamed intent, 4 steps) | §1.2 | `home.howItWorks` |
| 4 | Why Catch (4 cards; replaces formats-as-differentiator framing) | §1.3 | `home.whyCatch` |
| 5 | No one stands in the corner (NEW — guest-view playbook; reuse `MarketingInfoCardGrid` or the formats card grid; 4 cards + closing line) | §1.4 | `home.designedNight` |
| 6 | Formats (6 cards) | §1.5 | `home.formats` |
| 7 | Directory teaser (`HomeFeaturedOrganizersSection`; preserve card grid) | §1.7 | `home.directoryTeaser` |
| 8 | For-organizers teaser (`HomeHostProofSection`, keep product board demo but source its strings from content) | §1.8 | `home.organizersTeaser` |
| 9 | App captures | §1.9 | `home.captures` |
| 10 | Download (live-in-India) | §1.10 | `home.download`, `market.downloadBody` |
| 11 | Safety (4 cards) | §1.11 | `home.safety` |
| 12 | Consumer FAQ (NEW; 7 entries; `home_faq_open` events) | §1.11b | `home.faq` |
| 13 | Waitlist ("Not in your city yet?") — role options and success copy per deck §1.12; cities from `market.waitlistCities` | §1.12 | `home.waitlist`, `site.forms` |
| 14 | Footer (3 link columns + tagline) | §1.13 | `site.footer` |

Nav per deck §1: How it works · Events · Safety · Organizers · For
organizers · CTA **Get the app** (anchors to §10 or store link directly —
use `#download-app`).

Notes:
- Demo/product-board strings (Pickleball social, etc.) move to content too —
  they are user-visible.
- Consumer surfaces: zero occurrences of "Playbook", "Event Success",
  "module", "roster" (deck §0.6 banned list; `check:copy` + grep gate).
- New section 4 has no new capture ids; it is text cards only in v1.

---

## 5. Phase 2b — Host page (`features/host/`)

Delete `HostPreviewPage.tsx`, `HostPreviewSections.tsx`, `HostPages.tsx`
re-export; move the surviving preview sections (offer, FAQ, trust) into
`sections/` as host-page components. Update `shared/ui/primitives` manifests
as `check:ui-components` / `check:components` demand; delete primitives that
lose their last consumer.

Section order with deck mapping:

| Order | Section | Deck | Content export |
|-------|---------|------|----------------|
| 1 | Hero (console demo stays; demo strings → content; drop "West Village mixer" — use `market.exampleVenueCity` event name from content) | §2.1 | `host.hero` |
| 2 | Founding offer (port `HostPreviewOfferSection`) | §2.2 | `host.offer` |
| 3 | The problem (summary cards; port from comparison section) | §2.3 | `host.problem` |
| 4 | How it works (4 steps) | §2.4 | `host.workflow` |
| 5 | Create-event walkthrough (keep component; new outcome lines; keep field fixtures — already Mumbai/₹) | §2.5 | `host.createFlow` |
| 6 | Fill the room (3 modules, `ProductModuleGrid`) | §2.6 | `host.fillRoom` |
| 7 | **The Playbook (flagship)** — see §5.1 | §2.7 + §2.7a | `host.playbook` |
| 8 | After the event | §2.8 | `host.after` |
| 9 | Proof / report (ledger + illustrative funnel) | §2.9 | `host.proof` |
| 10 | Comparison (summary already used at #3; table + new facilitation row, plain-language row labels; columns from `market.comparisonColumns`) | §2.10 | `host.comparison` |
| 11 | Trust for hosts (3 cards) | §2.11 | `host.trust` |
| 12 | FAQ (port `HostPreviewFaqList`; 10 entries incl. Playbook, facilitator, phones, my-own-way) | §2.12 | `host.faq` |
| 13 | Apply (application flow; microcopy fixes deck §2.13) | §2.13 | `host.apply` + form strings in `site.forms` |

Nav per deck §2: How it works · Fill the room · The Playbook · Proof · FAQ ·
Directory · CTA **Apply to host** (→ `#founding-hosts`).

### 5.1 The Playbook flagship section (the one new composite component)

Structure, top to bottom (deck §2.7 then §2.7a):
1. `SectionHeader` — eyebrow `THE PLAYBOOK`, title, two-paragraph Level-1
   body (SectionHeader must accept a string[] body or render two `<p>`;
   smallest viable change).
2. Two mode cards — reuse `HostComparisonSummaryCards`.
3. Pull-quote — reuse the existing pull-quote/`PrivacyGuardrail`-style strip
   or `MarketingSectionCopy` variant; do not build a new primitive if an
   existing one fits.
4. Stage rail — reuse `HostFeatureRail` + `EventSuccessModuleGrid` pattern
   from the current `EventSuccessShowcase` (rename component to
   `PlaybookShowcase`; captures per stage keep current capture-id mapping).
   Stage copy = deck §2.7 rail (guest line + host line per stage).
5. Module catalog — accordion cards over `host.playbook.modules`
   (14 `PlaybookModule` entries, §2.7a): card front = publicName + chip +
   oneLiner; expanded = `more` + "Fits: {fits}". Each card gets
   `id={module.anchor}`; expanding scrolls into view when the URL hash
   matches on load. Reuse `ProductModuleGrid`'s expand/facts pattern —
   extend rather than duplicate.
6. Guardrail strip (existing `PrivacyGuardrail`) + format note line.

Naming rules (hard): rename user-visible "Event Success" everywhere on the
site to Playbook terms. Internal identifiers (`eventSuccessModules` exports,
capture ids like `host-post-event-report`) may keep their names — but the
old content exports are being deleted anyway; new exports use `playbook*`
naming so grep gates stay clean.

---

## 6. Phase 2c — Organizers, claim, 404, global

- Directory (`OrganizerSearchSections`): title/body/placeholder per deck §3
  → `organizers.search`.
- Listing pages: hero checklist labels (claimed/unclaimed variants), four
  section headers, review split labels, owner-reply notes, claim CTA + six
  unlock items per deck §4 → `organizers.listing`.
- Claim pages per deck §5 → `organizers.claim`.
- 404 per deck §6 → `site.notFound`.
- Waitlist/application form statuses, validation messages, consent banner
  per deck §7 → `site.forms`, `site.consent`. Before shipping the "No ad
  tracking" consent line, verify `src/analytics.ts` actually sets no ad/
  remarketing features; if it does, keep the current banner wording and flag.
- Footer tagline + columns per deck §1.13 → `site.footer` (host page footer
  uses the same object; per-page link lists allowed as fields).

---

## 7. Analytics

Keep `trackCtaClick` transport untouched. Contract as it actually exists
(verified): `trackCtaClick(label, href)` emits `cta_label` + `cta_href` —
the `{page}_{section}_{action}` ids below are passed as the `label`
argument; do NOT introduce a `cta_id` key. New/renamed CTA labels:
`home_hero_get_app`, `home_hero_browse_events`, `home_hero_host_link`,
`home_download_get_app`, `host_hero_apply`, `host_offer_apply`,
`notfound_browse_events`. Removed sections' ids die with them; ids that keep
their meaning keep their names.

Content-interaction events (NOT cta_click): `playbook_module_open` with
`module_id`, `host_faq_open` / `home_faq_open` with `faq_id` — stable ids
from content, not display strings. Add `content_version:
"website_copy_v2"` to page-view and interaction events so post-launch
measurement ties to this migration. Launch measurement set (record in the
analytics doc, no A/B framework): store CTA CTR, event-browse CTR, waitlist
completion, host-application start/completion, organizer-claim conversion,
indexing guardrails.

---

## 8. Owner-gated items (implement structure, wait for content)

1. **Legal/support pages at `/privacy`, `/terms`, `/help`** — these exact
   paths are LIVE URL contracts: the shipped Flutter app links to them from
   Settings (`lib/safety/presentation/settings_screen.dart:397–433`). Do
   NOT use `/legal/*`. Add the three routes (contract first), static
   template rendering `content/legal.ts`. Until owner supplies text,
   bodies are `null`, routes unregistered, footer links hidden. **Never
   write legal text.** NOTE (production-release blocker, not merely a
   hidden link): today these app-linked URLs resolve to the SPA 404 — a
   live gap that predates this migration; owner must supply destinations.
2. **Contact**: footer link `mailto:` — address to be supplied; use a
   `site.footer.contactHref` field, empty ⇒ link hidden.
3. **Store URLs**: real values into CI env (owner supplies).
4. **Stat callouts**: the deck's "rooms that run rotations see __%" pattern
   ships only when owner supplies a defensible number. Structure: optional
   `host.playbook.statCallout?: string` — absent in v1.

---

## 9. Verification gates (all must pass; run in this order)

1. `npm run typecheck` in `website/` — runs the full pretypecheck suite
   including new `check:copy`, `check:routes` (against the updated
   contract), import boundaries, component governance.
2. `npm run build` — postbuild must succeed reading `meta.json`; run
   `node scripts/postbuild.test.mjs` and update its fixtures.
3. Grep gates (all must return nothing) over `website/src` excluding tests:
   - `grep -rni "event success" website/src/content website/src/features`
   - `grep -rni "crush" website/src/content`
   - `grep -rni "mockup\|prototype\|callable\|lead packet\|aggregate-safe" website/src/content`
   - `grep -rn "West Village\|Cervo\|New York" website/src` (fixtures gone)
   - `grep -rni "coming soon" website/src/content` — allowed ONLY in the
     store-link build fallback string.
4. Storybook: update/rename stories for removed preview sections and the new
   Playbook section; `npm run build:storybook` passes.
5. Redirect: after deploy to a preview channel, `curl -I` on
   `/host/preview/` returns 301 → `/host/`.
6. Manual QA route pass (desktop + mobile viewports): every route in the
   contract renders; module accordion anchors deep-link correctly; empty
   events state renders when the feed has no future in-market events; store
   badges href non-empty in prod build.
7. CI: `.github/workflows/marketing-website.yml` green; deploy only
   `hosting:marketing`.

## 10. Suggested PR slicing

1. **PR 1 — Content infra**: `src/content/` scaffold + types + market pack +
   `check:copy` blocking with ratchet baseline + meta.json unification +
   checker manifest registration + old→new migration map appended to this
   spec (§11.8). No visual change.
2. **PR 2 — P0 fixes** (§2) + home page copy swap (§4). Baseline shrinks to
   exclude home files.
3. **PR 3 — Host route consolidation**: route contract, 301 redirect
   contract + firebase.json, Host Preview retirement, component/story/
   registry cleanup, merged Host composition (§3, §5 minus the catalog).
4. **PR 4 — Playbook catalog**: module content, semantic accordion
   (details/summary or aria-expanded buttons, keyboard + hash-deep-link),
   interaction analytics, a11y states, visual review states (§5.1).
5. **PR 5 — Organizers/claim/404/global** (§6) + delete
   `features/marketing/content.ts` + baseline file empty and deleted.

Each PR: contract check green, grep gates green for the files it touches.
(PR 3/4 split per §11.10 — routing/SEO risk stays separate from the new
interactive catalog.)

---

## 11. Implementation review amendments for Fable

Status: **proposed implementation amendments for external review** ·
2026-07-11

These notes refine architecture, data ownership, routing, verification, and
delivery. They do **not** authorize edits to the approved deck strings in this
implementation pass. Public-string recommendations are parked separately in
§12 so the core implementation can proceed without silently rewriting copy.

### 11.1 Source-of-truth lifecycle

- Treat `website_copy_deck.md` as the approved migration input. Once the
  migration lands, `website/src/content/` becomes the runtime copy source of
  truth and the deck becomes a frozen decision record. Do not leave two
  independently editable canonical copy sources.
- Close the corresponding open decision in
  `docs/marketing_website_architecture.md`, update that owner document with the
  final `content/` dependency rules, and update `website/README.md` when the
  Host Preview route and stories disappear.
- Update `design/website/components.json` explicitly for every removed,
  renamed, or new route/section export. Do not rely on the component checker to
  discover the intended migration after the code has moved.

### 11.2 Market and city contract

The proposed `MarketPack` is a useful boundary, but the initial interface does
not yet prove the goal that a future market requires only a new pack.

- Replace display-string city lists with structured city records containing a
  stable market/city id, slug, display label, aliases, IANA timezone, and
  launch status.
- Separate these concepts instead of overloading `liveCities`:
  - app-store availability country;
  - event-live cities;
  - featured/default city;
  - user-selected city;
  - waitlist-only cities; and
  - host-application cities.
- Add `countryCode`, `locale`, and `currencyCode`; a symbol alone is not enough
  for formatting or future markets.
- Replace `id: "in"` with a genuinely extensible market id contract.
- Replace `exampleVenueCity` with a coherent example fixture containing event
  name, city, venue, currency, and timezone.
- Derive the hero eyebrow, ticket label, and download city sentence from one
  city source rather than repeating city names inside three independent
  strings.
- Reconcile the approved public city list with the repo's canonical launch and
  city sources before shipping. In particular, normalize aliases such as
  Delhi/Delhi NCR and Bangalore/Bengaluru before filtering generated listings.
- If this pass still has no city selection or runtime geo-detection, describe
  the page as an India build with a configured featured city; do not make the
  implementation behave as though it knows the visitor's city.
- Delete or migrate `website/src/shared/lib/cities.ts` so it does not remain a
  second city source beside the market pack.

### 11.3 Public discovery and demo-data ownership

The current P0 fixture rule cannot be completed solely in
`publicDiscoveryData.ts`: that module derives the generated organizer
projection, while the New York sales-demo listing originates in the organizer
generation inputs.

- Do not hand-edit `website/src/generated/hostListings.json`.
- Choose and document one production boundary:
  1. preferred: production generation/checks run without `catchDemo` entries,
     while Storybook and sales-demo tooling retain their own fixtures; or
  2. narrower fallback: the Home selector explicitly excludes
     `dataOrigin: "catchDemo"`, and the global grep gate is scoped accordingly.
- If production should use `--no-demo`, include the generator command, package
  script, tests, workflow, and generated-output check in this spec. That is an
  intentional exception to the current "no organizer generation changes"
  non-goal.
- Define whether Home can show only Catch-bookable events or also external
  events. If external events remain, render an explicit external-booking label
  and use a different CTA from "Book in the app."
- Make event eligibility a pure selector with injected `now` and market ids so
  future/past and market filtering have deterministic tests and Storybook
  states.
- Add a freshness rule so an event-live city is not advertised without a
  qualifying future inventory source or an owner-approved empty state.

### 11.4 Content ownership and interpolation

Clarify goal 1 as: **all static, marketing-authored interface copy** lives in
`website/src/content/`. Generated organizer/event data, user content, external
API data, route ids, analytics ids, and machine-owned anchors are not marketing
copy and keep their existing owners.

The copy-ownership gate should then:

- scan both `.ts` and `.tsx` production sources;
- cover JSX text, string/template literals in known copy positions, one-word
  visible labels, validation/status messages, `alt`, `aria-label`,
  `aria-description`, helper text, tooltips, and SVG titles;
- cover authored static labels emitted by `scripts/postbuild.mjs`;
- exclude tests, stories, generated data, machine ids, URLs, analytics event
  names, and explicitly classified external/user data;
- define and test one typed interpolation helper for `{city}`, `{name}`,
  `{store}`, counts, and other approved tokens; and
- fail when an editor removes, adds, or misspells a required token.

Add an explicit `content` layer to
`tool/web/check_website_import_boundaries.mjs`. Feature pages, feature
components, feature controllers that own form/status copy, `pageMeta.ts`, and
the approved postbuild reader may import content. `shared/**` stays copy-neutral
and receives strings through props. If `@content/` is introduced, the checker
must understand the alias rather than checking only relative imports.

Resolve the allowlist contradiction before PR 1: either land a reasoned,
ratcheted migration baseline and shrink it per PR, or delay the blocking gate
until all current violations are migrated. "Start empty" and "temporarily
allowlist current violations" cannot both be acceptance criteria.

Register the checker and its self-tests in `tool/tools_manifest.json`, bind it
to an active/manual audit rule as appropriate, provide a known-bad/vacuity
proof, and run the enforcement-integrity/manifest gates. Ad hoc grep commands
may remain as developer diagnostics, but recurring public-copy rules should be
owned by a deterministic checker with exact exclusions and expected counts.

### 11.5 Metadata, routes, redirects, and public legal paths

- Give `meta.json` a schema or runtime validator and make `pageMeta.ts`,
  `postbuild.mjs`, postbuild tests, and
  `tool/marketing/check_website_routes.mjs` consume the same contract. The
  current route checker parses literal `pageMeta.ts` blocks and must be updated
  as part of the unification.
- Move the generated-listing title template and authored static profile labels
  into the shared content/meta contract too; otherwise metadata and visible
  postbuild copy remain partly duplicated.
- Model the Host Preview redirect in `design/website/routes.json` (or a
  route-adjacent redirect contract) with source, destination, and status. A
  note on the Host route is not machine enforcement. The route checker should
  compare this contract with `firebase.json`.
- Cover `/host/preview`, `/host/preview/`, a nested preview path, and preserved
  query parameters in redirect tests before retaining the preview-channel HTTP
  check.
- Preserve the existing public URL contracts `/privacy`, `/terms`, and `/help`,
  which are already referenced by app/store surfaces. If `/legal/*` becomes
  canonical, add permanent redirects and update every consumer atomically.
- Do not link or register empty legal pages, but treat missing required privacy,
  terms, and support destinations as a production-release blocker rather than
  merely hiding the footer links.
- Add a direct HTTP assertion that an unknown production path returns a real
  `404`, not only a React noindex page served with status `200`.

### 11.6 Store environment, consent behavior, and analytics contracts

- Require `VITE_APP_STORE_URL` and `VITE_PLAY_STORE_URL` in the production
  marketing environment validator and pass them to both the validation and
  deploy steps. "Coming soon" remains a local/preview fallback only.
- Test the consent banner in unset, essential-only, and accepted states.
- Decide explicitly whether pre-consent attribution storage is permitted; the
  current analytics bootstrap captures campaign/referrer information before a
  consent choice.
- Keep consent wording aligned with actual GTM/advertising behavior. The
  deferred wording decision is recorded in §12, but the implementation must
  not expose a false consent state.
- Resolve the analytics contract mismatch: `cta_click` is documented with
  `cta_id`, while the current helper emits `cta_label` and `cta_href`.
- Treat `host_playbook_module_open` and `host_faq_open` as content-interaction
  events with stable `module_id`/`faq_id`, not CTA clicks.
- Add `content_version: "website_copy_v2"` to relevant page and interaction
  events so post-launch measurements can be tied to this migration.
- Record the launch measurement set: store CTA CTR, event-browse CTR, waitlist
  completion, host-application start/completion, organizer-claim conversion,
  and SEO/indexing guardrails. No A/B framework is required in this pass.

### 11.7 Page hierarchy and component review questions

Fable should review these as information-architecture questions, independently
of the deferred wording review:

- Should real events (or the honest empty state) move immediately after the
  Home hero so the social object appears before five explanatory sections?
- Should Home retain a quiet Host/Organizer CTA in the first viewport, in
  addition to the consumer app and browse-events actions?
- Should the organizer directory/claim path move higher so the established
  directory → reviews → claim → host-tools loop is not treated as a late-page
  teaser?
- Should "Why Catch" and the guest-view designed-night material be tightened
  into one shorter proof block to avoid repeating the catch/match mechanism?
- Add a consumer FAQ state to the content/route review plan for availability,
  eligibility, check-in/catching, no-shows/refunds, blocking/reporting,
  accessibility, and supported event/audience formats.
- Explicitly preserve `RecommendedOrganizersSection` on unclaimed pages and
  source its copy from `organizers.ts`; this is part of the verified-organizer
  discovery/claim loop.
- Define measurable exit criteria for changing the organizer directory from
  `noindex, follow` rather than leaving the decision open-ended.
- Prefer removing the public profile-strength percentage. It is an internal
  weighted heuristic, not a public quality score or a user-actionable
  completion checklist.
- For the Playbook, consider showing four to six flagship modules initially
  with "Explore all 14," while preserving every module's deep-link anchor.
- The accordion needs a real semantic API: native details/summary or buttons
  with `aria-expanded`/`aria-controls`, keyboard activation, predictable focus,
  and hash-load opening. `ProductModuleGrid` does not currently provide this
  behavior merely by having expandable facts.
- Do not reuse `PrivacyGuardrail` solely because its strip styling fits a
  positioning quote; semantic reuse still matters.
- Rephrase the non-goal as "no new visual language or asset-production pass."
  Reordering thirteen Home sections and adding a major interactive Host
  composite is still a substantial IA and visual-QA change.

### 11.8 Explicit migration map and review states

Before implementation, add an old → new map for:

- route/page exports;
- Host Preview sections that move into the Host route;
- deleted versus retained shared primitives;
- Home sections added or renamed;
- Host problem/proof/Playbook exports;
- route and section stories;
- `design/website/components.json` entries and `routeIds`;
- Host Preview CSS selectors that are deleted, renamed, or retained; and
- canonical-doc/current-state paragraphs that become stale.

Add deterministic review states for:

- Home discovery with eligible events and with no eligible events;
- live, partial, and missing store URLs;
- Playbook collapsed, expanded, and hash-deep-linked modules;
- Host application default, validation, pending, failure, and success;
- organizer claimed/unclaimed, verified/public reviews, and recommended
  organizers; and
- capture-present and capture-fallback states.

Accessibility acceptance should include one H1, ordered headings, keyboard-only
navigation, visible focus, 200% zoom/reflow, reduced motion, contrast, form
error associations/live status, and an automated Storybook/axe failure gate.
`build:storybook` alone is not an accessibility assertion.

### 11.9 Operational prerequisites that remain owner/product gated

The following are not string-review questions. They are operational contracts
that must be true before the associated approved copy is published:

- real App Store and Play Store destinations;
- public privacy, terms, help/support, contact, community-guideline, and refund
  destinations as applicable;
- a Founding Host entitlement owner, 24-month start/expiry source, platform-fee
  behavior, public badge state, and priority-placement behavior;
- production-ready payment, refund, settlement, and processor-fee behavior for
  every marketed provider/market; and
- a dated evidence owner for competitor comparison cells and any quantitative
  public result.

If these are not ready when the layout ships, keep the affected content fields
absent/feature-gated rather than presenting operational promises without their
supporting behavior.

### 11.10 Verification and PR slicing amendments

Add these proof requirements to §9:

- tests for the copy checker, content interpolation, meta schema/reader,
  market/event selector, redirect contract, and analytics payloads;
- exact built-output assertions for title, description, canonical, robots,
  Open Graph/Twitter fields, sitemap membership, legal/support paths, and 404
  status;
- `node website/scripts/checkOrganizerBuildOutputs.mjs` after the production
  build;
- `node tool/run.mjs check --manifest-only` and the relevant meta/enforcement
  checks when the new checker is registered;
- `node tool/agent/check_agent_readiness.mjs` before handoff;
- desktop/mobile screenshots for the reordered Home and Host routes, including
  long-copy and empty-data states; and
- an audit-registry pass receipt covering the refactor and its proof.

Split the current PR 3 into two reviewable units:

1. **Host route consolidation** — route contract, 301, Host Preview retirement,
   component/story/registry cleanup, and the merged Host composition.
2. **Playbook catalog** — module content mapping, semantic accordion,
   hash-deep-link behavior, interaction analytics, accessibility, and visual
   review states.

This keeps routing/SEO risk separate from the new interactive catalog.

---

## 12. Deferred public-string review backlog

Status: **deferred until after the core implementation/Fable review**

This section records wording concerns without changing the approved deck or
authorizing implementers to paraphrase it. Revisit these items in a dedicated
copy review after the content architecture, route consolidation, and core page
composition are stable.

| ID | Revisit | Candidate direction for later review |
|---|---|---|
| `COPY-V2-001` | Attendance versus interaction | Replace claims that every match is someone the user talked to with the narrower product truth that both people checked in to the same event. |
| `COPY-V2-002` | Height/catfishing language | Remove "height — verified live" and the catfishing sentence; neither is a useful product guarantee. |
| `COPY-V2-003` | Absolute facilitation promises | Revisit "No one stands in the corner," "within minutes," "meet everyone," and "no repeats." Prefer outcomes the Playbook supports without guaranteeing every guest interaction. |
| `COPY-V2-004` | Host acquisition guarantee | Revisit "Catch fills it, runs it, and proves it worked." Candidate direction: Catch gives hosts one place to fill the room, run it, and see what happened. |
| `COPY-V2-005` | Empirical Playbook provenance | Revisit "practices that measurably work," "drawn from the best hosts on Catch," and "tested against outcomes" unless a defensible evidence record exists. |
| `COPY-V2-006` | Synthetic funnel presentation | Prefer real anonymized evidence. If sample data remains, label it visibly and accessibly as sample interface data, not observed Catch results; reconsider the synthetic star rating. |
| `COPY-V2-007` | Competitor absolutes | Re-review every comparison cell against dated evidence and avoid categorical "No" claims that cannot be maintained. Add an "As of" date if the table ships. |
| `COPY-V2-008` | Consent wording | "No ad tracking" is not compatible with the current accepted-consent behavior. Final language must match the owner/legal decision and actual GTM configuration. |
| `COPY-V2-009` | Guest quotations | The stage-rail first-person lines may resemble testimonials. Consider rendering them as labeled guest-experience outcomes rather than attributed or implied customer quotes. |
| `COPY-V2-010` | Optionality language | Distinguish optional facilitation modules from the non-optional safety layer; reconcile "by default" with per-event choice. |
| `COPY-V2-011` | Run phone-use claim | Replace "runs use no live phone moments" if check-in remains a phone interaction; candidate direction is that runs can keep phone use to check-in. |
| `COPY-V2-012` | Inclusive admission language | Scope binary-ratio examples to formats where they actually apply and document the intended queer/non-binary event model before implying universal balance behavior. |
| `COPY-V2-013` | Consumer vocabulary | Use "Catch app" rather than "member app" if "member" remains reserved for club membership. Clarify whether Founding Host status belongs to the person or organizer entity. |
| `COPY-V2-014` | Repetition across Home | Assign one job to each section: proposition, sequence, real-world context, anti-awkwardness, and safety. Remove repeated explanations of private catching/mutuality after layout review. |
| `COPY-V2-015` | Proof terminology | Revisit "proof real connections happened" and similar language. Prefer concrete observable outcomes such as attendance, catches, matches, reviews, and repeat guests. |

When this backlog is reopened, review the deck and rendered pages together;
do not perform a blind repository-wide replacement. Record accepted changes in
the content source of truth and retire the corresponding ids above.

---

## 13. Fable review resolutions (2026-07-11)

Disposition of every §11 amendment and §12 backlog item. Where §13 conflicts
with un-amended text in §1–10, §13 governs. Sections §1.7, §2 (item 5), §4
(order), §7, §8 (item 1), and §10 have already been amended inline.

### 13.1 §11 dispositions

- **11.1 (SoT lifecycle): ACCEPTED.** After PR 5, `website/src/content/` is
  the runtime copy SoT and the deck is a frozen decision record (stamp its
  header accordingly in PR 5). Update `docs/marketing_website_architecture.md`,
  `website/README.md`, and `design/website/components.json` explicitly per PR.
- **11.2 (market/city contract): ACCEPTED, scoped to what v1 renders.**
  Structured `CityRecord {id, slug, label, aliases[], timezone, status:
  "live" | "waitlist"}` plus pack-level `countryCode`, `locale`,
  `currencyCode` (+ symbol for display). Do NOT build six parallel city
  lists — derive roles from `status` flags; featured city = explicit
  `featuredCityId`. Hero eyebrow / ticket label / download sentence become
  templates interpolated from the same city source (see 11.4 helper).
  `exampleVenueCity` becomes an `exampleEvent {name, venue, city, currency}`
  fixture object. Normalize aliases (Delhi/Delhi NCR, Bangalore/Bengaluru)
  in one map used by listing filtering. Frame as "India build with a
  configured featured city" — no pretend geo-awareness. Delete
  `shared/lib/cities.ts` (waitlist reads the market pack).
- **11.3 (demo data): ACCEPTED, option 1 (preferred).** Production organizer
  generation runs without `catchDemo` entries; Storybook/sales tooling keep
  their fixtures. This is a granted, documented exception to the "no
  generation pipeline changes" non-goal — include generator flag, package
  script, tests, workflow wiring, and output check. Home shows only
  Catch-bookable future in-market events in v1 (external events appear on
  listing pages only, labeled per deck §4). Event eligibility = pure
  selector with injected `now` + market ids, unit-tested, with Storybook
  states for both branches. Cities are advertised as live from the market
  pack only (owner-configured); the events section independently renders
  real inventory or the honest empty state.
- **11.4 (ownership scope + gate): ACCEPTED in full.** Goal 1 reads: all
  static marketing-authored interface copy lives in `content/`; generated
  data, user content, machine ids, analytics ids, anchors keep their owners.
  Checker scans `.ts` + `.tsx`, covers the extended surface (single-word
  visible labels, `alt`, `aria-*`, validation/status strings, postbuild
  authored labels), excludes tests/stories/generated. One typed
  interpolation helper (`{city}`, `{name}`, `{store}`, counts) with
  missing/extra/misspelled-token failures, unit-tested. Import-boundary
  checker gains an explicit `content` layer; the `@content/` alias IS
  introduced and the checker must resolve it. `shared/**` stays copy-neutral
  (strings via props). Allowlist contradiction resolved inline (§1.7):
  blocking ratchet baseline from PR 1. Register checker + self-test in
  `tool/tools_manifest.json` with a seeded known-bad vacuity proof, and run
  the manifest/enforcement-integrity gates.
- **11.5 (meta/routes/redirects/legal): ACCEPTED.** `meta.json` gets a
  schema + runtime validator consumed by `pageMeta.ts`, `postbuild.mjs`,
  its tests, and an updated `tool/marketing/check_website_routes.mjs`.
  Listing-title template and authored postbuild labels join the content/meta
  contract. Redirects become a machine-checked block in
  `design/website/routes.json` (source, destination, status) compared
  against `firebase.json` by the route checker; tests cover `/host/preview`,
  trailing slash, nested paths, and query-param preservation. Legal paths:
  `/privacy`, `/terms`, `/help` (verified live contracts — §8 amended).
  404 must return real HTTP 404 for unknown paths (static `404.html` +
  hosting config; assert with curl in §9).
- **11.6 (env/consent/analytics): ACCEPTED**, analytics contract amended
  inline (§7). Store URLs required by
  `tool/env/check_web_hosting_env.mjs marketing` for production; "Coming
  soon" fallback is preview/local only. Consent banner tested in unset /
  essential-only / accepted states; wording must match actual behavior
  (COPY-V2-008). **Pre-consent attribution capture: OWNER DECISION** —
  until decided, do not expand current behavior and do not ship copy
  claiming "no ad tracking".
- **11.7 (IA questions): RULED** —
  - Events after hero: ACCEPTED (spec §4 amended; empty state allowed in
    slot 2).
  - Quiet host link in first viewport: ACCEPTED (`home_hero_host_link`).
  - Directory/claim moved higher: REJECTED for now — home stays
    consumer-first; the hero host link + teasers carry acquisition. Revisit
    with `host-application-start` source data after launch.
  - Merge Why-Catch + designed-night: REJECTED — different jobs (mechanism
    vs anti-awkwardness). One-job-per-section is a review gate; if visual QA
    shows repetition, cut lines via the copy backlog, not a merge.
  - Consumer FAQ: ACCEPTED — deck §1.11b added (7 entries), spec §4 row 12.
  - `RecommendedOrganizersSection`: ACCEPTED — preserved on unclaimed pages,
    strings from `organizers.ts`.
  - Directory noindex exit criteria: recorded as owner-gated. Suggested
    criterion: flip to index when ≥25 claimed listings each have ≥1
    verified attendee review; owner signs off.
  - Profile-strength percentage: ACCEPTED — removed from public UI (§2
    amended).
  - Playbook progressive disclosure: ACCEPTED — 6 flagship modules
    (First Hello, Starter pods, Rotations, Countdown reveals, "Help me say
    hi", The recap) + "Explore all 14"; every module keeps its anchor and
    is reachable pre-expansion via hash deep-link.
  - Semantic accordion: ACCEPTED — native `details`/`summary` preferred,
    else buttons with `aria-expanded`/`aria-controls`, keyboard activation,
    focus management, hash-open on load.
  - `PrivacyGuardrail` reuse for the pull-quote: ACCEPTED — build/extend a
    neutral quote-strip primitive instead; `PrivacyGuardrail` keeps its
    semantic job.
  - Non-goal rephrase: ACCEPTED — reads "no new visual language or
    asset-production pass"; the reorg is a real IA + visual-QA change.
- **11.8 (migration map + review states + a11y): ACCEPTED.** Codex generates
  the old→new map (routes, sections, primitives, stories, components.json
  entries, CSS selectors, stale doc paragraphs) as a PR 1 deliverable
  appended to this spec. Deterministic review states as listed. A11y
  acceptance: one H1, ordered headings, keyboard-only pass, visible focus,
  200% reflow, reduced motion, contrast, form-error association, and an
  automated Storybook+axe gate (build:storybook alone is not an a11y
  assertion).
- **11.9 (operational prerequisites): ACCEPTED** — owner checklist:
  (1) store URLs; (2) `/privacy`, `/terms`, `/help` destinations (already a
  live gap — the shipped app links to them); (3) Founding Host entitlement
  owner + 24-month clock source + fee/badge/placement behavior;
  (4) payment/refund/settlement per marketed provider; (5) dated evidence
  owner for comparison cells + any public number. Affected content fields
  ship absent/gated until true.
- **11.10 (verification + slicing): ACCEPTED** — §10 amended to 5 PRs; add
  the listed proof requirements to §9's gate list (checker/interpolation/
  meta/selector/redirect/analytics tests; built-output assertions incl. OG/
  Twitter/sitemap/404 status; `checkOrganizerBuildOutputs`; manifest and
  agent-readiness checks; desktop+mobile screenshots incl. long-copy and
  empty states; audit-registry pass receipt).

### 13.2 §12 backlog dispositions

Applied to the deck now (accuracy > cadence): **001** ("talked to" → "met");
**003** partial (rotation absolutes → "new faces each round" /
"no back-to-back repeats"; section title "No one stands in the corner"
STAYS — design-intent framing, not a per-guest guarantee); **006** (visible
"sample data" labeling rule); **007** ("As of" line + owner-maintained
evidence file); **009** (guest lines rendered as labeled designed-experience
outcomes, never quote-styled); **010** ("every module is optional — except
the safety layer"); **011** (runs keep phone use to check-in); **012**
(queer/mixed-format balance sentence); **013** partial (`THE CATCH APP`
eyebrow; Founding Host person-vs-entity = owner question).

Rejected — voice kept, owner veto open: **002** (height line is deliberate
voice, not a guarantee); **004** ("fills it, runs it, and proves it worked"
is the flagship claim; the softened candidate is mush); **015** ("proof" is
always adjacent to the concrete outcomes it means — attendance, catches,
matches, reviews).

Resolved by existing calibration: **005** (deck already claims mechanism,
not volume; stat claims stay gated on an evidence record — owner explicitly
ratified the provenance story). **008** owner-gated (consent wording must
match GTM reality; see 11.6). **014** is a standing review lens, not a
string change.

### 13.3 Open owner decisions (blocking noted items only)

1. Consent/ad-tracking wording + pre-consent attribution policy (blocks
   final consent copy only).
2. `/privacy`, `/terms`, `/help` destinations (production blocker — live
   app links 404 today).
3. Founding Host: person or organizer entity; entitlement/clock ops owner.
4. Directory index-flip criterion sign-off.
5. Standing veto on kept-voice items (COPY-V2-002/004/015).

---

## 14. PR 1 deterministic old → new migration map

Status: implementation map only. This section records the current source and
the required destination before the copy/IA patch begins. It does **not** mark
the mapped change complete. Route, component-registry, story, CSS, and doc
edits land together in the owning PR so none of these inventories becomes an
independent source of truth.

### 14.1 Routes and page owners

| Current | Target | Required contract action |
|---|---|---|
| `/` → `HomePage` | `/` → `HomePage` | Preserve route/canonical behavior; replace section order and review states only. |
| `/host/` → `HostPage` | `/host/` → merged `HostPage` | Keep the canonical route; absorb the surviving offer, trust, FAQ, create-flow, and Playbook material. |
| `/host/preview{,/**}` → `HostPreviewPage` SPA route | 301 → `/host/` | Add the machine-checked redirect contract first; remove runtime route detection and static review entry only after redirect tests pass. |
| `/organizers/` | unchanged | Preserve `noindex, follow`; copy/category-display changes only. |
| canonical and legacy organizer listing families | unchanged | Preserve canonical, legacy noindex, sitemap, and generated-output behavior. |
| `/claim/{,**}` | unchanged | Preserve lookup/rewrite and noindex behavior; copy ownership only. |
| `/404/` and root `404.html` | unchanged route family | Replace content later; separately prove unknown Hosting requests return HTTP 404. |
| `/privacy`, `/terms`, `/help` | owner-gated additions | Do not create placeholders until destinations/content owners are supplied. |

Route code affected when the redirect is approved:
`design/website/routes.json`, `firebase.json`,
`website/src/app/routeRegistry.ts`, `website/src/app/App.tsx`,
`website/src/app/pageMeta.ts`, `website/scripts/postbuild.mjs`, and
`tool/marketing/check_website_routes.mjs`.

### 14.2 Home sections

| Current section/source | Target owner/order | Migration action |
|---|---|---|
| `HomeHeroSection` | `HomeHeroSection` / 1 | Preserve shell; source copy from `content/home.ts`, CTA labels from `content/site.ts`, geo labels from `activeMarket`. |
| `HomeDiscoverySection` | `HomeDiscoverySection` / 2 | Preserve pure eligible-event input and deterministic event/empty stories; replace copy only. |
| `HomeMemberLoopSection` | `HomeHowItWorksSection` / 3 | Rename intent and registry/story ids; preserve `MarketingLoopList`. |
| none | `HomeWhyCatchSection` / 4 | Add as a configured `MarketingInfoCardGrid`; no new primitive. |
| none | `HomeDesignedNightSection` / 5 | Add guest-view anti-awkwardness cards; no public Playbook/Event Success terminology. |
| `HomeFormatsSection` | `HomeFormatsSection` / 6 | Preserve component and card primitive; move values to content. |
| `HomeFeaturedOrganizersSection` | same / 7 | Preserve generated data and internal strength ordering; never restore the public percentage. |
| `HomeHostProofSection` | `HomeOrganizerTeaserSection` / 8 | Preserve product-board structure where useful; move authored strings. |
| `HomeCapturesSection` | same / 9 | Preserve capture ids/fallback states; move labels/captions only. |
| `HomeDownloadSection` | same / 10 | Read geo body from market pack and labels from site content; URLs remain env-owned. |
| `HomeTrustSection` | `HomeSafetySection` / 11 | Rename intent/registry/story id; preserve neutral card shells. |
| none | `HomeFaqSection` / 12 | Add semantic FAQ/details coverage with seven deck entries. |
| `HomeWaitlistSection` | same / 13 | Preserve form/controller; cities remain market-owned. |
| app-level `SiteFooter` | same / 14 | Move labels into site content; legal links stay gated on owner destinations. |

`HomePage.tsx` remains a route-level table of contents. New section bodies stay
in `features/home/sections/HomePageSections.tsx` until file size or independent
test ownership justifies one-section files.

### 14.3 Host sections

| Current section/source | Target owner/order | Migration action |
|---|---|---|
| `HostHeroSection` + useful `HostPreviewHeroSection` product demo | `HostHeroSection` / 1 | Keep one hero and one console demo; delete the preview route wrapper. |
| `HostPreviewOfferSection` | `HostFoundingOfferSection` / 2 | Move into Host route; gate entitlement claims on owner prerequisites. |
| `HostEvidenceSection` + comparison summary cards | `HostProblemSection` / 3 | Consolidate summary only; do not duplicate the full comparison table. |
| `HostWorkflowSection` / `HostPreviewOperatingLoopSection` | `HostWorkflowSection` / 4 | Keep one four-step workflow and one story/registry entry. |
| `CreateEventWalkthrough` + `HostPreviewCreateFlowSection` wrapper | `CreateEventWalkthrough` / 5 | Keep the registered walkthrough; delete the preview-only wrapper. |
| `HostFillRoomSection`, `HostPreviewAdmissionSection`, `HostPreviewPaymentsSection` | `HostFillRoomSection` / 6 | Consolidate admission, bookings, and timed waitlist modules. |
| `EventSuccessShowcase`, `HostPreviewLiveSection`, `HostLiveModulesSection` | `HostPlaybookSection` / 7 | Rename public concept, keep six flagship modules plus expansion, stage rail, anchors, and hash-open behavior. |
| useful after-event material in `HostLiveModulesSection` / `HostPreviewAfterSection` | `HostAfterSection` / 8 | Keep one post-event section; remove duplicate route-specific claims. |
| `HostProofLedgerSection` + evidence metrics | `HostProofSection` / 9 | Keep ledger and visibly labelled illustrative funnel. |
| `HostComparisonSection` | same / 10 | Preserve expandable table; columns remain market-owned and evidence date is required. |
| `HostPreviewTrustSection` | `HostTrustSection` / 11 | Move into Host route and preserve neutral card structure. |
| `HostPreviewFaqSection` | `HostFaqSection` / 12 | Move semantic FAQ list into Host route and delete preview ownership. |
| `HostApplySection` + `HostPreviewApplySection` | `HostApplySection` / 13 | Keep one application flow and one anchor. |
| `HostPreviewFormatsSection` | no standalone section | Absorb useful format examples into Playbook/FAQ or delete duplication. |
| `HostCapturesSection` | no required standalone deck section | Reuse captures inside their owning sections; delete only after every capture id has a target or explicit retirement. |

Delete after the merged route passes its contract and visual gates:
`HostPreviewPage.tsx`, `HostPreviewSections.tsx`, the `HostPages.tsx`
compatibility re-export, and unused preview-only imports.

### 14.4 Shared primitives

| Current primitive family | Target disposition |
|---|---|
| `HostHero*`, `HostPageSection` | Keep as Host route shells. |
| `HostFeatureSection`, `HostFeatureGrid`, `HostFeatureRail` | Keep; configure Playbook and host sections through them where semantics fit. |
| `HostCreateFlowCapture` | Keep. |
| `HostComparisonTable*`, `HostComparisonSummaryCards` | Keep. |
| `EventSuccessModuleGrid` | Rename to `PlaybookModuleGrid`; rename registry state and CSS selectors in the same patch. |
| `PrivacyGuardrail` | Keep its privacy semantic job; do not reuse for the Playbook pull-quote. |
| none | Add the smallest neutral `QuoteStrip` only if existing `MarketingSectionCopy` cannot express the pull-quote accessibly. |
| `HostPreviewMain` | Delete with the preview route. |
| `HostPreviewHero*`, `HostPreviewSection*`, `HostPreviewApplyShell` | Prefer existing Host shells; retain only pieces that can be renamed to neutral Host concepts with a live merged-route consumer. |
| `HostPreviewFaqList` | Rename to `HostFaqList` if its native `details/summary` behavior is retained. |
| `HostPreviewOffer*` | Rename to `HostOffer*` only for the surviving founding-offer section; otherwise delete. |
| preview console/roster/payment/live/trust helpers | Map each to a merged Host consumer before renaming; delete helpers with zero consumers. |
| `ProfileStrength` | Keep only for host-application completeness; public organizer adapters remain deleted. |

No alias wrappers are allowed solely to preserve retired `HostPreview*` or
`EventSuccess*` names. Rename the canonical primitive, registry entry, story,
scanner family, and CSS ownership together.

### 14.5 Storybook and component registry

| Current evidence | Target evidence |
|---|---|
| `MarketingRoutes.stories.tsx::HostPreview` / `route_host_preview` | Delete after redirect proof; Host story owns merged states. |
| `MarketingRoutes.stories.tsx::Host` | Add merged default, offer, Playbook-expanded/hash-open, FAQ, and application states as deterministic stories/manual states per the route contract. |
| `HomeSections::HomeDiscoverySectionStory` + `HomeDiscoveryEmptyStateStory` | Keep both; these already prove inventory and empty branches. |
| `HomeMemberLoopSectionStory` / `home_member_loop_section` | Rename to How-it-works story/id. |
| `HomeTrustSectionStory` / `home_trust_section` | Rename to Safety story/id. |
| no Why-Catch/designed-night/FAQ entries | Add section registry entries and matching stories. |
| `HostSections::EventSuccessShowcaseSection` | Rename to Playbook story and add collapsed, one-open, all-expanded, hash-open, long-copy, and reduced-motion review states. |
| all `HostPreview*SectionStory` exports and `host_preview_*` entries | Move surviving evidence to renamed Host sections; delete obsolete exports/entries in the same registry version bump. |
| `host_preview_create_flow_section` | Delete wrapper entry; `host_create_event_walkthrough` remains the canonical exhibit. |
| `host_preview_apply_section` | Delete wrapper entry; `host_application_flow` and merged `host_apply_section` remain canonical. |
| `shared_host_preview_shell` | Split surviving renamed primitives into their actual Host family or delete if no consumer remains. |

The component checker must stay bidirectional throughout: no ready registry
entry without a matching `catchComponent` story, and no referenced story after
its registry entry is removed.

### 14.6 CSS ownership

| Current selector family | Target action |
|---|---|
| `.host-preview`, `.host-preview-page` | Delete route-only wrappers after the redirect/merged route lands. |
| `.host-preview-hero*` | Reuse existing `.host-hero*` where geometry matches; otherwise rename the surviving selectors to `.host-hero-*` without keeping aliases. |
| `.host-preview-offer*` | Rename surviving offer selectors to `.host-offer*`; delete the rest. |
| `.host-preview-section*`, `.host-preview-product-split*` | Prefer `.host-section*` / existing Host feature shells; delete zero-consumer selectors. |
| `.host-preview-format-rail`, `.host-preview-chip-row` | Rename only if retained by the Playbook/FAQ; otherwise delete. |
| `.host-preview-loop*`, `.host-preview-roster*`, `.host-preview-payment-flow*`, `.host-preview-live*`, `.host-preview-trust*`, `.host-preview-faq*`, `.host-preview-apply*` | Trace each to the target section above, rename with that section, then run a zero-reference search; never leave compatibility selectors. |
| `.event-success-showcase*`, `.event-success-stage-rail*`, `.event-success-module-grid*` | Rename to `.playbook*` in source, CSS, component-governance scanner, stories, and registry together. |
| organizer-listing Event Success selectors | Out of this website-copy rename unless the rendered public wording changes; preserve listing data-contract semantics until separately scoped. |

Responsive blocks in `host.css`, `responsive.css`, and shared occurrences in
`organizer-public.css` must be included in the same rename/delete search. Visual
parity is checked before deletion; selector absence alone is not proof.

### 14.7 Stale documentation to update with the implementation

When the merged route lands, remove or rewrite the current-state paragraphs in
`docs/marketing_website_architecture.md` that describe separate `HostPage` and
`HostPreviewPage` ownership, the `HostPreview*` primitive family, target-tree
entries for `HostPreviewPage.tsx` / `HostPreviewSections.tsx`, and
`EventSuccessShowcase` as a public Host section. Update
`docs/web_surface_architecture.md`, `website/README.md`, route/component
contracts, and the audit registry in the same pass. Historical audit receipts
remain append-only and are not rewritten.

### 14.8 Completion searches for the migration PR

The implementation PR is not complete until each search is either empty or has
an explicitly documented non-public/data-contract exception:

```sh
rg -n 'HostPreview|host_preview|host-preview' website/src design/website docs/marketing_website_architecture.md
rg -n 'EventSuccess|event-success|Event Success' website/src design/website docs/marketing_website_architecture.md
rg -n 'route_host_preview|host_preview_' design/website/components.json website/src/stories
rg -n 'host-preview|event-success' website/src/styles tool/web/check_react_component_governance.mjs
```

Then run the route/component/import/copy/governance gates, typecheck, production
build, Storybook build plus the real axe assertion, redirect and 404 HTTP tests,
desktop/mobile/200%-reflow captures, and the audit-registry receipt listed in
§9–§10.

### 14.9 Fable sign-off on the migration map (2026-07-11)

§14 is **approved as the PR-slicing input** with the following verification
record and three clarifying rulings.

Spot-checks performed against the repo (all grounded): the six cited
registry ids exist in `design/website/components.json`
(`route_host_preview`, `home_member_loop_section`, `home_trust_section`,
`host_preview_create_flow_section`, `host_preview_apply_section`,
`shared_host_preview_shell`); the cited story exports exist
(`HomeDiscoverySectionStory`/`HomeDiscoveryEmptyStateStory`,
`EventSuccessShowcaseSection`, `HostPreview` in both HostSections and
MarketingRoutes stories); `HostPreviewMain` and `ProfileStrength` exist in
`shared/ui/primitives.tsx`; `host-preview` and `event-success` selector
families confirmed in `host.css`, and `event-success` in
`organizer-public.css` (`responsive.css` currently has zero occurrences —
keep it in the search set anyway).

Rulings:
1. **Listing-page "Event Success" string (real catch).** The §14.6
   carve-out for organizer-listing Event Success *selectors and data fields*
   (`eventSuccessSummary` etc.) stands — but it covers CSS/data contracts
   only, not rendered strings. `ListingEventsSections.tsx` renders a public
   `eyebrow="Event Success"` (line ~220): that string MUST migrate in the
   copy pass. Replacement: `Event report` (consistent with the deck §4
   checklist label "Event report available"). The §14.8 completion search's
   "documented exception" may cover identifiers, never rendered text.
2. **Legal routes.** §14.1's stricter position supersedes §8's earlier
   wording: do not create `/privacy`, `/terms`, `/help` routes, templates,
   or contract entries until the owner supplies destinations/content. (The
   production-blocker status of those URLs is unchanged — the shipped app
   links to them today.)
3. **Section-file threshold.** §14.2's note that new Home section bodies
   stay in `HomePageSections.tsx` "until file size or independent test
   ownership justifies" a split is accepted, with a number: split a section
   into its own file when `HomePageSections.tsx` exceeds ~600 lines or a
   section needs its own test file, whichever comes first.

With §13 + §14 in place the spec is closed for open decisions except the
five owner items in §13.3. Codex may begin PR 1.

## 15. Local implementation receipt — 2026-07-12

- PR 1–2 foundations are active: validated metadata, market pack, event
  eligibility, analytics versioning, owner-gated content tests, and the
  blocking copy-ownership scanner.
- PR 3 retired the Host Preview route, added contract-backed 301 redirects for
  both exact and nested preview paths, merged offer/trust/FAQ into `/host/`,
  and removed duplicate page/section/story/registry owners.
- PR 4 added the canonical Playbook stage rail and all 14 semantic accordion
  modules with stable anchors, hash scrolling, expansion analytics, privacy
  guardrails, and ready Storybook states.
- PR 5 dissolved `features/marketing/content.ts`, moved authored content under
  `website/src/content/`, reduced the copy migration baseline to zero, applied
  the directory/listing/claim/404 public copy contracts, and removed public
  “Event Success” wording in favor of Playbook/event-report language.
- Legal/support destinations, store destinations, and Founding Host operational
  entitlement promises remain governed by the existing owner-gated checks;
  this implementation does not invent routes or production readiness.
