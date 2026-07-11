import crypto from "node:crypto";
import {onCall, CallableRequest, HttpsError} from
  "firebase-functions/v2/https";
import * as admin from "firebase-admin";
import {appCheckCallableOptions} from "../shared/callableOptions";
import {requireAuth} from "../shared/auth";
import {requireAdminRole} from "../admin/adminAuth";
import {setAdminAuditLogInTransaction} from "../admin/adminAudit";
import {
  ClubClaimRequestDocument,
  ClubDocument,
  UserProfileDocument,
} from "../shared/generated/firestoreAdminTypes";
import {RequestClubClaimCallablePayload} from
  "../shared/generated/requestClubClaimCallablePayload";
import {RequestClubClaimCallableResponse} from
  "../shared/generated/requestClubClaimCallableResponse";
import {AdminDecideClubClaimCallablePayload} from
  "../shared/generated/adminDecideClubClaimCallablePayload";
import {
  validateAdminDecideClubClaimCallablePayload,
  validateRequestClubClaimCallablePayload,
} from "../shared/generated/schemaValidators";
import {requireDoc, validateCallableWithAjv} from "../shared/validation";
import {checkRateLimit as defaultCheckRateLimit} from "../shared/rateLimit";
import {
  activeClubMembershipPatch,
  clubMembershipId,
} from "../shared/relationshipDocuments";
import {publicAvatarUrl, publicDisplayName} from "../shared/profileProjection";
import {
  activityNotificationId,
  setActivityNotificationInTransaction,
} from "../shared/notifications";

const claimReviewRoles = ["admin", "adminOwner", "support"] as const;

interface ClubClaimDeps {
  firestore: () => FirebaseFirestore.Firestore;
  serverTimestamp: () => FirebaseFirestore.FieldValue;
  checkRateLimit?: (
    db: FirebaseFirestore.Firestore,
    uid: string,
    action: string
  ) => Promise<void>;
}

const defaultDeps: ClubClaimDeps = {
  firestore: () => admin.firestore(),
  serverTimestamp: () => admin.firestore.FieldValue.serverTimestamp(),
  checkRateLimit: defaultCheckRateLimit,
};

export interface AdminDecideClubClaimResponse {
  requestId: string;
  clubId: string;
  decision: "approve" | "reject";
  status: "approved" | "rejected";
}

/**
 * Creates or reuses a pending organizer claim request for an unclaimed club.
 * @param {CallableRequest<unknown>} request Callable request.
 * @param {ClubClaimDeps} deps Injectable dependencies.
 * @return {Promise<RequestClubClaimCallableResponse>} Claim request status.
 */
export async function requestClubClaimHandler(
  request: CallableRequest<unknown>,
  deps: ClubClaimDeps = defaultDeps
): Promise<RequestClubClaimCallableResponse> {
  const requesterUid = requireAuth(request);
  const data = validateCallableWithAjv<RequestClubClaimCallablePayload>(
    request,
    validateRequestClubClaimCallablePayload,
    normalizeRequestClubClaimPayload
  );
  const db = deps.firestore();
  await deps.checkRateLimit?.(db, requesterUid, "requestClubClaim");

  const requestId = clubClaimRequestId(data.clubId, requesterUid);
  const clubRef = db.collection("clubs").doc(data.clubId);
  const requestRef = db.collection("clubClaimRequests").doc(requestId);
  const ownerLockRef = db.collection("clubHostClaims").doc(requesterUid);
  const deletedUserRef = db.collection("deletedUsers").doc(requesterUid);

  await db.runTransaction(async (tx) => {
    const [clubSnap, requestSnap, ownerLockSnap, deletedUserSnap] =
      await Promise.all([
        tx.get(clubRef),
        tx.get(requestRef),
        tx.get(ownerLockRef),
        tx.get(deletedUserRef),
      ]);

    if (deletedUserSnap.exists) {
      throw new HttpsError(
        "failed-precondition",
        "This account cannot claim organizer listings."
      );
    }
    if (ownerLockSnap.exists) {
      throw new HttpsError(
        "failed-precondition",
        "This account already owns a club."
      );
    }
    if (!clubSnap.exists) {
      throw new HttpsError("not-found", "Organizer listing not found.");
    }

    const club = requireDoc<ClubDocument>(clubSnap, "ClubDocument");
    assertClubCanBeClaimed(club);

    if (requestSnap.exists) {
      const existing = requireDoc<ClubClaimRequestDocument>(
        requestSnap,
        "ClubClaimRequestDocument"
      );
      if (existing.status === "pending") {
        if (claimRequestOwnsPendingState(club, requestId)) return;
        throw new HttpsError(
          "failed-precondition",
          "Another organizer claim is already under review."
        );
      }
      if (existing.status === "approved") {
        throw new HttpsError(
          "failed-precondition",
          "This claim request has already been approved."
        );
      }
    }
    if (club.claim?.state === "claimPending") {
      throw new HttpsError(
        "failed-precondition",
        "Another organizer claim is already under review."
      );
    }

    const timestamp = deps.serverTimestamp();
    tx.set(requestRef, {
      requestId,
      clubId: data.clubId,
      requesterUid,
      requesterName: data.requesterName,
      requesterRole: data.requesterRole,
      businessEmail: data.businessEmail ?? null,
      businessPhone: data.businessPhone ?? null,
      proofUrls: data.proofUrls ?? [],
      message: data.message ?? null,
      status: "pending",
      createdAt: timestamp,
      updatedAt: timestamp,
      decidedAt: null,
      decidedByUid: null,
      decisionReason: null,
      previousRequestId: null,
    });
    tx.update(clubRef, {
      claim: {
        state: "claimPending",
        claimHref: club.claim?.claimHref ?? "/host/#founding-hosts",
        lastClaimRequestId: requestId,
      },
    });
  });

  return {requestId, status: "pending"};
}

