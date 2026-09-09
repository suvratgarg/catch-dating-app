import type {Firestore, Transaction} from "firebase-admin/firestore";
import type {EventRcsSubscriptionDocument as Subscription} from
  "../../shared/generated/eventRcsSubscriptionDocument";
import {validateEventRcsSubscriptionDocument} from
  "../../shared/generated/validators/eventRcsSubscriptionDocument";
import {operationContentHash} from "../../operations/durableActions";
import {parseRcsCallback, rcsCallbackClock, rcsCallbackCollections,
  RcsCallbackDocument, requireRcsCallbackId} from "./rcsCallbackRecords";

export type {Subscription as RcsSubscription};
export const RCS_SUBSCRIPTIONS = "eventAssistanceRcsSubscriptions";

/** An agent conversation is independent of event and credential rotation. */
export function rcsSubscriptionId(agentId: string, endpointHash: string) {
  if (!/^[A-Za-z0-9][A-Za-z0-9._@-]*$/.test(agentId) ||
      agentId.length > 512 || /\s/.test(agentId) ||
      !/^[a-f0-9]{64}$/.test(endpointHash) || endpointHash.length !== 64) {
    throw invalid();
  }
  return "rcs-subscription:" + operationContentHash([agentId, endpointHash]);
}

export function parseRcsSubscription(value: unknown): Subscription {
  if (!validateEventRcsSubscriptionDocument(value) ||
      value.subscriptionId !== rcsSubscriptionId(value.agentId,
        value.endpointHash) ||
      value.updatedAt !== Math.max(value.lastStop?.observedAt ?? 0,
        value.lastSubscribeRequest?.observedAt ?? 0)) throw invalid();
  for (const item of [value.lastStop, value.lastSubscribeRequest]) {
    if (item) requireRcsCallbackId(item.callbackId);
  }
  return value;
}

/** Facts only: the absence of a stop does not grant event consent. */
export async function readRcsSubscription(db: Firestore, tx: Transaction,
  agentId: string, endpointHash: string, now: number):
  Promise<Subscription | null> {
  rcsCallbackClock(now);
  const id = rcsSubscriptionId(agentId, endpointHash);
  const snap = await tx.get(db.collection(RCS_SUBSCRIPTIONS).doc(id));
  if (!snap.exists) return null;
  const record = parseRcsSubscription(snap.data());
  if (record.subscriptionId !== id || record.updatedAt > now) throw invalid();
  const observations = [
    {requested: "unsubscribe", origin: record.lastStop},
    {requested: "subscribe", origin: record.lastSubscribeRequest},
  ].filter((item) => item.origin !== null);
  // Keep exact callback provenance. A signed STOP remains a restriction even
  // when its provider identity later conflicts; it never becomes a grant.
  const callbacks = await tx.getAll(...observations.map(({origin}) =>
    db.collection(rcsCallbackCollections.callbacks).doc(origin!.callbackId)));
  for (let i = 0; i < observations.length; i++) {
    const {origin, requested} = observations[i];
    const source = parseRcsCallback(callbacks[i].data(), origin!.callbackId);
    if (source.evidence.agentId !== agentId ||
        source.evidence.endpointHash !== endpointHash ||
        source.evidence.observation.kind !== "subscription" ||
        source.evidence.observation.requested !== requested ||
        source.storedAt !== origin!.observedAt) throw invalid();
  }
  return record;
}

/**
 * Called only by the verified inbox, before staged writes. First storage time
 * orders observations; callback id breaks ties. Replays can repair an older
 * inbox record without changing its time or overwriting a newer observation.
 */
export async function prepareRcsSubscription(db: Firestore, tx: Transaction,
  candidate: RcsCallbackDocument, now: number): Promise<() => void> {
  const {evidence, storedAt, callbackId} = parseRcsCallback(candidate,
    candidate.callbackId);
  if (evidence.observation.kind !== "subscription") return () => {};
  const {agentId, endpointHash} = evidence;
  const previous = await readRcsSubscription(db, tx, agentId, endpointHash,
    now);
  if (storedAt > now) throw invalid();
  const subscriptionId = rcsSubscriptionId(agentId, endpointHash);
  const field = evidence.observation.requested === "unsubscribe" ?
    "lastStop" : "lastSubscribeRequest";
  const prior = previous?.[field];
  if (prior && (prior.observedAt > storedAt ||
      (prior.observedAt === storedAt && prior.callbackId >= callbackId))) {
    return () => {};
  }
  const next = parseRcsSubscription({schemaVersion: 1, subscriptionId,
    routeId: "catchEventRcs", agentId, endpointHash,
    revision: (previous?.revision ?? 0) + 1,
    lastStop: previous?.lastStop ?? null,
    lastSubscribeRequest: previous?.lastSubscribeRequest ?? null,
    [field]: {callbackId, observedAt: storedAt},
    updatedAt: Math.max(previous?.updatedAt ?? 0, storedAt)});
  return () => tx.set(db.collection(RCS_SUBSCRIPTIONS).doc(subscriptionId),
    next);
}

function invalid(): Error {
  return new Error("Invalid RCS subscription evidence");
}
