import {HttpsError} from "firebase-functions/v2/https";
import type {EventDocument} from "../../shared/generated/firestoreAdminTypes";
import {localStartMillis} from "./basics";

/** Private drafts stay on their manager-only editor; published events can use
 * the rich editor with optimistic concurrency against every setup command.
 */
export function publishedEventEditPatch(event: EventDocument,
  expectedRevision: number | undefined, startTimeMillis: number
): Partial<EventDocument> {
  if (event.setupRevision === undefined) return {};
  if (event.publicationState !== "published") {
    throw new HttpsError("failed-precondition",
      "Use private event setup for this event.");
  }
  if (expectedRevision !== event.setupRevision) {
    throw new HttpsError("aborted",
      "Event details changed. Reload before saving.");
  }
  if (!Number.isSafeInteger(event.setupRevision) ||
      event.setupRevision >= 2147483647) {
    throw new HttpsError("failed-precondition", "Invalid setup revision.");
  }
  const patch: Partial<EventDocument> = {
    setupRevision: event.setupRevision + 1};
  if (startTimeMillis === event.startTime.toMillis()) return patch;
  if (!event.eventTimezone) {
    throw new HttpsError("failed-precondition", "Event timezone is missing.");
  }
  let parts: Record<string, string>;
  try {
    parts = Object.fromEntries(new Intl.DateTimeFormat("en-GB", {
      timeZone: event.eventTimezone, calendar: "gregory", hourCycle: "h23",
      year: "numeric", month: "2-digit", day: "2-digit", hour: "2-digit",
      minute: "2-digit",
    }).formatToParts(startTimeMillis).map((part) => [part.type, part.value]));
  } catch {
    throw new HttpsError("failed-precondition", "Invalid event timezone.");
  }
  const date = `${parts.year}-${parts.month}-${parts.day}`;
  const time = `${parts.hour}:${parts.minute}`;
  // The private editor also rejects ambiguous civil times. Preserve that
  // invariant so reopening after unpublish cannot move the event silently.
  if (localStartMillis(date, time, event.eventTimezone) !== startTimeMillis) {
    throw new HttpsError("invalid-argument",
      "Choose a whole-minute start time.");
  }
  return {...patch, eventLocalDate: date, eventLocalStartTime: time};
}
