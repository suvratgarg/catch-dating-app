import * as admin from "firebase-admin";
import {randomUUID} from "node:crypto";
import {CallableRequest, HttpsError, onCall} from
  "firebase-functions/v2/https";
import {requireAuth} from "../shared/auth";
import {appCheckCallableOptionsWithLimits} from "../shared/callableOptions";
import {checkRateLimit} from "../shared/rateLimit";
import {validateCallableWithAjv} from "../shared/validation";
import {
  nextRevision,
  programStaffGrantId,
} from "../shared/programAuthority";
import {staffTimestampMillis} from "../shared/eventOperatorAuthority";
import {normalizeRosterPhone} from "../events/eventAttendees";
import {
  dedupeDuties,
  maxGrantDurationMillis,
  maxProgramStaff,
  requireProgramManager,
  validateDutyStations,
} from "./programStaff";
import type {
  ProgramStaffGrantDocument,
  ProgramStaffInviteDocument,
} from "../shared/generated/firestoreAdminTypes";
import type {InviteProgramStaffCallablePayload} from
  "../shared/generated/inviteProgramStaffCallablePayload";
import type {ClaimProgramStaffInviteCallablePayload} from
  "../shared/generated/claimProgramStaffInviteCallablePayload";
import type {RevokeProgramStaffInviteCallablePayload} from
  "../shared/generated/revokeProgramStaffInviteCallablePayload";
import type {ProgramMutationCallableResponse} from
  "../shared/generated/programMutationCallableResponse";
import type {ProgramInviteClaimCallableResponse} from
  "../shared/generated/programInviteClaimCallableResponse";
import {
  validateInviteProgramStaffCallablePayload,
} from "../shared/generated/validators/inviteProgramStaffInput";
import {
  validateClaimProgramStaffInviteCallablePayload,
} from "../shared/generated/validators/claimProgramStaffInviteInput";
import {
  validateRevokeProgramStaffInviteCallablePayload,
} from "../shared/generated/validators/revokeProgramStaffInviteInput";

interface ProgramStaffInviteDeps {
  firestore: () => FirebaseFirestore.Firestore;
  checkRateLimit: typeof checkRateLimit;
  now: () => FirebaseFirestore.Timestamp;
}

const defaultDeps: ProgramStaffInviteDeps = {
  firestore: () => admin.firestore(),
  checkRateLimit,
  now: () => admin.firestore.Timestamp.now(),
};

const inviteCallableLimits = {timeoutSeconds: 60, maxInstances: 20};

/**
 * Create a phone-bound, single-use staff invite. Returns an existing pending
 * invite for the same program and phone instead of duplicating. Manager-only.
 */
export async function inviteProgramStaffHandler(
  request: CallableRequest<unknown>,
  deps: ProgramStaffInviteDeps = defaultDeps
): Promise<ProgramMutationCallableResponse> {
  const actorUid = requireAuth(request);
  const data = validateCallableWithAjv<InviteProgramStaffCallablePayload>(
    request, validateInviteProgramStaffCallablePayload);
  const db = deps.firestore();
  await deps.checkRateLimit(db, actorUid, "inviteProgramStaff");
  const bundle = await requireProgramManager(db, data.programId, actorUid);
  await validateDutyStations(db, data.programId, data.duties);
  const phone = normalizeRosterPhone(data.phoneNumber);
  if (!phone.value || phone.issue) {
    throw new HttpsError("invalid-argument", phone.issue ?? "Invalid phone.");
  }
  const now = deps.now();
  if (data.expiresAtMillis <= now.toMillis() ||
      data.expiresAtMillis > now.toMillis() + maxGrantDurationMillis) {
    throw new HttpsError("invalid-argument",
      "Invite expiry must be within the staff access window.");
  }
  const invites = db.collection("programStaffInvites");
  const existingSnap = await invites
    .where("programId", "==", data.programId)
    .where("phoneE164", "==", phone.value)
    .where("status", "==", "pending")
    .limit(5)
    .get();
  for (const doc of existingSnap.docs) {
    const invite = doc.data() as ProgramStaffInviteDocument;
    if (staffTimestampMillis(invite.expiresAt) > now.toMillis()) {
      return {
        entityId: doc.id,
        revision: invite.revision,
        alreadyApplied: true,
      };
    }
  }
  const ref = invites.doc(`inv_${randomUUID()}`);
  const document: ProgramStaffInviteDocument = {
    organizerId: bundle.program.organizerId,
    programId: data.programId,
    phoneE164: phone.value,
    displayName: data.displayName.trim(),
    duties: dedupeDuties(data.duties),
    status: "pending",
    createdBy: actorUid,
    createdAt: now,
    expiresAt: admin.firestore.Timestamp.fromMillis(data.expiresAtMillis),
    claimedByUid: null,
    claimedAt: null,
    revokedBy: null,
    revokedAt: null,
    updatedAt: now,
    revision: nextRevision(undefined, now),
  };
  await ref.set(document);
  return {
    entityId: ref.id,
    revision: document.revision,
    alreadyApplied: false,
  };
}

/**
 * Redeem an invite. The caller's verified auth-token phone must match the
 * invite's bound number; success writes/merges the staff grant and consumes
 * the invite atomically.
 */
