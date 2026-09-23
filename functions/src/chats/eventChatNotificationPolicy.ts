import * as admin from "firebase-admin";
import {requireDoc} from "../shared/validation";
import {hasBlockingRelationshipInTransaction} from "../safety/blocking";
import type {EventChatMessageDocument as Message} from
  "../shared/generated/firestoreAdminTypes";
import {requireEventChatMember} from "./eventChatAccess";

export interface EventChatNotificationCandidate {
  eventId: string;
  messageId: string;
  recipientUid: string;
}
export interface EventChatNotificationPreview extends
  EventChatNotificationCandidate {
  title: "Event room update";
  body: "Open the room to see the new message.";
}
interface Deps {
  db: () => FirebaseFirestore.Firestore;
  enabled: boolean;
  sink: (preview: EventChatNotificationPreview) => Promise<void>;
}
const defaults: Deps = {db: () => admin.firestore(), enabled: false,
  sink: async () => undefined};

/** A queued candidate is never an access grant. Read current admission,
 * membership, mute, sender and message state immediately before delivery.
 * Production delivery remains disabled until an approved provider is wired. */
export async function dispatchEventChatNotification(
  candidate: EventChatNotificationCandidate, deps: Deps = defaults
): Promise<boolean> {
  if (!deps.enabled) return false;
  const db = deps.db();
  const deliver = await db.runTransaction(async (tx) => {
    const snap = await tx.get(db.collection("eventChatMessages")
      .doc(candidate.messageId));
    if (!snap.exists) return false;
    const message = requireDoc<Message>(snap, "EventChatMessageDocument");
    if (message.eventId !== candidate.eventId ||
        message.status !== "visible" ||
        message.uid === candidate.recipientUid) return false;
    try {
      const [recipient, sender] = await Promise.all([
        requireEventChatMember(db, tx, candidate.eventId,
          candidate.recipientUid),
        requireEventChatMember(db, tx, candidate.eventId, message.uid!),
      ]);
      const blocked = await hasBlockingRelationshipInTransaction(tx, db,
        candidate.recipientUid, [message.uid!]);
      return !blocked && !recipient.member?.notificationsMuted &&
        recipient.view.organizerId === message.organizerId &&
        sender.view.organizerId === message.organizerId;
    } catch {
      return false;
    }
  });
  if (!deliver) return false;
  await deps.sink({...candidate, title: "Event room update",
    body: "Open the room to see the new message."});
  return true;
}

/** Bounded post-commit seam. Disabled by default; no queue or provider is
 * activated by a message write. A future worker can call this with its
 * approved sink and still gets dispatch-time authority rechecks. */
export async function dispatchEventChatNotificationCandidates(
  message: {eventId: string; messageId: string},
  deps: Deps = defaults
): Promise<number> {
  if (!deps.enabled) return 0;
  const db = deps.db();
  const members = await db.collection("eventChatMemberships")
    .where("eventId", "==", message.eventId).limit(101).get();
  if (members.size > 100) return 0;
  let delivered = 0;
  for (const row of members.docs) {
    const member = row.data();
    if (member.status !== "joined" || typeof member.uid !== "string") {
      continue;
    }
    if (await dispatchEventChatNotification({...message,
      recipientUid: member.uid}, deps)) delivered++;
  }
  return delivered;
}
