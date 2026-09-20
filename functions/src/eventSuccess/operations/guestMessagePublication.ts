import type {Firestore, Transaction} from "firebase-admin/firestore";
import {HttpsError} from "firebase-functions/v2/https";
import {operationContentHash} from "../../operations/durableActions";
import {joiningGuidanceIsCurrent} from "./groupProgressReader";
import {assistanceMessageId, newMessageRecord, parseMessageRecord} from
  "./messageOutbox";
import {parseMessageIntent} from "./messageProtocol";
import {EVENT_ASSISTANCE_MESSAGES} from "./firestoreMessageOutbox";
import {prepareDeliveryWorkEnqueue} from "./deliveryWorkEnqueue";
import {guestCanReceiveMessage, guestCollections, guestIdentity,
  messageWindowOpen, parseGuest, parseThread, readGuestSourceFacts,
  threadIdentity, unavailable} from "./guestRecords";

/** Read before staging writes; policy and a checkpoint can join the commit. */
export async function prepareGuestMessagePublication(db: Firestore,
  tx: Transaction, value: unknown, expectedThreadRevision: number | null,
  clock: () => number) {
  const readClock = () => {
    const value = clock();
    if (!Number.isSafeInteger(value) || value < 0) throw unavailable();
    return value;
  };
  const intent = parseMessageIntent(value);
  if (intent.context.mode !== "live") throw unavailable();
  const context = intent.context;
  const guestId = guestIdentity(context, intent.attendeeId);
  const threadId = threadIdentity(intent);
  const messageId = assistanceMessageId(intent);
  const threadRef = db.collection(guestCollections.threads)
    .doc(threadId);
  const messageRef = db.collection(EVENT_ASSISTANCE_MESSAGES)
    .doc(messageId);
  const [guestSnap, threadSnap, messageSnap] = await Promise.all([
    tx.get(db.collection(guestCollections.guests).doc(guestId)),
    tx.get(threadRef), tx.get(messageRef),
  ]);
  const guest = parseGuest(guestSnap.data());
  if (guest.guestId !== guestId) throw unavailable();
  const source = await readGuestSourceFacts(db, tx, context,
    intent.attendeeId);
  if (!guestCanReceiveMessage(guest, source, intent) ||
      guest.episodeId !== intent.episodeId) {
    throw unavailable();
  }
  if (!await joiningGuidanceIsCurrent(db, tx, intent, readClock())) {
    throw unavailable();
  }
  const previous = threadSnap.exists ?
    parseThread(threadSnap.data()) : null;
  if (previous && previous.threadId !== threadId) throw unavailable();
  const existing = messageSnap.exists ?
    parseMessageRecord(messageSnap.data()) : null;
  if (existing && operationContentHash(existing.intent) !==
      operationContentHash(intent)) throw conflict();
  if (previous?.messageId === messageId && existing) {
    return {thread: previous, replayed: true, commit: () => undefined};
  }
  if ((previous?.revision ?? null) !== expectedThreadRevision) {
    throw conflict();
  }
  const priorRef = previous ? db.collection(EVENT_ASSISTANCE_MESSAGES)
    .doc(previous.messageId) : null;
  const prior = priorRef ? parseMessageRecord((await tx.get(priorRef))
    .data()) : null;
  if (prior && (prior.messageId !== previous?.messageId ||
      threadIdentity(prior.intent) !== threadId)) throw unavailable();
  const now = readClock();
  if (!messageWindowOpen(intent, source, now)) throw unavailable();
  const message = existing ?? newMessageRecord(intent, now);
  if (message.lifecycle !== "active" || now >= intent.expiresAt) {
    throw unavailable();
  }
  const thread = parseThread({schemaVersion: 1, threadId, guestId, context,
    attendeeId: intent.attendeeId, episodeId: intent.episodeId,
    workflow: intent.workflow, messageId,
    revision: previous ? previous.revision + 1 : 0,
    createdAt: previous?.createdAt ?? now, updatedAt: now});
  const delivery = await prepareDeliveryWorkEnqueue(db, tx, message, now);
  return {thread, replayed: false, commit: () => {
    if (!existing) tx.create(messageRef, message);
    if (priorRef && prior?.lifecycle === "active") {
      tx.set(priorRef, parseMessageRecord({...prior, lifecycle: "superseded",
        revision: prior.revision + 1, updatedAt: now}));
    }
    tx.set(threadRef, thread);
    delivery.commit();
  }};
}

function conflict() {
  return new HttpsError("aborted",
    "Event assistance changed. Refresh and retry.");
}
