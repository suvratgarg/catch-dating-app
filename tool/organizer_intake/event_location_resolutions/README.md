# Event Location Resolutions

Repo-backed exports of admin-reviewed event location decisions live here.

Each JSON file is a deterministic batch produced by:

```sh
node tool/organizer_intake/export_event_location_resolutions_from_firestore.mjs \
  --env dev --date YYYY-MM-DD --write
```

These batches are consumed by `ingest_event_sources.mjs` before event import
planning. They do not enable external provider lookups or event writes.
