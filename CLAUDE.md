# Catch App — Audit & TODO Tracker

## How to use this file
Each section lists gaps found during the 2026-04-22 audit. Mark items `[x]` when done.
If we hit a usage limit mid-session, resume from the next unchecked item.

---

## Status: Audit complete — TODO comments added to all files.
## Next: Work through the TODO items below, feature by feature.

---

## 1. Dashboard (all hardcoded — never shows real data)

| # | File | Issue | Done |
|---|------|-------|------|
| 1 | `lib/dashboard/presentation/dashboard_screen.dart:32` | `_resolveHasBookedRun()` always returns `false`; `DashboardFull` is never shown. Wire to `signedUpRunsProvider` or `attendedRunsProvider`. | [x] |
| 2 | `lib/dashboard/presentation/widgets/dashboard_full.dart:28` | `dayCity()` hardcodes "Mumbai". Added `IndianCity? city` field to `AppUser`; `dayCity()` now uses `user.city?.label`. | [x] |
| 3 | `lib/dashboard/presentation/widgets/next_run_hero.dart` | Entire widget is hardcoded (title, time, location, participant count, match count). Wire to the user's next signed-up run via `signedUpRunsProvider`. | [x] |
| 4 | `lib/dashboard/presentation/widgets/catches_callout.dart` | Entire widget is hardcoded (countdown, unswiped count). Wire to the user's most-recent attended run + swipe state. | [x] |
| 5 | `lib/dashboard/presentation/widgets/quick_actions.dart` | "Browse runs" now navigates to RunClubsListScreen. Map view and Calendar are not yet built (no-op). | [x] |
| 6 | `lib/dashboard/presentation/widgets/stride_card.dart` | "28.4 km · 3 runs" and the bar chart are hardcoded. Aggregate from user's attended runs. | [x] |
| 7 | `lib/dashboard/presentation/widgets/recommendations.dart` | Static list `_runs` replaced with real upcoming runs from `followedRunClubIds` via `recommendedRunsProvider`. | [x] |
| 8 | `lib/dashboard/presentation/widgets/empty_hero_card.dart:53` | "Find a run near me" button has empty `onPressed: () {}`. Should navigate to the Clubs tab. | [x] |

---

## 2. Run Detail

| # | File | Issue | Done |
|---|------|-------|------|
| 9 | `lib/runs/presentation/widgets/run_detail_body.dart:98` | Share button has `onTap: () {}`. Implement using `share_plus` or similar. | [ ] |
| 10 | `lib/runs/presentation/widgets/run_detail_body.dart:105` | Bookmark button has `onTap: () {}`. Decide on bookmark/save feature or remove button. | [ ] |
| 11 | `lib/runs/presentation/widgets/who_is_running.dart:48` | `PersonAvatar(name: run.signedUpUserIds[i])` passes a raw UID as the name. Should batch-fetch `PublicProfile` for each signed-up user and show their actual name/photo. | [x] |

---

## 3. FCM (Push Notifications)

| # | File | Issue | Done |
|---|------|-------|------|
| 12 | `lib/core/fcm_service.dart:78` | `_handleTap` routes to `/matches/$matchId` but the actual GoRouter path is `/chats/$matchId`. Notification taps land on a 404. **Fixed 2026-04-22.** | [x] |

---

## 4. Payment History

| # | File | Issue | Done |
|---|------|-------|------|
| 13 | `lib/payments/presentation/payment_history_screen.dart:93` | Tile always shows "Run booking" as the title. Now fetches run title from Firestore on the fly via `watchRunProvider`. | [x] |

---

## 5. Dead Code / Never-Wired Widgets

| # | Location | Issue | Done |
|---|----------|-------|------|
| 14 | `lib/dashboard/presentation/widgets/dashboard_full.dart` and its sub-widgets (`NextRunHero`, `CatchesCallout`, `StrideCard`, `Recommendations`) | All wired to real data as part of items #1–7 above. | [x] |

---

---

## 6. Attendance — ENTIRE SWIPE FLOW IS BROKEN (critical)

`attendedUserIds` on a `Run` document is **never written by any Cloud Function or client code.**
No mechanism exists to mark a run as "attended" after it ends.

**Downstream breakage:**
- `attendedRunsProvider(uid)` → always empty → `SwipeHubScreen` always shows "No runs yet"
- `SwipeCandidateRepository.fetchCandidates` reads `attendedUserIds` → always empty → `SwipeScreen` never loads candidates
- `Run.hasAttended(uid)` → always `false` → `RunSignUpStatus.attended` never triggered
- `StrideCard` stats always empty
- `ReviewsSection` shows "Write a review" but nobody can trigger attendance-based gating

| # | What to build | Done |
|---|---------------|------|
| 15 | **Cloud Function `markRunAttendance`**: Callable function created in `functions/src/runs/markRunAttendance.ts`. Host calls it; it copies `signedUpUserIds` → `attendedUserIds`. Requires caller to be the club host. Run must have ended. | [x] |
| 16 | **`run_repository.dart`**: `markAttendance({required runId})` added — calls the `markRunAttendance` Cloud Function. | [x] |

---

## 7. Reviews — Missing Guards

| # | File | Issue | Done |
|---|------|-------|------|
| 17 | `lib/reviews/presentation/reviews_section.dart:92` | Any logged-in user can review any club/run — no attendance check. Gate the "Write a review" CTA behind `run.hasAttended(uid)` for run-level reviews, or `isMember` for club-level reviews. | [x] |
| 18 | `lib/reviews/presentation/reviews_section.dart` | `isHost` is not passed in, so the host can write a review of their own club. Add an `isHost` parameter and hide the CTA when true. | [x] |
| 19 | `lib/reviews/presentation/reviews_section.dart:32` | `_previewCount = 5` hard cap with no "See all reviews" button. Added a "See all N reviews" bottom sheet. | [x] |

---

## 8. Cloud Function Bugs

| # | File | Issue | Done |
|---|------|-------|------|
| 20 | `functions/src/runs/signUpUserForRun.ts:89` | Error message says **"You have been added to the waitlist."** but the function does NOT add the user to the waitlist — it just rejects them. The client would have to call `joinWaitlist` separately. Change the error message to "This run is now full." | [x] |
| 21 | `functions/src/matching/onSwipeCreated.ts` | Cross-run matching is intentional for MVP. Decision documented in inline comment. | [x] |

---

## Notes

- **Critical:** Items #15–16 (attendance) break the entire swipe/catches feature. Fix these first.
- Items #12 (FCM route) was fixed in the audit session.
- All other items are UX/data gaps that don't prevent other features from working.
- The `Payment` model lacks an `activityTitle` field — affects payment history tile (#13).

---

## Session History

| Date | Work done |
|------|-----------|
| 2026-04-22 | Full audit pass 1: dashboard, runs, FCM, payments. TODO comments added. FCM route bug fixed. |
| 2026-04-22 | Full audit pass 2: functions, swipes, reviews, Cloud Functions. Found critical `attendedUserIds` gap (#15), review guards (#17–19), CF message bug (#20). |
| 2026-04-22 | Implemented all TODOs #1–#21. Highlights: `markRunAttendance` CF created (#15–16); all dashboard widgets wired to real data (#1–8, #14); `AppUser.city` field added (#2); `WhoIsRunning` batch-fetches `PublicProfile` (#11); `ReviewsSection` guards + "See all" (#17–19); payment history shows run title (#13); CF bugs fixed (#20–21). Run `build_runner` is up to date. |
