import {onCall, CallableRequest, HttpsError} from
  "firebase-functions/v2/https";
import * as admin from "firebase-admin";
import {appCheckCallableOptions} from "../shared/callableOptions";
import {requireAuth} from "../shared/auth";
import {moderateText} from "../moderation/textFilter";
import {
  ReviewDocument,
  EventDocument,
  EventParticipationDocument,
  UserProfileDocument,
  ClubDocument,
} from "../shared/generated/firestoreAdminTypes";
import {
  checkIpRateLimit,
  checkRateLimit as defaultCheckRateLimit,
} from "../shared/rateLimit";
import {
  eventParticipationId,
} from "../shared/relationshipDocuments";
import {CreateEventReviewCallablePayload} from
  "../shared/generated/createEventReviewCallablePayload";
import {CreatePublicClubReviewCallablePayload} from
  "../shared/generated/createPublicClubReviewCallablePayload";
import {DeleteEventReviewCallablePayload} from
  "../shared/generated/deleteEventReviewCallablePayload";
import {ListPublicClubReviewsCallablePayload} from
  "../shared/generated/listPublicClubReviewsCallablePayload";
import {
  validateCreateEventReviewCallablePayload,
  validateCreatePublicClubReviewCallablePayload,
  validateDeleteEventReviewCallablePayload,
  validateListPublicClubReviewsCallablePayload,
  validateSetReviewResponseCallablePayload,
  validateUpdateEventReviewCallablePayload,
} from "../shared/generated/schemaValidators";
import {SetReviewResponseCallablePayload} from
  "../shared/generated/setReviewResponseCallablePayload";
import {UpdateEventReviewCallablePayload} from
  "../shared/generated/updateEventReviewCallablePayload";
import {normalizePayloadStrings, normalizeSingleIdPayload} from
  "../shared/callablePayloadNormalization";
import {requireDoc, validateCallableWithAjv} from "../shared/validation";
import {
  publicAvatarUrl,
  publicDisplayName,
} from "../shared/profileProjection";
import {clubHostProfiles, isClubHost} from "../shared/clubHosts";

/**
 * Moderation status for a freshly written review. If the comment or the
 * reviewer-supplied name trips the block filter, the review is held as
 * "pending" instead of "published" so it never renders on the public listing
 * nor counts toward the club rating until a human clears it.
 * @param {string} comment Review comment text.
 * @param {string} reviewerName Display name attached to the review.
 * @return {"published" | "pending"} Moderation status to store.
 */
function reviewModerationStatus(
  comment: string,
  reviewerName: string
): "published" | "pending" {
  const blocked = moderateText(comment).action === "block" ||
    moderateText(reviewerName).action === "block";
  return blocked ? "pending" : "published";
}

interface ReviewMutationDeps {
  firestore: () => FirebaseFirestore.Firestore;
  serverTimestamp?: () => FirebaseFirestore.FieldValue;
  checkRateLimit?: (
    db: FirebaseFirestore.Firestore,
    uid: string,
    action: string
  ) => Promise<void>;
  checkIpRateLimit?: (
    ip: string,
    maxRequests?: number,
    windowMs?: number
  ) => boolean;
}

const defaultDeps: ReviewMutationDeps = {
  firestore: () => admin.firestore(),
  serverTimestamp: () => admin.firestore.FieldValue.serverTimestamp(),
  checkRateLimit: defaultCheckRateLimit,
  checkIpRateLimit,
};

export interface PublicClubReview {
  id: string;
  reviewerName: string;
  rating: number;
  comment: string;
  createdAt: string;
  verificationStatus: "verified" | "unverified";
  source: "catchEvent" | "publicListing";
  isAnonymous: boolean;
  ownerResponse: {
    hostName: string;
    hostAvatarUrl: string | null;
    message: string;
    updatedAt: string;
  } | null;
}

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

    const user = requireDoc<UserProfileDocument>(

      userSnap,

      "UserProfileDocument"

    );
    tx.create(reviewRef, {
      clubId: data.clubId,
      eventId: data.eventId,
      reviewerUserId,
      reviewerName: publicDisplayName(user),
      rating: data.rating,
      comment: data.comment,
      verificationStatus: "verified",
      source: "catchEvent",
      moderationStatus: reviewModerationStatus(
        data.comment,
        publicDisplayName(user)
      ),
      isAnonymous: false,
      submittedFromPath: null,
      createdAt: deps.serverTimestamp?.() ??
        admin.firestore.FieldValue.serverTimestamp(),
    });
  });

  return {reviewId};
}

