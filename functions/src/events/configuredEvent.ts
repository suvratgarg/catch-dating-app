import {HttpsError} from "firebase-functions/v2/https";
import type {EventDocument} from "../shared/generated/firestoreAdminTypes";

type ConfiguredFields = "endTime" | "meetingPoint" | "meetingLocation" |
  "eventFormat" | "capacityLimit" | "priceInPaise";

/** Fields that booking and payment require in addition to a valid event doc. */
export type ConfiguredEventDocument = EventDocument &
  Required<Pick<EventDocument, ConfiguredFields>>;

function isFiniteTime(value: unknown): value is FirebaseFirestore.Timestamp {
  if (value === null || typeof value !== "object" ||
      typeof (value as {toMillis?: unknown}).toMillis !== "function") {
    return false;
  }
  try {
    return Number.isFinite((value as FirebaseFirestore.Timestamp).toMillis());
  } catch {
    return false;
  }
}

/** Legacy events need rich data; progressive events must also be published. */
export function isConfiguredEvent(
  event: EventDocument | null | undefined
): event is ConfiguredEventDocument {
  if (!event || typeof event !== "object") return false;
  const metadata = event as EventDocument & {
    publicationState?: unknown;
    setupRevision?: unknown;
  };
  if (Object.prototype.hasOwnProperty.call(metadata, "publicationState") ?
    metadata.publicationState !== "published" :
    Object.prototype.hasOwnProperty.call(metadata, "setupRevision")) {
    return false;
  }
  if (!isFiniteTime(event.startTime) || !isFiniteTime(event.endTime) ||
      event.endTime.toMillis() <= event.startTime.toMillis()) return false;
  if (typeof event.meetingPoint !== "string" ||
      event.meetingPoint.trim().length === 0) return false;
  const location = event.meetingLocation;
  if (!location || typeof location.name !== "string" ||
      !location.name.trim() || !Number.isFinite(location.latitude) ||
      !Number.isFinite(location.longitude) ||
      Math.abs(location.latitude) > 90 ||
      Math.abs(location.longitude) > 180) return false;
  const format = event.eventFormat;
  if (!format || !Number.isInteger(format.version) ||
      format.version < 1 || !format.activityKind ||
      !format.interactionModel) return false;
  return Number.isInteger(event.capacityLimit) &&
    event.capacityLimit > 0 && Number.isInteger(event.priceInPaise) &&
    event.priceInPaise >= 0;
}

export function requireConfiguredEvent(
  event: EventDocument | null | undefined
): ConfiguredEventDocument {
  if (!isConfiguredEvent(event)) {
    throw new HttpsError("failed-precondition",
      "This event is not ready for booking.");
  }
  return event;
}
