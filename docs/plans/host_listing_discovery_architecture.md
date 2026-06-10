---
doc_id: host_listing_discovery_architecture
version: 0.1.0
updated: 2026-06-10
owner: marketing_website
status: draft
---

# Organizer Listing Discovery Architecture

## Goal

Build a deterministic acquisition pipeline for finding high-fit event organizers and
publishing claimable public profiles without repeatedly searching the same
terms, duplicating businesses, or creating thin SEO pages.

The first target batch is 25-50 high-fit singles or social organizers. A listing can
start as an internal candidate, then become a noindex public QA page, and only
become indexable after it has enough verified public value.

## Initial Target Categories

Prioritize organizers where Catch's booking, attendance, live facilitation,
post-event matching, and aggregate reporting are natural upgrades:

| Category | Good-fit signal | Early query examples |
|---|---|---|
| Social run clubs | Recurring adult runs with post-run hangouts, creator-led community, or mixed-gender turnout | `run club {city}`, `social run {city}`, `community run {city}` |
| Racket sport socials | Pickleball, padel, tennis, badminton socials with rotations or mixed groups | `pickleball social {city}`, `padel club {city}`, `badminton mixer {city}` |
| Singles event operators | Dating mixers, speed dating, curated singles dinners, social mixers | `singles events {city}`, `speed dating {city}`, `singles mixer {city}` |
| Supper clubs and dinner hosts | Repeated tables where guests meet each other, not just restaurant reservations | `supper club {city}`, `dinner club {city}`, `community dinner {city}` |
| Quiz, bar crawl, and nightlife hosts | Team-based or social events where stranger interaction matters | `pub quiz {city}`, `bar crawl {city}`, `social mixer {city}` |
| Creator/community hosts | Instagram-native operators with recurring city events and manual DMs/forms | `things to do {city} community`, `new in {city} social club` |
| Venue-led socials | Cafes, bars, courts, gyms, coworking spaces hosting repeated social events | `{format} event venue {city}`, `{venue type} social night {city}` |

Deprioritize one-off concerts, conferences, family/kids programming, pure
fitness training with no social layer, and large festivals where Catch would not
own the guest journey.

## Deterministic Search Ledger

Every search run should create an immutable run record:

- `runId`: date plus category, city, and source.
- `queryTemplateId`: stable ID such as `run_club_city_v1`.
- `renderedQuery`: exact query string.
- `city`, `category`, `source`.
- `engine`: Google Places Text Search, Programmable Search, platform API, or
  manual source.
- `requestedFields`: exact fields requested from an API.
- `resultFingerprint`: hash of normalized result URLs, names, and place IDs.
- `rawSnapshotPath`: stored raw JSON or HTML snapshot when terms permit.
- `candidateIds`: normalized candidates created or touched by the run.
- `searchedAt`, `operator`, `notes`.

The search scheduler should only run query templates that do not already have a
fresh run for the same city, category, source, and template version.

## Candidate Identity And Deduplication

Each discovered organizer becomes or updates one candidate record. Candidate IDs
should be deterministic:

1. Use a canonical platform ID when available:
   - Google Places `places.id`
   - Event platform organizer ID
   - Instagram handle, only after verified
2. Otherwise derive a fallback ID from:
   - normalized name
   - city
   - primary URL domain or social handle

Deduplication should compare:

- exact platform IDs;
- exact canonical URLs;
- normalized Instagram handles;
- normalized name plus city;
- phone/email if the source lawfully exposes business contact details;
- fuzzy name similarity only as a review queue, not an automatic merge.

Merged candidates should retain all source aliases and all raw evidence.

## Candidate Lifecycle

| State | Meaning | Page behavior |
|---|---|---|
| `candidate` | Found by search, not reviewed | No public page |
| `qualified` | Matches ICP and has at least one stable public source | No public page or internal preview |
| `page_seeded` | Public QA page exists but evidence is thin | `noindex, follow` |
| `index_ready` | Has verified identity, category, city, source links, useful description, and owner-safe copy | Indexable |
| `claimed` | Owner account or host account has claimed it | Indexable, owner controls profile fields |
| `onboarded` | Host has created a Catch host account or event | Listing links to Catch host product |
| `suppressed` | Duplicate, removal request, bad fit, unsafe, or uncertain identity | No public page |

## Minimum Page Quality Gate

Do not index a page until it has:

- verified name, city, and category;
- at least one official or high-confidence public source URL;
- one business-safe way for the owner to claim or correct the page;
- original Catch-written summary and fit context;
- no copied social captions or review text;
- no private personal contact details unless the business publishes them for
  contact;
- clear status if the profile is unclaimed.

This avoids thin programmatic SEO and makes the page useful to searchers even
before the host claims it.

## Source Policy

Use APIs and public pages in this priority order:

1. Google Places Text Search and Place Details for place identity and location.
2. Event platforms with public organizer or event pages.
3. Host-owned websites.
4. Instagram, Facebook, Threads, LinkedIn, and other social profiles only when
   access method and terms allow it.
5. Manual owner/user-supplied seeds.

Store source confidence separately from the final listing. A listing may exist
with low confidence, but it should remain `noindex` until verification is high.

## Data Surfaces

The canonical source of truth is still `clubs/{clubId}` in Firestore, with the
club document now extended to support broader organizer profiles:

- `hostUserId`, `ownerUserId`, `hostUserIds`, and `hostProfiles` can represent
  claimed Catch ownership, while unclaimed programmatic organizers keep those
  ownership fields null or empty.
