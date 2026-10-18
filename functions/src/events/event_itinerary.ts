import {HttpsError} from "firebase-functions/v2/https";
import type {EventDocument, EventFormatSnapshot} from
  "../shared/generated/firestoreAdminTypes";
import type {CreateEventCallablePayload} from
  "../shared/generated/createEventCallablePayload";

type EventHostUpdateFields = {
  itinerary?: CreateEventCallablePayload["itinerary"]
};

export function normalizeEventItinerary(
  itinerary: CreateEventCallablePayload["itinerary"] |
    EventHostUpdateFields["itinerary"]
): NonNullable<EventDocument["itinerary"]> {
  return (itinerary ?? []).map((entry) => ({
    id: entry.id.trim(),
    kind: entry.kind,
    offsetMinutes: entry.offsetMinutes,
    durationMinutes: entry.durationMinutes ?? null,
    title: entry.title.trim(),
    description: entry.description?.trim() || null,
    location: entry.location ? {name: entry.location.name.trim(),
      address: entry.location.address?.trim() || null,
      placeId: entry.location.placeId?.trim() || null,
      latitude: entry.location.latitude, longitude: entry.location.longitude,
      notes: entry.location.notes?.trim() || null} : null,
    routeDistanceMeters: entry.routeDistanceMeters ?? null,
  }));
}

export function assertValidEventItinerary(params: {
  itinerary?: CreateEventCallablePayload["itinerary"] |
    EventHostUpdateFields["itinerary"];
  startTimeMillis: number;
  endTimeMillis: number;
  eventFormat?: EventFormatSnapshot | null;
}): void {
  const itinerary = params.itinerary ?? [];
  const eventDurationMinutes = Math.ceil(
    (params.endTimeMillis - params.startTimeMillis) / 60000
  );
  const ids = new Set<string>();
  let previousOffset = -1;
  const routePlan = params.eventFormat?.activityDetails?.routePlan;
  const hasRoutePath = Array.isArray(routePlan?.path) &&
    routePlan.path.length >= 2;
  for (const entry of itinerary) {
    if (ids.has(entry.id)) {
      throw new HttpsError(
        "invalid-argument",
        "Event itinerary ids must be unique."
      );
    }
    ids.add(entry.id);
    if (entry.offsetMinutes < previousOffset) {
      throw new HttpsError(
        "invalid-argument",
        "Event itinerary offsets must be in ascending order."
      );
    }
    if (entry.offsetMinutes > eventDurationMinutes) {
      throw new HttpsError(
        "invalid-argument",
        "Event itinerary entries must fit inside the event window."
      );
    }
    if (entry.routeDistanceMeters != null && !hasRoutePath) {
      throw new HttpsError(
        "invalid-argument",
        "Route distance requires a concrete route path."
      );
    }
    previousOffset = entry.offsetMinutes;
  }
}
