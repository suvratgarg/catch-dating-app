# Catch UI Enforcement System Spec (for Codex)

Status: draft v0.1.0 · all phases gated as marked · 2026-07-19
Scope: `packages/catch_ui_lints/`, `tool/check_catch_ui_lint*.sh`, `tool/check_*_raw_*.sh`, `tool/widget_cleanup_scan.sh`, `tool/audit/widget_cleanup_baseline.json`, `.github/workflows/flutter-ci.yml`, `design/components/`, `design/screens/`, `lib/core/widgets/`, `lib/core/presentation/`
Companions: [`catch_ui_lint_rules_plan.md`](catch_ui_lint_rules_plan.md) (Group A–E catalog, superseded where this spec disagrees), [`catch_ui_lint_p0_spec.md`](catch_ui_lint_p0_spec.md) (executed), [`catch_field_section_system_spec.md`](catch_field_section_system_spec.md) (field/section anatomy this spec enforces), `reconciliation_recovery_audit_20260716.md` §8–9 (prevention doctrine)
Origin: 2026-07-19 owner + Claude deep read of the full plugin (2,036 lines), all
scanner/wrapper/harness sources, plus live probe experiments. Every number below
was measured against main (`2bcd93270`) that day; §1 includes the census
commands so the numbers can be re-run.

Items marked `⚠ OWNER` need explicit go-ahead; everything else is ratified by
this doc.

---

## 0. Doctrine (owner-ratified, binding on every phase)

1. **Success = drift surfaced AND fixed.** A green gate over a baselined mess is
   wallpaper. Baselines exist to be burned down, never to grow quietly.
2. **Severity ladder**: every rule ships at `INFO` (surface), findings get fixed
   or narrowly sanctioned, then the rule is promoted to `WARNING` and given a
   blocking tree-wide gate. **Never promote a rule into an ungated severity** —
   as of 2026-07-19 that is exactly the live failure (§1.3).
3. **Anti-vacuity is universal**: a rule that is not proven to fire (seeded
   probe) is treated as not existing. This extends to gates: a gate whose
   engine can silently skip the plugin is vacuous.
4. **Enforcement lives at the cheapest layer that makes the wrong thing
   impossible**: primitive API > analyzer plugin > analyzer-CLI checker >
   ratchet script (see §2).
5. **Exceptions are narrow, in-code, and documented** — the
   `theme-independent art` allow-line pattern is the template. No blanket file
   or directory exemptions beyond the existing `lib/labs/` + `explore_concept`
   prototype carve-out.

## 1. Verified state — 2026-07-19 census

### 1.1 What exists

- Plugin: 31 diagnostic codes in one `MultiAnalysisRule` + one visitor
  (`packages/catch_ui_lints/lib/src/catch_ui_rules.dart`, 2,036 lines,
  `canUseParsedResult: true`, all detection name/pattern-based).
- Wrappers `check_sizing.sh`, `check_ui_local_constant_wrappers.sh`,
  `check_ui_allow_debt.sh`, `check_ui_system_raw_values.sh` are thin shells over
  `check_catch_ui_lint_drift.sh` (runs `dart analyze --format machine` from repo
  root, filters by code).
- `tool/check_catch_ui_lints.sh`: seeded-probe harness (29 of 31 codes probed) +
  clean probes + one embedded `rg` rule (`catch_screen_gutter_uses_semantic_insets`).
- `tool/widget_cleanup_scan.sh`: 26 regex/context categories with ratchet
  baseline `tool/audit/widget_cleanup_baseline.json` (42 live findings vs 49
  maxima; **not CI-gated** — agent-pass discipline only).
- Allow markers in `lib/`: **0**. `catch_no_allow_debt` also catches
  `// ignore: catch_*`.

### 1.2 Live drift (tree-wide, `--all`)

`bash tool/check_catch_ui_lint_drift.sh --all --summary` → **191 findings, 15
codes**:

