type PayloadRecord = Record<string, unknown>;

/**
 * Trims create-event text fields before generated schema validation.
 * @param {unknown} data Raw callable payload.
 * @return {unknown} Normalized payload.
 */
export function normalizeCreateEventPayload(data: unknown): unknown {
  if (!isRecord(data)) return data;
  const payload = normalizeFields(data, {
    stringFields: [
      "eventId",
      "clubId",
      "meetingPoint",
      "description",
    ],
    nullableStringFields: ["locationDetails", "photoUrl"],
  });
  if (!isRecord(payload.privateAccess)) return payload;
  return {
    ...payload,
    privateAccess: normalizeFields(payload.privateAccess, {
      stringFields: ["inviteCode"],
    }),
  };
}

/**
 * Trims update-event payload and nested patch fields before validation.
 * @param {unknown} data Raw callable payload.
 * @return {unknown} Normalized payload.
 */
export function normalizeUpdateEventPayload(data: unknown): unknown {
  if (!isRecord(data)) return data;
  const payload = normalizeFields(data, {stringFields: ["eventId"]});
  if (!isRecord(payload.fields)) return payload;
  const normalizedFields = normalizeFields(payload.fields, {
    stringFields: ["meetingPoint", "description"],
    nullableStringFields: ["locationDetails", "photoUrl"],
  });
  if (isRecord(normalizedFields.privateAccess)) {
    normalizedFields.privateAccess = normalizeFields(
      normalizedFields.privateAccess,
      {nullableStringFields: ["inviteCode"]}
    );
  }
  return {
    ...payload,
    fields: normalizedFields,
  };
}

/**
 * Trims cancel-event payload fields before validation.
 * @param {unknown} data Raw callable payload.
 * @return {unknown} Normalized payload.
 */
export function normalizeCancelEventPayload(data: unknown): unknown {
  if (!isRecord(data)) return data;
  return normalizeFields(data, {
    stringFields: ["eventId"],
    nullableStringFields: ["reason"],
  });
}

/**
 * Trims payloads whose primary field is eventId.
 * @param {unknown} data Raw callable payload.
 * @return {unknown} Normalized payload.
 */
export function normalizeEventIdPayload(data: unknown): unknown {
  if (!isRecord(data)) return data;
  return normalizeFields(data, {
    stringFields: ["eventId"],
    nullableStringFields: ["inviteCode"],
  });
}

/**
 * Trims attendance payload ids before validation.
 * @param {unknown} data Raw callable payload.
 * @return {unknown} Normalized payload.
 */
export function normalizeMarkEventAttendancePayload(data: unknown): unknown {
  if (!isRecord(data)) return data;
  return normalizeFields(data, {stringFields: ["eventId", "userId"]});
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
