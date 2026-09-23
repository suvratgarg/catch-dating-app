import * as admin from "firebase-admin";
import {snapshotMatchesLeg} from "./flightIdentity";
import * as logger from "firebase-functions/logger";
import {onRequest} from "firebase-functions/v2/https";
import {loadFlightProviderConfig} from "./flightProviderConfig";

import type {ProgramTravelLegDocument} from
  "../shared/generated/firestoreAdminTypes";
import {
  FlightStatusSnapshot,
  normalizeAeroFlight,
} from "./aeroDataBox";
import {
  writeFlightSnapshot,
} from "./flightRefresh";

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
      parsed.push({snapshot, flightNumber: snapshot.flightNumber});
    }
  }
  return parsed;
}

export interface FlightAlertWebhookDeps {
  firestore: () => FirebaseFirestore.Firestore;
  secret: () => string | Promise<string>;
  now: () => Date;
}

export const defaultFlightAlertWebhookDeps: FlightAlertWebhookDeps = {
  firestore: () => admin.firestore(),
  secret: async () => (await loadFlightProviderConfig())?.webhookSecret ?? "",
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
  const secret = await deps.secret();
  if (!secret || query["key"] !== secret) {
    throw new FlightAlertAuthError();
  }
  const legId = typeof query["leg"] === "string" ? query["leg"] : null;
  if (!legId || legId.includes("/") || legId.length > 180) return "no-match";
  const flights = pushedFlights(body);
  if (flights.length === 0) return "no-match";

  const db = deps.firestore();
  const legRef = db.collection("programTravelLegs").doc(legId);
  const legSnap = await legRef.get();
  const leg = legSnap.data() as ProgramTravelLegDocument | undefined;
  if (!leg) return "missing-leg";

  const matching = flights.filter((flight) =>
    snapshotMatchesLeg(leg, flight.snapshot));
  if (matching.length === 0) return "no-match";

  // Latest provider observation wins within one delivery.
  matching.sort((a, b) =>
    (a.snapshot.providerUpdatedAtMillis ?? 0) -
    (b.snapshot.providerUpdatedAtMillis ?? 0));
  const snapshot = matching[matching.length - 1].snapshot;
  const nowMillis = deps.now().getTime();
  const written = await writeFlightSnapshot(legRef, leg, snapshot, nowMillis);
  return written ? "applied" : "skipped";
}

export class FlightAlertAuthError extends Error {
  constructor() {
    super("Invalid flight alert webhook key.");
    this.name = "FlightAlertAuthError";
  }
}

export const flightAlertWebhook = onRequest(
  {},
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
      response.status(500).send("Flight update could not be stored.");
    }
  },
);
