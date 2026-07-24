---
doc_id: explore_findings_remediation_spec
version: 1.1.0
updated: 2026-07-23
owner: app
status: retirement_ready
---

# Explore + User Profile + Chats Findings — Remediation & Generalization Spec

## 0. Context for the implementing agent

Three consecutive staff audits compared feature slices against the Event
Detail reference (patterns `ARCH-SCREEN-001` and `ARCH-UI-STATE-001` in
`docs/audit_registry/architecture_pattern_adoption.json`):

- **Explore Discovery** — `needs_update`. The display-state pattern
  generalized well (16 provider-free adapters in
  `lib/explore/presentation/explore_screen_state.dart`, tested and
  machine-checked), but the screen boundary stops at the route:
  `ExploreScreen` is reference-quality while the body/sections below it still
  watch providers directly.
- **User Profile** — `needs_update` (light). Architecturally strong
  (clean route, 708-line provider-free edit adapter, broad tests), but the
  pattern adoption is entirely unregistered in the tracker, one state file is
  a provider/state hybrid, and `WidgetRef` is threaded into helpers.
- **Chats Inbox** — `needs_update`. Best mutation-error implementation in
  the app at the route, but: a per-match provider fan-out in the inbox view
  model (real Firestore read cost), a view model misnamed as a `_state.dart`
  file, an undocumented `keepAlive`, a list widget re-watching route
  providers, and zero tracker registration.

This spec has two halves and BOTH matter equally:

- **Fix the three slices** (Phases 1–4).
- **Generalize each finding into a scanner/rule** (Phase 5) so every future
  feature audit starts from a smaller finding set. Each scanner ratchets via
  baseline — never block on grandfathered debt, always block new debt.

**Hard constraints:**

- Read `docs/app_architecture.md` (Dependency Direction, Screen Definition,
  Controller And View-Model Contract sections) and the two pattern exhibits
  before editing.
- The Calendar screen (`lib/events/presentation/calendar/calendar_screen.dart`)
  is the reference for an interactive route with route-scoped state
  (selected date / expanded header). Use it, not Event Detail, as the model
  for lifting Explore's filter/search/city state handling.
- Run Flutter tests/analyzer sequentially, never in parallel.
- Every new scanner rule ships with: unit tests (known-bad fixture asserting
  findings > 0, known-good fixture asserting 0, exemption fixture), manifest
  metadata (`role`, `rules`, `vacuityProof`), a `rules.json` enforcement
  entry, and a regenerated baseline + `enforcement_baseline` receipt in
  `docs/audit_registry/agent_metrics.jsonl` (copy the existing receipt shape;
  the meta-gate fails on missing/mismatched receipts).
- After architecture changes: update
  `docs/audit_registry/architecture_pattern_adoption.json`,
  `design/screens/catch.screens.json` (`screen.explore.discovery` status),
  and stamp a pass receipt in `docs/audit_registry/passes.jsonl`.
- Verification gates that must pass at the end of every phase:

```sh
flutter analyze --no-fatal-infos
node tool/run.mjs check --category meta
node tool/run.mjs check --category audit
node tool/agent/check_agent_readiness.mjs
```

---

## Phase 1 — Surgical code fixes (small, independent)

### 1.1 (F2) Lift city auto-select policy out of `explore_city_picker.dart`

`lib/explore/presentation/widgets/explore_city_picker.dart:101-114` reads
`watchUserProfileProvider`, `deviceLocationProvider`, and
`cityRepositoryProvider` from inside a widget and implements
auto-select-nearest-city product policy there.

Create `lib/explore/presentation/explore_city_controller.dart`: a generated
`@riverpod` action controller (Pattern A, see
`lib/events/presentation/event_detail_controller.dart` for shape) with a
method `autoSelectCity()` that owns the profile-city → device-location →
nearest-city-lookup → `selectedExploreCityProvider` write sequence. The widget
keeps only: watch `selectedExploreCityProvider` + `cityListProvider` for
display, invoke the controller method, and render. Add a controller test
(`test/explore/explore_city_controller_test.dart`) with fake repository/
location seams covering: profile city wins, device location fallback, no
location available. Keep the existing picker widget tests green.

### 1.2 (F4) Let a healthy event feed survive club view-model failure