| severity | code | count |
|---|---|---|
| INFO | catch_prefer_semantic_insets | 65 |
| WARNING | catch_no_token_arithmetic | 20 |
| INFO | catch_no_nested_rounded_rectangles | 19 |
| INFO | catch_no_raw_surface_shell | 16 |
| INFO | catch_no_raw_motion | 13 |
| INFO | catch_no_widget_returning_method | 10 |
| INFO | catch_no_raw_icon_size | 9 |
| INFO | catch_no_raw_button_control | 7 |
| INFO | catch_no_raw_alpha | 7 |
| INFO | catch_mutation_pending_requires_error | 7 |
| INFO | catch_no_raw_stroke_width | 5 |
| WARNING | catch_no_raw_ui_spacing | 4 |
| WARNING | catch_no_raw_color | 4 |
| INFO | catch_no_raw_breakpoint | 4 |
| WARNING | catch_no_raw_text_style | 1 |

The 29 WARNING-level findings: the 4 colors are the theme-independent art files
(`graded_image.dart`, `event_activity_visuals.dart`); the 1 TextStyle is the
documented map-pin bitmap painter (`event_pins_map.dart:740`); the 20
token-arithmetic hits are untriaged.

### 1.3 The enforcement gaps (measured, not hypothetical)

1. **`flutter analyze` does not load the analyzer plugin.** CI's
   "Static analysis" step (`flutter analyze --no-fatal-infos`) has never run a
   catch rule. Verified by comparing `flutter analyze` (0 catch diagnostics)
   against `dart analyze <file>` (diagnostics present) on identical trees.
2. **`dart analyze lib` (subdirectory target) also skips the plugin**; only
   repo-root invocation loads it. Local verification with the wrong form
   reports a falsely clean tree.
3. Of 31 codes, only **3** have blocking tree-wide CI gates
   (`catch_no_raw_content_dimension`, `catch_no_local_design_constant`,
   `catch_no_allow_debt` — all genuinely at 0). The other 28 codes gate
   nothing; the 191 findings above are invisible to CI.
4. **Bug**: `_isRoundedCatchField` (catch_ui_rules.dart ≈1074–1099) returns
   `false` on every path — the flat variants each return false and so does the
   fallthrough, so a default boxed `CatchField` never counts as a rounded
   surface and `catch_no_nested_rounded_rectangles` undercounts.
5. **Probe gaps**: `catch_no_raw_letter_spacing` and
   `catch_no_direct_font_builder` have no seeded probe.
6. **Toolchain blocker**: recompiling the plugin crashes local `dart analyze`
   (documented in `tool/check_no_raw_network_image.sh` header). Plugin edits are
   currently only verifiable in CI.
7. `catch_no_widget_returning_method` sees method declarations only; local
   `Widget _build…()` functions inside `build` escape.
8. Dead condition at catch_ui_rules.dart:714 (`|| name == 'build'` unreachable).

### 1.4 Census commands

```sh
bash tool/check_catch_ui_lint_drift.sh --all --summary   # tree drift by code
bash tool/widget_cleanup_scan.sh --check                 # ratchet vs baseline
rg -o ':allow:' lib --no-filename | wc -l                # allow markers
bash tool/check_catch_ui_lints.sh                        # anti-vacuity probes
flutter analyze --no-fatal-infos                         # generic lints ONLY (no plugin)
dart analyze <single-file>                               # plugin loads
```

---

## 2. Architecture: four enforcement vehicles

| Vehicle | What it is | Use for |
|---|---|---|
| **A. Primitive API** | Required slots/parameters on Catch widgets | State exhaustiveness (empty/error slots), geometry ownership — make wrong usage unrepresentable |
| **B. Analyzer plugin** | `catch_ui_lints`, parsed AST, in-IDE | File-local, name-detectable: steering (raw X → CatchX), slot composition inside one file, literal/token policies |
| **C. Analyzer-CLI checker** | Standalone Dart tool on `package:analyzer` with resolution, the `tool/architecture/provider_graph.dart --check` pattern | Cross-file composition: route→shell conformance, screen-registry conformance, alias-proof import policies. No plugin-recompile constraint, full type resolution |
| **D. Contract generation + coverage gate** | Tables and probes generated from `design/components/` + `design/screens/`; a bidirectional completeness check | Exhaustiveness: the catalog *is* the rule source; a primitive without enforcement fails CI |

Decision rule: if the wrong code can be made uncompilable by an API, do A. If
detection needs only names/structure within one file, do B. If it needs types,
imports-as-resolved, or more than one file, do C. D closes the loop over all of
them.

---

## 3. Phase 0 — repair the pipeline (prerequisite for everything)