export async function createPublicClubReviewHandler(
  request: CallableRequest<unknown>,
  deps: ReviewMutationDeps = defaultDeps
): Promise<{
  reviewId: string;
  review: PublicClubReview;
}> {
  const data = validateCallableWithAjv<CreatePublicClubReviewCallablePayload>(
    request,
    validateCreatePublicClubReviewCallablePayload,
    normalizeCreatePublicClubReviewPayload
  );
  const db = deps.firestore();
  const reviewerUserId = request.auth?.uid ?? null;

  if (reviewerUserId) {
    await deps.checkRateLimit?.(db, reviewerUserId, "createPublicClubReview");
  } else {
    const ip = requesterIp(request);
    const allowed = deps.checkIpRateLimit?.(
      ip,
      5,
      60 * 60 * 1000
    ) ?? true;
    if (!allowed) {
      throw new HttpsError(
        "resource-exhausted",
        "Too many public reviews from this connection. Please try again later."
      );
    }
  }

  const clubRef = db.collection("clubs").doc(data.clubId);
  const reviewRef = db.collection("reviews").doc();
  const createdAt = new Date().toISOString();
  const reviewerName = publicReviewerName(data);

  await db.runTransaction(async (tx) => {
    const clubSnap = await tx.get(clubRef);
    assertCanReceivePublicReview(clubSnap);
    tx.create(reviewRef, {
      clubId: data.clubId,
      eventId: null,
      reviewerUserId,
      reviewerName,
      rating: data.rating,
      comment: data.comment,
      verificationStatus: "unverified",
      source: "publicListing",
      moderationStatus: reviewModerationStatus(data.comment, reviewerName),
      isAnonymous: data.isAnonymous,
      submittedFromPath: data.submittedFromPath ?? null,
      createdAt: deps.serverTimestamp?.() ??
        admin.firestore.FieldValue.serverTimestamp(),
    });
  });

  return {
    reviewId: reviewRef.id,
    review: {
      id: reviewRef.id,
      reviewerName,
      rating: data.rating,
      comment: data.comment,
      createdAt,
      verificationStatus: "unverified",
      source: "publicListing",
      isAnonymous: data.isAnonymous,
      ownerResponse: null,
    },
  };
}

