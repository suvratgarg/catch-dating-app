import {HttpsError} from "firebase-functions/v2/https";
import type {Firestore, Transaction} from "firebase-admin/firestore";
import {operationContentHash} from "../../operations/durableActions";
import {validateGetEventAssistanceCheckpointCallablePayload} from
  "../../shared/generated/validators/getEventAssistanceCheckpointInput";
import {validateRecordEventAssistanceCheckpointCallablePayload} from
  "../../shared/generated/validators/recordEventAssistanceCheckpointInput";
import {validateEventAssistanceCheckpointReceiptDocument} from
  "../../shared/generated/validators/eventAssistanceCheckpointReceiptDocument";
import {assertCommandContext, assertCommandRole} from "./commands";
import {requireGroupPermission, denied} from "./groupStaffAuthority";
import {invalidSource} from "./groupProgressSource";
import {readCheckpoint} from "./checkpointReader";
import {runAssistanceTransaction} from "./transactionCallback";
import {CHECKPOINTS, CHECKPOINT_RECEIPTS, checkpointIdentity,
  checkpointAvailability, checkpointSourceHash, checkpointResponse,
  checkpointConflict, parseCheckpointReport, Response, Scope, Report} from
  "./checkpointRecords";

/** Observations at one saved stop; no attendance or movement inference. */
export class EventCheckpointStore {
  constructor(private readonly db: Firestore,
    private readonly clock: () => number = Date.now) {}

  async get(actorUid: string, input: unknown): Promise<Response> {
    if (!validateGetEventAssistanceCheckpointCallablePayload(input)) {
      throw new HttpsError("invalid-argument", "Invalid checkpoint scope.");
    }
    return runAssistanceTransaction(this.db, async (tx) =>
      checkpointResponse("read", await this.read(tx, actorUid, input)));
  }

  async record(actorUid: string, input: unknown): Promise<Response> {
    if (!validateRecordEventAssistanceCheckpointCallablePayload(input) ||
        input.command.context.mode !== "live") {
      throw new HttpsError("invalid-argument", "Invalid checkpoint report.");
    }
    const {command} = input;
    const {context, payload} = command;
    if (context.mode !== "live") throw invalidSource();
    try {
      assertCommandContext(command, context);
    } catch {
      throw new HttpsError("invalid-argument", "Checkpoint context mismatch.");
    }
    const scope: Scope = {context, groupId: payload.groupId,
      checkpointId: payload.checkpointId,
      progressRevision: payload.expectedProgressRevision};
    if (!validateGetEventAssistanceCheckpointCallablePayload(scope)) {
      throw new HttpsError("invalid-argument", "Choose a recorded departure.");
    }
    const requestHash = operationContentHash([actorUid, input]);
    const receiptId = "checkpoint-action:" + operationContentHash([
      context, payload.groupId, command.operationId]);
    return runAssistanceTransaction(this.db, async (tx) => {
      const s = await this.read(tx, actorUid, scope);
      assertCommandRole(command, [s.access.role]);
      const receiptRef = this.db.collection(CHECKPOINT_RECEIPTS).doc(receiptId);
      const receipt = (await tx.get(receiptRef)).data();
      const now = this.clock();
      if (!Number.isSafeInteger(now) || now < s.now) throw invalidSource();
      if (now >= s.access.validUntil) throw denied();
      s.now = now;
      if (receipt !== undefined) {
        if (!validateEventAssistanceCheckpointReceiptDocument(receipt) ||
            receipt.receiptId !== receiptId ||
            receipt.requestHash !== requestHash || !s.report ||
            receipt.report.revision > s.report.revision ||
            receipt.report.createdAt !== s.report.createdAt) {
          throw checkpointConflict();
        }
        const original = parseCheckpointReport(receipt.report, scope,
          s.roster, now)!;
        if (original.revision !== payload.expectedCheckpointRevision + 1 ||
            original.reportedBy !== actorUid ||
            original.reportedAt > s.report.reportedAt ||
            original.correctionReason !==
              (payload.correctionReason?.trim() ?? null) ||
            operationContentHash(original.accountedFor) !==
              operationContentHash([...payload.accountedFor].sort()) ||
            original.revision === s.report.revision &&
              operationContentHash(original) !==
                operationContentHash(s.report)) {
          throw checkpointConflict();
        }
        return checkpointResponse("replayed", s, original.revision);
      }
      if (input.expectedSourceHash !== checkpointSourceHash(s) ||
          payload.expectedCheckpointRevision !== (s.report?.revision ?? 0)) {
        throw checkpointConflict();
      }
      const availability = checkpointAvailability(s);
      if (availability.kind !== "ready") {
        throw new HttpsError("failed-precondition",
          "This departure has no current checkpoint roster.");
      }
      const accountedFor = [...payload.accountedFor].sort();
      const prior = new Set(s.report?.accountedFor ?? []);
      for (const id of accountedFor) {
        const member = availability.members.find((m) => m.attendeeId === id);
        if (!member || !prior.has(id) && member.visit.kind !== "current") {
          throw new HttpsError("failed-precondition",
            "New observations must match a guest's original departure visit.");
        }
      }
      const correctionReason = payload.correctionReason?.trim() ?? null;
      if ([...prior].some((id) => !accountedFor.includes(id)) &&
          !correctionReason) {
        throw new HttpsError("failed-precondition",
          "Explain why a previously recorded guest is being removed.");
      }
      const report: Report = {schemaVersion: 1,
        reportId: checkpointIdentity(scope), ...scope,
        rosterId: s.roster!.rosterId,
        rosterHash: operationContentHash(s.roster),
        revision: (s.report?.revision ?? 0) + 1, accountedFor,
        reportedBy: actorUid, reportedAt: now, correctionReason,
        createdAt: s.report?.createdAt ?? now};
      parseCheckpointReport(report, scope, s.roster, now);
      const saved = {receiptId, requestHash, report};
      if (!validateEventAssistanceCheckpointReceiptDocument(saved)) {
        throw invalidSource();
      }
      const result = checkpointResponse("applied", {...s, report},
        report.revision);
      tx.set(this.db.collection(CHECKPOINTS).doc(report.reportId), report);
      tx.create(receiptRef, saved);
      return result;
    });
  }

  private async read(tx: Transaction, actorUid: string, scope: Scope) {
    const access = await requireGroupPermission(this.db, tx, scope.context,
      scope.groupId, actorUid, "recordCheckpoint", this.clock);
    const s = await readCheckpoint(this.db, tx, scope, this.clock);
    const now = this.clock();
    if (!Number.isSafeInteger(now) || now < s.now) throw invalidSource();
    if (now >= access.validUntil) throw denied();
    return {...s, now, access};
  }
}
