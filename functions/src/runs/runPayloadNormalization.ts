type PayloadRecord = Record<string, unknown>;

/**
 * Trims create-run text fields before generated schema validation.
 * @param {unknown} data Raw callable payload.
 * @return {unknown} Normalized payload.
 */
export function normalizeCreateRunPayload(data: unknown): unknown {
  if (!isRecord(data)) return data;
  return normalizeFields(data, {
    stringFields: [
      "runId",
      "runClubId",
      "meetingPoint",
      "description",
    ],
    nullableStringFields: ["locationDetails", "photoUrl"],
  });
}

/**
 * Trims update-run payload and nested patch fields before validation.
 * @param {unknown} data Raw callable payload.
 * @return {unknown} Normalized payload.
 */
export function normalizeUpdateRunPayload(data: unknown): unknown {
  if (!isRecord(data)) return data;
  const payload = normalizeFields(data, {stringFields: ["runId"]});
  if (!isRecord(payload.fields)) return payload;
  return {
    ...payload,
    fields: normalizeFields(payload.fields, {
      stringFields: ["meetingPoint", "description"],
      nullableStringFields: ["locationDetails", "photoUrl"],
    }),
  };
}

/**
 * Trims cancel-run payload fields before validation.
 * @param {unknown} data Raw callable payload.
 * @return {unknown} Normalized payload.
 */
export function normalizeCancelRunPayload(data: unknown): unknown {
  if (!isRecord(data)) return data;
  return normalizeFields(data, {
    stringFields: ["runId"],
    nullableStringFields: ["reason"],
  });
}

/**
 * Trims payloads whose primary field is runId.
 * @param {unknown} data Raw callable payload.
 * @return {unknown} Normalized payload.
 */
export function normalizeRunIdPayload(data: unknown): unknown {
  if (!isRecord(data)) return data;
  return normalizeFields(data, {stringFields: ["runId"]});
}

/**
 * Trims attendance payload ids before validation.
 * @param {unknown} data Raw callable payload.
 * @return {unknown} Normalized payload.
 */
export function normalizeMarkRunAttendancePayload(data: unknown): unknown {
  if (!isRecord(data)) return data;
  return normalizeFields(data, {stringFields: ["runId", "userId"]});
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
