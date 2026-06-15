import {onCall, CallableRequest, HttpsError} from
  "firebase-functions/v2/https";
import * as admin from "firebase-admin";
import {appCheckCallableOptions} from "../shared/callableOptions";
import {ClubDocument} from "../shared/generated/firestoreAdminTypes";
import {AdminGetClubDetailsCallablePayload} from
  "../shared/generated/adminGetClubDetailsCallablePayload";
import {AdminUpdateClubDetailsCallablePayload} from
  "../shared/generated/adminUpdateClubDetailsCallablePayload";
import {
  validateAdminGetClubDetailsCallablePayload,
  validateAdminUpdateClubDetailsCallablePayload,
} from "../shared/generated/schemaValidators";
import {requireDoc, validateCallableWithAjv} from "../shared/validation";
import {requireAdminRole} from "./adminAuth";
import {setAdminAuditLogInTransaction} from "./adminAudit";
import {checkRateLimit as defaultCheckRateLimit} from "../shared/rateLimit";

const clubDetailsRoles = ["admin", "adminOwner", "support"] as const;

interface ClubDetailsDeps {
  firestore: () => FirebaseFirestore.Firestore;
  serverTimestamp: () => FirebaseFirestore.FieldValue;
  checkRateLimit?: (
    db: FirebaseFirestore.Firestore,
    uid: string,
    action: string
  ) => Promise<void>;
}

const defaultDeps: ClubDetailsDeps = {
  firestore: () => admin.firestore(),
  serverTimestamp: () => admin.firestore.FieldValue.serverTimestamp(),
  checkRateLimit: defaultCheckRateLimit,
};

type ClubDetailsPatch = AdminUpdateClubDetailsCallablePayload["fields"];

export interface AdminClubDetailsSnapshot {
  clubId: string;
  name: string;
  description: string;
  location: string | null;
  area: string;
  tags: string[];
  instagramHandle: string | null;
  phoneNumber: string | null;
  email: string | null;
  imageUrl: string | null;
  profileImageUrl: string | null;
  entityKind: string | null;
  entitySubtypes: string[];
  displayCategory: string | null;
  cityName: string | null;
  regionName: string | null;
  countryCode: string | null;
  countryName: string | null;
  appVisibility: string | null;
  ownershipState: string | null;
  claimState: string | null;
  publicPage: {
    slug: string | null;
    citySlug: string | null;
    canonicalPath: string | null;
    publishStatus: string | null;
    indexStatus: string | null;
    robots: string | null;
    seoTitle: string | null;
    seoDescription: string | null;
  };
  provenance: {
    origin: string | null;
    sourceConfidence: string | null;
    verificationStatus: string | null;
  };
  publicProfile: {
    headline: string | null;
    summary: string | null;
    sourceSummary: string | null;
    formats: string[];
    fitNotes: string[];
    missingEvidence: string[];
  };
}

export interface AdminGetClubDetailsResponse {
  club: AdminClubDetailsSnapshot;
}

export interface AdminUpdateClubDetailsResponse {
  clubId: string;
  updatedFieldCount: number;
}

/**
 * Loads a review-safe organizer snapshot for the admin cleanup editor.
 * @param {CallableRequest<unknown>} request Callable request.
 * @param {ClubDetailsDeps} deps Injectable dependencies.
 * @return {Promise<AdminGetClubDetailsResponse>} Organizer snapshot.
 */
export async function adminGetClubDetailsHandler(
  request: CallableRequest<unknown>,
  deps: ClubDetailsDeps = defaultDeps
): Promise<AdminGetClubDetailsResponse> {
  const adminContext = requireAdminRole(request, clubDetailsRoles);
  const data = validateCallableWithAjv<AdminGetClubDetailsCallablePayload>(
    request,
    validateAdminGetClubDetailsCallablePayload,
    normalizeAdminGetClubDetailsPayload
  );
  const db = deps.firestore();
  await deps.checkRateLimit?.(db, adminContext.uid, "adminGetClubDetails");
  const clubRef = db.collection("clubs").doc(data.clubId);
  const clubSnap = await clubRef.get();
  if (!clubSnap.exists) {
    throw new HttpsError("not-found", "Organizer listing not found.");
  }
  const club = requireDoc<ClubDocument>(clubSnap, "ClubDocument");
  return {club: publicClubDetails(data.clubId, club)};
}

/**
 * Applies an audited admin cleanup patch to owner-safe organizer fields.
 * @param {CallableRequest<unknown>} request Callable request.
 * @param {ClubDetailsDeps} deps Injectable dependencies.
 * @return {Promise<AdminUpdateClubDetailsResponse>} Save summary.
 */
