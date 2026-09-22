import * as admin from "firebase-admin";
import * as logger from "firebase-functions/logger";
import {HttpsError} from "firebase-functions/v2/https";

import type {ProgramTravelLegDocument} from
  "../shared/generated/firestoreAdminTypes";
import {
  fetchFlightStatus,
  FlightStatusSnapshot,
} from "./aeroDataBox";

export type FlightRefreshTier = "hot" | "warm" | "cold" | "settled";

const HOT_WINDOW_MILLIS = 6 * 60 * 60 * 1000;
const WARM_WINDOW_MILLIS = 24 * 60 * 60 * 1000;
const LANDED_GRACE_MILLIS = 4 * 60 * 60 * 1000;
const RETRY_BACKOFF_MILLIS = 15 * 60 * 1000;
const NO_MATCH_BACKOFF_MILLIS = 6 * 60 * 60 * 1000;

const TIER_DELAY_MILLIS: Record<FlightRefreshTier, number | null> = {
  hot: 10 * 60 * 1000,
  warm: 60 * 60 * 1000,
  cold: 12 * 60 * 60 * 1000,
  settled: null,
};

function timestampMillis(
  value: admin.firestore.Timestamp | null | undefined,
): number | null {
  return value ? value.toMillis() : null;
}

function toTimestamp(millis: number | null): admin.firestore.Timestamp | null {
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
    "actualArrivalAt" | "readiness">,
  nowMillis: number,
): FlightRefreshTier {
  if (!leg.flightNumber ||
      ["dispatched", "arrived"].includes(leg.readiness) ||
      leg.actualArrivalAt) {
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
      actualArrivalAt: null, readiness: "expected"},
    now.getTime(),
  );
  const delay = TIER_DELAY_MILLIS[tier];
  return delay == null ? null :
    admin.firestore.Timestamp.fromMillis(now.getTime() + delay);
}

/**
 * Provider write-back rules: enrichment never clears an observed or
 * provider-confirmed landing, terminal statuses only propagate while the leg
 * has not landed, and a snapshot that is not 'landed' cannot regress a leg
 * the provider already landed.
 */
export function applyFlightSnapshot(
  leg: ProgramTravelLegDocument,
  snapshot: FlightStatusSnapshot,
  nowMillis: number,
): Partial<ProgramTravelLegDocument> {
  const patch: Partial<ProgramTravelLegDocument> = {
    flightRefreshedAt: admin.firestore.Timestamp.fromMillis(nowMillis),
  };
  if (snapshot.arrivalTerminal) {
    patch.arrivalTerminal = snapshot.arrivalTerminal;
  }
  if (snapshot.scheduledArrivalMillis != null) {
    patch.scheduledArrivalAt =
      admin.firestore.Timestamp.fromMillis(snapshot.scheduledArrivalMillis);
  }

  const legHasLanded = leg.actualArrivalAt != null;
  if (snapshot.actualArrivalMillis != null) {
    if (!legHasLanded) {
      patch.actualArrivalAt =
        admin.firestore.Timestamp.fromMillis(snapshot.actualArrivalMillis);
    }
    patch.flightStatus = "landed";
  } else if (legHasLanded) {
    // A stale provider response cannot un-land a flight.
    patch.flightStatus = "landed";
  } else if (
    (snapshot.status === "cancelled" || snapshot.status === "diverted") ||
    !(leg.flightStatus === "landed")
  ) {
    patch.flightStatus = snapshot.status;
  }
  if (snapshot.estimatedArrivalMillis != null && !legHasLanded) {
    patch.estimatedArrivalAt =
      admin.firestore.Timestamp.fromMillis(snapshot.estimatedArrivalMillis);
  }
  return patch;
}

export interface FlightRefreshDeps {
  now: () => Date;
  apiKey: () => string;
  fetchStatus: typeof fetchFlightStatus;
  /** Webhook subscription plumbing; omitted in tests and dry contexts. */
  syncAlert?: (
    legRef: FirebaseFirestore.DocumentReference,
    leg: ProgramTravelLegDocument,
    tier: FlightRefreshTier,
    legId: string,
  ) => Promise<void>;
}

export type RefreshOutcome =
  | "updated" | "settled" | "no-match" | "failed";

