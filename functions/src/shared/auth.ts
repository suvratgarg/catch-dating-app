import {CallableRequest, HttpsError} from "firebase-functions/v2/https";

/**
 * Extracts the authenticated user's UID from a callable request.
 *
 * Throws `unauthenticated` if the caller is not signed in.
 * @param {CallableRequest<unknown>} request The incoming callable request.
 * @return {string} The authenticated user's UID.
 */
export function requireAuth(request: CallableRequest<unknown>): string {
  if (!request.auth) {
    throw new HttpsError("unauthenticated", "You must be signed in.");
  }
  return request.auth.uid;
}
