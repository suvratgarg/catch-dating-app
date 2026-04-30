# Catch App — Test Plan

## How to use this file
Each item is one test or test group. Mark `[x]` when done.
Tests are ordered from pure domain logic (fastest, no Flutter) up to full widget flows.
Resume from the next unchecked item after any pause.

**Conventions used below:**
- **unit** — pure Dart, no Flutter, no Firebase. `dart test` friendly.
- **widget** — `testWidgets` with `ProviderScope(overrides: [...])`.
- **flow** — multi-screen widget test with a real `GoRouter`.

---

## 1. Domain — `Run`

File: `test/runs/run_domain_test.dart`

| # | Type | What to test | Done |
|---|------|-------------|------|
| 1 | unit | `run.title` returns `"Saturday Morning Run"` for a Saturday 6 AM start | [ ] |
| 2 | unit | `run.title` returns `"Wednesday Afternoon Run"` for a Wednesday 2 PM start | [ ] |
| 3 | unit | `run.isUpcoming` is `true` when `startTime` is 1 h in the future | [ ] |
| 4 | unit | `run.isUpcoming` is `false` when `startTime` is 1 h in the past | [ ] |
| 5 | unit | `run.isFull` is `false` when `signedUpUserIds.length < capacityLimit` | [ ] |
| 6 | unit | `run.isFull` is `true` when `signedUpUserIds.length == capacityLimit` | [ ] |
| 7 | unit | `run.isFree` is `true` when `priceInPaise == 0` | [ ] |
| 8 | unit | `run.isSignedUp(uid)` returns `true` only if uid is in `signedUpUserIds` | [ ] |
| 9 | unit | `run.hasAttended(uid)` returns `true` only if uid is in `attendedUserIds` | [ ] |
| 10 | unit | `run.isOnWaitlist(uid)` returns `true` only if uid is in `waitlistUserIds` | [ ] |

---

## 2. Domain — `Run.eligibilityFor` (all 8 branches)

File: `test/runs/run_eligibility_test.dart`

| # | Type | What to test | Done |
|---|------|-------------|------|
| 11 | unit | Returns `Attended` when `uid` is in `attendedUserIds` | [ ] |
| 12 | unit | Returns `AlreadySignedUp` when signed up and not yet attended | [ ] |
| 13 | unit | Returns `RunPast` when `startTime` is in the past and user never signed up | [ ] |
| 14 | unit | Returns `OnWaitlist` when user is on the waitlist (future run, not full) | [ ] |
| 15 | unit | Returns `AgeTooYoung` when user age < `constraints.minAge` | [ ] |
| 16 | unit | Returns `AgeTooOld` when user age > `constraints.maxAge` | [ ] |
| 17 | unit | Returns `GenderCapacityReached` when user's gender slot is at cap | [ ] |
| 18 | unit | Returns `RunFull` when run is at capacity (and user meets all other criteria) | [ ] |
| 19 | unit | Returns `Eligible` for a future, non-full run the user qualifies for | [ ] |
| 20 | unit | `run.statusFor(user)` maps each `eligibilityFor` result to the correct `RunSignUpStatus` | [ ] |

---

## 3. Domain — `AppUser`

File: `test/app_user/app_user_domain_test.dart`

| # | Type | What to test | Done |
|---|------|-------------|------|
| 21 | unit | `user.age` computes correctly for a birthday earlier this year | [ ] |
| 22 | unit | `user.age` computes correctly for a birthday later this year (year - 1) | [ ] |
| 23 | unit | `user.age` computes correctly on the exact birthday | [ ] |

---

## 4. Domain — Reviews

File: `test/reviews/review_document_id_test.dart` *(existing — keep)*

| # | Type | What to test | Done |
|---|------|-------------|------|
| 24 | unit | `reviewDocumentId` is deterministic per `(runClubId, reviewerUserId)` pair *(already passing)* | [x] |

---

## 5. Domain — `Version` (force-update)

File: `test/force_update/version_test.dart`

| # | Type | What to test | Done |
|---|------|-------------|------|
| 25 | unit | `Version.parse("1.2.3")` produces correct major/minor/patch | [ ] |
| 26 | unit | `v1 < v2` comparison is `true` when major is lower | [ ] |
| 27 | unit | `v1 < v2` comparison is `true` when major is equal and minor is lower | [ ] |
| 28 | unit | `v1 < v2` is `false` for equal versions | [ ] |

