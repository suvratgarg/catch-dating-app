import * as admin from "firebase-admin";
import * as logger from "firebase-functions/logger";
import {onDocumentWritten} from "firebase-functions/v2/firestore";
import {
  EventAttendeeDocument,
  EventParticipationDocument,
  PublicProfileDocument,
} from "../shared/generated/firestoreAdminTypes";
import {eventAttendeeId, normalizeRosterPhone} from "./eventAttendees";

interface ProjectionDeps {
  firestore: () => FirebaseFirestore.Firestore;
  auth: () => admin.auth.Auth;
  timestamp: () => FirebaseFirestore.Timestamp;
}

const defaultDeps: ProjectionDeps = {
  firestore: () => admin.firestore(),
  auth: () => admin.auth(),
  timestamp: () => admin.firestore.Timestamp.now(),
};

/**
 * Projects a UID-backed Consumer participation into the Host operational
 * roster. A verified Auth phone may converge with a prior Host-supplied row,
 * but a Catch booking never discloses private-profile contact fields to the
 * organizer.
 */
export async function projectEventParticipationToAttendee(
  before: EventParticipationDocument | undefined,
  after: EventParticipationDocument | undefined,
  deps: ProjectionDeps = defaultDeps
): Promise<void> {
  const participation = after ?? before;
  if (!participation) return;
  const db = deps.firestore();
  const [verifiedPhone, profileSnap] = await Promise.all([
    verifiedPhoneForUid(participation.uid, deps.auth()),
    db.collection("publicProfiles").doc(participation.uid).get(),
  ]);
  const profile = profileSnap.data() as PublicProfileDocument | undefined;
  const stableKey = verifiedPhone ?
    `phone:${verifiedPhone}` : `uid:${participation.uid}`;
  const attendeeId = eventAttendeeId(participation.eventId, stableKey);
  const attendeeRef = db.collection("eventAttendees").doc(attendeeId);
  const existingSnap = await attendeeRef.get();
  const existing = existingSnap.data() as EventAttendeeDocument | undefined;
  const now = deps.timestamp();
  const status = projectedParticipationStatus(
    participationStatus(after?.status),
    existing?.status
  );
  const displayName = profile?.name?.trim() || existing?.displayName ||
    participation.uid;

  const document: EventAttendeeDocument = {
    eventId: participation.eventId,
    clubId: participation.clubId,
    organizerId: participation.organizerId ?? participation.clubId,
    displayName,
    searchName: displayName.toLocaleLowerCase("en"),
    // Preserve the first operational acquisition source when a Host-imported
    // or web attendee later links a full Catch booking.
    source: existing?.source ?? "catchBooking",
    status,
    linkedUid: participation.uid,
    // Preserve only contact fields already supplied to this organizer. A
    // private users/{uid} value is never an organizer disclosure source.
    phoneE164: existing?.phoneE164 ?? null,
    email: existing?.email ?? null,
    externalReference: existing?.externalReference ?? null,
    arrivalGroup: existing?.arrivalGroup ?? null,
    ticketType: existing?.ticketType ?? null,
    importId: existing?.importId ?? null,
    sourceRowId: existing?.sourceRowId ?? null,
    createdAt: existing?.createdAt ?? participation.createdAt,
    updatedAt: now,
    registeredAt: participation.signedUpAt ?? existing?.registeredAt ?? null,
    waitlistedAt: participation.waitlistedAt ?? existing?.waitlistedAt ?? null,
    checkedInAt: status === "checkedIn" ?
      participation.attendedAt ?? existing?.checkedInAt ?? now : null,
    cancelledAt: status === "cancelled" ?
      participation.cancelledAt ?? participation.deletedAt ?? now : null,
    checkedInBy: existing?.checkedInBy ?? null,
    linkedAt: existing?.linkedAt ?? participation.createdAt,
    inviteLinkId: existing?.inviteLinkId ?? participation.inviteLinkId ?? null,
    inviteCapturedAt: existing?.inviteCapturedAt ??
      participation.inviteCapturedAt ?? null,
    attendanceRevision: existing?.attendanceRevision ?? 0,
    preCheckInStatus: status === "checkedIn" ?
      existing?.preCheckInStatus ?? "registered" : null,
  };
  await attendeeRef.set(document);
}

async function verifiedPhoneForUid(
  uid: string,
  auth: admin.auth.Auth
): Promise<string | null> {
  try {
    const user = await auth.getUser(uid);
    return normalizeRosterPhone(user.phoneNumber).value;
  } catch (error) {
    logger.warn("Could not resolve verified phone for attendee projection", {
      uid,
      error,
    });
    return null;
  }
}

export function projectedParticipationStatus(
  participation: EventAttendeeDocument["status"],
  existing: EventAttendeeDocument["status"] | undefined
): EventAttendeeDocument["status"] {
  if (participation !== "cancelled" && existing === "checkedIn") {
    return "checkedIn";
  }
  return participation;
}

export function participationStatus(
  status: EventParticipationDocument["status"] | undefined
): EventAttendeeDocument["status"] {
  switch (status) {
  case "signedUp": return "registered";
  case "waitlisted": return "waitlisted";
  case "attended": return "checkedIn";
  case "cancelled":
  case "deleted":
  case undefined:
    return "cancelled";
  }
}

export const onEventParticipationRosterProjected = onDocumentWritten(
  "eventParticipations/{participationId}",
  async (event) => {
    const before = event.data?.before.data() as
      EventParticipationDocument | undefined;
    const after = event.data?.after.data() as
      EventParticipationDocument | undefined;
    await projectEventParticipationToAttendee(before, after);
  }
);
