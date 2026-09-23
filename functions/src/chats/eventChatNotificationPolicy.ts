import * as admin from "firebase-admin";
import {requireDoc} from "../shared/validation";
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
      return !recipient.member?.notificationsMuted &&
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
