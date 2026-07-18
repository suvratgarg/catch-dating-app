---
doc_id: design_sync_pipeline
version: 1.2.0
updated: 2026-07-18
owner: design_system
status: active
---

# Code, Figma, and Claude Design sync

`catch.components.json` is the identity and behavior contract. Flutter owns
behavior, DTCG tokens own values, Figma owns editable design instances, and the
generated context pack is the Claude Design input. No tool may silently become
a second component registry.

Run `node tool/design/build_design_sync_manifest.mjs` after changing component
identity, APIs, states, or mapping metadata. CI runs the same command with
`--check`. Use `--require-live` only in a release environment that has a Figma
file and a Code Connect-capable plan; it is intentionally red while either
Badge or Field lacks current published evidence.

The manifest records a digest per contract, generated mapping metadata, Figma
property drift, concept metrics, Claude eligibility, and the Badge + Field
spike. A Figma mapping is current only when the registry component name resolves
to exactly one captured component node and its property definitions match the
generated contract projection. A Code Connect mapping is valid only when the
registry points to a template.

`figma_library_snapshot.json` is generated evidence. A `LIBRARY_PUBLISH`
webhook contains the trigger and changed library item keys/names; the receiver
must hydrate it with `GET /v1/files/:key` or `GET /v1/files/:key/nodes` before
running:

```sh
node tool/design/import_figma_library_snapshot.mjs \
  --webhook path/to/webhook.json \
  --file-response path/to/figma-file.json \
  --review-snapshots path/to/snapshot-index.json
```

The optional snapshot index is an object keyed by Figma node id. Each value is
either a repo-relative image path (the importer computes its SHA-256 digest) or
an object with `path` and a previously computed lowercase SHA-256 digest.

The importer extracts component and component-set node ids, canonicalizes
Figma property names (including generated `#...` suffixes), records optional
review-image paths/digests, captures descendant variable-binding references,
and stamps a content digest. The sync manifest joins those nodes to contract
ids by `design.figma.componentName` and generates node URLs. Neither artifact
is hand-edited. The live Badge + Field gate additionally requires at least one
captured variable binding, one review snapshot, and a published Code Connect
template for each component; planned metadata cannot satisfy it.

Current live discovery is stored in `live_capabilities.json`. It is operational
evidence, not a credential file. The current Starter plan permits library work
but does not satisfy the Organization/Enterprise prerequisite for published
Code Connect, so the repository prepares that seam without claiming it is live.

## Deterministic loop

1. Change Flutter, tokens, or the component contract.
2. Regenerate `design_context_pack`. Its
   `design_system/claude_design_handoff_request.json` is the only accepted
   Badge + Field Claude Design prompt contract.
3. Run that request through Claude Design and store its exact, referenced
   response in `design/sync/claude_design_receipt.json`. The sync gate rejects
   stale source, concept, or supported-state digests.
4. Update and publish the matching Figma component.
5. Let the publish receiver hydrate the webhook and regenerate the Figma
   snapshot artifact on a review branch.
6. Regenerate this sync manifest; it reports mappings as `current`, `stale`, or
   `missing` and verifies both the Claude context and receipt digests.
7. Publish Code Connect only where the plan supports it.
8. Run component, context-pack, snapshot, sync-manifest, Widgetbook, and drift
   gates.

The first live vertical slice is `catch.badge` plus `catch.field`. Scale to the
remaining concepts only after both components pass the full loop.
