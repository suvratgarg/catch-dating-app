import {createHash} from "node:crypto";
import * as admin from "firebase-admin";
import * as logger from "firebase-functions/logger";
import {onDocumentCreated, onDocumentWritten} from
  "firebase-functions/v2/firestore";
import {CallableRequest, HttpsError, onCall} from
  "firebase-functions/v2/https";
import {onSchedule} from "firebase-functions/v2/scheduler";
import {requireAuth} from "../shared/auth";
import {appCheckCallableOptionsWithSecrets} from
  "../shared/callableOptions";
import {normalizePayloadStrings} from
  "../shared/callablePayloadNormalization";
import {
  CrossPathsInvitationDocument,
  CrossPathsShowcaseEligibilityDocument,
  EventCrossPathsConsentDocument,
  EventDocument,
  EventParticipationDocument,
  PublicProfileDocument,
  UserProfileDocument,
} from "../shared/generated/firestoreAdminTypes";
import {CancelCrossPathsInvitationOrPlanCallablePayload} from
  "../shared/generated/cancelCrossPathsInvitationOrPlanCallablePayload";
import {CancelCrossPathsInvitationOrPlanCallableResponse} from
  "../shared/generated/cancelCrossPathsInvitationOrPlanCallableResponse";
import {RespondCrossPathsInvitationCallablePayload} from
  "../shared/generated/respondCrossPathsInvitationCallablePayload";
import {RespondCrossPathsInvitationCallableResponse} from
  "../shared/generated/respondCrossPathsInvitationCallableResponse";
import {SendCrossPathsInvitationCallablePayload} from
  "../shared/generated/sendCrossPathsInvitationCallablePayload";
import {SendCrossPathsInvitationCallableResponse} from
  "../shared/generated/sendCrossPathsInvitationCallableResponse";
import {
  validateCancelCrossPathsInvitationOrPlanCallablePayload,
  validateCancelCrossPathsInvitationOrPlanCallableResponse,
  validateRespondCrossPathsInvitationCallablePayload,
  validateRespondCrossPathsInvitationCallableResponse,
  validateSendCrossPathsInvitationCallablePayload,
  validateSendCrossPathsInvitationCallableResponse,
} from "../shared/generated/schemaValidators";
import {
  activityNotificationId,
  allowsPushPreference,
  sendFcmNotification,
  setActivityNotificationInTransaction,
} from "../shared/notifications";
import {checkRateLimit as defaultCheckRateLimit} from "../shared/rateLimit";
import {isReciprocallyEligible} from
  "../shared/relationshipEligibility";
import {requireDoc, validateCallableWithAjv} from "../shared/validation";
import {
  crossPathsSuggestionSigningKey,
  verifyCrossPathsSuggestionToken,
} from "./getCrossPathsSuggestions";
import {
  effectiveCrossPathsShowcaseEligibility,
  evaluateCrossPathsShowcaseReadiness,
} from "./showcaseEligibility";

const minimumInvitationLeadMillis = 6 * 60 * 60 * 1000;
const responseBufferMillis = 30 * 60 * 1000;
const eventPlanGraceMillis = 24 * 60 * 60 * 1000;
const maximumPendingInvitationsPerRecipient = 3;

type InvalidationReason = NonNullable<
  CrossPathsInvitationDocument["invalidationReason"]
>;

interface InvitationDeps {
  firestore: () => FirebaseFirestore.Firestore;
  now: () => FirebaseFirestore.Timestamp;
  checkRateLimit?: (
    db: FirebaseFirestore.Firestore,
    uid: string,
    action: string
  ) => Promise<void>;
  verifyToken?: (
    token: string,
    nowMillis: number
  ) => ReturnType<typeof verifyCrossPathsSuggestionToken>;
}

const defaultDeps: InvitationDeps = {
  firestore: () => admin.firestore(),
  now: () => admin.firestore.Timestamp.now(),
  checkRateLimit: defaultCheckRateLimit,
  verifyToken: verifyCrossPathsSuggestionToken,
};

export function crossPathsInvitationId(
  eventId: string,
  senderUid: string
): string {
  return `cp_${sha256(`${eventId}\u0000${senderUid}`).slice(0, 48)}`;
}

export function crossPathsEventPlanId(
  eventId: string,
  userA: string,
  userB: string
): string {
  const pair = [userA, userB].sort().join("\u0000");
  return `cpp_${sha256(`${eventId}\u0000${pair}`).slice(0, 48)}`;
}

