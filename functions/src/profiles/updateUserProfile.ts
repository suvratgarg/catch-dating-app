import {onCall, CallableRequest, HttpsError} from
  "firebase-functions/v2/https";
import * as admin from "firebase-admin";
import {ValidateFunction} from "ajv";
import {appCheckCallableOptions} from "../shared/callableOptions";
import {checkRateLimit as defaultCheckRateLimit} from "../shared/rateLimit";
import {requireAuth} from "../shared/auth";
import {
  schemaErrorMessages,
  validateUpdateUserProfileCallablePayload,
} from "../shared/generated/schemaValidators";
import {
  UpdateUserProfileCallablePayload,
} from "../shared/generated/updateUserProfileCallablePayload";

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

type UserProfilePatch = UpdateUserProfileCallablePayload["fields"];
type ProfilePatchField = keyof UserProfilePatch;

const trimmedStringFields: ProfilePatchField[] = [
  "name",
  "displayName",
  "email",
  "phoneNumber",
  "city",
];
const nullableTrimmedStringFields: ProfilePatchField[] = [
  "occupation",
  "company",
];
const trimmedStringArrayFields: ProfilePatchField[] = [
  "interestedInGenders",
  "languages",
  "preferredDistances",
  "runningReasons",
  "preferredRunTimes",
];

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
  const {fields} = validateUpdateUserProfilePayload(request.data);
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
 * Normalizes the profile update body, then validates it against the generated
 * JSON Schema contract.
 * @param {unknown} data Callable request data.
 * @return {UpdateUserProfileCallablePayload} Validated profile update payload.
 */
function validateUpdateUserProfilePayload(
  data: unknown
): UpdateUserProfileCallablePayload {
  const normalized = normalizeUpdateUserProfilePayload(data);
  if (validateUpdateUserProfileCallablePayload(normalized)) {
    return normalized;
  }
  const issues = schemaErrorMessages(
    validateUpdateUserProfileCallablePayload as ValidateFunction<unknown>
  ).join("; ");
  throw new HttpsError("invalid-argument", issues);
}

/**
 * Keeps input cleanup explicit now that the schema validator is generated.
 * @param {unknown} data Raw callable payload.
 * @return {unknown} Payload with profile string fields normalized.
 */
function normalizeUpdateUserProfilePayload(data: unknown): unknown {
  if (!isRecord(data) || !isRecord(data.fields)) return data;
  return {
    ...data,
    fields: normalizeProfilePatchFields(data.fields),
  };
}

/**
 * Normalizes the fields that Zod previously transformed while leaving unknown
 * fields intact so the generated schema can reject them.
 * @param {Record<string, unknown>} fields Raw update fields.
 * @return {Record<string, unknown>} Normalized update fields.
 */
function normalizeProfilePatchFields(
  fields: Record<string, unknown>
): Record<string, unknown> {
  const normalized: Record<string, unknown> = {...fields};

  for (const field of trimmedStringFields) {
    if (typeof normalized[field] === "string") {
      normalized[field] = normalized[field].trim();
    }
  }
  for (const field of nullableTrimmedStringFields) {
    if (typeof normalized[field] === "string") {
      normalized[field] = normalized[field].trim();
    }
  }
  if (typeof normalized.instagramHandle === "string") {
    normalized.instagramHandle = normalizeInstagramHandle(
      normalized.instagramHandle
    );
  }
  for (const field of trimmedStringArrayFields) {
    if (field in normalized) {
      normalized[field] = trimStringArrayValues(normalized[field]);
    }
  }
  if ("profilePrompts" in normalized) {
    normalized.profilePrompts = normalizeProfilePromptPayloads(
      normalized.profilePrompts
    );
  }
  if ("photoPrompts" in normalized) {
    normalized.photoPrompts = normalizePhotoPromptPayloads(
      normalized.photoPrompts
    );
  }
  if ("profilePhotos" in normalized) {
    normalized.profilePhotos = normalizeProfilePhotoPayloads(
      normalized.profilePhotos
    );
  }

  return normalized;
}

