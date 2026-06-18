# Event Source Batches

Reviewed provider payloads are normalized into these private event source
batches before any external event candidate can be reviewed.

This folder is not a crawler output sink. Files here must come from a reviewed
capture command such as `capture_luma_events.mjs`, and every downstream
candidate remains import-blocked until event import policy and dedupe review are
approved.
