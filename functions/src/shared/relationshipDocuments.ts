import * as admin from "firebase-admin";

export type ClubMembershipRole = "owner" | "host" | "member";
export type ClubMembershipStatus = "active" | "left" | "deleted";
export type EventParticipationStatus =
  "signedUp" | "waitlisted" | "attended" | "cancelled" | "deleted";

export interface EventParticipationSnapshot {
  ref: FirebaseFirestore.DocumentReference;
  data: {
    eventId: string;
    clubId: string;
    organizerId?: string;
    uid: string;
    status: EventParticipationStatus;
    genderAtSignup?: string;
    cohortAtSignup?: string;
  };
}

/**
 * Builds the deterministic club membership document id.
 * @param {string} clubId Club id.
 * @param {string} uid User id.
 * @return {string} Membership document id.
 */
export function clubMembershipId(clubId: string, uid: string): string {
  return `${clubId}_${uid}`;
}

/**
 * Builds the deterministic organizer relationship document id.
 * Team memberships and follows use separate collections but share this stable
 * identity so the migration can be replayed safely.
 * @param {string} organizerId Organizer id.
 * @param {string} uid User id.
 * @return {string} Relationship document id.
 */
export function organizerRelationshipId(
  organizerId: string,
  uid: string
): string {
  return `${organizerId}_${uid}`;
}

/**
 * Creates the canonical active organizer-team edge patch.
 * @param {object} params Team edge fields.
 * @param {string} params.organizerId Organizer id.
 * @param {string} params.uid User id.
 * @param {"owner" | "manager"} params.role Team role.
 * @return {Record<string, unknown>} Firestore patch.
 */
export function activeOrganizerTeamMembershipPatch(params: {
  organizerId: string;
  uid: string;
  role: "owner" | "manager";
}) {
  return {
    organizerId: params.organizerId,
    uid: params.uid,
    role: params.role,
    status: "active" as const,
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
    removedAt: null,
  };
}

/**
 * Creates the canonical active organizer-follow edge patch.
 * @param {object} params Follow edge fields.
 * @param {string} params.organizerId Organizer id.
 * @param {string} params.uid User id.
 * @param {boolean=} params.pushNotificationsEnabled Push preference.
 * @return {Record<string, unknown>} Firestore patch.
 */
export function activeOrganizerFollowPatch(params: {
  organizerId: string;
  uid: string;
  pushNotificationsEnabled?: boolean;
}) {
  return {
    organizerId: params.organizerId,
    uid: params.uid,
    status: "active" as const,
    pushNotificationsEnabled: params.pushNotificationsEnabled ?? false,
    followedAt: admin.firestore.FieldValue.serverTimestamp(),
    unfollowedAt: null,
  };
}

/**
 * Builds the deterministic event participation document id.
 * @param {string} eventId Event id.
 * @param {string} uid User id.
 * @return {string} Participation document id.
 */
export function eventParticipationId(eventId: string, uid: string): string {
  return `${eventId}_${uid}`;
}

/**
 * Builds the deterministic event waitlist offer document id.
 * @param {string} eventId Event id.
 * @param {string} uid Offered user id.
 * @return {string} Waitlist offer document id.
 */
export function eventWaitlistOfferId(eventId: string, uid: string): string {
  return `${eventId}_${uid}`;
}

/**
 * Builds the deterministic saved-event document id.
 * @param {string} uid User id.
 * @param {string} eventId Event id.
 * @return {string} Saved-event document id.
 */
export function savedEventId(uid: string, eventId: string): string {
  return `${uid}_${eventId}`;
}

/**
 * Reads event participation edges by status inside a transaction.
 * @param {FirebaseFirestore.Transaction} tx Transaction.
 * @param {FirebaseFirestore.Firestore} db Firestore instance.
 * @param {string} eventId Event id.
 * @param {EventParticipationStatus[]} statuses Statuses to include.
 * @return {Promise<EventParticipationSnapshot[]>} Matching edge docs.
 */
export async function eventParticipationsByStatusInTransaction(
  tx: FirebaseFirestore.Transaction,
  db: FirebaseFirestore.Firestore,
  eventId: string,
  statuses: EventParticipationStatus[]
): Promise<EventParticipationSnapshot[]> {
  if (statuses.length === 0) return [];
  const query = db
    .collection("eventParticipations")
    .where("eventId", "==", eventId)
    .where("status", "in", statuses);
  const snap = await tx.get(query);
  return snap.docs.map((doc) => ({
    ref: doc.ref,
    data: doc.data() as EventParticipationSnapshot["data"],
  }));
}

/**
 * Reads waitlisted participation edges in promotion order.
 * @param {FirebaseFirestore.Transaction} tx Transaction.
 * @param {FirebaseFirestore.Firestore} db Firestore instance.
 * @param {string} eventId Event id.
 * @return {Promise<EventParticipationSnapshot[]>} Waitlist edges.
 */