/** Sends one message-free, event-scoped invitation. */
export async function sendCrossPathsInvitationHandler(
  request: CallableRequest<unknown>,
  deps: InvitationDeps = defaultDeps
): Promise<SendCrossPathsInvitationCallableResponse> {
  const senderUid = requireAuth(request);
  const data = validateCallableWithAjv<SendCrossPathsInvitationCallablePayload>(
    request,
    validateSendCrossPathsInvitationCallablePayload,
    normalizeSendPayload
  );
  if (senderUid === data.recipientUid) throw unavailable();
  const db = deps.firestore();
  await deps.checkRateLimit?.(db, senderUid, "sendCrossPathsInvitation");
  const now = deps.now();
  const token = deps.verifyToken?.(data.suggestionToken, now.toMillis());
  if (
    !token ||
    token.viewerUid !== senderUid ||
    token.candidateUid !== data.recipientUid ||
    token.eventId !== data.eventId
  ) {
    throw unavailable();
  }
  if (await hasUnsafeReportOrModeration(db, senderUid, data.recipientUid)) {
    throw unavailable();
  }

  const invitationId = crossPathsInvitationId(data.eventId, senderUid);
  const invitationRef = db.collection("crossPathsInvitations")
    .doc(invitationId);
  let senderName = "Someone";
  let expiresAt = now;
  await db.runTransaction(async (tx) => {
    const refs = invitationRefs(db, data.eventId, senderUid, data.recipientUid);
    const [
      existing,
      eventSnap,
      senderParticipationSnap,
      recipientParticipationSnap,
      senderConsentSnap,
      recipientConsentSnap,
      senderUserSnap,
      recipientUserSnap,
      senderPublicSnap,
      recipientPublicSnap,
      senderShowcaseSnap,
      recipientShowcaseSnap,
      pendingForRecipient,
      senderPlans,
      recipientPlans,
      outgoingBlock,
      incomingBlock,
    ] = await Promise.all([
      tx.get(invitationRef),
      tx.get(refs.event),
      tx.get(refs.senderParticipation),
      tx.get(refs.recipientParticipation),
      tx.get(refs.senderConsent),
      tx.get(refs.recipientConsent),
      tx.get(refs.senderUser),
      tx.get(refs.recipientUser),
      tx.get(refs.senderPublic),
      tx.get(refs.recipientPublic),
      tx.get(refs.senderShowcase),
      tx.get(refs.recipientShowcase),
      tx.get(db.collection("crossPathsInvitations")
        .where("recipientUid", "==", data.recipientUid)),
      tx.get(db.collection("crossPathsInvitations")
        .where("participantIds", "array-contains", senderUid)),
      tx.get(db.collection("crossPathsInvitations")
        .where("participantIds", "array-contains", data.recipientUid)),
      tx.get(db.collection("blocks").doc(`${senderUid}__${data.recipientUid}`)),
      tx.get(db.collection("blocks").doc(`${data.recipientUid}__${senderUid}`)),
    ]);
    if (existing.exists || outgoingBlock.exists || incomingBlock.exists) {
      throw unavailable();
    }
    const event = validUpcomingEvent(eventSnap, now, true);
    const senderParticipation = signedUpParticipation(
      senderParticipationSnap,
      data.eventId,
      senderUid
    );
    const recipientParticipation = signedUpParticipation(
      recipientParticipationSnap,
      data.eventId,
      data.recipientUid
    );
    if (!senderParticipation || !recipientParticipation) throw unavailable();
    const senderConsent = effectiveConsent(
      senderConsentSnap,
      data.eventId,
      senderUid
    );
    const recipientConsent = effectiveConsent(
      recipientConsentSnap,
      data.eventId,
      data.recipientUid
    );
    if (!senderConsent || !recipientConsent) throw unavailable();
    const sender = activeUser(senderUserSnap);
    const recipient = activeUser(recipientUserSnap);
    if (
      sender.prefsShowInCrossPaths !== true ||
      recipient.prefsShowInCrossPaths !== true ||
      !isReciprocallyEligible({
        viewer: sender,
        candidate: recipient,
        nowMillis: now.toMillis(),
      }) ||
      !hasEligibleShowcase(senderPublicSnap, senderShowcaseSnap) ||
      !hasEligibleShowcase(recipientPublicSnap, recipientShowcaseSnap)
    ) {
      throw unavailable();
    }
    const pendingCount = pendingForRecipient.docs.filter((doc) => {
      const row = doc.data();
      return row.eventId === data.eventId && row.status === "pending" &&
        timestampMillis(row.expiresAt) > now.toMillis();
    }).length;
    if (pendingCount >= maximumPendingInvitationsPerRecipient) {
      throw unavailable();
    }
    if (
      hasAcceptedPlan(senderPlans.docs, data.eventId) ||
      hasAcceptedPlan(recipientPlans.docs, data.eventId)
    ) {
      throw unavailable();
    }
    expiresAt = admin.firestore.Timestamp.fromMillis(
      event.startTime.toMillis() - responseBufferMillis
    );
    senderName = sender.name;
    const invitation: CrossPathsInvitationDocument = {
      eventId: data.eventId,
      senderUid,
      recipientUid: data.recipientUid,
      participantIds: [senderUid, data.recipientUid],
      status: "pending",
      createdAt: now,
      updatedAt: now,
      expiresAt,
      respondedAt: null,
      cancelledAt: null,
      invalidatedAt: null,
      invalidationReason: null,
      conversationId: null,
    };
    tx.create(invitationRef, invitation);
    setActivityNotificationInTransaction(tx, db, {
      id: activityNotificationId("crossPathsInvitation", invitationId),
      uid: data.recipientUid,
      type: "crossPathsInvitation",
      title: "A Cross Paths invitation",
      body: `${senderName} would like to make a plan for this event.`,
      createdAt: now,
      eventId: data.eventId,
      invitationId,
      actorUid: senderUid,
      actorName: senderName,
    });
  });

  void deliverPush({
    db,
    uid: data.recipientUid,
    type: "crossPathsInvitation",
    title: "A Cross Paths invitation",
    body: `${senderName} would like to make a plan for this event.`,
    eventId: data.eventId,
    invitationId,
  });
  return validSendResponse({
    invitationId,
    status: "pending",
    eventId: data.eventId,
    recipientUid: data.recipientUid,
    expiresAt: expiresAt.toDate().toISOString(),
  });
}

