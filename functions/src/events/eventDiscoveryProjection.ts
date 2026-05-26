import {EventDocument} from "../shared/generated/firestoreAdminTypes";
import {
  cohortIds,
  EventCohortId,
  EventPolicyBundleDocument,
  EventRosterSnapshot,
  eventPolicyFromEvent,
  rosterFromEvent,
} from "./eventPolicy";

export const eventDiscoveryGeoCellSizeDegrees = 0.08;

type DiscoveryAvailability = "open" | "waitlist" | "gated" | "full" |
  "cancelled";

type EventDiscoveryProjectionInput = {
  event: EventDocument;
  clubLocation?: string | null;
  bookedCount?: number;
};

const discoveryCohortIds = Object.values(cohortIds) as EventCohortId[];

/**
 * Builds the callable-owned fields that let Explore query events directly.
 * @param {EventDiscoveryProjectionInput} input Event plus club city context.
 * @return {Partial<EventDocument>} Projection fields for events/{eventId}.
 */
export function eventDiscoveryProjection(
  input: EventDiscoveryProjectionInput
): Partial<EventDocument> {
  const event = input.event;
  const policy = eventPolicyFromEvent(event);
  const bookedCount = Math.max(0, Math.trunc(
    input.bookedCount ?? event.bookedCount ?? 0
  ));
  const projectedEvent = {...event, bookedCount};
  const roster = rosterFromEvent(projectedEvent);
  const isCancelled = event.status === "cancelled";
  const hasOpenSpots =
    !isCancelled && bookedCount < policy.admission.capacityLimit;
  const waitlistOpen =
    policy.admission.waitlistPolicy?.mode !== "disabled";
  const gated =
    policy.admission.inviteRequired === true ||
    policy.admission.membershipRequired === true ||
    policy.admission.manualApprovalRequired === true ||
    policy.admission.format === "inviteOnly" ||
    policy.admission.format === "membersOnly" ||
    policy.admission.format === "manualApproval";
  const availability: DiscoveryAvailability = isCancelled ?
    "cancelled" :
    gated ?
      "gated" :
      hasOpenSpots ?
        "open" :
        waitlistOpen ?
          "waitlist" :
          "full";
  const latitude = coordinateOrNull(
    event.startingPointLat ?? event.meetingLocation?.latitude
  );
  const longitude = coordinateOrNull(
    event.startingPointLng ?? event.meetingLocation?.longitude
  );
  const cohortProjection = discoveryCohortProjection({
    policy,
    roster,
    gated,
    isCancelled,
  });

  return {
    discoveryCityName: normalizeDiscoveryCityName(input.clubLocation),
    discoveryActivityKind:
      event.eventFormat?.activityKind ?? "socialRun",
    discoveryGeoCell: latitude == null || longitude == null ?
      null :
      discoveryGeoCellFor(latitude, longitude),
    discoveryHasOpenSpots: hasOpenSpots,
    discoveryAvailability: availability,
    discoveryOpenCohorts: cohortProjection.open,
    discoveryWaitlistCohorts: cohortProjection.waitlist,
    discoveryInviteRequired:
      policy.admission.inviteRequired === true ||
      policy.admission.format === "inviteOnly",
    discoveryMembershipRequired:
      policy.admission.membershipRequired === true ||
      policy.admission.format === "membersOnly",
    discoveryManualApprovalRequired:
      policy.admission.manualApprovalRequired === true ||
      policy.admission.format === "manualApproval",
    discoveryMinAge: event.constraints?.minAge ?? 0,
    discoveryMaxAge: event.constraints?.maxAge ?? 99,
  };
}

/**
 * Normalizes a club city/location slug for event discovery indexes.
 * @param {string|null|undefined} value Raw club location.
 * @return {string} Lowercase city slug.
 */
export function normalizeDiscoveryCityName(
  value: string | null | undefined
): string | null {
  const normalized = (value ?? "").trim().toLowerCase();
  return normalized.length > 0 ? normalized : null;
}

/**
 * Returns the coarse geo-cell key used by event discovery queries.
 * @param {number} latitude Latitude.
 * @param {number} longitude Longitude.
 * @return {string} Stable cell key.
 */
