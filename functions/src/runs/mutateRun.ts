import {onCall, CallableRequest, HttpsError} from
  "firebase-functions/v2/https";
import * as admin from "firebase-admin";
import * as logger from "firebase-functions/logger";
import {z} from "zod";
import {appCheckCallableOptions} from "../shared/callableOptions";
import {requireAuth} from "../shared/auth";
import {RunClubDoc, RunDoc, RunConstraints} from "../shared/firestore";
import {checkRateLimit as defaultCheckRateLimit} from "../shared/rateLimit";
import {requireDoc, validateCallable} from "../shared/validation";
import {
  allowsPushPreference,
  activityNotificationId,
  runActivityNotificationCopy,
  sendFcmNotification,
  setActivityNotification,
} from "../shared/notifications";
import {
  runParticipationsByStatusInTransaction,
} from "../shared/relationshipDocuments";
import {
  assertValidRunTimeRange,
  claimRunClubScheduleInTransaction,
  releaseRunClubScheduleInTransaction,
  releaseUserRunScheduleInTransaction,
  replaceRunClubScheduleInTransaction,
} from "./scheduleConflicts";
import {refreshRunClubNextRun as defaultRefreshRunClubNextRun} from
  "../runClubs/syncRunClubNextRun";

const PaceSchema = z.enum(["easy", "moderate", "fast", "competitive"]);
const nullableString = z.string().trim().max(1000).nullable().optional();
const nullableLat = z.number().min(-90).max(90).nullable().optional();
const nullableLng = z.number().min(-180).max(180).nullable().optional();
const requiredLat = z.number().min(-90).max(90);
const requiredLng = z.number().min(-180).max(180);

const RunConstraintsSchema = z.object({
  minAge: z.number().int().min(0).max(120).default(0),
  maxAge: z.number().int().min(0).max(120).default(99),
  maxMen: z.number().int().min(0).nullable().optional(),
  maxWomen: z.number().int().min(0).nullable().optional(),
}).strict().refine((value) => value.maxAge >= value.minAge, {
  message: "maxAge must be greater than or equal to minAge",
});

const RunCreateDetailsSchema = z.object({
  startTimeMillis: z.number().int(),
  endTimeMillis: z.number().int(),
  meetingPoint: z.string().trim().min(1).max(240),
  startingPointLat: requiredLat,
  startingPointLng: requiredLng,
  locationDetails: nullableString,
  distanceKm: z.number().positive().max(100),
  pace: PaceSchema,
  capacityLimit: z.number().int().min(1).max(1000),
  description: z.string().trim().max(2000),
  priceInPaise: z.number().int().min(0).max(100000000),
  constraints: RunConstraintsSchema.default({}),
}).strict();

const CreateRunSchema = RunCreateDetailsSchema.extend({
  runId: z.string().trim().min(1).optional(),
  runClubId: z.string().trim().min(1),
}).strict();

const RunHostUpdateFieldsSchema = z.object({
  startTimeMillis: z.number().int().optional(),
  endTimeMillis: z.number().int().optional(),
  meetingPoint: z.string().trim().min(1).max(240).optional(),
  startingPointLat: nullableLat,
  startingPointLng: nullableLng,
  locationDetails: nullableString,
  distanceKm: z.number().positive().max(100).optional(),
  pace: PaceSchema.optional(),
  description: z.string().trim().max(2000).optional(),
}).strict().refine((value) => Object.keys(value).length > 0, {
  message: "At least one run field must be provided",
});

const UpdateRunSchema = z.object({
  runId: z.string().trim().min(1),
  fields: RunHostUpdateFieldsSchema,
}).strict();

const CancelRunSchema = z.object({
  runId: z.string().trim().min(1),
  reason: z.string().trim().max(500).nullable().optional(),
}).strict();

const DeleteRunSchema = z.object({
  runId: z.string().trim().min(1),
}).strict();

