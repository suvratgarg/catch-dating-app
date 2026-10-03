import {Timestamp, type Firestore, type Transaction} from
  "firebase-admin/firestore";
import {HttpsError, type CallableRequest} from "firebase-functions/v2/https";
import {runAssistanceTransaction as transact} from
  "../eventSuccess/operations/transactionCallback";
import {validateCatchCommunicationPreferenceDocument} from
  "../shared/generated/validators/catchCommunicationPreferenceDocument";
import {authorizeCatchReply, assertCatchReplyEnabled, catchEndpointHash,
  catchReplyHash, catchReplyId, catchStopId, CATCH_SUPPORT_WINDOW_MS,
  parseCatchReplyInput, safeMillis, validProviderId} from
  "./whatsappReply";
import type {CatchGetUser, CatchReplyConfig,
  CatchReplyInput, CatchReplyOperation} from "./whatsappReply";

import {validateCatchWhatsappReplyOperationDocument} from
  "../shared/generated/validators/catchWhatsappReplyOperationDocument";
import {validateCatchWhatsappReplyReadinessDocument} from
  "../shared/generated/validators/catchWhatsappReplyReadinessDocument";
import {adminRolesFromToken} from "../admin/adminAuth";
import type {CatchReceipt} from "./whatsappEndpointStops";

export const CATCH_REPLY_READINESS = "catchWhatsappReplyReadiness";
export const catchReadinessId = (config: CatchReplyConfig): string =>
  "cwready_" + catchReplyHash([config.wabaId, config.phoneNumberId,
    catchEndpointHash(config.recipientE164)]);

export const CATCH_REPLY_OPERATIONS = "catchWhatsappReplyOperations";
export {CATCH_ENDPOINT_STOPS, CATCH_RECEIPTS, readCatchReceipt,
  persistCatchStopReceipt} from "./whatsappEndpointStops";
import {CATCH_ENDPOINT_STOPS, CATCH_RECEIPTS, readCatchReceipt,
  isCatchStopReceipt} from "./whatsappEndpointStops";

function serialized(value: unknown): unknown {
  if (value instanceof Timestamp) {
    return {_seconds: value.seconds,
      _nanoseconds: value.nanoseconds};
  }
  if (Array.isArray(value)) return value.map(serialized);
  if (value && typeof value === "object") {
    return Object.fromEntries(
      Object.entries(value).map(([key, entry]) => [key, serialized(entry)]));
  }
  return value;
}
/** Canonical shape validation with domain relational invariants. */
export function readCatchOperation(value: unknown): CatchReplyOperation {
  if (!validateCatchWhatsappReplyOperationDocument(value) ||
      value.operationId !== catchReplyId(value, value.inboundMessageId) ||
      value.updatedAtMillis < value.createdAtMillis ||
      value.reviewedAtMillis !== value.createdAtMillis ||
      value.deadlineMillis <= value.createdAtMillis) {
    throw new HttpsError("failed-precondition", "Invalid Catch reply record.");
  }
  return value;
}
export class CatchWhatsappReplyStore {
  constructor(readonly db: Firestore, private readonly deps: {
    config: () => CatchReplyConfig;
    getUser: CatchGetUser;
    now: () => number;
  }) {}

