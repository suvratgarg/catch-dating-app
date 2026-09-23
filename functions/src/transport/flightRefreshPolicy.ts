import * as admin from "firebase-admin";
import type {ProgramTravelLegDocument} from
  "../shared/generated/firestoreAdminTypes";

export type FlightRefreshTier = "hot" | "warm" | "cold" | "settled";

const HOT_WINDOW_MILLIS = 6 * 60 * 60 * 1000;
const WARM_WINDOW_MILLIS = 24 * 60 * 60 * 1000;
const LANDED_GRACE_MILLIS = 4 * 60 * 60 * 1000;

export const TIER_DELAY_MILLIS: Record<FlightRefreshTier, number | null> = {
  hot: 10 * 60 * 1000,
  warm: 60 * 60 * 1000,
  cold: 12 * 60 * 60 * 1000,
  settled: null,
};

export function timestampMillis(
  value: admin.firestore.Timestamp | null | undefined,
): number | null {
  return value ? value.toMillis() : null;
}

export function toTimestamp(millis: number | null):
  admin.firestore.Timestamp | null {
  return millis == null ? null :
    admin.firestore.Timestamp.fromMillis(millis);
}

/**
 * Refresh cadence keyed to arrival proximity, not a fixed interval: legs far
 * out cost ~2 calls/day, the ~6h pre-landing window polls every 10 minutes,
 * and legs with an observed or provider-confirmed arrival stop entirely.
 */
export function flightRefreshTier(
  leg: Pick<ProgramTravelLegDocument,
    "flightNumber" | "scheduledArrivalAt" | "estimatedArrivalAt" |
    "actualArrivalAt" | "readiness" | "flightStatus">,
  nowMillis: number,
): FlightRefreshTier {
  if (!leg.flightNumber ||
      ["dispatched", "arrived"].includes(leg.readiness) ||
      leg.actualArrivalAt || leg.flightStatus === "landed") {
    return "settled";
  }
  const arrivalMillis = timestampMillis(leg.estimatedArrivalAt) ??
    timestampMillis(leg.scheduledArrivalAt);
  if (arrivalMillis == null) return "cold";
  const delta = arrivalMillis - nowMillis;
  if (delta <= HOT_WINDOW_MILLIS && delta >= -LANDED_GRACE_MILLIS) {
    return "hot";
  }
  if (delta < -LANDED_GRACE_MILLIS) return "cold";
  return delta <= WARM_WINDOW_MILLIS ? "warm" : "cold";
}

export function nextFlightRefreshAt(
  flightNumber: string | null,
  scheduledArrivalAt: admin.firestore.Timestamp | null,
  now: Date,
): admin.firestore.Timestamp | null {
  const tier = flightRefreshTier(
    {flightNumber, scheduledArrivalAt, estimatedArrivalAt: null,
      actualArrivalAt: null, readiness: "expected", flightStatus: "scheduled"},
    now.getTime(),
  );
  const delay = TIER_DELAY_MILLIS[tier];
  return delay == null ? null :
    admin.firestore.Timestamp.fromMillis(now.getTime() + delay);
}