interface RunMutationDeps {
  firestore: () => FirebaseFirestore.Firestore;
  timestampFromMillis: (millis: number) => FirebaseFirestore.Timestamp;
  serverTimestamp?: () => FirebaseFirestore.FieldValue;
  sendNotification?: typeof sendFcmNotification;
  checkRateLimit?: (
    db: FirebaseFirestore.Firestore,
    uid: string,
    action: string
  ) => Promise<void>;
  refreshRunClubNextRun?: (
    runClubId: string,
    deps?: {
      firestore: () => FirebaseFirestore.Firestore;
      nowTimestamp: () => FirebaseFirestore.Timestamp;
    }
  ) => Promise<void>;
}

type ParsedRunConstraints = {
  minAge?: number;
  maxAge?: number;
  maxMen?: number | null;
  maxWomen?: number | null;
};

type ParsedCreateRunData =
  Omit<z.infer<typeof CreateRunSchema>, "constraints"> & {
    constraints?: ParsedRunConstraints;
  };

type NotificationUserDoc = {
  fcmToken?: string;
  prefsRunReminders?: boolean;
  prefsRunStatusUpdates?: boolean;
  prefsClubUpdates?: boolean;
};

type ClubMembershipNotificationDoc = {
  uid?: string;
  pushNotificationsEnabled?: boolean;
};

const defaultDeps: RunMutationDeps = {
  firestore: () => admin.firestore(),
  timestampFromMillis: (millis) =>
    admin.firestore.Timestamp.fromMillis(millis),
  serverTimestamp: () => admin.firestore.FieldValue.serverTimestamp(),
  sendNotification: sendFcmNotification,
  checkRateLimit: defaultCheckRateLimit,
  refreshRunClubNextRun: defaultRefreshRunClubNextRun,
};

/**
 * Creates a run for a club hosted by the signed-in user.
 * @param {CallableRequest<unknown>} request Callable request.
 * @param {RunMutationDeps} deps Injectable dependencies for tests.
 * @return {Promise<{runId: string}>} Created run id.
 */
export async function createRunHandler(
  request: CallableRequest<unknown>,
  deps: RunMutationDeps = defaultDeps
): Promise<{runId: string}> {
  const hostUserId = requireAuth(request);
  const data = validateCallable(request, CreateRunSchema);
  assertValidRunTimeRange(data.startTimeMillis, data.endTimeMillis);

  const db = deps.firestore();
  await deps.checkRateLimit?.(db, hostUserId, "createRun");

  const runRef = data.runId ?
    db.collection("runs").doc(data.runId) :
    db.collection("runs").doc();
  const clubRef = db.collection("runClubs").doc(data.runClubId);
  const deletedUserRef = db.collection("deletedUsers").doc(hostUserId);

  let createdRun: RunDoc | null = null;
  let clubName = "Your run club";

  await db.runTransaction(async (tx) => {
    const [runSnap, clubSnap, deletedUserSnap] = await Promise.all([
      tx.get(runRef),
      tx.get(clubRef),
      tx.get(deletedUserRef),
    ]);

    if (runSnap.exists) {
      throw new HttpsError("already-exists", "Run already exists.");
    }
    assertCanMutateRunClub(clubSnap, deletedUserSnap, hostUserId);
    const club = requireDoc<RunClubDoc>(clubSnap, "RunClubDoc");
    clubName = club.name;
    const run = {
      ...buildCreateRunDoc(data, deps),
      runClubId: data.runClubId,
      bookedCount: 0,
      checkedInCount: 0,
      waitlistedCount: 0,
      status: "active" as const,
      cancelledAt: null,
      cancellationReason: null,
      genderCounts: {},
    };

    await claimRunClubScheduleInTransaction(tx, db, {
      runClubId: data.runClubId,
      runId: runRef.id,
      startTimeMillis: data.startTimeMillis,
      endTimeMillis: data.endTimeMillis,
    });
    tx.create(runRef, run);
    createdRun = run;
  });

  if (createdRun) {
    await deps.refreshRunClubNextRun?.(data.runClubId, {
      firestore: deps.firestore,
      nowTimestamp: () => admin.firestore.Timestamp.now(),
    });
    await notifyClubMembersForNewRun({
      db,
      deps,
      runId: runRef.id,
      runClubId: data.runClubId,
      hostUserId,
      clubName,
      run: createdRun,
    });
  }

  return {runId: runRef.id};
}