  async claim(request: CallableRequest<unknown>, input: CatchReplyInput,
    expectedConfig: CatchReplyConfig): Promise<{
      operation: CatchReplyOperation; replayed: boolean;
    }> {
    input = parseCatchReplyInput(input);
    return transact(this.db, async (tx) => {
      const config = {...this.deps.config()};
      assertCatchReplyEnabled(config);
      if (catchReplyHash(config) !== catchReplyHash(expectedConfig)) {
        throw new HttpsError("aborted", "Controlled reply scope changed.");
      }
      await authorizeCatchReply(request, config, this.deps.getUser);
      const now = this.deps.now();
      if (!safeMillis(now)) throw new Error("Invalid reply clock");
      const inbound = await this.readEligibleInbound(tx, request,
        input.inboundEventId, config, now);
      if (catchReplyHash(inbound.text) !== input.reviewedInboundTextHash) {
        throw new HttpsError("failed-precondition", "Inbound review changed.");
      }
      const occurredAt = Number(inbound.providerTimestampSeconds) * 1000;
      const endpointHash = catchEndpointHash(config.recipientE164);
      const operationId = catchReplyId(config, inbound.messageId);
      const operationRef = this.db.collection(CATCH_REPLY_OPERATIONS)
        .doc(operationId);
      const existing = await tx.get(operationRef);
      const materialHash = catchReplyHash([config.wabaId, config.phoneNumberId,
        config.recipientUid, endpointHash, config.actorUid,
        config.readinessEvidenceHash, input]);
      if (existing.exists) {
        const operation = readCatchOperation(existing.data());
        if (operation.operationId !== operationId ||
            operation.materialHash !== materialHash) {
          throw new HttpsError("already-exists",
            "Inbound reply already claimed.");
        }
        if (operation.state !== "completed") {
          throw new HttpsError("failed-precondition",
            "Reply attempt consumed.");
        }
        return {operation, replayed: true};
      }
      const deadlineMillis = occurredAt + CATCH_SUPPORT_WINDOW_MS;
      if (!safeMillis(deadlineMillis) || now >= deadlineMillis) {
        throw new HttpsError("failed-precondition",
          "Support reply window closed.");
      }
      const operation = readCatchOperation({schemaVersion: 1, operationId,
        purpose: "serviceSupport", source: "reviewedInboundSupportRequest",
        wabaId: config.wabaId, phoneNumberId: config.phoneNumberId,
        recipientUid: config.recipientUid, endpointHash,
        actorUid: config.actorUid,
        inboundEventId: inbound.eventId, inboundMessageId: inbound.messageId,
        inboundTextHash: input.reviewedInboundTextHash,
        bodyHash: catchReplyHash(input.body), materialHash,
        readinessEvidenceHash: config.readinessEvidenceHash,
        reviewedAtMillis: now, deadlineMillis, state: "claimed",
        providerMessageId: null, deliveryStatus: "pending",
        deliveryEventId: null,
        deliveryAtMillis: null, createdAtMillis: now, updatedAtMillis: now});
      tx.create(operationRef, operation);
      return {operation, replayed: false};
    });
  }

  async review(request: CallableRequest<unknown>, inboundEventId: string,
    expectedConfig: CatchReplyConfig) {
    return transact(this.db, async (tx) => {
      const config = {...this.deps.config()};
      if (catchReplyHash(config) !== catchReplyHash(expectedConfig)) {
        throw new HttpsError("aborted", "Controlled reply scope changed.");
      }
      const now = this.deps.now();
      const inbound = await this.readEligibleInbound(tx, request,
        inboundEventId, config, now);
      const deadlineMillis = Number(inbound.providerTimestampSeconds) * 1000 +
        CATCH_SUPPORT_WINDOW_MS;
      if (now >= deadlineMillis) {
        throw new HttpsError("failed-precondition",
          "Support reply window closed.");
      }
      return {purpose: "serviceSupport" as const, inboundEventId,
        inboundText: inbound.text!, reviewedInboundTextHash:
          catchReplyHash(inbound.text), deadlineMillis};
    });
  }