/** Accepts or declines a pending invitation as its recipient. */
export async function respondCrossPathsInvitationHandler(
  request: CallableRequest<unknown>,
  deps: InvitationDeps = defaultDeps
): Promise<RespondCrossPathsInvitationCallableResponse> {
  const uid = requireAuth(request);
  const data = validateCallableWithAjv<
    RespondCrossPathsInvitationCallablePayload
  >(
    request,
    validateRespondCrossPathsInvitationCallablePayload,
    (value) => normalizePayloadStrings(value, {
      stringFields: ["invitationId", "decision"],
    })
  );
  const db = deps.firestore();
  await deps.checkRateLimit?.(db, uid, "respondCrossPathsInvitation");
  const now = deps.now();
  const invitationRef = db.collection("crossPathsInvitations")
    .doc(data.invitationId);
  const preflightSnap = await invitationRef.get();
  if (!preflightSnap.exists) throw unavailable();
  const preflight = requireDoc<CrossPathsInvitationDocument>(
    preflightSnap,
    "CrossPathsInvitationDocument"
  );
  if (
    preflight.recipientUid !== uid ||
    await hasUnsafeReportOrModeration(
      db,
      preflight.senderUid,
      preflight.recipientUid
    )
  ) {
    throw unavailable();
  }
  let senderUid = "";
  let eventId = "";
  let recipientName = "Someone";
  let response: RespondCrossPathsInvitationCallableResponse | undefined;
  let expired = false;

  await db.runTransaction(async (tx) => {
    const invitationSnap = await tx.get(invitationRef);
    if (!invitationSnap.exists) throw unavailable();
    const invitation = requireDoc<CrossPathsInvitationDocument>(
      invitationSnap,
      "CrossPathsInvitationDocument"
    );
    if (invitation.recipientUid !== uid) throw unavailable();
    senderUid = invitation.senderUid;
    eventId = invitation.eventId;
    if (
      invitation.status === "accepted" && data.decision === "accept" ||
      invitation.status === "declined" && data.decision === "decline"
    ) {
      response = {
        invitationId: data.invitationId,
        status: invitation.status,
        conversationId: invitation.conversationId,
      };
      return;
    }
    if (invitation.status !== "pending") throw unavailable();
    if (invitation.expiresAt.toMillis() <= now.toMillis()) {
      tx.update(invitationRef, {
        status: "expired",
        updatedAt: now,
        invalidatedAt: now,
      });
      expired = true;
      return;
    }
    if (data.decision === "decline") {
      tx.update(invitationRef, {
        status: "declined",
        updatedAt: now,
        respondedAt: now,
      });
      setActivityNotificationInTransaction(tx, db, {
        id: activityNotificationId(
          "crossPathsInvitationDeclined",
          data.invitationId
        ),
        uid: invitation.senderUid,
        type: "crossPathsInvitationDeclined",
        title: "Invitation update",
        body: "Your Cross Paths invitation was declined.",
        createdAt: now,
        eventId: invitation.eventId,
        invitationId: data.invitationId,
        actorUid: uid,
      });
      response = {
        invitationId: data.invitationId,
        status: "declined",
        conversationId: null,
      };
      return;
    }

    const refs = invitationRefs(
      db,
      invitation.eventId,
      invitation.senderUid,
      invitation.recipientUid
    );
    const conversationId = crossPathsEventPlanId(
      invitation.eventId,
      invitation.senderUid,
      invitation.recipientUid
    );
    const planRef = db.collection("matches").doc(conversationId);
    const [
      eventSnap,
      senderParticipationSnap,
      recipientParticipationSnap,
      senderConsentSnap,
      recipientConsentSnap,
      senderUserSnap,
      recipientUserSnap,
      senderPublicSnap,
      recipientPublicSnap,
      senderShowcaseSnap,
      recipientShowcaseSnap,
      senderPlans,
      recipientPlans,
      competingInvitations,
      outgoingBlock,
      incomingBlock,
      planSnap,
    ] = await Promise.all([
      tx.get(refs.event),
      tx.get(refs.senderParticipation),
      tx.get(refs.recipientParticipation),
      tx.get(refs.senderConsent),
      tx.get(refs.recipientConsent),
      tx.get(refs.senderUser),
      tx.get(refs.recipientUser),
      tx.get(refs.senderPublic),
      tx.get(refs.recipientPublic),
      tx.get(refs.senderShowcase),
      tx.get(refs.recipientShowcase),
      tx.get(db.collection("crossPathsInvitations")
        .where("participantIds", "array-contains", invitation.senderUid)),
      tx.get(db.collection("crossPathsInvitations")
        .where("participantIds", "array-contains", invitation.recipientUid)),
      tx.get(db.collection("crossPathsInvitations")
        .where("recipientUid", "==", invitation.recipientUid)),
      tx.get(db.collection("blocks").doc(
        `${invitation.senderUid}__${invitation.recipientUid}`
      )),
      tx.get(db.collection("blocks").doc(
        `${invitation.recipientUid}__${invitation.senderUid}`
      )),
      tx.get(planRef),
    ]);
    if (outgoingBlock.exists || incomingBlock.exists || planSnap.exists) {
      throw unavailable();
    }
    const event = validUpcomingEvent(eventSnap, now, false);
    if (
      !signedUpParticipation(
        senderParticipationSnap,
        invitation.eventId,
        invitation.senderUid
      ) ||
      !signedUpParticipation(
        recipientParticipationSnap,
        invitation.eventId,
        invitation.recipientUid
      ) ||
      !effectiveConsent(
        senderConsentSnap,
        invitation.eventId,
        invitation.senderUid
      ) ||
      !effectiveConsent(
        recipientConsentSnap,
        invitation.eventId,
        invitation.recipientUid
      )
    ) {
      throw unavailable();
    }
    const sender = activeUser(senderUserSnap);
    const recipient = activeUser(recipientUserSnap);
    if (
      sender.prefsShowInCrossPaths !== true ||
      recipient.prefsShowInCrossPaths !== true ||
      !isReciprocallyEligible({
        viewer: sender,
        candidate: recipient,
        nowMillis: now.toMillis(),
      }) ||
      !hasEligibleShowcase(senderPublicSnap, senderShowcaseSnap) ||
      !hasEligibleShowcase(recipientPublicSnap, recipientShowcaseSnap) ||
      hasOtherAcceptedPlan(senderPlans.docs, invitation) ||
      hasOtherAcceptedPlan(recipientPlans.docs, invitation)
    ) {
      throw unavailable();
    }
    recipientName = recipient.name;
    const planExpiresAt = admin.firestore.Timestamp.fromMillis(
      event.endTime.toMillis() + eventPlanGraceMillis
    );
    tx.create(planRef, {
      user1Id: invitation.senderUid,
      user2Id: invitation.recipientUid,
      eventIds: [invitation.eventId],
      createdAt: now,
      lastMessageAt: null,
      lastMessagePreview: null,
      lastMessageSenderId: null,
      unreadCounts: {
        [invitation.senderUid]: 0,
        [invitation.recipientUid]: 0,
      },
      status: "active",
      blockedBy: null,
      blockedAt: null,
      participantIds: [invitation.senderUid, invitation.recipientUid],
      conversationType: "crossPathsEventPlan",
      crossPathsInvitationId: data.invitationId,
      eventPlanExpiresAt: planExpiresAt,
      closedAt: null,
    });
    tx.update(invitationRef, {
      status: "accepted",
      updatedAt: now,
      respondedAt: now,
      conversationId,
    });
    for (const doc of competingInvitations.docs) {
      if (doc.id === data.invitationId) continue;
      const row = doc.data();
      if (row.eventId !== invitation.eventId || row.status !== "pending") {
        continue;
      }
      tx.update(doc.ref, {
        status: "invalidated",
        updatedAt: now,
        invalidatedAt: now,
        invalidationReason: "competing_plan_accepted",
      });
    }
    setActivityNotificationInTransaction(tx, db, {
      id: activityNotificationId(
        "crossPathsInvitationAccepted",
        data.invitationId
      ),
      uid: invitation.senderUid,
      type: "crossPathsInvitationAccepted",
      title: "Your event plan is ready",
      body: `${recipientName} accepted your Cross Paths invitation.`,
      createdAt: now,
      eventId: invitation.eventId,
      matchId: conversationId,
      invitationId: data.invitationId,
      actorUid: invitation.recipientUid,
      actorName: recipientName,
    });
    response = {
      invitationId: data.invitationId,
      status: "accepted",
      conversationId,
    };
  });

  if (expired || !response) throw unavailable();
  const copy = response.status === "accepted" ? {
    type: "crossPathsInvitationAccepted",
    title: "Your event plan is ready",
    body: `${recipientName} accepted your Cross Paths invitation.`,
  } as const : {
    type: "crossPathsInvitationDeclined",
    title: "Invitation update",
    body: "Your Cross Paths invitation was declined.",
  } as const;
  void deliverPush({
    db,
    uid: senderUid,
    ...copy,
    eventId,
    invitationId: data.invitationId,
    matchId: response.conversationId ?? undefined,
  });
  return validRespondResponse(response);
}

