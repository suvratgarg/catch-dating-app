import {HttpsError} from "firebase-functions/v2/https";
import {EventDoc, UserProfileDoc} from "./generated/firestoreAdminTypes";
import {runningPreferencesFromUserProfileDoc} from "./profileProjection";

export const currentRunPreferencesVersion = 1;
const defaultPaceMinSecsPerKm = 300;
const defaultPaceMaxSecsPerKm = 420;
type RunningPreferences = ReturnType<
  typeof runningPreferencesFromUserProfileDoc
>;

/**
 * Returns whether an event needs run-domain preferences before signup.
 * @param {EventDoc} event Event document.
 * @return {boolean} Whether run preferences are required.
 */
export function eventRequiresRunPreferences(event: EventDoc): boolean {
  const activityKind = event.eventFormat?.activityKind ?? "socialRun";
  return activityKind === "socialRun" || activityKind === "running";
}

/**
 * Returns whether a profile has completed the current run preference gate.
 * @param {UserProfileDoc} user Private profile document.
 * @return {boolean} Whether current run preferences are complete.
 */
export function hasCurrentRunPreferences(user: UserProfileDoc): boolean {
  const running = runningPreferencesFromUserProfileDoc(user);
  return (
    running.version >= currentRunPreferencesVersion ||
    hasRunPreferenceSelections(running)
  );
}

/**
 * Enforces run preferences only for run-like events.
 * @param {UserProfileDoc} user Private profile document.
 * @param {EventDoc} event Event document.
 */
export function assertRunPreferencesReadyForEvent(
  user: UserProfileDoc,
  event: EventDoc
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
