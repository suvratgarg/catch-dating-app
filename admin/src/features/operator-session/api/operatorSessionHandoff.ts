import {getIdTokenResult, type Auth} from "firebase/auth";

import {sessionRequest, sealSession, type SessionRequest} from "./operatorSessionTransport";
export {loopbackOrigin, sessionRequest} from "./operatorSessionTransport";
export type {SessionRequest} from "./operatorSessionTransport";
function unavailable(): never {throw new Error("Protected session handoff unavailable.");}

// Export only: no sign-in, reauthentication, linking, custom tokens, persistence
// changes or extra credential store. Refresh cannot update auth_time.
export async function transferSession(auth: Auth, request: SessionRequest,
  isCurrent: () => boolean, now = Date.now) {
  sessionRequest(request, now());
  const user = auth.currentUser;
  if (!user || user.uid !== request.actorUid || !user.emailVerified ||
      !user.email || auth.app.options.projectId !== request.projectId ||
      !user.providerData.some(provider => provider.providerId === "google.com") ||
      auth.tenantId !== null || !isCurrent()) unavailable();
  const email = new TextEncoder().encode(JSON.stringify(user.email.trim().toLowerCase()));
  const digest = await crypto.subtle.digest("SHA-256", email);
  const emailHash = Array.from(new Uint8Array(digest), byte => byte.toString(16).padStart(2, "0")).join("");
  if (emailHash !== request.actorEmailSha256 || !isCurrent() || auth.currentUser !== user) unavailable();
  const result = await getIdTokenResult(user, true);
  const claims = result.claims;
  const firebase = claims.firebase as {sign_in_provider?: unknown; tenant?: unknown} | undefined;
  const time = now();
  const integerSeconds = (value: unknown) => typeof value === "number" &&
    Number.isSafeInteger(value) && value >= 0 && Number.isSafeInteger(value * 1000);
  if (!isCurrent() || auth.currentUser !== user || time >= request.expiresAtMillis ||
      claims.sub !== user.uid || claims.aud !== request.projectId ||
      claims.iss !== "https://securetoken.google.com/" + request.projectId ||
      firebase?.sign_in_provider !== "google.com" || firebase?.tenant !== undefined ||
      claims.tenant_id !== undefined || ![claims.auth_time, claims.iat, claims.exp].every(integerSeconds) ||
      Number(claims.auth_time) > Number(claims.iat) || Number(claims.iat) * 1000 > time ||
      time - Number(claims.auth_time) * 1000 > 5 * 60 * 1000 ||
      Number(claims.exp) * 1000 <= time || Number(claims.exp) <= Number(claims.iat) ||
      Number(claims.exp) - Number(claims.iat) > 3600 || typeof result.token !== "string" ||
      result.token.length > 16384 || !/^[A-Za-z0-9_-]+\.[A-Za-z0-9_-]+\.[A-Za-z0-9_-]+$/u.test(result.token)) unavailable();
  const sealedSession = await sealSession(request, result.token);
  if (!isCurrent() || auth.currentUser !== user || now() >= request.expiresAtMillis) unavailable();
  return {challenge: request.challenge, sealedSession};
}