/** Cancels a pending invitation or closes an accepted event plan. */
export async function cancelCrossPathsInvitationOrPlanHandler(
  request: CallableRequest<unknown>,
  deps: InvitationDeps = defaultDeps
): Promise<CancelCrossPathsInvitationOrPlanCallableResponse> {
  const uid = requireAuth(request);
  const data = validateCallableWithAjv<
    CancelCrossPathsInvitationOrPlanCallablePayload
  >(
    request,
    validateCancelCrossPathsInvitationOrPlanCallablePayload,
    (value) => normalizePayloadStrings(value, {
      stringFields: ["invitationId"],
    })
  );
  const db = deps.firestore();
  await deps.checkRateLimit?.(
    db,
    uid,
    "cancelCrossPathsInvitationOrPlan"
  );
  const now = deps.now();
  const invitationRef = db.collection("crossPathsInvitations")
    .doc(data.invitationId);
  let notifyUid = "";
  let eventId = "";
  let matchId: string | undefined;
  let response: CancelCrossPathsInvitationOrPlanCallableResponse | undefined;
  await db.runTransaction(async (tx) => {
    const snap = await tx.get(invitationRef);
    if (!snap.exists) throw unavailable();
    const invitation = requireDoc<CrossPathsInvitationDocument>(
      snap,
      "CrossPathsInvitationDocument"
    );
    if (!invitation.participantIds.includes(uid)) throw unavailable();
    eventId = invitation.eventId;
    notifyUid = invitation.senderUid === uid ?
      invitation.recipientUid : invitation.senderUid;
    if (invitation.status === "cancelled") {
      response = {invitationId: data.invitationId, status: "cancelled"};
      return;
    }
    if (
      invitation.status === "invalidated" &&
      invitation.invalidationReason === "plan_cancelled"
    ) {
      response = {invitationId: data.invitationId, status: "invalidated"};
      return;
    }
    if (invitation.status === "pending") {
      if (uid !== invitation.senderUid) throw unavailable();
      tx.update(invitationRef, {
        status: "cancelled",
        updatedAt: now,
        cancelledAt: now,
      });
      response = {invitationId: data.invitationId, status: "cancelled"};
      return;
    }
    if (invitation.status !== "accepted" || !invitation.conversationId) {
      throw unavailable();
    }
    matchId = invitation.conversationId;
    tx.update(invitationRef, {
      status: "invalidated",
      updatedAt: now,
      invalidatedAt: now,
      invalidationReason: "plan_cancelled",
    });
    tx.update(db.collection("matches").doc(invitation.conversationId), {
      status: "closed",
      closedAt: now,
      unreadCounts: {
        [invitation.senderUid]: 0,
        [invitation.recipientUid]: 0,
      },
    });
    setActivityNotificationInTransaction(tx, db, {
      id: activityNotificationId("crossPathsPlanCancelled", data.invitationId),
      uid: notifyUid,
      type: "crossPathsPlanCancelled",
      title: "Event plan cancelled",
      body: "Your Cross Paths event plan is now closed.",
      createdAt: now,
      eventId: invitation.eventId,
      matchId: invitation.conversationId,
      invitationId: data.invitationId,
      actorUid: uid,
    });
    response = {invitationId: data.invitationId, status: "invalidated"};
  });
  if (!response) throw unavailable();
  if (response.status === "invalidated") {
    void deliverPush({
      db,
      uid: notifyUid,
      type: "crossPathsPlanCancelled",
      title: "Event plan cancelled",
      body: "Your Cross Paths event plan is now closed.",
      eventId,
      invitationId: data.invitationId,
      matchId,
    });
  }
  if (!validateCancelCrossPathsInvitationOrPlanCallableResponse(response)) {
    throw new HttpsError("internal", "Invalid Cross Paths response.");
  }
  return response;
}

