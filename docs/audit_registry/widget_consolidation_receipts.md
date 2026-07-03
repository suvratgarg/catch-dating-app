---
doc_id: widget_consolidation_receipts
version: 0.2.0
updated: 2026-07-02
owner: widget_consolidation
status: active
---

# Widget Consolidation Receipts

Receipts for the mechanical widget-consolidation pipeline. This file records
commands, headline numbers, manual spot-checks, and known limitations. Review
decisions belong in `docs/design_parity/widget_consolidation/`, not here.

## 2026-07-02 Phase A/B Startup

Scope:

- Phase A extractor package under `tool/widget_dedupe/`.
- Phase B similarity registry builder under `tool/design/build_widget_similarity.mjs`.
- Seeded structural probes under `tool/widget_dedupe/fixtures/`.
- Checked registry: `docs/audit_registry/widget_similarity.json`.

Commands run:

- `node tool/agent/context_pack.mjs --task widget-consolidation-pipeline-phase-ab --paths docs/plans/widget_consolidation_pipeline_spec.md,tool/design,tool/widget_dedupe,docs/audit_registry/widget_similarity.json,docs/audit_registry/widget_classification.json,design/components/catch.components.json`
- `/Users/suvratgarg/development/flutter/bin/dart tool/audit_registry.dart refresh`
- `/Users/suvratgarg/development/flutter/bin/dart analyze --no-fatal-warnings tool/widget_dedupe`
- `/Users/suvratgarg/development/flutter/bin/dart test tool/widget_dedupe/test/fingerprint_extractor_test.dart`
- `env DART=/Users/suvratgarg/development/flutter/bin/dart node tool/design/check_widget_dedupe_probes.mjs`
- `node tool/design/generate_widget_classification.mjs`
- `node tool/design/check_widget_classification.mjs`
- `/Users/suvratgarg/development/flutter/bin/dart run tool/widget_dedupe/bin/extract_fingerprints.dart`
- `node tool/design/build_widget_similarity.mjs`
- `node tool/design/build_widget_similarity.mjs --check`
- `node tool/run.mjs check --manifest-only`

Headline numbers:

| metric | value |
|---|---:|
| classification entries | 1,172 |
| widget classes fingerprinted | 1,067 |
| fingerprint failures | 0 |
| token classes discovered from `lib/core/theme` | 35 |
| skipped trivial widgets (`tokenStreamLength < 12`) | 196 |
| exact shape clusters | 4 |
| structural clusters | 7 |
| related edges | 13 |
| screen clusters | 3 |
| absorb-candidate clusters | 1 |
| calibrated strong SimHash hamming threshold | 18 |

Usage-count spot check:

| widget | registry count | `rg -w` lines | note |
|---|---:|---:|---|
| CatchSurface | 334 | 334 | matches |
| CatchSkeleton | 273 | 273 | matches |
| CatchField | 217 | 217 | matches |
| CatchBadge | 202 | 202 | matches |
| CatchButton | 177 | 177 | matches |
| ProfilePhoto | 94 | 89 | multiple same-line matches explain the count/line delta |
| CatchSection | 63 | 63 | matches |
| CatchTopBar | 49 | 49 | matches |
| CatchErrorBanner | 47 | 47 | matches |
| CatchIconButton | 47 | 47 | matches |
| CatchErrorState | 41 | 41 | matches |
| CatchFormFieldLabel | 36 | 36 | matches |
| CatchEmptyState | 35 | 35 | matches |
| CatchSelectChip | 35 | 35 | matches |
| HostClubsScreen | 33 | 33 | matches |
| CatchBottomDock | 32 | 32 | matches |
| CatchPersonAvatar | 29 | 29 | matches |
| CreateClubScreen | 29 | 29 | matches |
| CatchErrorScaffold | 25 | 25 | matches |
| CatchInlineErrorState | 25 | 25 | matches |

Known limitation:

`WIDGET-CONSOLIDATION-001`: the four spec-listed name-visible families do not
cross the structural related threshold in this first extractor:

| family | best observed Jaccard | status |
|---|---:|---|
| `ChatShareCard` / `ClubShareCard` / `EventShareCard` | 0.1481 | not related |
| `DarkPill` / `EventSuccessDarkPill` | 0.0870 | not related |
| `CountdownBeatPill` / `CountdownCuePill` | 0.0980 | not related |
| `DashboardFocusLoadingCard` / `DashboardStrideLoadingCard` / `ClubDirectorySkeletonCard` | 0.1538 | not related |

Do not lower thresholds to force these into the registry. The next Phase B
normalization pass should decide whether a second coarse skeleton signal is
needed, or whether these examples are better handled by the visual detector in
Phase C.

Handoff note:

- Phase C visual fingerprints, Phase D packets, and Phase E/F ratchets are not
  implemented in this slice.
- The classification registry was stale against the current checkout before this
  pass; it was regenerated and `node tool/design/check_widget_classification.mjs`
  passed before fingerprint generation.

## 2026-07-02 Phase A/B v0.2 Detector Refresh

Scope:

- Dual fine/coarse fingerprint streams per spec v0.2.0.
- Coarse 2-gram shingles for structural math.
- Small-widget token-multiset detector for compact pills/badges.
- Detector-ranked pair queue seeded from top structural/containment scores and
  one representative pair per name family.
- Ground-truth recall table regenerated in
  `docs/audit_registry/widget_similarity.json`.

Commands run:

- `node tool/agent/context_pack.mjs --task widget-consolidation-v020-detectors --paths docs/plans/widget_consolidation_pipeline_spec.md,tool/widget_dedupe,tool/design/build_widget_similarity.mjs,tool/design/check_widget_dedupe_probes.mjs,docs/audit_registry/widget_similarity.json,docs/audit_registry/widget_consolidation_receipts.md,docs/audit_registry/widget_classification.json`
- `/Users/suvratgarg/development/flutter/bin/dart tool/audit_registry.dart refresh`
- `/Users/suvratgarg/development/flutter/bin/dart format tool/widget_dedupe`
- `/Users/suvratgarg/development/flutter/bin/dart analyze --no-fatal-warnings tool/widget_dedupe`
- `/Users/suvratgarg/development/flutter/bin/dart test tool/widget_dedupe/test/fingerprint_extractor_test.dart`
- `node --check tool/design/build_widget_similarity.mjs`
- `node --check tool/design/check_widget_dedupe_probes.mjs`
- `env DART=/Users/suvratgarg/development/flutter/bin/dart node tool/design/check_widget_dedupe_probes.mjs`
- `/Users/suvratgarg/development/flutter/bin/dart run tool/widget_dedupe/bin/extract_fingerprints.dart`
- `node tool/design/build_widget_similarity.mjs`
- `node tool/design/build_widget_similarity.mjs --check`

Headline numbers:

| metric | value |
|---|---:|
| widget classes fingerprinted | 1,067 |
| fingerprint failures | 0 |
| coarse stream | class-only design tokens, sorted argument labels |
| shingle size | 2 |
| skipped trivial widgets (`coarseTokenStreamLength < 8`) | 98 |
| exact shape clusters | 11 |
| structural clusters | 65 |
| structural edges | 160 |
| small-widget edges | 98 |
| ranked pairs | 200 |
| name families | 236 |
| related cross-role edges | 77 |
| screen clusters | 22 |
| absorb-candidate clusters | 10 |
| calibrated strong SimHash hamming threshold | 39 |

Ranked-pair queue composition:

| source | selected pair count |
|---|---:|
| `top-score` | 72 |
| `name-family` | 135 |

Counts can overlap because a pair may be selected by both sources.

Ground-truth recall:

| ground truth | expected detector(s) | observed detector(s) | status | registry example |
|---|---|---|---|---|
| `DarkPill` / `EventSuccessDarkPill` | small-widget structural + name | name, ranked-pair, small-widget, structural | pass | ranked pair 45, score 0.6667 |
| `ChatShareCardSheet` / `CatchShareCardSheet` | ranked pairs | name, ranked-pair | pass | ranked pair 50, containment 0.6857 |
| `ChatShareCard` / `ClubShareCard` / `EventShareCard` | name family | name, ranked-pair | pass | `ShareCard` family |
| `CountdownBeatPill` / `CountdownCuePill` | name family | name, ranked-pair | pass | `CountdownPill` family |
| `Dashboard*LoadingCard` / `ClubDirectorySkeletonCard` | name family + ranked pairs | name, ranked-pair | pass | `LoadingCard` family, ranked pair 144 |

## 2026-07-03 Slice 1 WO-001 Cleanup

Scope:

- Mechanical cleanup for the committed slice-1 consolidation branch.
- Widgetbook use-case identifier repair, orphaned host preview parameter
  cleanup, `CatchSectionHeader.subtitle` catalog coverage, generated
  Widgetbook directory refresh, and widget registry refresh.

Commands run:

- `node tool/agent/context_pack.mjs --task widget-consolidation-wo-001 --paths docs/design_parity/widget_consolidation/codex_worklog.md,docs/design_parity/widget_consolidation/decisions.json,widgetbook/lib/catches/catches_use_cases.dart,widgetbook/lib/user_analytics/user_analytics_use_cases.dart,widgetbook/lib/hosts/host_operations_use_cases.dart,widgetbook/lib/primitives,widgetbook/lib/clubs/club_detail_use_cases.dart,lib/core/widgets,docs/widget_catalog.md,docs/audit_registry/widget_consolidation_receipts.md`
- `dart tool/audit_registry.dart refresh`
- `dart format widgetbook/lib/catches/catches_use_cases.dart widgetbook/lib/hosts/host_operations_use_cases.dart widgetbook/lib/primitives/core_catalog_use_cases.dart`
- `(cd widgetbook && flutter pub get)`
- `(cd widgetbook && dart run build_runner build --delete-conflicting-outputs)`
- `node tool/design/generate_widget_classification.mjs`
- `node tool/design/check_widget_classification.mjs`
- `dart run tool/widget_dedupe/bin/extract_fingerprints.dart`
- `node tool/design/build_widget_similarity.mjs`
- `node tool/design/build_widget_similarity.mjs --check`
- `node tool/design/check_widgetbook_coverage.mjs --check`
- `env DART=/Users/suvratgarg/Development/flutter/bin/dart node tool/design/check_widget_dedupe_probes.mjs`
- `flutter analyze --no-fatal-infos lib`
- `(cd widgetbook && flutter analyze)`
- `bash tool/widget_cleanup_scan.sh --summary`
- `git diff --check`
- `node tool/run.mjs check --manifest-only`
- `node tool/agent/check_agent_readiness.mjs`

Headline numbers:

| metric | value |
|---|---:|
| widget classification entries | 1,174 |
| classification review items | 44 |
| private widget classes flagged | 0 |
| widget fingerprints | 1,066 |
| fingerprint failures | 0 |
| similarity clusters | 62 |
| ranked pairs | 200 |
| name families | 234 |
| absorb candidates | 10 |
| root lib analyzer infos | 192 |
| widget cleanup scan categories with findings | 0 |
| agent readiness score | 100/100 |

Spot checks:

- `rg -n "CatchStatColumne|profileCatchStatColumnes|StatColumns|statColumn" widgetbook/lib/catches/catches_use_cases.dart widgetbook/lib/user_analytics/user_analytics_use_cases.dart widgetbook/lib/main.directories.g.dart` returned no matches.
- `widgetbook/lib/main.directories.g.dart` now points the Catches running use
  case at `profileRunningStates`.
- `_HostManageRouteScope` no longer exposes `themeMode`; it keeps the prior
  default behavior by passing `ThemeMode.light` to `_ThemedHostPreview`.
- `CatchSectionHeader` catalog states now include a subtitle example.
- The repointed club share meta preview remains typed to `CatchMetaRow`.

Known blockers / inherited debt:

- `node tool/design/check_widgetbook_coverage.mjs --check` still fails on the
  existing catalog-or-replace decision queue: 142 public widgets need
  decisions, with 0 stale decisions.
- `(cd widgetbook && flutter analyze)` still fails on 66 existing Widgetbook
  issues, mostly in `lib/hosts/host_operations_use_cases.dart`. The WO-001
  `unused_element_parameter` warning for `_HostManageRouteScope.themeMode` is
  gone.

## 2026-07-03 WO-002 CatchScrim Primitive

Scope:

- New shared `CatchScrim` primitive with detail hero, photo-frame, and profile
  hero tint presets.
- Runtime migration for detail hero media, club directory photo chrome, and
  profile hero media.
- Widgetbook/component-contract repoint from the retired local scrim widgets.
- Widget catalog and generated registry refresh.

Commands run:

- `node tool/agent/context_pack.mjs --task widget-consolidation-wo-002-catch-scrim --paths docs/design_parity/widget_consolidation/codex_worklog.md,docs/design_parity/widget_consolidation/decisions.json,lib/core/widgets/catch_scrim.dart,lib/core/widgets/catch_detail_hero_backdrop.dart,lib/clubs/presentation/discovery/widgets/club_list_tile_parts/directory_card.dart,lib/swipes/shared/profile_surface/catch_profile_view.dart,widgetbook/lib/primitives,widgetbook/lib/clubs/club_detail_use_cases.dart,widgetbook/lib/catches/catches_use_cases.dart,docs/widget_catalog.md,docs/audit_registry/widget_consolidation_receipts.md`
- `dart tool/audit_registry.dart refresh`
- `dart format lib/core/widgets/catch_scrim.dart lib/core/widgets/catch_detail_hero_backdrop.dart lib/clubs/presentation/discovery/widgets/club_list_tile.dart lib/clubs/presentation/discovery/widgets/club_list_tile_parts/directory_card.dart lib/swipes/shared/profile_surface/catch_profile_view.dart widgetbook/lib/catches/catches_use_cases.dart widgetbook/lib/clubs/club_detail_use_cases.dart widgetbook/lib/primitives/primitive_contract_use_cases.dart`
- `(cd widgetbook && flutter pub get)`
- `(cd widgetbook && dart run build_runner build --delete-conflicting-outputs)`
- `node tool/design/generate_widget_classification.mjs`
- `node tool/design/check_widget_classification.mjs`
- `dart run tool/widget_dedupe/bin/extract_fingerprints.dart`
- `node tool/design/build_widget_similarity.mjs`
- `node tool/design/build_widget_similarity.mjs --check`
- `node tool/design/check_widgetbook_coverage.mjs --check`
- `env DART=/Users/suvratgarg/Development/flutter/bin/dart node tool/design/check_widget_dedupe_probes.mjs`
- `node tool/design/check_component_contracts.mjs`
- `node tool/design/check_widgetbook_contract_refs.mjs --check`
- `flutter analyze --no-fatal-infos lib`
- `(cd widgetbook && flutter analyze)`
- `bash tool/widget_cleanup_scan.sh --summary`
- `node tool/run.mjs check --manifest-only`
- `node tool/agent/check_agent_readiness.mjs`
- `git diff --check`
- `rg -n "CatchDetailHeroScrim|ClubPhotoScrim|ProfileHeroScrim" lib widgetbook/lib docs/widget_catalog.md design/components/catch.components.json --glob '!*.g.dart'`

Headline numbers:

| metric | value |
|---|---:|
| widget classification entries | 1,172 |
| classification review items | 44 |
| private widget classes flagged | 0 |
| widget fingerprints | 1,064 |
| fingerprint failures | 0 |
| similarity clusters | 61 |
| ranked pairs | 200 |
| name families | 233 |
| absorb candidates | 9 |
| root lib analyzer infos | 192 |
| widget cleanup scan categories with findings | 0 |
| component contracts | 59 |
| agent readiness score | 100/100 |

Spot checks:

- Stale scrim symbol scan across active lib, Widgetbook source, component
  contract, and widget catalog returned no matches for the retired symbols.
- `widgetbook/lib/main.directories.g.dart` now exposes `CatchScrim` and no
  longer exposes the three retired scrim use cases.
- `design/components/catch.components.json` keeps
  `catch.detail_media.scrim` but points it to `CatchScrim` with the
  `detail-hero`, `photo-frame`, and `hero-tint` states.
- `docs/widget_catalog.md` v2.5.547 records the `CatchScrim` promotion and the
  club/profile catalog rows now refer to the named presets.

Known blockers / inherited debt:

- `node tool/design/check_widgetbook_coverage.mjs --check` still fails on the
  existing catalog-or-replace decision queue: 142 public widgets need
  decisions, with 0 stale decisions.
- `(cd widgetbook && flutter analyze)` still fails on 66 existing Widgetbook
  issues, mostly in `lib/hosts/host_operations_use_cases.dart`.
- `node tool/design/check_widgetbook_contract_refs.mjs --check` still fails on
  unrelated HostOperations preview ids.
- `CatchScrim.photoFrame` preserves the existing
  `CatchOpacity.eventSuccessSubtleBorder` bottom-edge alpha for visual parity;
  the event-specific token name is tracked as a WO-002 escalation.

## 2026-07-03 WO-003 Empty-State Wrapper Inlining

Scope:

- `EventMapEmptyState`, `EventMapNoPinnedEventsState`
- `LaunchAccessDisabledView`, `LaunchAccessSignedOutView`,
  `LaunchAccessStatusView`
- `ProfileUnavailableBody`

Commands:

- `dart tool/audit_registry.dart refresh`
- `node tool/agent/context_pack.mjs --task widget-consolidation-wo-003 --paths lib/events/presentation/event_map_screen.dart,lib/launch_access/presentation/launch_access_application_screen.dart,lib/user_profile/presentation/profile_screen.dart,docs/design_parity/widget_consolidation/codex_worklog.md,docs/design_parity/widget_consolidation/decisions.json`
- `dart tool/audit_registry.dart docs --path widget`
- `dart tool/audit_registry.dart rules --status active`
- `rg -n "EventMapEmptyState|EventMapNoPinnedEventsState|LaunchAccessDisabledView|LaunchAccessSignedOutView|LaunchAccessStatusView|ProfileUnavailableBody" lib widgetbook docs design --glob '!**/*.g.dart'`
- `dart format lib/events/presentation/event_map_screen.dart lib/launch_access/presentation/launch_access_application_screen.dart lib/user_profile/presentation/profile_screen.dart widgetbook/lib/events/event_detail_use_cases.dart widgetbook/lib/profiles/profile_use_cases.dart`
- `flutter pub get` in `widgetbook/`
- `dart run build_runner build --delete-conflicting-outputs` in `widgetbook/`
- `node tool/design/generate_widget_classification.mjs`
- `node tool/design/check_widget_classification.mjs`
- `dart run tool/widget_dedupe/bin/extract_fingerprints.dart`
- `node tool/design/build_widget_similarity.mjs`
- `node tool/design/build_widget_similarity.mjs --check`
- `node tool/design/check_widgetbook_coverage.mjs --check`
- `env DART=/Users/suvratgarg/Development/flutter/bin/dart node tool/design/check_widget_dedupe_probes.mjs`
- `flutter analyze --no-fatal-infos lib`
- `flutter analyze` in `widgetbook/`
- `bash tool/widget_cleanup_scan.sh --summary`
- `node tool/run.mjs check --manifest-only`
- `node tool/agent/check_agent_readiness.mjs`
- `node tool/design/check_widgetbook_contract_refs.mjs --check`
- `node tool/design/check_screen_contracts.mjs --check`
- `node -e "const fs=require('fs'); JSON.parse(fs.readFileSync('design/screens/catch.screens.json','utf8')); console.log('design/screens/catch.screens.json parses')"`
- `node -e "const fs=require('fs'); JSON.parse(fs.readFileSync('docs/audit_registry/doc_versions.json','utf8')); JSON.parse(fs.readFileSync('docs/audit_registry/widget_classification.json','utf8')); JSON.parse(fs.readFileSync('docs/audit_registry/widget_similarity.json','utf8')); console.log('json registries parse')"`
- `git diff --check`

Headline numbers:

| metric | value |
|---|---:|
| widget classification entries | 1,166 |
| classification review items | 44 |
| private widget classes flagged | 0 |
| widget fingerprints | 1,058 |
| fingerprint failures | 0 |
| similarity clusters | 60 |
| ranked pairs | 200 |
| name families | 231 |
| absorb candidates | 9 |
| root lib analyzer infos | 192 |
| widget cleanup scan categories with findings | 0 |
| screen contracts | 35 |
| screen-contract sections | 241 |
| agent readiness score | 100/100 |

Spot checks:

- Stale retired-symbol scan across active `lib`, `widgetbook/lib`,
  `docs/widget_catalog.md`, and `design/screens/catch.screens.json` returned
  no matches.
- `widgetbook/lib/main.directories.g.dart` no longer exposes preview blocks
  typed to `EventMapEmptyState`, `EventMapNoPinnedEventsState`, or
  `ProfileUnavailableBody`; the route/state previews remain.
- `docs/widget_catalog.md` v2.5.548 removes the six wrapper catalog entries
  and keeps ownership on `EventMapView`, `LaunchAccessApplicationScreen`, and
  `SelfProfileTabBody`.
- `design/screens/catch.screens.json` now points the self-profile unavailable
  section at `SelfProfileTabBody`, the branch that owns the inline empty state.
- The old constructor calls were `const`, but the inlined `CatchIcons`
  expressions are not valid constant expressions; the inline bodies therefore
  intentionally cannot remain `const`.

Known blockers / inherited debt:

- `node tool/design/check_widgetbook_coverage.mjs --check` still fails on the
  existing catalog-or-replace decision queue: 139 public widgets need
  decisions, with 0 stale decisions.
- `(cd widgetbook && flutter analyze)` still fails on 65 existing Widgetbook
  issues in `lib/hosts/host_operations_use_cases.dart`.
- `node tool/design/check_widgetbook_contract_refs.mjs --check` still fails on
  unrelated HostOperations preview ids.
- `dart run build_runner build --delete-conflicting-outputs` in `widgetbook/`
  succeeds, but build_runner reports that the delete-conflicting option has
  been removed and is ignored by the current builder.

## 2026-07-03 WO-004 EventCtaStatusLeading

Scope:

- `BookedLeading`
- `AttendedLeading`
- `EventCtaStatusLeading`

Commands:

- `dart tool/audit_registry.dart refresh`
- `node tool/agent/context_pack.mjs --task widget-consolidation-wo-004 --paths lib/events/presentation/widgets/event_detail_cta.dart,widgetbook/lib,docs/design_parity/widget_consolidation/codex_worklog.md,docs/design_parity/widget_consolidation/decisions.json`
- `rg -n "AttendedLeading|BookedLeading|EventCtaStatusLeading" lib widgetbook docs design --glob '!**/*.g.dart'`
- `dart format lib/events/presentation/widgets/event_detail_cta.dart widgetbook/lib/events/event_detail_use_cases.dart widgetbook/lib/primitives/core_catalog_use_cases.dart`
- `flutter pub get` in `widgetbook/`
- `dart run build_runner build --delete-conflicting-outputs` in `widgetbook/`
- `node tool/design/generate_widget_classification.mjs`
- `node tool/design/check_widget_classification.mjs`
- `dart run tool/widget_dedupe/bin/extract_fingerprints.dart`
- `node tool/design/build_widget_similarity.mjs`
- `node tool/design/build_widget_similarity.mjs --check`
- `node tool/design/check_widgetbook_coverage.mjs --check`
- `env DART=/Users/suvratgarg/Development/flutter/bin/dart node tool/design/check_widget_dedupe_probes.mjs`
- `flutter analyze --no-fatal-infos lib`
- `flutter analyze` in `widgetbook/`
- `bash tool/widget_cleanup_scan.sh --summary`
- `node tool/run.mjs check --manifest-only`
- `node tool/agent/check_agent_readiness.mjs`
- `node tool/design/check_widgetbook_contract_refs.mjs --check`
- `rg -n "AttendedLeading|BookedLeading" lib widgetbook/lib docs/widget_catalog.md --glob '!**/*.g.dart'`
- `node -e "const fs=require('fs'); for (const f of ['docs/audit_registry/doc_versions.json','docs/audit_registry/widget_classification.json','docs/audit_registry/widget_similarity.json']) JSON.parse(fs.readFileSync(f,'utf8')); console.log('json registries parse')"`
- `git diff --check`

Headline numbers:

| metric | value |
|---|---:|
| widget classification entries | 1,165 |
| classification review items | 44 |
| private widget classes flagged | 0 |
| widget fingerprints | 1,057 |
| fingerprint failures | 0 |
| similarity clusters | 60 |
| ranked pairs | 200 |
| name families | 231 |
| absorb candidates | 9 |
| root lib analyzer infos | 192 |
| widget cleanup scan categories with findings | 0 |
| agent readiness score | 100/100 |

Spot checks:

- Stale retired-symbol scan across active `lib`, `widgetbook/lib`, and
  `docs/widget_catalog.md` returned no matches for `AttendedLeading` or
  `BookedLeading`.
- `widgetbook/lib/main.directories.g.dart` now exposes
  `EventCtaStatusLeading/Status leading states` and no longer exposes the two
  retired leading components.
- `docs/widget_catalog.md` v2.5.549 records `EventCtaStatusLeading` as the
  feature-level Event Detail CTA terminal-state leading.
- `EventCtaStatusLeading` keeps a `const` constructor, but current
  `CatchIcons` values are not valid constant expressions, so migrated call
  sites are intentionally non-const.

Known blockers / inherited debt:

- `node tool/design/check_widgetbook_coverage.mjs --check` still fails on the
  existing catalog-or-replace decision queue: 139 public widgets need
  decisions, with 0 stale decisions.
- `(cd widgetbook && flutter analyze)` still fails on 65 existing Widgetbook
  issues in `lib/hosts/host_operations_use_cases.dart`.
- `node tool/design/check_widgetbook_contract_refs.mjs --check` still fails on
  unrelated HostOperations preview ids.
- `dart run build_runner build --delete-conflicting-outputs` in `widgetbook/`
  succeeds, but build_runner reports that the delete-conflicting option has
  been removed and is ignored by the current builder.

## 2026-07-03 WO-005 CatchAnalyticsBar

Scope:

- `HostAnalyticsBar`
- `UserAnalyticsBar`
- `CatchAnalyticsBar`
- `CatchPersonRosterLayout` context icon sizing

Commands:

- `dart tool/audit_registry.dart refresh`
- `node tool/agent/context_pack.mjs --task widget-consolidation-wo-005 --paths lib/core/widgets/catch_analytics_bar.dart,lib/hosts/presentation/host_operations_screen.dart,lib/user_analytics/shared/user_analytics_panel.dart,lib/core/widgets/catch_person_row.dart,widgetbook/lib,docs/design_parity/widget_consolidation/codex_worklog.md,docs/design_parity/widget_consolidation/decisions.json`
- `rg -n "CatchAnalyticsBar|HostAnalyticsBar|UserAnalyticsBar|hostStrictCatchAnalyticsBar|hostStrictHostAnalyticsBar|CatchIcon\\.micro|size: 11" lib widgetbook/lib docs/widget_catalog.md docs/design_parity/widget_consolidation docs/audit_registry/doc_versions.json`
- `dart format lib/core/widgets/catch_analytics_bar.dart lib/hosts/presentation/host_operations_screen.dart lib/user_analytics/shared/user_analytics_panel.dart lib/core/widgets/catch_person_row.dart widgetbook/lib/hosts/host_operations_use_cases.dart widgetbook/lib/user_analytics/user_analytics_use_cases.dart`
- `flutter pub get` in `widgetbook/`
- `dart run build_runner build --delete-conflicting-outputs` in `widgetbook/`
- `node tool/design/generate_widget_classification.mjs`
- `node tool/design/check_widget_classification.mjs`
- `dart run tool/widget_dedupe/bin/extract_fingerprints.dart`
- `node tool/design/build_widget_similarity.mjs`
- `node tool/design/build_widget_similarity.mjs --check`
- `node tool/design/check_widgetbook_coverage.mjs --check`
- `env DART=/Users/suvratgarg/Development/flutter/bin/dart node tool/design/check_widget_dedupe_probes.mjs`
- `flutter analyze --no-fatal-infos lib`
- `flutter analyze` in `widgetbook/`
- `bash tool/widget_cleanup_scan.sh --summary`
- `node tool/run.mjs check --manifest-only`
- `node tool/design/check_widgetbook_contract_refs.mjs --check`
- `node -e "const fs=require('fs'); for (const f of process.argv.slice(1)) JSON.parse(fs.readFileSync(f,'utf8')); console.log('JSON parse passed');" docs/audit_registry/widget_classification.json artifacts/widget_dedupe/fingerprints.json docs/audit_registry/widget_similarity.json docs/audit_registry/doc_versions.json docs/design_parity/widget_consolidation/decisions.json`
- `git diff --check`