/**
 * Approves or rejects an organizer listing claim request.
 * @param {CallableRequest<unknown>} request Callable request.
 * @param {ClubClaimDeps} deps Injectable dependencies.
 * @return {Promise<AdminDecideClubClaimResponse>} Decision status.
 */
export async function adminDecideClubClaimHandler(
  request: CallableRequest<unknown>,
  deps: ClubClaimDeps = defaultDeps
): Promise<AdminDecideClubClaimResponse> {
  const adminContext = requireAdminRole(request, claimReviewRoles);
  const data = validateCallableWithAjv<AdminDecideClubClaimCallablePayload>(
    request,
    validateAdminDecideClubClaimCallablePayload,
    normalizeAdminDecideClubClaimPayload
  );
  const db = deps.firestore();
  await deps.checkRateLimit?.(
    db,
    adminContext.uid,
    "adminDecideClubClaim"
  );

  let response: AdminDecideClubClaimResponse | null = null;

  await db.runTransaction(async (tx) => {
    const requestRef = db.collection("clubClaimRequests").doc(data.requestId);
    const requestSnap = await tx.get(requestRef);
    if (!requestSnap.exists) {
      throw new HttpsError("not-found", "Club claim request not found.");
    }
    const claimRequest = requireDoc<ClubClaimRequestDocument>(
      requestSnap,
      "ClubClaimRequestDocument"
    );
    if (claimRequest.status !== "pending") {
      throw new HttpsError(
        "failed-precondition",
        "This claim request has already been reviewed."
      );
    }

    const clubRef = db.collection("clubs").doc(claimRequest.clubId);

    if (data.decision === "reject") {
      const clubSnap = await tx.get(clubRef);
      const club = clubSnap.exists ?
        requireDoc<ClubDocument>(clubSnap, "ClubDocument") :
        null;
      const timestamp = deps.serverTimestamp();
      tx.set(requestRef, {
        status: "rejected",
        updatedAt: timestamp,
        decidedAt: timestamp,
        decidedByUid: adminContext.uid,
        decisionReason: data.decisionReason ?? null,
      }, {merge: true});
      if (club && claimRequestOwnsPendingState(club, data.requestId)) {
        tx.update(clubRef, {
          claim: {
            state: "unclaimed",
            claimHref: club.claim?.claimHref ?? "/host/#founding-hosts",
            lastClaimRequestId: data.requestId,
          },
        });
      }
      setActivityNotificationInTransaction(tx, db, {
        id: activityNotificationId("clubUpdate", `${data.requestId}_rejected`),
        uid: claimRequest.requesterUid,
        type: "clubUpdate",
        title: "Organizer claim update",
        body: club?.name ?
          `Catch could not verify the claim for ${club.name}.` :
          "Catch could not verify this organizer claim.",
        createdAt: timestamp,
        clubId: claimRequest.clubId,
        actorUid: adminContext.uid,
      });
      setAdminAuditLogInTransaction(tx, db, adminContext, {
        action: "adminDecideClubClaim",
        targetPath: requestRef.path,
        request,
        before: {status: claimRequest.status},
        after: {
          status: "rejected",
          decision: data.decision,
          clubId: claimRequest.clubId,
        },
        note: data.decisionReason,
        serverTimestamp: deps.serverTimestamp,
      });
      response = {
        requestId: data.requestId,
        clubId: claimRequest.clubId,
        decision: "reject",
        status: "rejected",
      };
      return;
    }

    const requesterRef = db.collection("users").doc(claimRequest.requesterUid);
    const deletedUserRef = db
      .collection("deletedUsers")
      .doc(claimRequest.requesterUid);
    const ownerLockRef = db
      .collection("clubHostClaims")
      .doc(claimRequest.requesterUid);
    const membershipRef = db.collection("clubMemberships").doc(
      clubMembershipId(claimRequest.clubId, claimRequest.requesterUid)
    );

    const [
      clubSnap,
      requesterSnap,
      deletedUserSnap,
      ownerLockSnap,
    ] = await Promise.all([
      tx.get(clubRef),
      tx.get(requesterRef),
      tx.get(deletedUserRef),
      tx.get(ownerLockRef),
    ]);

    if (!clubSnap.exists) {
      throw new HttpsError("not-found", "Organizer listing not found.");
    }
    if (!requesterSnap.exists) {
      throw new HttpsError("not-found", "Requesting user profile not found.");
    }
    if (deletedUserSnap.exists) {
      throw new HttpsError(
        "failed-precondition",
        "This account cannot claim organizer listings."
      );
    }
    if (ownerLockSnap.exists) {
      throw new HttpsError(
        "failed-precondition",
        "This account already owns a club."
      );
    }

    const club = requireDoc<ClubDocument>(clubSnap, "ClubDocument");
    assertClubCanBeClaimed(club);
    if (club.claim?.state === "claimPending" &&
        !claimRequestOwnsPendingState(club, data.requestId)) {
      throw new HttpsError(
        "failed-precondition",
        "This claim request is no longer the active organizer claim."
      );
    }
    const user = requireDoc<UserProfileDocument>(
      requesterSnap,
      "UserProfileDocument"
    );
    if (user.profileComplete !== true) {
      throw new HttpsError(
        "failed-precondition",
        "The requester must complete their profile before claiming."
      );
    }

    const timestamp = deps.serverTimestamp();
    const displayName = publicDisplayName(user);
    const avatarUrl = publicAvatarUrl(user);
    const ownerProfile = {
      uid: claimRequest.requesterUid,
      displayName,
      avatarUrl,
      role: "owner",
    };

    tx.update(clubRef, {
      ownerUserId: claimRequest.requesterUid,
      hostUserId: claimRequest.requesterUid,
      hostName: displayName,
      hostAvatarUrl: avatarUrl,
      hostUserIds: [claimRequest.requesterUid],
      hostProfiles: [ownerProfile],
      appVisibility: "discoverable",
      ownership: {
        state: "claimed",
        ownerUserId: claimRequest.requesterUid,
        primaryHostUserId: claimRequest.requesterUid,
        hostUserIds: [claimRequest.requesterUid],
        claimedAt: timestamp,
        claimedByUid: claimRequest.requesterUid,
      },
      claim: {
        state: "claimed",
        claimHref: null,
        lastClaimRequestId: data.requestId,
      },
      provenance: {
        origin: club.provenance?.origin ?? "adminSeed",
        sourceConfidence: "ownerVerified",
        verificationStatus: "ownerVerified",
        lastVerifiedAt: timestamp,
      },
    });
    tx.set(requestRef, {
      status: "approved",
      updatedAt: timestamp,
      decidedAt: timestamp,
      decidedByUid: adminContext.uid,
      decisionReason: data.decisionReason ?? null,
    }, {merge: true});
    tx.create(ownerLockRef, {
      uid: claimRequest.requesterUid,
      clubId: claimRequest.clubId,
      createdAt: timestamp,
    });
    tx.set(membershipRef, activeClubMembershipPatch({
      clubId: claimRequest.clubId,
      uid: claimRequest.requesterUid,
      role: "owner",
    }), {merge: true});
    setActivityNotificationInTransaction(tx, db, {
      id: activityNotificationId("clubUpdate", data.requestId),
      uid: claimRequest.requesterUid,
      type: "clubUpdate",
      title: "Your organizer profile is ready",
      body: `Open Catch to finish setup for ${club.name}.`,
      createdAt: timestamp,
      clubId: claimRequest.clubId,
      actorUid: adminContext.uid,
    });
    setAdminAuditLogInTransaction(tx, db, adminContext, {
      action: "adminDecideClubClaim",
      targetPath: requestRef.path,
      request,
      before: {status: claimRequest.status},
      after: {
        status: "approved",
        decision: data.decision,
        clubId: claimRequest.clubId,
        requesterUid: claimRequest.requesterUid,
      },
      note: data.decisionReason,
      serverTimestamp: deps.serverTimestamp,
    });

    response = {
      requestId: data.requestId,
      clubId: claimRequest.clubId,
      decision: "approve",
      status: "approved",
    };
  });

  if (!response) {
    throw new HttpsError("internal", "Claim decision did not complete.");
  }
  return response;
}

