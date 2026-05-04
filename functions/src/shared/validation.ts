import {CallableRequest, HttpsError} from "firebase-functions/v2/https";
import {ZodType} from "zod";

/**
 * Validates a callable request body against a Zod schema.
 *
 * Throws `invalid-argument` with a joined message of all validation issues
 * when the body does not match the schema.
 * @param {CallableRequest<unknown>} request The incoming callable request.
 * @param {ZodType<T>} schema The Zod schema to validate against.
 * @return {T} The parsed and typed request data.
 */
export function validateCallable<T>(
  request: CallableRequest<unknown>,
  schema: ZodType<T>,
): T {
  const result = schema.safeParse(request.data);
  if (!result.success) {
    const message = result.error.issues
      .map((i) => `${i.path.join(".")}: ${i.message}`)
      .join("; ");
    throw new HttpsError("invalid-argument", message);
  }
  return result.data;
}

/**
 * Extracts and validates data from a Firestore DocumentSnapshot.
 *
 * Throws `internal` if the document is empty (data() returns undefined),
 * which indicates a data integrity issue — the document should always
 * exist and have data if the caller checked `.exists`.
 *
 * When an optional schema is provided, the data is also validated against
 * it. Schema validation failures throw `internal` (not `invalid-argument`)
 * because the data was written by our own code, not the client.
 *
 * @param {FirebaseFirestore.DocumentSnapshot} snap A Firestore doc snapshot.
 * @param {string} label Human-readable label for error messages.
 * @param {ZodType=} schema Optional Zod schema for shape validation.
 * @return {T} The document data cast to T.
 */
export function requireDoc<T>(
  snap: FirebaseFirestore.DocumentSnapshot,
  label: string,
  schema?: ZodType<T>,
): T {
  const data = snap.data();
  if (data === undefined) {
    throw new HttpsError(
      "internal",
      `${label} document is empty or missing.`
    );
  }
  if (schema) {
    const result = schema.safeParse(data);
    if (!result.success) {
      const issues = result.error.issues
        .map((i) => `${i.path.join(".")}: ${i.message}`)
        .join("; ");
      throw new HttpsError(
        "internal",
        `${label} document shape mismatch: ${issues}`
      );
    }
    return result.data;
  }
  return data as T;
}