/**
 * Normalizes a user-entered Instagram handle for contract validation.
 * @param {string} value Raw handle.
 * @return {string} Trimmed handle without a leading at sign.
 */
function normalizeInstagramHandle(value: string): string {
  const trimmed = value.trim();
  return trimmed.startsWith("@") ? trimmed.slice(1).trim() : trimmed;
}

/**
 * Trims string values inside array payloads.
 * @param {unknown} value Raw field value.
 * @return {unknown} Normalized value.
 */
function trimStringArrayValues(value: unknown): unknown {
  if (!Array.isArray(value)) return value;
  return value.map((item) => typeof item === "string" ? item.trim() : item);
}

/**
 * Trims prompt id/title fields while preserving answer validation semantics.
 * @param {unknown} value Raw profile prompt payloads.
 * @return {unknown} Normalized profile prompt payloads.
 */
function normalizeProfilePromptPayloads(value: unknown): unknown {
  if (!Array.isArray(value)) return value;
  return value.map((item) => {
    if (!isRecord(item)) return item;
    return {
      ...item,
      promptId: trimIfString(item.promptId),
      prompt: trimIfString(item.prompt),
    };
  });
}

/**
 * Trims photo prompt id/title fields while preserving caption validation
 * semantics.
 * @param {unknown} value Raw photo prompt payloads.
 * @return {unknown} Normalized photo prompt payloads.
 */
function normalizePhotoPromptPayloads(value: unknown): unknown {
  if (!Array.isArray(value)) return value;
  return value.map((item) => {
    if (!isRecord(item)) return item;
    return {
      ...item,
      promptId: trimIfString(item.promptId),
      prompt: trimIfString(item.prompt),
    };
  });
}

/**
 * Trims profile-photo ids, URLs, Storage paths, and nested prompt display
 * fields while preserving timestamp validation semantics.
 * @param {unknown} value Raw profile-photo payloads.
 * @return {unknown} Normalized profile-photo payloads.
 */
function normalizeProfilePhotoPayloads(value: unknown): unknown {
  if (!Array.isArray(value)) return value;
  return value.map((item) => {
    if (!isRecord(item)) return item;
    const normalized: Record<string, unknown> = {
      ...item,
      id: trimIfString(item.id),
      url: trimIfString(item.url),
      thumbnailUrl: trimIfString(item.thumbnailUrl),
      storagePath: trimIfString(item.storagePath),
      thumbnailStoragePath: trimIfString(item.thumbnailStoragePath),
    };
    if (isRecord(item.prompt)) {
      normalized.prompt = {
        ...item.prompt,
        promptId: trimIfString(item.prompt.promptId),
        prompt: trimIfString(item.prompt.prompt),
      };
    }
    return normalized;
  });
}

/**
 * Trims a value only when it is a string.
 * @param {unknown} value Raw value.
 * @return {unknown} Trimmed string or original value.
 */
function trimIfString(value: unknown): unknown {
  return typeof value === "string" ? value.trim() : value;
}

/**
 * Checks for an object record.
 * @param {unknown} value Value to inspect.
 * @return {boolean} Whether the value is a plain record-like object.
 */
function isRecord(value: unknown): value is Record<string, unknown> {
  return value !== null && typeof value === "object" && !Array.isArray(value);
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
  if (fields.profilePhotos !== undefined) {
    updateFields.profilePhotos = fields.profilePhotos.map((photo) => ({
      ...photo,
      createdAt: deps.timestampFromMillis(photo.createdAt),
      updatedAt: deps.timestampFromMillis(photo.updatedAt),
      ...(photo.moderation?.reviewedAt !== undefined &&
        photo.moderation?.reviewedAt !== null && {
        moderation: {
          ...photo.moderation,
          reviewedAt: deps.timestampFromMillis(photo.moderation.reviewedAt),
        },
      }),
    }));
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
