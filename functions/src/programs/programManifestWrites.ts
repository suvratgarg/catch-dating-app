import {requireMutableTravelLeg, validateTravelPartyMembership}
  from "../transport/travelPartyPolicy";
import * as admin from "firebase-admin";
import {HttpsError} from "firebase-functions/v2/https";
import {nextRevision} from "../shared/programAuthority";
import {planHouseholdMembership, type HouseholdMembershipChange} from
  "./programHouseholdMembership";
import {nextFlightRefreshAt} from "../transport/flightRefreshPolicy";
import {reconcileTravelLegState} from
  "../transport/travelLegState";
import type {
  ProgramGuestDocument, ProgramHouseholdDocument, ProgramTravelLegDocument,
  ProgramTravelPartyDocument,
} from "../shared/generated/firestoreAdminTypes";
import {
  buildManifestPlans, normalizeManifestFlightNumber,
} from "./programManifestPlan";

/** Materialize one transaction's plan using the documents it just read. */
export function buildManifestWrites(
  programId: string,
  organizerId: string,
  planned: ReturnType<typeof buildManifestPlans>,
  households: Map<string, ProgramHouseholdDocument>,
  parties: Map<string, ProgramTravelPartyDocument>,
  legs: Map<string, ProgramTravelLegDocument>,
  now: FirebaseFirestore.Timestamp,
): Array<{path: string; data: object}> {
  const {plans, newHouseholds, newParties, newLabels} = planned;
  const householdChanges: HouseholdMembershipChange[] = [];
  const partyMembers = new Map<string, Set<string>>();

  const writes: Array<{path: string; data: object}> = [];

  for (const plan of plans) {
    const row = plan.row;
    const existing = plan.existingGuest;
    if (existing && (existing.programId !== programId ||
        existing.organizerId !== organizerId)) {
      throw new HttpsError("failed-precondition",
        "Guest ownership needs reconciliation.");
    }
    const guestDoc: ProgramGuestDocument = {
      programId,
      organizerId,
      displayName: row.displayName.trim(),
      householdId: plan.householdId ?? existing?.householdId ?? null,
      contactId: existing?.contactId ?? null,
      phoneE164: row.phoneE164 === undefined ?
        existing?.phoneE164 ?? null : row.phoneE164,
      email: row.email === undefined ? existing?.email ?? null : row.email,
      externalReference: row.externalReference ||
        existing?.externalReference || null,
      invitationStatus: existing?.invitationStatus ?? "notInvited",
      rsvpStatus: existing?.rsvpStatus ?? "pending",
      source: existing?.source ?? "import",
      createdAt: existing?.createdAt ?? now,
      updatedAt: now,
      revision: nextRevision(existing?.revision, now),
    };
    writes.push({path: `programGuests/${plan.guestId}`, data: guestDoc});
    householdChanges.push({guestId: plan.guestId,
      previousHouseholdId: existing?.householdId ?? null,
      nextHouseholdId: guestDoc.householdId});
    const partyId = plan.partyId ?? plan.existingLeg?.partyId;
    if (partyId) {
      const members = partyMembers.get(partyId) ??
        new Set(parties.get(partyId)?.legIds ?? []);
      members.add(plan.legId!);
      partyMembers.set(partyId, members);
    }

    if (plan.legAction === "create" || plan.legAction === "update") {
      const existingLeg = plan.existingLeg;
      const legId = plan.legId!;
      const scheduled = row.scheduledArrivalAtMillis != null ?
        admin.firestore.Timestamp.fromMillis(row.scheduledArrivalAtMillis) :
        existingLeg?.scheduledArrivalAt ?? null;
      const legDoc: ProgramTravelLegDocument = {
        programId,
        organizerId,
        guestId: plan.guestId,
        partyId: plan.partyId ?? existingLeg?.partyId ?? null,
        kind: "inbound",
        flightNumber: row.flightNumber === undefined ?
          existingLeg?.flightNumber ?? null :
          normalizeManifestFlightNumber(row.flightNumber),
        carrierCode: existingLeg?.carrierCode ?? null,
        originIata: row.originIata === undefined ?
          existingLeg?.originIata ?? null : row.originIata,
        destinationIata: row.destinationIata === undefined ?
          existingLeg?.destinationIata ?? null : row.destinationIata,
        scheduledArrivalAt: scheduled,
        estimatedArrivalAt: existingLeg?.estimatedArrivalAt ?? null,
        actualArrivalAt: existingLeg?.actualArrivalAt ?? null,
        flightStatus: existingLeg?.flightStatus ??
          (row.flightNumber ? "scheduled" : "unknown"),
        flightInstanceId: existingLeg?.flightInstanceId ?? null,
        arrivalTerminal: existingLeg?.arrivalTerminal ?? null,
        flightRefreshedAt: existingLeg?.flightRefreshedAt ?? null,
        flightAlertSubscriptionId:
          existingLeg?.flightAlertSubscriptionId ?? null,
        flightNextRefreshAt: existingLeg ? existingLeg.flightNextRefreshAt :
          nextFlightRefreshAt(
            normalizeManifestFlightNumber(row.flightNumber),
            scheduled, now.toDate()),
        international: row.international === undefined ?
          existingLeg?.international ?? null : row.international,
        pickupPointId: plan.pickupPointId ??
          existingLeg?.pickupPointId ?? null,
        destinationHotelId: plan.hotelId ??
          existingLeg?.destinationHotelId ?? null,
        destinationLabel: row.destinationLabel === undefined ?
          existingLeg?.destinationLabel ?? null : row.destinationLabel,
        readiness: existingLeg?.readiness ?? "expected",
        readyAt: existingLeg?.readyAt ?? null,
        claimedByUid: existingLeg?.claimedByUid ?? null,
        claimedAt: existingLeg?.claimedAt ?? null,
        manualCurbAt: existingLeg?.manualCurbAt ?? null,
        manualCurbNote: existingLeg?.manualCurbNote ?? null,
        passengers: row.passengers ?? existingLeg?.passengers ?? 1,
        luggageUnits: row.luggageUnits ?? existingLeg?.luggageUnits ?? 0,
        requiredCapabilities: existingLeg?.requiredCapabilities ?? [],
        dedicatedVehicle: existingLeg?.dedicatedVehicle ?? false,
        source: existingLeg?.source ?? "import",
        createdAt: existingLeg?.createdAt ?? now,
        updatedAt: now,
        revision: nextRevision(existingLeg?.revision, now),
      };
      writes.push({path: `programTravelLegs/${legId}`,
        data: reconcileTravelLegState(existingLeg, legDoc, now.toDate()),
      });
    }
  }

  const nextHouseholds = new Map(households);
  for (const [normalizedLabel, householdId] of newHouseholds) {
    const label = newLabels.get(householdId) ?? normalizedLabel;
    const firstMember = plans.find((plan) =>
      plan.householdId === householdId);
    const householdDoc: ProgramHouseholdDocument = {
      programId,
      organizerId,
      label,
      primaryContactName: firstMember?.row.displayName.trim() ?? label,
      primaryPhoneE164: firstMember?.row.phoneE164 ?? null,
      primaryEmail: firstMember?.row.email ?? null,
      memberGuestIds: [],
      deliveryPreference: "none",
      createdAt: now,
      updatedAt: now,
      revision: 1,
    };
    nextHouseholds.set(householdId, householdDoc);
  }
  const memberships = planHouseholdMembership(programId, organizerId,
    nextHouseholds, householdChanges);
  for (const [id, memberGuestIds] of memberships) {
    const existing = nextHouseholds.get(id)!;
    writes.push({path: `programHouseholds/${id}`,
      data: {...existing, memberGuestIds, updatedAt: now,
        revision: households.has(id) ?
          nextRevision(existing.revision, now) : existing.revision}});
  }
  for (const [normalizedLabel, partyId] of newParties) {
    const label = newLabels.get(partyId) ?? normalizedLabel;
    const members = partyMembers.get(partyId) ?? new Set<string>();
    const partyDoc: ProgramTravelPartyDocument = {
      programId,
      organizerId,
      label,
      legIds: [...members].sort(),
      dedicatedVehicle: false,
      createdAt: now,
      updatedAt: now,
      revision: 1,
    };
    writes.push({path: `programTravelParties/${partyId}`, data: partyDoc});
  }
  // Existing parties gain new journeys without losing old ones.
  for (const [partyId, members] of partyMembers) {
    if (!parties.has(partyId)) continue;
    const existing = parties.get(partyId)!;
    const merged = new Set<string>(existing.legIds);
    for (const legId of members) merged.add(legId);
    if (merged.size !== existing.legIds.length) {
      writes.push({
        path: `programTravelParties/${partyId}`,
        data: {...existing, legIds: [...merged].sort(),
          updatedAt: now, revision: nextRevision(existing.revision, now)},
      });
    }
  }

  const nextLegs = new Map(legs);
  const nextParties = new Map(parties);
  for (const write of writes) {
    if (write.path.startsWith("programTravelLegs/")) {
      nextLegs.set(write.path.split("/")[1],
        write.data as ProgramTravelLegDocument);
    }
    if (write.path.startsWith("programTravelParties/")) {
      nextParties.set(write.path.split("/")[1],
        write.data as ProgramTravelPartyDocument);
    }
  }
  for (const partyId of partyMembers.keys()) {
    const members = validateTravelPartyMembership(
      partyId, nextParties.get(partyId)!, nextLegs);
    members.forEach((leg) => requireMutableTravelLeg(leg.doc));
  }
  return writes;
}
