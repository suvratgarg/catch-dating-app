import {onCall, CallableRequest, HttpsError} from
  "firebase-functions/v2/https";
import * as admin from "firebase-admin";
import {appCheckCallableOptions} from "../shared/callableOptions";
import {requireAuth} from "../shared/auth";
import {
  UserProfileDocument,
} from "../shared/generated/firestoreAdminTypes";
import {
  normalizeOptionalUploadedPhotoForFirestore,
  normalizeUploadedPhotosForFirestore,
} from "../shared/uploadedPhotoNormalization";
import {checkRateLimit as defaultCheckRateLimit} from "../shared/rateLimit";
import {CreateClubCallablePayload} from
  "../shared/generated/createClubCallablePayload";
import {validateCreateClubCallablePayload} from
  "../shared/generated/schemaValidators";
import {requireDoc, validateCallableWithAjv} from "../shared/validation";
import {
  activeClubMembershipPatch,
  clubMembershipId,
} from "../shared/relationshipDocuments";
import {publicAvatarUrl, publicDisplayName} from "../shared/profileProjection";
import {normalizeCreateClubPayload} from "./clubPayloadNormalization";

interface CreateClubDeps {
  firestore: () => FirebaseFirestore.Firestore;
  serverTimestamp: () => FirebaseFirestore.FieldValue;
  checkRateLimit?: (
    db: FirebaseFirestore.Firestore,
    uid: string,
    action: string
  ) => Promise<void>;
}

const defaultDeps: CreateClubDeps = {
  firestore: () => admin.firestore(),
  serverTimestamp: () => admin.firestore.FieldValue.serverTimestamp(),
  checkRateLimit: defaultCheckRateLimit,
};

/**
 * Creates a club and host membership edge.
 * @param {CallableRequest<unknown>} request Callable request.
 * @param {CreateClubDeps} deps Injectable dependencies for tests.
 * @return {Promise<{clubId: string}>} Created club id.
 */
export async function createClubHandler(
  request: CallableRequest<unknown>,
  deps: CreateClubDeps = defaultDeps
): Promise<{clubId: string}> {
  const hostUserId = requireAuth(request);
  const data = validateCallableWithAjv<CreateClubCallablePayload>(
    request,
    validateCreateClubCallablePayload,
    normalizeCreateClubPayload
  );
  const db = deps.firestore();
  await deps.checkRateLimit?.(db, hostUserId, "createClub");
  const clubRef = data.clubId ?
    db.collection("clubs").doc(data.clubId) :
    db.collection("clubs").doc();
  const hostClaimRef = db.collection("clubHostClaims").doc(hostUserId);
  const membershipRef = db
    .collection("clubMemberships")
    .doc(clubMembershipId(clubRef.id, hostUserId));
  const userRef = db.collection("users").doc(hostUserId);
  const deletedUserRef = db.collection("deletedUsers").doc(hostUserId);
  const existingHostedClubSnap = await db
    .collection("clubs")
    .where("hostUserId", "==", hostUserId)
    .limit(1)
    .get();
  if (!existingHostedClubSnap.empty) {
    throw new HttpsError(
      "failed-precondition",
      "You can only host one club."
    );
  }

  await db.runTransaction(async (tx) => {
    const [clubSnap, hostClaimSnap, userSnap, deletedUserSnap] =
      await Promise.all([
        tx.get(clubRef),
        tx.get(hostClaimRef),
        tx.get(userRef),
        tx.get(deletedUserRef),
      ]);

    if (clubSnap.exists) {
      throw new HttpsError("already-exists", "Club already exists.");
    }
    if (hostClaimSnap.exists) {
      throw new HttpsError(
        "failed-precondition",
        "You can only host one club."
      );
    }
    if (!userSnap.exists) {
      throw new HttpsError("not-found", "User profile not found.");
    }
    if (deletedUserSnap.exists) {
      throw new HttpsError(
        "failed-precondition",
        "This account cannot create clubs."
      );
    }

    const user = requireDoc<UserProfileDocument>(

      userSnap,

      "UserProfileDocument"

    );
    if (user.profileComplete !== true) {
      throw new HttpsError(
        "failed-precondition",
        "Complete your profile before creating a club."
      );
    }

    const hostName = publicDisplayName(user);
    const hostAvatarUrl = publicAvatarUrl(user);
    const clubPhotos = normalizeUploadedPhotosForFirestore(data.clubPhotos);
    const logoPhoto = normalizeOptionalUploadedPhotoForFirestore(
      data.logoPhoto
    );

    tx.create(clubRef, {
      name: data.name,
      description: data.description,
      location: data.location,
      area: data.area,
      hostUserId,
      hostName,
      hostAvatarUrl,
      ownerUserId: hostUserId,
      hostUserIds: [hostUserId],
      hostProfiles: [{
        uid: hostUserId,
        displayName: hostName,
        avatarUrl: hostAvatarUrl,
        role: "owner",
      }],
      createdAt: deps.serverTimestamp(),
      imageUrl: primaryPhotoUrl(clubPhotos) ?? data.imageUrl ?? null,
      profileImageUrl: thumbnailOrUrl(logoPhoto) ??
        data.profileImageUrl ?? null,
      clubPhotos,
      logoPhoto,
      tags: [],
      memberCount: 1,
      rating: 0,
      reviewCount: 0,
      nextEventAt: null,
      nextEventLabel: null,
      status: "active",
      archived: false,
      archivedAt: null,
      archiveReason: null,
      instagramHandle: data.instagramHandle ?? null,
      phoneNumber: data.phoneNumber ?? null,
      email: data.email ?? null,
      hostDefaults: data.hostDefaults ?? defaultHostDefaults(),
      entityKind: "club",
      entitySubtypes: [],
      displayCategory: "Club",
      cityName: null,
      regionName: null,
      countryCode: "IN",
      countryName: "India",
      appVisibility: "discoverable",
      ownership: {
        state: "userCreated",
        ownerUserId: hostUserId,
        primaryHostUserId: hostUserId,
        hostUserIds: [hostUserId],
        claimedAt: deps.serverTimestamp(),
        claimedByUid: hostUserId,
      },
      claim: {
        state: "claimed",
        claimHref: null,
        lastClaimRequestId: null,
      },
      publicPage: {
        slug: clubRef.id,
        citySlug: data.location,
        canonicalPath: `/clubs/${clubRef.id}`,
        publishStatus: "draft",
        indexStatus: "noindex",
        robots: "noindex, follow",
        seoTitle: null,
        seoDescription: null,
        lastRenderedAt: null,
      },
      provenance: {
        origin: "userCreated",
        sourceConfidence: "ownerVerified",
        verificationStatus: "ownerVerified",
        lastVerifiedAt: deps.serverTimestamp(),
      },
      publicProfile: {
        headline: null,
        summary: null,
        sourceSummary: null,
        formats: [],
        facts: [],
        fitNotes: [],
        missingEvidence: [],
        eventEvidence: [],
      },
      publicSources: [],
    });
    tx.set(membershipRef, activeClubMembershipPatch({
      clubId: clubRef.id,
      uid: hostUserId,
      role: "owner",
    }), {merge: true});
    tx.create(hostClaimRef, {
      uid: hostUserId,
      clubId: clubRef.id,
      createdAt: deps.serverTimestamp(),
    });
  });

  return {clubId: clubRef.id};
}