/**
 * Updates host-editable schedule/descriptive fields for a run.
 * @param {CallableRequest<unknown>} request Callable request.
 * @param {RunMutationDeps} deps Injectable dependencies for tests.
 * @return {Promise<{updated: boolean}>} Whether the update completed.
 */
export async function updateRunHandler(
  request: CallableRequest<unknown>,
  deps: RunMutationDeps = defaultDeps
): Promise<{updated: boolean}> {
  const hostUserId = requireAuth(request);
  const data = validateCallable(request, UpdateRunSchema);
  const db = deps.firestore();
  await deps.checkRateLimit?.(db, hostUserId, "updateRun");

  const runRef = db.collection("runs").doc(data.runId);
  const deletedUserRef = db.collection("deletedUsers").doc(hostUserId);
  let updatedRun: RunDoc | null = null;
  let affectedRunClubId: string | null = null;
  let shouldNotifyParticipants = false;

  await db.runTransaction(async (tx) => {
    const [runSnap, deletedUserSnap] = await Promise.all([
      tx.get(runRef),
      tx.get(deletedUserRef),
    ]);

    if (!runSnap.exists) {
      throw new HttpsError("not-found", "Run not found.");
    }

    const run = requireDoc<RunDoc>(runSnap, "RunDoc");
    if (run.status === "cancelled") {
      throw new HttpsError(
        "failed-precondition",
        "Cancelled runs cannot be edited."
      );
    }
    const clubRef = db.collection("runClubs").doc(run.runClubId);
    const [clubSnap, activeParticipations] = await Promise.all([
      tx.get(clubRef),
      runParticipationsByStatusInTransaction(tx, db, data.runId, [
        "signedUp",
        "waitlisted",
        "attended",
      ]),
    ]);
    assertCanMutateRunClub(clubSnap, deletedUserSnap, hostUserId);
    assertValidMergedRunUpdate(run, data.fields);
    if (hasScheduleTimeChange(data.fields) && activeParticipations.length > 0) {
      throw new HttpsError(
        "failed-precondition",
        "Runs with participants or waitlisted users cannot be rescheduled."
      );
    }

    const patch = buildUpdateRunPatch(data.fields, deps);
    if (hasScheduleTimeChange(data.fields)) {
      await replaceRunClubScheduleInTransaction(tx, db, {
        runClubId: run.runClubId,
        runId: data.runId,
        previousStartTimeMillis: run.startTime.toMillis(),
        previousEndTimeMillis: run.endTime.toMillis(),
        startTimeMillis: fieldsStartTimeMillis(run, data.fields),
        endTimeMillis: fieldsEndTimeMillis(run, data.fields),
      });
    }
    tx.update(runRef, patch);
    updatedRun = {...run, ...patch};
    affectedRunClubId = run.runClubId;
    shouldNotifyParticipants = hasScheduleOrLocationChange(data.fields);
  });

  if (updatedRun && shouldNotifyParticipants) {
    await notifyRunParticipants({
      db,
      deps,
      runId: data.runId,
      run: updatedRun,
      type: "runUpdated",
    });
  }
  if (affectedRunClubId) {
    await deps.refreshRunClubNextRun?.(affectedRunClubId, {
      firestore: deps.firestore,
      nowTimestamp: () => admin.firestore.Timestamp.now(),
    });
  }

  return {updated: true};
}

/**
 * Cancels a run and notifies signed-up/waitlisted participants.
 *
 * This callable intentionally does not implement refund policy or expose a
 * host UI contract yet. It creates the backend state and notification path so
 * the product policy can be backfilled without client-owned multi-doc writes.
 * @param {CallableRequest<unknown>} request Callable request.
 * @param {RunMutationDeps} deps Injectable dependencies for tests.
 * @return {Promise<{cancelled: boolean}>} Whether the run is cancelled.
 */