/** Invalidates invitations and closes plans for a user/event boundary. */
export async function invalidateCrossPathsInvitations(params: {
  db: FirebaseFirestore.Firestore;
  uid?: string;
  eventId?: string;
  peerUid?: string;
  reason: InvalidationReason;
  includeAccepted?: boolean;
}): Promise<number> {
  const {db, uid, eventId, peerUid, reason, includeAccepted = true} = params;
  let query: FirebaseFirestore.Query = db.collection("crossPathsInvitations");
  if (uid) query = query.where("participantIds", "array-contains", uid);
  else if (eventId) query = query.where("eventId", "==", eventId);
  else return 0;
  const snap = await query.limit(400).get();
  const now = admin.firestore.Timestamp.now();
  const batch = db.batch();
  let count = 0;
  for (const doc of snap.docs) {
    const invitation = doc.data() as CrossPathsInvitationDocument;
    if (eventId && invitation.eventId !== eventId) continue;
    if (peerUid && !invitation.participantIds.includes(peerUid)) continue;
    if (
      invitation.status !== "pending" &&
      (invitation.status !== "accepted" || !includeAccepted)
    ) {
      continue;
    }
    batch.update(doc.ref, {
      status: "invalidated",
      updatedAt: now,
      invalidatedAt: now,
      invalidationReason: reason,
    });
    if (invitation.status === "accepted" && invitation.conversationId) {
      batch.update(db.collection("matches").doc(invitation.conversationId), {
        status: "closed",
        closedAt: now,
        unreadCounts: {
          [invitation.senderUid]: 0,
          [invitation.recipientUid]: 0,
        },
      });
    }
    count++;
  }
  if (count > 0) await batch.commit();
  return count;
}

