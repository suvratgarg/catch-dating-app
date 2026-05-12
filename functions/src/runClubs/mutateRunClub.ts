/* eslint-disable require-jsdoc, valid-jsdoc */
import {onCall, CallableRequest, HttpsError} from
  "firebase-functions/v2/https";
import * as admin from "firebase-admin";
import {z} from "zod";
import {appCheckCallableOptions} from "../shared/callableOptions";
import {requireAuth} from "../shared/auth";
import {RunClubDoc} from "../shared/firestore";
import {checkRateLimit as defaultCheckRateLimit} from "../shared/rateLimit";
import {requireDoc, validateCallable} from "../shared/validation";

const CityNameSchema = z.string().trim().min(1).max(80)
  .regex(/^[a-z0-9-]+$/);
const nullableString = z.string().trim().nullable().optional();

const UpdateRunClubSchema = z.object({
  clubId: z.string().trim().min(1),
  fields: z.object({
    name: z.string().trim().min(1).max(120).optional(),
    description: z.string().trim().min(1).max(2000).optional(),
    location: CityNameSchema.optional(),
    area: z.string().trim().min(1).max(120).optional(),
    hostName: z.string().trim().min(1).max(120).optional(),
    hostAvatarUrl: nullableString,
    imageUrl: nullableString,
    tags: z.array(z.string().trim().min(1).max(40)).max(12).optional(),
    instagramHandle: nullableString,
    phoneNumber: nullableString,
    email: nullableString,
  }).strict().refine(
    (fields) => Object.keys(fields).length > 0,
    "At least one run club field must be supplied."
  ),
}).strict();

const ArchiveRunClubSchema = z.object({
  clubId: z.string().trim().min(1),
  reason: z.string().trim().max(500).nullable().optional(),
}).strict();

const DeleteRunClubSchema = z.object({
  clubId: z.string().trim().min(1),
}).strict();

interface RunClubLifecycleDeps {
  firestore: () => FirebaseFirestore.Firestore;
  serverTimestamp?: () => FirebaseFirestore.FieldValue;
  checkRateLimit?: (
    db: FirebaseFirestore.Firestore,
    uid: string,
    action: string
  ) => Promise<void>;
}

const defaultDeps: RunClubLifecycleDeps = {
  firestore: () => admin.firestore(),
  serverTimestamp: () => admin.firestore.FieldValue.serverTimestamp(),
  checkRateLimit: defaultCheckRateLimit,
};

export async function updateRunClubHandler(
  request: CallableRequest<unknown>,
  deps: RunClubLifecycleDeps = defaultDeps
): Promise<{updated: boolean}> {
  const hostUserId = requireAuth(request);
  const data = validateCallable(request, UpdateRunClubSchema);
  const db = deps.firestore();
  await deps.checkRateLimit?.(db, hostUserId, "updateRunClub");

  const clubRef = db.collection("runClubs").doc(data.clubId);
  const deletedUserRef = db.collection("deletedUsers").doc(hostUserId);

  await db.runTransaction(async (tx) => {
    const [clubSnap, deletedUserSnap] = await Promise.all([
      tx.get(clubRef),
      tx.get(deletedUserRef),
    ]);
    assertCanMutateClub(clubSnap, deletedUserSnap, hostUserId);
    tx.update(clubRef, data.fields);
  });

  return {updated: true};
}

