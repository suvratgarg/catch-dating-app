import {randomUUID} from "node:crypto";
import * as logger from "firebase-functions/logger";
import type {ProgramTravelLegDocument} from
  "../shared/generated/firestoreAdminTypes";
import type {FetchImpl} from "./aeroDataBox";
import {normalizeFlightNumber} from "./flightIdentity";
import {flightRefreshTier, timestampMillis, toTimestamp} from
  "./flightRefreshPolicy";

const subscriptionsEndpoint =
  "https://api.aerodatabox.com/subscriptions/webhook";

/** Public URL the provider pushes to; secret and leg id ride in the query. */
export function flightAlertCallbackUrl(
  baseUrl: string,
  secret: string,
  legId: string,
): string {
  return `${baseUrl}?key=${encodeURIComponent(secret)}` +
    `&leg=${encodeURIComponent(legId)}`;
}

/**
 * Registers a FlightByNumber alert subscription with AeroDataBox.
 * Returns the provider subscription id, or null when the provider
 * declined (duplicate, unsupported subject). Throws on transport errors
 * so the caller can retry on the next sweep.
 */
export async function createFlightSubscription({
  flightNumber,
  callbackUrl,
  apiKey,
  fetchImpl = fetch,
}: {
  flightNumber: string;
  callbackUrl: string;
  apiKey: string;
  fetchImpl?: FetchImpl;
}): Promise<string | null> {
  const response = await fetchImpl(
    `${subscriptionsEndpoint}/FlightByNumber/` +
      `${encodeURIComponent(normalizeFlightNumber(flightNumber))}` +
      "?useCredits=true",
    {
      method: "POST",
      signal: AbortSignal.timeout(15_000),
      headers: {"X-Api-Key": apiKey, "Content-Type": "application/json"},
      body: JSON.stringify({url: callbackUrl, maxDeliveryRetries: 2}),
    },
  );
  if (response.status === 204 || response.status === 404) return null;
  if (response.status === 409) return null;
  if (response.status < 200 || response.status >= 300) {
    throw new Error(
      `AeroDataBox subscription failed with HTTP ${response.status}`);
  }
  const body = await response.json() as {
    id?: unknown;
    subscriptionId?: unknown;
    subscription?: {id?: unknown};
  } | null;
  const id = body?.subscription?.id ?? body?.subscriptionId ?? body?.id;
  return typeof id === "string" && id ? id : null;
}

export async function deleteFlightSubscription({
  subscriptionId,
  apiKey,
  fetchImpl = fetch,
}: {
  subscriptionId: string;
  apiKey: string;
  fetchImpl?: FetchImpl;
}): Promise<void> {
  const response = await fetchImpl(
    `${subscriptionsEndpoint}/${encodeURIComponent(subscriptionId)}`,
    {method: "DELETE", headers: {"X-Api-Key": apiKey},
      signal: AbortSignal.timeout(15_000)},
  );
  // Already gone is success for lifecycle cleanup.
  if (response.status === 404 || response.status === 204) return;
  if (response.status < 200 || response.status >= 300) {
    throw new Error(
      `AeroDataBox unsubscribe failed with HTTP ${response.status}`);
  }
}

interface ProviderSubscription {
  id: string;
  subject: {type: string; id?: string | null};
  subscriber: {type: string; id: string};
  isActive?: boolean;
}

/** Free provider listing recovers a create that succeeded before a timeout. */
export async function listFlightSubscriptions({apiKey, fetchImpl = fetch}: {
  apiKey: string; fetchImpl?: FetchImpl;
}): Promise<ProviderSubscription[]> {
  const response = await fetchImpl(subscriptionsEndpoint, {
    headers: {"X-Api-Key": apiKey}, signal: AbortSignal.timeout(15_000),
  });
  if (response.status < 200 || response.status >= 300) {
    throw new Error(`AeroDataBox subscription list failed: ${response.status}`);
  }
  const body = await response.json();
  if (!Array.isArray(body)) throw new Error("Invalid subscription list.");
  return body as ProviderSubscription[];
}

export interface FlightAlertDeps {
  now: () => Date;
  apiKey: () => string;
  secret: () => string;
  baseUrl: () => string;
  createSubscription: typeof createFlightSubscription;
  deleteSubscription: typeof deleteFlightSubscription;
  listSubscriptions: typeof listFlightSubscriptions;
  fetchImpl?: FetchImpl;
}

const leaseMillis = 5 * 60_000;
const retryMillis = 15 * 60_000;

function wantsAlerts(leg: ProgramTravelLegDocument, now: number): boolean {
  return !!leg.destinationIata && !!leg.scheduledArrivalAt &&
    flightRefreshTier(leg, now) === "hot";
}

function sameCallback(candidate: string, expected: string): boolean {
  try {
    const first = new URL(candidate);
    const second = new URL(expected);
    // Secret rotation must not strand an earlier subscription.
    first.searchParams.delete("key");
    second.searchParams.delete("key");
    return first.toString() === second.toString();
  } catch {
    return false;
  }
}