export const sendCrossPathsInvitation = onCall(
  appCheckCallableOptionsWithSecrets([crossPathsSuggestionSigningKey]),
  (request) => sendCrossPathsInvitationHandler(request)
);

export const respondCrossPathsInvitation = onCall(
  appCheckCallableOptionsWithSecrets([crossPathsSuggestionSigningKey]),
  (request) => respondCrossPathsInvitationHandler(request)
);

export const cancelCrossPathsInvitationOrPlan = onCall(
  appCheckCallableOptionsWithSecrets([crossPathsSuggestionSigningKey]),
  (request) => cancelCrossPathsInvitationOrPlanHandler(request)
);

export const expireCrossPathsInvitations = onSchedule(
  {schedule: "every 15 minutes", timeZone: "UTC"},
  async () => {
    const db = admin.firestore();
    const now = admin.firestore.Timestamp.now();
    const snap = await db.collection("crossPathsInvitations")
      .where("status", "==", "pending")
      .where("expiresAt", "<=", now)
      .limit(400)
      .get();
    const batch = db.batch();
    snap.docs.forEach((doc) => batch.update(doc.ref, {
      status: "expired",
      updatedAt: now,
      invalidatedAt: now,
    }));
    if (!snap.empty) await batch.commit();
  }
);

export const onCrossPathsParticipationWritten = onDocumentWritten(
  "eventParticipations/{participationId}",
  async (event) => {
    const after = event.data?.after.data() as
      EventParticipationDocument | undefined;
    const before = event.data?.before.data() as
      EventParticipationDocument | undefined;
    const row = after ?? before;
    if (!row || after?.status === "signedUp") return;
    await invalidateCrossPathsInvitations({
      db: admin.firestore(),
      uid: row.uid,
      eventId: row.eventId,
      reason: "participation_cancelled",
    });
  }
);