---

## 6. `RunBookingController` logic

File: `test/runs/run_booking_controller_test.dart`

| # | Type | What to test | Done |
|---|------|-------------|------|
| 29 | unit | `book()` calls `paymentRepo.bookFreeRun` for a free run | [ ] |
| 30 | unit | `book()` calls `paymentRepo.processPayment` for a paid run | [ ] |
| 31 | unit | `book()` throws `UnsupportedError` for a paid run on a platform where `supportsPaidBookings` is `false` | [ ] |

---

## 7. Router redirects

File: `test/routing/router_redirect_test.dart`

| # | Type | What to test | Done |
|---|------|-------------|------|
| 32 | unit | Unauthenticated user (`uid == null`) visiting `/` redirects to `/onboarding` | [ ] |
| 33 | unit | Authenticated user with no profile doc visiting `/` redirects to `/onboarding` | [ ] |
| 34 | unit | Authenticated user with `profileComplete = false` visiting `/` redirects to `/onboarding` | [ ] |
| 35 | unit | Fully set-up user visiting legacy `/auth` redirects to `/` | [ ] |
| 36 | unit | Fully set-up user visiting `/` does not redirect | [ ] |
| 37 | unit | Unauthenticated legacy `/auth` links redirect to `/onboarding` without an email/password screen | [ ] |

---

## 8. Widget — `DashboardScreen`

File: `test/dashboard/dashboard_screen_test.dart`

| # | Type | What to test | Done |
|---|------|-------------|------|
| 38 | widget | Shows `DashboardEmpty` (contains "Find a run near me") when `signedUpRunsProvider` returns `[]` | [ ] |
| 39 | widget | Shows `DashboardFull` (contains greeting text) when `signedUpRunsProvider` returns a non-empty list | [ ] |
| 40 | widget | Shows `CircularProgressIndicator` while `appUserStreamProvider` is loading | [ ] |

---

## 9. Widget — `EmptyHeroCard`

File: `test/dashboard/empty_hero_card_test.dart`

| # | Type | What to test | Done |
|---|------|-------------|------|
| 41 | widget | Tapping "Find a run near me" navigates to `/clubs` | [ ] |

---

## 10. Widget — `NextRunHero`

File: `test/dashboard/next_run_hero_test.dart`

| # | Type | What to test | Done |
|---|------|-------------|------|
| 42 | widget | Shows the run title and meeting point when `signedUpRunsProvider` has an upcoming run | [ ] |
| 43 | widget | Returns `SizedBox.shrink()` (renders nothing) when there are no upcoming signed-up runs | [ ] |

---

## 11. Widget — `CatchesCallout`

File: `test/dashboard/catches_callout_test.dart`

| # | Type | What to test | Done |
|---|------|-------------|------|
| 44 | widget | Returns `SizedBox.shrink()` when `attendedRunsProvider` is empty | [ ] |
| 45 | widget | Returns `SizedBox.shrink()` when attended runs exist but swipe window has closed (endTime + 24 h < now) | [ ] |
| 46 | widget | Renders countdown text when an attended run has an open swipe window | [ ] |
| 47 | widget | Tapping the card navigates to `/catches/:runId` | [ ] |

---

## 12. Widget — `StrideCard`

File: `test/dashboard/stride_card_test.dart`

| # | Type | What to test | Done |
|---|------|-------------|------|
| 48 | widget | Shows `0.0 km · 0 runs` when `attendedRunsProvider` is empty | [ ] |
| 49 | widget | Shows correct km total and run count for attended runs in the current week | [ ] |
| 50 | widget | Excludes attended runs from previous weeks | [ ] |

---

## 13. Widget — `ReviewsSection`

File: `test/reviews/reviews_section_test.dart`

| # | Type | What to test | Done |
|---|------|-------------|------|
| 51 | widget | "Write a review" CTA is **hidden** when `hasAttended = false` (run context) | [ ] |
| 52 | widget | "Write a review" CTA is **shown** when `hasAttended = true` (run context) | [ ] |
| 53 | widget | "Write a review" CTA is **hidden** when `isMember = false` (club context) | [ ] |
| 54 | widget | "Write a review" CTA is **shown** when `isMember = true` (club context) | [ ] |
| 55 | widget | "Write a review" CTA is **hidden** when `isHost = true` regardless of membership | [ ] |
| 56 | widget | "See all N reviews" link appears when review count > 5 | [ ] |
| 57 | widget | "See all N reviews" link is absent when review count ≤ 5 | [ ] |
| 58 | widget | Tapping "See all" opens a bottom sheet that lists all reviews | [ ] |
| 59 | widget | Review list is capped at 5 previews (6th review not visible in main list) | [ ] |

