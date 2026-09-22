import {defineSecret} from "firebase-functions/params";

export const aeroDataBoxApiKey = defineSecret("AERODATABOX_API_KEY");

const endpoint = "https://api.aerodatabox.com/flights/number";

import {FlightStatusSnapshot, TravelLegFlightStatus,
  normalizeFlightNumber} from "./flightIdentity";
export {normalizeFlightNumber} from "./flightIdentity";
export type {FlightStatusSnapshot} from "./flightIdentity";

export type FetchImpl = (
  url: string,
  init: {
    headers: Record<string, string>;
    method?: string;
    body?: string;
  },
) => Promise<{status: number; json: () => Promise<unknown>}>;

interface MovementTime {
  utc?: string;
}

interface AeroDataBoxFlight {
  number?: string;
  departure?: {airport?: {iata?: string}};
  status?: string;
  lastUpdatedUtc?: string;
  arrival?: {
    airport?: {iata?: string};
    terminal?: string;
    baggageBelt?: string;
    scheduledTime?: MovementTime;
    revisedTime?: MovementTime;
    predictedTime?: MovementTime;
    runwayTime?: MovementTime;
  };
}

const statusMap: Record<string, TravelLegFlightStatus> = {
  Expected: "scheduled",
  CheckIn: "scheduled",
  Boarding: "scheduled",
  GateClosed: "scheduled",
  EnRoute: "enroute",
  Departed: "enroute",
  Approaching: "enroute",
  Arrived: "landed",
  Delayed: "delayed",
  Canceled: "cancelled",
  CanceledUncertain: "cancelled",
  Diverted: "diverted",
  Unknown: "unknown",
};

function millis(value: string | undefined): number | null {
  if (typeof value !== "string" || !value) return null;
  const parsed = Date.parse(value);
  return Number.isNaN(parsed) ? null : parsed;
}

/**
 * Fetches one flight-number × local-date status from AeroDataBox.
 * Returns null when the provider has no matching flight; throws on
 * transport or provider failure so callers can schedule a retry.
 */
export async function fetchFlightStatus({
  flightNumber,
  dateLocal,
  scheduledArrivalMillis,
  destinationIata,
  originIata,
  apiKey,
  fetchImpl = fetch,
}: {
  flightNumber: string;
  dateLocal: string;
  scheduledArrivalMillis: number;
  destinationIata: string;
  originIata?: string | null;
  apiKey: string;
  fetchImpl?: FetchImpl;
}): Promise<FlightStatusSnapshot | null> {
  const response = await fetchImpl(
    `${endpoint}/${encodeURIComponent(normalizeFlightNumber(flightNumber))}` +
      `/${encodeURIComponent(dateLocal)}` +
      "?dateLocalRole=Arrival&withAircraftImage=false" +
      "&withLocation=false&withFlightPlan=false",
    {headers: {"X-Api-Key": apiKey}},
  );
  if (response.status === 204 || response.status === 404) return null;
  if (response.status < 200 || response.status >= 300) {
    throw new Error(
      `AeroDataBox flight status failed with HTTP ${response.status}`);
  }
  const body = await response.json();
  if (!Array.isArray(body)) throw new Error("Invalid flight status response.");
  const matches = body.map(normalizeAeroFlight).filter((snapshot) =>
    snapshot && snapshot.flightNumber === normalizeFlightNumber(flightNumber) &&
    snapshot.destinationIata === destinationIata &&
    (!originIata || snapshot.originIata === originIata) &&
    snapshot.scheduledArrivalMillis === scheduledArrivalMillis);
  // Several instances must be reviewed, never selected by array order.
  return matches.length === 1 ? matches[0] : null;
}

/**
 * Normalizes one AeroDataBox flight object (from a status response or a
 * webhook push) into the leg write-back shape. Returns null when the
 * object is not a flight record at all.
 */
export function normalizeAeroFlight(
  flight: AeroDataBoxFlight | undefined,
): FlightStatusSnapshot | null {
  if (!flight || typeof flight !== "object") return null;
  const arrival = flight.arrival;
  if (!arrival || typeof arrival !== "object" ||
      typeof flight.number !== "string") return null;
  const status = statusMap[flight.status ?? "Unknown"] ?? "unknown";
  const observed = millis(flight.lastUpdatedUtc);
  if (observed == null) return null;
  return {
    flightNumber: normalizeFlightNumber(flight.number),
    destinationIata: arrival.airport?.iata ?? null,
    originIata: flight.departure?.airport?.iata ?? null,
    status,
    scheduledArrivalMillis: millis(arrival.scheduledTime?.utc),
    estimatedArrivalMillis:
      millis(arrival.revisedTime?.utc) ??
      millis(arrival.predictedTime?.utc) ?? millis(arrival.runwayTime?.utc),
    actualArrivalMillis: status === "landed" ?
      (millis(arrival.runwayTime?.utc) ??
        millis(arrival.revisedTime?.utc)) : null,
    arrivalTerminal: typeof arrival.terminal === "string" ?
      arrival.terminal.slice(0, 8) : null,
    baggageBelt: arrival.baggageBelt ?? null,
    providerUpdatedAtMillis: observed,
  };
}
