# Catch Event Guide Marketing Ops

Private, review-first automation boundary for city event-guide marketing.

This module turns configured sources, weekly searches, source results, and
event candidates into an editable admin workbench packet. It does not publish
to Instagram, write app events, create website pages, or scrape Instagram.

## Boundary

- Marketing recommendations are content-only by default.
- Every public detail must keep a source reference.
- Instagram accounts are manual-reference sources unless an approved official
  API flow is available.
- AI can extract, score, and draft, but admin review decisions are the authority.
- Visual rendering must reference approved Catch primitives and the real
  `Catch _` logo asset/component before export.

## Run

```sh
node tool/marketing/event_guide/scripts/generate_marketing_ops_bridge.mjs \
  --week 2026-06-22 \
  --admin-output admin/src/generated/marketingOpsBridge.json \
  --event-intake-admin-output admin/src/generated/eventIntakeBridge.json
```

To capture live search results through an approved provider, set a provider key
and write a normalized source-result file:

```sh
SERPAPI_API_KEY=... \
node tool/marketing/event_guide/scripts/capture_search_results.mjs \
  --provider serpapi \
  --week 2026-06-22 \
  --output tool/marketing/event_guide/data/mumbai.search_results.2026-06-22.json
```

Then pass that source-result file into the bridge generator:

```sh
node tool/marketing/event_guide/scripts/generate_marketing_ops_bridge.mjs \
  --week 2026-06-22 \
  --source-results tool/marketing/event_guide/data/mumbai.search_results.2026-06-22.json \
  --admin-output admin/src/generated/marketingOpsBridge.json \
  --event-intake-admin-output admin/src/generated/eventIntakeBridge.json
```

Generated files are written to:

```text
tool/marketing/event_guide/generated/<city>/<week>/
```

`marketing_ops_bridge.json` feeds the Marketing tab. `event_intake_bridge.json`
feeds Event Intake and excludes recommendation/content-draft fields so source
review, candidate review, and import planning stay separate from marketing
packaging.

Publish the Event Intake bridge to the live admin dashboard document with:

```sh
node tool/marketing/event_guide/publish_event_intake_dashboard.mjs --env dev
node tool/marketing/event_guide/publish_event_intake_dashboard.mjs --env dev --apply
```

The publisher writes only `eventIntakeDashboards/current`. It does not write
`marketingOpsDashboards/current`, canonical `events/{id}`, `externalEvents/{id}`,
or marketing content drafts.

## Review States

- `new`: visible to operators, not approved.
- `needs_changes`: useful lead, but needs better evidence or copy.
- `approved`: can move to the next queue.
- `held`: paused without rejection.
- `rejected`: excluded from recommendations and public drafts.

## Implementation Path

1. Keep source/query/run config editable in the admin app.
2. Use scheduled jobs or manually triggered jobs to produce source results.
3. Normalize approved results into event candidates with citations.
4. Let a human approve candidates and ranking.
5. Generate content drafts and require final approval before export.
