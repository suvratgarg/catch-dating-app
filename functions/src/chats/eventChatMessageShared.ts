import {createHash} from "node:crypto";
import * as admin from "firebase-admin";
import {Timestamp} from "firebase-admin/firestore";
import {HttpsError} from "firebase-functions/v2/https";
import {checkRateLimit} from "../shared/rateLimit";
import {requireDoc} from "../shared/validation";
import {hasBlockingRelationshipInTransaction} from "../safety/blocking";
import type {EventChatMessageDocument as Message, UserProfileDocument} from
  "../shared/generated/firestoreAdminTypes";

export interface EventChatMessageDeps {
  db: () => FirebaseFirestore.Firestore;
  now: () => Timestamp;
  rateLimit: typeof checkRateLimit;
}
export const messageDefaults: EventChatMessageDeps = {
  db: () => admin.firestore(), now: () => Timestamp.now(),
  rateLimit: checkRateLimit,
};
export const chatHash = (value: unknown) => createHash("sha256")
  .update(JSON.stringify(value)).digest("hex");
export const eventChatReactionId = (messageId: string, uid: string) =>
  chatHash([messageId, uid]);
export const emptyReactionCounts = (): Message["reactionCounts"] =>
  ({like: 0, love: 0, laugh: 0, wow: 0, sad: 0, thanks: 0});
export const messageUnavailable = () => new HttpsError("permission-denied",
  "This message is unavailable.");
export function nextChatRevision(actual: number, expected: number): number {
  if (actual !== expected) {
    throw new HttpsError("aborted",
      "The conversation changed. Refresh and retry.");
  }
  if (!Number.isSafeInteger(actual + 1)) throw messageUnavailable();
  return actual + 1;
}

/** Allowlisted identities without CRM data or private proposals. */
export function chatIdentityReader(db: FirebaseFirestore.Firestore,
  tx: FirebaseFirestore.Transaction, viewerUid: string) {
  const cache = new Map<string, Promise<string | null>>();
  return (uid: string): Promise<string | null> => {
    const existing = cache.get(uid);
    if (existing) return existing;
    const result = (async () => {
      const [deleted, user, blocked] = await Promise.all([
        tx.get(db.collection("deletedUsers").doc(uid)),
        tx.get(db.collection("users").doc(uid)),
        hasBlockingRelationshipInTransaction(tx, db, viewerUid, [uid]),
      ]);
      if (deleted.exists || !user.exists || blocked) return null;
      const profile = requireDoc<UserProfileDocument>(user,
        "UserProfileDocument");
      if (profile.deleted === true ||
          (!profile.profileComplete && profile.profileClaimedAt == null)) {
        return null;
      }
      const name = profile.displayName?.trim();
      return name ? name.slice(0, 120) : null;
    })();
    cache.set(uid, result);
    return result;
  };
}

export async function readableChatMessage(message: Message | null,
  eventId: string, organizerId: string,
  identity: (uid: string) => Promise<string | null>) {
  if (!message || message.eventId !== eventId ||
      message.organizerId !== organizerId || message.status !== "visible" ||
      !message.uid || !message.text) return null;
  const name = await identity(message.uid);
  return name === null ? null : {message, name};
}
