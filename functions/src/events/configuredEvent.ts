import {HttpsError} from "firebase-functions/v2/https";
import type {EventDocument} from "../shared/generated/firestoreAdminTypes";

type ScheduledFields = "endTime" | "eventFormat";
type PolicyFields = "capacityLimit" | "priceInPaise";
type VenueFields = "meetingPoint" | "meetingLocation";

export type ScheduledEventDocument = EventDocument &
  Required<Pick<EventDocument, ScheduledFields>>;
export type EventPolicyTermsDocument = EventDocument &
  Required<Pick<EventDocument, PolicyFields>>;
export type RuntimeVenueEventDocument = ScheduledEventDocument &
  Required<Pick<EventDocument, VenueFields>>;

/** Fields that booking and payment require in addition to a valid event doc. */
export type ConfiguredEventDocument = RuntimeVenueEventDocument &
  EventPolicyTermsDocument;

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

export function isScheduledEvent(
  event: EventDocument | null | undefined
): event is ScheduledEventDocument {
  if (!event || typeof event !== "object") return false;
  if (!isFiniteTime(event.startTime) || !isFiniteTime(event.endTime) ||
      event.endTime.toMillis() <= event.startTime.toMillis()) return false;
  const format = event.eventFormat;
  return !!format && Number.isInteger(format.version) &&
    format.version >= 1 && !!format.activityKind &&
    !!format.interactionModel;
}

export function requireScheduledEvent(
  event: EventDocument | null | undefined
): ScheduledEventDocument {
  if (!isScheduledEvent(event)) {
    throw new HttpsError("failed-precondition",
      "This event needs a valid schedule and format.");
  }
  return event;
}

export function isEventPolicyTerms(
  event: EventDocument | null | undefined
): event is EventPolicyTermsDocument {
  return !!event && Number.isInteger(event.capacityLimit) &&
    event.capacityLimit > 0 && Number.isInteger(event.priceInPaise) &&
    event.priceInPaise >= 0;
}

export function requireEventPolicyTerms(
  event: EventDocument | null | undefined
): EventPolicyTermsDocument {
  if (!isEventPolicyTerms(event)) {
    throw new HttpsError("failed-precondition",
      "This event needs capacity and price terms.");
  }
  return event;
}

export function isRuntimeVenueEvent(
  event: EventDocument | null | undefined
): event is RuntimeVenueEventDocument {
  if (!isScheduledEvent(event)) return false;
  if (typeof event.meetingPoint !== "string" ||
      event.meetingPoint.trim().length === 0) return false;
  const location = event.meetingLocation;
  if (!location || typeof location.name !== "string" ||
      !location.name.trim() || !Number.isFinite(location.latitude) ||
      !Number.isFinite(location.longitude) ||
      Math.abs(location.latitude) > 90 ||
      Math.abs(location.longitude) > 180) return false;
  return true;
}

export function requireRuntimeVenueEvent(
  event: EventDocument | null | undefined
): RuntimeVenueEventDocument {
  if (!isRuntimeVenueEvent(event)) {
    throw new HttpsError("failed-precondition",
      "This event needs a valid schedule and venue.");
  }
  return event;
}

/** Completeness is independent of publication and organizer authority. */
export function isConfiguredEvent(
  event: EventDocument | null | undefined
): event is ConfiguredEventDocument {
  return isRuntimeVenueEvent(event) && isEventPolicyTerms(event);
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

/** Public consumer surfaces need publication in addition to completeness. */
export function isPublicConfiguredEvent(
  event: EventDocument | null | undefined
): event is ConfiguredEventDocument {
  if (!isConfiguredEvent(event)) return false;
  const metadata = event as ConfiguredEventDocument & {
    publicationState?: unknown;
    setupRevision?: unknown;
  };
  return Object.prototype.hasOwnProperty.call(metadata, "publicationState") ?
    metadata.publicationState === "published" :
    !Object.prototype.hasOwnProperty.call(metadata, "setupRevision");
}

export function requirePublicConfiguredEvent(
  event: EventDocument | null | undefined
): ConfiguredEventDocument {
  const configured = requireConfiguredEvent(event);
  if (!isPublicConfiguredEvent(configured)) {
    throw new HttpsError("failed-precondition",
      "This event is not open for public booking.");
  }
  return configured;
}
