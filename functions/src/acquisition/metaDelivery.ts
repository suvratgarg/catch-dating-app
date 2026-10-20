import {randomUUID} from "node:crypto";
import {Timestamp, type Firestore} from "firebase-admin/firestore";
import type {HostAcquisitionDeliveryDocument} from
  "../shared/generated/hostAcquisitionDeliveryDocument";
import {validateHostAcquisitionDeliveryDocument} from
  "../shared/generated/validators/hostAcquisitionDeliveryDocument";
import {validateHostAcquisitionConsentDocument} from
  "../shared/generated/validators/hostAcquisitionConsentDocument";
import {HOST_CONSENT_COLLECTION} from "./consentStore";
import {
  hasCurrentHostConsent, hostMetaDispatchDecision,
  HOST_META_DELIVERY_LIFETIME_MS, HOST_META_MAX_ATTEMPTS,
} from "./consentPolicy";
import {
  classifyHostMetaResponse, hostMetaLeadPayload, type HostMetaLeadPayload,
} from "./metaPayload";

export const HOST_DELIVERY_COLLECTION = "hostAcquisitionDeliveries";
type Delivery = HostAcquisitionDeliveryDocument;

/** Context and receipts expire together, including stopped/uncertain rows.
 * This is independent of the delivery gate and requires no remote TTL setup. */
export async function expireHostMetaDeliveries(db: Firestore,
  now = Date.now()): Promise<number> {
  const rows = await db.collection(HOST_DELIVERY_COLLECTION)
    .where("expiresAt", "<=", Timestamp.fromMillis(now)).limit(500).get();
  let removed = 0;
  for (const row of rows.docs) {
    if (await db.runTransaction(async (tx) => {
      const snap = await tx.get(row.ref);
      const data = snap.data();
      if (!validateHostAcquisitionDeliveryDocument(data) ||
          data.eventId !== row.id ||
          data.acceptedAt + HOST_META_DELIVERY_LIFETIME_MS > now) return false;
      tx.delete(row.ref);
      return true;
    })) removed++;
  }
  return removed;
}

/** Called inside the accepting lead transaction, after all its reads.
 * Only an authoritative NEW Host receipt can create a delivery. The caller
 * supplies the current consent read in that same transaction. */
export function prepareHostMetaDelivery(input: {
  enabled: boolean;
  eventId: string;
  isNew: boolean;
  intentId: string;
  consentId: string;
  consentDocument: unknown;
  context: unknown;
  now: number;
}): Delivery | null {
  if (!input.enabled || !input.isNew) return null;
  const consent = input.consentDocument;
  if (!validateHostAcquisitionConsentDocument(consent) ||
      consent.consentId !== input.consentId || consent.status !== "active" ||
      !hasCurrentHostConsent(consent.authority, input.now, "advertising")) {
    return null;
  }
  const acceptedAt = Number(input.eventId.split("_")[2]);
  const state = {eventId: input.eventId, acceptedAt,
    status: "pending" as const, attempts: 0, nextAttemptAt: input.now};
  if (acceptedAt < consent.authority.acceptedAt) return null;
  const payload = hostMetaLeadPayload({enabled: true, state,
    consent: consent.authority, context: input.context, now: input.now});
  if (!payload) return null;
  const context = input.context as NonNullable<Delivery["context"]>;
  // Preserve only the same allowlisted browser data used by the projection.
  const safeContext: NonNullable<Delivery["context"]> = {
    clientId: context.clientId, userAgent: context.userAgent,
    ...(payload.user_data.fbc ? {fbclid: context.fbclid,
      clickCapturedAt: context.clickCapturedAt} : {}),
  };
  const row = {...state, schemaVersion: 1, classification: "sales_private",
    intentId: input.intentId, consentId: input.consentId,
    attemptId: null, lastAttemptAt: null, context: safeContext,
    expiresAt: Timestamp.fromMillis(
      acceptedAt + HOST_META_DELIVERY_LIFETIME_MS),
  };
  return validateHostAcquisitionDeliveryDocument(row) ? row : null;
}

/** Read both authorities each time. Removing the intake record or withdrawing
 * permission prevents queued delivery; a stored snapshot is insufficient. */
