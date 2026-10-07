import {getIdTokenResult, type Auth} from "firebase/auth";

export interface SessionRequest {
  kind: "catch-operator-session-request";
  schemaVersion: 1;
  challenge: string;
  projectId: string;
  actorUid: string;
  actorEmailSha256: string;
  scopeSha256: string;
  sourceSha: string;
  expiresAtMillis: number;
}
function unavailable(): never {throw new Error("Protected session handoff unavailable.");}
export function loopbackOrigin(origin: string): boolean {
  try {
    const url = new URL(origin);
    return url.origin === origin && url.protocol === "http:" &&
      url.hostname === "127.0.0.1" && Number(url.port) > 1023 &&
      url.pathname === "/" && !url.username && !url.password;
  } catch {return false;}
}
export function sessionRequest(value: unknown, now = Date.now()): SessionRequest {
  if (!value || typeof value !== "object") unavailable();
  const request = value as SessionRequest;
  if (Object.keys(request).sort().join(",") !==
      "actorEmailSha256,actorUid,challenge,expiresAtMillis,kind,projectId,schemaVersion,scopeSha256,sourceSha" ||
      request.kind !== "catch-operator-session-request" || request.schemaVersion !== 1 ||
      ![request.actorUid, request.projectId, request.challenge, request.actorEmailSha256,
        request.scopeSha256, request.sourceSha].every(value => typeof value === "string") ||
      !/^[A-Za-z0-9_-]{1,128}$/u.test(request.actorUid) ||
      !/^[a-z][a-z0-9-]{4,28}[a-z0-9]$/u.test(request.projectId) ||
      ![request.challenge, request.actorEmailSha256, request.scopeSha256].every(value => /^[a-f0-9]{64}$/u.test(value)) ||
      !/^[a-f0-9]{40}$/u.test(request.sourceSha) ||
      !Number.isSafeInteger(request.expiresAtMillis) || request.expiresAtMillis <= now ||
      request.expiresAtMillis > now + 5 * 60 * 1000) unavailable();
  return {...request};
}

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
  return {kind: "catch-operator-session-transfer", challenge: request.challenge, idToken: result.token};
}
