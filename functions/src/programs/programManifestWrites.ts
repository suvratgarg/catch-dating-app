import * as admin from "firebase-admin";
import {nextRevision} from "../shared/programAuthority";
import {nextFlightRefreshAt} from "../transport/flightRefreshPolicy";
import {reconcileTravelLegFlightState} from
  "../transport/travelLegFlightState";
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
  db: FirebaseFirestore.Firestore,
  now: FirebaseFirestore.Timestamp,
): Array<{path: string; data: object}> {
  const {plans, newHouseholds, newParties, newLabels} = planned;
  const householdMembers = new Map<string, Set<string>>();
  const partyMembers = new Map<string, Set<string>>();

  const writes: Array<{path: string; data: object}> = [];

  for (const plan of plans) {
    const row = plan.row;
    const existing = plan.existingGuest;
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
    if (plan.householdId && existing?.householdId &&
        plan.householdId !== existing.householdId) {
      const old = householdMembers.get(existing.householdId) ??
        new Set(households.get(existing.householdId)?.memberGuestIds ?? []);
      old.delete(plan.guestId);
      householdMembers.set(existing.householdId, old);
    }
    if (plan.householdId) {
      const members = householdMembers.get(plan.householdId) ??
        new Set(households.get(plan.householdId)?.memberGuestIds ?? []);
      members.add(plan.guestId);
      householdMembers.set(plan.householdId, members);
    }
    if (plan.partyId) {
      const members = partyMembers.get(plan.partyId) ?? new Set();
      members.add(plan.guestId);
      partyMembers.set(plan.partyId, members);
    }

    if (plan.legAction === "create" || plan.legAction === "update") {
      const existingLeg = plan.existingLeg;
      const legId = plan.legId ??
        db.collection("programTravelLegs").doc().id;
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
        data: reconcileTravelLegFlightState(existingLeg, legDoc, now.toDate()),
      });
    }
  }

  for (const [normalizedLabel, householdId] of newHouseholds) {
    const label = newLabels.get(householdId) ?? normalizedLabel;
    const existingMembers = new Set<string>(
      households.get(householdId)?.memberGuestIds ?? []);
    for (const guestId of householdMembers.get(householdId) ?? []) {
      existingMembers.add(guestId);
    }
    const firstMember = plans.find((plan) =>
      plan.householdId === householdId);
    const householdDoc: ProgramHouseholdDocument = {
      programId,
      organizerId,
      label,
      primaryContactName: firstMember?.row.displayName.trim() ?? label,
      primaryPhoneE164: firstMember?.row.phoneE164 ?? null,
      primaryEmail: firstMember?.row.email ?? null,
      memberGuestIds: [...existingMembers].sort(),
      deliveryPreference: "none",
      createdAt: now,
      updatedAt: now,
      revision: 1,
    };
    writes.push({
      path: `programHouseholds/${householdId}`, data: householdDoc});
  }
  for (const [normalizedLabel, partyId] of newParties) {
    const label = newLabels.get(partyId) ?? normalizedLabel;
    const members = partyMembers.get(partyId) ?? new Set<string>();
    const partyDoc: ProgramTravelPartyDocument = {
      programId,
      organizerId,
      label,
      memberGuestIds: [...members].sort(),
      dedicatedVehicle: false,
      createdAt: now,
      updatedAt: now,
      revision: 1,
    };
    writes.push({path: `programTravelParties/${partyId}`, data: partyDoc});
  }
  // Existing households/parties gain new members without losing old ones.
  for (const [householdId, members] of householdMembers) {
    if (!households.has(householdId)) continue;
    const existing = households.get(householdId)!;
    const merged = members;
    if (merged.size !== existing.memberGuestIds.length ||
        [...merged].some((id) => !existing.memberGuestIds.includes(id))) {
      writes.push({
        path: `programHouseholds/${householdId}`,
        data: {...existing, memberGuestIds: [...merged].sort(),
          updatedAt: now, revision: nextRevision(existing.revision, now)},
      });
    }
  }
  for (const [partyId, members] of partyMembers) {
    if (!parties.has(partyId)) continue;
    const existing = parties.get(partyId)!;
    const merged = new Set<string>(existing.memberGuestIds);
    for (const guestId of members) merged.add(guestId);
    if (merged.size !== existing.memberGuestIds.length) {
      writes.push({
        path: `programTravelParties/${partyId}`,
        data: {...existing, memberGuestIds: [...merged].sort(),
          updatedAt: now, revision: nextRevision(existing.revision, now)},
      });
    }
  }

  return writes;
}
