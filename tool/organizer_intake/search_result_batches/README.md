# Search Result Batches

Store captured organizer search results here when a search run should become
repo-reviewed intake evidence.

These files are raw private evidence. They do not publish organizer pages and
do not write Firestore. Convert reviewed provider payloads into this schema:

```sh
node tool/organizer_intake/capture_search_results.mjs \
  --run-key '<host-discovery runKey>' \
  --raw-results path/to/provider-results.json \
  --date 2026-06-17 \
  --write
```

Then run:

```sh
node tool/organizer_intake/ingest_search_results.mjs
node tool/organizer_intake/ingest_search_results.mjs --check
```

The generated candidate queue normalizes URLs through
`lib/platform_adapters.mjs`, matches existing organizer surface dedupe keys, and
keeps crawl metadata disabled by default. Admin or curation operations still
decide whether a surface attaches to an entity, creates a new candidate, or is
rejected as a wrong entity.
