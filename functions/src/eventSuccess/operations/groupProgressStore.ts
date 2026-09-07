import {HttpsError} from "firebase-functions/v2/https";
import type {Firestore, Transaction} from "firebase-admin/firestore";
import {operationContentHash} from "../../operations/durableActions";
import {isOrganizerManager} from "../../shared/organizerHosts";
import {validateOrganizerDocument} from
  "../../shared/generated/validators/organizerDocument";
import {validateEventDocument} from
  "../../shared/generated/validators/eventDocument";
import {validateEventSuccessPlanDocument} from
  "../../shared/generated/validators/eventSuccessPlanDocument";
import {validateEventAssistanceGroupProgressDocument} from
  "../../shared/generated/validators/eventAssistanceGroupProgressDocument";
import {validateEventAssistanceProgressReceiptDocument} from
  "../../shared/generated/validators/eventAssistanceProgressReceiptDocument";
import {validateConfirmEventAssistanceDepartureCallablePayload} from
  "../../shared/generated/validators/confirmEventAssistanceDepartureInput";
import {validateGetEventAssistanceGroupProgressCallablePayload} from
  "../../shared/generated/validators/getEventAssistanceGroupProgressInput";
import {validateEventAssistanceGroupProgressCallableResponse} from
  "../../shared/generated/validators/eventAssistanceGroupProgressOutput";
import type {EventAssistanceGroupProgressDocument as Progress} from
  "../../shared/generated/eventAssistanceGroupProgressDocument";
import type {EventAssistanceGroupProgressCallableResponse as Response} from
  "../../shared/generated/eventAssistanceGroupProgressCallableResponse";
import type {OrganizerDocument} from
  "../../shared/generated/firestoreAdminTypes";
import {assertCommandContext, assertCommandRole} from "./commands";
import {requireDocumentId} from "./guestRecords";
import {
  groupProgressSource, invalidSource, ProgressContext, progressIdentity,
  projectGroupProgress,
} from "./groupProgressSource";

export const GROUP_PROGRESS = "eventAssistanceGroupProgress";
export const PROGRESS_RECEIPTS = "eventAssistanceProgressReceipts";

/** Physical progress is independent of messaging policy and execution. */
export class EventGroupProgressStore {
  constructor(private readonly db: Firestore,
    private readonly clock: () => number = Date.now) {}

  async get(actorUid: string, input: unknown): Promise<Response> {
    if (!validateGetEventAssistanceGroupProgressCallablePayload(input)) {
      throw new HttpsError("invalid-argument", "Invalid group progress scope.");
    }
    return this.db.runTransaction(async (tx) => {
      const state = await this.read(tx, actorUid, input.context, input.groupId);
      return response("read", state);
    });
  }