- **0.1 Toolchain**: diagnose and fix the plugin recompile crash so
  `dart analyze` survives a fresh plugin compile locally. Acceptance: edit a
  comment in `catch_ui_rules.dart`, run `dart analyze` from root, get
  diagnostics not a crash. If genuinely unfixable, ratify the CI-verified edit
  loop in `AGENTS.md` and this spec — but try first (suspects: stale
  `.dart_tool` plugin isolate cache, analyzer/SDK version skew between
  `packages/catch_ui_lints` and the app).
- **0.2 Clear the 29 WARNING findings** so gating is possible:
  - Triage the 20 `catch_no_token_arithmetic` hits: move real layout math into
    named `CatchLayout`/`CatchSpacing` helpers; genuinely local math gets a
    narrow allow line with reason. `⚠ OWNER` reviews the split.
  - Sanction the 5 legitimate exceptions (4 art-file colors, 1 bitmap-painter
    TextStyle) via the `theme-independent art` allow-line mechanism — extend
    `_isThemeIndependentArtAllow`'s path list to
    `lib/events/presentation/widgets/event_pins_map.dart`. `⚠ OWNER` per file.
- **0.3 Wire the missing tree gates** in `flutter-ci.yml`: one step per
  warning-stage code group via
  `bash tool/check_catch_ui_lint_drift.sh --code "<regex>" --label "<label>"`
  (the script already exits 1 on findings). Cover: spacing, color,
  text-style+font+letter-spacing+direct-font-builder, radius,
  token-arithmetic, section-list, field/section named constructors,
  event-detail thumbnail. Acceptance: a seeded violation on a branch turns the
  new step red.
- **0.4 Fix `_isRoundedCatchField`** (fallthrough returns `true` for the boxed
  variant) + add a CatchField-nesting seeded probe. Expect the
  nested-rounded INFO count to rise; record the new number in the drift JSON
  artifact, do not suppress it.
- **0.5 Add the two missing probes** (letter-spacing, direct-font-builder) to
  `check_catch_ui_lints.sh`.
