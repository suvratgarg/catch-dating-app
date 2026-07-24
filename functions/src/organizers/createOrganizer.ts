import {CallableRequest, HttpsError, onCall} from "firebase-functions/v2/https";
import * as admin from "firebase-admin";
import {appCheckCallableOptions} from "../shared/callableOptions";
import {requireAuth} from "../shared/auth";
import {CreateOrganizerCallablePayload} from
  "../shared/generated/createOrganizerCallablePayload";
import {validateCreateOrganizerCallablePayload} from
  "../shared/generated/schemaValidators";
import {validateCallableWithAjv} from "../shared/validation";
import {
  normalizeOptionalUploadedPhotoForFirestore,
  normalizeUploadedPhotosForFirestore,
} from "../shared/uploadedPhotoNormalization";
import {checkRateLimit as defaultCheckRateLimit} from "../shared/rateLimit";
import {
  activeClubMembershipPatch,
  activeOrganizerTeamMembershipPatch,
  clubMembershipId,
  organizerRelationshipId,
} from "../shared/relationshipDocuments";
import {
  hostProfileSeedPatch,
  professionalHostSnapshot,
} from "../shared/hostProfiles";
import {marketForIdOrAlias} from "../locations/marketConfig";
import {normalizeCreateOrganizerPayload} from
  "./organizerPayloadNormalization";

interface CreateOrganizerDeps {
  firestore: () => FirebaseFirestore.Firestore;
  serverTimestamp: () => FirebaseFirestore.FieldValue;
  checkRateLimit?: (
    db: FirebaseFirestore.Firestore,
    uid: string,
    action: string
  ) => Promise<void>;
}

const defaultDeps: CreateOrganizerDeps = {
  firestore: () => admin.firestore(),
  serverTimestamp: () => admin.firestore.FieldValue.serverTimestamp(),
  checkRateLimit: defaultCheckRateLimit,
};

