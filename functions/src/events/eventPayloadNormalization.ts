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
      "currency",
    ],
    nullableStringFields: ["locationDetails", "photoUrl"],
  });
  if (isRecord(payload.privateAccess)) {
    payload.privateAccess = normalizeFields(payload.privateAccess, {
      stringFields: ["inviteCode"],
    });
  }
  if (isRecord(payload.meetingLocation)) {
    payload.meetingLocation = normalizeMeetingLocation(
      payload.meetingLocation
    );
  }
  if (typeof payload.currency === "string") {
    payload.currency = payload.currency.toUpperCase();
  }
  if (isRecord(payload.eventSuccessDefaults)) {
    payload.eventSuccessDefaults = normalizeEventSuccessDefaults(
      payload.eventSuccessDefaults
    );
  }
  return payload;
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
  if (isRecord(normalizedFields.meetingLocation)) {
    normalizedFields.meetingLocation = normalizeMeetingLocation(
      normalizedFields.meetingLocation
    );
  }
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
    nullableStringFields: ["inviteCode", "inviteLinkId"],
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
 * Trims join-request decision payload ids and decision before validation.
 * @param {unknown} data Raw callable payload.
 * @return {unknown} Normalized payload.
 */
export function normalizeEventJoinRequestDecisionPayload(
  data: unknown
): unknown {
  if (!isRecord(data)) return data;
  return normalizeFields(data, {
    stringFields: ["eventId", "userId", "decision"],
  });
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
 * Trims the optional event-success create payload before schema validation.
 * @param {PayloadRecord} data Event success defaults payload.
 * @return {PayloadRecord} Normalized event success defaults.
 */
function normalizeEventSuccessDefaults(data: PayloadRecord): PayloadRecord {
  const defaults = normalizeFields(data, {
    stringFields: ["playbookId", "hostGoal"],
    nullableStringFields: ["attendeePrompt"],
  });
  if (Array.isArray(defaults.selectedModuleIds)) {
    defaults.selectedModuleIds = defaults.selectedModuleIds.map((value) =>
      typeof value === "string" ? value.trim() : value
    );
  }
  if (isRecord(defaults.questionnaireConfig)) {
    defaults.questionnaireConfig = normalizeFields(
      defaults.questionnaireConfig,
      {
        stringFields: ["templateId"],
        nullableStringFields: ["customTitle"],
      }
    );
  }
  return defaults;
}

/**
 * Trims structured meeting-location text fields before schema validation.
 * @param {PayloadRecord} data Meeting location payload.
 * @return {PayloadRecord} Normalized meeting location.
 */
function normalizeMeetingLocation(data: PayloadRecord): PayloadRecord {
  return normalizeFields(data, {
    stringFields: ["name"],
    nullableStringFields: ["address", "placeId", "notes"],
  });
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
