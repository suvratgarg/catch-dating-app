import {defineSecret} from "firebase-functions/params";

export const aeroDataBoxApiKey = defineSecret("AERODATABOX_API_KEY");

const endpoint = "https://api.aerodatabox.com/flights/number";

export type TravelLegFlightStatus =
  | "scheduled" | "enroute" | "landed" | "delayed" | "cancelled"
  | "diverted" | "unknown";

export interface FlightStatusSnapshot {
  status: TravelLegFlightStatus;
  scheduledArrivalMillis: number | null;
  estimatedArrivalMillis: number | null;
  actualArrivalMillis: number | null;
  arrivalTerminal: string | null;
  baggageBelt: string | null;
  providerUpdatedAtMillis: number | null;
}

export type FetchImpl = (
  url: string,
  init: {headers: Record<string, string>},
) => Promise<{status: number; json: () => Promise<unknown>}>;

interface MovementTime {
  utc?: string;
}

interface AeroDataBoxFlight {
  status?: string;
  lastUpdatedUtc?: string;
  arrival?: {
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
  if (!value) return null;
  const parsed = Date.parse(value);
  return Number.isNaN(parsed) ? null : parsed;
}

/** "AI-847", "ai 847" → "AI847"; the API accepts loose formats upstream. */
export function normalizeFlightNumber(flightNumber: string): string {
  return flightNumber.replace(/[\s-]+/g, "").toUpperCase();
}

/**
 * Fetches one flight-number × local-date status from AeroDataBox.
 * Returns null when the provider has no matching flight; throws on
 * transport or provider failure so callers can schedule a retry.
 */
export async function fetchFlightStatus({
  flightNumber,
  dateLocal,
  apiKey,
  fetchImpl = fetch,
}: {
  flightNumber: string;
  dateLocal: string;
  apiKey: string;
  fetchImpl?: FetchImpl;
}): Promise<FlightStatusSnapshot | null> {
  const response = await fetchImpl(
    `${endpoint}/${encodeURIComponent(normalizeFlightNumber(flightNumber))}` +
      `/${encodeURIComponent(dateLocal)}` +
      "?withAircraftImage=false&withLocation=false&withFlightPlan=false",
    {headers: {"X-Api-Key": apiKey}},
  );
  if (response.status === 204 || response.status === 404) return null;
  if (response.status < 200 || response.status >= 300) {
    throw new Error(
      `AeroDataBox flight status failed with HTTP ${response.status}`);
  }
  const flights = (await response.json()) as AeroDataBoxFlight[];
  const flight = flights.find((item) => item?.arrival) ?? flights[0];
  if (!flight) return null;
  const arrival = flight.arrival ?? {};
  return {
    status: statusMap[flight.status ?? "Unknown"] ?? "unknown",
    scheduledArrivalMillis: millis(arrival.scheduledTime?.utc),
    estimatedArrivalMillis:
      millis(arrival.revisedTime?.utc) ??
      millis(arrival.predictedTime?.utc),
    actualArrivalMillis: millis(arrival.runwayTime?.utc),
    arrivalTerminal: arrival.terminal ?? null,
    baggageBelt: arrival.baggageBelt ?? null,
    providerUpdatedAtMillis: millis(flight.lastUpdatedUtc),
  };
}
