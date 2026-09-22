import type {ProgramTravelLegDocument} from
  "../shared/generated/firestoreAdminTypes";
import {flightIdentity} from "./flightIdentity";
import {nextFlightRefreshAt} from "./flightRefreshPolicy";

/** Retain provider lifecycle state while replacing facts from an old flight. */
export function reconcileTravelLegFlightState(
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
