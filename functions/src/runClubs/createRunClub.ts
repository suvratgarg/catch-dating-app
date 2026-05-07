import {onCall, CallableRequest, HttpsError} from
  "firebase-functions/v2/https";
import * as admin from "firebase-admin";
import {z} from "zod";
import {appCheckCallableOptions} from "../shared/callableOptions";
import {requireAuth} from "../shared/auth";
import {UserProfileDoc} from "../shared/firestore";
import {checkRateLimit as defaultCheckRateLimit} from "../shared/rateLimit";
import {requireDoc, validateCallable} from "../shared/validation";
import {
  activeRunClubMembershipPatch,
  runClubMembershipId,
} from "../shared/relationshipDocuments";

const IndianCitySchema = z.enum([
  "mumbai",
  "delhi",
  "bangalore",
  "hyderabad",
  "chennai",
  "kolkata",
  "pune",
  "ahmedabad",
  "indore",
]);

const nullableString = z.string().trim().nullable().optional();

const CreateRunClubSchema = z.object({
  clubId: z.string().min(1).optional(),
  name: z.string().trim().min(1).max(120),
  description: z.string().trim().min(1).max(2000),
  location: IndianCitySchema,
  area: z.string().trim().min(1).max(120),
  imageUrl: nullableString,
  instagramHandle: nullableString,
  phoneNumber: nullableString,
  email: nullableString,
});

interface CreateRunClubDeps {
  firestore: () => FirebaseFirestore.Firestore;
  serverTimestamp: () => FirebaseFirestore.FieldValue;
  checkRateLimit?: (
    db: FirebaseFirestore.Firestore,
    uid: string,
    action: string
  ) => Promise<void>;
}

const defaultDeps: CreateRunClubDeps = {
  firestore: () => admin.firestore(),
  serverTimestamp: () => admin.firestore.FieldValue.serverTimestamp(),
  checkRateLimit: defaultCheckRateLimit,
};

/**
 * Creates a run club and host membership edge.
 * @param {CallableRequest<unknown>} request Callable request.
 * @param {CreateRunClubDeps} deps Injectable dependencies for tests.
 * @return {Promise<{clubId: string}>} Created club id.
 */
export async function createRunClubHandler(
  request: CallableRequest<unknown>,
  deps: CreateRunClubDeps = defaultDeps
): Promise<{clubId: string}> {
  const hostUserId = requireAuth(request);
  const data = validateCallable(request, CreateRunClubSchema);
  const db = deps.firestore();
  await deps.checkRateLimit?.(db, hostUserId, "createRunClub");
  const clubRef = data.clubId ?
    db.collection("runClubs").doc(data.clubId) :
    db.collection("runClubs").doc();
  const membershipRef = db
    .collection("runClubMemberships")
    .doc(runClubMembershipId(clubRef.id, hostUserId));
  const userRef = db.collection("users").doc(hostUserId);
  const deletedUserRef = db.collection("deletedUsers").doc(hostUserId);

  await db.runTransaction(async (tx) => {
    const [clubSnap, userSnap, deletedUserSnap] = await Promise.all([
      tx.get(clubRef),
      tx.get(userRef),
      tx.get(deletedUserRef),
    ]);

    if (clubSnap.exists) {
      throw new HttpsError("already-exists", "Run club already exists.");
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

    const user = requireDoc<UserProfileDoc>(userSnap, "UserProfileDoc");
    if (user.profileComplete !== true) {
      throw new HttpsError(
        "failed-precondition",
        "Complete your profile before creating a club."
      );
    }

    tx.create(clubRef, {
      name: data.name,
      description: data.description,
      location: data.location,
      area: data.area,
      hostUserId,
      hostName: user.name,
      hostAvatarUrl: user.photoUrls[0] ?? null,
      createdAt: deps.serverTimestamp(),
      imageUrl: data.imageUrl ?? null,
      tags: [],
      memberCount: 1,
      rating: 0,
      reviewCount: 0,
      nextRunAt: null,
      nextRunLabel: null,
      instagramHandle: data.instagramHandle ?? null,
      phoneNumber: data.phoneNumber ?? null,
      email: data.email ?? null,
    });
    tx.set(membershipRef, activeRunClubMembershipPatch({
      clubId: clubRef.id,
      uid: hostUserId,
      role: "host",
    }), {merge: true});
  });

  return {clubId: clubRef.id};
}

export const createRunClub = onCall(
  appCheckCallableOptions,
  (request) => createRunClubHandler(request)
);
