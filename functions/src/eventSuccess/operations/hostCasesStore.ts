import {runAssistanceTransaction as transact} from "./transactionCallback";
import {HttpsError} from "firebase-functions/v2/https";
import {FieldPath} from "firebase-admin/firestore";
import type {Firestore, Transaction} from "firebase-admin/firestore";
import {operationContentHash} from "../../operations/durableActions";
import {isOrganizerManager} from "../../shared/organizerHosts";
import type {OrganizerDocument} from
  "../../shared/generated/firestoreAdminTypes";
import type {EventAssistanceCasesCallableResponse as ListResponse} from
  "../../shared/generated/eventAssistanceCasesCallableResponse";
import type {EventAssistanceCaseCallableResponse as Response} from
  "../../shared/generated/eventAssistanceCaseCallableResponse";
import {validateOrganizerDocument} from
  "../../shared/generated/validators/organizerDocument";
import {validateEventDocument} from
  "../../shared/generated/validators/eventDocument";
import {validateListEventAssistanceCasesCallablePayload} from
  "../../shared/generated/validators/listEventAssistanceCasesInput";
import {validateResolveEventAssistanceCaseCallablePayload} from
  "../../shared/generated/validators/resolveEventAssistanceCaseInput";
import {validateEventAssistanceCasesCallableResponse} from
  "../../shared/generated/validators/eventAssistanceCasesOutput";
import {validateEventAssistanceCaseCallableResponse} from
  "../../shared/generated/validators/eventAssistanceCaseOutput";
import {validateEventAssistanceCaseReceiptDocument} from
  "../../shared/generated/validators/eventAssistanceCaseReceiptDocument";
import {assertCommandContext, assertCommandRole} from "./commands";
import {guestCollections} from "./guestRecords";
import {invalidSource} from "./groupProgressSource";
import {HostCase, hostCaseBindingHash, parseHostCase, projectHostCase} from
  "./hostCaseRecords";

export const CASE_RECEIPTS = "eventAssistanceCaseReceipts";
const pageSize = 50;

/** Practical guest requests. Safety ownership never crosses this boundary. */
export class EventAssistanceCasesStore {
  constructor(private readonly db: Firestore,
    private readonly clock: () => number = Date.now) {}

  async list(actorUid: string, value: unknown): Promise<ListResponse> {
    if (!validateListEventAssistanceCasesCallablePayload(value)) {
      throw new HttpsError("invalid-argument", "Invalid help request scope.");
    }
    const input = structuredClone(value);
    return this.db.runTransaction(async (tx) => {
      const {organizer, event} = await this.access(tx, actorUid, input.context);
      let query = this.db.collection(guestCollections.cases)
        .where("context.mode", "==", "live")
        .where("context.organizerId", "==", input.context.organizerId)
        .where("context.eventId", "==", input.context.eventId)
        .where("owner", "==", "eventLead")
        .where("status", "==", input.status)
        .orderBy(FieldPath.documentId()).limit(pageSize + 1);
      if (input.cursor) query = query.startAfter(input.cursor);
      const snapshot = await tx.get(query);
      const now = this.now();
      const requests = snapshot.docs.map((doc) =>
        parseHostCase(doc.data(), doc.id, input.context, now));
      const page = requests.slice(0, pageSize);
      const attendees = page.length ? await tx.getAll(...page.map((request) =>
        this.db.collection("eventAttendees").doc(request.attendeeId))) : [];
      const result: ListResponse = {context: input.context, serverTime: now,
        coverage: "page", status: input.status,
        cases: page.map((request, i) =>
          projectHostCase(request, event, attendees[i], organizer)),
        nextCursor: requests.length > pageSize ? page.at(-1)!.caseId : null};
      if (!validateEventAssistanceCasesCallableResponse(result)) {
        throw invalidSource();
      }
      return result;
    }, {readOnly: true});
  }