- `entityKind`, `entitySubtypes`, `displayCategory`, and location display fields
  prevent every organizer from being forced into club wording.
- `ownership`, `claim`, `publicPage`, `provenance`, `publicProfile`, and
  `publicSources` model claim state, noindex/index-ready status, verified public
  evidence, and owner-safe page content directly on the canonical document.

For local seed work before live Firestore import, use backend-shaped fixtures:

- `tool/host_discovery/seed_clubs/*.json`

Each seed file wraps a target Firestore path plus a `data` object whose shape is
the actual `clubs/{clubId}` document. Website-specific listing JSON must be a
generated projection from those club documents, not a hand-authored source of
truth:

- `website/scripts/generateOrganizerListings.mjs`
- `website/src/generated/hostListings.json`

For scraper operations, use a separate ledger and private source-evidence store
until this graduates to Firestore or BigQuery:

- `tool/host_discovery/query_templates.json`
- `tool/host_discovery/target_categories.json`
- `tool/host_discovery/search_matrix.json`
- `tool/host_discovery/candidate_batches/*.json`
- `tool/host_discovery/runs/*.json`
- `tool/host_discovery/generated/candidate_dedupe_index.json`
- `tool/host_discovery/generated/search_plan.json`
- `tool/host_discovery/generated/source_evidence.json`
- `tool/host_discovery/generated/index_readiness_report.json`
- `tool/host_discovery/generated/firestore_seed_import_plan.json`
- future `clubDiscoveryRuns/{runId}`
- future `clubs/{clubId}/sourceEvidence/{sourceId}` or
  `clubSourceEvidence/{sourceId}`

The website should render only page-ready club documents. The scraper ledger and
evidence collections may contain low-quality, duplicate, rejected, raw, private,
and suppressed candidates.

## Candidate Backlog

The first target backlog is now machine-readable:

- `tool/host_discovery/candidate_batches/2026-06-10-initial-organizer-targets.json`

It contains 35 organizer candidates across the first target categories. The
backlog is intentionally broader than the seeded public pages: `candidate` and
`qualified` records are not public pages, while `page_seeded` records must point
to a backend-shaped `clubs/{clubId}` seed document.

Current batch distribution:

| Dimension | Count |
|---|---:|
| Total candidates | 35 |
| Page seeded | 2 |
| Qualified | 15 |
| Candidate review backlog | 18 |

The validator generates a deterministic dedupe index from names, city slugs,
official domains, source URLs, Instagram handles, event URLs, seed document
paths, and canonical page paths:

```sh
node tool/host_discovery/validate_discovery_data.mjs
node tool/host_discovery/validate_discovery_data.mjs --check
```

The search planner expands category/city queries and candidate-specific
verification queries while skipping candidates with fresh run logs:

```sh
node tool/host_discovery/plan_search_runs.mjs
node tool/host_discovery/plan_search_runs.mjs --check
```

As of 2026-06-10, the generated plan has 225 planned searches and skips 10
candidate verification searches because Afterfly and Bhag already have fresh run
logs.

## Source Evidence And Import Plan

Run logs are normalized into source evidence records before anything graduates to
Firestore:

```sh
node tool/host_discovery/generate_source_evidence.mjs
node tool/host_discovery/generate_source_evidence.mjs --check
```

The generated evidence file separates public-display-safe facts from internal
facts that should not be rendered directly, such as raw image URLs, exact private
addresses, registration counts, commerce internals, or personal contact details.

Seed import is represented as a dry-run write plan:

```sh
node tool/host_discovery/export_seed_import_plan.mjs
node tool/host_discovery/export_seed_import_plan.mjs --check
```

The import plan intentionally does not perform remote writes. Applying it to
Firestore requires explicit Firebase project selection, remote-write approval,
and a preflight proving the target `clubs/{clubId}` paths are absent or safe to
overwrite.

## Index Readiness

No seeded organizer page becomes indexable until it passes the generated
readiness gate:

```sh
node tool/host_discovery/check_index_readiness.mjs
node tool/host_discovery/check_index_readiness.mjs --check
```

The gate checks that a page is still QA/noindex, has a claim/correction path, is
hidden from native app discovery, has high-confidence public sources, has
owner-safe original page copy, and has no unresolved city, cadence, owner/contact,
or media-permission blockers.

When the operational review is complete, admins promote or hold the canonical
`clubs/{clubId}.publicPage` state through `adminSetClubIndexStatus`. The callable
persists `publicPage.indexReview` with the source-evidence, media-rights,
cadence, and owner/contact checklist so indexability is auditable from the same
club document used by the app and website.

As of 2026-06-10, both seeded pages are intentionally blocked from indexing:

| Candidate | Index blockers |
|---|---|
| Afterfly Indore | Current cadence, owner/contact verification, media permission |
| Bhag Delhi | Delhi city evidence, current cadence, owner/contact verification, media permission |

## First Seed

`Afterfly Run Club` in Indore and `Bhag Run Club` in Delhi are the first test
profiles. The 2026-06-10 Afterfly pass found a stable Luma event page for AFTER
FLY after the direct web and Instagram-oriented queries were sparse. The
2026-06-10 Bhag pass found an official Bhag site and a Bhag Club Luma event in
Gurugram, but not a stable Delhi-specific public source. Both profiles therefore
ship as unclaimed, hidden-from-app, `noindex` organizer seed documents with
public event evidence and the remaining missing evidence shown explicitly.
