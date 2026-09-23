import {createHash} from "node:crypto";
import * as admin from "firebase-admin";
import {Timestamp} from "firebase-admin/firestore";
import {HttpsError, onCall, type CallableRequest} from
  "firebase-functions/v2/https";
import {requireAuth} from "../shared/auth";
import {appCheckCallableOptionsWithLimits} from "../shared/callableOptions";
import {checkRateLimit} from "../shared/rateLimit";
import {requireDoc, validateCallableWithAjv} from "../shared/validation";
import {eventOrganizerId, eventOrganizerRef, requireEventOrganizer,
  isEventOrganizerManager} from "../shared/eventOrganizers";
import {requireVerifiedParticipant} from "../profiles/claimFormProfile";
import type {EventDocument, UserProfileDocument,
  EventParticipationDocument, EventAttendeeDocument,
  EventChatRoomDocument as Room, EventChatMembershipDocument as Membership,
  EventChatAccessReceiptDocument as Receipt} from
  "../shared/generated/firestoreAdminTypes";
import type {GetEventChatAccessCallableResponse as View} from
  "../shared/generated/getEventChatAccessCallableResponse";
import type {UpdateEventChatAccessCallableResponse as Result} from
  "../shared/generated/updateEventChatAccessCallableResponse";
import {validateGetEventChatAccessCallablePayload} from
  "../shared/generated/validators/getEventChatAccessInput";
import {validateUpdateEventChatAccessCallablePayload} from
  "../shared/generated/validators/updateEventChatAccessInput";

export const eventChatTermsVersion = "event-chat-v1";
const hash = (value: unknown) => createHash("sha256")
  .update(JSON.stringify(value)).digest("hex");
export const eventChatMembershipId = (eventId: string, uid: string) =>
  hash([eventId, uid]);
interface Deps {
  db: () => FirebaseFirestore.Firestore;
  now: () => Timestamp;
  rateLimit: typeof checkRateLimit;
}
const defaults: Deps = {db: () => admin.firestore(), now: () => Timestamp.now(),
  rateLimit: checkRateLimit};

/** Canonical cancellation or conflicting evidence cannot be bypassed by a
 * stale room membership, runtime identity, or another positive projection. */
export function hasEventChatAdmission(eventId: string, organizerId: string,
  uid: string, participation: EventParticipationDocument | null,
  attendees: EventAttendeeDocument[]): boolean {
  if (attendees.length > 1) return false;
  if (participation && (participation.eventId !== eventId ||
      participation.uid !== uid ||
      (participation.organizerId ?? participation.clubId) !== organizerId ||
      !["signedUp", "attended"].includes(participation.status))) return false;
  const attendee = attendees[0];
  if (attendee && (attendee.eventId !== eventId ||
      attendee.organizerId !== organizerId || attendee.linkedUid !== uid ||
      !["registered", "checkedIn"].includes(attendee.status))) return false;
  return participation !== null || attendee !== undefined;
}

async function readAccount(db: FirebaseFirestore.Firestore,
  tx: FirebaseFirestore.Transaction, uid: string) {
  const [deleted, user] = await Promise.all([
    tx.get(db.collection("deletedUsers").doc(uid)),
    tx.get(db.collection("users").doc(uid)),
  ]);
  if (deleted.exists || user.data()?.deleted === true) {
    throw new HttpsError("permission-denied", "This account is unavailable.");
  }
  return user.exists ? requireDoc<UserProfileDocument>(user,
    "UserProfileDocument") : null;
}

/** Reads current event authority without trusting a cached roster grant. */
export async function readEventChatAccess(db: FirebaseFirestore.Firestore,
  tx: FirebaseFirestore.Transaction, eventId: string, uid: string) {
  const user = await readAccount(db, tx, uid);
  const eventSnap = await tx.get(db.collection("events").doc(eventId));
  if (!eventSnap.exists) throw unavailable();
  const event = requireDoc<EventDocument>(eventSnap, "EventDocument");
  const organizerId = eventOrganizerId(event);
  const organizer = requireEventOrganizer(await tx.get(
    eventOrganizerRef(db, event)), event);
  const host = isEventOrganizerManager(organizer, event, uid);
  if (!host) {
    const [participationSnap, attendeeRows] = await Promise.all([
      tx.get(db.collection("eventParticipations").doc(`${eventId}_${uid}`)),
      tx.get(db.collection("eventAttendees").where("eventId", "==", eventId)
        .where("linkedUid", "==", uid).limit(2)),
    ]);
    const participation = participationSnap.exists ?
      requireDoc<EventParticipationDocument>(participationSnap,
        "EventParticipationDocument") : null;
    if (!hasEventChatAdmission(eventId, organizerId, uid, participation,
      attendeeRows.docs.map((row) => requireDoc<EventAttendeeDocument>(row,
        "EventAttendeeDocument")))) throw unavailable();
  }
  const [roomSnap, memberSnap] = await Promise.all([
    tx.get(db.collection("eventChatRooms").doc(eventId)),
    tx.get(db.collection("eventChatMemberships")
      .doc(eventChatMembershipId(eventId, uid))),
  ]);
  const room = roomSnap.exists ? requireDoc<Room>(roomSnap,
    "EventChatRoomDocument") : null;
  const member = memberSnap.exists ? requireDoc<Membership>(memberSnap,
    "EventChatMembershipDocument") : null;
  if ((room && (room.eventId !== eventId ||
      room.organizerId !== organizerId)) ||
      (member && (member.eventId !== eventId || member.uid !== uid ||
        member.organizerId !== organizerId))) throw unavailable();
  const claimed = user !== null && typeof user.displayName === "string" &&
    user.displayName.trim().length > 0 &&
    (user.profileComplete === true || (user.profileRevision ?? 0) > 0);
  const active = event.status === "active" && room?.status === "open";
  const view: View = {eventId, organizerId, title: event.name ?? "",
    role: host ? "host" : "attendee",
    room: {status: room?.status ?? "notCreated", revision: room?.revision ?? 0},
    membership: {status: member?.status ?? "notJoined",
      revision: member?.revision ?? 0},
    canManage: host, canJoin: active && claimed,
    canReadMessages: active && claimed && member?.status === "joined",
    profileClaimRequired: !claimed, termsVersion: eventChatTermsVersion};
  return {event, room, member, user, view};
}

