import {Timestamp, type Firestore} from "firebase-admin/firestore";
import {HttpsError, type CallableRequest} from "firebase-functions/v2/https";
import {runAssistanceTransaction as transact} from
  "../eventSuccess/operations/transactionCallback";
import {isWhatsappStopCommand} from "../organizers/organizerCampaignModel";
import {validateCatchWhatsappWebhookEventDocument} from
  "../shared/generated/validators/catchWhatsappWebhookEventDocument";
import {validateCatchCommunicationPreferenceDocument} from
  "../shared/generated/validators/catchCommunicationPreferenceDocument";
import {WEBHOOK_RETENTION_MILLIS, type CatchWebhookEvent} from
  "./whatsappWebhookProtocol";
import {authorizeCatchReply, assertCatchReplyEnabled, catchEndpointHash,
  catchReplyHash, catchReplyId, catchStopId, CATCH_SUPPORT_WINDOW_MS,
  parseCatchReplyInput, safeMillis, validHash, validProviderId} from
  "./whatsappReply";
import type {CatchEndpointStop, CatchGetUser, CatchReplyConfig,
  CatchReplyInput, CatchReplyOperation} from "./whatsappReply";

export const CATCH_REPLY_OPERATIONS = "catchWhatsappReplyOperations";
export const CATCH_ENDPOINT_STOPS = "catchWhatsappEndpointStops";
export const CATCH_RECEIPTS = "catchWhatsappWebhookEvents";
export type CatchReceipt = CatchWebhookEvent & {
  receivedAtMillis: number; expiresAt: Timestamp;
};

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
export function readCatchReceipt(value: unknown): CatchReceipt {
  const data = value as CatchReceipt | undefined;
  if (!data || !(data.expiresAt instanceof Timestamp) ||
      !validateCatchWhatsappWebhookEventDocument(serialized(data))) {
    throw new HttpsError("failed-precondition", "Invalid Catch receipt.");
  }
  return data;
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
export function readCatchStop(value: unknown): CatchEndpointStop {
  const data = value as CatchEndpointStop | undefined;
  if (!data || Object.keys(data).sort().join(",") !==
      "endpointHash,observedAtMillis,payloadHash,phoneNumberId,schemaVersion," +
      "sourceEventId,sourceMessageId,stopId,wabaId" ||
      data.schemaVersion !== 1 || !validHash(data.endpointHash) ||
      !validHash(data.payloadHash) || !safeMillis(data.observedAtMillis) ||
      !/^[0-9]{1,32}$/u.test(data.wabaId) ||
      !/^[0-9]{1,32}$/u.test(data.phoneNumberId) ||
      !/^cwhe_[a-f0-9]{64}$/u.test(data.sourceEventId) ||
      !validProviderId(data.sourceMessageId) ||
      data.stopId !== catchStopId(data, data.endpointHash)) {
    throw new HttpsError("failed-precondition", "Invalid Catch suppression.");
  }
  return data;
}

/** Never classify truncated text or interactive display labels as STOP. */
export function isCatchStopReceipt(event: CatchWebhookEvent): boolean {
  return event.eventKind === "inbound" && event.messageType === "text" &&
    !event.textTruncated && typeof event.text === "string" &&
    /^[1-9][0-9]{6,14}$/u.test(event.participantId) &&
    isWhatsappStopCommand(event.text);
}

/**
 * Future ingress hook ONLY AFTER signature and exact configured sender checks.
 * Not yet called by whatsappWebhook.ts: sending must remain gated until the
 * receiver owner wires this and reconciles historical STOP receipts. Existing
 * receipt bytes/TTL never change. The separate suppression has no TTL/reset.
 */
export async function persistCatchStopReceipt(db: Firestore,
  event: CatchWebhookEvent, nowMillis: number): Promise<void> {
  if (!safeMillis(nowMillis) || !isCatchStopReceipt(event)) {
    throw new Error("Expected a verified Catch text STOP");
  }
  const incoming = readCatchReceipt({...event, receivedAtMillis: nowMillis,
    expiresAt: Timestamp.fromMillis(nowMillis + WEBHOOK_RETENTION_MILLIS)});
  await transact(db, async (tx) => {
    const ref = db.collection(CATCH_RECEIPTS).doc(event.eventId);
    const previous = await tx.get(ref);
    const receipt = previous.exists ? readCatchReceipt(previous.data()) :
      incoming;
    if (!isCatchStopReceipt(receipt) || receipt.eventId !== event.eventId ||
        receipt.wabaId !== event.wabaId ||
        receipt.phoneNumberId !== event.phoneNumberId ||
        receipt.participantId !== event.participantId ||
        receipt.messageId !== event.messageId || receipt.text !== event.text ||
        receipt.providerTimestampSeconds !== event.providerTimestampSeconds) {
      throw new Error("Catch STOP receipt identity conflict");
    }
    const endpointHash = catchEndpointHash("+" + receipt.participantId);
    const stopId = catchStopId(receipt, endpointHash);
    const stopRef = db.collection(CATCH_ENDPOINT_STOPS).doc(stopId);
    const stop = await tx.get(stopRef);
    if (stop.exists) {
      if (readCatchStop(stop.data()).stopId !== stopId) {
        throw new Error("Catch suppression identity conflict");
      }
    } else {
      tx.create(stopRef, readCatchStop({schemaVersion: 1, stopId,
        wabaId: receipt.wabaId, phoneNumberId: receipt.phoneNumberId,
        endpointHash, sourceEventId: receipt.eventId,
        sourceMessageId: receipt.messageId, payloadHash: receipt.payloadHash,
        observedAtMillis: receipt.receivedAtMillis}));
    }
    if (!previous.exists) tx.create(ref, incoming);
  });
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
