import * as admin from "firebase-admin";
import {CallableRequest, HttpsError, onCall} from
  "firebase-functions/v2/https";
import {requireAuth} from "../shared/auth";
import {appCheckCallableOptionsWithLimits} from "../shared/callableOptions";
import {checkRateLimit} from "../shared/rateLimit";
import {requireProgramAccess, requireProgramDuty} from
  "../shared/programAuthority";
import {validateCallableWithAjv} from "../shared/validation";
import {hashRequest} from "../transport/programArrivals";
import {nextFlightRefreshAt} from "../transport/flightRefresh";
import type {ImportProgramManifestCallablePayload} from
  "../shared/generated/importProgramManifestCallablePayload";
import type {ProgramManifestImportCallableResponse} from
  "../shared/generated/programManifestImportCallableResponse";
import {
  validateImportProgramManifestCallablePayload,
} from "../shared/generated/validators/importProgramManifestInput";
import type {
  ProgramGuestDocument,
  ProgramHouseholdDocument,
  ProgramHotelDocument,
  ProgramPickupPointDocument,
  ProgramTravelLegDocument,
  ProgramTravelPartyDocument,
  TransportOperationReceiptDocument,
} from "../shared/generated/firestoreAdminTypes";

interface ImportDeps {
  firestore: () => FirebaseFirestore.Firestore;
  checkRateLimit: typeof checkRateLimit;
  now: () => FirebaseFirestore.Timestamp;
}

const defaultDeps: ImportDeps = {
  firestore: () => admin.firestore(),
  checkRateLimit,
  now: () => admin.firestore.Timestamp.now(),
};

const receiptRetentionMillis = 30 * 24 * 60 * 60 * 1000;
const importCallableLimits = {timeoutSeconds: 120, maxInstances: 5};
const batchSize = 400;

type ManifestRow =
  ImportProgramManifestCallablePayload["rows"][number];

interface RowIssue {
  index: number;
  message: string;
}

interface RowPlan {
  index: number;
  row: ManifestRow;
  guestId: string;
  guestAction: "create" | "update";
  existingGuest: ProgramGuestDocument | null;
  legId: string | null;
  legAction: "create" | "update" | "none";
  existingLeg: ProgramTravelLegDocument | null;
  householdId: string | null;
  partyId: string | null;
  pickupPointId: string | null;
  hotelId: string | null;
}

function normalizeLabel(value: string | null | undefined): string | null {
  const trimmed = value?.trim().toLowerCase();
  return trimmed ? trimmed : null;
}

function arrivalDayBucket(millis: number | null | undefined): string {
  if (millis == null) return "none";
  return new Date(millis).toISOString().slice(0, 10);
}

function normalizeFlightNumber(
  value: string | null | undefined
): string | null {
  const normalized = value?.replace(/[\s-]+/g, "").toUpperCase();
  return normalized ? normalized : null;
}

async function listByProgram<T>(
  db: FirebaseFirestore.Firestore,
  collectionPath: string,
  programId: string,
): Promise<Map<string, T>> {
  const snap = await db.collection(collectionPath)
    .where("programId", "==", programId)
    .get();
  const result = new Map<string, T>();
  for (const doc of snap.docs) result.set(doc.id, doc.data() as T);
  return result;
}

/**
 * Dedup keys: externalReference wins; a flight leg keys on
 * name + flight + arrival day only when exactly one candidate exists.
 * Name-only matches require review and never merge people.
 */
function guestDedupKey(row: ManifestRow): {
  key: string; ambiguous: boolean;
} {
  if (row.externalReference) {
    return {
      key: `ref:${row.externalReference}`, ambiguous: false,
    };
  }
  const name = normalizeLabel(row.displayName)!;
  const flight = normalizeFlightNumber(row.flightNumber);
  if (flight) {
    return {
      key: `leg:${name}|${flight}|` +
        arrivalDayBucket(row.scheduledArrivalAtMillis),
      ambiguous: false,
    };
  }
  return {key: `name:${name}`, ambiguous: true};
}