export async function requireEventChatMember(db: FirebaseFirestore.Firestore,
  tx: FirebaseFirestore.Transaction, eventId: string, uid: string) {
  const access = await readEventChatAccess(db, tx, eventId, uid);
  if (!access.view.canReadMessages) throw unavailable();
  return access;
}

export async function getEventChatAccessHandler(
  request: CallableRequest<unknown>, deps: Deps = defaults): Promise<View> {
  const uid = requireAuth(request);
  const data = validateCallableWithAjv(request,
    validateGetEventChatAccessCallablePayload);
  const db = deps.db();
  await deps.rateLimit(db, uid, "getEventChatAccess");
  return db.runTransaction(async (tx) =>
    (await readEventChatAccess(db, tx, data.eventId, uid)).view);
}

export async function updateEventChatAccessHandler(
  request: CallableRequest<unknown>, deps: Deps = defaults): Promise<Result> {
  const uid = requireAuth(request);
  const data = validateCallableWithAjv(request,
    validateUpdateEventChatAccessCallablePayload);
  if (data.action === "join") {
    requireVerifiedParticipant(request);
    if (data.termsVersion !== eventChatTermsVersion) {
      throw new HttpsError("failed-precondition",
        "Review the room disclosure.");
    }
  } else if (data.termsVersion !== null) {
    throw new HttpsError("invalid-argument", "Terms apply only when joining.");
  }
  const db = deps.db();
  await deps.rateLimit(db, uid, "updateEventChatAccess");
  const receiptRef = db.collection("eventChatAccessReceipts")
    .doc(hash([uid, data.requestId]));
  const payloadHash = hash([data.eventId, data.action, data.expectedRevision,
    data.termsVersion]);
  return db.runTransaction(async (tx) => {
    await readAccount(db, tx, uid);
    const receiptSnap = await tx.get(receiptRef);
    if (receiptSnap.exists) {
      const receipt = requireDoc<Receipt>(receiptSnap,
        "EventChatAccessReceiptDocument");
      if (receipt.uid !== uid || receipt.eventId !== data.eventId ||
          receipt.payloadHash !== payloadHash) {
        throw new HttpsError("already-exists",
          "This request was already used.");
      }
      // A replay reports the old applied revision, not present access.
      return {revision: receipt.revision, replayed: true};
    }
    const memberRef = db.collection("eventChatMemberships")
      .doc(eventChatMembershipId(data.eventId, uid));
    const now = deps.now();
    let revision: number;
    if (data.action === "leave") {
      // Withdrawal is available even after admission or the event disappears.
      const snap = await tx.get(memberRef);
      const member = snap.exists ? requireDoc<Membership>(snap,
        "EventChatMembershipDocument") : null;
      if (!member || member.uid !== uid || member.eventId !== data.eventId) {
        throw unavailable();
      }
      assertRevision(member.revision, data.expectedRevision);
      revision = member.revision + 1;
      tx.set(memberRef, {...member, revision, status: "left", leftAt: now,
        updatedAt: now} satisfies Membership);
    } else {
      const access = await readEventChatAccess(db, tx, data.eventId, uid);
      if (data.action === "join") {
        if (!access.view.canJoin) throw unavailable();
        assertRevision(access.member?.revision ?? 0, data.expectedRevision);
        revision = (access.member?.revision ?? 0) + 1;
        tx.set(memberRef, {eventId: data.eventId,
          organizerId: access.view.organizerId, uid, revision, status: "joined",
          termsVersion: eventChatTermsVersion, joinedAt: now, leftAt: null,
          createdAt: access.member?.createdAt ?? now, updatedAt: now} satisfies
          Membership);
      } else {
        if (!access.view.canManage || (data.action === "open" &&
            access.event.status !== "active")) throw unavailable();
        assertRevision(access.room?.revision ?? 0, data.expectedRevision);
        revision = (access.room?.revision ?? 0) + 1;
        tx.set(db.collection("eventChatRooms").doc(data.eventId), {
          eventId: data.eventId, organizerId: access.view.organizerId,
          status: data.action === "open" ? "open" : "closed", revision,
          createdByUid: access.room?.createdByUid ?? uid, updatedByUid: uid,
          createdAt: access.room?.createdAt ?? now, updatedAt: now,
        } satisfies Room);
      }
    }
    tx.create(receiptRef, {eventId: data.eventId, uid, payloadHash, revision,
      createdAt: now} satisfies Receipt);
    return {revision, replayed: false};
  });
}

function assertRevision(actual: number, expected: number) {
  if (actual !== expected) {
    throw new HttpsError("aborted",
      "Room settings changed. Refresh and retry.");
  }
  if (!Number.isSafeInteger(actual + 1)) throw unavailable();
}
function unavailable() {
  return new HttpsError("permission-denied", "This event chat is unavailable.");
}
export const getEventChatAccess = onCall(
  appCheckCallableOptionsWithLimits({timeoutSeconds: 30, maxInstances: 20}),
  (request) => getEventChatAccessHandler(request));
export const updateEventChatAccess = onCall(
  appCheckCallableOptionsWithLimits({timeoutSeconds: 30, maxInstances: 20}),
  (request) => updateEventChatAccessHandler(request));
