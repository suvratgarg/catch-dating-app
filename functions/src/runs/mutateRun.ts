import {onCall, CallableRequest, HttpsError} from
  "firebase-functions/v2/https";
import * as admin from "firebase-admin";
import {z} from "zod";
import {appCheckCallableOptions} from "../shared/callableOptions";
import {requireAuth} from "../shared/auth";
import {RunClubDoc, RunDoc, RunConstraints} from "../shared/firestore";
import {checkRateLimit as defaultCheckRateLimit} from "../shared/rateLimit";
import {requireDoc, validateCallable} from "../shared/validation";

const PaceSchema = z.enum(["easy", "moderate", "fast", "competitive"]);
const nullableString = z.string().trim().max(1000).nullable().optional();
const nullableLat = z.number().min(-90).max(90).nullable().optional();
const nullableLng = z.number().min(-180).max(180).nullable().optional();

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
  startingPointLat: nullableLat,
  startingPointLng: nullableLng,
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

interface RunMutationDeps {
  firestore: () => FirebaseFirestore.Firestore;
  timestampFromMillis: (millis: number) => FirebaseFirestore.Timestamp;
  checkRateLimit?: (
    db: FirebaseFirestore.Firestore,
    uid: string,
    action: string
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

const defaultDeps: RunMutationDeps = {
  firestore: () => admin.firestore(),
  timestampFromMillis: (millis) =>
    admin.firestore.Timestamp.fromMillis(millis),
  checkRateLimit: defaultCheckRateLimit,
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
  assertValidTimeRange(data.startTimeMillis, data.endTimeMillis);
  assertValidCoordinatePair(data.startingPointLat, data.startingPointLng);

  const db = deps.firestore();
  await deps.checkRateLimit?.(db, hostUserId, "createRun");

  const runRef = data.runId ?
    db.collection("runs").doc(data.runId) :
    db.collection("runs").doc();
  const clubRef = db.collection("runClubs").doc(data.runClubId);
  const deletedUserRef = db.collection("deletedUsers").doc(hostUserId);

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

    tx.create(runRef, {
      ...buildCreateRunDoc(data, deps),
      runClubId: data.runClubId,
      bookedCount: 0,
      checkedInCount: 0,
      waitlistedCount: 0,
      signedUpUserIds: [],
      attendedUserIds: [],
      waitlistUserIds: [],
      genderCounts: {},
    });
  });

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
    const clubSnap = await tx.get(clubRef);
    assertCanMutateRunClub(clubSnap, deletedUserSnap, hostUserId);
    assertValidMergedRunUpdate(run, data.fields);

    tx.update(runRef, buildUpdateRunPatch(data.fields, deps));
  });

  return {updated: true};
}

/**
 * Builds the immutable initial run document controlled by the create callable.
 * @param {ParsedCreateRunData} data Validated callable data.
 * @param {RunMutationDeps} deps Injectable dependencies.
 * @return {object} Run fields except ownership/booking arrays.
 */
function buildCreateRunDoc(
  data: ParsedCreateRunData,
  deps: RunMutationDeps
): Omit<RunDoc, "runClubId" | "signedUpUserIds" |
  "attendedUserIds" | "waitlistUserIds" | "genderCounts"> {
  return {
    startTime: deps.timestampFromMillis(data.startTimeMillis),
    endTime: deps.timestampFromMillis(data.endTimeMillis),
    meetingPoint: data.meetingPoint,
    startingPointLat: data.startingPointLat ?? null,
    startingPointLng: data.startingPointLng ?? null,
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
  assertValidTimeRange(startTimeMillis, endTimeMillis);
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
 * Throws when a run does not end after it starts.
 * @param {number} startTimeMillis Start time in epoch milliseconds.
 * @param {number} endTimeMillis End time in epoch milliseconds.
 */
function assertValidTimeRange(startTimeMillis: number, endTimeMillis: number) {
  if (endTimeMillis <= startTimeMillis) {
    throw new HttpsError(
      "invalid-argument",
      "Run end time must be after the start time."
    );
  }
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

export const createRun = onCall(
  appCheckCallableOptions,
  (request) => createRunHandler(request)
);
export const updateRun = onCall(
  appCheckCallableOptions,
  (request) => updateRunHandler(request)
);
