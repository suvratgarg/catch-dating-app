import {HttpsError} from "firebase-functions/v2/https";
import type {EventDocument} from "../shared/generated/firestoreAdminTypes";
import {isEventPubliclyAccessible} from "./eventPublicationAccess";

type TimedFields = "endTime";
type ScheduledFields = "eventFormat";
type PolicyFields = "capacityLimit" | "priceInPaise";
type VenueFields = "meetingPoint" | "meetingLocation";

export type TimedEventDocument = EventDocument &
  Required<Pick<EventDocument, TimedFields>>;
export type ScheduledEventDocument = TimedEventDocument &
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

export function isEventTimeRange(
  event: EventDocument | null | undefined
): event is TimedEventDocument {
  if (!event || typeof event !== "object") return false;
  return isFiniteTime(event.startTime) && isFiniteTime(event.endTime) &&
    event.endTime.toMillis() > event.startTime.toMillis();
}

export function requireEventTimeRange(
  event: EventDocument | null | undefined
): TimedEventDocument {
  if (!isEventTimeRange(event)) {
    throw new HttpsError("failed-precondition",
      "This event needs a valid time range.");
  }
  return event;
}

export function isScheduledEvent(
  event: EventDocument | null | undefined
): event is ScheduledEventDocument {
  if (!isEventTimeRange(event)) return false;
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
  if (!event) return false;
  const {capacityLimit, priceInPaise} = event;
  return typeof capacityLimit === "number" &&
    Number.isInteger(capacityLimit) && capacityLimit > 0 &&
    typeof priceInPaise === "number" &&
    Number.isInteger(priceInPaise) && priceInPaise >= 0;
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
  return isConfiguredEvent(event) && isEventPubliclyAccessible(event);
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
