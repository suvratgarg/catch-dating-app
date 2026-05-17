type PayloadRecord = Record<string, unknown>;

const topLevelStringFields = [
  "clubId",
  "name",
  "description",
  "location",
  "area",
  "reason",
];

const nullableContactFields = [
  "imageUrl",
  "instagramHandle",
  "phoneNumber",
  "email",
  "hostAvatarUrl",
];

const updateStringFields = [
  "name",
  "description",
  "location",
  "area",
  "hostName",
];

/**
 * Trims create-club text fields before generated schema validation.
 * @param {unknown} data Raw callable payload.
 * @return {unknown} Normalized payload.
 */
export function normalizeCreateClubPayload(data: unknown): unknown {
  if (!isRecord(data)) return data;
  return normalizeFields(data, {
    stringFields: topLevelStringFields,
    nullableStringFields: nullableContactFields,
  });
}

/**
 * Trims update-club payload and nested patch fields before validation.
 * @param {unknown} data Raw callable payload.
 * @return {unknown} Normalized payload.
 */
export function normalizeUpdateClubPayload(data: unknown): unknown {
  if (!isRecord(data)) return data;
  const payload = normalizeFields(data, {stringFields: ["clubId"]});
  if (!isRecord(payload.fields)) return payload;
  return {
    ...payload,
    fields: normalizeFields(payload.fields, {
      stringFields: updateStringFields,
      nullableStringFields: nullableContactFields,
      trimStringArrayFields: ["tags"],
    }),
  };
}

/**
 * Trims archive-club payload fields before validation.
 * @param {unknown} data Raw callable payload.
 * @return {unknown} Normalized payload.
 */
export function normalizeArchiveClubPayload(data: unknown): unknown {
  if (!isRecord(data)) return data;
  return normalizeFields(data, {
    stringFields: ["clubId"],
    nullableStringFields: ["reason"],
  });
}

/**
 * Trims a payload whose only normalized string field is clubId.
 * @param {unknown} data Raw callable payload.
 * @return {unknown} Normalized payload.
 */
export function normalizeClubIdPayload(data: unknown): unknown {
  if (!isRecord(data)) return data;
  return normalizeFields(data, {stringFields: ["clubId"]});
}

/**
 * Returns a shallow copy with selected string fields trimmed.
 * @param {PayloadRecord} data Payload record.
 * @param {object} options Fields to normalize.
 * @return {PayloadRecord} Normalized payload.
 */
function normalizeFields(
  data: PayloadRecord,
  options: {
    stringFields?: string[];
    nullableStringFields?: string[];
    trimStringArrayFields?: string[];
  }
): PayloadRecord {
  const result: PayloadRecord = {...data};
  for (const field of options.stringFields ?? []) {
    if (typeof result[field] === "string") {
      result[field] = result[field].trim();
    }
  }
  for (const field of options.nullableStringFields ?? []) {
    if (typeof result[field] === "string") {
      result[field] = result[field].trim();
    }
  }
  for (const field of options.trimStringArrayFields ?? []) {
    if (Array.isArray(result[field])) {
      result[field] = result[field].map((item) =>
        typeof item === "string" ? item.trim() : item
      );
    }
  }
  return result;
}

/**
 * Checks whether a value can be treated as a plain payload object.
 * @param {unknown} value Value to inspect.
 * @return {boolean} Whether the value is a record.
 */
function isRecord(value: unknown): value is PayloadRecord {
  return typeof value === "object" && value !== null &&
    !Array.isArray(value);
}
