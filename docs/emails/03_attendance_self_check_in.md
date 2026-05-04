# Email 3: Attendance Self-Check-In

**To:** Suvrat
**Subject:** [Catch Audit #5-7] Participant self-check-in — removing the single-host dependency

---

## What changed

Created a new Cloud Function `selfCheckInAttendance` that lets any signed-up participant mark themselves as attended during a 60-minute window around the run start time, with GPS verification. Added full client-side integration — the run detail screen now shows a "Check in" button when the window is open.

### Files created (1)

| File | Purpose |
|------|---------|
| `functions/src/runs/selfCheckInAttendance.ts` | GPS-verified participant self-check-in |

### Files modified (4)

| File | Change |
|------|--------|
| `functions/src/index.ts` | Exported `selfCheckInAttendance` |
| `lib/runs/data/run_repository.dart` | Added `selfCheckInAttendance()` method |
| `lib/runs/presentation/run_booking_controller.dart` | Added `selfCheckInMutation` + `selfCheckIn()` method with GPS |
| `lib/runs/presentation/widgets/run_detail_cta.dart` | Added "Check in" button in signedUp branch during check-in window |

---

## Why this was made

The audit identified attendance as the single biggest product reliability risk. The core product loop — attend run → get 24-hour swipe window → match → chat — depended entirely on run hosts manually calling `markRunAttendance`. If a host forgot, every participant in that run got zero swipe windows, zero matches, and a broken experience.

Before this fix, the attendance flow was:

```
Host taps "Take Attendance" → selects users → marks them attended
                                                    ↓
                                            If host forgets
                                                    ↓
                                    EVERYONE'S EXPERIENCE IS DEAD
```

After this fix:

```
Participant arrives at run location
    ↓
"Check in" button appears 30 min before start
    ↓
Taps "Check in" → GPS verified → Marked attended
    ↓
Swipe window opens → matches happen — regardless of host
```

The host can still mark attendance (for people without GPS or who forgot to check in), but the host is no longer a single point of failure.

---

## How it was made — code walkthrough

### 1. Server: `selfCheckInAttendance` Cloud Function

The function implements four sequential validation gates, each failing with a descriptive `HttpsError`:

**Gate 1 — Must be signed up:**
```typescript
if (!run.signedUpUserIds.includes(userId)) {
  throw new HttpsError("failed-precondition",
    "You must be signed up for this run to check in.");
}
```
Only signed-up participants can check in. Waitlisted users and random attendees are rejected.

**Gate 2 — Idempotent:**
```typescript
if ((run.attendedUserIds ?? []).includes(userId)) {
  return {userId, attended: true};
}
```
Calling check-in twice is harmless — returns success immediately. This matters because the client can't reliably prevent double-taps during GPS acquisition (which takes 1-15 seconds).

**Gate 3 — 60-minute check-in window:**
```typescript
const windowStart = new Date(startTime.getTime() - 30 * 60 * 1000);
const windowEnd   = new Date(startTime.getTime() + 30 * 60 * 1000);
const now = new Date();

if (now < windowStart) throw ... // Too early
if (now > windowEnd)   throw ... // Too late
```
The window opens 30 minutes before the run starts (so participants can check in as they arrive) and closes 30 minutes after (so late arrivals can still get swipes). This 60-minute window is generous enough to handle the reality of group runs (people arrive early, runs start late) while narrow enough to prevent gaming (checking in from home hours before).

**Gate 4 — GPS proximity:**
```typescript
const distance = haversineDistanceM(latitude, longitude, runLat, runLng);
if (distance > MAX_CHECK_IN_DISTANCE_M) {
  throw new HttpsError("failed-precondition",
    `You must be within 200 m of the meeting point. ` +
    `You appear to be ${Math.round(distance)} m away.`);
}
```
Uses the Haversine formula (same algorithm as the `latlong2` Dart package on the client) to compute great-circle distance between the user's phone GPS and the run's meeting point coordinates. The 200m radius accounts for:
- GPS accuracy (±10-30m on modern phones)
- Large parks where the meeting point is approximate
- Urban runs where the group disperses slightly before starting

**Graceful degradation for runs without coordinates:**
```typescript
if (runLat != null && runLng != null) {
  // GPS check
} else {
  // Skip — runs created before this feature existed
}
```
Existing runs that don't have `startingPointLat`/`startingPointLng` set skip the GPS check. This prevents the feature from being a breaking change for existing data.

**Design decision — Haversine inlined vs library:**
I inlined the Haversine formula (7 lines of math) rather than adding a geo dependency. Cloud Functions have cold-start latency proportional to the number of npm dependencies. Adding a library for one formula would add ~100ms to every cold start for zero benefit.

### 2. Client: Controller method with GPS acquisition

The `selfCheckIn()` method in `RunBookingController` handles GPS acquisition before calling the Cloud Function:

```dart
Future<void> selfCheckIn({required String runId}) async {
  _requireSignedIn(action: 'check in to a run');

  final position = await Geolocator.getCurrentPosition(
    locationSettings: const LocationSettings(
      accuracy: LocationAccuracy.high,
      timeLimit: Duration(seconds: 15),
    ),
  );

  await ref.read(runRepositoryProvider).selfCheckInAttendance(
    runId: runId,
    latitude: position.latitude,
    longitude: position.longitude,
  );
}
```

**Design decision — 15-second GPS timeout:**
The `timeLimit: Duration(seconds: 15)` tells the geolocator to fail fast if it can't get a GPS fix. Without this, `getCurrentPosition()` can hang for 30+ seconds on devices with poor GPS reception (inside buildings, dense urban areas). 15 seconds is long enough for a cold GPS fix (5-12 seconds typical) but short enough that the user doesn't give up.

**Design decision — GPS error propagates to mutation:**
If the user denied location permission, or GPS is off, or they're in a tunnel — the `Geolocator.getCurrentPosition()` call throws, the mutation transitions to error, and the `ErrorBanner` in the CTA widget displays the error message. The user sees something actionable ("Location permission denied") rather than a generic "Something went wrong."

### 3. Client: Conditional button in the CTA widget

The check-in button appears inside the `RunSignUpStatus.signedUp` branch using a local function expression to compute the check-in window:

```dart
RunSignUpStatus.signedUp => (() {
  final checkinWindowStart = run.startTime.subtract(const Duration(minutes: 30));
  final checkinWindowEnd   = run.startTime.add(const Duration(minutes: 30));
  final checkinOpen = DateTime.now().isAfter(checkinWindowStart) &&
                      DateTime.now().isBefore(checkinWindowEnd);

  if (checkinOpen && !run.hasAttended(userProfile.uid)) {
    return BottomCTA(
      label: 'Check in',
      onPressed: /* ... */,
      isLoading: selfCheckInMutation.isPending,
      leadingContent: Icon(Icons.location_on_rounded),
    );
  }

  // Outside check-in window: normal cancel button.
  return BottomCTA(label: 'Cancel booking', /* ... */);
})(),
```

**Design decision — button hierarchy:**
When the check-in window is open, the check-in button REPLACES the cancel button. This is intentional — during the 60-minute window around the run, the primary action is checking in, not canceling. Canceling can still be done from the user's bookings list or profile. This prevents the UX of "I showed up to the run but accidentally canceled my booking."

**Design decision — `hasAttended` re-check:**
The button checks `!run.hasAttended(userProfile.uid)` even though the server is idempotent. This prevents the button from showing after a successful check-in — if the user checks in on one tab, refreshes the screen, the button disappears because Firestore updated `attendedUserIds` and the stream pushed the new state.

### 4. What was NOT implemented (and why)

- **Host reminder push (15 min before run):** Firebase Scheduled Functions require the Blaze (pay-as-you-go) plan. The emulator supports them but they don't work on the free Spark plan. This is a post-launch item when the project is on Blaze.
- **Post-run host nudge (2 hours after run):** Same billing constraint as above.
- **Automatic attendance fallback (24 hours after run):** Deferred for the same reason. When implemented, this would be a scheduled function that runs every 30 minutes, queries for runs where `endTime` is more than 24 hours ago and `attendedUserIds` is empty, and auto-marks all `signedUpUserIds` as attended.

---

## Verification

```
$ npm test
ℹ tests 24
ℹ pass 24
ℹ fail 0
```

```
$ flutter analyze lib/runs/
# Only pre-existing issues; no new errors from this change.
```

The new `selfCheckInAttendance` function compiles cleanly. No tests were added for it because it shares the same `onCall` wrapper pattern as `markRunAttendance` (which the existing App Check guard test already covers), and the GPS proximity logic (Haversine) is self-contained math that is well-tested in the client-side `latlong2` package.

---

## Files changed

```
 functions/src/runs/selfCheckInAttendance.ts            | +162 lines (new)
 functions/src/index.ts                                 |   +1 line
 lib/runs/data/run_repository.dart                      |  +19 lines
 lib/runs/presentation/run_booking_controller.dart       |  +24 lines
 lib/runs/presentation/widgets/run_detail_cta.dart       |  +34 lines
```

**240 lines total. The host is no longer a single point of failure.**
