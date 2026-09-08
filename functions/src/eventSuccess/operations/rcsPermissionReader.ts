import type {Firestore, Transaction} from "firebase-admin/firestore";
import {GuestSourceFacts, guestSourceFactsFromSnapshots} from "./guestRecords";
import {rcsCallbackClock} from "./rcsCallbackRecords";
import {RcsConfig, parseRcsConfig, rcsPhoneHash} from "./rcsProtocol";
import {readRcsSubscription, RcsSubscription} from "./rcsSubscriptions";
import {Permission, rcsConsentCollections, rcsPermissionId,
  parseRcsPermission, parseRcsConsentReceipt, rcsPermissionHasReceipt,
  rcsPermissionClearsStop} from "./rcsConsent";

export type RcsPermissionScope = {context: Permission["context"];
  attendeeId: string; senderId: string};
export type RcsPermissionResult =
  | {kind: "blocked"; reason: "missingPermission" | "suppressed"}
  | {kind: "allowed"; permission: Extract<Permission, {status: "granted"}>;
      source: GuestSourceFacts;
      subscription: RcsSubscription | null};

/** Shared consent facts for planning and final dispatch transactions. */
export async function readRcsMessagePermission(db: Firestore, tx: Transaction,
  scope: RcsPermissionScope, config: RcsConfig, now: number):
  Promise<RcsPermissionResult> {
  rcsCallbackClock(now);
  parseRcsConfig(config);
  const missing: RcsPermissionResult = {kind: "blocked",
    reason: "missingPermission"};
  const suppressed: RcsPermissionResult = {kind: "blocked",
    reason: "suppressed"};
  const {context, attendeeId, senderId} = scope;
  if (context.mode !== "live" || senderId !== config.senderId) return missing;
  const id = rcsPermissionId(context, attendeeId, senderId);
  const [permissionSnap, eventSnap, attendeeSnap] = await tx.getAll(
    db.collection(rcsConsentCollections.permissions).doc(id),
    db.collection("events").doc(context.eventId),
    db.collection("eventAttendees").doc(attendeeId));
  if (!permissionSnap.exists) return missing;
  const permission = parseRcsPermission(permissionSnap.data());
  if (permission.status !== "granted") return suppressed;
  const source = guestSourceFactsFromSnapshots(context, attendeeId,
    eventSnap, attendeeSnap);
  const attendee = attendeeSnap.data();
  if (permission.permissionId !== id ||
      permission.sender.agentId !== config.agentId ||
      permission.attendeeGeneration !== source.attendeeGeneration ||
      permission.sourceGeneration !== source.sourceGeneration ||
      permission.phoneE164 !== attendee?.phoneE164 ||
      permission.subjectUid !== attendee?.linkedUid ||
      permission.updatedAt > now || permission.expiresAt <= now ||
      now >= Math.floor(source.eventEnd) + 86_400_000) return missing;
  const receiptSnap = await tx.get(db.collection(rcsConsentCollections.receipts)
    .doc(permission.currentReceiptId));
  const receipt = receiptSnap.exists ?
    parseRcsConsentReceipt(receiptSnap.data()) : null;
  if (!rcsPermissionHasReceipt(permission, receipt)) return missing;
  const subscription = await readRcsSubscription(db, tx, config.agentId,
    rcsPhoneHash(permission.phoneE164)!, now);
  return rcsPermissionClearsStop(permission, subscription) ?
    {kind: "allowed", permission, source, subscription} : suppressed;
}
