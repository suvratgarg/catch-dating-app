import {runAssistanceTransaction as transact} from "./transactionCallback";
import {HttpsError} from "firebase-functions/v2/https";
import type {Firestore, Transaction} from "firebase-admin/firestore";
import {operationContentHash} from "../../operations/durableActions";
import {isOrganizerManager} from "../../shared/organizerHosts";
import type {OrganizerDocument} from
  "../../shared/generated/firestoreAdminTypes";
import {validateOrganizerDocument} from
  "../../shared/generated/validators/organizerDocument";
import {validateGetEventAssistanceRuntimeConfigCallablePayload} from
  "../../shared/generated/validators/getEventAssistanceRuntimeConfigInput";
import {validateSetEventAssistanceRuntimeConfigCallablePayload} from
  "../../shared/generated/validators/setEventAssistanceRuntimeConfigInput";
import {validateEventAssistanceRuntimeConfigCallableResponse} from
  "../../shared/generated/validators/eventAssistanceRuntimeConfigOutput";
import {validateEventAssistanceRuntimeConfigReceiptDocument} from
  // eslint-disable-next-line max-len -- Canonical individual validator path.
  "../../shared/generated/validators/eventAssistanceRuntimeConfigReceiptDocument";
import type {EventAssistanceRuntimeConfigCallableResponse as Response} from
  "../../shared/generated/eventAssistanceRuntimeConfigCallableResponse";
import {invalidSource} from "./groupProgressSource";
import {prepareRosterWorkEnqueue, runtimeRosterInput} from
  "./rosterWorkEnqueue";
import {RuntimeContext, RUNTIME_CONFIGS, RUNTIME_CONFIG_RECEIPTS,
  parseRuntimeConfig, runtimeConfigId, runtimeConfigSource,
  runtimeConfigStatus, validRuntimeConfiguration} from "./runtimeConfigRecords";

/** Saves permission and its roster job; never infers participation or sends. */
export class EventAssistanceRuntimeConfigStore {
  constructor(private readonly db: Firestore,
    private readonly clock: () => number = Date.now) {}

  async get(actorUid: string, input: unknown): Promise<Response> {
    if (!validateGetEventAssistanceRuntimeConfigCallablePayload(input)) {
      throw new HttpsError("invalid-argument", "Invalid automation scope.");
    }
    return transact(this.db, async (tx) =>
      response("read", await this.read(tx, actorUid, input.context)));
  }

  async set(actorUid: string, input: unknown): Promise<Response> {
    if (!validateSetEventAssistanceRuntimeConfigCallablePayload(input) ||
        input.command.kind === "configure" &&
        !validRuntimeConfiguration(input.command.configuration)) {
      throw new HttpsError("invalid-argument", "Invalid automation setup.");
    }
    const requestHash = operationContentHash([actorUid, input]);
    const receiptId = "runtime-action:" + operationContentHash([
      input.context, input.requestId]);
    return transact(this.db, async (tx) => {
      const state = await this.read(tx, actorUid, input.context);
      const receiptRef = this.db.collection(RUNTIME_CONFIG_RECEIPTS)
        .doc(receiptId);
      const receipt = (await tx.get(receiptRef)).data();
      const now = this.clock();
      if (!Number.isSafeInteger(now) || now < state.now) throw invalidSource();
      state.now = now;
      if (receipt !== undefined) {
        if (!validateEventAssistanceRuntimeConfigReceiptDocument(receipt) ||
            receipt.receiptId !== receiptId ||
            receipt.runtimeId !== state.record?.runtimeId ||
            receipt.sourceGeneration !== state.source.generation ||
            receipt.requestHash !== requestHash ||
            receipt.revision > state.record.revision ||
            receipt.createdAt > now) throw conflict();
        return response("replayed", state, receipt.revision);
      }
      if (input.expectedRevision !== (state.record?.revision ?? 0) ||
          input.expectedSourceHash !== state.source.hash) throw conflict();
      const configuration = input.command.kind === "configure" ?
        input.command.configuration : state.record?.configuration ?? null;
      if (input.command.kind === "configure" &&
          (state.source.closed || configuration!.expiresAt <= now ||
            configuration!.expiresAt > state.source.eventEnd ||
            now >= state.source.eventEnd)) {
        throw new HttpsError("failed-precondition",
          "Automation must end within the current open event.");
      }
      const record = parseRuntimeConfig({schemaVersion: 1,
        runtimeId: runtimeConfigId(input.context), context: input.context,
        workflowKind: "lateJoin", revision: (state.record?.revision ?? 0) + 1,
        status: input.command.kind === "configure" ? "enabled" : "paused",
        configuration, sourceHash: state.source.hash,
        sourceGeneration: state.source.generation, updatedBy: actorUid,
        createdAt: state.record?.createdAt ?? now, updatedAt: now},
      input.context, now);
      const savedReceipt = {receiptId, runtimeId: record.runtimeId, requestHash,
        sourceGeneration: state.source.generation, revision: record.revision,
        createdAt: now};
      if (!validateEventAssistanceRuntimeConfigReceiptDocument(savedReceipt)) {
        throw invalidSource();
      }
      const result = response("applied", {...state, record}, record.revision);
      const roster = input.command.kind === "configure" ?
        await prepareRosterWorkEnqueue(this.db, tx, runtimeRosterInput(record),
          now) : null;
      const committedAt = this.clock();
      if (committedAt < now || (roster &&
          committedAt >= record.configuration!.expiresAt)) throw conflict();
      tx.set(this.db.collection(RUNTIME_CONFIGS).doc(record.runtimeId), record);
      tx.create(receiptRef, savedReceipt);
      roster?.commit();
      return result;
    });
  }

  private async read(tx: Transaction, actorUid: string,
    context: RuntimeContext) {
    const id = runtimeConfigId(context);
    const [eventSnap, planSnap, organizerSnap, recordSnap] = await tx.getAll(
      this.db.collection("events").doc(context.eventId),
      this.db.collection("eventSuccessPlans").doc(context.eventId),
      this.db.collection("organizers").doc(context.organizerId),
      this.db.collection(RUNTIME_CONFIGS).doc(id));
    const organizer = organizerSnap.data();
    if (!validateOrganizerDocument(organizer)) throw invalidSource();
    if (!isOrganizerManager(organizer as unknown as OrganizerDocument,
      actorUid)) {
      throw new HttpsError("permission-denied",
        "Only organizer managers can configure event automation.");
    }
    const now = this.clock();
    const source = runtimeConfigSource(context, eventSnap, planSnap, now);
    const record = recordSnap.exists ?
      parseRuntimeConfig(recordSnap.data(), context, now) : null;
    return {context, source, record, now};
  }
}

type State = {
  context: RuntimeContext; now: number;
  source: ReturnType<typeof runtimeConfigSource>;
  record: ReturnType<typeof parseRuntimeConfig> | null;
};
function response(outcome: Response["outcome"], state: State,
  operationRevision: number | null = null): Response {
  const value: Response = {outcome, operationRevision, view: {
    context: state.context, serverTime: state.now,
    sourceHash: state.source.hash, revision: state.record?.revision ?? 0,
    runtime: state.record,
    status: runtimeConfigStatus(state.record, state.source, state.now),
    canConfigure: !state.source.closed && state.now < state.source.eventEnd,
    eventEnd: state.source.eventEnd}};
  if (!validateEventAssistanceRuntimeConfigCallableResponse(value)) {
    throw invalidSource();
  }
  return value;
}
function conflict(): HttpsError {
  return new HttpsError("aborted",
    "Automation setup changed. Refresh and retry.");
}
