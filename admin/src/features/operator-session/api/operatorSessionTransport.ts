export interface SessionLaunch {
  kind: "catch-operator-session-launch";
  schemaVersion: 1;
  localOrigin: string;
  bootstrapCapability: string;
  challenge: string;
  serverEncryptionKey: string;
  serverSigningKey: string;
  sourceSha: string;
  expiresAtMillis: number;
}
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
  serverEncryptionKey: string;
  serverSigningKey: string;
}
function unavailable(): never {throw new Error("Protected session handoff unavailable.");}
const encode = (value: string) => new TextEncoder().encode(value);
const b64 = (bytes: ArrayBuffer | Uint8Array<ArrayBuffer>) => btoa(String.fromCharCode(...new Uint8Array(bytes))).replaceAll("+", "-").replaceAll("/", "_").replace(/=+$/u, "");
function binary(value: unknown, min: number, max = min): Uint8Array<ArrayBuffer> {
  if (typeof value !== "string" || !/^[A-Za-z0-9_-]+$/u.test(value) || value.length > Math.ceil(max * 4 / 3)) unavailable();
  const text = atob(value.replaceAll("-", "+").replaceAll("_", "/"));
  const bytes = Uint8Array.from(text, char => char.charCodeAt(0));
  if (bytes.length < min || bytes.length > max || b64(bytes) !== value) unavailable();
  return bytes;
}
export function loopbackOrigin(origin: string): boolean {
  try {
    const url = new URL(origin);
    return url.origin === origin && url.protocol === "http:" && url.hostname === "127.0.0.1" && Number(url.port) > 1023;
  } catch {return false;}
}
function deadline(value: unknown, now: number) {
  if (typeof value !== "number" || !Number.isSafeInteger(value) || value <= now || value > now + 15 * 60 * 1000) unavailable();
}
export function sessionLaunch(fragment: string, now = Date.now()): Readonly<SessionLaunch> {
  const value = JSON.parse(new TextDecoder("utf-8", {fatal: true}).decode(binary(fragment.replace(/^#/u, ""), 1, 4096))) as SessionLaunch;
  if (!value || Object.keys(value).sort().join(",") !== "bootstrapCapability,challenge,expiresAtMillis,kind,localOrigin,schemaVersion,serverEncryptionKey,serverSigningKey,sourceSha" ||
      value.kind !== "catch-operator-session-launch" || value.schemaVersion !== 1 ||
      !loopbackOrigin(value.localOrigin) || !/^[a-f0-9]{40}$/u.test(value.sourceSha) ||
      ![value.challenge, value.bootstrapCapability].every(v => typeof v === "string" && /^[a-f0-9]{64}$/u.test(v))) unavailable();
  binary(value.serverEncryptionKey, 294); binary(value.serverSigningKey, 294);
  if (value.serverEncryptionKey === value.serverSigningKey) unavailable();
  deadline(value.expiresAtMillis, now);
  return Object.freeze({...value});
}
const launches = new WeakMap<Window, Readonly<SessionLaunch> | null>();
export function takeSessionLaunch(target: Window = window): Readonly<SessionLaunch> | null {
  if (launches.has(target)) return launches.get(target)!;
  const fragment = target.location.hash;
  target.history.replaceState(null, "", target.location.pathname);
  target.opener = null;
  let pinned: Readonly<SessionLaunch> | null = null;
  try {if (target.location.protocol === "https:") pinned = sessionLaunch(fragment);} catch { /* Fixed unavailable UI. */ }
  launches.set(target, pinned);
  return pinned;
}
export function sessionRequest(value: unknown, now = Date.now()): Readonly<SessionRequest> {
  if (!value || typeof value !== "object") unavailable();
  const request = value as SessionRequest;
  if (Object.keys(request).sort().join(",") !== "actorEmailSha256,actorUid,challenge,expiresAtMillis,kind,projectId,schemaVersion,scopeSha256,serverEncryptionKey,serverSigningKey,sourceSha" ||
      request.kind !== "catch-operator-session-request" || request.schemaVersion !== 1 ||
      ![request.actorUid, request.projectId, request.challenge, request.actorEmailSha256, request.scopeSha256, request.sourceSha].every(v => typeof v === "string") ||
      !/^[A-Za-z0-9_-]{1,128}$/u.test(request.actorUid) || !/^[a-z][a-z0-9-]{4,28}[a-z0-9]$/u.test(request.projectId) ||
      ![request.challenge, request.actorEmailSha256, request.scopeSha256].every(v => /^[a-f0-9]{64}$/u.test(v)) || !/^[a-f0-9]{40}$/u.test(request.sourceSha)) unavailable();
  binary(request.serverEncryptionKey, 294); binary(request.serverSigningKey, 294);
  if (request.serverEncryptionKey === request.serverSigningKey) unavailable();
  deadline(request.expiresAtMillis, now);
  return Object.freeze({...request});
}
const key = (spki: string, name: "RSA-OAEP" | "RSA-PSS", usage: KeyUsage) => crypto.subtle.importKey("spki", binary(spki, 294), {name, hash: "SHA-256"}, false, [usage]);
export async function sealSession(request: SessionRequest, token: string) {
  const context = JSON.stringify(Object.keys(request).sort().map(k => [k, request[k as keyof SessionRequest]]));
  const encryptionKey = await key(request.serverEncryptionKey, "RSA-OAEP", "encrypt");
  const aes = await crypto.subtle.generateKey({name: "AES-GCM", length: 256}, true, ["encrypt"]);
  const iv = crypto.getRandomValues(new Uint8Array(12));
  const ciphertext = await crypto.subtle.encrypt({name: "AES-GCM", iv, additionalData: encode(context)}, aes, encode(token));
  const wrappedKey = await crypto.subtle.encrypt({name: "RSA-OAEP", label: encode("catch-operator-session/token/" + context)}, encryptionKey, await crypto.subtle.exportKey("raw", aes));
  return {wrappedKey: b64(wrappedKey), iv: b64(iv), ciphertext: b64(ciphertext)};
}
export function createSessionTransport(launch: Readonly<SessionLaunch>, dispatch = fetch) {
  // Freeze an independent copy. No HTTP response may update either key.
  const pinned = sessionLaunch(b64(encode(JSON.stringify(launch))));
  const post = async (route: "/bootstrap" | "/configure" | "/session" | "/cancel", value: unknown, csrf?: string) => {
    if (Date.now() >= pinned.expiresAtMillis) unavailable();
    const requestId = b64(crypto.getRandomValues(new Uint8Array(32)));
    const id = Array.from(binary(requestId, 32), b => b.toString(16).padStart(2, "0")).join("");
    const body = JSON.stringify(value);
    const digest = Array.from(new Uint8Array(await crypto.subtle.digest("SHA-256", encode(body))), b => b.toString(16).padStart(2, "0")).join("");
    const response = await dispatch(pinned.localOrigin + route, {method: "POST", mode: "cors", credentials: "omit", redirect: "error", referrerPolicy: "no-referrer", signal: AbortSignal.timeout(12000),
      headers: {"Content-Type": "application/json", "X-Catch-Request": id, ...(csrf ? {"X-Catch-CSRF": csrf} : {})}, body});
    const raw = await response.text();
    if (raw.length > 131072) unavailable();
    const signed = JSON.parse(raw) as {payload: string; signature: string};
    if (!signed || Object.keys(signed).sort().join(",") !== "payload,signature" || typeof signed.payload !== "string") unavailable();
    const context = JSON.stringify([pinned.challenge, pinned.sourceSha, pinned.expiresAtMillis, "POST", route, id, digest, response.status, signed.payload]);
    if (!await crypto.subtle.verify({name: "RSA-PSS", saltLength: 32}, await key(pinned.serverSigningKey, "RSA-PSS", "verify"), binary(signed.signature, 256), encode(context)) || Date.now() >= pinned.expiresAtMillis) unavailable();
    const payload: unknown = JSON.parse(signed.payload);
    if (!response.ok && !(route === "/cancel" && response.status === 409)) unavailable();
    return payload;
  };
  return {post, cancelOnUnload(csrf: string) {
    const id = Array.from(crypto.getRandomValues(new Uint8Array(32)), b => b.toString(16).padStart(2, "0")).join("");
    // Dispatch synchronously before teardown. Ignore the response entirely:
    // an unload cannot claim either a confirmed cancellation or an undone save.
    void dispatch(pinned.localOrigin + "/cancel", {method: "POST", mode: "cors", credentials: "omit", redirect: "error", referrerPolicy: "no-referrer", keepalive: true,
      headers: {"Content-Type": "application/json", "X-Catch-Request": id, "X-Catch-CSRF": csrf}, body: "{}"}).catch(() => {});
  }, async bootstrap() {
    const sealed = await crypto.subtle.encrypt({name: "RSA-OAEP", label: encode("catch-operator-session/bootstrap/" + pinned.challenge)}, await key(pinned.serverEncryptionKey, "RSA-OAEP", "encrypt"), encode(pinned.bootstrapCapability));
    return post("/bootstrap", {encryptedBootstrap: b64(sealed)});
  }};
}
