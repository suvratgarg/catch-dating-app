/* eslint-disable require-jsdoc */
import {onCall, CallableRequest, HttpsError} from
  "firebase-functions/v2/https";
import * as admin from "firebase-admin";
import {appCheckCallableOptions} from "../shared/callableOptions";
import {requireAuth} from "../shared/auth";
import {
  ReviewDoc,
  EventDoc,
  EventParticipationDoc,
  UserProfileDoc,
} from "../shared/generated/firestoreAdminTypes";
import {checkRateLimit as defaultCheckRateLimit} from "../shared/rateLimit";
import {
  eventParticipationId,
} from "../shared/relationshipDocuments";
import {CreateEventReviewCallablePayload} from
  "../shared/generated/createEventReviewCallablePayload";
import {DeleteEventReviewCallablePayload} from
  "../shared/generated/deleteEventReviewCallablePayload";
import {
  validateCreateEventReviewCallablePayload,
  validateDeleteEventReviewCallablePayload,
  validateUpdateEventReviewCallablePayload,
} from "../shared/generated/schemaValidators";
import {UpdateEventReviewCallablePayload} from
  "../shared/generated/updateEventReviewCallablePayload";
import {normalizePayloadStrings, normalizeSingleIdPayload} from
  "../shared/callablePayloadNormalization";
import {requireDoc, validateCallableWithAjv} from "../shared/validation";
import {publicDisplayName} from "../shared/profileProjection";

interface ReviewMutationDeps {
  firestore: () => FirebaseFirestore.Firestore;
  serverTimestamp?: () => FirebaseFirestore.FieldValue;
  checkRateLimit?: (
    db: FirebaseFirestore.Firestore,
    uid: string,
    action: string
  ) => Promise<void>;
}

const defaultDeps: ReviewMutationDeps = {
  firestore: () => admin.firestore(),
  serverTimestamp: () => admin.firestore.FieldValue.serverTimestamp(),
  checkRateLimit: defaultCheckRateLimit,
};

export async function createEventReviewHandler(
  request: CallableRequest<unknown>,
  deps: ReviewMutationDeps = defaultDeps
): Promise<{reviewId: string}> {
  const reviewerUserId = requireAuth(request);
  const data = validateCallableWithAjv<CreateEventReviewCallablePayload>(
    request,
    validateCreateEventReviewCallablePayload,
    normalizeCreateEventReviewPayload
  );
  const db = deps.firestore();
  await deps.checkRateLimit?.(db, reviewerUserId, "createEventReview");

  const reviewId = eventReviewId(data.eventId, reviewerUserId);
  const reviewRef = db.collection("reviews").doc(reviewId);
  const eventRef = db.collection("events").doc(data.eventId);
  const userRef = db.collection("users").doc(reviewerUserId);
  const deletedUserRef = db.collection("deletedUsers").doc(reviewerUserId);
  const participationRef = db
    .collection("eventParticipations")
    .doc(eventParticipationId(data.eventId, reviewerUserId));

  await db.runTransaction(async (tx) => {
    const [
      reviewSnap,
      eventSnap,
      userSnap,
      deletedUserSnap,
      participationSnap,
    ] = await Promise.all([
      tx.get(reviewRef),
      tx.get(eventRef),
      tx.get(userRef),
      tx.get(deletedUserRef),
      tx.get(participationRef),
    ]);

    if (reviewSnap.exists) {
      throw new HttpsError(
        "already-exists",
        "You have already reviewed this event."
      );
    }
    assertCanWriteReview(
      eventSnap,
      userSnap,
      deletedUserSnap,
      participationSnap,
      data.clubId
    );

    const user = requireDoc<UserProfileDoc>(userSnap, "UserProfileDoc");
    tx.create(reviewRef, {
      clubId: data.clubId,
      eventId: data.eventId,
      reviewerUserId,
      reviewerName: publicDisplayName(user),
      rating: data.rating,
      comment: data.comment,
      createdAt: deps.serverTimestamp?.() ??
        admin.firestore.FieldValue.serverTimestamp(),
    });
  });

  return {reviewId};
}