---

## 14. Widget — `WhoIsRunning`

File: `test/runs/who_is_running_test.dart`

| # | Type | What to test | Done |
|---|------|-------------|------|
| 60 | widget | Shows "No one has booked yet" when `signedUpUserIds` is empty | [ ] |
| 61 | widget | Shows real name from `runnerProfilesProvider` override instead of raw UID | [ ] |
| 62 | widget | Shows `PersonAvatar.count` overflow badge when more than 7 runners signed up | [ ] |

---

## 15. Widget — `SwipeHubScreen`

File: `test/swipes/swipe_hub_screen_test.dart`

| # | Type | What to test | Done |
|---|------|-------------|------|
| 63 | widget | Shows "No runs yet" empty state when `attendedRunsProvider` is empty | [ ] |
| 64 | widget | Shows a run tile for each attended run | [ ] |
| 65 | widget | Tapping a run tile navigates to `SwipeScreen` for that `runId` | [ ] |

---

## 16. Widget — `SwipeScreen`

File: `test/swipes/swipe_screen_test.dart`

| # | Type | What to test | Done |
|---|------|-------------|------|
| 66 | widget | Shows `SwipeEmptyState` when `swipeQueueProvider` returns an empty list | [ ] |
| 67 | widget | Shows the first profile card's name when queue is non-empty | [ ] |
| 68 | widget | Tapping the like button calls `swipeQueueNotifier.swipe(SwipeDirection.like)` | [ ] |
| 69 | widget | Tapping the pass button calls `swipeQueueNotifier.swipe(SwipeDirection.pass)` | [ ] |

---

## 17. Widget — `MatchesListScreen`

File: `test/chats/matches_list_screen_test.dart`

| # | Type | What to test | Done |
|---|------|-------------|------|
| 70 | widget | Shows empty state message when `matchesProvider` returns `[]` | [ ] |
| 71 | widget | Shows a list tile for each match | [ ] |
| 72 | widget | Tapping a match tile navigates to `/chats/:matchId` | [ ] |
| 73 | widget | Unread count badge appears on the nav bar destination when `totalUnreadCountProvider > 0` | [ ] |

---

## 18. Widget — `ChatScreen`

File: `test/chats/chat_screen_test.dart`

| # | Type | What to test | Done |
|---|------|-------------|------|
| 74 | widget | Shows messages from `chatMessagesProvider` in order | [ ] |
| 75 | widget | Own messages appear on the right; other user's on the left | [ ] |
| 76 | widget | Tapping Send with a non-empty message calls `chatRepository.sendMessage` | [ ] |
| 77 | widget | Send button is disabled (or no-op) when the text field is empty | [ ] |

---

## 19. Widget — `PaymentHistoryScreen`

File: `test/payments/payment_history_screen_test.dart`

| # | Type | What to test | Done |
|---|------|-------------|------|
| 78 | widget | Shows "No payments yet." when `paymentsForUserProvider` is empty | [ ] |
| 79 | widget | Shows the run's `title` (from `watchRunProvider` override) instead of "Run booking" | [ ] |
| 80 | widget | Shows the formatted amount (`₹500`) | [ ] |
| 81 | widget | Shows "Paid" status chip for a `completed` payment | [ ] |
| 82 | widget | Shows "Refunded" status chip for a `refunded` payment | [ ] |

---

## 20. Widget — `RunDetailBody`

File: `test/runs/run_detail_body_test.dart`

| # | Type | What to test | Done |
|---|------|-------------|------|
| 83 | widget | Shows run title, distance, and pace tag | [ ] |
| 84 | widget | "Sign Up" CTA is visible for an eligible future free run | [ ] |
| 85 | widget | "Cancel" CTA is visible when the user is already signed up | [ ] |
| 86 | widget | "Join Waitlist" CTA is visible when the run is full and user is eligible | [ ] |
| 87 | widget | "Leave Waitlist" CTA is visible when the user is on the waitlist | [ ] |
| 88 | widget | Shows `ReviewsSection` with `hasAttended = true` when `run.attendedUserIds` contains the current uid | [ ] |

