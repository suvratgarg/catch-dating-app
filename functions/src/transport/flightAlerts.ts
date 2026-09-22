import * as admin from "firebase-admin";
import * as logger from "firebase-functions/logger";
import {onRequest} from "firebase-functions/v2/https";
import {defineSecret, defineString} from "firebase-functions/params";

import type {ProgramTravelLegDocument} from
  "../shared/generated/firestoreAdminTypes";
import {
  aeroDataBoxApiKey,
  aeroFlightNumber,
  FetchImpl,
  FlightStatusSnapshot,
  normalizeAeroFlight,
  normalizeFlightNumber,
} from "./aeroDataBox";
import {
  applyFlightSnapshot,
  FlightRefreshTier,
  writeFlightSnapshot,
} from "./flightRefresh";

export const flightWebhookSecret = defineSecret("FLIGHT_WEBHOOK_SECRET");
export const flightWebhookBaseUrl =
  defineString("FLIGHT_WEBHOOK_BASE_URL");

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

export function defaultAlertBaseUrl(): string {
  const configured = flightWebhookBaseUrl.value().trim();
  if (configured) return configured.replace(/\/$/, "");
  const project = process.env.GCLOUD_PROJECT;
  if (!project) {
    throw new Error(
      "FLIGHT_WEBHOOK_BASE_URL is unset and GCLOUD_PROJECT is unavailable.");
  }
  return `https://asia-south1-${project}.cloudfunctions.net/` +
    "flightAlertWebhook";
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
    {method: "DELETE", headers: {"X-Api-Key": apiKey}},
  );
  // Already gone is success for lifecycle cleanup.
  if (response.status === 404 || response.status === 204) return;
  if (response.status < 200 || response.status >= 300) {
    throw new Error(
      `AeroDataBox unsubscribe failed with HTTP ${response.status}`);
  }
}

/** Injectable webhook plumbing so tests never touch the provider. */
export interface FlightAlertDeps {
  apiKey: () => string;
  secret: () => string;
  baseUrl: () => string;
  createSubscription: typeof createFlightSubscription;
  deleteSubscription: typeof deleteFlightSubscription;
  fetchImpl?: FetchImpl;
}

/**
 * Keeps one provider subscription aligned with a leg's refresh tier:
 * hot legs get pushes, settled legs release theirs. Runs inside the
 * polling sweep so it needs no extra indexes; provider failures are
 * logged and left for the next pass.
 */
export async function syncLegAlertSubscription(
  legRef: FirebaseFirestore.DocumentReference,
  leg: ProgramTravelLegDocument,
  tier: FlightRefreshTier,
  legId: string,
  alerts: FlightAlertDeps,
): Promise<void> {
  const existing = leg.flightAlertSubscriptionId ?? null;
  if (tier === "hot" && !existing && leg.flightNumber) {
    try {
      const id = await alerts.createSubscription({
        flightNumber: leg.flightNumber,
        callbackUrl: flightAlertCallbackUrl(
          alerts.baseUrl(), alerts.secret(), legId),
        apiKey: alerts.apiKey(),
        fetchImpl: alerts.fetchImpl,
      });
      if (id) await legRef.update({flightAlertSubscriptionId: id});
    } catch (error) {
      logger.warn("Flight alert subscribe failed", {
        legId,
        error: error instanceof Error ? error.message : String(error),
      });
    }
    return;
  }
  if (tier === "settled" && existing) {
    try {
      await alerts.deleteSubscription({
        subscriptionId: existing,
        apiKey: alerts.apiKey(),
        fetchImpl: alerts.fetchImpl,
      });
    } catch (error) {
      logger.warn("Flight alert unsubscribe failed", {
        legId, subscriptionId: existing,
        error: error instanceof Error ? error.message : String(error),
      });
    }
    // Clear regardless: stale pushes re-apply through the same guards.
    await legRef.update({flightAlertSubscriptionId: null});
  }
}

interface PushedFlight {
  snapshot: FlightStatusSnapshot;
  flightNumber: string | null;
}

/**
 * Extracts the flight records from an AeroDataBox push. The documented
 * FlightNotificationContract wraps flights, but older and marketplace
 * payloads have shipped as a bare flight or array — accept all three.
 */
export function pushedFlights(body: unknown): PushedFlight[] {
  const candidates: unknown[] = [];
  if (Array.isArray(body)) {
    candidates.push(...body);
  } else if (body && typeof body === "object") {
    const record = body as {
      flights?: unknown;
      flight?: unknown;
      arrival?: unknown;
      departure?: unknown;
      number?: unknown;
      status?: unknown;
    };
    if (Array.isArray(record.flights)) {
      candidates.push(...record.flights);
    } else if (record.flight) {
      candidates.push(record.flight);
    } else if (
      record.arrival != null || record.departure != null ||
      record.number != null || record.status != null
    ) {
      candidates.push(body);
    }
  }
  const parsed: PushedFlight[] = [];
  for (const candidate of candidates) {
    const snapshot = normalizeAeroFlight(
      candidate as Parameters<typeof normalizeAeroFlight>[0]);
    if (snapshot) {
      parsed.push({snapshot, flightNumber: aeroFlightNumber(candidate)});
    }
  }
  return parsed;
}

