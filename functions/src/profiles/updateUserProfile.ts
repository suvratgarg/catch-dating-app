import {onCall, CallableRequest, HttpsError} from
  "firebase-functions/v2/https";
import * as admin from "firebase-admin";
import {z} from "zod";
import {appCheckCallableOptions} from "../shared/callableOptions";
import {requireAuth} from "../shared/auth";
import {validateCallable} from "../shared/validation";

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

const GenderSchema = z.enum(["man", "woman", "nonBinary", "other"]);
const EducationSchema = z.enum([
  "highSchool",
  "someCollege",
  "bachelors",
  "masters",
  "phd",
  "tradeSchool",
  "other",
]);
const ReligionSchema = z.enum([
  "hindu",
  "muslim",
  "christian",
  "sikh",
  "jain",
  "buddhist",
  "other",
  "nonReligious",
]);
const RelationshipGoalSchema = z.enum([
  "relationship",
  "casual",
  "marriage",
  "friendship",
  "unsure",
]);
const DrinkingSchema = z.enum(["never", "socially", "often"]);
const SmokingSchema = z.enum(["never", "occasionally", "often"]);
const WorkoutSchema = z.enum(["never", "sometimes", "often", "everyday"]);
const DietSchema = z.enum(["omnivore", "vegetarian", "vegan", "jain", "other"]);
const ChildrenSchema = z.enum([
  "dontHave",
  "haveWantMore",
  "haveNoMore",
  "wantSomeday",
  "dontWant",
]);
const SexualOrientationSchema = z.enum([
  "straight",
  "gay",
  "bisexual",
  "pansexual",
  "asexual",
  "other",
]);

const optionalString = z.string().trim().nullable();
const positiveInt = z.number().int().positive();
const nonNegativeMillis = z.number().int().nonnegative();

const UserProfilePatchSchema = z.object({
  name: z.string().trim().min(1).max(120).optional(),
  email: z.string().trim().max(320).optional(),
  bio: z.string().max(2000).optional(),
  instagramHandle: optionalString.optional(),
  phoneNumber: z.string().trim().min(1).max(32).optional(),
  dateOfBirth: nonNegativeMillis.optional(),
  gender: GenderSchema.optional(),
  sexualOrientation: SexualOrientationSchema.nullable().optional(),
  profileComplete: z.boolean().optional(),
  photoUrls: z.array(z.string().url()).max(12).optional(),
  city: IndianCitySchema.nullable().optional(),
  latitude: z.number().min(-90).max(90).nullable().optional(),
  longitude: z.number().min(-180).max(180).nullable().optional(),
  interestedInGenders: z.array(GenderSchema).max(8).optional(),
  minAgePreference: z.number().int().min(18).max(99).optional(),
  maxAgePreference: z.number().int().min(18).max(99).optional(),
  height: z.number().int().min(90).max(260).nullable().optional(),
  occupation: optionalString.optional(),
  company: optionalString.optional(),
  education: EducationSchema.nullable().optional(),
  religion: ReligionSchema.nullable().optional(),
  languages: z.array(z.string()).max(20).optional(),
  relationshipGoal: RelationshipGoalSchema.nullable().optional(),
  drinking: DrinkingSchema.nullable().optional(),
  smoking: SmokingSchema.nullable().optional(),
  workout: WorkoutSchema.nullable().optional(),
  diet: DietSchema.nullable().optional(),
  children: ChildrenSchema.nullable().optional(),
  paceMinSecsPerKm: positiveInt.optional(),
  paceMaxSecsPerKm: positiveInt.optional(),
  preferredDistances: z.array(z.string()).max(12).optional(),
  runningReasons: z.array(z.string()).max(12).optional(),
  prefsNewCatches: z.boolean().optional(),
  prefsRunReminders: z.boolean().optional(),
  prefsWeeklyDigest: z.boolean().optional(),
  prefsShowOnMap: z.boolean().optional(),
}).strict().refine((fields) => Object.keys(fields).length > 0, {
  message: "At least one profile field is required.",
});

const UpdateUserProfileSchema = z.object({
  fields: UserProfilePatchSchema,
});

interface UpdateUserProfileDeps {
  firestore: () => FirebaseFirestore.Firestore;
  timestampFromMillis: (millis: number) => FirebaseFirestore.Timestamp;
}

const defaultDeps: UpdateUserProfileDeps = {
  firestore: () => admin.firestore(),
  timestampFromMillis: (millis) => admin.firestore.Timestamp.fromMillis(millis),
};

type UserProfilePatch = z.infer<typeof UserProfilePatchSchema>;

/**
 * Applies a validated owner profile patch to users/{uid}.
 * @param {CallableRequest<unknown>} request Callable request.
 * @param {UpdateUserProfileDeps} deps Injectable dependencies for tests.
 */
export async function updateUserProfileHandler(
  request: CallableRequest<unknown>,
  deps: UpdateUserProfileDeps = defaultDeps
): Promise<{updated: boolean}> {
  const uid = requireAuth(request);
  const {fields} = validateCallable(request, UpdateUserProfileSchema);
  const db = deps.firestore();
  const userRef = db.collection("users").doc(uid);
  const deletedUserRef = db.collection("deletedUsers").doc(uid);
  const updateFields = toFirestorePatch(fields, deps);

  await db.runTransaction(async (tx) => {
    const [userSnap, deletedUserSnap] = await Promise.all([
      tx.get(userRef),
      tx.get(deletedUserRef),
    ]);

    if (!userSnap.exists) {
      throw new HttpsError("not-found", "User profile not found.");
    }
    if (deletedUserSnap.exists) {
      throw new HttpsError(
        "failed-precondition",
        "This account cannot update its profile."
      );
    }

    tx.update(userRef, updateFields);
  });

  return {updated: true};
}

/**
 * Converts callable-safe patch values into Firestore update values.
 * @param {UserProfilePatch} fields Validated callable patch.
 * @param {UpdateUserProfileDeps} deps Injectable dependencies.
 * @return {Record<string, unknown>} Firestore update patch.
 */
function toFirestorePatch(
  fields: UserProfilePatch,
  deps: UpdateUserProfileDeps
): Record<string, unknown> {
  const updateFields: Record<string, unknown> = {...fields};
  if (fields.dateOfBirth !== undefined) {
    updateFields.dateOfBirth = deps.timestampFromMillis(fields.dateOfBirth);
  }
  return updateFields;
}

export const updateUserProfile = onCall(
  appCheckCallableOptions,
  (request) => updateUserProfileHandler(request)
);