export async function archiveRunClubHandler(
  request: CallableRequest<unknown>,
  deps: RunClubLifecycleDeps = defaultDeps
): Promise<{archived: boolean}> {
  const hostUserId = requireAuth(request);
  const data = validateCallable(request, ArchiveRunClubSchema);
  const db = deps.firestore();
  await deps.checkRateLimit?.(db, hostUserId, "archiveRunClub");

  const clubRef = db.collection("runClubs").doc(data.clubId);
  const deletedUserRef = db.collection("deletedUsers").doc(hostUserId);

  await db.runTransaction(async (tx) => {
    const [clubSnap, deletedUserSnap] = await Promise.all([
      tx.get(clubRef),
      tx.get(deletedUserRef),
    ]);
    assertCanMutateClub(clubSnap, deletedUserSnap, hostUserId);
    const existing = clubSnap.data();
    if (existing?.status === "archived" || existing?.archived === true) {
      return;
    }
    tx.update(clubRef, {
      status: "archived",
      archived: true,
      archivedAt: deps.serverTimestamp?.() ??
        admin.firestore.FieldValue.serverTimestamp(),
      archiveReason: data.reason ?? null,
    });
  });

  return {archived: true};
}

export async function deleteRunClubHandler(
  request: CallableRequest<unknown>,
  deps: RunClubLifecycleDeps = defaultDeps
): Promise<{deleted: boolean}> {
  const hostUserId = requireAuth(request);
  const data = validateCallable(request, DeleteRunClubSchema);
  const db = deps.firestore();
  await deps.checkRateLimit?.(db, hostUserId, "deleteRunClub");

  const clubRef = db.collection("runClubs").doc(data.clubId);
  const hostClaimRef = db.collection("runClubHostClaims").doc(hostUserId);
  const deletedUserRef = db.collection("deletedUsers").doc(hostUserId);

  await db.runTransaction(async (tx) => {
    const [
      clubSnap,
      deletedUserSnap,
      runsSnap,
      reviewsSnap,
      paymentsSnap,
      membershipsSnap,
    ] = await Promise.all([
      tx.get(clubRef),
      tx.get(deletedUserRef),
      tx.get(db.collection("runs")
        .where("runClubId", "==", data.clubId)
        .limit(1)),
      tx.get(db.collection("reviews")
        .where("runClubId", "==", data.clubId)
        .limit(1)),
      tx.get(db.collection("payments")
        .where("runClubId", "==", data.clubId)
        .limit(1)),
      tx.get(db.collection("runClubMemberships")
        .where("clubId", "==", data.clubId)
        .limit(2)),
    ]);

    assertCanMutateClub(clubSnap, deletedUserSnap, hostUserId);
    const memberships = membershipsSnap.docs.map((doc) => doc.data());
    const onlyHostMembership = memberships.length <= 1 &&
      memberships.every((membership) =>
        membership.uid === hostUserId && membership.role === "host"
      );
    if (
      !runsSnap.empty ||
      !reviewsSnap.empty ||
      !paymentsSnap.empty ||
      !onlyHostMembership
    ) {
      throw new HttpsError(
        "failed-precondition",
        "Clubs with runs, payments, reviews, or members must be archived."
      );
    }

    membershipsSnap.docs.forEach((doc) => tx.delete(doc.ref));
    tx.delete(hostClaimRef);
    tx.delete(clubRef);
  });

  return {deleted: true};
}

function assertCanMutateClub(
  clubSnap: FirebaseFirestore.DocumentSnapshot,
  deletedUserSnap: FirebaseFirestore.DocumentSnapshot,
  hostUserId: string
) {
  if (deletedUserSnap.exists) {
    throw new HttpsError(
      "failed-precondition",
      "This account cannot manage clubs."
    );
  }
  if (!clubSnap.exists) {
    throw new HttpsError("not-found", "Run club not found.");
  }
  const club = requireDoc<RunClubDoc>(clubSnap, "RunClubDoc");
  if (club.hostUserId !== hostUserId) {
    throw new HttpsError(
      "permission-denied",
      "Only the run club host can manage this club."
    );
  }
}

export const archiveRunClub = onCall(
  appCheckCallableOptions,
  (request) => archiveRunClubHandler(request)
);

export const deleteRunClub = onCall(
  appCheckCallableOptions,
  (request) => deleteRunClubHandler(request)
);

export const updateRunClub = onCall(
  appCheckCallableOptions,
  (request) => updateRunClubHandler(request)
);