export async function adminUpdateClubDetailsHandler(
  request: CallableRequest<unknown>,
  deps: ClubDetailsDeps = defaultDeps
): Promise<AdminUpdateClubDetailsResponse> {
  const adminContext = requireAdminRole(request, clubDetailsRoles);
  const data =
    validateCallableWithAjv<AdminUpdateClubDetailsCallablePayload>(
      request,
      validateAdminUpdateClubDetailsCallablePayload,
      normalizeAdminUpdateClubDetailsPayload
    );
  const patch = buildFirestorePatch(data.fields, deps.serverTimestamp());
  const updatedFieldCount = Object.keys(patch).length;
  if (updatedFieldCount === 0) {
    throw new HttpsError("invalid-argument", "No editable fields supplied.");
  }

  const db = deps.firestore();
  await deps.checkRateLimit?.(db, adminContext.uid, "adminUpdateClubDetails");
  const clubRef = db.collection("clubs").doc(data.clubId);
  await db.runTransaction(async (tx) => {
    const clubSnap = await tx.get(clubRef);
    if (!clubSnap.exists) {
      throw new HttpsError("not-found", "Organizer listing not found.");
    }
    const before = requireDoc<ClubDocument>(clubSnap, "ClubDocument");
    tx.update(clubRef, patch);
    setAdminAuditLogInTransaction(tx, db, adminContext, {
      action: "adminUpdateClubDetails",
      targetPath: clubRef.path,
      request,
      before: {club: publicClubDetails(data.clubId, before)},
      after: {
        clubId: data.clubId,
        updatedFields: Object.keys(patch).sort(),
      },
      note: data.reviewNote,
      serverTimestamp: deps.serverTimestamp,
    });
  });

  return {clubId: data.clubId, updatedFieldCount};
}

/**
 * Builds the admin UI snapshot from the canonical club document.
 * @param {string} clubId Firestore document id.
 * @param {ClubDocument} club Canonical club document.
 * @return {AdminClubDetailsSnapshot} Admin-safe snapshot.
 */
function publicClubDetails(
  clubId: string,
  club: ClubDocument
): AdminClubDetailsSnapshot {
  return {
    clubId,
    name: club.name,
    description: club.description,
    location: club.location ?? null,
    area: club.area,
    tags: club.tags ?? [],
    instagramHandle: club.instagramHandle ?? null,
    phoneNumber: club.phoneNumber ?? null,
    email: club.email ?? null,
    imageUrl: club.imageUrl ?? null,
    profileImageUrl: club.profileImageUrl ?? null,
    entityKind: club.entityKind ?? null,
    entitySubtypes: club.entitySubtypes ?? [],
    displayCategory: club.displayCategory ?? null,
    cityName: club.cityName ?? null,
    regionName: club.regionName ?? null,
    countryCode: club.countryCode ?? null,
    countryName: club.countryName ?? null,
    appVisibility: club.appVisibility ?? null,
    ownershipState: club.ownership?.state ?? null,
    claimState: club.claim?.state ?? null,
    publicPage: {
      slug: club.publicPage?.slug ?? null,
      citySlug: club.publicPage?.citySlug ?? null,
      canonicalPath: club.publicPage?.canonicalPath ?? null,
      publishStatus: club.publicPage?.publishStatus ?? null,
      indexStatus: club.publicPage?.indexStatus ?? null,
      robots: club.publicPage?.robots ?? null,
      seoTitle: club.publicPage?.seoTitle ?? null,
      seoDescription: club.publicPage?.seoDescription ?? null,
    },
    provenance: {
      origin: club.provenance?.origin ?? null,
      sourceConfidence: club.provenance?.sourceConfidence ?? null,
      verificationStatus: club.provenance?.verificationStatus ?? null,
    },
    publicProfile: {
      headline: club.publicProfile?.headline ?? null,
      summary: club.publicProfile?.summary ?? null,
      sourceSummary: club.publicProfile?.sourceSummary ?? null,
      formats: club.publicProfile?.formats ?? [],
      fitNotes: club.publicProfile?.fitNotes ?? [],
      missingEvidence: club.publicProfile?.missingEvidence ?? [],
    },
  };
}

/**
 * Converts validated payload fields into Firestore dot-path updates.
 * @param {ClubDetailsPatch} fields Validated cleanup fields.
 * @param {FirebaseFirestore.FieldValue} timestamp Server timestamp.
 * @return {Record<string, unknown>} Firestore update patch.
 */