export async function cancelRunHandler(
  request: CallableRequest<unknown>,
  deps: RunMutationDeps = defaultDeps
): Promise<{cancelled: boolean}> {
  const hostUserId = requireAuth(request);
  const data = validateCallable(request, CancelRunSchema);
  const db = deps.firestore();
  await deps.checkRateLimit?.(db, hostUserId, "cancelRun");

  const runRef = db.collection("runs").doc(data.runId);
  const deletedUserRef = db.collection("deletedUsers").doc(hostUserId);
  let cancelledRun: RunDoc | null = null;
  let affectedRunClubId: string | null = null;
  let shouldNotifyParticipants = false;

  await db.runTransaction(async (tx) => {
    const [runSnap, deletedUserSnap] = await Promise.all([
      tx.get(runRef),
      tx.get(deletedUserRef),
    ]);

    if (!runSnap.exists) {
      throw new HttpsError("not-found", "Run not found.");
    }

    const run = requireDoc<RunDoc>(runSnap, "RunDoc");
    const clubRef = db.collection("runClubs").doc(run.runClubId);
    const [clubSnap, participantEdges] = await Promise.all([
      tx.get(clubRef),
      runParticipationsByStatusInTransaction(tx, db, data.runId, [
        "signedUp",
        "waitlisted",
      ]),
    ]);
    assertCanMutateRunClub(clubSnap, deletedUserSnap, hostUserId);

    if (run.status === "cancelled") {
      cancelledRun = run;
      affectedRunClubId = run.runClubId;
      return;
    }

    const cancelledAt = deps.serverTimestamp?.() ??
      admin.firestore.FieldValue.serverTimestamp();
    tx.update(runRef, {
      status: "cancelled",
      cancelledAt,
      cancellationReason: data.reason ?? null,
    });
    releaseRunClubScheduleInTransaction(tx, db, {
      runClubId: run.runClubId,
      runId: data.runId,
      startTimeMillis: run.startTime.toMillis(),
      endTimeMillis: run.endTime.toMillis(),
    });
    for (const edge of participantEdges) {
      releaseUserRunScheduleInTransaction(tx, db, {
        uid: edge.data.uid,
        runId: data.runId,
        startTimeMillis: run.startTime.toMillis(),
        endTimeMillis: run.endTime.toMillis(),
      });
    }
    cancelledRun = {
      ...run,
      status: "cancelled",
      cancelledAt: run.cancelledAt,
      cancellationReason: data.reason ?? null,
    };
    affectedRunClubId = run.runClubId;
    shouldNotifyParticipants = true;
  });

  if (cancelledRun && shouldNotifyParticipants) {
    await notifyRunParticipants({
      db,
      deps,
      runId: data.runId,
      run: cancelledRun,
      type: "runCancelled",
    });
  }
  if (affectedRunClubId) {
    await deps.refreshRunClubNextRun?.(affectedRunClubId, {
      firestore: deps.firestore,
      nowTimestamp: () => admin.firestore.Timestamp.now(),
    });
  }

  return {cancelled: true};
}

/**
 * Hard-deletes an unused run.
 *
 * Runs with any user activity are cancelled, not deleted, so payments,
 * notifications, reviews, and attendance history keep a stable audit trail.
 * @param {CallableRequest<unknown>} request Callable request.
 * @param {RunMutationDeps} deps Injectable dependencies for tests.
 * @return {Promise<{deleted: boolean}>} Whether the run was deleted.
 */
