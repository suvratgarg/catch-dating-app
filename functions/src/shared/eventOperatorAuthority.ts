import * as admin from "firebase-admin";
import {HttpsError} from "firebase-functions/v2/https";
import {
  EventDocument,
  EventStaffGrantDocument,
} from "./generated/firestoreAdminTypes";
import {
  EventOrganizerDocument,
  isEventOrganizerManager,
} from "./eventOrganizers";

export type EventOperatorPermission =
  EventStaffGrantDocument["permissions"][number];

export const eventOperatorPermissions: EventOperatorPermission[] = [
  "viewRoster",
  "setAttendance",
  "reviewRuntimeClaims",
  "publishLiveLocation",
];

export function eventStaffGrantId(eventId: string, uid: string): string {
  return `${eventId}__${uid}`;
}

export async function requireEventOperatorPermission(params: {
  db: FirebaseFirestore.Firestore;
  organizer: EventOrganizerDocument;
  event: EventDocument;
  eventId: string;
  actorUid: string;
  permission: EventOperatorPermission;
  now?: FirebaseFirestore.Timestamp;
  transaction?: FirebaseFirestore.Transaction;
}): Promise<{role: "manager" | "operator";
  grant: EventStaffGrantDocument | null}> {
  if (isEventOrganizerManager(
    params.organizer, params.event, params.actorUid
  )) {
    return {role: "manager", grant: null};
  }
  const grantRef = params.db.collection("eventStaffGrants").doc(
    eventStaffGrantId(params.eventId, params.actorUid)
  );
  const grantSnap = params.transaction ?
    await params.transaction.get(grantRef) : await grantRef.get();
  const grant = grantSnap.data() as EventStaffGrantDocument | undefined;
  const now = params.now ?? admin.firestore.Timestamp.now();
  if (!grant || grant.eventId !== params.eventId ||
      grant.organizerId !== (params.event.organizerId ?? params.event.clubId) ||
      grant.uid !== params.actorUid || grant.status !== "active" ||
      grant.expiresAt.toMillis() <= now.toMillis() ||
      !grant.permissions.includes(params.permission)) {
    throw new HttpsError(
      "permission-denied",
      "This account does not have active event-operator access."
    );
  }
  return {role: "operator", grant};
}