function buildFirestorePatch(
  fields: ClubDetailsPatch,
  timestamp: FirebaseFirestore.FieldValue
): Record<string, unknown> {
  const patch: Record<string, unknown> = {};
  copyDefined(patch, fields, [
    "name",
    "description",
    "location",
    "area",
    "tags",
    "instagramHandle",
    "phoneNumber",
    "email",
    "imageUrl",
    "profileImageUrl",
    "entityKind",
    "entitySubtypes",
    "displayCategory",
    "cityName",
    "regionName",
    "countryCode",
    "countryName",
    "appVisibility",
  ]);
  copyNestedDefined(patch, "publicPage", fields.publicPage, [
    "slug",
    "citySlug",
    "canonicalPath",
    "publishStatus",
    "seoTitle",
    "seoDescription",
  ]);
  copyNestedDefined(patch, "publicProfile", fields.publicProfile, [
    "headline",
    "summary",
    "sourceSummary",
    "formats",
    "fitNotes",
    "missingEvidence",
  ]);
  copyNestedDefined(patch, "provenance", fields.provenance, [
    "sourceConfidence",
    "verificationStatus",
  ]);
  if (fields.provenance !== undefined &&
      Object.keys(fields.provenance).length > 0) {
    patch["provenance.lastVerifiedAt"] = timestamp;
  }
  return patch;
}

/**
 * Copies defined top-level fields into the patch.
 * @param {Record<string, unknown>} patch Output patch.
 * @param {Record<string, unknown>} source Validated source object.
 * @param {string[]} keys Keys to copy.
 */
function copyDefined(
  patch: Record<string, unknown>,
  source: Record<string, unknown>,
  keys: string[]
) {
  for (const key of keys) {
    if (source[key] !== undefined) patch[key] = source[key];
  }
}

/**
 * Copies defined nested fields into Firestore dot paths.
 * @param {Record<string, unknown>} patch Output patch.
 * @param {string} prefix Firestore field prefix.
 * @param {Record<string, unknown> | undefined} source Nested source.
 * @param {string[]} keys Keys to copy.
 */
function copyNestedDefined(
  patch: Record<string, unknown>,
  prefix: string,
  source: Record<string, unknown> | undefined,
  keys: string[]
) {
  if (source === undefined) return;
  for (const key of keys) {
    if (source[key] !== undefined) patch[`${prefix}.${key}`] = source[key];
  }
}

/**
 * Normalizes the get payload before schema validation.
 * @param {unknown} value Raw callable data.
 * @return {unknown} Normalized payload.
 */
function normalizeAdminGetClubDetailsPayload(value: unknown): unknown {
  if (!value || typeof value !== "object") return value;
  const data = value as Record<string, unknown>;
  return {...data, clubId: normalizeString(data.clubId)};
}

/**
 * Normalizes admin cleanup payload text and list fields before validation.
 * @param {unknown} value Raw callable data.
 * @return {unknown} Normalized payload.
 */
function normalizeAdminUpdateClubDetailsPayload(value: unknown): unknown {
  if (!value || typeof value !== "object") return value;
  const data = value as Record<string, unknown>;
  const fields = data.fields && typeof data.fields === "object" ?
    data.fields as Record<string, unknown> :
    data.fields;
  if (!fields || typeof fields !== "object") {
    return {
      ...data,
      clubId: normalizeString(data.clubId),
      reviewNote: normalizeNullableString(data.reviewNote),
    };
  }
  return {
    ...data,
    clubId: normalizeString(data.clubId),
    reviewNote: normalizeNullableString(data.reviewNote),
    fields: normalizeClubDetailsFields(fields as Record<string, unknown>),
  };
}

/**
 * Normalizes editable club fields.
 * @param {Record<string, unknown>} fields Raw fields object.
 * @return {Record<string, unknown>} Normalized fields.
 */
function normalizeClubDetailsFields(
  fields: Record<string, unknown>
): Record<string, unknown> {
  return {
    ...mapStringFields(fields, [
      "name",
      "description",
      "location",
      "area",
      "entityKind",
      "appVisibility",
    ]),
    tags: normalizeStringArray(fields.tags),
    entitySubtypes: normalizeStringArray(fields.entitySubtypes),
    instagramHandle: normalizeNullableString(fields.instagramHandle),
    phoneNumber: normalizeNullableString(fields.phoneNumber),
    email: normalizeNullableString(fields.email),
    imageUrl: normalizeNullableString(fields.imageUrl),
    profileImageUrl: normalizeNullableString(fields.profileImageUrl),
    displayCategory: normalizeNullableString(fields.displayCategory),
    cityName: normalizeNullableString(fields.cityName),
    regionName: normalizeNullableString(fields.regionName),
    countryCode: normalizeCountryCode(fields.countryCode),
    countryName: normalizeNullableString(fields.countryName),
    publicPage: normalizeNestedObject(fields.publicPage, normalizePublicPage),
    provenance: normalizeNestedObject(fields.provenance, normalizeProvenance),
    publicProfile: normalizeNestedObject(
      fields.publicProfile,
      normalizePublicProfile
    ),
  };
}