Headline numbers:

| metric | value |
|---|---:|
| widget classification entries | 1,164 |
| classification review items | 45 |
| private widget classes flagged | 0 |
| widget fingerprints | 1,056 |
| fingerprint failures | 0 |
| similarity clusters | 60 |
| ranked pairs | 200 |
| name families | 230 |
| absorb candidates | 9 |
| Widgetbook coverage decision queue | 139 |
| Widgetbook coverage stale decisions | 0 |
| root lib analyzer infos | 192 |
| Widgetbook analyzer issues | 65 |
| widget cleanup scan categories with findings | 0 |
| agent readiness score | 100/100 |

Spot checks:

- Active `lib`, `widgetbook/lib`, and `docs/widget_catalog.md` references now
  use `CatchAnalyticsBar`; the retired `HostAnalyticsBar` and
  `UserAnalyticsBar` names only remain in the consolidation decision/worklog
  evidence.
- `widgetbook/lib/main.directories.g.dart` now exposes
  `CatchAnalyticsBar/Exact catalog` in Host Operations strict coverage and
  `CatchAnalyticsBar/Bar states` under User Analytics.
- `docs/widget_catalog.md` v2.5.550 records `CatchAnalyticsBar` as the core
  analytics mini-chart bar primitive, updates `UserAnalyticsTrendPanel` to the
  shared `user_analytics/shared` file path, and drops the stale
  `UserAnalyticsInlineStat` catalog row from the prior stats merge.
- `CatchPersonRosterLayout` now matches `CatchPersonChatLayout` by using
  `CatchIcon.micro` for the context-line activity icon.

Known blockers / inherited debt:

- `node tool/design/check_widgetbook_coverage.mjs --check` still fails on the
  existing catalog-or-replace decision queue: 139 public widgets need
  decisions, with 0 stale decisions.
- `(cd widgetbook && flutter analyze)` still fails on 65 existing Widgetbook
  issues in `lib/hosts/host_operations_use_cases.dart`; the WO-005 touched
  helper still contains inherited HostOperations preview type drift in branches
  outside the `CatchAnalyticsBar` preview.
- `node tool/design/check_widgetbook_contract_refs.mjs --check` still fails on
  unrelated HostOperations preview ids.
- `dart run build_runner build --delete-conflicting-outputs` in `widgetbook/`
  succeeds, but build_runner reports that the delete-conflicting option has
  been removed and is ignored by the current builder.

## 2026-07-03 WO-006 Skeleton composition primitives

Scope:

- `CatchSkeletonRows`
- `CatchSkeletonBoxRow`
- `CatchSkeletonChips`
- `EventSuccessSkeletonSurface`
- `HostRosterSkeleton`
- `CompanionPeerListSkeleton`
- `EventSuccessLiveRosterSkeleton`
- `DashboardQuickActionsLoadingRow`
- `EventSuccessTabPickerSkeleton`
- `ClubTagLoadingSkeleton`
- `GenderFilterSkeleton`
- `OptimisticSocialSkeleton`
- `EventPreviewSectionSkeleton`

Commands:

- `node tool/agent/context_pack.mjs --task widget-consolidation-wo-006 --paths lib/core/widgets/catch_skeleton_layouts.dart,lib/core/widgets/catch_skeleton.dart,lib/hosts/presentation/widgets/host_loading_skeletons.dart,lib/hosts/presentation/widgets/host_event_attendance_panel.dart,lib/hosts/presentation/host_account_screen.dart,lib/hosts/presentation/host_operations_screen.dart,lib/dashboard/presentation/dashboard_screen.dart,lib/dashboard/presentation/dashboard_loading_screen.dart,lib/event_success/presentation/event_success_host_screen.dart,lib/event_success/presentation/event_success_companion_screen.dart,lib/event_success/presentation/event_success_event_preview_loading_screen.dart,lib/clubs/presentation/detail/widgets/club_detail_skeleton.dart,lib/swipes/presentation/filters_screen.dart,lib/events/presentation/widgets/event_detail_optimistic_body.dart,lib/events/presentation/widgets/event_detail_loading_skeleton.dart,widgetbook/lib/primitives,widgetbook/lib/hosts/host_operations_use_cases.dart,widgetbook/lib/event_success/event_success_strict_coverage_use_cases.dart,widgetbook/lib/events/event_detail_use_cases.dart,widgetbook/lib/clubs/club_detail_use_cases.dart,docs/design_parity/widget_consolidation/codex_worklog.md,docs/design_parity/widget_consolidation/decisions.json`
- `dart format lib/core/widgets/catch_skeleton_layouts.dart lib/event_success/presentation/event_success_skeletons.dart lib/clubs/presentation/detail/widgets/club_detail_skeleton.dart lib/dashboard/presentation/dashboard_loading_screen.dart lib/dashboard/presentation/dashboard_screen.dart lib/event_success/presentation/event_success_companion_screen.dart lib/event_success/presentation/event_success_event_preview_loading_screen.dart lib/event_success/presentation/event_success_host_screen.dart lib/events/presentation/widgets/event_detail_optimistic_body.dart lib/hosts/presentation/widgets/host_event_attendance_panel.dart lib/hosts/presentation/widgets/host_loading_skeletons.dart lib/swipes/presentation/filters_screen.dart widgetbook/lib/primitives/skeleton_layout_use_cases.dart widgetbook/lib/clubs/club_detail_use_cases.dart widgetbook/lib/event_success/event_success_strict_coverage_use_cases.dart widgetbook/lib/events/event_detail_use_cases.dart widgetbook/lib/hosts/host_operations_use_cases.dart widgetbook/lib/main.directories.g.dart`
- `flutter pub get` in `widgetbook/`
- `dart run build_runner build --delete-conflicting-outputs` in `widgetbook/`
- `rg -n "HostRosterSkeleton|CompanionPeerListSkeleton|EventSuccessLiveRosterSkeleton|DashboardQuickActionsLoadingRow|EventSuccessTabPickerSkeleton|ClubTagLoadingSkeleton|GenderFilterSkeleton|OptimisticSocialSkeleton|EventPreviewSectionSkeleton|trailingChips|actionCount" lib widgetbook/lib --glob '!**/*.g.dart'`
- `flutter analyze --no-fatal-infos lib/core/widgets/catch_skeleton_layouts.dart lib/event_success/presentation/event_success_skeletons.dart lib/clubs/presentation/detail/widgets/club_detail_skeleton.dart lib/dashboard/presentation/dashboard_loading_screen.dart lib/dashboard/presentation/dashboard_screen.dart lib/event_success/presentation/event_success_companion_screen.dart lib/event_success/presentation/event_success_event_preview_loading_screen.dart lib/event_success/presentation/event_success_host_screen.dart lib/events/presentation/widgets/event_detail_optimistic_body.dart lib/hosts/presentation/widgets/host_event_attendance_panel.dart lib/hosts/presentation/widgets/host_loading_skeletons.dart lib/swipes/presentation/filters_screen.dart`
- `flutter analyze --no-fatal-infos lib`
- `flutter analyze` in `widgetbook/`
- `node tool/design/generate_widget_classification.mjs`
- `node tool/design/check_widget_classification.mjs`
- `dart run tool/widget_dedupe/bin/extract_fingerprints.dart`
- `node tool/design/build_widget_similarity.mjs`
- `node tool/design/build_widget_similarity.mjs --check`
- `node tool/design/check_widgetbook_coverage.mjs --check`
- `env DART=/Users/suvratgarg/Development/flutter/bin/dart node tool/design/check_widget_dedupe_probes.mjs`
- `bash tool/widget_cleanup_scan.sh --summary`
- `node tool/run.mjs check --manifest-only`
- `node tool/design/check_widgetbook_contract_refs.mjs --check`
- `node -e "const fs=require('fs'); for (const f of process.argv.slice(1)) JSON.parse(fs.readFileSync(f,'utf8')); console.log('JSON parse passed');" docs/audit_registry/widget_classification.json artifacts/widget_dedupe/fingerprints.json docs/audit_registry/widget_similarity.json docs/audit_registry/doc_versions.json docs/design_parity/widget_consolidation/decisions.json`
- `dart tool/audit_registry.dart refresh`
- `node tool/agent/check_agent_readiness.mjs`
- `git diff --check`

Headline numbers:

| metric | value |
|---|---:|
| widget classification entries | 1,158 |
| classification review items | 46 |
| private widget classes flagged | 0 |
| widget fingerprints | 1,050 |
| fingerprint failures | 0 |
| similarity clusters | 59 |
| ranked pairs | 200 |
| name families | 225 |
| absorb candidates | 9 |
| Widgetbook coverage decision queue | 134 |
| Widgetbook coverage stale decisions | 0 |
| root lib analyzer infos | 192 |
| Widgetbook analyzer issues | 65 |
| widget cleanup scan categories with findings | 0 |
| agent readiness score | 100/100 |

Spot checks:

- Active `lib` and `widgetbook/lib` references no longer contain the deleted
  duplicate symbols or old `trailingChips` / `actionCount` API names.
- `widgetbook/lib/main.directories.g.dart` now exposes
  `CatchSkeletonRows`, `CatchSkeletonBoxRow`, and `CatchSkeletonChips` under
  the core loading-composition catalog.
- `HostEventAttendancePanel`, the Dashboard quick-action row, Event Success
  tab/live/preview loading, Club Detail tags, Filters chips, and Event Detail
  optimistic social loading now route through the shared skeleton compositions
  where the full bodies were isomorphic.
- `EventSuccessSkeletonSurface` moved to
  `lib/event_success/presentation/event_success_skeletons.dart` with
  `trailingCount`, so host and preview loading sections share one
  feature-level surface without adding a core primitive.
- `HostEventRowsSkeleton` and `HostSettingsRowsSkeleton` remain deliberately:
  full-body review showed divider separators between rows, while
  `CatchSkeletonRows` only models gap-separated rows.

Known blockers / inherited debt:

- `node tool/design/check_widgetbook_coverage.mjs --check` still fails on the
  existing catalog-or-replace decision queue: 134 public widgets need
  decisions, with 0 stale decisions.
- `(cd widgetbook && flutter analyze)` still fails on 65 existing Widgetbook
  issues in `lib/hosts/host_operations_use_cases.dart`.
- `node tool/design/check_widgetbook_contract_refs.mjs --check` still fails on
  unrelated HostOperations preview ids.
- `dart run build_runner build --delete-conflicting-outputs` in `widgetbook/`
  succeeds, but build_runner reports that the delete-conflicting option has
  been removed and is ignored by the current builder.

## 2026-07-03 WO-007 Chat share sheet consolidation

Scope:

- `ChatShareCardSheet`
- `_ChatShareCardSheetState`
- `showChatShareCardSheet`
- `ChatShareCard`
- `ShareCardHeader`
- `ShareCardBubble`
- `CatchShareCardSheet`

Commands:

- `node tool/agent/context_pack.mjs --task widget-consolidation-wo-007 --paths lib/chats/presentation/widgets/chat_share_card.dart,lib/core/widgets/catch_share_card_sheet.dart,widgetbook/lib/chats,widgetbook/lib/main.directories.g.dart,docs/design_parity/widget_consolidation/codex_worklog.md,docs/design_parity/widget_consolidation/decisions.json,docs/widget_catalog.md,docs/audit_registry/widget_consolidation_receipts.md`
- `dart format lib/chats/presentation/widgets/chat_share_card.dart widgetbook/lib/matches/matches_chat_use_cases.dart`
- `flutter analyze --no-fatal-infos lib/chats/presentation/widgets/chat_share_card.dart widgetbook/lib/matches/matches_chat_use_cases.dart`
- `flutter pub get` in `widgetbook/`
- `dart run build_runner build --delete-conflicting-outputs` in `widgetbook/`
- `node tool/design/generate_widget_classification.mjs`
- `node tool/design/check_widget_classification.mjs`
- `dart run tool/widget_dedupe/bin/extract_fingerprints.dart`
- `node tool/design/build_widget_similarity.mjs`
- `node tool/design/build_widget_similarity.mjs --check`
- `node tool/design/check_widgetbook_coverage.mjs --check`
- `DART=/Users/suvratgarg/Development/flutter/bin/dart node tool/design/check_widget_dedupe_probes.mjs`
- `flutter analyze --no-fatal-infos lib`
- `flutter analyze` in `widgetbook/`
- `bash tool/widget_cleanup_scan.sh --summary`
- `node tool/run.mjs check --manifest-only`
- `node tool/design/check_widgetbook_contract_refs.mjs --check`
- `node -e "const fs=require('fs'); for (const f of process.argv.slice(1)) JSON.parse(fs.readFileSync(f,'utf8')); console.log('JSON parse passed');" docs/audit_registry/widget_classification.json artifacts/widget_dedupe/fingerprints.json docs/audit_registry/widget_similarity.json docs/audit_registry/doc_versions.json docs/design_parity/widget_consolidation/decisions.json`
- `rg -n "class ChatShareCardSheet|_ChatShareCardSheetState|type: ChatShareCardSheet|child: ChatShareCardSheet|title: 'ChatShareCardSheet'" lib widgetbook/lib --glob '!widgetbook/lib/main.directories.g.dart'`
- `git diff --check`

Headline numbers:

| metric | value |
|---|---:|
| widget classification entries | 1,156 |
| classification review items | 46 |
| private widget classes flagged | 0 |
| widget fingerprints | 1,049 |
| fingerprint failures | 0 |
| similarity clusters | 59 |
| ranked pairs | 200 |
| name families | 224 |
| absorb candidates | 9 |
| Widgetbook coverage decision queue | 134 |
| Widgetbook coverage stale decisions | 0 |
| root lib analyzer infos | 192 |
| Widgetbook analyzer issues | 65 |
| widget cleanup scan categories with findings | 0 |

Spot checks:

- `showChatShareCardSheet` now builds `CatchShareCardSheet` with a
  `ChatShareCard` preview, chat file name, footnote, subject, text, max-width,
  and pixel-ratio mapping.
- `CatchShareCardSheet` already owns the preview width constraint through
  `ConstrainedBox(maxWidth: widget.maxWidth)`, so no local sheet-shell
  workaround was needed.
- Active `lib` and `widgetbook/lib` code no longer define, type, or instantiate
  `ChatShareCardSheet`; the only remaining references are historical
  decision/worklog evidence.
- Widgetbook keeps the chat card, header, and bubble review surfaces while the
  sheet state is typed as `CatchShareCardSheet`.
- `docs/widget_catalog.md` v2.5.552 removes the retired
  `ChatShareCardSheet` row and keeps the remaining chat share-card internals
  cataloged at their new line numbers.

Known blockers / inherited debt:

- `node tool/design/check_widgetbook_coverage.mjs --check` still fails on the
  existing catalog-or-replace decision queue: 134 public widgets need
  decisions, with 0 stale decisions.
- `(cd widgetbook && flutter analyze)` still fails on 65 existing Widgetbook
  issues in `lib/hosts/host_operations_use_cases.dart`.
- `node tool/design/check_widgetbook_contract_refs.mjs --check` still fails on
  unrelated HostOperations preview ids.
- `dart run build_runner build --delete-conflicting-outputs` in `widgetbook/`
  succeeds, but build_runner reports that the delete-conflicting option has
  been removed and is ignored by the current builder.
- The dedupe-probe script needed unsandboxed access because Flutter's Dart
  wrapper attempted SDK cache writes outside the workspace before reporting
  `Widget dedupe probes passed`.

## 2026-07-03 — WO-012 HostEmptyActionCard

Scope:

- Added feature-level `HostEmptyActionCard` in host widgets.
- Migrated Host Home no-club branches, Host Clubs no-club branch, Host Profile
  missing branch, and Host Today empty-events branch to the shared card while
  keeping route/section-owned CTA construction at the call sites.
- Deleted `HostEmptyState`, `HostProfileMissingState`, and
  `HostTodayEmptyEvents`.
- Replaced wrapper Widgetbook coverage with `HostEmptyActionCard` action-card
  states and strict exact coverage.
- Repointed Host Home, Host Clubs, and Host Profile design metadata to the
  shared card review surface.

Deleted public widget wrappers:

- `HostEmptyState`
- `HostProfileMissingState`
- `HostTodayEmptyEvents`

Commands:

