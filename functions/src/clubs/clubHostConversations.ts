import {onCall, CallableRequest, HttpsError} from
  "firebase-functions/v2/https";
import * as admin from "firebase-admin";
import {createHash} from "node:crypto";
import {appCheckCallableOptions} from "../shared/callableOptions";
import {requireAuth} from "../shared/auth";
import {
  ClubDocument,
  EventDocument,
  MatchDocument,
} from "../shared/generated/firestoreAdminTypes";
import {checkRateLimit as defaultCheckRateLimit} from "../shared/rateLimit";
import {StartClubHostConversationCallablePayload} from
  "../shared/generated/startClubHostConversationCallablePayload";
import {
  validateStartClubHostConversationCallablePayload,
} from "../shared/generated/schemaValidators";
import {clubHostUserIds} from "../shared/clubHosts";
import {assertNoBlockingRelationshipInTransaction} from "../safety/blocking";
import {normalizeClubHostPayload} from "./clubPayloadNormalization";
import {requireDoc, validateCallableWithAjv} from "../shared/validation";

interface ClubHostConversationDeps {
  firestore: () => FirebaseFirestore.Firestore;
  serverTimestamp: () => FirebaseFirestore.FieldValue;
  checkRateLimit?: (
    db: FirebaseFirestore.Firestore,
    uid: string,
    action: string
  ) => Promise<void>;
}

const defaultDeps: ClubHostConversationDeps = {
  firestore: () => admin.firestore(),
  serverTimestamp: () => admin.firestore.FieldValue.serverTimestamp(),
  checkRateLimit: defaultCheckRateLimit,
};

/**
 * Starts or reuses a scoped direct conversation between a viewer and a club
 * host. Event inquiries never reuse a dating match or a general club inquiry.
 * @param {CallableRequest<unknown>} request Callable request.
 * @param {ClubHostConversationDeps} deps Injectable dependencies for tests.
 * @return {Promise<{matchId: string}>} Match-backed conversation id.
 */
export async function startClubHostConversationHandler(
  request: CallableRequest<unknown>,
  deps: ClubHostConversationDeps = defaultDeps
): Promise<{matchId: string}> {
  const callerUid = requireAuth(request);
  const data =
    validateCallableWithAjv<StartClubHostConversationCallablePayload>(
      request,
      validateStartClubHostConversationCallablePayload,
      normalizeClubHostPayload
    );
  if (callerUid === data.hostUid) {
    throw new HttpsError(
      "failed-precondition",
      "You cannot message yourself."
    );
  }

  const db = deps.firestore();
  await deps.checkRateLimit?.(db, callerUid, "startClubHostConversation");
  const [user1Id, user2Id] = [callerUid, data.hostUid].sort();
  const legacyPairMatchId = `${user1Id}_${user2Id}`;
  const scopedMatchId = clubHostInquiryMatchId({
    clubId: data.clubId,
    eventId: data.eventId,
    user1Id,
    user2Id,
  });
  let resolvedMatchId = scopedMatchId;
  const clubRef = db.collection("clubs").doc(data.clubId);
  const matchRef = db.collection("matches").doc(scopedMatchId);
  const legacyPairMatchRef = db.collection("matches").doc(legacyPairMatchId);
  const eventRef = data.eventId ?
    db.collection("events").doc(data.eventId) : null;
  const callerDeletedRef = db.collection("deletedUsers").doc(callerUid);
  const hostDeletedRef = db.collection("deletedUsers").doc(data.hostUid);

  await db.runTransaction(async (tx) => {
    const [
      clubSnap,
      matchSnap,
      legacyPairMatchSnap,
      callerDeletedSnap,
      hostDeletedSnap,
      eventSnap,
    ] =
      await Promise.all([
        tx.get(clubRef),
        tx.get(matchRef),
        tx.get(legacyPairMatchRef),
        tx.get(callerDeletedRef),
        tx.get(hostDeletedRef),
        eventRef ? tx.get(eventRef) : Promise.resolve(null),
      ]);

    if (callerDeletedSnap.exists || hostDeletedSnap.exists) {
      throw new HttpsError(
        "failed-precondition",
        "This conversation is unavailable."
      );
    }
    if (!clubSnap.exists) {
      throw new HttpsError("not-found", "Club not found.");
    }
    const club = requireDoc<ClubDocument>(
      clubSnap,
      "ClubDocument"
    );
    if (!clubHostUserIds(club).includes(data.hostUid)) {
      throw new HttpsError(
        "permission-denied",
        "That user is not a host for this club."
      );
    }
    if (eventRef) {
      if (!eventSnap?.exists) {
        throw new HttpsError("not-found", "Event not found.");
      }
      const event = requireDoc<EventDocument>(eventSnap, "EventDocument");
      if (event.clubId !== data.clubId) {
        throw new HttpsError(
          "failed-precondition",
          "That event does not belong to this club."
        );
      }
    }
    await assertNoBlockingRelationshipInTransaction(
      tx,
      db,
      callerUid,
      [data.hostUid]
    );

    if (matchSnap.exists) {
      const match = requireDoc<MatchDocument>(
        matchSnap,
        "MatchDocument"
      );
      if (match.conversationType !== "clubHostInquiry" ||
          match.clubId !== data.clubId) {
        throw new HttpsError(
          "failed-precondition",
          "This conversation id is unavailable."
        );
      }
      if (match.status === "blocked") {
        throw new HttpsError(
          "failed-precondition",
          "This conversation is closed."
        );
      }
      return;
    }

    if (!data.eventId && legacyPairMatchSnap.exists) {
      const legacyMatch = requireDoc<MatchDocument>(
        legacyPairMatchSnap,
        "MatchDocument"
      );
      if (legacyMatch.conversationType === "clubHostInquiry" &&
          legacyMatch.clubId === data.clubId) {
        if (legacyMatch.status === "blocked") {
          throw new HttpsError(
            "failed-precondition",
            "This conversation is closed."
          );
        }
        resolvedMatchId = legacyPairMatchId;
        return;
      }
    }

    const now = deps.serverTimestamp() as unknown as
      FirebaseFirestore.Timestamp;
    const matchDoc: MatchDocument = {
      user1Id,
      user2Id,
      participantIds: [user1Id, user2Id],
      eventIds: data.eventId ? [data.eventId] : [],
      createdAt: now,
      lastMessageAt: null,
      lastMessagePreview: null,
      lastMessageSenderId: null,
      unreadCounts: {[user1Id]: 0, [user2Id]: 0},
      status: "active",
      blockedBy: null,
      blockedAt: null,
      conversationType: "clubHostInquiry",
      clubId: data.clubId,
    };
    tx.create(matchRef, matchDoc);
  });

  return {matchId: resolvedMatchId};
}

/**
 * Returns a stable opaque id for one club/event/participant inquiry scope.
 * @param {object} scope Canonical host-inquiry identity.
 * @return {string} Firestore-safe deterministic match id.
 */
export function clubHostInquiryMatchId(scope: {
  clubId: string;
  eventId?: string;
  user1Id: string;
  user2Id: string;
}): string {
  const digest = createHash("sha256")
    .update(JSON.stringify([
      scope.clubId,
      scope.eventId ?? null,
      scope.user1Id,
      scope.user2Id,
    ]))
    .digest("hex")
    .slice(0, 40);
  return `clubHostInquiry_${digest}`;
}

export const startClubHostConversation = onCall(
  appCheckCallableOptions,
  (request) => startClubHostConversationHandler(request)
);
