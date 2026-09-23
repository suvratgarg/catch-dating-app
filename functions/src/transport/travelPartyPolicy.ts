import {HttpsError} from "firebase-functions/v2/https";
import {hashRequest} from "../shared/programOperationHash";
import type {ProgramTravelLegDocument, ProgramTravelPartyDocument} from
  "../shared/generated/firestoreAdminTypes";

export type TravelLeg = {id: string; doc: ProgramTravelLegDocument};

/** Hotel ids and free-text destinations occupy separate identity domains. */
export function travelDestinationKey(leg: Pick<ProgramTravelLegDocument,
  "destinationHotelId" | "destinationLabel">): string | null {
  if (leg.destinationHotelId) {
    return hashRequest({kind: "hotel", id: leg.destinationHotelId});
  }
  const label = leg.destinationLabel?.trim().toLowerCase();
  return label ? hashRequest({kind: "label", label}) : null;
}

export function travelPartyRouteKey(leg: Pick<ProgramTravelLegDocument,
  "kind" | "pickupPointId" | "destinationHotelId" | "destinationLabel">
): string {
  return hashRequest({kind: leg.kind, pickupPointId: leg.pickupPointId,
    destination: travelDestinationKey(leg)});
}

export function requireMutableTravelLeg(leg: ProgramTravelLegDocument): void {
  if (leg.readiness === "dispatched" || leg.readiness === "arrived") {
    throw new HttpsError("failed-precondition",
      "This journey already departed. Reconcile its trip before editing.");
  }
}

/** Validate complete membership after applying its indexes. */
export function validateTravelPartyMembership(
  partyId: string,
  party: ProgramTravelPartyDocument,
  legs: Map<string, ProgramTravelLegDocument>,
): TravelLeg[] {
  if (!Array.isArray(party.legIds) || party.legIds.length > 50 ||
      new Set(party.legIds).size !== party.legIds.length) {
    throw new HttpsError("failed-precondition",
      "This party needs explicit journey membership before use.");
  }
  const members = party.legIds.map((id) => ({id, doc: legs.get(id)}));
  if (members.some((leg) => !leg.doc ||
      leg.doc.programId !== party.programId ||
      leg.doc.organizerId !== party.organizerId ||
      leg.doc.partyId !== partyId)) {
    throw new HttpsError("failed-precondition",
      "Travel party and journey membership disagree. Reconcile the party.");
  }
  const valid = members as TravelLeg[];
  if (new Set(valid.map((leg) => leg.doc.guestId)).size !== valid.length) {
    throw new HttpsError("failed-precondition",
      "A travel party must contain one journey per guest.");
  }
  const first = valid[0]?.doc;
  if (first && valid.some(({doc}) =>
    travelPartyRouteKey(doc) !== travelPartyRouteKey(first))) {
    throw new HttpsError("failed-precondition",
      "A party must share a journey kind, pickup point and destination.");
  }
  return valid;
}
