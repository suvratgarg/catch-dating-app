/* eslint-disable require-jsdoc */
import {onCall, CallableRequest, HttpsError} from
  "firebase-functions/v2/https";
import * as admin from "firebase-admin";
import {appCheckCallableOptions} from "../shared/callableOptions";
import {requireAuth} from "../shared/auth";
import {
  ReviewDoc,
  RunDoc,
  RunParticipationDoc,
  UserProfileDoc,
} from "../shared/firestore";
import {checkRateLimit as defaultCheckRateLimit} from "../shared/rateLimit";
import {
  runParticipationId,
} from "../shared/relationshipDocuments";
import {CreateRunReviewCallablePayload} from
  "../shared/generated/createRunReviewCallablePayload";
import {DeleteRunReviewCallablePayload} from
  "../shared/generated/deleteRunReviewCallablePayload";
import {
  validateCreateRunReviewCallablePayload,
  validateDeleteRunReviewCallablePayload,
  validateUpdateRunReviewCallablePayload,
} from "../shared/generated/schemaValidators";
import {UpdateRunReviewCallablePayload} from
  "../shared/generated/updateRunReviewCallablePayload";
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

export async function createRunReviewHandler(
  request: CallableRequest<unknown>,
  deps: ReviewMutationDeps = defaultDeps
): Promise<{reviewId: string}> {
  const reviewerUserId = requireAuth(request);
  const data = validateCallableWithAjv<CreateRunReviewCallablePayload>(
    request,
    validateCreateRunReviewCallablePayload,
    normalizeCreateRunReviewPayload
  );
  const db = deps.firestore();
  await deps.checkRateLimit?.(db, reviewerUserId, "createRunReview");

  const reviewId = runReviewId(data.runId, reviewerUserId);
  const reviewRef = db.collection("reviews").doc(reviewId);
  const runRef = db.collection("runs").doc(data.runId);
  const userRef = db.collection("users").doc(reviewerUserId);
  const deletedUserRef = db.collection("deletedUsers").doc(reviewerUserId);
  const participationRef = db
    .collection("runParticipations")
    .doc(runParticipationId(data.runId, reviewerUserId));

  await db.runTransaction(async (tx) => {
    const [
      reviewSnap,
      runSnap,
      userSnap,
      deletedUserSnap,
      participationSnap,
    ] = await Promise.all([
      tx.get(reviewRef),
      tx.get(runRef),
      tx.get(userRef),
      tx.get(deletedUserRef),
      tx.get(participationRef),
    ]);

    if (reviewSnap.exists) {
      throw new HttpsError(
        "already-exists",
        "You have already reviewed this run."
      );
    }
    assertCanWriteReview(
      runSnap,
      userSnap,
      deletedUserSnap,
      participationSnap,
      data.runClubId
    );

    const user = requireDoc<UserProfileDoc>(userSnap, "UserProfileDoc");
    tx.create(reviewRef, {
      runClubId: data.runClubId,
      runId: data.runId,
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

export async function updateRunReviewHandler(
  request: CallableRequest<unknown>,
  deps: ReviewMutationDeps = defaultDeps
): Promise<{updated: boolean}> {
  const reviewerUserId = requireAuth(request);
  const data = validateCallableWithAjv<UpdateRunReviewCallablePayload>(
    request,
    validateUpdateRunReviewCallablePayload,
    normalizeUpdateRunReviewPayload
  );
  const db = deps.firestore();
  await deps.checkRateLimit?.(db, reviewerUserId, "updateRunReview");

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

export async function deleteRunReviewHandler(
  request: CallableRequest<unknown>,
  deps: ReviewMutationDeps = defaultDeps
): Promise<{deleted: boolean}> {
  const reviewerUserId = requireAuth(request);
  const data = validateCallableWithAjv<DeleteRunReviewCallablePayload>(
    request,
    validateDeleteRunReviewCallablePayload,
    normalizeSingleIdPayload("reviewId")
  );
  const db = deps.firestore();
  await deps.checkRateLimit?.(db, reviewerUserId, "deleteRunReview");

  const reviewRef = db.collection("reviews").doc(data.reviewId);
  await db.runTransaction(async (tx) => {
    const reviewSnap = await tx.get(reviewRef);
    assertOwnsReview(reviewSnap, reviewerUserId);
    tx.delete(reviewRef);
  });

  return {deleted: true};
}

function normalizeCreateRunReviewPayload(data: unknown): unknown {
  return normalizePayloadStrings(data, {
    stringFields: ["runClubId", "runId", "comment"],
  });
}

function normalizeUpdateRunReviewPayload(data: unknown): unknown {
  return normalizePayloadStrings(data, {
    stringFields: ["reviewId", "comment"],
  });
}

function assertCanWriteReview(
  runSnap: FirebaseFirestore.DocumentSnapshot,
  userSnap: FirebaseFirestore.DocumentSnapshot,
  deletedUserSnap: FirebaseFirestore.DocumentSnapshot,
  participationSnap: FirebaseFirestore.DocumentSnapshot,
  runClubId: string
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
  if (!runSnap.exists) {
    throw new HttpsError("not-found", "Run not found.");
  }

  const run = requireDoc<RunDoc>(runSnap, "RunDoc");
  if (run.runClubId !== runClubId) {
    throw new HttpsError(
      "failed-precondition",
      "This review does not match the run club."
    );
  }
  if (!participationSnap.exists) {
    throw new HttpsError(
      "failed-precondition",
      "Only attended runners can review a run."
    );
  }

  const participation = requireDoc<RunParticipationDoc>(
    participationSnap,
    "RunParticipationDoc"
  );
  if (participation.status !== "attended") {
    throw new HttpsError(
      "failed-precondition",
      "Only attended runners can review a run."
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

function runReviewId(runId: string, reviewerUserId: string): string {
  return `${runId}~${reviewerUserId}`;
}

export const createRunReview = onCall(
  appCheckCallableOptions,
  (request) => createRunReviewHandler(request)
);

export const updateRunReview = onCall(
  appCheckCallableOptions,
  (request) => updateRunReviewHandler(request)
);

export const deleteRunReview = onCall(
  appCheckCallableOptions,
  (request) => deleteRunReviewHandler(request)
);
