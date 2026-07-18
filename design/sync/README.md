---
doc_id: design_sync_pipeline
version: 1.0.0
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
Badge or Field is unmapped.

The manifest records a digest per contract, bidirectional mapping metadata,
concept metrics, Claude eligibility, and the Badge + Field spike. A Figma
mapping is valid only when its registry entry has a node-specific component URL.
A Code Connect mapping is valid only when the registry points to a template.

Current live discovery is stored in `live_capabilities.json`. It is operational
evidence, not a credential file. The current Starter plan permits library work
but does not satisfy the Organization/Enterprise prerequisite for published
Code Connect, so the repository prepares that seam without claiming it is live.

## Deterministic loop

1. Change Flutter, tokens, or the component contract.
2. Regenerate `design_context_pack` for Claude Design.
3. Regenerate this sync manifest.
4. Update the matching Figma component and its node-specific URL.
5. Publish Code Connect only where the plan supports it.
6. Run component, context-pack, sync-manifest, Widgetbook, and drift gates.

The first live vertical slice is `catch.badge` plus `catch.field`. Scale to the
remaining concepts only after both components pass the full loop.