/** Reconcile durable intent under a lease; provider I/O stays outside it. */
export async function syncLegAlertSubscription(
  ref: FirebaseFirestore.DocumentReference,
  alerts: FlightAlertDeps,
): Promise<void> {
  const now = alerts.now().getTime();
  const token = randomUUID();
  const reserved = await ref.firestore.runTransaction(async (tx) => {
    const leg = (await tx.get(ref)).data() as
      ProgramTravelLegDocument | undefined;
    if (!leg || (timestampMillis(leg.flightAlertLease?.expiresAt) ?? 0) > now) {
      return null;
    }
    const wanted = wantsAlerts(leg, now);
    const number = leg.flightNumber ? normalizeFlightNumber(leg.flightNumber) :
      null;
    const subject = leg.flightAlertFlightNumber ?? null;
    const id = leg.flightAlertSubscriptionId ?? null;
    if (!wanted && !id && !subject) return null;
    const pendingNumber = subject ?? (id ? null : number);
    tx.update(ref, {
      flightAlertFlightNumber: pendingNumber,
      flightAlertLease: {token, expiresAt: toTimestamp(now + leaseMillis)},
      flightNextRefreshAt: toTimestamp(now + leaseMillis),
    });
    return {...leg, flightAlertFlightNumber: pendingNumber};
  });
  if (!reserved) return;

  try {
    const secret = alerts.secret().trim();
    const apiKey = alerts.apiKey().trim();
    if (!secret || !apiKey) {
      throw new Error("Flight provider secrets are missing.");
    }
    const callbackUrl = flightAlertCallbackUrl(
      alerts.baseUrl(), secret, ref.id);
    const subject = reserved.flightAlertFlightNumber;
    const wanted = wantsAlerts(reserved, now) && !!subject &&
      subject === normalizeFlightNumber(reserved.flightNumber ?? "");
    const subscriptions = await alerts.listSubscriptions({
      apiKey, fetchImpl: alerts.fetchImpl,
    });
    const owned = subscriptions.filter((sub) =>
      typeof sub.id === "string" &&
      sub.subject?.type === "FlightByNumber" &&
      typeof sub.subject.id === "string" &&
      normalizeFlightNumber(sub.subject.id) === subject &&
      typeof sub.subscriber?.id === "string" &&
      sameCallback(sub.subscriber.id, callbackUrl));
    const ids = [...new Set([
      ...owned.map((sub) => sub.id),
      ...(reserved.flightAlertSubscriptionId ?
        [reserved.flightAlertSubscriptionId] : []),
    ])].sort();
    // Recover current callbacks; rotate stale keys rather than retaining a
    // subscription whose pushes can no longer authenticate.
    let keep = wanted ? owned.find((sub) =>
      sub.isActive !== false && sub.subscriber.id === callbackUrl)?.id ?? null :
      null;
    if (wanted && !keep) {
      keep = await alerts.createSubscription({flightNumber: subject!,
        callbackUrl, apiKey, fetchImpl: alerts.fetchImpl});
      if (!keep) throw new Error("Provider did not return a subscription id.");
    }
    // Bound external work to fit the lease. Any remainder stays recoverable.
    const remove = ids.filter((id) => id !== keep);
    for (const id of remove.slice(0, 8)) {
      await alerts.deleteSubscription({subscriptionId: id,
        apiKey, fetchImpl: alerts.fetchImpl});
    }
    if (remove.length > 8) throw new Error("Subscription cleanup will resume.");
    await ref.firestore.runTransaction(async (tx) => {
      const current = (await tx.get(ref)).data() as
        ProgramTravelLegDocument | undefined;
      if (!current || current.flightAlertLease?.token !== token) return;
      const stillWanted = wantsAlerts(current, alerts.now().getTime());
      const aligned = !!keep && stillWanted && subject ===
        normalizeFlightNumber(current.flightNumber ?? "");
      tx.update(ref, {
        flightAlertSubscriptionId: keep,
        flightAlertFlightNumber: keep ? subject : null,
        flightAlertLease: null,
        flightNextRefreshAt: toTimestamp(aligned ? now + 10 * 60_000 :
          keep || stillWanted ? now :
            flightRefreshTier(current, now) === "settled" ? null :
              now + retryMillis),
      });
    });
  } catch (error) {
    logger.warn("Flight subscription reconciliation will retry", {
      legId: ref.id,
      error: error instanceof Error ? error.message : String(error),
    });
    await ref.firestore.runTransaction(async (tx) => {
      const current = (await tx.get(ref)).data() as
        ProgramTravelLegDocument | undefined;
      if (current?.flightAlertLease?.token !== token) return;
      // Keep the old id or pending subject: a failed DELETE/POST is uncertain.
      tx.update(ref, {flightAlertLease: {token, expiresAt:
        toTimestamp(alerts.now().getTime() + retryMillis)},
      flightNextRefreshAt: toTimestamp(alerts.now().getTime() + retryMillis)});
    });
  }
}