export async function claimProgramStaffInviteHandler(
  request: CallableRequest<unknown>,
  deps: ProgramStaffInviteDeps = defaultDeps
): Promise<ProgramInviteClaimCallableResponse> {
  const uid = requireAuth(request);
  const data =
    validateCallableWithAjv<ClaimProgramStaffInviteCallablePayload>(
      request, validateClaimProgramStaffInviteCallablePayload);
  const db = deps.firestore();
  await deps.checkRateLimit(db, uid, "claimProgramStaffInvite");
  const rawPhone = request.auth?.token.phone_number;
  const callerPhone = typeof rawPhone === "string" ?
    normalizeRosterPhone(rawPhone).value : null;
  if (!callerPhone) {
    throw new HttpsError(
      "failed-precondition",
      "Sign in with a verified phone number to claim a staff invite."
    );
  }
  const inviteRef = db.collection("programStaffInvites").doc(data.inviteId);
  const now = deps.now();
  return db.runTransaction(async (tx) => {
    const snap = await tx.get(inviteRef);
    const invite = snap.data() as ProgramStaffInviteDocument | undefined;
    if (!invite) {
      throw new HttpsError("not-found", "Staff invite not found.");
    }
    if (invite.status === "claimed") {
      if (invite.claimedByUid === uid) {
        return {programId: invite.programId, alreadyApplied: true};
      }
      throw new HttpsError(
        "failed-precondition", "This staff invite was already claimed.");
    }
    if (invite.status !== "pending" ||
        staffTimestampMillis(invite.expiresAt) <= now.toMillis()) {
      throw new HttpsError(
        "failed-precondition", "This staff invite is no longer valid.");
    }
    if (invite.phoneE164 !== callerPhone) {
      throw new HttpsError(
        "permission-denied",
        "This invite was sent to a different phone number."
      );
    }
    const grantRef = db.collection("programStaffGrants")
      .doc(programStaffGrantId(invite.programId, uid));
    const [grantSnap, activeSnap] = await Promise.all([
      tx.get(grantRef),
      tx.get(db.collection("programStaffGrants")
        .where("programId", "==", invite.programId)
        .where("status", "==", "active")
        .where("expiresAt", ">", now)
        .limit(maxProgramStaff)),
    ]);
    const current = grantSnap.data() as ProgramStaffGrantDocument | undefined;
    const currentActive = current?.status === "active" &&
      staffTimestampMillis(current.expiresAt) > now.toMillis();
    if (!currentActive && activeSnap.size >= maxProgramStaff) {
      throw new HttpsError(
        "resource-exhausted",
        "This program already has the maximum number of staff grants."
      );
    }
    const committedAt = deps.now();
    const mergedDuties = dedupeDuties([
      ...(current?.duties ?? []),
      ...invite.duties,
    ]);
    const grantExpiryMillis = Math.max(
      current ? staffTimestampMillis(current.expiresAt) : 0,
      staffTimestampMillis(invite.expiresAt));
    const grant: ProgramStaffGrantDocument = {
      organizerId: invite.organizerId,
      programId: invite.programId,
      uid,
      displayName: invite.displayName,
      phoneLastFour: invite.phoneE164.slice(-4),
      duties: mergedDuties,
      status: "active",
      createdBy: current?.createdBy ?? invite.createdBy,
      createdAt: current?.createdAt ?? committedAt,
      expiresAt:
        admin.firestore.Timestamp.fromMillis(grantExpiryMillis),
      revokedBy: null,
      revokedAt: null,
      updatedAt: committedAt,
      revision: current ? nextRevision(current.revision, committedAt) : 1,
    };
    tx.set(grantRef, grant);
    tx.set(inviteRef, {
      ...invite,
      status: "claimed",
      claimedByUid: uid,
      claimedAt: committedAt,
      updatedAt: committedAt,
      revision: nextRevision(invite.revision, committedAt),
    });
    return {programId: invite.programId, alreadyApplied: false};
  });
}

/** Revoke a pending invite so its link can no longer be claimed. */
export async function revokeProgramStaffInviteHandler(
  request: CallableRequest<unknown>,
  deps: ProgramStaffInviteDeps = defaultDeps
): Promise<ProgramMutationCallableResponse> {
  const actorUid = requireAuth(request);
  const data =
    validateCallableWithAjv<RevokeProgramStaffInviteCallablePayload>(
      request, validateRevokeProgramStaffInviteCallablePayload);
  const db = deps.firestore();
  await deps.checkRateLimit(db, actorUid, "revokeProgramStaffInvite");
  const inviteRef = db.collection("programStaffInvites").doc(data.inviteId);
  return db.runTransaction(async (tx) => {
    const [snap] = await Promise.all([
      tx.get(inviteRef),
      requireProgramManager(db, data.programId, actorUid, tx),
    ]);
    const invite = snap.data() as ProgramStaffInviteDocument | undefined;
    if (!invite || invite.programId !== data.programId) {
      throw new HttpsError("not-found", "Staff invite not found.");
    }
    if (invite.status !== "pending") {
      return {
        entityId: data.inviteId,
        revision: invite.revision,
        alreadyApplied: true,
      };
    }
    const committedAt = deps.now();
    const revision = nextRevision(invite.revision, committedAt);
    tx.set(inviteRef, {
      ...invite,
      status: "revoked",
      revokedBy: actorUid,
      revokedAt: committedAt,
      updatedAt: committedAt,
      revision,
    });
    return {
      entityId: data.inviteId,
      revision,
      alreadyApplied: false,
    };
  });
}

export const inviteProgramStaff = onCall(
  appCheckCallableOptionsWithLimits(inviteCallableLimits),
  (request) => inviteProgramStaffHandler(request)
);
export const claimProgramStaffInvite = onCall(
  appCheckCallableOptionsWithLimits(inviteCallableLimits),
  (request) => claimProgramStaffInviteHandler(request)
);
export const revokeProgramStaffInvite = onCall(
  appCheckCallableOptionsWithLimits(inviteCallableLimits),
  (request) => revokeProgramStaffInviteHandler(request)
);
