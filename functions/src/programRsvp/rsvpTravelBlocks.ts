import * as admin from "firebase-admin";
import type {ProgramTravelLegDocument} from
  "../shared/generated/firestoreAdminTypes";
import {nextRevision} from "../shared/programAuthority";

/**
 * One household-submitted travel block, mirroring the optional `travel`
 * entries on submitProgramHouseholdRsvpCallablePayload. The generated
 * payload type lands with the contract regen; this interface is the
 * domain-local shape so the write path can be tested independently.
 */
export interface RsvpTravelBlockInput {
  guestId: string;
  kind: "inbound" | "outbound" | "ground";
  flightNumber?: string | null;
  carrierCode?: string | null;
  originIata?: string | null;
  destinationIata?: string | null;
  scheduledArrivalAtMillis?: number | null;
  pickupPointId?: string | null;
  destinationHotelId?: string | null;
  destinationLabel?: string | null;
  passengers?: number | null;
  luggageUnits?: number | null;
}

export interface RsvpTravelLegContext {
  programId: string;
  organizerId: string;
  householdId: string;
  now: FirebaseFirestore.Timestamp;
}

/**
 * Household-submitted legs share one deterministic id per
 * (household, guest, journey kind). Resubmitted blocks update the same
 * row instead of forking duplicates, and replays stay idempotent.
 */
export function rsvpTravelLegId(
  householdId: string,
  guestId: string,
  kind: RsvpTravelBlockInput["kind"],
): string {
  return `rsvp_${householdId}_${guestId}_${kind}`;
}

/** Last block wins per (guestId, kind) inside a single submit. */
export function dedupeTravelBlocks(
  blocks: readonly RsvpTravelBlockInput[] | null | undefined,
): Map<string, RsvpTravelBlockInput> {
  const deduped = new Map<string, RsvpTravelBlockInput>();
  for (const block of blocks ?? []) {
    deduped.set(`${block.guestId}:${block.kind}`, block);
  }
  return deduped;
}

export type RsvpTravelBlockRejection =
  | "missingDestination"
  | "arrivalRequired";

/**
 * Cheap shape checks beyond the payload schema: every leg needs a
 * destination the transport desk can route to, and a scheduled time so
 * dispatch can anchor it. Returns a stable reason or null.
 */
export function rsvpTravelBlockRejection(
  block: RsvpTravelBlockInput,
): RsvpTravelBlockRejection | null {
  if (!block.destinationHotelId && !block.destinationLabel?.trim()) {
    return "missingDestination";
  }
  if (block.scheduledArrivalAtMillis == null) {
    return "arrivalRequired";
  }
  return null;
}

/**
 * Build the stored leg document for a household block. Planner-owned
 * enrichment (provider fields, party membership, curb observations,
 * vehicle requirements) always survives a household resubmit; the block
 * only owns itinerary fields. New legs default to 1 seat, no luggage,
 * and `formResponse` provenance.
 */
export function buildRsvpTravelLegDoc(
  block: RsvpTravelBlockInput,
  ctx: RsvpTravelLegContext,
  existing?: ProgramTravelLegDocument,
): ProgramTravelLegDocument {
  return {
    programId: ctx.programId,
    organizerId: ctx.organizerId,
    guestId: block.guestId,
    partyId: existing?.partyId ?? null,
    kind: block.kind,
    flightNumber: block.flightNumber ?? null,
    carrierCode: block.carrierCode ?? null,
    originIata: block.originIata ?? null,
    destinationIata: block.destinationIata ?? null,
    scheduledArrivalAt: block.scheduledArrivalAtMillis == null ? null :
      admin.firestore.Timestamp.fromMillis(block.scheduledArrivalAtMillis),
    estimatedArrivalAt: existing?.estimatedArrivalAt ?? null,
    actualArrivalAt: existing?.actualArrivalAt ?? null,
    flightStatus: existing?.flightStatus ??
      (block.flightNumber ? "scheduled" : "unknown"),
    flightInstanceId: existing?.flightInstanceId ?? null,
    international: existing?.international ?? null,
    // Pickup points are ops routing a household form cannot express;
    // keep a planner assignment unless the block names one.
    pickupPointId: block.pickupPointId ?? existing?.pickupPointId ?? null,
    destinationHotelId: block.destinationHotelId ?? null,
    destinationLabel: block.destinationLabel ?? null,
    readiness: existing?.readiness ?? "expected",
    readyAt: existing?.readyAt ?? null,
    claimedByUid: existing?.claimedByUid ?? null,
    claimedAt: existing?.claimedAt ?? null,
    manualCurbAt: existing?.manualCurbAt ?? null,
    manualCurbNote: existing?.manualCurbNote ?? null,
    passengers: block.passengers ?? 1,
    luggageUnits: block.luggageUnits ?? 0,
    requiredCapabilities: existing?.requiredCapabilities ?? [],
    dedicatedVehicle: existing?.dedicatedVehicle ?? false,
    source: existing?.source ?? "formResponse",
    createdAt: existing?.createdAt ?? ctx.now,
    updatedAt: ctx.now,
    revision: nextRevision(existing?.revision ?? 0, ctx.now),
    arrivalTerminal: existing?.arrivalTerminal ?? null,
    flightRefreshedAt: existing?.flightRefreshedAt ?? null,
    flightNextRefreshAt: existing?.flightNextRefreshAt ?? null,
    flightAlertSubscriptionId: existing?.flightAlertSubscriptionId ?? null,
    flightProviderUpdatedAt: existing?.flightProviderUpdatedAt ?? null,
    flightAlertFlightNumber: existing?.flightAlertFlightNumber ?? null,
    flightAlertLease: existing?.flightAlertLease ?? null,
  };
}