export const createClub = onCall(
  appCheckCallableOptions,
  (request) => createClubHandler(request)
);

/**
 * Extracts the first usable full-size URL from an uploaded photo gallery.
 * @param {unknown[] | undefined} photos Candidate uploaded photo records.
 * @return {string|null} First full-size URL, or null when unavailable.
 */
function primaryPhotoUrl(photos: unknown[] | undefined): string | null {
  if (!Array.isArray(photos) || photos.length === 0) return null;
  const first = photos[0];
  if (first === null || typeof first !== "object") return null;
  const url = (first as {url?: unknown}).url;
  return typeof url === "string" && url.trim().length > 0 ? url : null;
}

/**
 * Prefers an uploaded photo thumbnail URL and falls back to its full-size URL.
 * @param {unknown} photo Candidate uploaded photo record.
 * @return {string|null} Best display URL, or null when unavailable.
 */
function thumbnailOrUrl(photo: unknown): string | null {
  if (photo === null || typeof photo !== "object") return null;
  const thumbnailUrl = (photo as {thumbnailUrl?: unknown}).thumbnailUrl;
  if (typeof thumbnailUrl === "string" && thumbnailUrl.trim().length > 0) {
    return thumbnailUrl;
  }
  const url = (photo as {url?: unknown}).url;
  return typeof url === "string" && url.trim().length > 0 ? url : null;
}

/**
 * Default host-management settings for newly created clubs.
 * @return {object} Event policy and event success defaults.
 */
function defaultHostDefaults() {
  return {
    primaryActivityKind: "socialRun",
    supportedActivityKinds: ["socialRun"],
    eventPolicy: {
      admissionPreset: "openCapacity",
      minAge: 0,
      maxAge: 99,
      maxMen: null,
      maxWomen: null,
      dynamicPricingEnabled: false,
      dynamicPricingStepInPaise: null,
      dynamicPricingMaxInPaise: null,
      cancellationPolicyId: "standard",
    },
    eventSuccess: {
      enabled: false,
      playbookId: "social_run_light",
      selectedModuleIds: [],
      structureConfig: {
        unitKind: "pods",
        unitSize: 4,
        unitCount: null,
        rotationIntervalMinutes: null,
        revealCountdownSeconds: 10,
      },
      hostGoal: "Help attendees meet at least two new people.",
      wingmanRequestsEnabled: true,
      contextualOpenersEnabled: true,
      compatibilityAffectsRanking: false,
      attendeePrompt: null,
    },
    eventSuccessByActivityKind: {},
  };
}