In `lib/explore/presentation/explore_screen_state.dart`,
`ExploreScreenBodyState.from` (~line 880): `viewModelError` currently
full-screens the route even when `eventFeedHasContent` is true. Change the
precedence: if `viewModelError != null && eventFeedHasContent`, return the
`content` kind (the club-dependent sections degrade; the feed renders).
`viewModelError` with NO feed content keeps the current error branch. The
`content` state needs the view model — when the VM errored there is none, so
add an explicit representation (e.g. `contentWithoutClubs` kind or a nullable
viewModel handled by the body builder rendering only feed slivers + a
`CatchInlineErrorState` for the club sections with the explore retry target).
Prefer the smallest honest representation; do NOT fake an empty view model, as
empty clubs and failed clubs must stay distinguishable. Add
`test/explore/explore_view_model_test.dart` cases: club-VM error + feed
content → feed visible + club section error affordance; club-VM error + no
feed → full-screen error (unchanged).

### 1.3 (F5) Make the null-organizer regression guard real

`docs/agent_regression_ledger.json` entry `REG-AGENT-005` guards with
`flutter test test/explore/explore_view_model_test.dart`, but that file has no
null-host/unclaimed-organizer case. Add explicit tests: an external event
with `primaryExternalUri == null` renders the "No link" row state, and any
Explore display path that touches organizer/host fields handles null without
throwing (inspect `ExploreExternalEventRowState.from` and the feed VM's
external-item mapping for the exact nullable fields). Name at least one test
with the literal phrase `unclaimed organizer` and update the ledger entry's
guard to `flutter test test/explore/explore_view_model_test.dart --plain-name
'unclaimed organizer'` so the guard is specific.

### 1.4 (F6) Single seam for empty-state clear actions

