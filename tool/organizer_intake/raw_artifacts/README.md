# Raw Artifacts

Temporary holding area for high-volume organizer scrape/search/provider payloads.

Files placed here are intentionally ignored by git. Reviewed, redacted, small
fixtures can still live under `fixtures/`; normalized reviewed batches belong in
`search_result_batches/` or `event_source_batches/`.

Raw artifacts must not be stored in Firestore. The generated
`raw_artifact_storage_manifest.json` inventories local raw payloads and blocks
remote object upload until bucket, retention, deletion, and crawl-cost policy
are approved.