/**
 * Raises an HttpsError when a club is not eligible for claim requests.
 * @param {ClubDocument} club Club document to inspect.
 */
function assertClubCanBeClaimed(club: ClubDocument) {
  if (club.archived === true || club.status === "archived") {
    throw new HttpsError(
      "failed-precondition",
      "Archived organizer listings cannot be claimed."
    );
  }
  if (
    typeof club.ownerUserId === "string" ||
    typeof club.hostUserId === "string" ||
    club.ownership?.state === "claimed" ||
    club.claim?.state === "claimed" ||
    club.claim?.state === "verified"
  ) {
    throw new HttpsError(
      "failed-precondition",
      "This organizer listing has already been claimed."
    );
  }
  if (club.claim?.state === "suppressed") {
    throw new HttpsError(
      "failed-precondition",
      "This organizer listing is not available for claims."
    );
  }
}

function claimRequestOwnsPendingState(
  club: ClubDocument,
  requestId: string
): boolean {
  return club.claim?.state === "claimPending" &&
    club.claim?.lastClaimRequestId === requestId;
}

/**
 * Trims nullable text fields before request-club-claim schema validation.
 * @param {unknown} value Raw callable payload.
 * @return {Record<string, unknown>} Normalized payload candidate.
 */
function normalizeRequestClubClaimPayload(
  value: unknown
): Record<string, unknown> {
  const data = isRecord(value) ? value : {};
  return {
    ...data,
    clubId: trimString(data.clubId),
    requesterName: trimString(data.requesterName),
    requesterRole: trimString(data.requesterRole),
    businessEmail: nullableTrimmedString(data.businessEmail),
    businessPhone: nullableTrimmedString(data.businessPhone),
    proofUrls: uniqueStrings(
      Array.isArray(data.proofUrls) ?
        data.proofUrls.map((url) => trimString(url)) :
        []
    ),
    message: nullableTrimmedString(data.message),
  };
}