export const onCrossPathsConsentWritten = onDocumentWritten(
  "eventCrossPathsConsents/{consentId}",
  async (event) => {
    const after = event.data?.after.data() as
      EventCrossPathsConsentDocument | undefined;
    if (!after || after.enabled === true) return;
    await invalidateCrossPathsInvitations({
      db: admin.firestore(),
      uid: after.uid,
      eventId: after.eventId,
      reason: "consent_revoked",
      includeAccepted: false,
    });
  }
);

export const onCrossPathsEventWritten = onDocumentWritten(
  "events/{eventId}",
  async (event) => {
    const after = event.data?.after.data() as EventDocument | undefined;
    if (after?.status === "active") return;
    await invalidateCrossPathsInvitations({
      db: admin.firestore(),
      eventId: event.params.eventId,
      reason: "event_unavailable",
    });
  }
);

export const onCrossPathsBlockCreated = onDocumentCreated(
  "blocks/{blockId}",
  async (event) => {
    const block = event.data?.data();
    const blocker = block?.blockerUserId;
    const blocked = block?.blockedUserId;
    if (typeof blocker !== "string" || typeof blocked !== "string") return;
    await invalidateCrossPathsInvitations({
      db: admin.firestore(),
      uid: blocker,
      peerUid: blocked,
      reason: "safety_state_changed",
    });
  }
);

function invitationRefs(
  db: FirebaseFirestore.Firestore,
  eventId: string,
  senderUid: string,
  recipientUid: string
) {
  return {
    event: db.collection("events").doc(eventId),
    senderParticipation: db.collection("eventParticipations")
      .doc(`${eventId}_${senderUid}`),
    recipientParticipation: db.collection("eventParticipations")
      .doc(`${eventId}_${recipientUid}`),
    senderConsent: db.collection("eventCrossPathsConsents")
      .doc(`${eventId}_${senderUid}`),
    recipientConsent: db.collection("eventCrossPathsConsents")
      .doc(`${eventId}_${recipientUid}`),
    senderUser: db.collection("users").doc(senderUid),
    recipientUser: db.collection("users").doc(recipientUid),
    senderPublic: db.collection("publicProfiles").doc(senderUid),
    recipientPublic: db.collection("publicProfiles").doc(recipientUid),
    senderShowcase: db.collection("crossPathsShowcaseEligibility")
      .doc(senderUid),
    recipientShowcase: db.collection("crossPathsShowcaseEligibility")
      .doc(recipientUid),
  };
}

function hasEligibleShowcase(
  publicSnap: FirebaseFirestore.DocumentSnapshot,
  showcaseSnap: FirebaseFirestore.DocumentSnapshot
): boolean {
  if (!publicSnap.exists || !showcaseSnap.exists) return false;
  const publicProfile = requireDoc<PublicProfileDocument>(
    publicSnap,
    "PublicProfileDocument (Cross Paths invitation)"
  );
  const storedShowcase = requireDoc<CrossPathsShowcaseEligibilityDocument>(
    showcaseSnap,
    "CrossPathsShowcaseEligibilityDocument"
  );
  return effectiveCrossPathsShowcaseEligibility(
    evaluateCrossPathsShowcaseReadiness(publicProfile),
    storedShowcase
  ).status === "eligible";
}

function validUpcomingEvent(
  snap: FirebaseFirestore.DocumentSnapshot,
  now: FirebaseFirestore.Timestamp,
  requireLead: boolean
): EventDocument {
  if (!snap.exists) throw unavailable();
  const event = requireDoc<EventDocument>(snap, "EventDocument");
  const minimumStart = now.toMillis() +
    (requireLead ? minimumInvitationLeadMillis : responseBufferMillis);
  if (event.status !== "active" || event.startTime.toMillis() <= minimumStart) {
    throw unavailable();
  }
  return event;
}

function signedUpParticipation(
  snap: FirebaseFirestore.DocumentSnapshot,
  eventId: string,
  uid: string
): EventParticipationDocument | undefined {
  if (!snap.exists) return undefined;
  const row = requireDoc<EventParticipationDocument>(
    snap,
    "EventParticipationDocument (Cross Paths invitation)"
  );
  return row.eventId === eventId &&
    row.uid === uid &&
    row.status === "signedUp" ? row : undefined;
}

