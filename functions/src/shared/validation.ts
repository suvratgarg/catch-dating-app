import {CallableRequest, HttpsError} from "firebase-functions/v2/https";
import {ValidateFunction} from "ajv";

/**
 * Validates a callable request body against a generated Ajv validator.
 *
 * The optional normalizer keeps input cleanup explicit at the callable
 * boundary; JSON Schema validation itself must stay side-effect free.
 * @param {CallableRequest<unknown>} request The incoming callable request.
 * @param {ValidateFunction<T>} validator Generated Ajv validator.
 * @param {function(unknown): unknown} [normalize] Optional input normalizer.
 * @return {T} Validated request data.
 */
export function validateCallableWithAjv<T>(
  request: CallableRequest<unknown>,
  validator: ValidateFunction<T>,
  normalize: (data: unknown) => unknown = (data) => data
): T {
  const data = normalize(request.data);
  if (validator(data)) return data;
  const message = (validator.errors ?? [])
    .map((error) => {
      const location = error.instancePath
        .split("/")
        .filter((part) => part.length > 0)
        .join(".");
      return `${location}: ${error.message ?? "failed validation"}`;
    })
    .join("; ");
  throw new HttpsError("invalid-argument", message);
}

/**
 * Extracts and validates data from a Firestore DocumentSnapshot.
 *
 * Throws `internal` if the document is empty (data() returns undefined),
 * which indicates a data integrity issue — the document should always
 * exist and have data if the caller checked `.exists`.
 *
 * @param {FirebaseFirestore.DocumentSnapshot} snap A Firestore doc snapshot.
 * @param {string} label Human-readable label for error messages.
 * @return {T} The document data cast to T.
 */
export function requireDoc<T>(
  snap: FirebaseFirestore.DocumentSnapshot,
  label: string,
): T {
  const data = snap.data();
  if (data === undefined) {
    throw new HttpsError(
      "internal",
      `${label} document is empty or missing.`
    );
  }
  return data as T;
}