export async function deleteRunHandler(
  request: CallableRequest<unknown>,
  deps: RunMutationDeps = defaultDeps
): Promise<{deleted: boolean}> {
  const hostUserId = requireAuth(request);
  const data = validateCallable(request, DeleteRunSchema);
  const db = deps.firestore();
  await deps.checkRateLimit?.(db, hostUserId, "deleteRun");

  const runRef = db.collection("runs").doc(data.runId);
  const deletedUserRef = db.collection("deletedUsers").doc(hostUserId);
  let deletedRunClubId: string | null = null;

  await db.runTransaction(async (tx) => {
    const runSnap = await tx.get(runRef);
    if (!runSnap.exists) {
      throw new HttpsError("not-found", "Run not found.");
    }

    const run = requireDoc<RunDoc>(runSnap, "RunDoc");
    const clubRef = db.collection("runClubs").doc(run.runClubId);
    const [
      clubSnap,
      deletedUserSnap,
      participationSnap,
      paymentSnap,
      reviewSnap,
    ] = await Promise.all([
      tx.get(clubRef),
      tx.get(deletedUserRef),
      tx.get(db.collection("runParticipations")
        .where("runId", "==", data.runId)
        .limit(1)),
      tx.get(db.collection("payments")
        .where("runId", "==", data.runId)
        .limit(1)),
      tx.get(db.collection("reviews")
        .where("runId", "==", data.runId)
        .limit(1)),
    ]);

    assertCanMutateRunClub(clubSnap, deletedUserSnap, hostUserId);
    if (
      !participationSnap.empty ||
      !paymentSnap.empty ||
      !reviewSnap.empty
    ) {
      throw new HttpsError(
        "failed-precondition",
        "Runs with participants, payments, or reviews must be cancelled."
      );
    }

    tx.delete(runRef);
    deletedRunClubId = run.runClubId;
    releaseRunClubScheduleInTransaction(tx, db, {
      runClubId: run.runClubId,
      runId: data.runId,
      startTimeMillis: run.startTime.toMillis(),
      endTimeMillis: run.endTime.toMillis(),
    });
  });

  if (deletedRunClubId) {
    await deps.refreshRunClubNextRun?.(deletedRunClubId, {
      firestore: deps.firestore,
      nowTimestamp: () => admin.firestore.Timestamp.now(),
    });
  }

  return {deleted: true};
}

/**
 * Builds the immutable initial run document controlled by the create callable.
 * @param {ParsedCreateRunData} data Validated callable data.
 * @param {RunMutationDeps} deps Injectable dependencies.
 * @return {object} Run fields except ownership/booking aggregates.
 */
function buildCreateRunDoc(
  data: ParsedCreateRunData,
  deps: RunMutationDeps
): Omit<RunDoc, "runClubId" | "genderCounts" |
  "status" | "cancelledAt" | "cancellationReason"> {
  return {
    startTime: deps.timestampFromMillis(data.startTimeMillis),
    endTime: deps.timestampFromMillis(data.endTimeMillis),
    meetingPoint: data.meetingPoint,
    startingPointLat: data.startingPointLat,
    startingPointLng: data.startingPointLng,
    locationDetails: data.locationDetails ?? null,
    distanceKm: data.distanceKm,
    pace: data.pace,
    capacityLimit: data.capacityLimit,
    description: data.description,
    priceInPaise: data.priceInPaise,
    constraints: normalizeConstraints(data.constraints),
  };
}

/**
 * Converts host-editable callable fields into Firestore update fields.
 * @param {object} fields Update fields.
 * @param {RunMutationDeps} deps Injectable dependencies.
 * @return {Partial<RunDoc>} Firestore update patch.
 */
function buildUpdateRunPatch(
  fields: z.infer<typeof RunHostUpdateFieldsSchema>,
  deps: RunMutationDeps
): Partial<RunDoc> {
  const patch: Partial<RunDoc> = {};
  if (fields.startTimeMillis !== undefined) {
    patch.startTime = deps.timestampFromMillis(fields.startTimeMillis);
  }
  if (fields.endTimeMillis !== undefined) {
    patch.endTime = deps.timestampFromMillis(fields.endTimeMillis);
  }
  if (fields.meetingPoint !== undefined) {
    patch.meetingPoint = fields.meetingPoint;
  }
  if (fields.startingPointLat !== undefined) {
    patch.startingPointLat = fields.startingPointLat;
  }
  if (fields.startingPointLng !== undefined) {
    patch.startingPointLng = fields.startingPointLng;
  }
  if (fields.locationDetails !== undefined) {
    patch.locationDetails = fields.locationDetails;
  }
  if (fields.distanceKm !== undefined) patch.distanceKm = fields.distanceKm;
  if (fields.pace !== undefined) patch.pace = fields.pace;
  if (fields.description !== undefined) patch.description = fields.description;
  return patch;
}