export async function updateEventReviewHandler(
  request: CallableRequest<unknown>,
  deps: ReviewMutationDeps = defaultDeps
): Promise<{updated: boolean}> {
  const reviewerUserId = requireAuth(request);
  const data = validateCallableWithAjv<UpdateEventReviewCallablePayload>(
    request,
    validateUpdateEventReviewCallablePayload,
    normalizeUpdateEventReviewPayload
  );
  const db = deps.firestore();
  await deps.checkRateLimit?.(db, reviewerUserId, "updateEventReview");

  const reviewRef = db.collection("reviews").doc(data.reviewId);
  await db.runTransaction(async (tx) => {
    const reviewSnap = await tx.get(reviewRef);
    assertOwnsReview(reviewSnap, reviewerUserId);
    tx.update(reviewRef, {
      rating: data.rating,
      comment: data.comment,
      updatedAt: deps.serverTimestamp?.() ??
        admin.firestore.FieldValue.serverTimestamp(),
    });
  });

  return {updated: true};
}

export async function deleteEventReviewHandler(
  request: CallableRequest<unknown>,
  deps: ReviewMutationDeps = defaultDeps
): Promise<{deleted: boolean}> {
  const reviewerUserId = requireAuth(request);
  const data = validateCallableWithAjv<DeleteEventReviewCallablePayload>(
    request,
    validateDeleteEventReviewCallablePayload,
    normalizeSingleIdPayload("reviewId")
  );
  const db = deps.firestore();
  await deps.checkRateLimit?.(db, reviewerUserId, "deleteEventReview");

  const reviewRef = db.collection("reviews").doc(data.reviewId);
  await db.runTransaction(async (tx) => {
    const reviewSnap = await tx.get(reviewRef);
    assertOwnsReview(reviewSnap, reviewerUserId);
    tx.delete(reviewRef);
  });

  return {deleted: true};
}

function normalizeCreateEventReviewPayload(data: unknown): unknown {
  return normalizePayloadStrings(data, {
    stringFields: ["clubId", "eventId", "comment"],
  });
}

function normalizeUpdateEventReviewPayload(data: unknown): unknown {
  return normalizePayloadStrings(data, {
    stringFields: ["reviewId", "comment"],
  });
}

function assertCanWriteReview(
  eventSnap: FirebaseFirestore.DocumentSnapshot,
  userSnap: FirebaseFirestore.DocumentSnapshot,
  deletedUserSnap: FirebaseFirestore.DocumentSnapshot,
  participationSnap: FirebaseFirestore.DocumentSnapshot,
  clubId: string
) {
  if (deletedUserSnap.exists) {
    throw new HttpsError(
      "failed-precondition",
      "This account cannot write reviews."
    );
  }
  if (!userSnap.exists) {
    throw new HttpsError("not-found", "User profile not found.");
  }
  if (!eventSnap.exists) {
    throw new HttpsError("not-found", "Event not found.");
  }

  const event = requireDoc<EventDoc>(eventSnap, "EventDoc");
  if (event.clubId !== clubId) {
    throw new HttpsError(
      "failed-precondition",
      "This review does not match the club."
    );
  }
  if (!participationSnap.exists) {
    throw new HttpsError(
      "failed-precondition",
      "Only attended attendees can review an event."
    );
  }

  const participation = requireDoc<EventParticipationDoc>(
    participationSnap,
    "EventParticipationDoc"
  );
  if (participation.status !== "attended") {
    throw new HttpsError(
      "failed-precondition",
      "Only attended attendees can review an event."
    );
  }
}

function assertOwnsReview(
  reviewSnap: FirebaseFirestore.DocumentSnapshot,
  reviewerUserId: string
) {
  if (!reviewSnap.exists) {
    throw new HttpsError("not-found", "Review not found.");
  }
  const review = requireDoc<ReviewDoc>(reviewSnap, "ReviewDoc");
  if (review.reviewerUserId !== reviewerUserId) {
    throw new HttpsError(
      "permission-denied",
      "Only the review author can change this review."
    );
  }
}

function eventReviewId(eventId: string, reviewerUserId: string): string {
  return `${eventId}~${reviewerUserId}`;
}

export const createEventReview = onCall(
  appCheckCallableOptions,
  (request) => createEventReviewHandler(request)
);

export const updateEventReview = onCall(
  appCheckCallableOptions,
  (request) => updateEventReviewHandler(request)
);

export const deleteEventReview = onCall(
  appCheckCallableOptions,
  (request) => deleteEventReviewHandler(request)
);