export async function refreshTravelLeg(
  db: FirebaseFirestore.Firestore,
  legId: string,
  deps: FlightRefreshDeps,
): Promise<RefreshOutcome> {
  const legRef = db.collection("programTravelLegs").doc(legId);
  const legSnap = await legRef.get();
  const leg = legSnap.data() as ProgramTravelLegDocument | undefined;
  if (!leg) return "settled";
  const nowMillis = deps.now().getTime();
  const tier = flightRefreshTier(leg, nowMillis);
  if (tier === "settled") {
    await legRef.update({flightNextRefreshAt: null});
    await deps.syncAlert?.(legRef, leg, "settled", legId);
    return "settled";
  }

  const programSnap = await db.collection("organizerPrograms")
    .doc(leg.programId).get();
  const timezone =
    (programSnap.data() as {timezone?: string} | undefined)?.timezone ??
      "UTC";
  const arrivalMillis = timestampMillis(leg.estimatedArrivalAt) ??
    timestampMillis(leg.scheduledArrivalAt) ?? nowMillis;
  const dateLocal = new Intl.DateTimeFormat("en-CA", {
    timeZone: timezone, year: "numeric", month: "2-digit", day: "2-digit",
  }).format(new Date(arrivalMillis));

  let patch: Partial<ProgramTravelLegDocument>;
  try {
    const snapshot = await deps.fetchStatus({
      flightNumber: leg.flightNumber!,
      dateLocal,
      apiKey: deps.apiKey(),
    });
    if (!snapshot) {
      patch = {flightNextRefreshAt:
        toTimestamp(nowMillis + NO_MATCH_BACKOFF_MILLIS)};
      await legRef.update(patch);
      return "no-match";
    }
    patch = applyFlightSnapshot(leg, snapshot, nowMillis);
  } catch (error) {
    logger.warn("Flight status refresh failed", {
      legId, flightNumber: leg.flightNumber,
      error: error instanceof Error ? error.message : String(error),
    });
    await legRef.update({flightNextRefreshAt:
      toTimestamp(nowMillis + RETRY_BACKOFF_MILLIS)});
    return "failed";
  }

  const nextTier = await writeFlightSnapshot(legRef, leg, patch, nowMillis);
  await deps.syncAlert?.(
    legRef, {...leg, ...patch} as ProgramTravelLegDocument,
    nextTier, legId);
  return "updated";
}

/**
 * Persists a provider-derived patch onto a leg: recomputes the refresh
 * cadence for the merged doc, bumps revision, and stamps the update.
 * Shared by the polling sweep and the webhook receiver so both paths
 * honour the same write-back guards.
 */
export async function writeFlightSnapshot(
  legRef: FirebaseFirestore.DocumentReference,
  leg: ProgramTravelLegDocument,
  patch: Partial<ProgramTravelLegDocument>,
  nowMillis: number,
): Promise<FlightRefreshTier> {
  const nextTier = flightRefreshTier(
    {...leg, ...patch} as ProgramTravelLegDocument, nowMillis);
  const delay = TIER_DELAY_MILLIS[nextTier];
  patch.flightNextRefreshAt =
    delay == null ? null : toTimestamp(nowMillis + delay);
  patch.updatedAt = admin.firestore.Timestamp.fromMillis(nowMillis);
  patch.revision = (leg.revision ?? 0) + 1;
  await legRef.update(patch);
  return nextTier;
}

export async function refreshDueFlightLegs(
  db: FirebaseFirestore.Firestore,
  deps: FlightRefreshDeps,
  limit = 50,
): Promise<{updated: number; skipped: number; failed: number}> {
  const nowMillis = deps.now().getTime();
  const due = await db.collection("programTravelLegs")
    .where("flightNextRefreshAt", "<=",
      admin.firestore.Timestamp.fromMillis(nowMillis))
    .orderBy("flightNextRefreshAt")
    .limit(limit)
    .get();
  let updated = 0;
  let skipped = 0;
  let failed = 0;
  for (const doc of due.docs) {
    const outcome = await refreshTravelLeg(db, doc.id, deps);
    if (outcome === "updated") updated++;
    else if (outcome === "failed") failed++;
    else skipped++;
  }
  return {updated, skipped, failed};
}

export async function refreshTravelLegForRequest(
  db: FirebaseFirestore.Firestore,
  programId: string,
  legId: string,
  deps: FlightRefreshDeps,
): Promise<RefreshOutcome> {
  const legSnap = await db.collection("programTravelLegs").doc(legId).get();
  const leg = legSnap.data() as ProgramTravelLegDocument | undefined;
  if (!leg || leg.programId !== programId) {
    throw new HttpsError("not-found", "Leg not found in this program.");
  }
  return refreshTravelLeg(db, legId, deps);
}