export async function waitlistedEventParticipationsInTransaction(
  tx: FirebaseFirestore.Transaction,
  db: FirebaseFirestore.Firestore,
  eventId: string
): Promise<EventParticipationSnapshot[]> {
  const query = db
    .collection("eventParticipations")
    .where("eventId", "==", eventId)
    .where("status", "==", "waitlisted")
    .orderBy("waitlistedAt", "asc");
  const snap = await tx.get(query);
  return snap.docs.map((doc) => ({
    ref: doc.ref,
    data: doc.data() as EventParticipationSnapshot["data"],
  }));
}

/**
 * Returns active peer ids for block checks.
 * @param {EventParticipationSnapshot[]} participations Participation edges.
 * @param {string=} exceptUid Optional user id to exclude.
 * @return {string[]} Unique participant user ids.
 */
export function participantUids(
  participations: EventParticipationSnapshot[],
  exceptUid?: string
): string[] {
  return [...new Set(
    participations
      .map((participation) => participation.data.uid)
      .filter((uid) => uid && uid !== exceptUid)
  )];
}

/**
 * Creates the patch used when a membership is active.
 * @param {object} params Membership fields.
 * @param {string} params.clubId Club id.
 * @param {string} params.uid User id.
 * @param {ClubMembershipRole} params.role Membership role.
 * @return {Record<string, unknown>} Firestore patch.
 */
export function activeClubMembershipPatch(params: {
  clubId: string;
  uid: string;
  role: ClubMembershipRole;
}) {
  return {
    clubId: params.clubId,
    uid: params.uid,
    role: params.role,
    status: "active" as const,
    pushNotificationsEnabled: false,
    joinedAt: admin.firestore.FieldValue.serverTimestamp(),
    leftAt: admin.firestore.FieldValue.delete(),
    deletedAt: admin.firestore.FieldValue.delete(),
  };
}

/**
 * Creates the patch used when a membership is left.
 * @return {Record<string, unknown>} Firestore patch.
 */
export function leftClubMembershipPatch() {
  return {
    status: "left" as const,
    leftAt: admin.firestore.FieldValue.serverTimestamp(),
  };
}

/**
 * Creates a status-specific event participation patch.
 * @param {object} params Participation fields.
 * @param {boolean} params.exists Whether the edge document already exists.
 * @param {string} params.eventId Event id.
 * @param {string} params.clubId Club id.
 * @param {string} params.uid User id.
 * @param {EventParticipationStatus} params.status New participation status.
 * @param {string=} params.genderAtSignup Optional signup-time gender snapshot.
 * @param {string=} params.cohortAtSignup Optional signup-time policy cohort.
 * @param {string=} params.paymentId Optional linked payment document id.
 * @return {Record<string, unknown>} Firestore patch.
 */
export function eventParticipationPatch(params: {
  exists: boolean;
  eventId: string;
  clubId: string;
  organizerId?: string;
  uid: string;
  status: EventParticipationStatus;
  genderAtSignup?: string;
  cohortAtSignup?: string;
  paymentId?: string;
}) {
  const now = admin.firestore.FieldValue.serverTimestamp();
  const patch: Record<string, unknown> = {
    eventId: params.eventId,
    clubId: params.clubId,
    organizerId: params.organizerId ?? params.clubId,
    uid: params.uid,
    status: params.status,
    updatedAt: now,
  };

  if (!params.exists) {
    patch.createdAt = now;
  }
  if (params.genderAtSignup !== undefined) {
    patch.genderAtSignup = params.genderAtSignup;
  }
  if (params.cohortAtSignup !== undefined) {
    patch.cohortAtSignup = params.cohortAtSignup;
  }
  if (params.paymentId !== undefined) {
    patch.paymentId = params.paymentId;
  }

  switch (params.status) {
  case "signedUp":
    patch.signedUpAt = now;
    patch.waitlistedAt = admin.firestore.FieldValue.delete();
    patch.attendedAt = admin.firestore.FieldValue.delete();
    patch.cancelledAt = admin.firestore.FieldValue.delete();
    patch.deletedAt = admin.firestore.FieldValue.delete();
    break;
  case "waitlisted":
    patch.waitlistedAt = now;
    patch.attendedAt = admin.firestore.FieldValue.delete();
    patch.cancelledAt = admin.firestore.FieldValue.delete();
    patch.deletedAt = admin.firestore.FieldValue.delete();
    break;
  case "attended":
    patch.attendedAt = now;
    patch.cancelledAt = admin.firestore.FieldValue.delete();
    patch.deletedAt = admin.firestore.FieldValue.delete();
    break;
  case "cancelled":
    patch.cancelledAt = now;
    break;
  case "deleted":
    patch.deletedAt = now;
    break;
  }

  return patch;
}