`lib/explore/presentation/widgets/explore_events_section.dart:114-116` reads
`exploreSearchQueryProvider.notifier` / `exploreFiltersProvider.notifier`
directly for its empty-state clear actions while the route passes callbacks
into `ExploreScreenEmptyState`. Convert the section's empty state to accept
`onClearSearch`/`onClearFilters` callbacks threaded from the route (this
becomes trivial after Phase 2; if implementing Phase 1 standalone, thread
through `buildExploreEventsSlivers`'s parameters).

### 1.5 (F7) Naming and compat residue

- Rename provider function `exploreViewModel` →
  `exploreClubsViewModel` (file may stay `explore_view_model.dart` or move to
  `explore_clubs_view_model.dart` — prefer the rename-file option; update
  `design/screens/catch.screens.json` stateController entries and all call
  sites; regenerate codegen).
- Delete `ExploreScreen.enableEventMapNetworkTiles` (doc comment says it is
  dead compat); update the three Widgetbook mounts and any tests.
- In `ExploreBody`, remove `includeJoinedClubsRail`/`includeClubDirectory`
  flags IF no call site passes non-default values (verify with grep first; if
  a live call site needs them, leave and note in the pass receipt).

---

## Phase 2 — Explore body screen-boundary migration (F1, F8)

This is the tracked migration the pattern tracker already demands ("the full
Explore route/feed body still needs a separate screen-boundary migration").
Target shape, modeled on Calendar:

1. **Kill the `ref` parameter.** `buildExploreBodySlivers(context, ref, …)`
   (`lib/explore/presentation/widgets/explore_body.dart:44`) and
   `buildExploreEventsSlivers(ref, …)`
   (`lib/explore/presentation/widgets/explore_events_section.dart:58`) must
   stop taking `WidgetRef`. The route (`ExploreScreen`) watches
   `exploreFeedViewModelProvider`, `exploreFiltersProvider`,
   `exploreSearchQueryProvider`, and `exploreSourceClubsProvider` (it already
   watches most of these), resolves the existing provider-free adapters
   (`ExploreFeedSectionState`, `ExploreChromeState`, `ExploreFilterRailState`,
   `ExploreFilterSheetState`, `ExploreCoverStoryState`, row states), and
   passes state objects + typed callbacks down.
2. **Chrome:** `ExploreDiscoveryCoverHeader` and `ExploreFilterRail` become
   plain `StatelessWidget`s receiving their `Explore*State` + callbacks
   (`onQueryChanged`, `onFilterToggled`, `onOpenFilterSheet`,
   `onCityTapped`, …). The route owns the notifier writes.
3. **Events section:** becomes a provider-free sliver family receiving
   `ExploreFeedSectionState` + row states + `onEventSelected`,
   `onExternalEventOpened`, `onClearSearch`, `onClearFilters`. The
   external-link side effect (`explore_events_section.dart:1062`,
   `externalLinkControllerProvider`) moves to the route as an
   `onExternalEventOpened` handler.
4. **Split the megafile** (F8): `explore_events_section.dart` (1,107 lines)
   splits into the section shell, row widgets, and day-header widgets —
   follow existing feature-widget file naming. No behavior change.
5. **Rebuild-scope note:** the route already watches query/filters, so
   lifting reads does not worsen rebuild behavior. If profiling shows
   keystroke rebuild cost, the sanctioned tool is `select`/provider
   granularity at the route — NOT re-introducing widget-level watches.
6. **Registry updates:** mark `ExploreScreen`, `ExploreMapScreen`, and the
   migrated body/section files as `ARCH-SCREEN-001` adopters (aligned, with
   `providerFree: true` on the provider-free widget/state files) in the
   pattern tracker; update the tracker note that previously said Explore
   still needed this migration; set `screen.explore.discovery` status from
   `in_progress` to its aligned value; run
   `node tool/architecture/check_adopted_architecture_boundaries.mjs`.
7. **Tests/Widgetbook:** update `test/explore/explore_widgets_test.dart` so
   section/chrome tests construct state objects + callback spies directly (no
   ProviderScope needed for provider-free widgets); route-level tests keep
   provider overrides. Update `widgetbook/lib/explore/explore_use_cases.dart`
   body/section states to explicit state fixtures (mirror how
   `widgetbook/lib/events/event_detail_use_cases.dart` handles body-only
   states).

Definition of done for this phase: zero `ref.watch/ref.read` and zero
`ConsumerWidget` under `lib/explore/presentation/widgets/**` except any file
explicitly recorded as a variant in the tracker with a reason.

---

## Phase 3 — Barrel public-API policy (F3)

Decision (already made — implement, do not re-litigate): **feature-root
barrels are the sanctioned public API surface for cross-feature imports, and
every barrel export of a presentation file must be explicitly annotated.**

1. In each feature-root barrel (e.g. `lib/clubs/clubs.dart`,
   `lib/events/events.dart`, `lib/explore/explore.dart`), every `export` of a
   path under `presentation/` must carry a trailing same-line or previous-line
   annotation: `// public-api: <one-line reason>`. Add annotations to all
   current presentation exports (reasons exist in the recent seam-move
   commits).
2. Update rule `DEPENDENCY-DIRECTION-001` instruction: replace the "one
   sanctioned seam is a sibling feature's public controller" sentence with:
   sanctioned seams are (a) a sibling feature's public controller
   (`presentation/*_controller.dart`) imported from a screen or controller,
   and (b) symbols exported by the sibling feature's root barrel
   (`lib/<feature>/<feature>.dart`), where every presentation export in a
   barrel requires a `// public-api:` annotation. Direct deep imports of
   sibling `presentation/` files remain violations.
3. Update `docs/app_architecture.md` Dependency Direction section with the
   same policy (same pass, same wording).

## Phase 4 — User Profile and Chats remediation

Independent of Phases 1–3; may be implemented in parallel batches but commit
separately per sub-item.

### 4.1 (Profile) Split the hybrid state file

`lib/user_profile/presentation/self_profile_screen_state.dart:9-22` declares
`selfProfileScreenStateProvider` (a manual Riverpod `Provider`) in the same
file as the provider-free `SelfProfileScreenState.fromAsync` factory. Move
the provider into `lib/user_profile/presentation/profile_screen.dart` (or a
new `self_profile_providers.dart`), migrate it to `@riverpod` codegen, and
leave the state file with zero Riverpod imports. Keep
`test/user_profile/self_profile_screen_state_test.dart` green.

### 4.2 (Profile) Register the pattern adoption

Add to the `ARCH-UI-STATE-001` adopters in
`docs/audit_registry/architecture_pattern_adoption.json`:
`self_profile_screen_state.dart` (post-split) and
`self_profile_edit_tab_state.dart` with `providerFree: true` and accurate
role strings, plus `test/user_profile/self_profile_screen_state_test.dart`
and `test/user_profile/self_profile_edit_tab_state_test.dart` as evidence.
Run `node tool/architecture/check_adopted_architecture_boundaries.mjs` and
fix anything it flags. Do NOT mark the Profile route under `ARCH-SCREEN-001`
in this pass (its `WidgetRef`-threading helpers are Phase 5 baseline debt).

### 4.3 (Profile) Rename the non-controller

`lib/user_profile/presentation/self_profile_photo_action_controller.dart`
declares `SelfProfilePhotoActionController`, a pure intent factory with no
Riverpod notifier. Rename class and file to
`SelfProfilePhotoIntentFactory` / `self_profile_photo_intent_factory.dart`
("Controller" is load-bearing for scanner conventions). Mechanical rename,
update call sites and tests.

### 4.4 (Profile) Save-mutation banner test

Add one widget test asserting a failed
`ProfileEditController.saveFieldsMutation` renders the `CatchErrorBanner` in
the inline editor (`lib/user_profile/presentation/widgets/inline_editor_save.dart:79`
is the surface). The file-level scanner cannot verify per-mutation; this test
pins it.

### 4.5 (Chats) Fix the per-match provider fan-out (production read cost)

`lib/chats/presentation/inbox/chats_list_view_model.dart:136-147`:
`_previewForMatch` watches `watchClubProvider(clubId)` and
`watchPublicProfileProvider(otherUid)` PER MATCH — an inbox with N matches
holds up to 2N realtime listeners for display-only name/photo data, violating
`DATA-ACCESS-BATCH-001`. Replace with batched lookups: collect the distinct
club ids and other-uids across all matches, resolve them through batched
whereIn providers (follow the existing batched pattern —
`clubNameLookupProvider` in `lib/clubs/data/club_name_lookup.dart` and
`watchEventsByIdsProvider` are the references; add a batched
public-profile-preview provider in `lib/public_profile/data/` if none
exists), then build previews from the resolved maps. Preserve the existing
display precedence (club host profile before public profile, current
fallback copy). Add a view-model test asserting one batched read per
collection rather than per-row reads (assert via fake repository call
counts). This changes read behavior — run
`flutter test test/chats/` in full.

### 4.6 (Chats) Rename the misnamed view model

`lib/chats/presentation/chat_route_state.dart` is a `Provider.family` doing
10+ watches — a view model, not a state adapter. Split the pure
`ChatRouteState` class (keep in a `_state.dart` file with no Riverpod
imports) from the provider (move to `chat_route_view_model.dart`, migrate to
`@riverpod` codegen). Update imports and keep `test/chats/chat_screen_test.dart`
green.

### 4.7 (Chats) Document or remove the undocumented keepAlive

`lib/chats/presentation/inbox/chats_list_view_model.dart:57`:
`ChatSearchQuery` is `@Riverpod(keepAlive: true)` with no rationale. Add the
marker comment introduced in Phase 5.6b —
`// keepalive: preserve inbox search text across tab switches and route
re-entry` — directly above the annotation. Do not change the lifecycle
behavior in this pass.

### 4.8 (Chats) Register the pattern adoption

Add the five provider-free chats state files
(`chats_list_screen_state.dart`, `host_chat_screen_state.dart`,
`chat_thread_lookup_state.dart`, `chat_read_marker_state.dart`, and the
post-4.6 `chat_route_state.dart`) plus their tests as `ARCH-UI-STATE-001`
adopters with `providerFree: true`. Leave the inbox list widget's re-watching
of route providers (`lib/chats/presentation/inbox/widgets/chats_list.dart:35-55`)
as recorded debt: add a `candidateQueue` entry under `ARCH-SCREEN-001` for
the Chats inbox screen-boundary migration rather than fixing it here.

## Phase 5 — Generalizing scanners (repo-wide ratchets)

Extend `tool/architecture/check_dependency_direction.mjs` (follow the pattern
of the existing rules; file-level baseline keys `rule|path` for source
patterns, `rule|path|import` for import patterns):

### 5.1 `widgetRefParameter` (generalizes F1)

Flag any function/constructor parameter of type `WidgetRef` in
`lib/**/presentation/**` — regex `\bWidgetRef\s+\w+\s*[,)]` on lines that do
NOT contain `Widget build(`. Passing `ref` into helpers/builders is how
provider reads leak below the route boundary. Baseline existing occurrences;
Explore's disappear in Phase 2.

### 5.2 `widgetRepositoryProviderRead` (generalizes F2)

Flag `ref.(watch|read|listen)` of an identifier matching
`[a-z]\w*[Rr]epositoryProvider` in `lib/**/presentation/**` EXCEPT files
ending `_view_model.dart`, `_controller.dart`, or `_service.dart`. This is
name-convention-based (repository providers are consistently named
`*RepositoryProvider` in this repo) — note that limitation in the scanner
help text. Baseline existing occurrences.

### 5.3 `barrelPresentationExport` (generalizes F3)

For every feature-root barrel `lib/<feature>/<feature>.dart`: flag `export`
statements whose path contains `/presentation/` and that lack a
`// public-api:` annotation on the same or previous line. NOT baselined —
Phase 3 annotates everything, so this ships as a clean hard gate. Also extend
the `crossFeaturePresentationImport` rule's help text to state that barrels
are the sanctioned bypass and this rule is the barrel's gatekeeper.

### 5.4 Meta-gate: ledger guard specificity (generalizes F5)

In `tool/check_enforcement_integrity.mjs`: for every ACTIVE regression-ledger
entry whose guard is a `flutter test <file>` command WITHOUT `--plain-name`,
emit a failure asking for either a `--plain-name` filter or a
`guardEvidence` field (a literal string the guard's target file must contain;
validate it). Update the ledger entries this catches (expected:
REG-AGENT-005 fixed in Phase 1.3; fix any others it finds the same way).

### 5.5 `stateFileProviderImport` (from the User Profile audit)

Files matching `lib/**/presentation/**/*_state.dart` must be provider-free by
naming convention, whether or not the tracker lists them. Flag any such file
that imports `flutter_riverpod`, `hooks_riverpod`, or `riverpod_annotation`,
or whose source matches `\bProvider<|\bref\.(watch|read|listen)`. The two
known offenders are fixed by Phase 4.1
(`self_profile_screen_state.dart`) and Phase 4.6 (`chat_route_state.dart`);
after those land, regenerate and expect an EMPTY baseline — if other files
surface, baseline them and note the count in the receipt. This converts the
`_state.dart` naming convention into an invariant instead of a
tracked-files-only check.

### 5.6 `untrackedStateAdapter` (from the User Profile audit)

Cross-artifact check: every `lib/**/presentation/**/*_state.dart` and
`lib/**/presentation/**/*_screen_state.dart` file must appear as an adopter
`path` somewhere in
`docs/audit_registry/architecture_pattern_adoption.json`. Flag unregistered
files — silent pattern adoption means no boundary-checker coverage and no
back-propagation obligation. Fix findings by REGISTERING files, not by
baselining: Phases 4.2 (User Profile) and 4.8 (Chats) cover the known
unregistered adapters; register anything further this scanner surfaces the
same way. Ship as a hard gate once registration is done.

### 5.6b `undocumentedKeepAlive` (from the Chats audit)

`docs/app_architecture.md` requires every `keepAlive` provider to document its
lifecycle rationale. Flag `@Riverpod(keepAlive: true)` or `keepAlive: true`
in handwritten `lib/**` unless a comment matching `// keepalive:` appears
within the 3 lines above. Introduce that marker convention in the doc's
Realtime Stream Lifecycle section in the same pass. The known offender
(`ChatSearchQuery`) gets its marker in Phase 4.7; ratchet any remaining
occurrences the scanner finds. Map to `STREAM-LIFECYCLE-001`
(stage `scanner-ratchet`).

### 5.6c `manualProviderDeclaration` (ratchet, upgraded from optional)

Two consecutive audits found manual `Provider(`/`Provider.family(`
declarations where repo convention is `@riverpod` codegen
(`selfProfileScreenStateProvider`, `chatRouteStateProvider`). Flag
`=\s*Provider(?:\.family)?(?:<|\()` and `StateProvider<`/`FutureProvider<`
declarations in handwritten `lib/**` outside `lib/core/**`. The two known
offenders are migrated to codegen by Phases 4.1 and 4.6; ratchet any
remaining occurrences with a baseline. Map to `CONTROLLER-BOUNDARY-001`
(stage `scanner-ratchet`).

### 5.6d `misplacedStateClass` (from the Event Success / Hosts audits)

The 5.5/5.6 scanners key on `_state.dart` file naming — but Event Success
defines its display-state classes INSIDE screen/part files (e.g. the
companion screen-state classes tested by
`test/event_success/event_success_companion_screen_state_test.dart` live in
screen/part files, and `HostClubsScreenState` is declared inside
`lib/hosts/presentation/host_operations_screen.dart:173`), which evades both
scanners and tracker registration. Flag `class \w+(Screen)?State\b`
declarations carrying a `factory .*\.(from|resolve)\(` in the same class
body, in `lib/**/presentation/**` files NOT ending `_state.dart`. Ratchet
with baseline (do NOT move the classes in this pass — file splits are
follow-up work). Map to `AUDIT-REGISTRY-001` (stage `scanner-ratchet`).

### 5.6e `multiRouteScreenFile` (from the Hosts audit)

`lib/hosts/presentation/host_operations_screen.dart` is 5,312 lines
containing FIVE route screens (`HostOperationsHomeScreen`, `HostClubsScreen`,
`HostAccountScreen`, `HostProfileScreen`, `HostAuthRequiredScreen`) plus ~80
supporting classes. Route screens must be findable per
`docs/app_architecture.md` ("keep route-level screens easy to find"). Flag
files under `lib/**/presentation/**` declaring 2+ classes matching
`class \w+Screen extends (Consumer(Stateful)?|Stateless|Stateful)Widget`.
Ratchet with baseline; the host_operations split itself is follow-up work,
not this pass. Map to `AUDIT-REGISTRY-001` or a new `SCREEN-FILE-001` rule
(agent's choice; if new rule, add it to rules.json with kind `contract` and
full metadata per the meta-gate's requirements).

Optional (implement only if trivial): a `finder`-role report listing classes
named `*Controller` that carry no `@riverpod` annotation in the same file
(naming is load-bearing for scanner conventions; renames are follow-up work,
not this pass).

### 5.7 Rules registry entries

Add enforcement entries mapping: `widgetRefParameter` +
`widgetRepositoryProviderRead` → `CONTROLLER-BOUNDARY-001` and
`DEPENDENCY-DIRECTION-001` (stage `scanner-ratchet`);
`barrelPresentationExport` → `DEPENDENCY-DIRECTION-001` (stage
`scanner-gate`); `stateFileProviderImport` → `DEPENDENCY-DIRECTION-001`
(stage `scanner-ratchet`, `scanner-gate` once the baseline is empty);
`untrackedStateAdapter` → `AUDIT-REGISTRY-001` (stage `scanner-gate`).
Update `CONTROLLER-BOUNDARY-001`'s enforcement from manual-only.

---

## Phase 6 — Verification & receipts

Run, in order, and report results:

```sh
node --test tool/architecture/check_dependency_direction.test.mjs
node --test tool/check_enforcement_integrity.test.mjs
node tool/run.mjs check --category meta
node tool/run.mjs check --category audit
flutter analyze --no-fatal-infos
flutter test test/explore/explore_view_model_test.dart test/explore/explore_widgets_test.dart
flutter test test/explore/explore_city_controller_test.dart
flutter test test/user_profile/
flutter test test/chats/
node tool/architecture/check_adopted_architecture_boundaries.mjs
node tool/agent/check_agent_readiness.mjs
git diff --check
```

Stamp pass receipts per slice:
`2026-07-XX-explore-screen-boundary` (Phases 1–3),
`2026-07-XX-profile-chats-state-governance` (Phase 4), and
`2026-07-XX-audit-generalization-scanners` (Phase 5) — each with pattern
ids, adopter paths, new scanner rules + baseline counts, rules.json changes,
and (for the Explore receipt) the ledger guard fix. Final summary must
report per-phase commit SHAs, the baseline counts for every new ratchet
rule, the fake-repository read counts proving the Phase 4.5 batching fix,
whether `ExploreBody` legacy flags were removable, and any deviation from
this spec with reasons.

**Out of scope:** feature slices beyond Explore, User Profile, and Chats;
the Chats inbox screen-boundary migration (recorded as candidateQueue debt
in Phase 4.8, not fixed); analyzer-lint promotion of the new scanner rules;
web lane; changing product behavior beyond the Explore F4 partial-failure
policy and the Chats 4.5 read-batching fix.