/** Creates the canonical organizer and a temporary legacy club shadow. */
export async function createOrganizerHandler(
  request: CallableRequest<unknown>,
  deps: CreateOrganizerDeps = defaultDeps
): Promise<{organizerId: string}> {
  const ownerUid = requireAuth(request);
  const data = validateCallableWithAjv<CreateOrganizerCallablePayload>(
    request,
    validateCreateOrganizerCallablePayload,
    normalizeCreateOrganizerPayload
  );
  const market = marketForIdOrAlias(data.location);
  if (!market || !market.hostCreatable) {
    throw new HttpsError(
      "failed-precondition",
      "This city is not open for organizer creation yet."
    );
  }

  const db = deps.firestore();
  await deps.checkRateLimit?.(db, ownerUid, "createOrganizer");
  const organizerRef = data.organizerId ?
    db.collection("organizers").doc(assertSafeOrganizerId(data.organizerId)) :
    db.collection("organizers").doc();
  const organizerId = organizerRef.id;
  const legacyClubRef = db.collection("clubs").doc(organizerId);
  const teamRef = db.collection("organizerTeamMemberships")
    .doc(organizerRelationshipId(organizerId, ownerUid));
  const legacyMembershipRef = db.collection("clubMemberships")
    .doc(clubMembershipId(organizerId, ownerUid));
  const userRef = db.collection("users").doc(ownerUid);
  const hostProfileRef = db.collection("hostProfiles").doc(ownerUid);
  const deletedUserRef = db.collection("deletedUsers").doc(ownerUid);

  await db.runTransaction(async (tx) => {
    const [
      organizerSnap,
      legacyClubSnap,
      userSnap,
      hostProfileSnap,
      deletedUserSnap,
    ] = await Promise.all([
      tx.get(organizerRef),
      tx.get(legacyClubRef),
      tx.get(userRef),
      tx.get(hostProfileRef),
      tx.get(deletedUserRef),
    ]);
    if (organizerSnap.exists || legacyClubSnap.exists) {
      throw new HttpsError("already-exists", "Organizer already exists.");
    }
    if (deletedUserSnap.exists) {
      throw new HttpsError(
        "failed-precondition",
        "This account cannot create organizers."
      );
    }

    const ownerProfile = professionalHostSnapshot({
      uid: ownerUid,
      hostProfileSnap,
      userSnap,
      role: "owner",
    });
    const organizerPhotos = normalizeUploadedPhotosForFirestore(
      data.organizerPhotos
    );
    const logoPhoto = normalizeOptionalUploadedPhotoForFirestore(
      data.logoPhoto
    );
    const timestamp = deps.serverTimestamp();
    const common = {
      name: data.name,
      description: data.description,
      location: market.marketId,
      locationCityId: market.cityId,
      locationMarketId: market.marketId,
      area: data.area,
      hostUserId: ownerUid,
      hostName: ownerProfile.displayName,
      hostAvatarUrl: ownerProfile.avatarUrl,
      ownerUserId: ownerUid,
      hostUserIds: [ownerUid],
      hostProfiles: [ownerProfile],
      createdAt: timestamp,
      imageUrl: primaryPhotoUrl(organizerPhotos) ?? data.imageUrl ?? null,
      profileImageUrl: thumbnailOrUrl(logoPhoto) ??
        data.profileImageUrl ?? null,
      logoPhoto,
      tags: [],
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
      organizerType: data.organizerType ?? "club",
      organizerTypeUpdatedAt: timestamp,
      organizerTypeUpdatedByUid: ownerUid,
      publicCategoryLabel: null,
      cityName: market.cityLabel,
      regionName: market.regionName,
      countryCode: market.countryIsoCode,
      countryName: market.countryName,
      appVisibility: "discoverable",
      ownership: {
        state: "userCreated",
        ownerUserId: ownerUid,
        primaryHostUserId: ownerUid,
        hostUserIds: [ownerUid],
        claimedAt: timestamp,
        claimedByUid: ownerUid,
      },
      claim: {
        state: "claimed",
        claimHref: null,
        lastClaimRequestId: null,
      },
      publicPage: {
        slug: organizerId,
        citySlug: market.slug,
        canonicalPath: `/organizers/${organizerId}/`,
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
        lastVerifiedAt: timestamp,
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
    };

    tx.create(organizerRef, {
      ...common,
      organizerPhotos,
      followerCount: 0,
    });
    // Compatibility shadow for released clients. Canonical writes and new
    // development target organizers; the migration contract owns retirement.
    tx.create(legacyClubRef, {
      ...common,
      clubPhotos: organizerPhotos,
      memberCount: 1,
    });
    tx.set(teamRef, activeOrganizerTeamMembershipPatch({
      organizerId,
      uid: ownerUid,
      role: "owner",
    }), {merge: true});
    tx.set(legacyMembershipRef, activeClubMembershipPatch({
      clubId: organizerId,
      uid: ownerUid,
      role: "owner",
    }), {merge: true});
    if (!hostProfileSnap.exists) {
      tx.set(
        hostProfileRef,
        hostProfileSeedPatch(ownerProfile, timestamp),
        {merge: true}
      );
    }
  });

  return {organizerId};
}

export const createOrganizer = onCall(
  appCheckCallableOptions,
  (request) => createOrganizerHandler(request)
);

function assertSafeOrganizerId(organizerId: string): string {
  if (!/^[a-z0-9](?:[a-z0-9-]{1,62}[a-z0-9])?$/.test(organizerId)) {
    throw new HttpsError(
      "invalid-argument",
      "Organizer id must be 3-64 lowercase letters, numbers, or hyphens."
    );
  }
  return organizerId;
}

function primaryPhotoUrl(photos: unknown[] | undefined): string | null {
  if (!Array.isArray(photos) || photos.length === 0) return null;
  const first = photos[0];
  if (first === null || typeof first !== "object") return null;
  const url = (first as {url?: unknown}).url;
  return typeof url === "string" && url.trim().length > 0 ? url : null;
}

function thumbnailOrUrl(photo: unknown): string | null {
  if (photo === null || typeof photo !== "object") return null;
  const thumbnailUrl = (photo as {thumbnailUrl?: unknown}).thumbnailUrl;
  if (typeof thumbnailUrl === "string" && thumbnailUrl.trim().length > 0) {
    return thumbnailUrl;
  }
  const url = (photo as {url?: unknown}).url;
  return typeof url === "string" && url.trim().length > 0 ? url : null;
}

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
