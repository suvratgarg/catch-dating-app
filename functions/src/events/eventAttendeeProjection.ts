import * as admin from "firebase-admin";
import {onDocumentWritten} from "firebase-functions/v2/firestore";
import {
  EventAttendeeDocument,
  EventParticipationDocument,
  PublicProfileDocument,
  UserProfileDocument,
} from "../shared/generated/firestoreAdminTypes";
import {publicDisplayName} from "../shared/profileProjection";
import {eventAttendeeId, normalizeRosterPhone} from "./eventAttendees";

interface ProjectionDeps {
  firestore: () => FirebaseFirestore.Firestore;
  timestamp: () => FirebaseFirestore.Timestamp;
}

const defaultDeps: ProjectionDeps = {
  firestore: () => admin.firestore(),
  timestamp: () => admin.firestore.Timestamp.now(),
};

/**
 * Projects a UID-backed Consumer participation into the Host operational
 * roster. Phone identity is event-scoped and converges with a prior Host
 * import when the same normalized number was supplied.
 */
export async function projectEventParticipationToAttendee(
  before: EventParticipationDocument | undefined,
  after: EventParticipationDocument | undefined,
  deps: ProjectionDeps = defaultDeps
): Promise<void> {
  const participation = after ?? before;
  if (!participation) return;
  const db = deps.firestore();
  const [userSnap, profileSnap] = await Promise.all([
    db.collection("users").doc(participation.uid).get(),
    db.collection("publicProfiles").doc(participation.uid).get(),
  ]);
  const user = userSnap.data() as UserProfileDocument | undefined;
  const profile = profileSnap.data() as PublicProfileDocument | undefined;
  const phone = normalizeRosterPhone(user?.phoneNumber).value;
  const stableKey = phone ? `phone:${phone}` : `uid:${participation.uid}`;
  const attendeeId = eventAttendeeId(participation.eventId, stableKey);
  const attendeeRef = db.collection("eventAttendees").doc(attendeeId);
  const existingSnap = await attendeeRef.get();
  const existing = existingSnap.data() as EventAttendeeDocument | undefined;
  const now = deps.timestamp();
  const status = projectedParticipationStatus(
    participationStatus(after?.status),
    existing?.status
  );
  const displayName = profile?.name?.trim() ||
    (user ? publicDisplayName(user) : existing?.displayName) ||
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
    phoneE164: phone ?? existing?.phoneE164 ?? null,
    email: user?.email?.trim() || existing?.email || null,
    externalReference: existing?.externalReference ?? null,
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
  };
  await attendeeRef.set(document);
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