  async confirmDeparture(actorUid: string, input: unknown): Promise<Response> {
    if (!validateConfirmEventAssistanceDepartureCallablePayload(input) ||
        input.command.kind !== "confirmDeparture" ||
        input.command.context.mode !== "live") {
      throw new HttpsError("invalid-argument", "Invalid departure command.");
    }
    const command = input.command;
    const context = command.context;
    if (context.mode !== "live") throw invalidSource();
    assertCommandContext(command, context);
    const hash = operationContentHash([actorUid, input]);
    const receiptId = "progress-action:" + operationContentHash([
      context, command.payload.groupId, command.operationId]);
    return this.db.runTransaction(async (tx) => {
      const state = await this.read(tx, actorUid, context,
        command.payload.groupId);
      const receiptRef = this.db.collection(PROGRESS_RECEIPTS).doc(receiptId);
      const receipt = (await tx.get(receiptRef)).data();
      // Receipt reads can outlast the event. Re-sample after every source read.
      const now = this.clock();
      if (!Number.isSafeInteger(now) || now < state.now) throw invalidSource();
      state.now = now;
      state.source.eventOpen = state.source.eventOpen &&
        now < state.source.endAt;
      // Resolve the role from canonical organizer state in this transaction.
      assertCommandRole(command, ["eventLead"]);
      if (receipt !== undefined) {
        if (!validateEventAssistanceProgressReceiptDocument(receipt) ||
            receipt.receiptId !== receiptId ||
            receipt.progressId !== state.progress?.progressId ||
            receipt.requestHash !== hash ||
            receipt.revision > state.progress.revision ||
            receipt.createdAt > state.now) throw conflict();
        return response("replayed", state, receipt.revision);
      }
      if (command.payload.expectedProgressRevision !==
          (state.progress?.revision ?? 0) ||
          input.expectedSourceHash !== state.source.sourceHash) {
        throw conflict();
      }
      if (!state.source.eventOpen || !state.source.runtimeLive) {
        throw new HttpsError("failed-precondition",
          "Start the event before confirming departure.");
      }
      const target = state.source.destinations.find((d) =>
        operationContentHash(d.target) ===
          operationContentHash(command.payload.destination));
      if (!target) {
        throw new HttpsError("failed-precondition",
          "Choose a destination from the current event setup.");
      }
      const progress: Progress = {
        schemaVersion: 1, progressId: progressIdentity(context,
          command.payload.groupId), context, groupId: command.payload.groupId,
        revision: (state.progress?.revision ?? 0) + 1,
        destination: target.target, sourceHash: state.source.sourceHash,
        confirmedBy: actorUid, confirmedAt: state.now,
        operationId: command.operationId, requestHash: hash,
        createdAt: state.progress?.createdAt ?? state.now, updatedAt: state.now,
      };
      if (!validateEventAssistanceGroupProgressDocument(progress)) {
        throw invalidSource();
      }
      const savedReceipt = {receiptId, progressId: progress.progressId,
        requestHash: hash, revision: progress.revision, createdAt: state.now};
      if (!validateEventAssistanceProgressReceiptDocument(savedReceipt)) {
        throw invalidSource();
      }
      const result = response("applied", {...state, progress},
        progress.revision);
      tx.set(this.db.collection(GROUP_PROGRESS).doc(progress.progressId),
        progress);
      tx.create(receiptRef, savedReceipt);
      return result;
    });
  }

  private async read(tx: Transaction, actorUid: string,
    context: ProgressContext, groupId: string) {
    requireDocumentId(context.organizerId);
    requireDocumentId(context.eventId);
    requireDocumentId(groupId);
    const progressId = progressIdentity(context, groupId);
    const [eventSnap, organizerSnap, planSnap, progressSnap] = await tx.getAll(
      this.db.collection("events").doc(context.eventId),
      this.db.collection("organizers").doc(context.organizerId),
      this.db.collection("eventSuccessPlans").doc(context.eventId),
      this.db.collection(GROUP_PROGRESS).doc(progressId));
    const event = eventSnap.data();
    const organizer = organizerSnap.data();
    const plan = planSnap.data() ?? null;
    if (!validateEventDocument(event) ||
        event.organizerId !== context.organizerId ||
        !validateOrganizerDocument(organizer)) throw invalidSource();
    if (!isOrganizerManager(organizer as unknown as OrganizerDocument,
      actorUid)) {
      throw new HttpsError("permission-denied",
        "Only organizer managers can control group progress.");
    }
    if (plan !== null && (!validateEventSuccessPlanDocument(plan) ||
        plan.eventId !== context.eventId ||
        (plan.organizerId ?? plan.clubId) !== context.organizerId)) {
      throw invalidSource();
    }
    const progress = progressSnap.data() ?? null;
    const now = this.clock();
    if (!Number.isSafeInteger(now) || now < 0 || (progress !== null &&
        (!validateEventAssistanceGroupProgressDocument(progress) ||
          progress.progressId !== progressId || progress.groupId !== groupId ||
          progressIdentity(progress.context, progress.groupId) !== progressId ||
          progress.confirmedAt > now || progress.updatedAt > now ||
          progress.createdAt > progress.confirmedAt ||
          progress.confirmedAt !== progress.updatedAt))) throw invalidSource();
    const source = groupProgressSource({context, groupId, event, plan,
      eventGeneration: eventSnap.createTime,
      planGeneration: planSnap.createTime, now});
    return {source, progress, now};
  }
}

type State = Parameters<typeof projectGroupProgress>;
function response(outcome: Response["outcome"], state: {
  source: State[0]; progress: State[1]; now: number;
}, operationRevision: number | null = null): Response {
  const value = {outcome, view: projectGroupProgress(state.source,
    state.progress, state.now), operationRevision};
  if (!validateEventAssistanceGroupProgressCallableResponse(value)) {
    throw invalidSource();
  }
  return value;
}

function conflict(): HttpsError {
  return new HttpsError("aborted",
    "Group progress changed. Refresh and retry.");
}