/**
 * Trims admin decision text fields before schema validation.
 * @param {unknown} value Raw callable payload.
 * @return {Record<string, unknown>} Normalized payload candidate.
 */
function normalizeAdminDecideClubClaimPayload(
  value: unknown
): Record<string, unknown> {
  const data = isRecord(value) ? value : {};
  return {
    ...data,
    requestId: trimString(data.requestId),
    decision: trimString(data.decision),
    decisionReason: nullableTrimmedString(data.decisionReason),
  };
}

/**
 * Builds a stable claim request id for a club and requester pair.
 * @param {string} clubId Organizer listing id.
 * @param {string} uid Requester user id.
 * @return {string} Stable claim request id.
 */
function clubClaimRequestId(clubId: string, uid: string): string {
  const hash = crypto.createHash("sha256")
    .update(`${clubId}:${uid}`)
    .digest("hex")
    .slice(0, 24);
  return `club_claim_${hash}`;
}

/**
 * Checks whether a value can be treated as a plain object payload.
 * @param {unknown} value Value to inspect.
 * @return {boolean} True when value is a non-array object.
 */
function isRecord(value: unknown): value is Record<string, unknown> {
  return typeof value === "object" && value !== null && !Array.isArray(value);
}

/**
 * Trims string values while preserving non-string values for validation.
 * @param {unknown} value Value to normalize.
 * @return {unknown} Trimmed string or original value.
 */
function trimString(value: unknown): unknown {
  return typeof value === "string" ? value.trim() : value;
}

/**
 * Normalizes optional text values to either trimmed text or null.
 * @param {unknown} value Value to normalize.
 * @return {string | null} Trimmed string or null.
 */
function nullableTrimmedString(value: unknown): string | null {
  if (value == null) return null;
  if (typeof value !== "string") return null;
  const trimmed = value.trim();
  return trimmed.length > 0 ? trimmed : null;
}

/**
 * Removes blank and duplicate strings from an array.
 * @param {unknown[]} values Values to filter.
 * @return {string[]} Unique non-empty strings.
 */
function uniqueStrings(values: unknown[]): string[] {
  return [...new Set(values.filter((value): value is string =>
    typeof value === "string" && value.length > 0
  ))];
}

export const requestClubClaim = onCall(
  appCheckCallableOptions,
  (request) => requestClubClaimHandler(request)
);

export const adminDecideClubClaim = onCall(
  appCheckCallableOptions,
  (request) => adminDecideClubClaimHandler(request)
);