export function discoveryGeoCellFor(
  latitude: number,
  longitude: number
): string {
  const latBucket = Math.floor(latitude / eventDiscoveryGeoCellSizeDegrees);
  const lngBucket = Math.floor(longitude / eventDiscoveryGeoCellSizeDegrees);
  return `${latBucket}:${lngBucket}`;
}

/**
 * Normalizes optional coordinate inputs from legacy and meeting-location docs.
 * @param {unknown} value Candidate coordinate.
 * @return {number|null} Finite coordinate or null.
 */
function coordinateOrNull(value: unknown): number | null {
  return typeof value === "number" && Number.isFinite(value) ? value : null;
}

/**
 * Computes coarse cohort buckets for Firestore event discovery indexes.
 * @param {{policy: EventPolicyBundleDocument, roster: EventRosterSnapshot,
 * gated: boolean, isCancelled: boolean}} params Projection inputs.
 * @return {{open: EventCohortId[], waitlist: EventCohortId[]}} Cohort buckets.
 */
function discoveryCohortProjection(params: {
  policy: EventPolicyBundleDocument;
  roster: EventRosterSnapshot;
  gated: boolean;
  isCancelled: boolean;
}): {open: EventCohortId[]; waitlist: EventCohortId[]} {
  if (params.isCancelled || params.gated) {
    return {open: [], waitlist: []};
  }
  const open: EventCohortId[] = [];
  const waitlist: EventCohortId[] = [];
  for (const cohortId of discoveryCohortIds) {
    const availability = cohortDiscoveryAvailability({
      policy: params.policy,
      roster: params.roster,
      cohortId,
    });
    if (availability === "open") open.push(cohortId);
    if (availability === "waitlist") waitlist.push(cohortId);
  }
  return {open, waitlist};
}

/**
 * Resolves indexable slot state for a single standard event cohort.
 * @param {{policy: EventPolicyBundleDocument, roster: EventRosterSnapshot,
 * cohortId: string}} params Policy, roster, and cohort id.
 * @return {"open"|"waitlist"|null} Coarse discovery availability.
 */
function cohortDiscoveryAvailability(params: {
  policy: EventPolicyBundleDocument;
  roster: EventRosterSnapshot;
  cohortId: string;
}): "open" | "waitlist" | null {
  const admission = params.policy.admission;
  if (params.roster.totalBooked >= admission.capacityLimit) {
    return waitlistAvailability(admission);
  }

  const cohortLimit = admission.cohortCapacityLimits?.[params.cohortId];
  if (cohortLimit != null &&
      (params.roster.bookedCountsByCohort[params.cohortId] ?? 0) >=
        cohortLimit) {
    return waitlistAvailability(admission);
  }

  const ratio = admission.balancedRatioPolicy;
  if (admission.format !== "balancedRatio" || !ratio) return "open";

  const applies = params.cohortId === ratio.leftCohortId ||
    params.cohortId === ratio.rightCohortId;
  if (!applies) {
    switch (ratio.outOfRatioCohortPolicy) {
    case "admitWithinGeneralCapacity":
      return "open";
    case "waitlist":
      return waitlistAvailability(admission);
    case "manualReview":
    case "reject":
      return null;
    }
  }

  const counterpartId = params.cohortId === ratio.leftCohortId ?
    ratio.rightCohortId :
    ratio.leftCohortId;
  const currentCount =
    params.roster.bookedCountsByCohort[params.cohortId] ?? 0;
  const counterpartCount =
    params.roster.bookedCountsByCohort[counterpartId] ?? 0;
  const nextCount = currentCount + 1;
  if (counterpartCount === 0 &&
      currentCount < ratio.openingBufferPerCohort) {
    return "open";
  }
  if (nextCount <= counterpartCount + ratio.maxSkew) return "open";
  return waitlistAvailability(admission);
}

/**
 * Returns the waitlist bucket only when the event has an enabled waitlist.
 * @param {object} admission Admission policy.
 * @return {string|null} Waitlist availability.
 */
function waitlistAvailability(
  admission: EventPolicyBundleDocument["admission"]
): "waitlist" | null {
  return admission.waitlistPolicy?.mode !== "disabled" ? "waitlist" : null;
}