function effectiveConsent(
  snap: FirebaseFirestore.DocumentSnapshot,
  eventId: string,
  uid: string
): boolean {
  if (!snap.exists) return false;
  const row = requireDoc<EventCrossPathsConsentDocument>(
    snap,
    "EventCrossPathsConsentDocument (Cross Paths invitation)"
  );
  return row.eventId === eventId && row.uid === uid && row.enabled === true;
}

function activeUser(
  snap: FirebaseFirestore.DocumentSnapshot
): UserProfileDocument {
  if (!snap.exists) throw unavailable();
  const user = requireDoc<UserProfileDocument>(
    snap,
    "UserProfileDocument (Cross Paths invitation)"
  );
  if (user.deleted === true || user.profileComplete !== true) {
    throw unavailable();
  }
  return user;
}

function hasAcceptedPlan(
  docs: FirebaseFirestore.QueryDocumentSnapshot[],
  eventId: string
): boolean {
  return docs.some((doc) => {
    const row = doc.data();
    return row.eventId === eventId && row.status === "accepted";
  });
}

function hasOtherAcceptedPlan(
  docs: FirebaseFirestore.QueryDocumentSnapshot[],
  invitation: CrossPathsInvitationDocument
): boolean {
  return docs.some((doc) => {
    const row = doc.data();
    return row.eventId === invitation.eventId && row.status === "accepted" &&
      doc.id !== crossPathsInvitationId(
        invitation.eventId,
        invitation.senderUid
      );
  });
}

function timestampMillis(value: unknown): number {
  return typeof (value as {toMillis?: unknown})?.toMillis === "function" ?
    (value as {toMillis: () => number}).toMillis() : 0;
}

async function hasUnsafeReportOrModeration(
  db: FirebaseFirestore.Firestore,
  userA: string,
  userB: string
): Promise<boolean> {
  const [reportsA, reportsB, moderationA, moderationB] = await Promise.all([
    db.collection("reports").where("reporterUserId", "==", userA)
      .limit(200).get(),
    db.collection("reports").where("reporterUserId", "==", userB)
      .limit(200).get(),
    db.collection("moderationFlags").where("targetUserId", "==", userA)
      .limit(200).get(),
    db.collection("moderationFlags").where("targetUserId", "==", userB)
      .limit(200).get(),
  ]);
  const hasPairReport = [
    ...reportsA.docs.map((doc) => doc.data()),
    ...reportsB.docs.map((doc) => doc.data()),
  ].some((row) => row.status === "open" &&
    (row.targetUserId === userA || row.targetUserId === userB ||
      row.reportedUserId === userA || row.reportedUserId === userB));
  const hasPendingModeration = [...moderationA.docs, ...moderationB.docs]
    .some((doc) => doc.data().status === "pending");
  return hasPairReport || hasPendingModeration;
}

async function deliverPush(params: {
  db: FirebaseFirestore.Firestore;
  uid: string;
  type: string;
  title: string;
  body: string;
  eventId: string;
  invitationId: string;
  matchId?: string;
}): Promise<void> {
  try {
    const snap = await params.db.collection("users").doc(params.uid).get();
    const user = snap.data() as UserProfileDocument | undefined;
    if (
      !user?.fcmToken ||
      !allowsPushPreference(user, "crossPathsInvitations")
    ) {
      return;
    }
    await sendFcmNotification({
      token: user.fcmToken,
      type: params.type,
      title: params.title,
      body: params.body,
      eventId: params.eventId,
      invitationId: params.invitationId,
      matchId: params.matchId,
    });
  } catch (error) {
    logger.warn("Cross Paths invitation push failed", {
      uid: params.uid,
      invitationId: params.invitationId,
      error,
    });
  }
}

function normalizeSendPayload(value: unknown): unknown {
  return normalizePayloadStrings(value, {
    stringFields: ["eventId", "recipientUid", "suggestionToken"],
  });
}

function validSendResponse(
  response: SendCrossPathsInvitationCallableResponse
): SendCrossPathsInvitationCallableResponse {
  if (!validateSendCrossPathsInvitationCallableResponse(response)) {
    throw new HttpsError("internal", "Invalid Cross Paths response.");
  }
  return response;
}

function validRespondResponse(
  response: RespondCrossPathsInvitationCallableResponse
): RespondCrossPathsInvitationCallableResponse {
  if (!validateRespondCrossPathsInvitationCallableResponse(response)) {
    throw new HttpsError("internal", "Invalid Cross Paths response.");
  }
  return response;
}

function unavailable(): HttpsError {
  return new HttpsError(
    "failed-precondition",
    "This Cross Paths plan is no longer available."
  );
}

function sha256(value: string): string {
  return createHash("sha256").update(value).digest("hex");
}
