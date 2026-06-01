---
doc_id: catch-ui-lint-rules-plan
version: 0.3.0
updated: 2026-06-02
owner: ui_elevation_initiative
dri: TBD
status: remaining_work
priority: P1
sprint: unscheduled
---

# Catch UI Lint Rules - Remaining Roadmap

The P0 lint package has landed in the live worktree. This roadmap keeps only the
unimplemented or still-weak lint/governance work.

## Implemented Baseline

- Local analyzer plugin: `packages/catch_ui_lints`.
- Enabled through `analysis_options.yaml` and verified by `tool/check_catch_ui_lints.sh`.
- Current diagnostics:
  - `catch_no_raw_ui_spacing`
  - `catch_no_token_arithmetic`
  - `catch_use_section_list`
  - `catch_prefer_semantic_insets`
  - `catch_event_detail_prefers_photo_thumbnail`
  - `catch_no_raw_material_control`
  - `catch_no_raw_color`
  - `catch_no_raw_text_style`
  - `catch_no_raw_font_drift`
  - `catch_no_raw_radius`
  - `catch_no_raw_content_dimension`
  - `catch_no_local_design_constant`
  - `catch_no_raw_icon_source`
  - `catch_no_raw_icon_size`
  - `catch_no_raw_alpha`
  - `catch_no_raw_shadow`
  - `catch_no_raw_motion`
  - `catch_no_raw_breakpoint`
  - `catch_no_raw_surface_shell`
  - `catch_no_allow_debt`
  - `catch_no_widget_returning_method`
- Semantic spacing exists through `CatchGaps`, `CatchInsets`, and the UI architecture
  docs.
- Color/text/font drift count is currently `0` via `tool/check_catch_ui_lint_drift.sh`.
- P0 alignment gaps from `catch_ui_lint_p0_spec.md` are closed: no retired sandbox
  exclusions, line-level art exceptions instead of whole-file color exemptions,
  completed radius coverage, narrowed Chip/Card/Badge material-control scope, and
  analyzer-backed local-constant/allow-debt counts.
- Former shell scanner entry points are now analyzer-output wrappers:
  `check_sizing.sh`, `check_ui_local_constant_wrappers.sh`,
  `check_ui_system_raw_values.sh`, and `check_ui_allow_debt.sh`.
- The shared shell scanner helper is retired because no scanner wrapper consumes it.

## Phase 0 - Token Foundation Still Open

1. **F2: token-source detection hardening.**
   - Live rules are still parsed-AST and name-based.
   - Keep this open for rules that need real symbol identity or shadowing protection.

2. **F3: missing token categories.**
   - Add or explicitly reject `CatchBreakpoints`.
   - Add or explicitly reject a layering/z-index token (`CatchZIndex` or equivalent).
   - Decide whether `CatchMapPinColors` and activity/map palettes should become tiered
     semantic tokens or stay sanctioned expressive art.

3. **F4: document the token tier model.**
   - `docs/ui_architecture.md` documents semantic spacing.
   - `docs/design_language.md` documents identity and color principles.
   - A concise tier model/naming rule is still missing if future lint messages need a
     stable rationale link.

## Phase 1 - P0 Alignment Gaps

The implementation now matches the narrowed P0 scope documented in
`catch_ui_lint_p0_spec.md`. Keep future changes in that file if a P0 rule is widened
again.

## Phase 1.5 - Scanner Family Migration

Closed on 2026-06-02. The deterministic scanner surfaces now live in
`packages/catch_ui_lints`; the historical root commands are analyzer-report
wrappers only.

## Phase 2 - P1 Rule Candidates

Implement only after the current scanner/lint policy is stable.

- Group A value rules: raw stroke and any shadow/opacity/icon/motion refinements that
  need resolved symbol identity beyond the migrated parsed-AST checks.
- Group B primitive bypass: preferred Catch image primitive and calibrated
  card/surface refinements beyond `catch_no_raw_surface_shell`.
- Group C component proliferation: private widget complexity and max build nesting depth.
- Group D boundaries: import boundaries, raw values only in theme, single icon set.
- Group E accessibility: required semantic labels for icon-only controls and meaningful
  images.

## Phase 3 - P2 / Advanced Candidates

- Raw aspect ratio.
- Magic breakpoint.
- Direct `Theme.of(context).colorScheme` strictness.
- Raw asset path.
- Duplicate subtree detection.
- Minimum tap target.
- Raw user-facing string / l10n policy.

## Phase 4 - Governance Loop

1. **Visual-regression gate.**
   - The UI capture and golden infrastructure exists, but full visual review is not a
     required PR gate.

2. **Deprecation + codemods.**
   - Built-in `deprecated_member_use_from_same_package` can enforce deprecated tokens and
     primitives, but the design-system workflow is not yet formalized.

3. **Drift metric.**
   - Counts exist for some scanners/lints. A single trend artifact/dashboard does not.

4. **Component lifecycle ownership.**
   - Add a lightweight proposal/review flow before adding shared primitives if component
     sprawl keeps recurring.

## Parked / Not Worth Right Now

- Do not move all rules to resolved AST preemptively. Do it per rule when parsed matching
  cannot give a defensible signal.
- Do not add Style Dictionary/DTCG codegen unless token editing leaves Dart or a second
  platform needs the same source.
- Do not build duplicate dashboard infrastructure while scanner/lint output already gives
  a cheap count.

## Verification Commands

```bash
bash tool/check_catch_ui_lints.sh
bash tool/check_catch_ui_lint_drift.sh --count
bash tool/check_sizing.sh --count
bash tool/check_ui_local_constant_wrappers.sh --summary
bash tool/check_ui_system_raw_values.sh --count
bash tool/check_ui_allow_debt.sh --summary
flutter analyze --no-fatal-infos
```
