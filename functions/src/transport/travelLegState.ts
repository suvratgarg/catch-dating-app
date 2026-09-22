import type {ProgramTravelLegDocument} from
  "../shared/generated/firestoreAdminTypes";
import {flightIdentity, normalizeFlightNumber} from "./flightIdentity";
import {hashRequest} from "../shared/programOperationHash";
import {travelDestinationKey} from "./travelPartyPolicy";
import {nextFlightRefreshAt} from "./flightRefreshPolicy";

/** Rebooking invalidates observations; provider cleanup keeps its lease. */
export function reconcileTravelLegState(
  current: ProgramTravelLegDocument | null | undefined,
  next: ProgramTravelLegDocument,
  now: Date,
): ProgramTravelLegDocument {
  const changed = !current || flightIdentity(current) !== flightIdentity(next);
  const document = {...next,
    flightAlertSubscriptionId: current?.flightAlertSubscriptionId ?? null,
    flightProviderUpdatedAt: current?.flightProviderUpdatedAt ?? null,
    flightAlertFlightNumber: current?.flightAlertFlightNumber ?? null,
    flightAlertLease: current?.flightAlertLease ?? null,
  };
  if (current && observationIdentity(current) !== observationIdentity(next)) {
    Object.assign(document, {readiness: "expected", readyAt: null,
      claimedByUid: null, claimedAt: null, manualCurbAt: null,
      manualCurbNote: null});
  }
  if (!changed) return document;
  return {...document, estimatedArrivalAt: null, actualArrivalAt: null,
    flightStatus: next.flightNumber ? "scheduled" : "unknown",
    flightInstanceId: null, arrivalTerminal: null,
    flightRefreshedAt: null, flightProviderUpdatedAt: null,
    // Removed flights still need a sweep to release their subscription.
    flightNextRefreshAt: (current?.flightAlertSubscriptionId ||
      current?.flightAlertFlightNumber ||
      current?.flightAlertLease) ? next.updatedAt :
      nextFlightRefreshAt(next.flightNumber, next.scheduledArrivalAt, now),
  };
}

function observationIdentity(leg: ProgramTravelLegDocument): string {
  return hashRequest({
    guestId: leg.guestId,
    kind: leg.kind,
    flightNumber: leg.flightNumber ? normalizeFlightNumber(leg.flightNumber) :
      null,
    originIata: leg.originIata,
    destinationIata: leg.destinationIata,
    scheduledArrivalAt: leg.scheduledArrivalAt?.toMillis() ?? null,
    pickupPointId: leg.pickupPointId,
    destination: travelDestinationKey(leg),
  });
}