- `node tool/agent/context_pack.mjs --task widget-consolidation-wo-012 --paths lib/hosts/presentation/host_operations_screen.dart,lib/hosts/presentation/widgets/host_empty_action_card.dart,widgetbook/lib/hosts/host_operations_use_cases.dart,docs/design_parity/widget_consolidation/codex_worklog.md,docs/widget_catalog.md,docs/audit_registry/widget_consolidation_receipts.md`
- `dart format lib/hosts/presentation/widgets/host_empty_action_card.dart lib/hosts/presentation/host_operations_screen.dart widgetbook/lib/hosts/host_operations_use_cases.dart`
- `flutter analyze --no-fatal-infos lib/hosts/presentation/widgets/host_empty_action_card.dart lib/hosts/presentation/host_operations_screen.dart`
- `flutter analyze --no-fatal-infos widgetbook/lib/hosts/host_operations_use_cases.dart`
- `dart run build_runner build --delete-conflicting-outputs` in `widgetbook/`
- `node tool/design/generate_widget_classification.mjs`
- `node tool/design/check_widget_classification.mjs`
- `dart run tool/widget_dedupe/bin/extract_fingerprints.dart`
- `node tool/design/build_widget_similarity.mjs`
- `node tool/design/build_widget_similarity.mjs --check`
- `node tool/design/check_widgetbook_coverage.mjs --check`
- `node tool/design/check_widget_dedupe_probes.mjs`
- `flutter analyze --no-fatal-infos lib`
- `flutter analyze` in `widgetbook/`
- `bash tool/widget_cleanup_scan.sh --summary`
- `node tool/run.mjs check --manifest-only`
- `node tool/design/check_widgetbook_contract_refs.mjs --check`
- `node -e "const fs=require('fs'); const files=['design/screens/catch.screens.json','docs/design_parity/state_matrix.json','design/components/catch.components.json','docs/audit_registry/widget_classification.json','docs/audit_registry/widget_similarity.json','docs/audit_registry/doc_versions.json']; for (const f of files) JSON.parse(fs.readFileSync(f,'utf8')); console.log('json ok', files.length);"`
- `rg -n "HostEmptyState|HostProfileMissingState|HostTodayEmptyEvents" lib widgetbook/lib test design/screens/catch.screens.json docs/design_parity/state_matrix.json docs/widget_catalog.md --glob '*.dart' --glob '*.json' --glob '*.md' --glob '!widgetbook/lib/main.directories.g.dart'`
- `dart tool/audit_registry.dart refresh`
- `dart tool/audit_registry.dart mark-pass --pass 2026-07-03-widget-consolidation-wo-012-host-empty-action-card ...`

Headline numbers:

| metric | value |
|---|---:|
| widget classification entries | 1,148 |
| classification review items | 46 |
| private widget classes flagged | 0 |
| widget fingerprints | 1,041 |
| fingerprint failures | 0 |
| similarity clusters | 53 |
| ranked pairs | 200 |
| name families | 223 |
| absorb candidates | 8 |
| Widgetbook coverage decision queue | 132 |
| Widgetbook coverage stale decisions | 0 |
| root lib analyzer infos | 192 |
| Widgetbook analyzer issues | 65 |
| widget cleanup scan categories with findings | 0 |
| audit registry file entries | 3,173 |

Known blockers / inherited debt:

- `node tool/design/check_widgetbook_coverage.mjs --check` still fails on the
  existing catalog-or-replace decision queue: 132 public widgets need
  decisions, with 0 stale decisions.
- `(cd widgetbook && flutter analyze)` still fails on 65 existing Widgetbook
  issues in `lib/hosts/host_operations_use_cases.dart`.
- `node tool/design/check_widgetbook_contract_refs.mjs --check` still fails
  only on unrelated HostOperations home/team preview ids.
- `dart run build_runner build --delete-conflicting-outputs` in `widgetbook/`
  succeeds, but build_runner reports that the delete-conflicting option has
  been removed and is ignored by the current builder.
- The dedupe-probe script needed unsandboxed access because Flutter's Dart
  wrapper attempted SDK cache writes outside the workspace before reporting
  `Widget dedupe probes passed`.

## 2026-07-03 — WO-013 Event Success skeleton title-width tokens

Scope:

- Replaced raw `EventSuccessSkeletonSurface.titleWidth` values in
  `EventSuccessSetupTabSkeleton`, `EventSuccessLiveTabSkeleton`, and
  `EventSuccessReportTabSkeleton` with nearest existing
  `CatchLayout.skeletonText*` tokens.
- Swept `event_success_event_preview_loading_screen.dart` and replaced raw
  preview loading skeleton title widths with nearest existing tokens.
- No new skeleton width tokens were added.

Token mapping:

| raw width | replacement |
|---:|---|
| 132 | `CatchLayout.skeletonTextTitleWidth` |
| 140 | `CatchLayout.skeletonTextBodyWideWidth` |
| 148 | `CatchLayout.skeletonTextInlineTitleWidth` |
| 150 | `CatchLayout.skeletonTextWideWidth` |
| 170 | `CatchLayout.skeletonTextActionLabelWidth` |
| 180 | `CatchLayout.skeletonTextCardTitleWidth` |
| 188 | `CatchLayout.skeletonTextBodyLongWidth` |
| 190 | `CatchLayout.skeletonTextLongWidth` |
| 210 | `CatchLayout.skeletonTextFeatureWidth` |

Commands:

- `node tool/agent/context_pack.mjs --task widget-consolidation-wo-013 --paths lib/event_success/presentation/event_success_host_screen.dart,lib/event_success/presentation/event_success_event_preview_loading_screen.dart,docs/design_parity/widget_consolidation/codex_worklog.md,docs/widget_catalog.md,docs/audit_registry/widget_consolidation_receipts.md`
- `rg -n "skeletonText" lib/core/theme`
- `rg -n "EventSuccessLiveTabSkeleton|EventSuccessSetupTabSkeleton|EventSuccessReportTabSkeleton|EventSuccessSkeletonSurface|width: [0-9]" lib/event_success/presentation/event_success_host_screen.dart lib/event_success/presentation/event_success_event_preview_loading_screen.dart`
- `dart format lib/event_success/presentation/event_success_host_screen.dart lib/event_success/presentation/event_success_event_preview_loading_screen.dart`
- `rg -n "titleWidth: [0-9]|width: [0-9]" lib/event_success/presentation/event_success_host_screen.dart lib/event_success/presentation/event_success_event_preview_loading_screen.dart`
- `flutter analyze --no-fatal-infos lib/event_success/presentation/event_success_host_screen.dart lib/event_success/presentation/event_success_event_preview_loading_screen.dart`
- `node tool/design/generate_widget_classification.mjs`
- `node tool/design/check_widget_classification.mjs`
- `dart run tool/widget_dedupe/bin/extract_fingerprints.dart`
- `node tool/design/build_widget_similarity.mjs`
- `node tool/design/build_widget_similarity.mjs --check`
- `node tool/design/check_widgetbook_coverage.mjs --check`
- `node tool/design/check_widget_dedupe_probes.mjs`
- `flutter analyze --no-fatal-infos lib`
- `flutter analyze` in `widgetbook/`
- `bash tool/widget_cleanup_scan.sh --summary`
- `node tool/run.mjs check --manifest-only`
- `node -e "const fs=require('fs'); const files=['docs/audit_registry/widget_classification.json','docs/audit_registry/widget_similarity.json','docs/audit_registry/doc_versions.json']; for (const f of files) JSON.parse(fs.readFileSync(f,'utf8')); console.log('json ok', files.length);"`

Headline numbers:

| metric | value |
|---|---:|
| widget classification entries | 1,148 |
| classification review items | 46 |
| private widget classes flagged | 0 |
| widget fingerprints | 1,041 |
| fingerprint failures | 0 |
| similarity clusters | 53 |
| ranked pairs | 200 |
| name families | 223 |
| absorb candidates | 8 |
| Widgetbook coverage decision queue | 132 |
| Widgetbook coverage stale decisions | 0 |
| root lib analyzer infos | 192 |
| Widgetbook analyzer issues | 65 |
| widget cleanup scan categories with findings | 0 |

Known blockers / inherited debt:

- `node tool/design/check_widgetbook_coverage.mjs --check` still fails on the
  existing catalog-or-replace decision queue: 132 public widgets need
  decisions, with 0 stale decisions.
- `(cd widgetbook && flutter analyze)` still fails on 65 existing Widgetbook
  issues in `lib/hosts/host_operations_use_cases.dart`.
- The dedupe-probe script needed unsandboxed access because Flutter's Dart
  wrapper attempted SDK cache writes outside the workspace before reporting
  `Widget dedupe probes passed`.

## 2026-07-03 WO-008 Empty-state wrapper inlines

Scope:

- `PaymentHistoryEmptyState`
- `ReviewsHistoryEmptyState`
- `CalendarMessage`
- `SavedEventsMessage`

Commands:

- `node tool/agent/context_pack.mjs --task widget-consolidation-wo-008 --paths lib/payments/presentation/payment_history_screen.dart,lib/reviews/presentation/reviews_history_screen.dart,lib/events/presentation/calendar/calendar_screen.dart,lib/events/presentation/saved_events_screen.dart,widgetbook/lib,payment,docs/design_parity/widget_consolidation/codex_worklog.md,docs/design_parity/widget_consolidation/decisions.json,docs/widget_catalog.md,docs/audit_registry/widget_consolidation_receipts.md`
- `dart format lib/payments/presentation/payment_history_screen.dart lib/reviews/presentation/reviews_history_screen.dart lib/events/presentation/calendar/calendar_screen.dart lib/events/presentation/saved_events_screen.dart widgetbook/lib/utility/p3_utility_use_cases.dart`
- `flutter analyze --no-fatal-infos lib/payments/presentation/payment_history_screen.dart lib/reviews/presentation/reviews_history_screen.dart lib/events/presentation/calendar/calendar_screen.dart lib/events/presentation/saved_events_screen.dart widgetbook/lib/utility/p3_utility_use_cases.dart`
- `node - <<'NODE' ...` recon count script for `CatchScreenBody(... Center(child: CatchEmptyState(...)))` and direct `Center(child: CatchEmptyState(...))` hits in `lib/`
- `dart run build_runner build --delete-conflicting-outputs` in `widgetbook/`
- `node tool/design/generate_widget_classification.mjs`
- `node tool/design/check_widget_classification.mjs`
- `dart run tool/widget_dedupe/bin/extract_fingerprints.dart`
- `node tool/design/build_widget_similarity.mjs`
- `node tool/design/build_widget_similarity.mjs --check`
- `node tool/design/check_widgetbook_coverage.mjs --check`
- `DART=/Users/suvratgarg/Development/flutter/bin/dart node tool/design/check_widget_dedupe_probes.mjs`
- `flutter analyze --no-fatal-infos lib`
- `flutter analyze` in `widgetbook/`
- `bash tool/widget_cleanup_scan.sh --summary`
- `node tool/run.mjs check --manifest-only`
- `node tool/design/check_widgetbook_contract_refs.mjs --check`
- `node -e "const fs=require('fs'); for (const f of process.argv.slice(1)) JSON.parse(fs.readFileSync(f,'utf8')); console.log('JSON parse passed');" docs/audit_registry/widget_classification.json artifacts/widget_dedupe/fingerprints.json docs/audit_registry/widget_similarity.json docs/audit_registry/doc_versions.json docs/design_parity/widget_consolidation/decisions.json`
- `rg -n "PaymentHistoryEmptyState|ReviewsHistoryEmptyState|CalendarMessage|SavedEventsMessage" lib widgetbook/lib --glob '!widgetbook/lib/main.directories.g.dart'`
- `git diff --check`

