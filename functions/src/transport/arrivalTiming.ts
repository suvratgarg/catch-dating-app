export interface ArrivalTimingInput {
  flight: {
    status: "scheduled" | "airborne" | "landed" | "cancelled" | "diverted";
    scheduledLandingAtMillis: number | null;
    estimatedLandingAtMillis: number | null;
    actualLandingAtMillis: number | null;
  } | null;
  exitLagMillis: number;
  manualCurbAtMillis: number | null;
  readyAtMillis: number | null;
}

export type ArrivalTiming = {
  kind: "available";
  curbAtMillis: number;
  source: "ready" | "manual" | "actualLanding" | "estimatedLanding" |
    "scheduledLanding";
} | {
  kind: "unavailable";
  reason: "cancelled" | "diverted" | "missingTiming";
};

export function resolveArrivalTiming(input: ArrivalTimingInput): ArrivalTiming {
  const {flight, exitLagMillis, manualCurbAtMillis, readyAtMillis} = input;
  for (const value of [exitLagMillis, manualCurbAtMillis, readyAtMillis,
    flight?.actualLandingAtMillis ?? null,
    flight?.estimatedLandingAtMillis ?? null,
    flight?.scheduledLandingAtMillis ?? null]) {
    if (value !== null) requireMillis(value);
  }
  if (readyAtMillis !== null) {
    return {kind: "available", curbAtMillis: readyAtMillis, source: "ready"};
  }
  if (manualCurbAtMillis !== null) {
    return {kind: "available", curbAtMillis: manualCurbAtMillis,
      source: "manual"};
  }
  if (!flight) return {kind: "unavailable", reason: "missingTiming"};
  if (flight.status === "cancelled" || flight.status === "diverted") {
    return {kind: "unavailable", reason: flight.status};
  }
  const times = [
    [flight.actualLandingAtMillis, "actualLanding"],
    [flight.estimatedLandingAtMillis, "estimatedLanding"],
    [flight.scheduledLandingAtMillis, "scheduledLanding"],
  ] as const;
  for (const [landingAtMillis, source] of times) {
    if (landingAtMillis === null) continue;
    const curbAtMillis = landingAtMillis + exitLagMillis;
    requireMillis(curbAtMillis);
    return {kind: "available", curbAtMillis, source};
  }
  return {kind: "unavailable", reason: "missingTiming"};
}

function requireMillis(value: number): void {
  if (!Number.isSafeInteger(value) || value < 0) {
    throw new RangeError(
      "Transport timing must be non-negative safe milliseconds.");
  }
}
