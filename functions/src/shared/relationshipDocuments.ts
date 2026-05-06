import * as admin from "firebase-admin";

export type RunClubMembershipRole = "host" | "member";
export type RunClubMembershipStatus = "active" | "left" | "deleted";
export type RunParticipationStatus =
  "signedUp" | "waitlisted" | "attended" | "cancelled" | "deleted";

/**
 * Builds the deterministic run-club membership document id.
 * @param {string} clubId Run club id.
 * @param {string} uid User id.
 * @return {string} Membership document id.
 */
export function runClubMembershipId(clubId: string, uid: string): string {
  return `${clubId}_${uid}`;
}

/**
 * Builds the deterministic run participation document id.
 * @param {string} runId Run id.
 * @param {string} uid User id.
 * @return {string} Participation document id.
 */
export function runParticipationId(runId: string, uid: string): string {
  return `${runId}_${uid}`;
}

/**
 * Builds the deterministic saved-run document id.
 * @param {string} uid User id.
 * @param {string} runId Run id.
 * @return {string} Saved-run document id.
 */
export function savedRunId(uid: string, runId: string): string {
  return `${uid}_${runId}`;
}

/**
 * Creates the patch used when a membership is active.
 * @param {object} params Membership fields.
 * @param {string} params.clubId Run club id.
 * @param {string} params.uid User id.
 * @param {RunClubMembershipRole} params.role Membership role.
 * @return {Record<string, unknown>} Firestore patch.
 */
export function activeRunClubMembershipPatch(params: {
  clubId: string;
  uid: string;
  role: RunClubMembershipRole;
}) {
  return {
    clubId: params.clubId,
    uid: params.uid,
    role: params.role,
    status: "active" as const,
    joinedAt: admin.firestore.FieldValue.serverTimestamp(),
    leftAt: admin.firestore.FieldValue.delete(),
    deletedAt: admin.firestore.FieldValue.delete(),
  };
}

/**
 * Creates the patch used when a membership is left.
 * @return {Record<string, unknown>} Firestore patch.
 */
export function leftRunClubMembershipPatch() {
  return {
    status: "left" as const,
    leftAt: admin.firestore.FieldValue.serverTimestamp(),
  };
}

/**
 * Creates a status-specific run participation patch.
 * @param {object} params Participation fields.
 * @param {boolean} params.exists Whether the edge document already exists.
 * @param {string} params.runId Run id.
 * @param {string} params.runClubId Run club id.
 * @param {string} params.uid User id.
 * @param {RunParticipationStatus} params.status New participation status.
 * @param {string=} params.genderAtSignup Optional signup-time gender snapshot.
 * @param {string=} params.paymentId Optional linked payment document id.
 * @return {Record<string, unknown>} Firestore patch.
 */
export function runParticipationPatch(params: {
  exists: boolean;
  runId: string;
  runClubId: string;
  uid: string;
  status: RunParticipationStatus;
  genderAtSignup?: string;
  paymentId?: string;
}) {
  const now = admin.firestore.FieldValue.serverTimestamp();
  const patch: Record<string, unknown> = {
    runId: params.runId,
    runClubId: params.runClubId,
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
