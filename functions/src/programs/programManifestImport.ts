import * as admin from "firebase-admin";
import {CallableRequest, HttpsError, onCall} from
  "firebase-functions/v2/https";
import {requireAuth} from "../shared/auth";
import {appCheckCallableOptionsWithLimits} from "../shared/callableOptions";
import {checkRateLimit} from "../shared/rateLimit";
import {requireProgramAccess, requireProgramDuty} from
  "../shared/programAuthority";
import {validateCallableWithAjv} from "../shared/validation";
import {hashRequest} from "../shared/programOperationHash";
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

import {buildManifestPlans, normalizeManifestFlightNumber} from
  "./programManifestPlan";
import {buildManifestChunk, completedManifestRows} from
  "./programManifestChunks";

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

async function listByProgram<T>(
  db: FirebaseFirestore.Firestore,
  collectionPath: string,
  programId: string,
  tx?: FirebaseFirestore.Transaction,
): Promise<Map<string, T>> {
  const query = db.collection(collectionPath)
    .where("programId", "==", programId);
  const snap = tx ? await tx.get(query) : await query.get();
  const result = new Map<string, T>();
  for (const doc of snap.docs) result.set(doc.id, doc.data() as T);
  return result;
}

async function loadManifest(
  db: FirebaseFirestore.Firestore,
  programId: string,
  tx?: FirebaseFirestore.Transaction,
) {
  const [guests, legs, households, parties, hotels, pickupPoints] =
    await Promise.all([
      listByProgram<ProgramGuestDocument>(
        db, "programGuests", programId, tx),
      listByProgram<ProgramTravelLegDocument>(
        db, "programTravelLegs", programId, tx),
      listByProgram<ProgramHouseholdDocument>(
        db, "programHouseholds", programId, tx),
      listByProgram<ProgramTravelPartyDocument>(
        db, "programTravelParties", programId, tx),
      listByProgram<ProgramHotelDocument>(
        db, "programHotels", programId, tx),
      listByProgram<ProgramPickupPointDocument>(
        db, "programPickupPoints", programId, tx),
    ]);

  return {guests, legs, households, parties, hotels, pickupPoints};
}