function buildPlans(
  rows: ManifestRow[],
  guests: Map<string, ProgramGuestDocument>,
  legs: Map<string, ProgramTravelLegDocument>,
  households: Map<string, ProgramHouseholdDocument>,
  parties: Map<string, ProgramTravelPartyDocument>,
  hotels: Map<string, ProgramHotelDocument>,
  pickupPoints: Map<string, ProgramPickupPointDocument>,
  db: FirebaseFirestore.Firestore,
): {plans: RowPlan[]; issues: RowIssue[];
    newHouseholds: Map<string, string>; newParties: Map<string, string>;
    newLabels: Map<string, string>} {
  const issues: RowIssue[] = [];
  const plans: RowPlan[] = [];
  const seenKeys = new Set<string>();
  const selectedGuests = new Set<string>();
  const householdByLabel = new Map<string, string>();
  const partyByLabel = new Map<string, string>();
  const hotelByName = new Map<string, string>();
  const pickupByLabel = new Map<string, string>();
  const newHouseholds = new Map<string, string>();
  const newParties = new Map<string, string>();
  const newLabels = new Map<string, string>();
  for (const [id, doc] of households) {
    const label = normalizeLabel(doc.label);
    if (label && !householdByLabel.has(label)) householdByLabel.set(label, id);
  }
  for (const [id, doc] of parties) {
    const label = normalizeLabel(doc.label);
    if (label && !partyByLabel.has(label)) partyByLabel.set(label, id);
  }
  for (const [id, doc] of hotels) {
    const name = normalizeLabel(doc.name);
    if (name && !hotelByName.has(name)) hotelByName.set(name, id);
  }
  for (const [id, doc] of pickupPoints) {
    const label = normalizeLabel(doc.label);
    if (label && !pickupByLabel.has(label)) pickupByLabel.set(label, id);
  }

  const guestsByRef = new Map<string, string[]>();
  const guestsByName = new Map<string, string[]>();
  for (const [id, guest] of guests) {
    if (guest.externalReference) {
      const key = `ref:${guest.externalReference}`;
      guestsByRef.set(key, [...(guestsByRef.get(key) ?? []), id]);
    }
    const name = normalizeLabel(guest.displayName);
    if (name) {
      const list = guestsByName.get(name) ?? [];
      list.push(id);
      guestsByName.set(name, list);
    }
  }
  const legsByGuestFlight = new Map<string, string>();
  for (const [id, leg] of legs) {
    const flight = normalizeFlightNumber(leg.flightNumber);
    if (flight) {
      legsByGuestFlight.set(
        `${leg.guestId}|${flight}|` +
          arrivalDayBucket(leg.scheduledArrivalAt?.toMillis()), id);
    }
  }

  for (const [index, row] of rows.entries()) {
    const plan: RowPlan = {
      index, row,
      guestId: "", guestAction: "create", existingGuest: null,
      legId: null, legAction: "none", existingLeg: null,
      householdId: null, partyId: null,
      pickupPointId: null, hotelId: null,
    };
    const rowErrors: string[] = [];

    const dedup = guestDedupKey(row);
    if (seenKeys.has(dedup.key)) {
      rowErrors.push(
        "Duplicate manifest row; add a distinct externalReference.");
    }
    seenKeys.add(dedup.key);

    if (!row.displayName.trim()) rowErrors.push("Guest name is required.");
    const referenceMatches = dedup.key.startsWith("ref:") ?
      guestsByRef.get(dedup.key) ?? [] : [];
    let guestId = referenceMatches.length === 1 ?
      referenceMatches[0] : undefined;
    if (referenceMatches.length > 1) {
      rowErrors.push("Multiple guests share this reference; resolve it first.");
    }
    // A new upstream reference may adopt exactly one unreferenced guest.
    // It must never overwrite a different reference or choose an arbitrary
    // same-name person. Flight-only evidence also requires a service date.
    if (!guestId && referenceMatches.length === 0 && row.flightNumber &&
        row.scheduledArrivalAtMillis != null) {
      const name = normalizeLabel(row.displayName)!;
      const flight = normalizeFlightNumber(row.flightNumber)!;
      const day = arrivalDayBucket(row.scheduledArrivalAtMillis);
      const candidates = (guestsByName.get(name) ?? []).filter((id) =>
        (!row.externalReference || !guests.get(id)!.externalReference) &&
        legsByGuestFlight.has(`${id}|${flight}|${day}`));
      if (candidates.length === 1) guestId = candidates[0];
      if (candidates.length > 1) {
        rowErrors.push("Ambiguous guest and flight; use externalReference.");
      }
    }
    if (!guestId && !row.externalReference &&
        (!row.flightNumber || row.scheduledArrivalAtMillis == null) &&
        (guestsByName.get(normalizeLabel(row.displayName)!) ?? []).length > 0) {
      rowErrors.push(
        "Name alone cannot identify a guest; use externalReference.");
    }
    if (guestId && selectedGuests.has(guestId)) {
      rowErrors.push("Multiple rows target the same guest; resolve the rows.");
    }
    if (guestId) {
      plan.guestId = guestId;
      plan.guestAction = "update";
      plan.existingGuest = guests.get(guestId)!;
    }

    const pickupLabel = normalizeLabel(row.pickupPointLabel);
    if (row.pickupPointLabel != null) {
      plan.pickupPointId = pickupLabel ?
        pickupByLabel.get(pickupLabel) ?? null : null;
      if (!plan.pickupPointId) {
        rowErrors.push(`Unknown pickup point "${row.pickupPointLabel}".`);
      }
    }
    const hotelName = normalizeLabel(row.destinationHotelName);
    if (row.destinationHotelName != null) {
      plan.hotelId = hotelName ? hotelByName.get(hotelName) ?? null : null;
      if (!plan.hotelId) {
        rowErrors.push(`Unknown hotel "${row.destinationHotelName}".`);
      }
    }
    // Validate before creating anything: an errored row must not mint
    // households or parties that a commit would then write.
    if (rowErrors.length > 0) {
      for (const message of rowErrors) {
        issues.push({index, message});
      }
      continue;
    }
    if (row.householdLabel) {
      const label = normalizeLabel(row.householdLabel)!;
      let householdId = householdByLabel.get(label);
      if (!householdId) {
        householdId = newHouseholds.get(label) ??
          db.collection("programHouseholds").doc().id;
        newHouseholds.set(label, householdId);
        newLabels.set(householdId, row.householdLabel!.trim());
        householdByLabel.set(label, householdId);
      }
      plan.householdId = householdId;
    }
    if (row.partyLabel) {
      const label = normalizeLabel(row.partyLabel)!;
      let partyId = partyByLabel.get(label);
      if (!partyId) {
        partyId = newParties.get(label) ??
          db.collection("programTravelParties").doc().id;
        newParties.set(label, partyId);
        newLabels.set(partyId, row.partyLabel!.trim());
        partyByLabel.set(label, partyId);
      }
      plan.partyId = partyId;
    }

    const flight = normalizeFlightNumber(row.flightNumber);
    if (flight || row.scheduledArrivalAtMillis != null) {
      const legKey = plan.guestId && flight ?
        `${plan.guestId}|${flight}|` +
          arrivalDayBucket(row.scheduledArrivalAtMillis) : null;
      const existingLegId = legKey ? legsByGuestFlight.get(legKey) : null;
      if (existingLegId) {
        plan.legId = existingLegId;
        plan.legAction = "update";
        plan.existingLeg = legs.get(existingLegId)!;
      } else {
        plan.legAction = "create";
      }
    }
    if (!plan.guestId) {
      plan.guestId = db.collection("programGuests").doc().id;
    }
    selectedGuests.add(plan.guestId);
    plans.push(plan);
  }
  return {plans, issues, newHouseholds, newParties, newLabels};
}

