import type {
  AnchorFacts,
  GeoPoint,
  MomentDefinition,
  TravelFacts,
} from "./momentModel";

/**
 * Distance-aware lead times (rollout spec decision 5.2): a `functionGuests`
 * audience flagged `travelTimeLead` shifts each recipient's due earlier by
 * their hotel→function travel estimate, so "leave for the venue" reminders
 * land when that guest actually has to leave.
 *
 * The estimator is a seam: today it is a pure haversine guess at urban
 * coach speed plus a boarding buffer; a cached Routes API provider can
 * replace it through the runner deps without touching the engine.
 */

export type TravelEstimator =
  (origin: GeoPoint, destination: GeoPoint) => number;

const EARTH_RADIUS_KM = 6371;
/** Deliberately conservative city speed — underestimating the lead sends a
 *  departure reminder too late to act on. */
const ASSUMED_SPEED_KM_PER_HOUR = 25;
/** Fixed buffer for boarding, lobby checkout, and curb waits. */
const BOARDING_BUFFER_MINUTES = 10;
const MINUTES_PER_HOUR = 60;

export function haversineTravelMinutes(
  origin: GeoPoint,
  destination: GeoPoint,
): number {
  const toRad = (deg: number) => deg * Math.PI / 180;
  const dLat = toRad(destination.latitude - origin.latitude);
  const dLng = toRad(destination.longitude - origin.longitude);
  const a = Math.sin(dLat / 2) ** 2 +
    Math.cos(toRad(origin.latitude)) * Math.cos(toRad(destination.latitude)) *
      Math.sin(dLng / 2) ** 2;
  const km = 2 * EARTH_RADIUS_KM * Math.asin(Math.min(1, Math.sqrt(a)));
  return Math.ceil(km / ASSUMED_SPEED_KM_PER_HOUR * MINUTES_PER_HOUR) +
    BOARDING_BUFFER_MINUTES;
}

export interface TravelEstimateContext {
  /** Venue pin for the audience's function; null disables all leads. */
  venue: GeoPoint | null;
  facts: TravelFacts;
  estimator: TravelEstimator;
}

/**
 * Builds the dispatch/planning context for a moment, or null when the
 * audience is not a travel-lead `functionGuests` pick on a program scope —
 * in which case the moment behaves exactly like a fixed-offset one.
 */
export function buildTravelContext(
  moment: MomentDefinition,
  facts: AnchorFacts,
  estimator: TravelEstimator,
): TravelEstimateContext | null {
  if (moment.scope.kind !== "program" ||
      moment.audience.kind !== "functionGuests" ||
      moment.audience.travelTimeLead !== true ||
      facts.travel === undefined) {
    return null;
  }
  return {
    venue: facts.functions[moment.audience.functionId]?.venueLocation ?? null,
    facts: facts.travel,
    estimator,
  };
}

/**
 * The run-level lead: the largest hotel→venue estimate across hotel-linked
 * groups. The run wakes this many minutes before the nominal due so the
 * farthest guest is reachable; nearer recipients defer inside dispatch.
 * Zero when the venue has no coordinates or no group carries a hotel.
 */
export function maxTravelLeadMinutes(context: TravelEstimateContext): number {
  if (context.venue === null) return 0;
  let max = 0;
  for (const hotelId of Object.values(context.facts.groupHotelIds)) {
    const hotel = context.facts.hotelLocations[hotelId];
    if (hotel === undefined) continue;
    max = Math.max(max, context.estimator(hotel, context.venue));
  }
  return max;
}

/**
 * One recipient's lead. A guest may sit in several hotel-linked groups;
 * the largest estimate wins so they are never told to leave late. Guests
 * with no hotel link keep the nominal due — there is no honest basis to
 * shift them earlier.
 */
export function guestTravelLeadMinutes(
  groupIds: ReadonlyArray<string>,
  context: TravelEstimateContext,
): number {
  if (context.venue === null) return 0;
  let max = 0;
  for (const groupId of groupIds) {
    const hotelId = context.facts.groupHotelIds[groupId];
    if (hotelId === undefined) continue;
    const hotel = context.facts.hotelLocations[hotelId];
    if (hotel === undefined) continue;
    max = Math.max(max, context.estimator(hotel, context.venue));
  }
  return max;
}
