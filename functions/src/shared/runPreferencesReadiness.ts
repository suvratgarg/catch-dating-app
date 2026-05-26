import {HttpsError} from "firebase-functions/v2/https";
import {
  EventDocument,
  UserProfileDocument,
} from "./generated/firestoreAdminTypes";
import {runningPreferencesFromUserProfileDoc} from "./profileProjection";

export const currentRunPreferencesVersion = 1;
const defaultPaceMinSecsPerKm = 300;
const defaultPaceMaxSecsPerKm = 420;
type RunningPreferences = ReturnType<
  typeof runningPreferencesFromUserProfileDoc
>;

/**
 * Returns whether an event needs run-domain preferences before signup.
 * @param {EventDocument} event Event document.
 * @return {boolean} Whether run preferences are required.
 */
export function eventRequiresRunPreferences(event: EventDocument): boolean {
  const activityKind = event.eventFormat?.activityKind ?? "socialRun";
  return activityKind === "socialRun" || activityKind === "running";
}

/**
 * Returns whether a profile has completed the current run preference gate.
 * @param {UserProfileDocument} user Private profile document.
 * @return {boolean} Whether current run preferences are complete.
 */
export function hasCurrentRunPreferences(user: UserProfileDocument): boolean {
  const running = runningPreferencesFromUserProfileDoc(user);
  return (
    running.version >= currentRunPreferencesVersion ||
    hasRunPreferenceSelections(running)
  );
}

/**
 * Enforces run preferences only for run-like events.
 * @param {UserProfileDocument} user Private profile document.
 * @param {EventDocument} event Event document.
 */
export function assertRunPreferencesReadyForEvent(
  user: UserProfileDocument,
  event: EventDocument
): void {
  if (!eventRequiresRunPreferences(event)) return;
  if (hasCurrentRunPreferences(user)) return;

  throw new HttpsError(
    "failed-precondition",
    "Add your run preferences before joining this run."
  );
}

/**
 * Treats non-default run values as already answered.
 * @param {RunningPreferences} running Running preferences to inspect.
 * @return {boolean} Whether running preferences contain a meaningful signal.
 */
function hasRunPreferenceSelections(
  running: RunningPreferences
): boolean {
  return Boolean(
    running.preferredDistances.length ||
    running.runningReasons.length ||
    running.preferredRunTimes.length ||
    running.paceMinSecsPerKm !== defaultPaceMinSecsPerKm ||
    running.paceMaxSecsPerKm !== defaultPaceMaxSecsPerKm
  );
}