- **0.6 Footguns + nits**: document the `flutter analyze` / `dart analyze lib`
  plugin-loading behavior in `TESTS.md` and `tool/README.md`, and add an
  AGENTS.md routing note ("catch lint verification = drift script or
  `dart analyze` from root, never `flutter analyze`"). Remove the dead
  condition (1.3.8). Extend `catch_no_widget_returning_method` to local and
  top-level functions.

## 4. Phase 1 — scanner→lint promotions and retirements

Each promotion ships with: detection spec implemented in vehicle B, a seeded
probe, an INFO rollout, and retirement of its shell counterpart only after a
seeded-fixture parity proof (a green-tree diff proves nothing).

1. `catch_no_raw_network_image` — replace `tool/check_no_raw_network_image.sh`
   (its header already reserves the code name). `Image.network` steering →
   `CatchNetworkImage`; `lib/core/widgets/**` exempt.
2. `catch_no_presentation_platform_import` — import directives for
   url_launcher/connectivity_plus/firebase_messaging/image_picker/share_plus in
   presentation code (port the scanner's sanctioned-path globs as the initial
   exception list; migrate to C later for alias-proofing).
3. `catch_no_tokens_prop_drilling` — `final CatchTokens tokens` fields /
   `required this.tokens` params.
4. `catch_no_presentation_repository_reach` — `ref.watch|read(...RepositoryProvider…)`
   name-suffix detection in presentation.
5. `catch_no_legacy_spacing_token` — `Sizes.p*` identifiers (both the 4-point
   and fine-grained sets; scanner categories are at 0, this is regression
   guard).
6. `catch_no_low_level_typography_role` — `CatchTextStyles.bodyS|bodyM|titleS(`
   invocations outside the three sanctioned primitive files.
7. `catch_screen_gutter_uses_semantic_insets` — move the `rg` block out of the
   probe harness into a real rule (named page-gutter constants rebuilt from
   `CatchSpacing` → `CatchInsets.pageBody*` roles).
8. `catch_text_requires_style` — the big one: `Text(` without a `style:`
   argument and without a sanctioned ancestor (SnackBar content, PopupMenuItem
   child, Badge label, AlertDialog title). AST ancestry replaces the scanner's
   fragile ±6-line window. Burns down the 27-slot `unstyled_text_candidates`
   baseline. Ships INFO + ratchet, promotes at zero.
9. Test-side rules (relax the plugin's `/lib/`-only path gate per rule, scoped
   to `test/` + `integration_test/`): `catch_no_brittle_pump_timing`
   (`pumpAndSettle(`, `pump(const Duration`, `warnIfMissed: false`),
   `catch_no_positional_widget_finder` (`find.x(...).at|first|last`),
   `catch_no_async_flush_hack` (`Future<void>.delayed(Duration.zero)`).
10. **Retire without promotion**: `nonzero_letter_spacing_candidates`
    (redundant with the existing lint, both at 0);
    `raw_decorated_surface_candidates` (reconcile with
    `catch_no_raw_surface_shell`, keep the lint); the five profile-campaign
    one-off categories at 0 (`profile_*`) — finished campaigns.
11. **Gate the ratchet**: add `bash tool/widget_cleanup_scan.sh --check` as a
    flutter-ci step so baseline re-seeding (0 → 49 happened between 07-03 and
    07-12) can never again occur silently. Baseline increases require a diff to
    `tool/audit/widget_cleanup_baseline.json` that review can see. `⚠ OWNER`
    ratifies the current 49 maxima as the burn-down list.

## 5. Phase 2 — placement & composition rules ("right widget, right place")

Each rule: intent, vehicle, detection, exceptions, probe, INFO rollout. All
policies `⚠ OWNER` before implementation.

- **5.1 Top bar.**
  - B: steering — add `AppBar`, `SliverAppBar`, `CupertinoNavigationBar` to the
    raw-control constructor set outside `lib/core/widgets/` →
    "use `CatchTopBar`".
  - B: slot composition — inside a `CatchTopBar(actions:|leading:…)` argument,
    a raw `Row`/ad-hoc children list is flagged → `CatchTopBarActionGroup`
    (geometry-owned-by-primitive doctrine; the primitive exists at
    `lib/core/widgets/catch_top_bar.dart:73`).
  - C: per-screen top-bar variant conformance against the screen registry
    (§6.4).
- **5.2 App shell.**
  - B: only `lib/core/presentation/app_shell.dart` / `host_app_shell.dart` may
    instantiate the tab scaffold / root `Scaffold` with a bottom navigation
    slot.
  - C: no feature screen reachable under a shell route may nest its own
    `Scaffold` (route graph walk; requires resolution — this is the flagship
    C-vehicle rule).
  - **Dependency**: reconciliation audit §5.2 (finish or retire
    `CatchAdaptiveTabScaffold`) must be decided first; enforcing "the shell" is
    incoherent while the shell itself is half-migrated. `⚠ OWNER`.
- **5.3 Field/Section placement.** B: a `CatchField` outside a
  `CatchSection`/`fieldRows`/`CatchFieldLanes`/form-schema context is flagged
  (file-local ancestor walk; the named-constructor rules from
  [`catch_field_section_system_spec.md`](catch_field_section_system_spec.md)
  already enforce anatomy selection — this adds *situation* enforcement).
  Cross-file composition moves to C when the Phase D form schema lands.
- **5.4 State surfaces (loading / error / empty / data).**
  - A first: list/section primitives that render collections grow a required
    empty-state slot (e.g. `CatchSectionList` requires `emptyBuilder` or an
    explicit `emptyStateOmitted` opt-out named in code). `⚠ OWNER` API change.
  - B: `catch_async_requires_state_surface` — an `AsyncValue` obtained via
    `ref.watch(...)` whose `.when(` lacks `error:` or `loading:` named
    arguments, or any `.requireValue`/`.value!` in presentation code, is
    flagged → route through `CatchAsyncValueView` (exists:
    `lib/core/widgets/catch_async_value_view.dart`), `CatchErrorState`,
    `CatchEmptyState`. Implementation reuses the
    `catch_mutation_pending_requires_error` visitor pattern (variable-binding +
    coverage walk), which is the proven template for this rule class.
  - B: promote the `raw_error_surface_candidates` scanner into steering
    (`Center(child: Text('…failed…'))` shapes → `CatchErrorState`).
- **5.5 Shell-aware composition.** B: `MediaQuery.of(context).size` and
  `LayoutBuilder` in feature presentation are flagged outside sanctioned
  adaptive primitives — breakpoint decisions come from `CatchLayout` roles /
  shell-provided layout context, not per-screen measurement. Promote
  `catch_no_raw_breakpoint` INFO→WARNING when its 4 findings clear.

## 6. Phase 3 — the generative loop (how this stays exhaustive)

The mechanism that converts the UI system into lints *programmatically* rather
than one rule at a time:

- **6.1 Enforcement block in the component contract.** Extend the
  `design/components/catch.components.json` schema so every component entry
  carries:

  ```json
  "enforcement": {
    "code": "catch_no_raw_button_control",
    "vehicle": "plugin | checker | api",
    "replaces": ["ElevatedButton", "TextButton"],
    "placement": { "allowedParents": ["CatchSection"], "slot": "actions" },
    "states": ["loading", "error", "empty"],
    "probeSeed": "ElevatedButton(onPressed: null, child: Text('x'))",
    "waiver": { "reason": "…", "owner": "…", "expires": "2026-09-01" }
  }
  ```

  (`enforcement` or `waiver` is required; absence is a build failure.)
- **6.2 Generator** `tool/design/build_lint_enforcement_tables.mjs` emits:
  1. `packages/catch_ui_lints/lib/src/catch_ui_rules_tables.g.dart` — the
     steering sets and replacement maps the plugin today hardcodes
     (`_rawControlConstructors`, `_rawButtonControlConstructors`,
     `_rawControlReplacements`, …) become generated;
  2. `tool/design/generated/enforcement_expectations.json` for C checkers;
  3. generated probe seeds appended to the harness corpus (every steering rule
     gets its anti-vacuity probe for free).
- **6.3 Coverage gate** `tool/design/check_component_enforcement_coverage.mjs`
  (CI): bidirectional completeness — every catalog component maps to an
  enforcement or an unexpired waiver, and every `catch_*` code maps back to a
  catalog entry. **This is the exhaustiveness property: shipping a new
  primitive without deciding its enforcement fails CI.**
- **6.4 Screen registry conformance.** `design/screens/catch.screens.json` rows
  gain `shell`, `topBar`, and `statePolicy` columns; a C checker validates
  every registered screen (and the capture catalog already inventories the
  screen set, so unregistered screens are detectable).
- **6.5 Governance**: waivers expire and expired waivers fail the coverage
  gate; every rule's count is exported as a drift JSON artifact
  (`--json` mode exists); ratchet counts may only decrease.

## 7. Severity/rollout ladder (applies to every new rule)

INFO + drift JSON → findings fixed or waived → WARNING → wrapper/CI gate →
(where applicable) shell scanner or ratchet category retired with fixture
parity proof. No step may be skipped; §1.3 is what skipping looks like.

## 8. Acceptance per phase

- P0: drift `--all` count = 162 (INFO only, plus the re-baselined
  nested-rounded delta from the bug fix); all WARNING codes tree-gated in CI;
  probes cover 31/31 codes; plugin edit verified locally (or CI loop ratified).
- P1: each promoted rule has probe + parity fixture; retired scanner categories
  deleted from `widget_cleanup_scan.sh` and baseline; ratchet CI-gated.
- P2: each placement rule at INFO with a published drift count and an owner
  decision log line.
- P3: coverage gate green means: components without enforcement = 0, orphan
  lint codes = 0, expired waivers = 0.

## 9. Risks & limits

- Parsed-AST rules are alias-blind (`import … as m; m.TextStyle(…)` escapes) —
  accepted for B; C-vehicle checkers are the resolution-backed backstop where
  it matters.
- The recompile crash (0.1) may be environmental; if unfixed, every plugin
  phase runs through CI verification — slower but workable (the
  network-image grep documents this pattern today).
- §5.2 shell enforcement is blocked on the adaptive-scaffold owner decision;
  §5.4's API changes touch live feature code — sequence behind the current
  feature branches.
- Generated tables must not regress plugin performance; keep them `const` sets.

## 10. Execution order for Codex

1. Phase 0 (0.1 first; 0.2–0.6 parallelizable after).
2. Phase 1 items 1–7 + 11 (mechanical), then 8 (unstyled-text burn-down), then
   9–10.
3. Phase 2 one surface at a time, each behind its `⚠ OWNER` gate: 5.1 → 5.4 →
   5.5 → 5.3 → 5.2 (last, pending the scaffold decision).
4. Phase 3 schema + generator + coverage gate; migrate hardcoded tables; then
   the registry conformance checker.