async function authorities(tx: FirebaseFirestore.Transaction,
  db: Firestore, row: Delivery, now: number) {
  const [permission, intent] = await Promise.all([
    tx.get(db.collection(HOST_CONSENT_COLLECTION).doc(row.consentId)),
    tx.get(db.collection("salesInboundIntents").doc(row.intentId)),
  ]);
  const consent = permission.data();
  const lead = intent.data();
  if (!validateHostAcquisitionConsentDocument(consent) ||
      consent.consentId !== row.consentId || consent.status !== "active" ||
      !hasCurrentHostConsent(consent.authority, now, "advertising") ||
      consent.authority.acceptedAt > row.acceptedAt ||
      lead?.classification !== "sales_private" ||
      lead.source !== "website" || lead.hostLead?.isNew !== true ||
      lead.hostLead.eventId !== row.eventId) return null;
  return consent.authority;
}

/** Exactly one worker reserves an attempt. An interrupted send becomes unknown
 * and is never automatically resent. No network call runs in a transaction.
 * The sender uses a fixed endpoint and a timeout below 60 seconds. */
export async function deliverHostMetaLead(input: {
  db: Firestore;
  eventId: string;
  enabled: boolean;
  send: (payload: HostMetaLeadPayload) =>
    Promise<{status: number; body: unknown}>;
  now?: () => number;
}): Promise<
  "disabled" | "idle" | "accepted" | "pending" | "unknown" | "stopped"
> {
  if (!input.enabled) return "disabled";
  const now = input.now ?? Date.now;
  const ref = input.db.collection(HOST_DELIVERY_COLLECTION).doc(input.eventId);
  const attemptId = randomUUID();
  const reserved = await input.db.runTransaction(async (tx) => {
    const snap = await tx.get(ref);
    const row = snap.data();
    if (!validateHostAcquisitionDeliveryDocument(row) ||
        row.eventId !== input.eventId) return null;
    const clock = now();
    if (row.status === "sending") {
      if (row.lastAttemptAt !== null && clock - row.lastAttemptAt >= 60_000) {
        tx.update(ref, {status: "unknown", context: null});
      }
      return null;
    }
    if (row.status !== "pending") return null;
    const consent = await authorities(tx, input.db, row, clock);
    const decision = hostMetaDispatchDecision({enabled: true,
      consent, state: row, now: clock});
    if (decision.kind === "wait") return null;
    const payload = decision.kind === "dispatch" ? hostMetaLeadPayload({
      enabled: true, consent, state: row, context: row.context, now: clock,
    }) : null;
    if (!payload) {
      tx.update(ref, {status: "stopped", context: null}); return null;
    }
    tx.update(ref, {status: "sending", attempts: row.attempts + 1,
      attemptId, lastAttemptAt: clock});
    return {payload, row};
  });
  if (!reserved) return "idle";
  // Withdrawal and deletion can occur after reservation. Check again as the
  // last awaited authority step before dispatch, without claiming atomicity
  // across Firestore and the external provider.
  const permitted = await input.db.runTransaction(async (tx) => {
    const snap = await tx.get(ref);
    const row = snap.data();
    if (!validateHostAcquisitionDeliveryDocument(row) ||
        row.status !== "sending" || row.attemptId !== attemptId) return false;
    const consent = await authorities(tx, input.db, row, now());
    if (!consent || now() - row.acceptedAt >= HOST_META_DELIVERY_LIFETIME_MS) {
      tx.update(ref, {status: "stopped", context: null}); return false;
    }
    return true;
  });
  if (!permitted) return "stopped";
  let outcome: ReturnType<typeof classifyHostMetaResponse>;
  try {
    const response = await input.send(reserved.payload);
    outcome = classifyHostMetaResponse(response.status, response.body);
  } catch {
    outcome = {kind: "unknown"};
  }
  return input.db.runTransaction(async (tx) => {
    const snap = await tx.get(ref);
    const row = snap.data();
    if (!validateHostAcquisitionDeliveryDocument(row) ||
        row.status !== "sending" || row.attemptId !== attemptId) {
      return "unknown";
    }
    const clock = now();
    const consent = await authorities(tx, input.db, row, clock);
    const retry = outcome.kind === "rejected" && outcome.retryable && consent &&
      row.attempts < HOST_META_MAX_ATTEMPTS &&
      clock + 60_000 * 2 ** row.attempts <
        row.acceptedAt + HOST_META_DELIVERY_LIFETIME_MS;
    const status = outcome.kind === "accepted" ? "accepted" :
      outcome.kind === "unknown" ? "unknown" : retry ? "pending" : "stopped";
    tx.update(ref, {status, context: retry ? row.context : null,
      nextAttemptAt: retry ? clock + 60_000 * 2 ** row.attempts : clock});
    return status;
  });
}