/**
 * Returns true when an update changes when/where participants show up.
 * @param {object} fields Host update fields.
 * @return {boolean} Whether participants should be notified.
 */
function hasScheduleOrLocationChange(
  fields: z.infer<typeof RunHostUpdateFieldsSchema>
): boolean {
  return fields.startTimeMillis !== undefined ||
    fields.endTimeMillis !== undefined ||
    fields.meetingPoint !== undefined ||
    fields.startingPointLat !== undefined ||
    fields.startingPointLng !== undefined ||
    fields.locationDetails !== undefined;
}

/**
 * Returns true when the run's time window changes, not merely its location.
 * @param {object} fields Host update fields.
 * @return {boolean} Whether time locks must be replaced.
 */
function hasScheduleTimeChange(
  fields: z.infer<typeof RunHostUpdateFieldsSchema>
): boolean {
  return fields.startTimeMillis !== undefined ||
    fields.endTimeMillis !== undefined;
}

/**
 * Applies partial schedule edits to a run start time.
 * @param {RunDoc} run Current run document.
 * @param {object} fields Update fields.
 * @return {number} Merged start time in epoch milliseconds.
 */
function fieldsStartTimeMillis(
  run: RunDoc,
  fields: z.infer<typeof RunHostUpdateFieldsSchema>
): number {
  return fields.startTimeMillis ?? run.startTime.toMillis();
}

/**
 * Applies partial schedule edits to a run end time.
 * @param {RunDoc} run Current run document.
 * @param {object} fields Update fields.
 * @return {number} Merged end time in epoch milliseconds.
 */
function fieldsEndTimeMillis(
  run: RunDoc,
  fields: z.infer<typeof RunHostUpdateFieldsSchema>
): number {
  return fields.endTimeMillis ?? run.endTime.toMillis();
}

/**
 * Converts optional client constraint fields into the canonical stored shape.
 * @param {ParsedRunConstraints=} constraints Validated constraints.
 * @return {RunConstraints} Firestore constraints shape.
 */
function normalizeConstraints(
  constraints?: ParsedRunConstraints
): RunConstraints {
  const value = {
    minAge: 0,
    maxAge: 99,
    ...constraints,
  };
  return {
    minAge: value.minAge,
    maxAge: value.maxAge,
    maxMen: value.maxMen ?? null,
    maxWomen: value.maxWomen ?? null,
  };
}

/**
 * Ensures the caller is an active account and host of the target club.
 * @param {FirebaseFirestore.DocumentSnapshot} clubSnap Club snapshot.
 * @param {FirebaseFirestore.DocumentSnapshot} deletedUserSnap Tombstone snap.
 * @param {string} hostUserId Authenticated caller UID.
 */
function assertCanMutateRunClub(
  clubSnap: FirebaseFirestore.DocumentSnapshot,
  deletedUserSnap: FirebaseFirestore.DocumentSnapshot,
  hostUserId: string
) {
  if (deletedUserSnap.exists) {
    throw new HttpsError(
      "failed-precondition",
      "This account cannot manage runs."
    );
  }
  if (!clubSnap.exists) {
    throw new HttpsError("not-found", "Run club not found.");
  }
  const club = requireDoc<RunClubDoc>(clubSnap, "RunClubDoc");
  if (club.hostUserId !== hostUserId) {
    throw new HttpsError(
      "permission-denied",
      "Only the run club host can manage runs."
    );
  }
}