  async resolve(actorUid: string, value: unknown): Promise<Response> {
    if (!validateResolveEventAssistanceCaseCallablePayload(value) ||
        value.command.context.mode !== "live") {
      throw new HttpsError("invalid-argument", "Invalid help request action.");
    }
    const input = structuredClone(value);
    const {command} = input;
    const {context, payload} = command;
    if (context.mode !== "live") throw invalidSource();
    try {
      assertCommandContext(command, context);
    } catch {
      throw new HttpsError("invalid-argument", "Help request scope mismatch.");
    }
    const receiptId = "case-action:" + operationContentHash([
      context, payload.caseId, command.operationId]);
    const requestHash = operationContentHash([actorUid, input]);
    return transact(this.db, async (tx) => {
      const {organizer, event} = await this.access(tx, actorUid, context);
      assertCommandRole(command, ["eventLead"]);
      const caseRef = this.db.collection(guestCollections.cases)
        .doc(payload.caseId);
      const receiptRef = this.db.collection(CASE_RECEIPTS).doc(receiptId);
      const [caseSnap, receiptSnap] = await tx.getAll(caseRef, receiptRef);
      const raw = caseSnap.data();
      if (!raw || raw.owner !== "eventLead" ||
          raw.context?.eventId !== context.eventId ||
          raw.context?.organizerId !== context.organizerId) {
        throw new HttpsError("not-found", "This help request is unavailable.");
      }
      const now = this.now();
      const request = parseHostCase(raw, caseSnap.id, context, now);
      const attendee = await tx.get(this.db.collection("eventAttendees")
        .doc(request.attendeeId));
      const view = projectHostCase(request, event, attendee, organizer);
      const bindingHash = hostCaseBindingHash(request);
      const receipt = receiptSnap.data();
      if (receipt !== undefined) {
        if (!validateEventAssistanceCaseReceiptDocument(receipt) ||
            receipt.receiptId !== receiptId ||
            receipt.caseId !== request.caseId ||
            operationContentHash(receipt.context) !==
              operationContentHash(context) ||
            receipt.actorUid !== actorUid ||
            receipt.outcome !== payload.outcome ||
            receipt.caseBindingHash !== bindingHash ||
            receipt.requestHash !== requestHash ||
            receipt.revision > (view.revision ?? -1) ||
            receipt.createdAt < request.receivedAt ||
            receipt.createdAt > now) throw conflict();
        return this.response("replayed", context, now, receipt.revision, view);
      }
      if (!("handling" in request) || !view.canChange) {
        throw new HttpsError("failed-precondition",
          "This help request is closed or its guest source has changed.");
      }
      if (payload.expectedRevision !== request.handling.revision ||
          input.expectedSourceHash !== view.sourceHash) throw conflict();
      if (payload.outcome === "transferred") {
        if (!isOrganizerManager(organizer, payload.owner)) {
          throw new HttpsError("failed-precondition",
            "Choose a current organizer manager for this handoff.");
        }
      } else if (payload.owner !== actorUid) {
        throw new HttpsError("permission-denied",
          "Record this resolution under your own host identity.");
      }
      const handling = {revision: request.handling.revision + 1,
        assigneeUid: payload.outcome === "transferred" ? payload.owner :
          request.handling.assigneeUid,
        updatedAt: now, resolution: payload.outcome === "transferred" ? null :
          {outcome: payload.outcome, actorUid, at: now}};
      const updated: HostCase = parseHostCase({...request, handling,
        status: handling.resolution ? "resolved" : "open"}, request.caseId,
      context, now);
      const savedReceipt = {receiptId, context, caseId: request.caseId,
        caseBindingHash: bindingHash, requestHash, revision: handling.revision,
        actorUid, outcome: payload.outcome, createdAt: now};
      if (!validateEventAssistanceCaseReceiptDocument(savedReceipt)) {
        throw invalidSource();
      }
      const result = this.response("applied", context, now, handling.revision,
        projectHostCase(updated, event, attendee, organizer));
      tx.set(caseRef, updated);
      tx.create(receiptRef, savedReceipt);
      return result;
    });
  }

  private async access(tx: Transaction, actorUid: string,
    context: ListResponse["context"]) {
    const data = (await tx.get(this.db.collection("organizers")
      .doc(context.organizerId))).data();
    if (!validateOrganizerDocument(data) ||
        !isOrganizerManager(data as unknown as OrganizerDocument, actorUid)) {
      throw new HttpsError("permission-denied",
        "Only organizer managers can review guest help requests.");
    }
    const event = await tx.get(this.db.collection("events")
      .doc(context.eventId));
    const eventData = event.data();
    if (!validateEventDocument(eventData) ||
        eventData.organizerId !== context.organizerId) throw invalidSource();
    return {organizer: data as unknown as OrganizerDocument, event};
  }

  private now(): number {
    const now = this.clock();
    if (!Number.isSafeInteger(now) || now < 0) throw invalidSource();
    return now;
  }

  private response(outcome: Response["outcome"],
    context: Response["context"], serverTime: number, operationRevision: number,
    view: Response["view"]): Response {
    const result = {context, serverTime, operationRevision, view, outcome};
    if (!validateEventAssistanceCaseCallableResponse(result)) {
      throw invalidSource();
    }
    return result;
  }
}

function conflict(): HttpsError {
  return new HttpsError("aborted",
    "This help request changed. Review it again.");
}
