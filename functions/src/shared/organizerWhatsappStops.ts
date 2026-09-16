import type {Firestore, Transaction} from "firebase-admin/firestore";
import type {OrganizerWhatsappEndpointStopDocument as EndpointStop} from
  "./generated/organizerWhatsappEndpointStopDocument";
import {validateOrganizerWhatsappEndpointStopDocument} from
  "./generated/validators/organizerWhatsappEndpointStopDocument";
import {operationContentHash} from "../operations/durableActions";

export type {EndpointStop};
export const WHATSAPP_ENDPOINT_STOPS = "organizerWhatsappEndpointStops";

export function whatsappStopId(organizerId: string, endpointHash: string) {
  return "wa-stop:" + operationContentHash([organizerId, endpointHash]);
}

export function parseWhatsappStop(value: unknown): EndpointStop {
  if (!validateOrganizerWhatsappEndpointStopDocument(value) ||
      value.stopId !== whatsappStopId(value.organizerId, value.endpointHash) ||
      value.stoppedAt > value.observedAt) {
    throw new Error("Invalid WhatsApp endpoint STOP record");
  }
  return value;
}

/**
 * Only signature-verified ingress calls this, before creating its receipt.
 * The returned commit performs no reads and shares the queue transaction.
 */
export async function prepareWhatsappStop(db: Firestore, tx: Transaction,
  input: Omit<EndpointStop, "schemaVersion" | "revision" | "stopId" |
    "stoppedAt" | "observedAt"> & {occurredAt: number | null; now: number}):
  Promise<() => void> {
  const {now, occurredAt, ...identity} = input;
  if (!Number.isSafeInteger(now) || now < 0) {
    throw new Error("Invalid WhatsApp STOP clock");
  }
  // Recheck the unambiguous sender inside the transaction. The outer webhook
  // lookup is a routing hint and must not authorize a stale tenant mapping.
  const senders = await tx.get(db.collection("organizerSenderConnections")
    .where("provider", "==", "metaCloudApi")
    .where("phoneNumberId", "==", identity.providerPhoneNumberId).limit(2));
  const sender = senders.docs[0]?.data();
  if (senders.docs.length !== 1 || senders.docs[0].id !== input.connectionId ||
      sender?.organizerId !== input.organizerId ||
      sender?.wabaId !== input.providerAccountId ||
      sender?.channel !== "whatsapp") {
    throw new Error("WhatsApp STOP sender changed; retry ingress");
  }
  const stopId = whatsappStopId(input.organizerId, input.endpointHash);
  const ref = db.collection(WHATSAPP_ENDPOINT_STOPS).doc(stopId);
  const snap = await tx.get(ref);
  const previous = snap.exists ? parseWhatsappStop(snap.data()) : null;
  if (previous && (previous.stopId !== stopId || previous.observedAt > now)) {
    throw new Error("WhatsApp STOP identity or clock mismatch");
  }
  // Missing/future provider time cannot put a stop indefinitely in the future.
  const stoppedAt = Number.isSafeInteger(occurredAt) && occurredAt! >= 0 ?
    Math.min(occurredAt!, now) : now;
  if (previous && (previous.stoppedAt > stoppedAt ||
      (previous.stoppedAt === stoppedAt &&
        previous.providerEventId >= input.providerEventId))) return () => {};
  const next = parseWhatsappStop({schemaVersion: 1, stopId, ...identity,
    stoppedAt, observedAt: now, revision: (previous?.revision ?? 0) + 1});
  return () => tx.set(ref, next);
}
