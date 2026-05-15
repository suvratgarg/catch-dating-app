type PayloadRecord = Record<string, unknown>;

interface StringNormalizationOptions {
  stringFields?: string[];
  nullableStringFields?: string[];
}

/**
 * Trims selected top-level string fields while preserving unknown keys for
 * schema validation to reject.
 * @param {unknown} data Raw callable payload.
 * @param {object} options Fields to normalize.
 * @return {unknown} Normalized payload.
 */
export function normalizePayloadStrings(
  data: unknown,
  options: StringNormalizationOptions
): unknown {
  if (!isRecord(data)) return data;
  return normalizeRecordStrings(data, options);
}

/**
 * Trims selected strings on a nested object field.
 * @param {unknown} data Raw callable payload.
 * @param {string} field Nested object field.
 * @param {object} options Fields to normalize.
 * @return {unknown} Normalized payload.
 */
export function normalizeNestedPayloadStrings(
  data: unknown,
  field: string,
  options: StringNormalizationOptions
): unknown {
  if (!isRecord(data)) return data;
  const result: PayloadRecord = {...data};
  if (isRecord(result[field])) {
    result[field] = normalizeRecordStrings(result[field], options);
  }
  return result;
}

/**
 * Normalizes a payload that carries only one required id field.
 * @param {string} field Field name to trim.
 * @return {function(unknown): unknown} Normalizer.
 */
export function normalizeSingleIdPayload(
  field: string
): (data: unknown) => unknown {
  return (data) => normalizePayloadStrings(data, {stringFields: [field]});
}

/**
 * Returns a shallow copy with selected string fields trimmed.
 * @param {PayloadRecord} data Payload record.
 * @param {object} options Fields to normalize.
 * @return {PayloadRecord} Normalized payload.
 */
function normalizeRecordStrings(
  data: PayloadRecord,
  options: StringNormalizationOptions
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
