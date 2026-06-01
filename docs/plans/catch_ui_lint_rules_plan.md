---
doc_id: catch-ui-lint-rules-plan
version: 0.2.0
updated: 2026-06-01
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
  - `catch_no_widget_returning_method`
- Semantic spacing exists through `CatchGaps`, `CatchInsets`, and the UI architecture
  docs.
- Color/text/font drift count is currently `0` via `tool/check_catch_ui_lint_drift.sh`.
- P0 alignment gaps from `catch_ui_lint_p0_spec.md` are closed: no retired sandbox
  exclusions, line-level art exceptions instead of whole-file color exemptions,
  completed radius coverage, narrowed Chip/Card/Badge material-control scope, and zero
  local-constant/allow-debt shell counts.

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

Keep this as the next concrete enforcement milestone.

1. **`catch_no_raw_content_dimension` from `check_sizing.sh`.**
   - Current shell count is `0`.
   - Migration is optional until the shell gate becomes maintenance burden.

2. **`catch_no_local_design_constant` from `check_ui_local_constant_wrappers.sh`.**
   - Current shell count is `0`.
   - The scanner allows token-backed named `EdgeInsets` contracts and still flags raw
     private constants.

3. **Fold `check_ui_system_raw_values.sh` into analyzer rules.**
   - Current shell count is `0`.
   - Only migrate if it prevents real regression beyond the existing plugin rules.

4. **Keep or retarget `check_ui_allow_debt.sh`.**
   - Current count is `0`.
   - This meta-gate may stay shell-based because analyzer rules do not naturally count
     their own suppressions across the tree.

5. **Retire `tool/lib/scanner_shell.sh` only after all shell consumers are gone.**
   - Do not remove it while any root scanner still sources it.

## Phase 2 - P1 Rule Candidates

Implement only after the current scanner/lint policy is stable.

- Group A value rules: raw stroke, shadow/elevation, opacity, icon size, and motion.
- Group B primitive bypass: ad-hoc card/surface detection and preferred Catch image
  primitive.
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
