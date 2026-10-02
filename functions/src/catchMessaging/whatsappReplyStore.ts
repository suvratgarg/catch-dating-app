import {Timestamp, type Firestore} from "firebase-admin/firestore";
import {HttpsError, type CallableRequest} from "firebase-functions/v2/https";
import {runAssistanceTransaction as transact} from
  "../eventSuccess/operations/transactionCallback";
import {validateCatchCommunicationPreferenceDocument} from
  "../shared/generated/validators/catchCommunicationPreferenceDocument";
import {authorizeCatchReply, assertCatchReplyEnabled, catchEndpointHash,
  catchReplyHash, catchReplyId, catchStopId, CATCH_SUPPORT_WINDOW_MS,
  parseCatchReplyInput, safeMillis, validHash, validProviderId} from
  "./whatsappReply";
import type {CatchGetUser, CatchReplyConfig,
  CatchReplyInput, CatchReplyOperation} from "./whatsappReply";

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
/** Authored domain codecs until the shared schema/codegen owner integrates. */
export function readCatchOperation(value: unknown): CatchReplyOperation {
  const data = value as CatchReplyOperation | undefined;
  const keys = "actorUid,bodyHash,createdAtMillis,deadlineMillis," +
    "deliveryAtMillis,deliveryEventId,deliveryStatus,endpointHash," +
    "inboundEventId,inboundMessageId,inboundTextHash," +
    "materialHash,operationId," +
    "phoneNumberId,providerMessageId,purpose,recipientUid,reviewedAtMillis," +
    "schemaVersion,source,state,updatedAtMillis,wabaId";
  if (!data || Object.keys(data).sort().join(",") !== keys ||
      data.schemaVersion !== 1 || data.purpose !== "serviceSupport" ||
      data.source !== "reviewedInboundSupportRequest" ||
      !validProviderId(data.actorUid) || !validProviderId(data.recipientUid) ||
      !/^[0-9]{1,32}$/u.test(data.wabaId) ||
      !/^[0-9]{1,32}$/u.test(data.phoneNumberId) ||
      !/^cwhe_[a-f0-9]{64}$/u.test(data.inboundEventId) ||
      !validProviderId(data.inboundMessageId) ||
      data.operationId !== catchReplyId(data, data.inboundMessageId) ||
      ![data.bodyHash, data.materialHash, data.inboundTextHash,
        data.endpointHash].every(validHash) ||
      ![data.createdAtMillis, data.updatedAtMillis, data.reviewedAtMillis,
        data.deadlineMillis].every(safeMillis) ||
      data.updatedAtMillis < data.createdAtMillis ||
      data.reviewedAtMillis !== data.createdAtMillis ||
      data.deadlineMillis <= data.createdAtMillis ||
      !["claimed", "unknown", "completed"].includes(data.state) ||
      !["pending", "accepted", "sent", "delivered", "read", "failed"]
        .includes(data.deliveryStatus) ||
      (data.state === "completed" ? !validProviderId(data.providerMessageId) :
        data.providerMessageId !== null) ||
      (data.state === "completed" ? data.deliveryStatus === "pending" :
        data.deliveryStatus !== "pending") ||
      (data.deliveryEventId === null ? data.deliveryAtMillis !== null :
        !/^cwhe_[a-f0-9]{64}$/u.test(data.deliveryEventId) ||
        !safeMillis(data.deliveryAtMillis)) ||
      (["pending", "accepted"].includes(data.deliveryStatus) !==
        (data.deliveryEventId === null))) {
    throw new HttpsError("failed-precondition", "Invalid Catch reply record.");
  }
  return data;
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
      const inbound = readCatchReceipt((await tx.get(this.db.collection(
        CATCH_RECEIPTS).doc(input.inboundEventId))).data());
      const occurredAt = Number(inbound.providerTimestampSeconds) * 1000;
      if (inbound.eventId !== input.inboundEventId ||
          inbound.eventKind !== "inbound" || inbound.messageType !== "text" ||
          inbound.textTruncated || !inbound.text?.trim() ||
          isCatchStopReceipt(inbound) || inbound.wabaId !== config.wabaId ||
          inbound.phoneNumberId !== config.phoneNumberId ||
          "+" + inbound.participantId !== config.recipientE164 ||
          catchReplyHash(inbound.text) !== input.reviewedInboundTextHash ||
          !safeMillis(occurredAt) || occurredAt > inbound.receivedAtMillis ||
          inbound.receivedAtMillis > now ||
          inbound.expiresAt.toMillis() <= now) {
        throw new HttpsError("failed-precondition", "Inbound review changed.");
      }
      const endpointHash = catchEndpointHash(config.recipientE164);
      const operationId = catchReplyId(config, inbound.messageId);
      const operationRef = this.db.collection(CATCH_REPLY_OPERATIONS)
        .doc(operationId);
      const [stop, preference, deleted, existing] = await Promise.all([
        tx.get(this.db.collection(CATCH_ENDPOINT_STOPS)
          .doc(catchStopId(config, endpointHash))),
        tx.get(this.db.collection("catchCommunicationPreferences")
          .doc(config.recipientUid)),
        tx.get(this.db.collection("deletedUsers").doc(config.recipientUid)),
        tx.get(operationRef),
      ]);
      // STOP presence is enough to deny, even if its record is malformed.
      // Catch sender-wide withdrawal is independent of marketing opt-in.
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
      const materialHash = catchReplyHash([config.wabaId, config.phoneNumberId,
        config.recipientUid, endpointHash, config.actorUid, input]);
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
        reviewedAtMillis: now, deadlineMillis, state: "claimed",
        providerMessageId: null, deliveryStatus: "pending",
        deliveryEventId: null,
        deliveryAtMillis: null, createdAtMillis: now, updatedAtMillis: now});
      tx.create(operationRef, operation);
      return {operation, replayed: false};
    });
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