export async function listPublicClubReviewsHandler(
  request: CallableRequest<unknown>,
  deps: ReviewMutationDeps = defaultDeps
): Promise<{
  reviews: PublicClubReview[];
}> {
  const data = validateCallableWithAjv<ListPublicClubReviewsCallablePayload>(
    request,
    validateListPublicClubReviewsCallablePayload,
    normalizeSingleIdPayload("clubId")
  );
  const db = deps.firestore();
  const reviewsSnap = await db
    .collection("reviews")
    .where("clubId", "==", data.clubId)
    .orderBy("createdAt", "desc")
    .limit(50)
    .get();

  const reviews = reviewsSnap.docs
    .map((doc) => toPublicClubReview(doc.id, doc.data() as ReviewDocument))
    .filter((review): review is PublicClubReview => review !== null);

  return {reviews};
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

export async function setReviewResponseHandler(
  request: CallableRequest<unknown>,
  deps: ReviewMutationDeps = defaultDeps
): Promise<{updated: boolean}> {
  const hostUserId = requireAuth(request);
  const data = validateCallableWithAjv<SetReviewResponseCallablePayload>(
    request,
    validateSetReviewResponseCallablePayload,
    normalizeSetReviewResponsePayload
  );
  // The host response is published immediately, so reject blocked content
  // outright (the host can edit and resubmit) rather than holding it.
  if (moderateText(data.message).action === "block") {
    throw new HttpsError(
      "invalid-argument",
      "This response can't be posted. Please revise the wording."
    );
  }
  const db = deps.firestore();
  await deps.checkRateLimit?.(db, hostUserId, "setReviewResponse");

  const reviewRef = db.collection("reviews").doc(data.reviewId);
  const userRef = db.collection("users").doc(hostUserId);
  const deletedUserRef = db.collection("deletedUsers").doc(hostUserId);

  await db.runTransaction(async (tx) => {
    const reviewSnap = await tx.get(reviewRef);
    if (!reviewSnap.exists) {
      throw new HttpsError("not-found", "Review not found.");
    }
    const review = requireDoc<ReviewDocument>(
      reviewSnap,
      "ReviewDocument"
    );
    const clubRef = db.collection("clubs").doc(review.clubId);
    const [
      clubSnap,
      userSnap,
      deletedUserSnap,
    ] = await Promise.all([
      tx.get(clubRef),
      tx.get(userRef),
      tx.get(deletedUserRef),
    ]);
    assertCanRespondToReview(clubSnap, userSnap, deletedUserSnap, hostUserId);
    const club = requireDoc<ClubDocument>(
      clubSnap,
      "ClubDocument"
    );
    const user = requireDoc<UserProfileDocument>(
      userSnap,
      "UserProfileDocument"
    );
    const existingResponse = responseRecord(review.ownerResponse);
    const hostProfile = clubHostProfiles(club)
      .find((profile) => profile.uid === hostUserId);
    const timestamp = deps.serverTimestamp?.() ??
      admin.firestore.FieldValue.serverTimestamp();

    tx.update(reviewRef, {
      ownerResponse: {
        hostUserId,
        hostName: hostProfile?.displayName ?? publicDisplayName(user),
        hostAvatarUrl: hostProfile?.avatarUrl ?? publicAvatarUrl(user),
        message: data.message,
        createdAt: existingResponse?.createdAt ?? timestamp,
        updatedAt: timestamp,
      },
    });
  });

  return {updated: true};
}

function normalizeCreateEventReviewPayload(data: unknown): unknown {
  return normalizePayloadStrings(data, {
    stringFields: ["clubId", "eventId", "comment"],
  });
}

function normalizeCreatePublicClubReviewPayload(data: unknown): unknown {
  return normalizePayloadStrings(data, {
    stringFields: ["clubId", "comment", "reviewerName", "submittedFromPath"],
  });
}

function normalizeUpdateEventReviewPayload(data: unknown): unknown {
  return normalizePayloadStrings(data, {
    stringFields: ["reviewId", "comment"],
  });
}

function normalizeSetReviewResponsePayload(data: unknown): unknown {
  return normalizePayloadStrings(data, {
    stringFields: ["reviewId", "message"],
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

  const event = requireDoc<EventDocument>(

    eventSnap,

    "EventDocument"

  );
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

  const participation = requireDoc<EventParticipationDocument>(
    participationSnap,
    "EventParticipationDocument"
  );
  if (participation.status !== "attended") {
    throw new HttpsError(
      "failed-precondition",
      "Only attended attendees can review an event."
    );
  }
}

function assertCanReceivePublicReview(
  clubSnap: FirebaseFirestore.DocumentSnapshot
) {
  if (!clubSnap.exists) {
    throw new HttpsError("not-found", "Organizer profile not found.");
  }
  const club = requireDoc<ClubDocument>(clubSnap, "ClubDocument");
  if (club.archived || club.status === "archived") {
    throw new HttpsError(
      "failed-precondition",
      "This organizer profile is not accepting reviews."
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
  const review = requireDoc<ReviewDocument>(
    reviewSnap,
    "ReviewDocument"
  );
  if (review.reviewerUserId !== reviewerUserId) {
    throw new HttpsError(
      "permission-denied",
      "Only the review author can change this review."
    );
  }
}

function assertCanRespondToReview(
  clubSnap: FirebaseFirestore.DocumentSnapshot,
  userSnap: FirebaseFirestore.DocumentSnapshot,
  deletedUserSnap: FirebaseFirestore.DocumentSnapshot,
  hostUserId: string
) {
  if (deletedUserSnap.exists) {
    throw new HttpsError(
      "failed-precondition",
      "This account cannot respond to reviews."
    );
  }
  if (!userSnap.exists) {
    throw new HttpsError("not-found", "User profile not found.");
  }
  if (!clubSnap.exists) {
    throw new HttpsError("not-found", "Club not found.");
  }
  const club = requireDoc<ClubDocument>(
    clubSnap,
    "ClubDocument"
  );
  if (!isClubHost(club, hostUserId)) {
    throw new HttpsError(
      "permission-denied",
      "Only the club host can respond to this review."
    );
  }
}

function responseRecord(value: unknown): Record<string, unknown> | null {
  if (typeof value !== "object" || value === null || Array.isArray(value)) {
    return null;
  }
  return value as Record<string, unknown>;
}

function eventReviewId(eventId: string, reviewerUserId: string): string {
  return `${eventId}~${reviewerUserId}`;
}

function publicReviewerName(data: CreatePublicClubReviewCallablePayload) {
  if (data.isAnonymous) return "Anonymous reviewer";
  const name = data.reviewerName.trim();
  if (!name) {
    throw new HttpsError(
      "invalid-argument",
      "Name is required unless the review is anonymous."
    );
  }
  return name;
}

function requesterIp(request: CallableRequest<unknown>): string {
  const rawRequest = request.rawRequest as
    | {ip?: string; headers?: Record<string, string | string[] | undefined>}
    | undefined;
  const forwarded = rawRequest?.headers?.["x-forwarded-for"];
  const forwardedIp = Array.isArray(forwarded) ? forwarded[0] : forwarded;
  return rawRequest?.ip ?? forwardedIp?.split(",")[0]?.trim() ?? "unknown";
}

function toPublicClubReview(
  id: string,
  review: ReviewDocument
): PublicClubReview | null {
  if (review.moderationStatus && review.moderationStatus !== "published") {
    return null;
  }
  const createdAt = timestampIso(review.createdAt);
  if (!createdAt) return null;
  const ownerResponse = review.ownerResponse;
  return {
    id,
    reviewerName: review.reviewerName,
    rating: review.rating,
    comment: review.comment,
    createdAt,
    verificationStatus:
      review.verificationStatus ?? (review.eventId ? "verified" : "unverified"),
    source: review.source ?? (review.eventId ? "catchEvent" : "publicListing"),
    isAnonymous: review.isAnonymous ?? false,
    ownerResponse: ownerResponse ? {
      hostName: ownerResponse.hostName,
      hostAvatarUrl: ownerResponse.hostAvatarUrl,
      message: ownerResponse.message,
      updatedAt: timestampIso(ownerResponse.updatedAt) ?? createdAt,
    } : null,
  };
}

function timestampIso(value: unknown): string | null {
  if (
    value &&
    typeof value === "object" &&
    "toDate" in value &&
    typeof (value as {toDate?: unknown}).toDate === "function"
  ) {
    return (value as {toDate: () => Date}).toDate().toISOString();
  }
  if (
    value &&
    typeof value === "object" &&
    typeof (value as {_seconds?: unknown})._seconds === "number"
  ) {
    return new Date((value as {_seconds: number})._seconds * 1000)
      .toISOString();
  }
  return null;
}

export const createEventReview = onCall(
  appCheckCallableOptions,
  (request) => createEventReviewHandler(request)
);

export const createPublicClubReview = onCall(
  appCheckCallableOptions,
  (request) => createPublicClubReviewHandler(request)
);

export const listPublicClubReviews = onCall(
  appCheckCallableOptions,
  (request) => listPublicClubReviewsHandler(request)
);

export const updateEventReview = onCall(
  appCheckCallableOptions,
  (request) => updateEventReviewHandler(request)
);

export const deleteEventReview = onCall(
  appCheckCallableOptions,
  (request) => deleteEventReviewHandler(request)
);

export const setReviewResponse = onCall(
  appCheckCallableOptions,
  (request) => setReviewResponseHandler(request)
);