  private async readEligibleInbound(tx: Transaction,
    request: CallableRequest<unknown>, inboundEventId: string,
    config: CatchReplyConfig, now: number): Promise<CatchReceipt> {
    await authorizeCatchReply(request, config, this.deps.getUser);
    if (!safeMillis(now)) throw new Error("Invalid reply clock");
    const inbound = readCatchReceipt((await tx.get(this.db.collection(
      CATCH_RECEIPTS).doc(inboundEventId))).data());
    const occurredAt = Number(inbound.providerTimestampSeconds) * 1000;
    if (inbound.eventId !== inboundEventId ||
        inbound.eventKind !== "inbound" || inbound.messageType !== "text" ||
        inbound.textTruncated || !inbound.text?.trim() ||
        isCatchStopReceipt(inbound) || inbound.wabaId !== config.wabaId ||
        inbound.phoneNumberId !== config.phoneNumberId ||
        "+" + inbound.participantId !== config.recipientE164 ||
        !safeMillis(occurredAt) || occurredAt > inbound.receivedAtMillis ||
        inbound.receivedAtMillis > now || inbound.expiresAt.toMillis() <= now) {
      throw new HttpsError("failed-precondition", "Inbound review changed.");
    }
    const endpointHash = catchEndpointHash(config.recipientE164);
    const [stop, preference, deleted, readiness] = await Promise.all([
      tx.get(this.db.collection(CATCH_ENDPOINT_STOPS)
        .doc(catchStopId(config, endpointHash))),
      tx.get(this.db.collection("catchCommunicationPreferences")
        .doc(config.recipientUid)),
      tx.get(this.db.collection("deletedUsers").doc(config.recipientUid)),
      tx.get(this.db.collection(CATCH_REPLY_READINESS)
        .doc(catchReadinessId(config))),
    ]);
    if (stop.exists || deleted.exists) {
      throw new HttpsError("failed-precondition",
        "Catch replies suppressed.");
    }
    if (preference.exists) {
      const value = serialized(preference.data());
      if (!validateCatchCommunicationPreferenceDocument(value) ||
          value.uid !== config.recipientUid ||
          value.whatsapp.status === "optedOut") {
        throw new HttpsError("failed-precondition",
          "Catch replies suppressed.");
      }
    }
    const proof = readiness.data();
    if (!validateCatchWhatsappReplyReadinessDocument(proof) ||
        proof.readinessId !== catchReadinessId(config) ||
        proof.wabaId !== config.wabaId ||
        proof.phoneNumberId !== config.phoneNumberId ||
        proof.recipientUid !== config.recipientUid ||
        proof.endpointHash !== endpointHash || proof.state !== "ready" ||
        proof.evidenceSha256 !== config.readinessEvidenceHash ||
        proof.atomicIngressStartedAtMillis > inbound.receivedAtMillis ||
        proof.coveredThroughMillis < proof.atomicIngressStartedAtMillis ||
        proof.coveredThroughMillis > proof.reviewedAtMillis ||
        proof.reviewedAtMillis > now || proof.expiresAtMillis <= now ||
        proof.expiresAtMillis <= proof.reviewedAtMillis ||
        proof.expiresAtMillis - proof.reviewedAtMillis >
          CATCH_SUPPORT_WINDOW_MS) {
      throw new HttpsError("failed-precondition",
        "Catch reply readiness required.");
    }
    const reviewer = await this.deps.getUser(proof.reviewedByUid);
    if (reviewer.disabled ||
        !adminRolesFromToken(reviewer.customClaims).includes("adminOwner")) {
      throw new HttpsError("failed-precondition",
        "Current readiness owner required.");
    }
    return inbound;
  }

  async complete(claim: CatchReplyOperation, providerMessageId: string):
    Promise<CatchReplyOperation> {
    if (!validProviderId(providerMessageId)) {
      throw new Error("Invalid message id");
    }
    return transact(this.db, async (tx) => {
      const ref = this.db.collection(CATCH_REPLY_OPERATIONS)
        .doc(claim.operationId);
      const current = readCatchOperation((await tx.get(ref)).data());
      if (current.materialHash !== claim.materialHash ||
          current.operationId !== claim.operationId ||
          current.state === "unknown" || (current.providerMessageId !== null &&
            current.providerMessageId !== providerMessageId)) {
        throw new Error("Reply claim changed");
      }
      if (current.state === "completed") return current;
      const next = readCatchOperation({...current, state: "completed",
        providerMessageId, deliveryStatus: "accepted",
        updatedAtMillis: this.deps.now()});
      tx.update(ref, {state: next.state, providerMessageId,
        deliveryStatus: next.deliveryStatus,
        updatedAtMillis: next.updatedAtMillis});
      return next;
    });
  }

  async markUnknown(claim: CatchReplyOperation): Promise<void> {
    await transact(this.db, async (tx) => {
      const ref = this.db.collection(CATCH_REPLY_OPERATIONS)
        .doc(claim.operationId);
      const current = readCatchOperation((await tx.get(ref)).data());
      if (current.operationId !== claim.operationId ||
          current.materialHash !== claim.materialHash) {
        throw new Error("Reply claim changed");
      }
      if (current.state !== "claimed") return;
      const next = readCatchOperation({...current, state: "unknown",
        updatedAtMillis: this.deps.now()});
      tx.update(ref, {state: next.state,
        updatedAtMillis: next.updatedAtMillis});
    });
  }
}