Headline numbers:

| metric | value |
|---|---:|
| widget classification entries | 1,152 |
| classification review items | 46 |
| private widget classes flagged | 0 |
| widget fingerprints | 1,045 |
| fingerprint failures | 0 |
| similarity clusters | 57 |
| ranked pairs | 200 |
| name families | 224 |
| absorb candidates | 9 |
| Widgetbook coverage decision queue | 133 |
| Widgetbook coverage stale decisions | 0 |
| root lib analyzer infos | 192 |
| Widgetbook analyzer issues | 65 |
| widget cleanup scan categories with findings | 0 |

Recon:

| pattern | count |
|---|---:|
| `CatchScreenBody(... Center(child: CatchEmptyState(...)))` in `lib/` | 3 |
| `Center(child: CatchEmptyState(...))` in `lib/` | 14 |

The screen-body count is below the >=4 threshold from WO-008, so no follow-up
`CatchEmptyState` screen-variant work order was opened.

Spot checks:

- Payment History signed-out and empty-history branches now inline
  `CatchScreenBody(scrollable: false)` plus the correct icon/title/message.
- Reviews History empty branches now inline the review icon empty state inside
  the existing `ReviewsHistoryBody` dispatcher.
- Calendar agenda empty state now inlines the former `CalendarMessage`
  `CatchEmptyState` override set.
- Saved Events now uses the Calendar override set with
  `CatchLayout.calendarEmptyIconSize`, `CatchInsets.contentSpacious`,
  `CatchTextStyles.titleL`, and `CatchTextStyles.proseM(..., color: t.ink2)`
  while keeping `CatchIcons.bookmarkBorderRounded`.
- Widgetbook deleted the three wrapper-specific use cases; route/body/list
  states remain as the review surface.
- Active `lib` and `widgetbook/lib` code no longer references the deleted
  wrapper names.

Known blockers / inherited debt:

- `node tool/design/check_widgetbook_coverage.mjs --check` still fails on the
  existing catalog-or-replace decision queue: 133 public widgets need
  decisions, with 0 stale decisions.
- `(cd widgetbook && flutter analyze)` still fails on 65 existing Widgetbook
  issues in `lib/hosts/host_operations_use_cases.dart`.
- `node tool/design/check_widgetbook_contract_refs.mjs --check` still fails on
  unrelated HostOperations preview ids.
- `dart run build_runner build --delete-conflicting-outputs` in `widgetbook/`
  succeeds, but build_runner reports that the delete-conflicting option has
  been removed and is ignored by the current builder.
- The dedupe-probe script needed unsandboxed access because Flutter's Dart
  wrapper attempted SDK cache writes outside the workspace before reporting
  `Widget dedupe probes passed`.

Calibration note:

The v0.1.0 SimHash threshold of 18 is void. The v0.2.0 registry recalibrates
against coarse 2-gram shingles and records `simhashHammingStrong: 39`.

Top 10 structural clusters by registry rank:

| rank | cluster | members |
|---:|---|---|
| 1 | `c001-error-state` | `CatchErrorState`, `CatchInlineErrorState` |
| 2 | `c002-icon-action` | `CatchTopBarIconAction`, `FeedbackIconAction`, `HostOverrideIconAction` |
| 3 | `c003-afterglow-beat-row` | `AfterglowBeatRow`, `CountdownCuePill`, `EmptyRosterMessage`, `EventSuccessPromptCard`, `EventSuccessRecommendationTile`, `HostFunnelSummary`, `HostReportSignalGrid`, `LiveAttendanceSummaryCard`, `LiveCheckInQrCard`, `NoticeCard`, `UserAnalyticsDataQualityRow`, `UserAnalyticsEmptyState`, `UserAnalyticsTipRow`, `WaitingRevealCue` |
| 4 | `c004-catch-detail-hero-scrim` | `CatchDetailHeroScrim`, `CatchEventThumbnailScrimOverlay`, `ClubPhotoScrim`, `ProfileHeroScrim` |
| 5 | `c005-layout` | `CatchPersonChatLayout`, `CatchPersonRosterLayout` |
| 6 | `c006-club-share-meta-row` | `ClubShareMetaRow`, `EventShareMetaRow`, `StageSectionLabel` |
| 7 | `c007-dialog` | `CatchConfirmDialog`, `CatchFormDialog` |
| 8 | `c008-live-section-header` | `LiveSectionHeader`, `RevealHostCopy`, `RunningStat`, `SetupSectionTitle`, `StructureNumberField`, `UserAnalyticsInlineStat` |
| 9 | `c009-event-map-empty-state` | `EventMapEmptyState`, `EventMapNoPinnedEventsState`, `LaunchAccessDisabledView`, `LaunchAccessSignedOutView`, `LaunchAccessStatusView`, `ProfileUnavailableBody` |
| 10 | `c010-companion-peer-list-skeleton` | `CompanionPeerListSkeleton`, `EventSuccessLiveRosterSkeleton`, `EventSuccessReportMetricsSkeleton`, `EventSuccessSetupControlsSkeleton`, `PaymentConfirmationLoadingScreen`, `ReviewHistoryItemSkeleton` |

Historical limitation status:

`WIDGET-CONSOLIDATION-001` is superseded by the v0.2.0 detector model. The
v0.1.0 miss remains useful evidence, but it is no longer an active blocker:
the registry now records the expected recall table hits without lowering the
structural thresholds.

Open handoff items:

- Phase C visual fingerprints are still not implemented.
- Phase D review packets and INDEX are still not implemented.
- Phase E/F decision ledger, taxonomy census, helper-method ratchet, and
  similarity ratchet remain future slices.

## 2026-07-03 — WO-009 CatchCountBadge + badge/pill cleanups

Scope:

- Added `CatchCountBadge` as the shared anchored count overlay primitive and
  registered it under component contract `catch.badge.count_badge`.
- Migrated `AppShellNavigationBar` and `CatchTabDockIcon` unread overlays to
  `CatchCountBadge`.
- Replaced `PhotoSlotMainBadge` with `CatchBadge` call sites and deleted the
  local badge class.
- Added `CatchOpacity.overlayPillFill` and routed `MapPill` through the token.

Deleted public widget wrappers:

- `AppShellNavigationBadge`
- `PhotoSlotMainBadge`

Commands:

- `node tool/agent/context_pack.mjs --task widget-consolidation-wo-009 --paths lib/core/widgets/catch_count_badge.dart,lib/core/presentation/app_shell.dart,lib/core/widgets/catch_tab_dock.dart,lib/image_uploads/shared/photo_slot.dart,lib/events/presentation/widgets/event_detail_design_primitives.dart,widgetbook/lib/primitives/primitive_contract_use_cases.dart,widgetbook/lib/shell/app_shell_use_cases.dart,widgetbook/lib/utility/p3_utility_use_cases.dart,design/components/catch.components.json,docs/widget_catalog.md,docs/design_parity/widget_consolidation/codex_worklog.md,docs/audit_registry/widget_consolidation_receipts.md`
- `dart format lib/core/widgets/catch_count_badge.dart lib/core/presentation/app_shell.dart lib/core/widgets/catch_tab_dock.dart lib/image_uploads/shared/photo_slot.dart lib/core/theme/catch_tokens.dart lib/events/presentation/widgets/event_detail_design_primitives.dart widgetbook/lib/shell/app_shell_use_cases.dart widgetbook/lib/utility/p3_utility_use_cases.dart widgetbook/lib/primitives/primitive_contract_use_cases.dart`
- `flutter analyze --no-fatal-infos lib/core/widgets/catch_count_badge.dart lib/core/presentation/app_shell.dart lib/core/widgets/catch_tab_dock.dart lib/image_uploads/shared/photo_slot.dart lib/core/theme/catch_tokens.dart lib/events/presentation/widgets/event_detail_design_primitives.dart widgetbook/lib/shell/app_shell_use_cases.dart widgetbook/lib/utility/p3_utility_use_cases.dart widgetbook/lib/primitives/primitive_contract_use_cases.dart`
- `rg -n "AppShellNavigationBadge|PhotoSlotMainBadge" lib widgetbook/lib --glob '!widgetbook/lib/main.directories.g.dart'`
- `rg -n "withValues\\(alpha: 0\\.93\\)|alpha: 0\\.93" lib/events lib/core lib/image_uploads`
- `dart run build_runner build --delete-conflicting-outputs` in `widgetbook/`
- `node tool/design/generate_widget_classification.mjs`
- `node tool/design/check_widget_classification.mjs`
- `dart run tool/widget_dedupe/bin/extract_fingerprints.dart`
- `node tool/design/build_widget_similarity.mjs`
- `node tool/design/build_widget_similarity.mjs --check`
- `node tool/design/check_widgetbook_coverage.mjs --check`
- `DART=/Users/suvratgarg/Development/flutter/bin/dart node tool/design/check_widget_dedupe_probes.mjs`
- `flutter analyze --no-fatal-infos lib`
- `flutter analyze` in `widgetbook/`
- `bash tool/widget_cleanup_scan.sh --summary`
- `node tool/run.mjs check --manifest-only`
- `node tool/design/check_widgetbook_contract_refs.mjs --check`
- `node -e "for (const f of ['docs/audit_registry/widget_classification.json','docs/audit_registry/widget_similarity.json','docs/audit_registry/doc_versions.json']) JSON.parse(require('fs').readFileSync(f,'utf8')); console.log('json ok')"`

