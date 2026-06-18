# Organizer Curation Decisions

Repo-backed manual QA operations for dedupe and surface cleanup.

Use these batches to merge duplicate organizer candidates, suppress false
positives, reject or accept ambiguous surfaces, and mark surfaces that need a
separate organizer entity. The generator applies these operations before
building dedupe, review, website projection, and claim-target artifacts.

Live admin persistence can move here later, but raw search and scrape evidence
should still stay out of Firestore.
