import {onCall, CallableRequest, HttpsError} from
  "firebase-functions/v2/https";
import * as admin from "firebase-admin";
import {appCheckCallableOptions} from "../shared/callableOptions";
import {requireAuth} from "../shared/auth";
import {
  ClubDocument,
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
 * Starts or reuses a direct conversation between a viewer and a club host.
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
  const matchId = `${user1Id}_${user2Id}`;
  const clubRef = db.collection("clubs").doc(data.clubId);
  const matchRef = db.collection("matches").doc(matchId);
  const callerDeletedRef = db.collection("deletedUsers").doc(callerUid);
  const hostDeletedRef = db.collection("deletedUsers").doc(data.hostUid);

  await db.runTransaction(async (tx) => {
    const [clubSnap, matchSnap, callerDeletedSnap, hostDeletedSnap] =
      await Promise.all([
        tx.get(clubRef),
        tx.get(matchRef),
        tx.get(callerDeletedRef),
        tx.get(hostDeletedRef),
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
      if (match.status === "blocked") {
        throw new HttpsError(
          "failed-precondition",
          "This conversation is closed."
        );
      }
      return;
    }

    const now = deps.serverTimestamp() as unknown as
      FirebaseFirestore.Timestamp;
    const matchDoc: MatchDocument = {
      user1Id,
      user2Id,
      participantIds: [user1Id, user2Id],
      eventIds: [],
      createdAt: now,
      lastMessageAt: null,
      lastMessagePreview: `Ask about ${club.name}`,
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

  return {matchId};
}

export const startClubHostConversation = onCall(
  appCheckCallableOptions,
  (request) => startClubHostConversationHandler(request)
);
