import {HttpsError} from "firebase-functions/v2/https";
import {EventDoc, UserProfileDoc} from "./firestore";

export const currentRunPreferencesVersion = 1;
const defaultPaceMinSecsPerKm = 300;
const defaultPaceMaxSecsPerKm = 420;

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
  return (
    (user.runPreferencesVersion ?? 0) >= currentRunPreferencesVersion ||
    hasLegacyRunPreferenceSelections(user)
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
 * Treats non-default legacy run values as already answered so older users who
 * gave real run preferences do not have to answer the same questions again.
 * @param {UserProfileDoc} user Private profile document.
 * @return {boolean} Whether legacy fields contain a meaningful signal.
 */
function hasLegacyRunPreferenceSelections(user: UserProfileDoc): boolean {
  return Boolean(
    user.preferredDistances?.length ||
    user.runningReasons?.length ||
    user.preferredRunTimes?.length ||
    (typeof user.paceMinSecsPerKm === "number" &&
      user.paceMinSecsPerKm !== defaultPaceMinSecsPerKm) ||
    (typeof user.paceMaxSecsPerKm === "number" &&
      user.paceMaxSecsPerKm !== defaultPaceMaxSecsPerKm)
  );
}