---

## 21. Flow — Run Clubs

File: `test/run_clubs/run_clubs_flow_test.dart` *(existing — extend)*

| # | Type | What to test | Done |
|---|------|-------------|------|
| 89 | flow | Club card tap navigates to detail with correct `runClubId` path param *(existing — passing)* | [x] |
| 90 | flow | Detail screen loads from stream without navigation extra *(existing — passing)* | [x] |
| 91 | flow | Detail screen updates membership button when club stream emits updated `memberUserIds` *(existing — passing)* | [x] |
| 92 | flow | Host sees "Create run" button; non-host does not | [ ] |
| 93 | flow | "Join club" calls `runClubsRepository.joinClub` and button switches to "Leave club" | [ ] |

---

## 22. Flow — Auth redirect

File: `test/routing/auth_redirect_flow_test.dart`

| # | Type | What to test | Done |
|---|------|-------------|------|
| 94 | flow | App starts unauthenticated → lands on onboarding phone auth | [ ] |
| 95 | flow | `uidProvider` emitting a uid with complete profile → redirects to `/` (DashboardScreen) | [ ] |
| 96 | flow | `uidProvider` emitting a uid with `profileComplete = false` → redirects to `/onboarding` | [ ] |

---

## 23. Cloud Function unit tests (TypeScript / Jest)

File: `functions/src/__tests__/signUpUserForRun.test.ts`

| # | Type | What to test | Done |
|---|------|-------------|------|
| 97 | unit | Happy path: user added to `signedUpUserIds`, `genderCounts` incremented | [ ] |
| 98 | unit | Idempotent: calling twice for same user/run does not double-add | [ ] |
| 99 | unit | Throws `failed-precondition` when `signedUpUserIds.length >= capacityLimit` with message "This run is now full." | [ ] |
| 100 | unit | Throws `failed-precondition` when user age < `constraints.minAge` | [ ] |
| 101 | unit | Throws `failed-precondition` when user age > `constraints.maxAge` | [ ] |
| 102 | unit | Throws `failed-precondition` when gender cap is reached for user's gender | [ ] |
| 103 | unit | Throws `not-found` when run document does not exist | [ ] |

File: `functions/src/__tests__/markRunAttendance.test.ts`

| # | Type | What to test | Done |
|---|------|-------------|------|
| 104 | unit | Happy path: `attendedUserIds` set to union of `signedUpUserIds` | [ ] |
| 105 | unit | Throws `permission-denied` when caller is not the club host | [ ] |
| 106 | unit | Throws `failed-precondition` when run `endTime` is in the future | [ ] |
| 107 | unit | Throws `not-found` when run document does not exist | [ ] |

File: `functions/src/__tests__/onSwipeCreated.test.ts`

| # | Type | What to test | Done |
|---|------|-------------|------|
| 108 | unit | Single "like" with no reverse swipe → no match document created | [ ] |
| 109 | unit | Single "pass" → no match document created | [ ] |
| 110 | unit | Mutual "like" → match document created with deterministic sorted ID | [ ] |
| 111 | unit | Mutual "like" called twice → second call is a no-op (idempotent via `create()` ALREADY_EXISTS) | [ ] |
| 112 | unit | Cross-run mutual like (different `runId` on each swipe) → match is still created (intentional MVP behaviour) | [ ] |

---

## Notes

- Items #1–31 and #51–59 have no Firebase dependencies — use plain `dart test` with fake/stub repositories.
- Items #32–37 (router) can be tested with a manually constructed `GoRouter` and a `ProviderContainer` — no widget pump needed.
- Items #38–91 use `testWidgets` + `ProviderScope(overrides: [...])`. Never hit real Firestore.
- Items #97–112 require Jest + `firebase-functions-test` (or a lightweight Firestore emulator mock). Add `jest`, `ts-jest`, and `@firebase/rules-unit-testing` to `functions/package.json` dev deps.
- When a test needs a fake `Run`, copy the `_buildRun()` helper pattern from `run_clubs_flow_test.dart`.
- Existing tests in `test/run_clubs/run_clubs_list_controller_test.dart` reference deleted providers (`selectedRunClubCityProvider`, `runClubsListViewModelProvider`) — fix or delete those before the test suite can pass cleanly.

---

## Session History

| Date | Work done |
|------|-----------|
| 2026-04-22 | Test plan created. 112 items across unit, widget, flow, and CF layers. |
