---
doc_id: design_context_pack_plan
version: 0.5.0
updated: 2026-06-17
owner: ui_elevation_initiative
status: remaining_work
---

# Design Context Pack - Remaining Work

The design context pack is mostly implemented. This plan now tracks the live gaps
only.

## Implemented / Closed

- `tool/design/build_context_pack.mjs` exists with update/check modes.
- `tool/design/context_pack_builder_test.dart` generates:
  - `design_context_pack/README.txt`
  - `design_system/tokens.json`
  - `design_system/activity_palette.json`
  - `design_system/typography.json`
  - `design_system/design_language.txt`
  - `design_system/specimens/catch_design_system.html`
  - `gallery/manifest.json`
  - `MANIFEST.json`
- The extractor executes Flutter code rather than scraping text, so derived activity
  palettes and resolved typography are exported.
- The typography registry has a drift guard against new `CatchTextStyles` methods.
- The component contract registry lives at `design/components/catch.components.json`,
  is validated by `node tool/design/check_component_contracts.mjs`, and is exported
  into the pack as `design_system/components.json`.
- The UI capture DPR bug is fixed: `captureCatchWidget` threads `pixelRatio` into
  `RenderRepaintBoundary.toImage`.
- `tool/ui_capture/run_captures.mjs --profile design-gallery` exists and uses
  3x, theme-first output.
- `design:context-pack` is registered in `tool/tools_manifest.json`.
- Route inventory and capture coverage are current.
- `node tool/design/build_context_pack.mjs --check` passes.
- `design_context_pack/gallery/manifest.json` now lists all 31 live capture entries,
  including `event_detail_member_ticket` and `event_detail_member_spotlight`.

## Remaining Work

1. **Decide gallery image policy.**
   - Current committed pack has only:
     - `design_context_pack/gallery/light/profile_self.png`
     - `design_context_pack/gallery/dark/profile_self.png`
   - `MANIFEST.json` currently has `includesGalleryPngs: false`.
   - Decide whether gallery PNGs are committed, generated-only, or split so only selected
     reference shots are committed.

2. **Empirically validate the usage/cost assumption.**
   - The "small pack is cheaper than repo crawl" premise is reasonable but not measured.
   - First real Claude Design refresh should record the observed upload/context cost and
     whether partial Remix updates actually avoid full re-ingestion.

3. **Document the operational workflow once the pack policy is settled.**
   - Keep the current `.txt`/`.html`/`.json`/`.png` upload format decision.
   - Add the exact update/check commands to the owner doc or `tool/README.md` after the
     generated-vs-committed gallery decision is final. The component registry side
     is now documented in `docs/ui_architecture.md` and `design/components/README.md`.

## Parked / Not Worth Right Now

- Do not ship raw `docs/visual_references/*.html`; they contain rejected design
  candidates. The curated specimen is the correct upload surface.
- Do not bundle font binaries unless offline byte-identical specimen rendering becomes
  necessary.
- Do not upload all gallery PNGs to a normal chat by default; use selected screenshots
  unless doing a deliberate system-wide consistency pass.

## Verification Commands

```bash
node tool/ui_capture/check_route_inventory.mjs --check
node tool/ui_capture/check_capture_coverage.mjs --check
node tool/design/build_context_pack.mjs --check
node tool/design/build_context_pack.mjs --render-gallery
node tool/ui_capture/run_captures.mjs --profile design-gallery
```