export async function importProgramManifestHandler(
  request: CallableRequest<unknown>,
  deps: ImportDeps = defaultDeps
): Promise<ProgramManifestImportCallableResponse> {
  const actorUid = requireAuth(request);
  const data =
    validateCallableWithAjv<ImportProgramManifestCallablePayload>(
      request, validateImportProgramManifestCallablePayload);
  const db = deps.firestore();
  await deps.checkRateLimit(db, actorUid, "importProgramManifest");
  const access = await requireProgramAccess({
    db, programId: data.programId, actorUid, now: deps.now(),
  });
  requireProgramDuty(access, "programCoordinator");

  const requestHash = hashRequest({
    programId: data.programId, mode: data.mode, rows: data.rows,
  });
  const receiptRef = db.collection("transportOperationReceipts").doc(
    `${data.programId}__manifestImport__${data.clientOperationId}`);

  if (data.mode === "commit") {
    const receiptSnap = await receiptRef.get();
    const receipt = receiptSnap.data() as
      TransportOperationReceiptDocument | undefined;
    if (receipt) {
      if (receipt.requestHash !== requestHash ||
          receipt.actorUid !== actorUid) {
        throw new HttpsError(
          "aborted",
          "This operation id was already used for a different request.");
      }
      const replayed = JSON.parse(receipt.resultJson ?? "{}") as
        ProgramManifestImportCallableResponse;
      return {...replayed, alreadyApplied: true};
    }
  }

  const [guests, legs, households, parties, hotels, pickupPoints] =
    await Promise.all([
      listByProgram<ProgramGuestDocument>(
        db, "programGuests", data.programId),
      listByProgram<ProgramTravelLegDocument>(
        db, "programTravelLegs", data.programId),
      listByProgram<ProgramHouseholdDocument>(
        db, "programHouseholds", data.programId),
      listByProgram<ProgramTravelPartyDocument>(
        db, "programTravelParties", data.programId),
      listByProgram<ProgramHotelDocument>(
        db, "programHotels", data.programId),
      listByProgram<ProgramPickupPointDocument>(
        db, "programPickupPoints", data.programId),
    ]);

  const {plans, issues, newHouseholds, newParties, newLabels} = buildPlans(
    data.rows, guests, legs, households, parties, hotels, pickupPoints, db);

  const response: ProgramManifestImportCallableResponse = {
    mode: data.mode,
    totalRows: data.rows.length,
    guestsCreated: plans.filter((p) => p.guestAction === "create").length,
    guestsUpdated: plans.filter((p) => p.guestAction === "update").length,
    legsCreated: plans.filter((p) => p.legAction === "create").length,
    legsUpdated: plans.filter((p) => p.legAction === "update").length,
    householdsCreated: newHouseholds.size,
    partiesCreated: newParties.size,
    rowErrors: issues,
    alreadyApplied: false,
  };
  if (data.mode === "preview") return response;

  const now = deps.now();
  const organizerId = access.program.organizerId;
  const householdMembers = new Map<string, Set<string>>();
  const partyMembers = new Map<string, Set<string>>();

  const writes: Array<{path: string; data: object}> = [];

  for (const plan of plans) {
    const row = plan.row;
    const existing = plan.existingGuest;
    const guestDoc: ProgramGuestDocument = {
      programId: data.programId,
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
      revision: (existing?.revision ?? 0) + 1,
    };
    writes.push({path: `programGuests/${plan.guestId}`, data: guestDoc});
    if (plan.householdId) {
      const members = householdMembers.get(plan.householdId) ?? new Set();
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
        programId: data.programId,
        organizerId,
        guestId: plan.guestId,
        partyId: plan.partyId ?? existingLeg?.partyId ?? null,
        kind: "inbound",
        flightNumber: row.flightNumber === undefined ?
          existingLeg?.flightNumber ?? null :
          normalizeFlightNumber(row.flightNumber),
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
        flightNextRefreshAt: nextFlightRefreshAt(
          row.flightNumber !== undefined ?
            normalizeFlightNumber(row.flightNumber) :
            existingLeg?.flightNumber ?? null,
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
        revision: (existingLeg?.revision ?? 0) + 1,
      };
      writes.push({path: `programTravelLegs/${legId}`, data: legDoc});
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
      programId: data.programId,
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
      programId: data.programId,
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
    const merged = new Set<string>(existing.memberGuestIds);
    for (const guestId of members) merged.add(guestId);
    if (merged.size !== existing.memberGuestIds.length) {
      writes.push({
        path: `programHouseholds/${householdId}`,
        data: {...existing, memberGuestIds: [...merged].sort(),
          updatedAt: now, revision: (existing.revision ?? 0) + 1},
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
          updatedAt: now, revision: (existing.revision ?? 0) + 1},
      });
    }
  }

  writes.push({
    path: receiptRef.path,
    data: {
      programId: data.programId,
      operationKind: "manifestImport",
      clientOperationId: data.clientOperationId,
      actorUid,
      requestHash,
      tripId: null,
      legId: null,
      resultRevision: 1,
      resultJson: JSON.stringify(response),
      createdAt: now,
      expiresAt: admin.firestore.Timestamp.fromMillis(
        now.toMillis() + receiptRetentionMillis),
    } satisfies Partial<TransportOperationReceiptDocument>,
  });

  // Batched, not transactional: a manifest exceeds transaction limits.
  // Idempotent convergence covers a mid-import failure — a replay re-plans
  // from live state and only applies the remaining writes.
  for (let offset = 0; offset < writes.length; offset += batchSize) {
    const batch = db.batch();
    for (const write of writes.slice(offset, offset + batchSize)) {
      batch.set(db.doc(write.path),
        write.data as admin.firestore.DocumentData);
    }
    await batch.commit();
  }
  return response;
}

export const importProgramManifest = onCall(
  appCheckCallableOptionsWithLimits(importCallableLimits),
  async (request) => importProgramManifestHandler(request),
);
