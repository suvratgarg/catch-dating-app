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
  OrganizerDocument,
} from "../shared/generated/firestoreAdminTypes";
import {checkRateLimit as defaultCheckRateLimit} from "../shared/rateLimit";
import {StartClubHostConversationCallablePayload} from
  "../shared/generated/startClubHostConversationCallablePayload";
import {
  validateStartClubHostConversationCallablePayload,
  validateStartOrganizerConversationCallablePayload,
} from "../shared/generated/schemaValidators";
import {clubHostUserIds} from "../shared/clubHosts";
import {organizerManagerUserIds} from "../shared/organizerHosts";
import {assertNoBlockingRelationshipInTransaction} from "../safety/blocking";
import {normalizeClubHostPayload} from "./clubPayloadNormalization";
import {StartOrganizerConversationCallablePayload} from
  "../shared/generated/startOrganizerConversationCallablePayload";
import {normalizeOrganizerHostPayload} from
  "../organizers/organizerPayloadNormalization";
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
  const legacyData =
    validateCallableWithAjv<StartClubHostConversationCallablePayload>(
      request,
      validateStartClubHostConversationCallablePayload,
      normalizeClubHostPayload
    );
  return startOrganizerConversationCore(callerUid, {
    organizerId: legacyData.clubId,
    hostUid: legacyData.hostUid,
    eventId: legacyData.eventId,
  }, deps, "startClubHostConversation");
}

/** Starts or reuses a canonical organizer-host conversation. */
export async function startOrganizerConversationHandler(
  request: CallableRequest<unknown>,
  deps: ClubHostConversationDeps = defaultDeps
): Promise<{matchId: string}> {
  const callerUid = requireAuth(request);
  const data =
    validateCallableWithAjv<StartOrganizerConversationCallablePayload>(
      request,
      validateStartOrganizerConversationCallablePayload,
      normalizeOrganizerHostPayload
    );
  return startOrganizerConversationCore(
    callerUid,
    data,
    deps,
    "startOrganizerConversation"
  );
}

async function startOrganizerConversationCore(
  callerUid: string,
  data: StartOrganizerConversationCallablePayload,
  deps: ClubHostConversationDeps,
  rateLimitAction: "startClubHostConversation" | "startOrganizerConversation"
): Promise<{matchId: string}> {
  if (callerUid === data.hostUid) {
    throw new HttpsError(
      "failed-precondition",
      "You cannot message yourself."
    );
  }

  const db = deps.firestore();
  await deps.checkRateLimit?.(db, callerUid, rateLimitAction);
  const [user1Id, user2Id] = [callerUid, data.hostUid].sort();
  const legacyPairMatchId = `${user1Id}_${user2Id}`;
  const scopedMatchId = clubHostInquiryMatchId({
    clubId: data.organizerId,
    eventId: data.eventId,
    user1Id,
    user2Id,
  });
  let resolvedMatchId = scopedMatchId;
  const organizerRef = db.collection("organizers").doc(data.organizerId);
  const clubRef = db.collection("clubs").doc(data.organizerId);
  const matchRef = db.collection("matches").doc(scopedMatchId);
  const legacyPairMatchRef = db.collection("matches").doc(legacyPairMatchId);
  const eventRef = data.eventId ?
    db.collection("events").doc(data.eventId) : null;
  const callerDeletedRef = db.collection("deletedUsers").doc(callerUid);
  const hostDeletedRef = db.collection("deletedUsers").doc(data.hostUid);

  await db.runTransaction(async (tx) => {
    const [
      organizerSnap,
      clubSnap,
      matchSnap,
      legacyPairMatchSnap,
      callerDeletedSnap,
      hostDeletedSnap,
      eventSnap,
    ] =
      await Promise.all([
        tx.get(organizerRef),
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
    if (!organizerSnap.exists && !clubSnap.exists) {
      throw new HttpsError("not-found", "Organizer not found.");
    }
    const hostUserIds = organizerSnap.exists ?
      organizerManagerUserIds(requireDoc<OrganizerDocument>(
        organizerSnap,
        "OrganizerDocument"
      )) :
      clubHostUserIds(requireDoc<ClubDocument>(clubSnap, "ClubDocument"));
    if (!hostUserIds.includes(data.hostUid)) {
      throw new HttpsError(
        "permission-denied",
        "That user is not a manager for this organizer."
      );
    }
    if (eventRef) {
      if (!eventSnap?.exists) {
        throw new HttpsError("not-found", "Event not found.");
      }
      const event = requireDoc<EventDocument>(eventSnap, "EventDocument");
      if ((event.organizerId ?? event.clubId) !== data.organizerId) {
        throw new HttpsError(
          "failed-precondition",
          "That event does not belong to this organizer."
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
          (match.organizerId ?? match.clubId) !== data.organizerId) {
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
      const legacyOrganizerId = legacyMatch.organizerId ?? legacyMatch.clubId;
      if (legacyMatch.conversationType === "clubHostInquiry" &&
          legacyOrganizerId === data.organizerId) {
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
      organizerId: data.organizerId,
      clubId: data.organizerId,
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

export const startOrganizerConversation = onCall(
  appCheckCallableOptions,
  (request) => startOrganizerConversationHandler(request)
);
