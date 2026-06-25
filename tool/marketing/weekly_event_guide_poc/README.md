# Catch Weekly Event Guide PoC

This is a self-contained experiment for weekly city event guides. It is not wired
to the app, website, organizer intake, Firestore, or Instagram publishing.

The goal is to prove the editorial loop before integration:

1. Configure the weekly city, source list, search prompts, ranking rules, and
   CTA copy.
2. Collect candidate events from approved sources or manual research.
3. Generate a ranked review queue and carousel draft in multiple public tones.
4. Review each event manually before any public use.
5. Export the approved copy/design packet for a human to edit and publish.

## Current Boundary

- Mumbai-first.
- Non-Catch events are allowed while Catch has no event supply.
- Every candidate is treated as unverified until reviewed.
- Instagram is manual-reference only in this PoC. Do not build an unofficial
  scraper into this loop.
- The output is a draft packet, not an autoposter.

## Run

```bash
node tool/marketing/weekly_event_guide_poc/scripts/validate_config.mjs
node tool/marketing/weekly_event_guide_poc/scripts/generate_guide.mjs --week 2026-06-22 --tone both
```

Generated files are written to:

```text
tool/marketing/weekly_event_guide_poc/generated/<city>/<week>/
```

When a decisions file is supplied, the default output folder is:

```text
tool/marketing/weekly_event_guide_poc/generated/<city>/<week>-with-decisions/
```

To apply editor decisions without changing the source candidate file:

```bash
node tool/marketing/weekly_event_guide_poc/scripts/generate_guide.mjs \
  --week 2026-06-22 \
  --tone both \
  --decisions tool/marketing/weekly_event_guide_poc/review_decisions/mumbai.2026-06-22.example.json
```

## Review States

- `draft`: candidate can appear in an internal review queue.
- `needs_changes`: candidate needs better details, verification, or copy.
- `approved`: candidate may appear in an export packet.
- `rejected`: candidate is excluded.

The generator includes `draft`, `needs_changes`, and `approved` events in the
review queue. It excludes `rejected` events. Public publishing should only use
events promoted to `approved`.

## Tone Variants

`singles-friendly` is the recommended default while using third-party events.
It is truthful when an event is not explicitly for singles, but is still easy to
attend solo and likely to support conversation.

`singles-social` should be reserved for events that are explicitly singles-led,
dating-led, mixer-led, or hosted by Catch. The generator can still mock this
tone, but it flags non-singles events as "singles-friendly, not singles-only."

The earlier generated concept boards and the first HTML primitive board are not
approved templates. They recreated brand elements instead of referencing them.

The approved reference contract starts here:

- `design/BRAND_PRIMITIVES.md`
- `design/primitives.contract.json`

Validate references:

```bash
node tool/marketing/weekly_event_guide_poc/scripts/validate_brand_references.mjs
```

Visual rendering is intentionally blocked until the real `Catch _` logo asset or
component is available and referenced.

## Integration Later

If this loop works, the integration path should be:

1. Replace sample candidates with reviewed source adapters.
2. Add durable source snapshots and per-field citations.
3. Add an editor UI for approve/reject/request-changes.
4. Add a renderer for the chosen carousel template.
5. Add an explicit publishing handoff, still behind human approval.
