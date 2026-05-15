import {onCall, CallableRequest, HttpsError} from
  "firebase-functions/v2/https";
import * as admin from "firebase-admin";
import {z} from "zod";
import {appCheckCallableOptions} from "../shared/callableOptions";
import {checkRateLimit as defaultCheckRateLimit} from "../shared/rateLimit";
import {requireAuth} from "../shared/auth";
import {validateCallable} from "../shared/validation";

const CityNameSchema = z.string().trim().min(1).max(80)
  .regex(/^[a-z0-9-]+$/);
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
const PreferredRunTimeSchema = z.enum([
  "earlyMorning",
  "morning",
  "afternoon",
  "evening",
  "night",
]);

const optionalString = z.string().trim().nullable();
const positiveInt = z.number().int().positive();
const nonNegativeMillis = z.number().int().nonnegative();
const minimumHeightCm = 120;
const maximumHeightCm = 220;
const ProfilePromptAnswerSchema = z.object({
  promptId: z.string().trim().min(1).max(80),
  prompt: z.string().trim().min(1).max(140),
  answer: z.string().max(300),
}).strict();
const PhotoPromptAnswerSchema = z.object({
  photoIndex: z.number().int().min(0).max(5),
  promptId: z.string().trim().min(1).max(80),
  prompt: z.string().trim().min(1).max(140),
  caption: z.string().max(140),
}).strict();

const UserProfilePatchSchema = z.object({
  name: z.string().trim().min(1).max(120).optional(),
  displayName: z.string().trim().min(1).max(80).optional(),
  email: z.string().trim().max(320).optional(),
  instagramHandle: optionalString.optional(),
  profilePrompts: z.array(ProfilePromptAnswerSchema).max(3).optional(),
  phoneNumber: z.string().trim().min(1).max(32).optional(),
  dateOfBirth: nonNegativeMillis.optional(),
  gender: GenderSchema.optional(),
  profileComplete: z.boolean().optional(),
  photoUrls: z.array(z.string().url()).max(12).optional(),
  photoPrompts: z.array(PhotoPromptAnswerSchema).max(6).optional(),
  city: CityNameSchema.nullable().optional(),
  latitude: z.number().min(-90).max(90).nullable().optional(),
  longitude: z.number().min(-180).max(180).nullable().optional(),
  interestedInGenders: z.array(GenderSchema).min(1).max(8).optional(),
  minAgePreference: z.number().int().min(18).max(99).optional(),
  maxAgePreference: z.number().int().min(18).max(99).optional(),
  height: z.number().int()
    .min(minimumHeightCm)
    .max(maximumHeightCm)
    .nullable()
    .optional(),
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
  preferredRunTimes: z.array(PreferredRunTimeSchema).max(8).optional(),
  prefsNewCatches: z.boolean().optional(),
  prefsMessages: z.boolean().optional(),
  prefsRunReminders: z.boolean().optional(),
  prefsRunStatusUpdates: z.boolean().optional(),
  prefsClubUpdates: z.boolean().optional(),
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
  checkRateLimit?: (
    db: FirebaseFirestore.Firestore,
    uid: string,
    action: string
  ) => Promise<void>;
}

const defaultDeps: UpdateUserProfileDeps = {
  firestore: () => admin.firestore(),
  timestampFromMillis: (millis) => admin.firestore.Timestamp.fromMillis(millis),
  checkRateLimit: defaultCheckRateLimit,
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
  await deps.checkRateLimit?.(db, uid, "updateUserProfile");

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
  if (fields.profilePrompts !== undefined) {
    updateFields.profilePrompts = fields.profilePrompts
      .map((prompt) => ({
        ...prompt,
        promptId: prompt.promptId.trim(),
        prompt: prompt.prompt.trim(),
        answer: collapseStackedPromptBlankLines(prompt.answer).trim(),
      }))
      .filter((prompt) => prompt.answer.length > 0);
  }
  if (fields.photoPrompts !== undefined) {
    updateFields.photoPrompts = fields.photoPrompts
      .map((prompt) => ({
        ...prompt,
        promptId: prompt.promptId.trim(),
        prompt: prompt.prompt.trim(),
        caption: collapseStackedPromptBlankLines(prompt.caption).trim(),
      }))
      .filter((prompt) => prompt.caption.length > 0);
  }
  if (fields.dateOfBirth !== undefined) {
    updateFields.dateOfBirth = deps.timestampFromMillis(fields.dateOfBirth);
  }
  return updateFields;
}

/**
 * Collapses excessive blank lines in prompt text.
 * @param {string} value Raw prompt text.
 * @return {string} Prompt text with at most one empty line in a row.
 */
function collapseStackedPromptBlankLines(value: string): string {
  return value
    .replace(/\r\n/g, "\n")
    .replace(/\r/g, "\n")
    .replace(/\n[ \t]*\n(?:[ \t]*\n)+/g, "\n\n");
}

export const updateUserProfile = onCall(
  appCheckCallableOptions,
  (request) => updateUserProfileHandler(request)
);
