# Feature audits — May 2026

Living audit document. Each feature gets its own section. New findings
discovered in later passes are appended under the relevant feature with a
dated subheading rather than rewriting earlier content.

**Severity legend:** Blocker > High > Medium > Low > Nit.

**Index**
- [Run clubs](#run-clubs) — audited 2026-05-15
- [Runs](#runs) — audited 2026-05-15
- [User profile](#user-profile) — audited 2026-05-15

---

## Run clubs
*Initial pass: 2026-05-15. Scope: `lib/run_clubs/` (39 source files) + `test/run_clubs/` (7 test files), ~10.8k LOC. Cross-referenced `firestore.rules`, `functions/src/runClubs/*`, `lib/routing/go_router.dart`.*

### Executive summary

The feature is functional, broadly well-architected, and shipped-quality on the surface — Riverpod patterns are correct, mutation lifecycle is wired up properly, backend-owned writes are honored, tests cover the load-bearing paths. The two real concerns are (1) **product completeness**: discovery/filter/sort is thin for a dating-meets-running app, edit/share is uneven, and the join model is binary (no save/follow); (2) **internal inconsistency** with the rest of the codebase: presentation is sub-foldered while every other feature is flat, `_parts/` `part of` is unique here, and there are two parallel "join" controllers doing the same thing. No blockers for launch. About 2–3 days of cleanup + 1–2 weeks of product gaps depending on appetite.

**Launch verdict:** Ship-ready for an MVP. The product gaps below would matter more after week one of usage than at launch.

### A. Data modeling

- **[High] Three redundant fields for archive state** — `lib/run_clubs/domain/run_club.dart:32-35`. `status: RunClubLifecycleStatus`, `archived: bool`, `archivedAt: DateTime?` + `archiveReason: String?` all encode the same lifecycle state. A future bug will let them diverge. Collapse to either the enum or the boolean + timestamp pair, not both. No UI exposes archive yet, so this is cheap to fix now.
- **[Medium] `RunClub.location` is a free string** — `lib/run_clubs/domain/run_club.dart:16`. Everything else treats it as a city slug; search relies on `.toLowerCase().contains()`. Type as `CityData` or enum.
- **[Medium] `RunClubMembership.status` + `leftAt`/`deletedAt` are redundant** — `lib/run_clubs/domain/run_club_membership.dart:18-24`. Status is derivable from timestamps.
- **[Low] `RunClubDetailViewModel.allRuns` is dead** — `lib/run_clubs/presentation/detail/run_club_detail_view_model.dart:25`. Built and tested but never consumed in `ClubDetailBody`. Remove.
  - Done 2026-05-15: removed `allRuns` from `RunClubDetailViewModel`, its builder, generated Freezed output, and stale tests.
- **[Low] No `coverImages` gallery on `RunClub`** — single `imageUrl` field; community pages typically have 2–3 photos.

### B. Repositories

- **[High] `watchRunClubsByLocation` has no pagination** — `lib/run_clubs/data/run_clubs_repository.dart:57-69`. Streams every club in a city. Add `.limit(N)` immediately; plan paged loading or move to Algolia before scaling marketing.
  - Done 2026-05-15: added `RunClubsRepository.discoveryLimit` and applied `.limit(...)` to location and rating discovery streams with a repository limit test.
- **[Low] `watchRunClubsByLocationSortedByRating` is dead** — `lib/run_clubs/data/run_clubs_repository.dart:71-84`. Defined, tested, never called by UI. Wire up or delete.
- **[Low] `setClubPushNotifications` has no test** — repo `lib/run_clubs/data/run_clubs_repository.dart:184-197` and controller `lib/run_clubs/presentation/detail/run_club_membership_controller.dart:32` both untested.
  - Done 2026-05-15: added controller coverage for `setPushNotifications`; repository callable coverage already exercises the backend name/payload.
- Positives: every write goes through callables; `withBackendErrorContext` used consistently; keepAlive on the right providers.

### C. Controllers and view models

- **[High] Two near-identical "join" controllers** — `lib/run_clubs/presentation/list/run_clubs_list_controller.dart:20-23` and `lib/run_clubs/presentation/detail/run_club_membership_controller.dart:22-25`. Both expose a `joinMutation` and a `join`/`joinClub` method delegating to the same repo call. Unify behind one `RunClubMembershipController` with a single mutation.
  - Done 2026-05-15: deleted the list controller and routed list/detail join UI through `RunClubMembershipController.joinMutation`.
- **[Medium] `_CityPickerState._tryAutoSelectFromGps` instantiates `CityRepository` directly** — `lib/run_clubs/presentation/list/widgets/city_picker.dart:71-78`. Bypasses Riverpod DI; tests can't override the city repo here. Expose a `cityRepositoryProvider`.
  - Done 2026-05-15: changed GPS auto-select to use the existing `cityRepositoryProvider`.
- **[Medium] `SelectedRunClubCity._userSelected` flag is in-memory only** — `lib/run_clubs/presentation/list/run_clubs_list_view_model.dart:52`. GPS overwrites a user's manual pick across app restarts.
- **[Low] `void build() {}` action controllers** — both controllers exist only to host `static final` mutations. Pattern consistent across feature; flag only if you change project convention.
- **[Low] Hosted-clubs auto-included in `joinedClubs`** — `lib/run_clubs/presentation/list/run_clubs_list_view_model.dart:170-177`. Correct product behavior but partition factory only takes `joinedClubIds`; the host union happens outside. Move into the factory or rename for clarity.

### D. UI / widgets

- **[High] `_parts/` + Dart `part of` is unique to this feature** — `lib/run_clubs/presentation/list/widgets/run_club_list_tile.dart:16-18`. Modern Dart prefers separate libraries; `part of` blocks IDE refactors and re-exports. Either promote parts to top-level files or justify with a comment.
- **[Medium] `club_detail_body.dart` is doing too much in one file** — `lib/run_clubs/presentation/detail/widgets/club_detail_body.dart` (322 lines, 5 private widgets `_HostActionPanel`, `_ClubContactSection`, `_ContactRow`, `_GuestPrompt`, plus the body). Promote to siblings under `detail/widgets/`.
- **[Medium] `_ClubBellButton` uses `Theme.of(context).colorScheme` directly** — `lib/run_clubs/presentation/detail/widgets/membership_button.dart:90-97`. Everything else reads `CatchTokens.of(context)`.
- **[Medium] Magic numbers throughout** — e.g. `lib/run_clubs/presentation/detail/widgets/club_detail_body.dart:60-66`, `lib/run_clubs/presentation/list/widgets/run_club_discover_list.dart:27-32` (`14`/`8` mixed with `CatchSpacing.s5`).
- **[Medium] Raw hex colors not from theme** — `lib/run_clubs/presentation/list/widgets/run_club_list_tile_parts/directory_card.dart:43-46`, `lib/run_clubs/presentation/shared/run_club_cover_fallback.dart:197-216`.
- **[Medium] Two redundant "create club" entry points** — header `+` at `lib/run_clubs/presentation/list/widgets/run_clubs_sliver_header.dart:60-64` and trailing tile at `lib/run_clubs/presentation/list/widgets/run_club_avatar_rail.dart:41-95`. Pick one or differentiate.
- **[Low] `revenueRupees` calculated inside `HostStatsBar`** — `lib/run_clubs/presentation/detail/widgets/host_stats_bar.dart:18-22`. Business logic in a widget. Hardcoded `₹`.
- **[Low] `_buildBody` in detail screen is 13-arg plumbing** — `lib/run_clubs/presentation/detail/run_club_detail_screen.dart:125-151`.
- **[Low] `wrapMutationListeners` nests three `MutationErrorSnackbarListener` widgets** — `lib/run_clubs/presentation/detail/run_club_detail_screen.dart:51-60`. Build a `MutationErrorSnackbarListenerGroup` in `core/widgets/`.
- **[Low] `_HostAvatar` and `_AvatarChip` duplicate "image-or-initial" logic** — `lib/run_clubs/presentation/list/widgets/run_club_list_tile_parts/directory_card.dart:243-273` and `avatar_chip.dart`.
- **[Nit] `_RunClubCoverPalette.forSeed` hash uses additive code points** — `lib/run_clubs/presentation/shared/run_club_cover_fallback.dart:218`. Anagrams collide.
- Positives: const constructors used aggressively, `Semantics` labels on tappable surfaces, theme tokens overall, clean cover-photo + fallback separation.

### E. UX / product completeness

| Gap | Severity |
|---|---|
| No filters beyond city + search (pace, distance, gender balance, paid/free, beginner-friendly) | High |
| No sort options (closest, top-rated, most active, newest) — repo method exists, UI doesn't expose | High |
| Discover list shows joined clubs with "Joined" badge | Medium |
| No "Save / follow" for non-members | Medium |
| No "Notify me when this club posts a run" for non-members | Medium |
| No member roster on club detail (dating context!) | Medium |
| No leave-club confirmation — `membership_button.dart:29-41`, one tap | Medium |
| No tag editing in create/edit — `RunClub.tags` exists, never set | Medium |
| No archive/unarchive UI | Low |
| One-club-per-host limit is invisible (`+` button just disappears) | Low |
| No phone/email/Instagram validation in `create_run_club_contact_fields.dart:38-60` | Low |
| Area picker is free-text (`TODO` already in `create_run_club_details_fields.dart:51-54`) | Low |
| No preview before submit in the wizard | Low |
| No "share club" affordance on list tile (only on detail) | Low |
| Cover "map" is a decorative painter, not a real map | Low |

### F. Routing

Routes correctly wired: `/clubs/run-clubs/:runClubId`, `/clubs/run-clubs/:runClubId/edit`, `/clubs/create-run-club`. `EditRunClubRouteScreen` (`lib/routing/go_router.dart:528-557`) falls back to fetch when `extra` is missing. Solid.

**[Nit]** Edit route has no host-only guard at the router layer; host check is in `CreateRunClubController.submit:60-62`. A redirect would be more defensive but it's not exploitable (Cloud Function enforces).

### G. Test coverage

**Strong:**
- Detail view model has 8 cases covering loading/errors/host/member/upcoming derivation/partial hydration — `test/run_clubs/run_clubs_controllers_test.dart:82-244`.
- Repository round-trips Firestore conversion, callable invocations, real-time keep-alive — `test/run_clubs/run_clubs_repository_test.dart`.
- Draft repo covers stale expiry + multi-user isolation.
- Widget tests are 1,427 lines and cover empty state, search-empty, join/leave toggling, semantic labels.
- Flow test exercises tap-through-to-detail and live membership stream updates.

**Gaps:**
- No `setClubPushNotifications` test (repo or controller). [Medium]
  - Done 2026-05-15: added controller test coverage for the notification preference path.
- No `RunClubMembershipRepository` test file. [Medium]
- No test for host create-gate (`canCreateRunClub` returns false when host owns a club). [Medium]
- No edit-flow integration test. [Medium]
- No widget test for `RunClubCoverFallback` palette / initials. [Low]
- No test for `_CityPickerState._tryAutoSelectFromGps`. [Low]
- No share-button test on `ClubHeroAppBar`. [Low]

### H. Code quality / naming

- **`joinedClubs`/`joinedClubIds`** (client) vs **`memberCount`/`memberUserIds`** (server) — three names for overlapping ideas. Unify on "member" or "joined".
- **`CreateRunClubController.submit` is a 60-line method** with two distinct branches. Split into `_create` / `_update`.
- **`_restoreSavedDraft` swallows errors silently** — `lib/run_clubs/presentation/create/create_run_club_screen.dart:94` (`catch (_) { return; }`). At least log to `errorLoggerProvider`.
- **Unused `CreateRunClubDetailsFields`** — `lib/run_clubs/presentation/create/widgets/create_run_club_details_fields.dart`. Dead file; create flow uses `RunClubBasicsStep` + `RunClubDetailsStep`.
  - Done 2026-05-15: deleted the unused widget file.
- **Inconsistent feedback channel**: snackbar (draft restore/save) vs banner (mutation error) vs silent pop (mutation success). Pick a rule.

### I. Cross-feature consistency

Pulled from sibling-feature comparison (`runs/`, `payments/`, `swipes/`, `matches/`):

- **`run_clubs` is the only feature with a sub-foldered `presentation/`** (`list/`, `detail/`, `create/`, `shared/`). Others use flat `presentation/` + `widgets/`.
- **`_parts/` `part of` decomposition is unique to run_clubs.**
- **Error display is inconsistent**: only create screen uses `mutationErrorMessage()` directly; detail uses `MutationErrorSnackbarListener` (3x nested). `runs/` uses `ErrorBanner` + the helper.
- **`matches/` has zero tests** (separate concern).

### J. Project-specific gotcha audit

- ✅ Partial-update timestamp round-trip — N/A, all writes are callables.
- ✅ Backend-owned writes — `runClubs` rules deny all client writes (`firestore.rules:413-430`).
- ✅ `MutationError` access — `.isPending`, `.isSuccess`, `.hasError` correct throughout.
- ⚠️ `mutationErrorMessage()` — used in create only. Detail nests three listeners. Inconsistent.
- ✅ Schema alignment — `setRunClubNotificationPreference` exported and tested in functions.

### Prioritized next steps

| # | Step | Effort |
|---|---|---|
| 1 | Collapse two join controllers into one<br>Done 2026-05-15. | S |
| 2 | Fix `RunClub` archive state redundancy | S |
| 3 | Add `.limit(N)` to `watchRunClubsByLocation`<br>Done 2026-05-15. | S |
| 4 | Delete dead `CreateRunClubDetailsFields` + `allRuns` field<br>Done 2026-05-15. | S |
| 5 | Move `CityRepository` instantiation behind a provider<br>Done 2026-05-15. | S |
| 6 | Add tag editing + wire sort/filter UI | M |
| 7 | Add Save/Follow + notify-me for non-members | M |
| 8 | Add member roster to detail page | M |
| 9 | Promote `club_detail_body.dart` private widgets to own files | M |
| 10 | Decide `_parts/` / sub-foldered `presentation/` divergence | M |
| 11 | Add tests for push-notif preference, host gate, edit flow, city auto-select | M |
| 12 | Replace decorative cover painter with real map snippet | L |

---

### Additions from runs cross-read — 2026-05-15

While auditing runs I noticed a few small things to fold back here:

- **[Low] Pattern A reference**: The runs feature explicitly documents `RunBookingController` ([run_booking_controller.dart:14-27](lib/runs/presentation/run_booking_controller.dart:14)) as the project's *canonical* Pattern A example. When you unify the two run_clubs join controllers (finding C-High above), use that as the template. The unification will also reduce the nested `MutationErrorSnackbarListener` triple-wrap in [run_club_detail_screen.dart:51-60](lib/run_clubs/presentation/detail/run_club_detail_screen.dart:51) since you'll have one mutation to listen to instead of three.
- **[Low] No host "cancel club" / "delete club" path** — symmetric to the runs gap. `firestore.rules:413-430` denies direct delete, and no Cloud Function is exposed. Backend roadmap item, not a UI bug per se.
- **[Low] Dead-data parallel**: the `RunClubDetailViewModel.allRuns` field (already flagged) is the same "computed-but-not-displayed" pattern as `SavedRun.removedAt` in the runs feature. If you sweep dead model fields, do both at once.

---

## Runs
*Initial pass: 2026-05-15. Scope: `lib/runs/` (48 source files) + `test/runs/` (20 test files), ~16k+ LOC. Cross-referenced `firestore.rules`, `functions/src/runs/*`, `lib/routing/go_router.dart`.*

### Executive summary

Runs is the largest, most carefully-tested feature in the app and the deepest in terms of state coordination — Pattern A is canonized here, eligibility logic has a sealed-class state machine, the view-model split is clean, and the test surface is ~3× run_clubs. The work needed is mostly **closing product gaps** (no host can cancel/delete a run from the UI, no real run photos, no per-run reminders, no waitlist position) and **simplifying a few overgrown spots** (the create-run screen's 615 lines with scrambled form-key names, the hand-rolled stream chunking in `_watchRunsForParticipationStatuses`, duplicated eligibility/status logic between `Run` and `run_detail_cta`).

**Launch verdict:** Ship-ready. The host-can't-cancel-a-run gap is the only item that might bite within the first week if a host needs to cancel a run for weather/illness.

### A. Data modeling

- **[Medium] `SavedRun.removedAt` is dead** — [saved_run.dart:15](lib/runs/domain/saved_run.dart:15). `unsaveRun` does `delete()` ([saved_run_repository.dart:75-83](lib/runs/data/saved_run_repository.dart:75)), and rules deny updates (`firestore.rules:486` `allow update: if false`). The field exists on the freezed model and nowhere else. Remove.
  - Done 2026-05-16: removed `SavedRun.removedAt` from the Dart model, Firestore schema, generated TS mirrors, fixtures, and demo seeding paths; the rules test now still proves saved-run updates are denied without keeping the dead field name alive.
- **[Medium] `Run.statusFor()` has unreachable switch arms** — [run.dart:115-125](lib/runs/domain/run.dart:115). The switch handles `Attended`, `AlreadySignedUp`, `OnWaitlist` but `Run.eligibilityFor()` ([run.dart:102-112](lib/runs/domain/run.dart:102)) never returns those — those require knowing the participation edge. The doc comment acknowledges this. Effectively those switch arms are dead.
  - Done 2026-05-16: `Run.statusFor` now maps only fresh-viewer eligibility, `Run.eligibilityFor` accepts an injectable `now`, and the run-detail CTA reuses the domain method for fresh-viewer logic while keeping participation-aware states local.
- **[Medium] `eligibilityFor`/`statusFor` duplicated in the CTA** — [run_detail_cta.dart:211-255](lib/runs/presentation/widgets/run_detail_cta.dart:211): `_eligibilityForFreshViewer` and `_statusForEligibility` are copies of the domain methods. Either route fresh-viewer logic through `Run.eligibilityFor` and keep the participation-aware wrapper local to the CTA, or drop the domain methods entirely.
  - Done 2026-05-16: removed `_eligibilityForFreshViewer` from the CTA and routed the cancelled/deleted/null participation branch through `Run.eligibilityFor(userProfile, now: now)`.
- **[Low] `RunDraft.isEmpty` doesn't check all fields** — [run_draft.dart:51-64](lib/runs/domain/run_draft.dart:51) misses `paceName`, `locationDetails`, `startingPointLng`, `durationMinutes`. A draft with only a pace selected reports `isEmpty=true` and gets skipped by the save flow.
  - Done 2026-05-15: expanded `isEmpty` to include secondary location/time fields and non-default duration, with unit coverage.
- **[Low] Nullable counter trio**: `Run.bookedCount`/`checkedInCount`/`waitlistedCount` are `int?` with getters that fallback to `0`. Null vs 0 is never distinguished anywhere. Pick one.
- **[Low] `Run.title` builds a derived weekday-period string in the model** — [run.dart:127-136](lib/runs/domain/run.dart:127). Formatting in domain is unusual; consider moving to a formatter alongside `RunFormatters`.
- **[Low] `RunHypeAvatarQuery` has hand-written `==`/`hashCode`/`_sameGenders`** — [run_hype_avatar_stack.dart:23-41,167-173](lib/runs/presentation/widgets/run_hype_avatar_stack.dart:23). Use Freezed.

### B. Repositories

- **[High] `_watchRunsForParticipationStatuses` is 100+ lines of hand-rolled stream coordination** — [run_repository.dart:93-204](lib/runs/data/run_repository.dart:93). It listens to a participations query, chunks the resulting runIds, opens N sub-streams against the runs collection, and uses a `generation` counter to drop stale emissions. Works, but it's a lot of state to read. Either replace with rxdart's `switchMap` + `combineLatest`, or extract into a `MultiQueryRunStream` helper with a unit test for the stale-emission case.
- **[Medium] `fetchUpcomingRunsForClubs` silently caps clubs at 10** — [run_repository.dart:216](lib/runs/data/run_repository.dart:216) (`.take(10)`). Firestore `whereIn` limit. If a user follows 20 clubs the other 10 are invisible with no warning. Split into multiple queries or paginate.
  - Done 2026-05-16: current repository code chunks unique club ids into Firestore-safe `whereIn` groups and merges/sorts the results; added a regression test covering 12 clubs so this does not quietly regress to the old cap.
- **[Medium] `cancelRun` and `deleteRun` Cloud Functions exist but no Dart client method calls them** — `functions/src/index.ts:15` exports them, but [run_repository.dart](lib/runs/data/run_repository.dart) has no `cancelRun`/`deleteRun` method and no UI surfaces a host CTA. Hosts cannot cancel or delete a run from the app.
  - Done 2026-05-16: added typed callable DTOs, `RunRepository.cancelRun`/`deleteRun`, `RunBookingController` host mutations, host-manage CTAs, confirmation dialogs, and repository/controller/widget tests.
- **[Low] `SavedRunRepository.saveRun` writes a raw map** — [saved_run_repository.dart:61-72](lib/runs/data/saved_run_repository.dart:61). Bypasses the typed converter so it can use `FieldValue.serverTimestamp()`. Worth a one-line comment explaining why.
- **Positive:** `RecommendedRunsQuery` defines `==`/`hashCode` so the Riverpod `family` provider doesn't churn.

### C. Controllers and view models

- **[High] `CreateRunScreen._currentStepKey` has scrambled key names** — [create_run_screen.dart:95-100](lib/runs/presentation/create_run_screen.dart:95):
  ```
  0 => _step2Key,  // UI step 0 = Run details
  1 => _step1Key,  // UI step 1 = Where
  2 => _step0Key,  // UI step 2 = When
  _ => _step3Key,  // UI step 3 = Eligibility
  ```
  The `0/1/2/3` suffix on the form-key names doesn't match the order of steps in the PageView. Works (each key is unique to one form), but a future reader will assume `_step0Key` is for step 0. Rename to `_runDetailsKey`/`_whereKey`/`_whenKey`/`_eligibilityKey`.
  - Done 2026-05-15: renamed the form keys to step-owned names and updated the PageView/current-step wiring.
- **[Medium] `_hasUnsavedChanges` returns false when a draft is active** — [create_run_screen.dart:329-345](lib/runs/presentation/create_run_screen.dart:329). If a user restored a draft and then made further edits, no "unsaved changes" prompt fires on back. Track a `_dirtySinceLastSave` flag instead.
  - Done 2026-05-15: replaced the active-draft shortcut with a draft-content signature comparison that detects edits after restore/save.
- **[Medium] `RunDetailScreen` doesn't accept `initialRun`** — [run_detail_screen.dart](lib/runs/presentation/run_detail_screen.dart) vs `RunClubDetailScreen` which does. Deep links always show a full-screen spinner. Mirror the run_clubs pattern.
  - Done 2026-05-16: `RunDetailScreen` now accepts a route-matching `initialRun`, renders it while the canonical detail stream is loading, and run navigation surfaces pass the full `Run` as `state.extra` when they already have it.
- **[Low] `_restoreSavedDraft` silently swallows errors** — [create_run_screen.dart](lib/runs/presentation/create_run_screen.dart) (mirror of run_clubs same-named method). At least log.
- **[Low] PROJECT_CONTEXT step order is stale** — [`PROJECT_CONTEXT.md:259-263`](PROJECT_CONTEXT.md:259) lists the wizard as `When → Where → Run details → Eligibility`. The actual order in [create_run_screen.dart:562-598](lib/runs/presentation/create_run_screen.dart:562) is `Run details → Where → When → Eligibility`. Update the doc.
  - Done 2026-05-15: updated `PROJECT_CONTEXT.md` to the actual run creation step order.
- **[Low] `_stepTitle` switch in [create_run_screen.dart:517-522](lib/runs/presentation/create_run_screen.dart:517)** uses a `_` default for what should be step 0, with the actual default for step 3. Refactor to an exhaustive enum-keyed map.
  - Done 2026-05-15: made `_stepTitle` explicit for all four steps and throw for invalid indexes.
- **[Low] `RunDetailController.toggleSavedRun` returns `bool`** — but the consumer in `run_detail_body.dart:168-178` ignores the returned value (the saved-run stream updates the UI). The return type is misleading.
- **Positive:** `RunBookingController` is documented as the canonical Pattern A reference and lives up to that — clean separation, predictable mutation lifecycle, defensive `_requireSignedIn`.

### D. UI / widgets

- **[High] `RunPhotoHeader` paints a fake hand-drawn city map** — [run_photo_header.dart](lib/runs/presentation/widgets/run_photo_header.dart). The hero "photo" is a `CustomPainter` simulating roads/buildings. For a dating app this hurts polish a lot. Replace with: (a) an OSM static-tile snapshot centered on `startingPointLat/Lng`, or (b) actual photo upload support on the `Run` model.
  - Done 2026-05-16: added optional `Run.photoUrl`, create/update callable support, run-photo upload via the create-run flow, and changed `RunPhotoHeader` to render uploaded photos with a plain themed fallback.
- **[Medium] Hardcoded raw colors in `_RunMapPainter`** — `0xFF1A2E2A`, `0xFF0F1E2B`, `0xFF2A423D`, `0xFF2F2A24` ([run_photo_header.dart:120-153](lib/runs/presentation/widgets/run_photo_header.dart:120)). Not theme tokens.
  - Done 2026-05-16: removed `_RunMapPainter`; the fallback now uses `CatchTokens`.
- **[Medium] Pace-level colors hardcoded outside the theme** — [pace_level_theme.dart:16-33](lib/runs/domain/pace_level_theme.dart:16). The comment justifies it ("traffic-light semantic colors that don't vary by brand palette") but they're still not dark-mode-aware and not in `catch_tokens.dart`.
- **[Medium] `host_run_manage_screen.dart:38` duplicates revenue calc** — `bookedCount * (run.priceInPaise ~/ 100)`. Identical formula in `lib/run_clubs/presentation/detail/widgets/host_stats_bar.dart:18-22`. Pull into a `Run` extension method.
- **[Medium] Magic numbers throughout** — `SizedBox(width: 12)`, `padding: EdgeInsets.all(14)`, `expandedHeight: 320` in [run_detail_hero_app_bar.dart:30](lib/runs/presentation/widgets/run_detail_hero_app_bar.dart:30), etc. mixed with `CatchSpacing.s*` tokens. Pick one.
- **[Low] Three sign-in prompts on a single guest view of run detail** — bottom CTA (`_GuestBookCta` at [run_detail_body.dart:225-251](lib/runs/presentation/widgets/run_detail_body.dart:225)), social section banner (`_GuestWhoIsRunning` at [run_detail_social_section.dart:61-90](lib/runs/presentation/widgets/run_detail_social_section.dart:61)), and the save-button toggling also routes to onboarding (`_toggleSavedRun` at [run_detail_body.dart:160-165](lib/runs/presentation/widgets/run_detail_body.dart:160)). User sees the same prompt three places.
- **[Low] `run_detail_cta.dart:66-72` `errorMutation` fallback is misleading** — `firstWhere(... orElse: () => bookMutation)` returns the bookMutation even when nothing errored. Guarded by the `errorMutation.hasError` check afterwards, but the fallback intent is unclear.
- **[Low] `RunPinsMap.didUpdateWidget`** — [run_pins_map.dart:48-59](lib/runs/presentation/widgets/run_pins_map.dart:48) animates the camera in a post-frame callback only when the *initial* center prop changes. If a user is panning, an external update jumps them. Likely intentional but consider.

### E. UX / product completeness

| Gap | Severity |
|---|---|
| **Hosts can't cancel or delete a run from the UI** — Cloud Functions `cancelRun`/`deleteRun` exist (functions/src/index.ts:15) but no Dart method or CTA<br>Done 2026-05-16: host manage now exposes cancel/delete actions with destructive confirmations and hides delete once booked/waitlist/attendance activity is visible. | **High** |
| **No real run photos** — `RunPhotoHeader` is a fake painter; `Run` has no `photoUrl`<br>Done 2026-05-16: real run photo upload and `Run.photoUrl` rendering are wired through contracts, Functions, repository, create-run UI, and the detail header. | **High** |
| **No edit of capacity / price post-creation** — `updateRun` callable only handles descriptive/location fields (`run_callable_dtos.dart:RunDetailsCallableFields`) | Medium |
| **No per-run reminder push** — push notifications are club-level only | Medium |
| **Self check-in window is invisible to the user** — `run_arrival_action.dart` gates the CTA by a time window; outside the window the user sees no CTA and no countdown | Medium |
| **No "add to calendar"** for a booked run | Medium |
| **No waitlist position shown** — user joins, sees no indication of where they are | Medium |
| **No "I'm running late / can't make it" message** to host or co-attendees | Medium |
| **No refund preview on cancel** — paid run cancellation relies on Cloud Function logic; user has no info about expected refund | Medium |
| **Save run only from detail screen** — no save affordance on agenda list / map sheet | Low |
| **No inline map on run detail** — the meeting-point card is text + a chevron to a separate map screen | Low |
| **No host re-pin starting point** — uncertain; `RunDetailsCallableFields` includes `startingPointLat/Lng` so `updateRun` *can* take them, but no UI flow exposes editing them after creation | Low |
| **No "review before submit" preview step** in the wizard | Low |
| **No club context strip on run detail** — only the celebration screen mentions the club by name | Low |

### F. Routing

Routes from [`lib/routing/go_router.dart`](lib/routing/go_router.dart):
- `/clubs/run-clubs/:runClubId/runs/:runId` — run detail
- `/clubs/run-clubs/:runClubId/runs/:runId/attendance` — attendance sheet
- `/clubs/run-clubs/:runClubId/create-run` — create run
- `/calendar/run-clubs/:runClubId/runs/:runId` and `/dashboard/run-clubs/:runClubId/runs/:runId` — alternate entry paths
- `/runs/:runId/map` — standalone map (via `RunLocationMapRouteScreen`)

All wired correctly. No host-only guard at the router on `attendance` — relies on Cloud Function enforcement. Same defensive consideration as run_clubs edit.

### G. Test coverage

**Strong (20 test files):**
- Domain: `run_domain_test.dart`, `run_eligibility_test.dart`, `run_draft_test.dart`, `runs_domain_helpers_test.dart`, `run_formatters_test.dart` — full eligibility decision table covered.
- Data: `run_repository_test.dart`, `run_draft_repository_test.dart`, `saved_run_repository_test.dart` with FakeFirebaseFirestore + Fake FirebaseFunctions.
- Controllers: `create_run_controller_test.dart`, `run_booking_controller_test.dart`, `run_detail_controller_test.dart`.
- Screens: `attendance_sheet_screen_test.dart`, `create_run_screen_test.dart`, `location_picker_screen_test.dart`, `run_map_screen_test.dart`.
- Widgets: `runs_widgets_test.dart`, `run_detail_widgets_test.dart`, `run_hype_avatar_stack_test.dart`, `run_map_view_model_test.dart`.

**Gaps:**
- Self check-in error messages from `GeolocatorRunCheckInLocationService` ([run_check_in_location_service.dart:25-47](lib/runs/presentation/run_check_in_location_service.dart:25)) aren't surface-tested through the controller — only the location service interface. [Medium]
- No test confirming a `cancelMutation` success actually clears the booking from the UI (depends on the participation stream). [Medium]
- No test for `_watchRunsForParticipationStatuses` stale-generation handling. [Medium]
- No test for the create-run step-key scramble (a passing test wouldn't catch the confusing names anyway). [Low]
- No test for the run-detail deep-link loading state vs the run_clubs `initialRunClub` parity. [Low]<br>Done 2026-05-16: added a `RunDetailScreen` widget test that renders `initialRun` while live detail data is still loading.

### H. Code quality / naming

- **Scrambled `_step0/1/2/3Key` names** (already noted as High).
- **`signedUpCount`/`bookedCount` are aliases** — `signedUpCount` is `bookedCount ?? 0`. Sometimes UI uses one, sometimes the other (`host_run_manage_screen.dart:36` does `roster?.bookedCount ?? run.signedUpCount`). Pick the canonical name and rename.
- **`create_run_screen.dart` is 615 lines** — biggest file in the feature. State, all field controllers, draft restore, step ordering, validation, navigation, and the success/host-manage swap. Split into a `CreateRunFormState` value object + a screen.
- **Long single-method validations** in [eligibility_step.dart:26-48](lib/runs/presentation/widgets/eligibility_step.dart:26) — works, but `_validateAge` is asymmetric (checks `<= max` from min side, `>= min` from max side). Use a single shared validator.
- **`RunHypeAvatarQuery` could be Freezed** — already noted.

### I. Cross-feature consistency

- **`RunBookingController` is the canonical Pattern A** — explicitly documented at [run_booking_controller.dart:14-27](lib/runs/presentation/run_booking_controller.dart:14). When you collapse the run_clubs two-join-controllers issue, mirror this controller exactly.
- **No `_parts/` `part of` decomposition** — consistent with siblings; only `run_clubs` deviates.
- **Error display is consistent within the feature** — `ErrorBanner(message: mutationErrorMessage(...))` in `create_run_screen.dart:602`, `run_detail_cta.dart:77`, `attendance_sheet_screen.dart:99`. No nested `MutationErrorSnackbarListener` triples like the run_clubs detail screen.
- **Pattern D view-models are clean and tested** — `run_detail_view_model.dart`, `attendance_sheet_view_model.dart`, `run_map_view_model.dart` all extract a pure `buildXyzViewModel(...)` function for testability. Use this as the template for new view models.

### J. Project-specific gotcha audit

- ✅ Partial-update timestamp pitfall — all run/participation writes are callables; `savedRuns` writes a fresh doc with `FieldValue.serverTimestamp()`.
- ✅ `MutationError` and lifecycle access — correct throughout.
- ✅ `mutationErrorMessage()` — used consistently in 3 screens.
- ✅ Backend-owned writes — `runs` and `runParticipations` are `allow update: if false`; `savedRuns` is correctly user-owned with strict shape validation (`firestore.rules:476-486`).
- ✅ Schema alignment — `Run` Dart model, `run_callable_dtos.dart`, `functions/src/runs/*`, and the shared TS firestore mirror all agree on fields.

### Prioritized next steps

| # | Step | Effort |
|---|---|---|
| 1 | Wire `cancelRun` + `deleteRun` Cloud Functions into `RunRepository` and add host CTAs<br>Done 2026-05-16. | M |
| 2 | Add real photo support to `Run` (replace `RunPhotoHeader` fake painter)<br>Done 2026-05-16. | M |
| 3 | Rename scrambled `_step0/1/2/3Key` to step-named keys<br>Done 2026-05-15. | S |
| 4 | Remove `SavedRun.removedAt` (dead field)<br>Done 2026-05-16. | S |
| 5 | Remove dead switch arms from `Run.statusFor` or remove the duplicated logic in `run_detail_cta.dart`<br>Done 2026-05-16. | S |
| 6 | Fix `_hasUnsavedChanges` to track edits since last draft save<br>Done 2026-05-15. | S |
| 7 | Fix `RunDraft.isEmpty` to include missing fields<br>Done 2026-05-15. | S |
| 8 | Add `initialRun` deep-link placeholder to `RunDetailScreen` (mirror run_clubs)<br>Done 2026-05-16. | S |
| 9 | Replace `_watchRunsForParticipationStatuses` with rxdart-style `switchMap` + a test | M |
| 10 | Paginate or split `fetchUpcomingRunsForClubs` (10-club cap)<br>Done 2026-05-16. | S |
| 11 | Add waitlist position display + self-check-in countdown | M |
| 12 | Add "add to calendar" + per-run reminder push opt-in | M |
| 13 | Split `create_run_screen.dart` into form-state + screen | M |
| 14 | Update PROJECT_CONTEXT to match actual wizard step order<br>Done 2026-05-15. | S |
| 15 | Inline map preview on run detail | M |

---

## User profile
*Initial pass: 2026-05-15. Scope: `lib/user_profile/` (11 source files, ~2.3k LOC) + `test/user_profile/` (2 test files, ~240 LOC). Cross-referenced `firestore.rules`, `functions/src/profiles/updateUserProfile.ts`, `functions/src/shared/firestore.ts`, `lib/onboarding/`, `lib/public_profile/`.*

### Executive summary

The feature has the **lowest test-to-source ratio** of any feature audited so far (~10%) and the **largest single widget file** in the codebase (`profile_inline_editors.dart` at 951 lines). The two structural problems on top of those: (1) a **stalled name-field migration** with four fields and a fallback chain (`name`, `firstName`, `lastName`, `displayName`); (2) **two product-blocker UX gaps** — date-of-birth and gender are display-only with no editor, and the phone-number field has an inline editor but the auth-side phone-change flow isn't wired, so a "save" desyncs auth from profile. Editing for notification prefs and match-age prefs isn't exposed at all.

**Launch verdict:** **Not ship-ready** as-is. The phone-edit / auth desync is a correctness bug. The DOB/gender lock-out is a support burden waiting to happen. About 1 week of work to close the blockers plus the file-splitting cleanup; the rest is incremental.

### A. Data modeling

- **[High] Four name fields with a fallback ladder** — [user_profile.dart:180-183](lib/user_profile/domain/user_profile.dart:180). `name` is required and non-empty; `firstName`/`lastName`/`displayName` default to `''`. `accountDisplayName` and `publicDisplayName` ([user_profile.dart:248-265](lib/user_profile/domain/user_profile.dart:248)) walk a fallback chain. The TS firestore mirror lists all four ([functions/src/shared/firestore.ts:141-143](functions/src/shared/firestore.ts:141)). Looks like a partly-done migration from legacy `name` → structured names. Pick a canonical form, write a one-shot migration, and remove the fallback ladder. Until then, every callsite has to decide which getter to use.
- **[Medium] `email: ''` vs `instagramHandle: null`** — inconsistent absence representation for two optional fields. Empty-string-as-sentinel is a smell, especially with phone-auth where most users will never set email.
- **[Medium] Seven flat notification-pref booleans** — `prefsNewCatches`, `prefsMessages`, `prefsRunReminders`, `prefsRunStatusUpdates`, `prefsClubUpdates`, `prefsWeeklyDigest`, `prefsShowOnMap` ([user_profile.dart:234-240](lib/user_profile/domain/user_profile.dart:234)). Adding a new pref requires touching the model, the rules, the TS mirror, and the callable. A `Map<String, bool>` keyed by enum is more extensible. Bigger issue: **none of these are surfaced in the profile UI yet** (search confirms no editor for them in this feature).
- **[Low] `paceMinSecsPerKm: 300`, `paceMaxSecsPerKm: 420` magic defaults** — [user_profile.dart:228-229](lib/user_profile/domain/user_profile.dart:228). The slider in the editor uses 240-540 ([profile_tab.dart:318-319](lib/user_profile/presentation/widgets/profile_tab.dart:318)). A nullable "not yet set" representation would be honest; today every new user has a default pace they never picked.
- **[Low] `photoUrls` and `photoThumbnailUrls` are parallel lists kept aligned by backend** — works, but a single `List<{full,thumbnail}>` would avoid index-misalignment risk.

### B. Repositories

- **[High] `setUserProfile` does a full-document `set()` directly to Firestore** — [user_profile_repository.dart:63-71](lib/user_profile/data/user_profile_repository.dart:63). The project's §18 partial-update convention warns against this. Only caller is `lib/onboarding/presentation/onboarding_controller.dart:224` (initial profile creation, allowed by `isValidUserCreate` rules). Confine to creation with a `@visibleForTesting`-style guard or rename to `createUserProfile` so the dangerous shape can't be reused for edits.
- **[Medium] `updateUserProfile` takes `uid` but never uses it** — [user_profile_repository.dart:78-91](lib/user_profile/data/user_profile_repository.dart:78). The callable derives uid from `request.auth.uid`. Remove the unused parameter (or assert it matches).
- **[Medium] `_callableFields` doesn't recurse into nested Maps** — [user_profile_repository.dart:122-136](lib/user_profile/data/user_profile_repository.dart:122). Iterables are handled, but a `Map<String, Timestamp>` value would silently pass through unconverted. If you ever ship a nested-map field (e.g. notification prefs as a map per (A) above), this will bite.
- **[Low] `Stream.empty()` in the `watchUserProfile` provider** — [user_profile_repository.dart:155](lib/user_profile/data/user_profile_repository.dart:155). When uid is loading, the stream is empty. The UI's `.when(loading)` arm handles it but a future consumer reading `.asData?.value` would silently get `null`.
- **Positive:** all writes other than the create path go through callables; `withBackendErrorContext` used consistently; `updatePhotoUrls`/`updateDetectedLocation`/`setProfileComplete` are typed convenience wrappers.

### C. Controllers and view models

- **[Medium] `ProfileEditController.saveFields` chains saves through `_pendingSave`** — [profile_edit_controller.dart:18-62](lib/user_profile/presentation/profile_edit_controller.dart:18). Good idea (serializes rapid bottom-sheet edits, prevents races), but each save's error is logged twice (once on the chained `_pendingSave.catchError`, once on `nextSave.catchError`). Plus there's no cancellation on dispose. Also the chain holds the previous future forever — if a user spends the whole session editing, you have a growing chain of `then`s in memory. Use a `Completer`-based queue or a single in-flight token instead.
- **[Medium] `_InlineSaveState` mixin holds local `_isSaving`/`_saveError` per editor instance** — [profile_inline_editors.dart:34-69](lib/user_profile/presentation/widgets/profile_inline_editors.dart:34) — while the global `ProfileEditController.saveFieldsMutation` is also tracking the same lifecycle. Two parallel state tracks for one action. The mutation is barely used by the UI. Either drop the mutation or drop the mixin.
- **[Low] `Future.value()` initializer** is fine but a one-liner `Future<void>.value()` is clearer about void.
- **Positive:** the "Pattern A" doc comment matches other controllers.

### D. UI / widgets

- **[High] `profile_inline_editors.dart` is 951 lines** — one file holds 11+ classes: the editable-text component, four inline editors (text/height/single-choice/multi-choice/range), three chip helpers, the action row, the panel, the padding wrapper, and the save-state mixin. Each editor should be its own file (`profile_inline_text_editor.dart` etc.). The shared `_InlineEditorPanel`/`_InlineEditorActions`/`_InlineSaveState` go in a `profile_inline_common.dart`. This is the single biggest readability blocker in the feature.
- **[High] `profile_tab.dart` is 519 lines** — the section composition lists (basics/background/intentions/lifestyle/location/running) live inline alongside the `_textEntry`/`_singleEnumEntry`/`_multiEnumEntry` factory helpers. Extract section builders to separate files.
- **[Medium] `ProfileInlineEditableText` uses raw `EditableText` and a hand-rolled underline** — [profile_inline_editors.dart:106-235](lib/user_profile/presentation/widgets/profile_inline_editors.dart:106). Manual `TextPainter`-based width measurement to size an `AnimatedContainer` underline. Loses standard `TextField` features (error indicator hooks, IME quirks handled by Flutter). Either justify with a clear comment about why `TextField`'s underline didn't work, or replace with `CatchTextField`/`TextField` and lose ~80 lines.
- **[Medium] `currentFieldValue` vs `currentValue` distinction is subtle** — [profile_tab.dart:402-448](lib/user_profile/presentation/widgets/profile_tab.dart:402) and the editor's "unchanged" detection at [profile_inline_editors.dart:334-343](lib/user_profile/presentation/widgets/profile_inline_editors.dart:334) has three fallback rules. Hard to reason about. Consolidate to a single `OriginalValue<T>` type.
- **[Medium] Stringly-typed expansion state** — `_expandedField: String?` in [profile_tab.dart:96](lib/user_profile/presentation/widgets/profile_tab.dart:96). A typo in `_toggleField('paceRagne')` compiles. Use an enum.
- **[Medium] `ProfileInfoEntry` has two shapes** — [profile_info_section.dart:8-28](lib/user_profile/presentation/widgets/profile_info_section.dart:8): either `builder` (custom widget) or `icon`/`label`/`value` + optional `editor`. Most entries set `builder`, making the `editor` field dead-in-practice for those paths. Two distinct entry types would be clearer.
- **[Low] DOB display uses raw string interpolation** — [profile_tab.dart:135](lib/user_profile/presentation/widgets/profile_tab.dart:135) (`'${user.dateOfBirth.day.toString().padLeft(2, '0')}/...'`). Use `RunFormatters`-style formatters or the `intl` package.
- **[Low] `profile_screen.dart` `_handlePreviewLeadingOverscroll`** — bespoke jump on the outer scroll controller in response to inner overscroll. Works but fragile to future Flutter scroll-physics changes.
- **[Low] `profile_sliver_header.dart:17` `titleHeight: 104` is hardcoded** — should reference `CatchSliverHeader` constants.
- **[Low] Most `_textEntry` calls don't set autofill hints for organization/job title** — minor missed autofill opportunity.

### E. UX / product completeness

| Gap | Severity |
|---|---|
| **Phone number has an inline text editor but no OTP re-verification flow** — [profile_tab.dart:142-152](lib/user_profile/presentation/widgets/profile_tab.dart:142) calls `validateRequiredPhoneNumber` then saves through `updateUserProfile`. Auth phone (Firebase Auth) is *not* updated. User ends up with profile phone ≠ auth phone, and future logins use the old phone. | **Blocker** |
| **Date of birth has no editor** — [profile_tab.dart:131-136](lib/user_profile/presentation/widgets/profile_tab.dart:131): display-only `ProfileInfoEntry`, no `onTap`. Typo at onboarding → no way to fix in-app. | **High** |
| **Gender has no editor** — [profile_tab.dart:137-141](lib/user_profile/presentation/widgets/profile_tab.dart:137): display-only. | **High** |
| **Notification preferences not editable here** — seven `prefs*` boolean fields exist on the model with no UI surface in `user_profile/`. Possibly intended for `lib/settings/`; worth confirming. | **High** |
| **Match-age preferences not editable** — `minAgePreference`/`maxAgePreference` set during onboarding, no edit path in profile. | **High** |
| **`prefsShowOnMap` exists but no toggle** — privacy-relevant. | High |
| **Pace range is metric-only** — most Indian runners are fine with min/km, but no unit toggle for min/mile. | Medium |
| **No verified-state shown** for email/phone/Instagram | Medium |
| **Bio max length 2000 chars but no character counter** in the bio editor — [profile_validation.dart:9](lib/user_profile/domain/profile_validation.dart:9) and [profile_tab.dart:347-361](lib/user_profile/presentation/widgets/profile_tab.dart:347). | Medium |
| **No preview-as-someone-interested-in-me toggle** — preview tab shows public profile flat, doesn't reflect filtered viewer perspective. | Low |
| **No deactivate-account link from profile** — only request-deletion lives elsewhere. | Low |
| **Photo reorder UX unclear** — `PhotoGrid` is reused; drag-to-reorder support is its concern but not exercised by a test here. | Low |
| **No back/cancel hint** when an inline editor is open — saves on enter, cancels via the Cancel button only. | Low |

### F. Routing

- `/you` → `ProfileScreen` (per PROJECT_CONTEXT route map).
- `/settings` from the title-bar icon.
- `/profiles/:uid` for public profiles is handled by a separate feature.
- No deep-link target for an individual editor (acceptable).

### G. Test coverage

**What exists (2 files, ~240 LOC):**
- Domain: age boundary cases, `toJson` omits uid, public-profile projection privacy, display-name fallback chain, thumbnail fallback.
- Repository: `setUserProfile` round-trip, `updatePhotoUrls` delegation, `_callableFields` timestamp normalization.

**Gaps (this is the leanest test surface in the audit):**
- No widget test for any inline editor (text / single-choice / multi-choice / height / range). [High]
- No widget test for `ProfileTab` or `ProfileScreen` (tab switching, preview tab, expand/collapse). [High]
- No test for `ProfileEditController._pendingSave` serialization or the double-logging behavior. [High]
- No test confirming `_callableFields` handles nested Maps (it doesn't — would catch the gap in (B)). [Medium]
- No test for `validateOptionalInstagramHandle` / `validateOptionalEmail` regex edge cases. [Medium]
- No test for `normalizeInstagramHandle` (`@asha` → `asha`, surrounding whitespace, etc.). [Medium]
- No test for `normalizeAgePreferenceRange` swap logic. [Medium]
- No test for the preview-tab overscroll handoff. [Low]
- No test confirming `_expandedField` collapses on save / cancel. [Low]
- Coverage ratio (~10%) vs runs (~38%), run_clubs (~22%). Lowest among audited features.

### H. Code quality / naming

- **`profile_inline_editors.dart` 951 lines** (already noted as High).
- **`profile_tab.dart` 519 lines** (already noted as High).
- **`_expandedField` stringly-typed** (already noted).
- **`_callableFields` / `_callableValue`** are file-private functions used only by one instance method. Could be private static helpers on the class.
- **`ProfileInfoEntry` dual-shape** (builder vs structured) is confusing; the `editor` field is dead when `builder` is set.
- **Inconsistent absence representation** between `email: ''` and `instagramHandle: null` (already noted).
- **`Future.value()` initializer** of `_pendingSave` — minor.
- **Mixed `String?` vs `''` defaults** across the model — defaults are `''` for `firstName`/`lastName`/`displayName`/`email`/`bio`, `null` for `instagramHandle`/`city`/`occupation`/`company`/etc. The pattern doesn't track required-vs-optional clearly.

### I. Cross-feature consistency

- **Direct `.set()` create path** is unique to user_profile. Every other feature audited uses callables.
- **`_InlineSaveState` local-save-state mixin** is unique to this feature. Other features rely on the mutation-driven pattern alone.
- **951-line widget file** is the largest in the codebase. No parallel in run_clubs/runs/payments/swipes.
- **Test coverage is the thinnest** of audited features. runs has 20 test files, run_clubs 7, payments 5, user_profile 2.
- **Profile uses `appErrorMessage` (not `mutationErrorMessage`) for save errors** — [profile_inline_editors.dart:65-67](lib/user_profile/presentation/widgets/profile_inline_editors.dart:65). Acceptable since the local-save mixin sidesteps the mutation, but worth normalizing on one helper.

### J. Project-specific gotcha audit

- ⚠️ **`setUserProfile` full-doc `set()` only safe in create path** — already noted. Add a guard or rename.
- ✅ `updateUserProfile` callable used for every edit; rules deny most direct updates (`isValidUserUpdate` allows only narrow runtime fields).
- ✅ `toJson` omits `uid` correctly.
- ✅ Public profile projection drops `latitude`/`longitude`/`phoneNumber` (confirmed by `user_profile_domain_test.dart:72-80`).
- ⚠️ **Name-field migration mid-flight** — Dart model, TS schema, rules, and tests all carry both legacy `name` and structured `firstName`/`lastName`/`displayName`. Track to completion.

### Cross-read additions to earlier features (2026-05-15)

While auditing user_profile I noticed a few items worth back-porting:

- **Runs / run_clubs — Iterable-only normalization helper.** Each repository has its own `Timestamp`/`DateTime` normalization layer for callables. `UserProfileRepository._callableFields` is the most permissive (handles Iterables recursively). If a shared `BackendCallable.normalize(...)` helper existed in `core/`, all three features could deduplicate. Low priority but cheap.
- **All three features — direct `.set()` audit.** user_profile's `setUserProfile` is the only direct `.set()` write in the audited features so far. Confirms the §18 convention is otherwise well-respected.
- **Pattern A variants.** Three slightly different Pattern A controller flavors now exist: simplest (`RunClubsListController` — single mutation, single method); canonical (`RunBookingController` — multiple mutations, no local state); serialized-saves (`ProfileEditController` — `_pendingSave` chain). The third is the only one that maintains queue ordering. Worth picking a single recommended Pattern A variant in the project conventions doc.

### Prioritized next steps

| # | Step | Effort |
|---|---|---|
| 1 | **Wire phone-change OTP flow OR remove the phone editor** in profile_tab | M |
| 2 | **Add DOB editor** (inline date picker) | S |
| 3 | **Add gender editor** (inline single-choice — reuse `ProfileInlineSingleChoiceEntryEditor`) | S |
| 4 | **Add match-age and notification-preference editors** (or confirm they live in `lib/settings/` and link from here) | M |
| 5 | Decide name-field canonical form, migrate, remove fallback ladder | M |
| 6 | Split `profile_inline_editors.dart` into one file per editor + a `common.dart` | M |
| 7 | Split `profile_tab.dart` into section builders | M |
| 8 | Add widget tests for inline editors and profile tab | M |
| 9 | Add test for `ProfileEditController._pendingSave` serialization | S |
| 10 | Fix `_callableFields` to recurse into Maps (or restrict the field set) | S |
| 11 | Remove unused `uid` param from `updateUserProfile`, rename `setUserProfile` → `createUserProfile` | S |
| 12 | Replace `ProfileInlineEditableText` raw `EditableText` with `CatchTextField` (or justify) | S |
| 13 | Convert `_expandedField: String?` to an enum | S |
| 14 | Add bio character counter | S |
| 15 | Surface `prefsShowOnMap` toggle (privacy) | S |