Headline numbers:

| metric | value |
|---|---:|
| widget classification entries | 1,151 |
| classification review items | 47 |
| private widget classes flagged | 0 |
| widget fingerprints | 1,044 |
| fingerprint failures | 0 |
| similarity clusters | 55 |
| ranked pairs | 200 |
| name families | 224 |
| absorb candidates | 8 |
| Widgetbook coverage decision queue | 133 |
| Widgetbook coverage stale decisions | 0 |
| root lib analyzer infos | 192 |
| Widgetbook analyzer issues | 65 |
| widget cleanup scan categories with findings | 0 |

Recon:

- `CatchPersonUnreadCountPill` also clamps `99+` and uses a primary
  `CatchBadge`, but it owns person-row unread semantics and remains distinct.
- `CatchCountPill` accepts caller-supplied badge text, does not own clamping,
  and uses an ink overlay badge on a raised floating control.

Known blockers / inherited debt:

- `node tool/design/check_widgetbook_coverage.mjs --check` still fails on the
  existing catalog-or-replace decision queue: 133 public widgets need
  decisions, with 0 stale decisions.
- `(cd widgetbook && flutter analyze)` still fails on 65 existing Widgetbook
  issues in `lib/hosts/host_operations_use_cases.dart`.
- `node tool/design/check_widgetbook_contract_refs.mjs --check` now fails only
  on unrelated HostOperations preview ids.
- `dart run build_runner build --delete-conflicting-outputs` in `widgetbook/`
  succeeds, but build_runner reports that the delete-conflicting option has
  been removed and is ignored by the current builder.
- The dedupe-probe script needed unsandboxed access because Flutter's Dart
  wrapper attempted SDK cache writes outside the workspace before reporting
  `Widget dedupe probes passed`.

## 2026-07-03 — WO-010 CatchConfirmDialog shell delegation inspection

Scope:

- Inspected `CatchConfirmDialog` and `CatchFormDialog` in
  `lib/core/widgets/catch_adaptive_dialog.dart`.
- Did not delegate `CatchConfirmDialog` to `CatchFormDialog` because the shared
  outer shell hides load-bearing differences in title alignment, content slot
  shape, and action layout.

Commands:

- `node tool/agent/context_pack.mjs --task widget-consolidation-wo-010 --paths lib/core/widgets/catch_adaptive_dialog.dart,widgetbook/lib/primitives/primitive_contract_use_cases.dart,docs/design_parity/widget_consolidation/codex_worklog.md,docs/widget_catalog.md,docs/audit_registry/widget_consolidation_receipts.md`
- `nl -ba lib/core/widgets/catch_adaptive_dialog.dart | sed -n '1,260p'`
- `rg -n "CatchConfirmDialog|CatchFormDialog|showCatchConfirm|catchConfirm|catchFormDialog" lib widgetbook/lib test --glob '*.dart'`
- `flutter analyze --no-fatal-infos lib/core/widgets/catch_adaptive_dialog.dart`

Escalation:

`CatchConfirmDialog` and `CatchFormDialog` share the same outer `Dialog` plus
overlay `CatchSurface` shell, but their inner contracts differ. Confirm dialogs
center title/body text, omit the body when the message is empty, and render
action buttons as equal-width full-width buttons for one or two actions or as a
full-width stack for longer action lists. Form dialogs left-align the title,
reserve a child content slot, and right-align arbitrary action widgets in a
trailing row. A direct delegation would either change confirm button layout or
place the confirm action row inside an unconstrained trailing form-action row.
Both public classes stay distinct pending a later explicit decision to extract a
private shared dialog shell.

## 2026-07-03 — WO-011 CatchTabRail<T>

Scope:

- Added `CatchTabRail<T>` and `CatchLayout.tabRailHeight`.
- Migrated Host Clubs and Host Settings app-bar bottom rails to `CatchTabRail`.
- Deleted `HostClubTabRail` and `HostSettingsTabRail`.
- Added the `catch.tab_rail` component contract and primitive Widgetbook states.
- Repointed Host Clubs and Host Settings design metadata from retired rail
  symbols to shared `CatchTabRail` coverage.

Deleted public widget wrappers:

- `HostClubTabRail`
- `HostSettingsTabRail`

Commands:

- `node tool/agent/context_pack.mjs --task widget-consolidation-wo-011 --paths lib/core/widgets/catch_option_group.dart,lib/core/widgets/catch_tab_rail.dart,widgetbook/lib/primitives/primitive_contract_use_cases.dart,docs/design_parity/widget_consolidation/codex_worklog.md,docs/widget_catalog.md,docs/audit_registry/widget_consolidation_receipts.md`
- `dart format lib/core/widgets/catch_tab_rail.dart lib/core/theme/catch_tokens.dart lib/hosts/presentation/host_operations_screen.dart lib/hosts/presentation/host_account_screen.dart widgetbook/lib/primitives/primitive_contract_use_cases.dart widgetbook/lib/hosts/host_operations_use_cases.dart`
- `flutter analyze --no-fatal-infos lib/core/widgets/catch_tab_rail.dart lib/core/theme/catch_tokens.dart lib/hosts/presentation/host_operations_screen.dart lib/hosts/presentation/host_account_screen.dart widgetbook/lib/primitives/primitive_contract_use_cases.dart`
- `flutter analyze --no-fatal-infos widgetbook/lib/hosts/host_operations_use_cases.dart`
- `dart run build_runner build --delete-conflicting-outputs` in `widgetbook/`
- `node tool/design/generate_widget_classification.mjs`
- `node tool/design/check_widget_classification.mjs`
- `dart run tool/widget_dedupe/bin/extract_fingerprints.dart`
- `node tool/design/build_widget_similarity.mjs`
- `node tool/design/build_widget_similarity.mjs --check`
- `node tool/design/check_widgetbook_coverage.mjs --check`
- `DART=/Users/suvratgarg/Development/flutter/bin/dart node tool/design/check_widget_dedupe_probes.mjs`
- `flutter analyze --no-fatal-infos lib`
- `flutter analyze` in `widgetbook/`
- `bash tool/widget_cleanup_scan.sh --summary`
- `node tool/run.mjs check --manifest-only`
- `node tool/design/check_widgetbook_contract_refs.mjs --check`
- `node -e "for (const f of ['design/screens/catch.screens.json','docs/design_parity/state_matrix.json','design/components/catch.components.json','docs/audit_registry/widget_classification.json','docs/audit_registry/widget_similarity.json','docs/audit_registry/doc_versions.json']) JSON.parse(require('fs').readFileSync(f,'utf8')); console.log('json ok')"`
- `rg -n "HostClubTabRail|HostSettingsTabRail" lib widgetbook/lib test --glob '*.dart' --glob '!widgetbook/lib/main.directories.g.dart'`

Headline numbers:

| metric | value |
|---|---:|
| widget classification entries | 1,150 |
| classification review items | 46 |
| private widget classes flagged | 0 |
| widget fingerprints | 1,043 |
| fingerprint failures | 0 |
| similarity clusters | 54 |
| ranked pairs | 200 |
| name families | 223 |
| absorb candidates | 8 |
| Widgetbook coverage decision queue | 133 |
| Widgetbook coverage stale decisions | 0 |
| root lib analyzer infos | 192 |
| Widgetbook analyzer issues | 65 |
| widget cleanup scan categories with findings | 0 |

Known blockers / inherited debt:

- `node tool/design/check_widgetbook_coverage.mjs --check` still fails on the
  existing catalog-or-replace decision queue: 133 public widgets need
  decisions, with 0 stale decisions.
- `(cd widgetbook && flutter analyze)` still fails on 65 existing Widgetbook
  issues in `lib/hosts/host_operations_use_cases.dart`.
- `node tool/design/check_widgetbook_contract_refs.mjs --check` now fails only
  on unrelated HostOperations home/team preview ids.
- `dart run build_runner build --delete-conflicting-outputs` in `widgetbook/`
  succeeds, but build_runner reports that the delete-conflicting option has
  been removed and is ignored by the current builder.
- The dedupe-probe script needed unsandboxed access because Flutter's Dart
  wrapper attempted SDK cache writes outside the workspace before reporting
  `Widget dedupe probes passed`.