/**
 * Validates timing and coordinate invariants after applying a partial update.
 * @param {RunDoc} run Current run document.
 * @param {object} fields Update fields.
 */
function assertValidMergedRunUpdate(
  run: RunDoc,
  fields: z.infer<typeof RunHostUpdateFieldsSchema>
) {
  const startTimeMillis = fields.startTimeMillis ??
    run.startTime.toMillis();
  const endTimeMillis = fields.endTimeMillis ??
    run.endTime.toMillis();
  assertValidRunTimeRange(startTimeMillis, endTimeMillis);
  assertValidCoordinatePair(
    fields.startingPointLat !== undefined ?
      fields.startingPointLat :
      run.startingPointLat,
    fields.startingPointLng !== undefined ?
      fields.startingPointLng :
      run.startingPointLng
  );
}

/**
 * Throws when only one coordinate is present.
 * @param {number|null=} latitude Latitude.
 * @param {number|null=} longitude Longitude.
 */
function assertValidCoordinatePair(
  latitude?: number | null,
  longitude?: number | null
) {
  if ((latitude == null) !== (longitude == null)) {
    throw new HttpsError(
      "invalid-argument",
      "Starting latitude and longitude must be provided together."
    );
  }
}

/**
 * Fans out a new-run activity item to active club members.
 *
 * Notification delivery is intentionally best-effort: run creation should not
 * be reported as failed after the run document has already been committed.
 * @param {object} params Fan-out parameters.
 * @param {FirebaseFirestore.Firestore} params.db Firestore instance.
 * @param {RunMutationDeps} params.deps Injectable dependencies.
 * @param {string} params.runId Created run id.
 * @param {string} params.runClubId Club id.
 * @param {string} params.hostUserId Host user id to exclude.
 * @param {string} params.clubName Club display name.
 * @param {RunDoc} params.run Created run document.
 */
async function notifyClubMembersForNewRun(params: {
  db: FirebaseFirestore.Firestore;
  deps: RunMutationDeps;
  runId: string;
  runClubId: string;
  hostUserId: string;
  clubName: string;
  run: RunDoc;
}) {
  try {
    const members = await params.db
      .collection("runClubMemberships")
      .where("clubId", "==", params.runClubId)
      .where("status", "==", "active")
      .get();
    const memberEntries = members.docs
      .map((doc) => doc.data() as ClubMembershipNotificationDoc)
      .filter((membership): membership is
        Required<Pick<ClubMembershipNotificationDoc, "uid">> &
        ClubMembershipNotificationDoc =>
        typeof membership.uid === "string" &&
        membership.uid !== params.hostUserId
      );
    if (memberEntries.length === 0) return;

    const userSnaps = await Promise.all(
      memberEntries.map((membership) =>
        params.db.collection("users").doc(membership.uid).get()
      )
    );
    const copy = newClubRunNotificationCopy(params.clubName, params.run);

    await Promise.all(userSnaps.map(async (snap, index) => {
      const membership = memberEntries[index];
      const uid = membership.uid;
      const user = snap.data() as NotificationUserDoc | undefined;
      if (!user) return;
      await setActivityNotification(params.db, {
        id: activityNotificationId("clubUpdate", params.runId),
        uid,
        type: "clubUpdate",
        title: copy.title,
        body: copy.body,
        createdAt: params.deps.serverTimestamp?.() ??
          admin.firestore.FieldValue.serverTimestamp(),
        runId: params.runId,
        runClubId: params.runClubId,
      });
      if (
        membership.pushNotificationsEnabled === true &&
        user.fcmToken &&
        allowsPushPreference(user, "clubUpdates")
      ) {
        await params.deps.sendNotification?.({
          token: user.fcmToken,
          title: copy.title,
          body: copy.body,
          type: "clubUpdate",
          runId: params.runId,
          runClubId: params.runClubId,
        });
      }
    }));
  } catch (error) {
    logger.error("Failed to fan out new-run notifications", {
      runId: params.runId,
      runClubId: params.runClubId,
      error,
    });
  }
}