function localDateFor(millis: number, timezone: string): string {
  return new Intl.DateTimeFormat("en-CA", {
    timeZone: timezone, year: "numeric", month: "2-digit", day: "2-digit",
  }).format(new Date(millis));
}

export interface FlightAlertWebhookDeps {
  firestore: () => FirebaseFirestore.Firestore;
  secret: () => string;
  now: () => Date;
}

export const defaultFlightAlertWebhookDeps: FlightAlertWebhookDeps = {
  firestore: () => admin.firestore(),
  secret: () => flightWebhookSecret.value(),
  now: () => new Date(),
};

export type FlightAlertOutcome =
  | "applied" | "skipped" | "no-match" | "missing-leg";

/**
 * Applies a pushed flight update to the leg named by `?leg=`. The URL
 * secret is the only authentication — the path is unguessable and
 * revocation is a redeploy. A pushed flight whose flight number or
 * arrival date does not match the leg is ignored: the same flight
 * number runs daily and subscriptions outlive the day they were made.
 */
export async function flightAlertWebhookHandler(
  query: Record<string, unknown>,
  body: unknown,
  deps: FlightAlertWebhookDeps = defaultFlightAlertWebhookDeps,
): Promise<FlightAlertOutcome> {
  if (query["key"] !== deps.secret()) {
    throw new FlightAlertAuthError();
  }
  const legId = typeof query["leg"] === "string" ? query["leg"] : null;
  if (!legId) return "no-match";
  const flights = pushedFlights(body);
  if (flights.length === 0) return "no-match";

  const db = deps.firestore();
  const legRef = db.collection("programTravelLegs").doc(legId);
  const legSnap = await legRef.get();
  const leg = legSnap.data() as ProgramTravelLegDocument | undefined;
  if (!leg) return "missing-leg";

  const programSnap =
    await db.collection("organizerPrograms").doc(leg.programId).get();
  const timezone =
    (programSnap.data() as {timezone?: string} | undefined)?.timezone ??
      "UTC";
  const legArrivalMillis =
    leg.estimatedArrivalAt?.toMillis() ?? leg.scheduledArrivalAt?.toMillis();
  const legDate = legArrivalMillis == null ? null :
    localDateFor(legArrivalMillis, timezone);
  const legFlight = leg.flightNumber ?
    normalizeFlightNumber(leg.flightNumber) : null;

  const matching = flights.filter((flight) => {
    if (legFlight && flight.flightNumber &&
      flight.flightNumber !== legFlight) {
      return false;
    }
    if (legDate && flight.snapshot.scheduledArrivalMillis != null &&
      localDateFor(flight.snapshot.scheduledArrivalMillis, timezone) !==
        legDate) {
      return false;
    }
    return true;
  });
  if (matching.length === 0) return "no-match";

  // Latest provider observation wins within one delivery.
  matching.sort((a, b) =>
    (a.snapshot.providerUpdatedAtMillis ?? 0) -
    (b.snapshot.providerUpdatedAtMillis ?? 0));
  const snapshot = matching[matching.length - 1].snapshot;
  const nowMillis = deps.now().getTime();
  const patch = applyFlightSnapshot(leg, snapshot, nowMillis);
  await writeFlightSnapshot(legRef, leg, patch, nowMillis);
  return "applied";
}

export class FlightAlertAuthError extends Error {
  constructor() {
    super("Invalid flight alert webhook key.");
    this.name = "FlightAlertAuthError";
  }
}

export const flightAlertWebhook = onRequest(
  {secrets: [flightWebhookSecret, aeroDataBoxApiKey]},
  async (request, response) => {
    if (request.method !== "POST") {
      response.status(405).send("POST only.");
      return;
    }
    try {
      const outcome = await flightAlertWebhookHandler(
        request.query as Record<string, unknown>, request.body);
      // 204 even when nothing matched: pushes are best-effort and a
      // non-2xx would trigger provider retries we cannot satisfy.
      response.status(204).send();
      if (outcome === "applied") {
        logger.info("Flight alert applied", {outcome});
      }
    } catch (error) {
      if (error instanceof FlightAlertAuthError) {
        response.status(403).send("Forbidden.");
        return;
      }
      logger.error("Flight alert webhook failed", error);
      response.status(400).send("Bad flight alert payload.");
    }
  },
);
