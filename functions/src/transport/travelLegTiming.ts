import type {ProgramAccess} from "../shared/programAuthority";
import type {ProgramTravelLegDocument} from
  "../shared/generated/firestoreAdminTypes";
import {staffTimestampMillis} from "../shared/eventOperatorAuthority";
import {resolveArrivalTiming} from "./arrivalTiming";

export function legTiming(leg: ProgramTravelLegDocument,
  settings: ProgramAccess["program"]["transportSettings"]) {
  const statusMap: Record<string,
    "scheduled" | "airborne" | "landed" | "cancelled" | "diverted"> = {
      scheduled: "scheduled",
      enroute: "airborne",
      landed: "landed",
      delayed: "scheduled",
      unknown: "scheduled",
      cancelled: "cancelled",
      diverted: "diverted",
    };
  return resolveArrivalTiming({
    flight: leg.flightNumber ? {
      status: statusMap[leg.flightStatus] ?? "scheduled",
      scheduledLandingAtMillis: leg.scheduledArrivalAt ?
        staffTimestampMillis(leg.scheduledArrivalAt) : null,
      estimatedLandingAtMillis: leg.estimatedArrivalAt ?
        staffTimestampMillis(leg.estimatedArrivalAt) : null,
      actualLandingAtMillis: leg.actualArrivalAt ?
        staffTimestampMillis(leg.actualArrivalAt) : null,
    } : null,
    exitLagMillis: leg.international ?
      settings.internationalExitLagMillis : settings.domesticExitLagMillis,
    manualCurbAtMillis: leg.manualCurbAt ?
      staffTimestampMillis(leg.manualCurbAt) : null,
    readyAtMillis: leg.readyAt ? staffTimestampMillis(leg.readyAt) : null,
  });
}