/**
 * Normalizes public page cleanup fields.
 * @param {Record<string, unknown>} value Raw nested object.
 * @return {Record<string, unknown>} Normalized nested object.
 */
function normalizePublicPage(
  value: Record<string, unknown>
): Record<string, unknown> {
  return {
    ...mapStringFields(value, [
      "slug",
      "citySlug",
      "canonicalPath",
      "publishStatus",
    ]),
    seoTitle: normalizeNullableString(value.seoTitle),
    seoDescription: normalizeNullableString(value.seoDescription),
  };
}

/**
 * Normalizes provenance fields.
 * @param {Record<string, unknown>} value Raw nested object.
 * @return {Record<string, unknown>} Normalized nested object.
 */
function normalizeProvenance(
  value: Record<string, unknown>
): Record<string, unknown> {
  return mapStringFields(value, ["sourceConfidence", "verificationStatus"]);
}

/**
 * Normalizes public profile fields.
 * @param {Record<string, unknown>} value Raw nested object.
 * @return {Record<string, unknown>} Normalized nested object.
 */
function normalizePublicProfile(
  value: Record<string, unknown>
): Record<string, unknown> {
  return {
    headline: normalizeNullableString(value.headline),
    summary: normalizeNullableString(value.summary),
    sourceSummary: normalizeNullableString(value.sourceSummary),
    formats: normalizeStringArray(value.formats),
    fitNotes: normalizeStringArray(value.fitNotes),
    missingEvidence: normalizeStringArray(value.missingEvidence),
  };
}

/**
 * Preserves undefined nested objects so partial patches stay partial.
 * @param {unknown} value Raw nested value.
 * @param {function(Record<string, unknown>): Record<string, unknown>}
 * normalizer Normalizer.
 * @return {unknown} Normalized value.
 */
function normalizeNestedObject(
  value: unknown,
  normalizer: (value: Record<string, unknown>) => Record<string, unknown>
): unknown {
  if (value === undefined) return undefined;
  if (!value || typeof value !== "object" || Array.isArray(value)) return value;
  return normalizer(value as Record<string, unknown>);
}

/**
 * Trims selected string fields while preserving absent keys.
 * @param {Record<string, unknown>} source Source object.
 * @param {string[]} keys Keys to normalize.
 * @return {Record<string, unknown>} Normalized key subset.
 */
function mapStringFields(
  source: Record<string, unknown>,
  keys: string[]
): Record<string, unknown> {
  const normalized: Record<string, unknown> = {};
  for (const key of keys) {
    if (source[key] !== undefined) {
      normalized[key] = normalizeString(source[key]);
    }
  }
  return normalized;
}

/**
 * Trims a string value.
 * @param {unknown} value Raw value.
 * @return {unknown} Trimmed value.
 */
function normalizeString(value: unknown): unknown {
  return typeof value === "string" ? value.trim() : value;
}

/**
 * Trims optional string fields and converts blanks to null.
 * @param {unknown} value Raw value.
 * @return {unknown} Normalized nullable text.
 */
function normalizeNullableString(value: unknown): unknown {
  if (value === undefined) return undefined;
  if (value === null) return null;
  if (typeof value !== "string") return value;
  const trimmed = value.trim();
  return trimmed.length === 0 ? null : trimmed;
}

/**
 * Trims and uppercases optional country codes.
 * @param {unknown} value Raw value.
 * @return {unknown} Normalized country code.
 */
function normalizeCountryCode(value: unknown): unknown {
  const normalized = normalizeNullableString(value);
  return typeof normalized === "string" ? normalized.toUpperCase() : normalized;
}

/**
 * Trims, drops blanks, and dedupes string arrays.
 * @param {unknown} value Raw value.
 * @return {unknown} Normalized array or original value for validation errors.
 */
function normalizeStringArray(value: unknown): unknown {
  if (value === undefined) return undefined;
  if (!Array.isArray(value)) return value;
  return Array.from(new Set(
    value
      .map((item) => typeof item === "string" ? item.trim() : item)
      .filter((item) => typeof item === "string" && item.length > 0)
  ));
}

export const adminGetClubDetails = onCall(
  appCheckCallableOptions,
  (request) => adminGetClubDetailsHandler(request)
);

export const adminUpdateClubDetails = onCall(
  appCheckCallableOptions,
  (request) => adminUpdateClubDetailsHandler(request)
);