export async function importProgramManifestHandler(
  request: CallableRequest<unknown>,
  deps: ImportDeps = defaultDeps
): Promise<ProgramManifestImportCallableResponse> {
  const actorUid = requireAuth(request);
  const data = validateCallableWithAjv<ImportProgramManifestCallablePayload>(
    request, validateImportProgramManifestCallablePayload, (value) => {
      if (!value || typeof value !== "object") return value;
      const input = value as {rows?: unknown};
      if (!Array.isArray(input.rows)) return value;
      return {...input, rows: input.rows.map((row) => {
        if (!row || typeof row !== "object") return row;
        const entry = {...row};
        if (typeof entry.flightNumber === "string") {
          entry.flightNumber =
            normalizeManifestFlightNumber(entry.flightNumber);
        }
        return entry;
      })};
    });
  const db = deps.firestore();
  await deps.checkRateLimit(db, actorUid, "importProgramManifest");
  const requestHash = hashRequest({
    programId: data.programId, mode: data.mode, rows: data.rows,
  });
  const receiptRef = db.collection("transportOperationReceipts").doc(
    `${data.programId}__manifestImport__${data.clientOperationId}`);
  const emptyResult = (): ProgramManifestImportCallableResponse => ({
    mode: data.mode, totalRows: data.rows.length, guestsCreated: 0,
    guestsUpdated: 0, legsCreated: 0, legsUpdated: 0, householdsCreated: 0,
    partiesCreated: 0, rowErrors: [], alreadyApplied: false,
  });
  const addResult = (
    result: ProgramManifestImportCallableResponse,
    planned: ReturnType<typeof buildManifestPlans>,
  ): ProgramManifestImportCallableResponse => ({
    ...result,
    guestsCreated: result.guestsCreated + planned.plans
      .filter((p) => p.guestAction === "create").length,
    guestsUpdated: result.guestsUpdated + planned.plans
      .filter((p) => p.guestAction === "update").length,
    legsCreated: result.legsCreated + planned.plans
      .filter((p) => p.legAction === "create").length,
    legsUpdated: result.legsUpdated + planned.plans
      .filter((p) => p.legAction === "update").length,
    householdsCreated: result.householdsCreated + planned.newHouseholds.size,
    partiesCreated: result.partiesCreated + planned.newParties.size,
    rowErrors: [...result.rowErrors, ...planned.issues]
      .sort((a, b) => a.index - b.index),
  });
  if (data.mode === "preview") {
    const access = await requireProgramAccess({
      db, programId: data.programId, actorUid, now: deps.now(),
    });
    requireProgramDuty(access, "programCoordinator");
    let state = await loadManifest(db, data.programId);
    const completed: number[] = [];
    const importedGuestIds: string[] = [];
    let result = emptyResult();
    while (completed.length < data.rows.length) {
      const chunk = buildManifestChunk({rows: data.rows, state,
        completed, importedGuestIds, programId: data.programId,
        organizerId: access.program.organizerId,
        allocateId: (collection) => db.collection(collection).doc().id,
        now: deps.now()});
      state = chunk.state;
      completed.push(...chunk.resolvedIndices);
      importedGuestIds.push(...chunk.planned.plans.map((plan) => plan.guestId));
      result = addResult(result, chunk.planned);
    }
    return result;
  }

  // Each chunk publishes complete travel parties and exact input indices.
  // A retry skips resolved indices, including rejected rows. Concurrent
  // retries serialize through the same receipt and
  // all authority/source reads are revalidated by Firestore on contention.
  let applied = false;
  while (true) {
    const chunk = await db.runTransaction(async (tx) => {
      const access = await requireProgramAccess({
        db, programId: data.programId, actorUid,
        now: deps.now(), transaction: tx,
      });
      requireProgramDuty(access, "programCoordinator");
      const receipt = (await tx.get(receiptRef)).data() as
        TransportOperationReceiptDocument | undefined;
      if (receipt && (receipt.requestHash !== requestHash ||
          receipt.actorUid !== actorUid)) {
        throw new HttpsError("aborted",
          "This operation id was already used for a different request.");
      }
      const previous = receipt ? JSON.parse(receipt.resultJson!) as
        ProgramManifestImportCallableResponse : emptyResult();
      const completed = completedManifestRows(receipt, data.rows.length);
      if (completed.length === data.rows.length) {
        return {result: previous, done: true, applied: false};
      }
      const state = await loadManifest(db, data.programId, tx);
      const now = deps.now();
      const {planned, writes, resolvedIndices} = buildManifestChunk({
        rows: data.rows, completed, state,
        importedGuestIds: receipt?.importedGuestIds ?? [],
        programId: data.programId, organizerId: access.program.organizerId,
        allocateId: (collection) => db.collection(collection).doc().id, now,
      });
      const result = addResult(previous, planned);
      const completedRowIndices = [...completed, ...resolvedIndices]
        .sort((a, b) => a - b);
      for (const write of writes) {
        tx.set(db.doc(write.path), write.data as admin.firestore.DocumentData);
      }
      const progress: TransportOperationReceiptDocument = {
        programId: data.programId, operationKind: "manifestImport",
        clientOperationId: data.clientOperationId, actorUid, requestHash,
        tripId: null, legId: null,
        resultRevision: (receipt?.resultRevision ?? 0) + 1,
        completedRows: completedRowIndices.length, completedRowIndices,
        resultJson: JSON.stringify(result),
        importedGuestIds: [...(receipt?.importedGuestIds ?? []),
          ...planned.plans.map((plan) => plan.guestId)],
        createdAt: receipt?.createdAt ?? now,
        expiresAt: admin.firestore.Timestamp.fromMillis(
          now.toMillis() + receiptRetentionMillis),
      };
      tx.set(receiptRef, progress);
      return {result, done: completedRowIndices.length === data.rows.length,
        applied: true};
    });
    applied ||= chunk.applied;
    if (chunk.done) return {...chunk.result, alreadyApplied: !applied};
  }
}

export const importProgramManifest = onCall(
  appCheckCallableOptionsWithLimits(importCallableLimits),
  async (request) => importProgramManifestHandler(request),
);
