---
doc_id: cryptic-hatching-hummingbird
version: 2.1
updated: 2026-06-01
owner: ui_elevation_initiative
status: superseded_remaining_work_only
---

# Superseded UI Elevation Plan

This plan is superseded. The active sources are:

- `docs/design_language.md` for the locked visual identity.
- `docs/ui_elevation_implementation.md` for implementation status.
- `docs/ui_architecture.md` for layout, spacing, sizing, and scroll rules.
- `docs/plans/catch_ui_debt_inventory.md` for remaining UI debt triage.
- `docs/plans/catch_ui_lint_rules_plan.md` and `catch_ui_lint_p0_spec.md` for lint
  enforcement gaps.

Do not implement the old phase text from this file. It contained pre-decision ideas
such as Instrument Serif, a global accent, grep-only gates, and exploratory lab
directions that no longer match the repo.

## Implemented / Moved Elsewhere

- The editorial B&W identity is locked in `docs/design_language.md`.
- `CatchTokens`, `ActivityPalette`, bundled fonts, optical sizing, and the matte photo
  grade exist in code.
- `ProfileSurface` / `CatchProfileView` is the live flagship profile surface for
  Catches, preview, and public profile.
- Sizing doctrine is documented and `tool/check_sizing.sh --count` returns `0`.
- Raw color/text/font drift is analyzer-backed and
  `tool/check_catch_ui_lint_drift.sh --count` returns `0`.
- The `eventTicketMediaHeight = 136` item is stale; ticket media now derives from
  constraints/aspect ratio.
- `ClubCoverFallback` is gone; do not keep a backlog item to delete it.
- `tool/check_design_tokens.sh` and `tool/check_raw_color_sweep.sh` are gone; use the
  Catch UI analyzer plugin and current scanner scripts.
- `tool/check_ui_local_constant_wrappers.sh --summary` and
  `tool/check_ui_allow_debt.sh --summary` return `0`.
- `tool/design/design_personality_preview_app.dart` and
  `tool/design/render_design_personality_previews.dart` no longer reference the retired
  Electric Sunset/Nitron exploration names.
- `_ExploreClubCover` now wraps uploaded club photos in `GradedImage` and keeps
  `ClubPolaroidArtwork` as the no-photo fallback.
- Text-scale `2.0` capture proof now passes for `profile_self`,
  `onboarding_welcome`, `event_detail_member`, `host_live_console`,
  `settings_account`, `payment_history_empty`, and `event_success_companion`.
- The onboarding welcome screen now scrolls under large Dynamic Type instead of
  overflowing.
- `docs/ui_modernization_backlog.md` no longer asks to delete the already-retired
  `ClubCoverFallback`.

## Remaining Work From This Old Plan

1. **Map-pin palette decision.**
   - `event_pin_renderer.dart` still uses static `CatchMapPinColors`, including older
     orange values in `catch_tokens.dart`.
   - Either route map pins through `ActivityPalette`/tokens, or document the map-pin
     palette as a sanctioned expressive-art exception in `docs/design_language.md`.

## Verification Commands

```bash
bash tool/check_sizing.sh --summary
bash tool/check_catch_ui_lint_drift.sh --count
bash tool/check_ui_system_raw_values.sh --summary
bash tool/check_ui_local_constant_wrappers.sh --summary
bash tool/check_ui_allow_debt.sh --summary
flutter analyze --no-fatal-infos
flutter test test/goldens
node tool/ui_capture/run_captures.mjs --ids profile_self,onboarding_welcome,event_detail_member,host_live_console,settings_account,payment_history_empty,event_success_companion --text-scale 2.0 --output-dir /private/tmp/catch-ui-elevation-audit --device iphone-17-pro --pixel-ratio 2.0 --output-layout theme-first
```
