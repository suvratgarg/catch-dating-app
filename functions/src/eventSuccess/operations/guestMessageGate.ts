import type {Firestore, Transaction} from "firebase-admin/firestore";
import type {MessageRecord} from "./messageOutbox";
import type {DispatchGate} from "./messagingPolicy";
import {
  guestCanReceiveMessage, guestCollections, guestIdentity, messageWindowOpen,
  parseGuest, parseThread, readGuestSourceFacts, threadIdentity,
} from "./guestRecords";
import {assistanceMessageId} from "./messageOutbox";

/** Event/roster authority shared by all live channel fact readers. */
export async function readEventAssistanceMessageGate(
  db: Firestore, tx: Transaction, intent: MessageRecord["intent"], now: number
): Promise<DispatchGate> {
  if (intent.context.mode !== "live") {
    return {kind: "stop", reason: "hostStopped"};
  }
  const guestId = guestIdentity(intent.context, intent.attendeeId);
  const threadId = threadIdentity(intent);
  const [guestSnap, threadSnap] = await tx.getAll(
    db.collection(guestCollections.guests).doc(guestId),
    db.collection(guestCollections.threads).doc(threadId),
  );
  if (!guestSnap.exists || !threadSnap.exists) {
    return {kind: "stop", reason: "notAdmitted"};
  }
  const guest = parseGuest(guestSnap.data());
  const thread = parseThread(threadSnap.data());
  if (guest.guestId !== guestId || thread.threadId !== threadId ||
      thread.messageId !== assistanceMessageId(intent) ||
      guest.episodeId !== intent.episodeId) {
    return {kind: "stop", reason: "superseded"};
  }
  const source = await readGuestSourceFacts(db, tx, intent.context,
    intent.attendeeId);
  if (!guestCanReceiveMessage(guest, source, intent)) {
    return {kind: "stop", reason: "notAdmitted"};
  }
  // Event-service consent cannot outlive the current event window after a
  // schedule change, even if its original grant and message remain valid.
  const serviceEnd = Math.floor(source.eventEnd) + 86_400_000;
  if (now >= serviceEnd || !messageWindowOpen(intent, source, now)) {
    return {kind: "stop", reason: "eventClosed"};
  }
  if (intent.kind === "joiningUpdate") {
    if (source.attendeeStatus === "checkedIn") {
      return {kind: "stop", reason: "guestPresent"};
    }
    if (guest.intention.kind === "notComing") {
      return {kind: "stop", reason: "guestDeclined"};
    }
  }
  return {kind: "allow", checkedAt: now,
    validUntil: Math.min(now + 30_000, intent.expiresAt,
      source.eventEnd > now ? source.eventEnd : serviceEnd),
    instructionRevision: intent.kind === "joiningUpdate" ?
      intent.guidance.revision : intent.instructionRevision};
}
