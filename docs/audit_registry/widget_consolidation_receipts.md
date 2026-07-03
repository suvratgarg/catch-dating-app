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
