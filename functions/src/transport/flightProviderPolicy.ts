import * as admin from "firebase-admin";
import {defineString} from "firebase-functions/params";
import {HttpsError} from "firebase-functions/v2/https";

// Nonsecret rollout intent is deliberately independent from credential storage.
export const flightProviderPolicy = defineString(
  "FLIGHT_PROVIDER_POLICY", {default: ""});

const POLL_SECOND_MILLIS = 1000;
const POLL_DAY_MILLIS = 86_400_000;

export interface FlightProviderPolicy {
  schema: "catch.flight-policy/v1";
  mode: "polling-pilot";
  programIds: string[];
  legIds: string[];
  startsAt: string;
  expiresAt: string;
  maxRequestsPerDay: number;
}

export function readFlightProviderPolicy(raw: string, now: number):
  FlightProviderPolicy | null {
  if (!raw.trim()) return null;
  try {
    const value = JSON.parse(raw) as FlightProviderPolicy;
    if (!value || Object.keys(value).sort().join(",") !==
        "expiresAt,legIds,maxRequestsPerDay,mode,programIds,schema,startsAt" ||
        value.schema !== "catch.flight-policy/v1" ||
        value.mode !== "polling-pilot" ||
        !Array.isArray(value.programIds) || !value.programIds.length ||
        value.programIds.length > 5 ||
        new Set(value.programIds).size !== value.programIds.length ||
        value.programIds.some((id) => typeof id !== "string" ||
          !/^[A-Za-z0-9_-]{1,180}$/u.test(id)) ||
        !Array.isArray(value.legIds) || !value.legIds.length ||
        value.legIds.length > 5 ||
        new Set(value.legIds).size !== value.legIds.length ||
        value.legIds.some((id) => typeof id !== "string" ||
          !/^[A-Za-z0-9_-]{1,180}$/u.test(id)) ||
        !Number.isSafeInteger(value.maxRequestsPerDay) ||
        value.maxRequestsPerDay < 1 || value.maxRequestsPerDay > 100 ||
        typeof value.startsAt !== "string" ||
        typeof value.expiresAt !== "string") return null;
    const start = Date.parse(value.startsAt);
    const end = Date.parse(value.expiresAt);
    if (!Number.isFinite(start) || !Number.isFinite(end) ||
        !Number.isFinite(now) || end <= start || end - start > 86_400_000 ||
        now < start || now >= end) return null;
    return value;
  } catch {
    return null;
  }
}

export function loadFlightProviderPolicy(): FlightProviderPolicy | null {
  return readFlightProviderPolicy(flightProviderPolicy.value(), Date.now());
}

export function pilotAllowsProgram(policy: FlightProviderPolicy,
  programId: string, now: number): boolean {
  return readFlightProviderPolicy(JSON.stringify(policy), now) != null &&
    policy.programIds.includes(programId);
}

/**
 * Shared by scheduler and callable instances in this project. Reserve before
 * every HTTP attempt, including failures; never refund an uncertain request.
 * Counts attempts, not provider API units or account-wide monetary spend.
 */
export async function reserveFlightPoll(
  db: FirebaseFirestore.Firestore,
  policy: FlightProviderPolicy,
  now: number,
): Promise<void> {
  if (!readFlightProviderPolicy(JSON.stringify(policy), now)) {
    throw new HttpsError("failed-precondition", "Flight pilot is inactive.");
  }
  const windows = [
    {action: "flightPollSecond", millis: POLL_SECOND_MILLIS, limit: 1},
    {action: "flightPollDay", millis: POLL_DAY_MILLIS,
      limit: policy.maxRequestsPerDay},
  ].map((window) => ({...window,
    key: Math.floor(now / window.millis)}));
  const refs = windows.map((window) => db.collection("rateLimits")
    .doc(`flight-provider_${window.action}_${window.key}`));
  await db.runTransaction(async (tx) => {
    const snapshots = await tx.getAll(...refs);
    const counts = snapshots.map((snapshot) =>
      snapshot.exists ? snapshot.data()?.count : 0);
    if (counts.some((count, i) => !Number.isSafeInteger(count) || count < 0 ||
        count >= windows[i].limit)) {
      throw new HttpsError("resource-exhausted", "Flight pilot limit reached.");
    }
    windows.forEach((window, i) => tx.set(refs[i], {
      uid: "flight-provider", action: window.action, windowKey: window.key,
      count: counts[i] + 1,
      expiresAt: admin.firestore.Timestamp.fromMillis(
        (window.key + 2) * window.millis),
    }, {merge: true}));
  });
}

/** Recheck expiry and reserved windows immediately before provider I/O. */
export async function runFlightPoll<T>(
  policy: FlightProviderPolicy,
  now: () => number,
  reserve: (now: number) => Promise<void>,
  poll: () => Promise<T>,
): Promise<T> {
  const reservedAt = now();
  await reserve(reservedAt);
  const dispatchAt = now();
  if (!readFlightProviderPolicy(JSON.stringify(policy), dispatchAt)) {
    throw new HttpsError("failed-precondition", "Flight pilot is inactive.");
  }
  if ([POLL_SECOND_MILLIS, POLL_DAY_MILLIS].some((windowMillis) =>
    Math.floor(reservedAt / windowMillis) !==
      Math.floor(dispatchAt / windowMillis))) {
    // Keep the old debit. Retrying here would silently spend another token;
    // dispatching would charge work to a window that no longer applies.
    throw new HttpsError("resource-exhausted",
      "Flight pilot reservation window elapsed.");
  }
  return poll();
}