/**
 * Fans out run update/cancellation activity to booked and waitlisted users.
 *
 * Delivery is best-effort after the canonical run write commits. A notification
 * failure should not roll back a host's already-committed schedule update or
 * cancellation.
 * @param {object} params Fan-out parameters.
 * @param {FirebaseFirestore.Firestore} params.db Firestore instance.
 * @param {RunMutationDeps} params.deps Injectable dependencies.
 * @param {string} params.runId Run id.
 * @param {RunDoc} params.run Run document used for copy.
 * @param {"runUpdated"|"runCancelled"} params.type Notification type.
 */
async function notifyRunParticipants(params: {
  db: FirebaseFirestore.Firestore;
  deps: RunMutationDeps;
  runId: string;
  run: RunDoc;
  type: "runUpdated" | "runCancelled";
}) {
  try {
    const [signedUp, waitlisted] = await Promise.all([
      params.db
        .collection("runParticipations")
        .where("runId", "==", params.runId)
        .where("status", "==", "signedUp")
        .get(),
      params.db
        .collection("runParticipations")
        .where("runId", "==", params.runId)
        .where("status", "==", "waitlisted")
        .get(),
    ]);
    const uids = Array.from(new Set([...signedUp.docs, ...waitlisted.docs]
      .map((doc) => doc.data().uid)
      .filter((uid): uid is string => typeof uid === "string")));
    if (uids.length === 0) return;

    const copy = runActivityNotificationCopy(params.type, params.run);
    const userSnaps = await Promise.all(
      uids.map((uid) => params.db.collection("users").doc(uid).get())
    );

    await Promise.all(userSnaps.map(async (snap, index) => {
      const uid = uids[index];
      const user = snap.data() as NotificationUserDoc | undefined;
      if (!user) return;
      await setActivityNotification(params.db, {
        id: activityNotificationId(params.type, params.runId),
        uid,
        type: params.type,
        title: copy.title,
        body: copy.body,
        createdAt: params.deps.serverTimestamp?.() ??
          admin.firestore.FieldValue.serverTimestamp(),
        runId: params.runId,
        runClubId: params.run.runClubId,
      });
      if (user.fcmToken && allowsPushPreference(user, "runStatusUpdates")) {
        await params.deps.sendNotification?.({
          token: user.fcmToken,
          title: copy.title,
          body: copy.body,
          type: params.type,
          runId: params.runId,
          runClubId: params.run.runClubId,
        });
      }
    }));
  } catch (error) {
    logger.error("Failed to fan out run participant notifications", {
      runId: params.runId,
      type: params.type,
      error,
    });
  }
}

/**
 * Builds user-facing copy for a newly hosted club run.
 * @param {string} clubName Club display name.
 * @param {RunDoc} run Created run.
 * @return {{title: string, body: string}} Notification copy.
 */
function newClubRunNotificationCopy(
  clubName: string,
  run: RunDoc
): {title: string; body: string} {
  return {
    title: `${clubName} posted a run`,
    body: `${formatDistance(run.distanceKm)} from ${run.meetingPoint}.`,
  };
}

/**
 * Formats a distance without noisy trailing decimals.
 * @param {number} distanceKm Distance in kilometres.
 * @return {string} Human-readable distance.
 */
function formatDistance(distanceKm: number): string {
  return Number.isInteger(distanceKm) ?
    `${distanceKm} km` :
    `${distanceKm.toFixed(1)} km`;
}

export const createRun = onCall(
  appCheckCallableOptions,
  (request) => createRunHandler(request)
);
export const updateRun = onCall(
  appCheckCallableOptions,
  (request) => updateRunHandler(request)
);
export const cancelRun = onCall(
  appCheckCallableOptions,
  (request) => cancelRunHandler(request)
);
export const deleteRun = onCall(
  appCheckCallableOptions,
  (request) => deleteRunHandler(request)
);
