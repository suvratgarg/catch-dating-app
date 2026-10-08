import {webcrypto, generateKeyPairSync, createHash, privateDecrypt, sign, constants} from "node:crypto";
import {beforeEach, expect, it, vi} from "vitest";
import {createSessionTransport, sessionLaunch, sessionRequest, takeSessionLaunch, type SessionLaunch} from "./operatorSessionTransport";
const encryption = generateKeyPairSync("rsa", {modulusLength: 2048});
const signing = generateKeyPairSync("rsa", {modulusLength: 2048});
const replacement = generateKeyPairSync("rsa", {modulusLength: 2048});
const anchor = (): SessionLaunch => ({kind: "catch-operator-session-launch", schemaVersion: 1,
  localOrigin: "http://127.0.0.1:12345", challenge: "a".repeat(64), bootstrapCapability: "b".repeat(64),
  serverEncryptionKey: encryption.publicKey.export({type: "spki", format: "der"}).toString("base64url"),
  serverSigningKey: signing.publicKey.export({type: "spki", format: "der"}).toString("base64url"), sourceSha: "c".repeat(40), expiresAtMillis: Date.now() + 300000});
const fragment = (launch: SessionLaunch) => "#" + Buffer.from(JSON.stringify(launch)).toString("base64url");
beforeEach(() => {vi.stubGlobal("crypto", webcrypto);});
function response(launch: SessionLaunch, url: string, init: RequestInit, payload: unknown, privateKey = signing.privateKey) {
  const headers = init.headers as Record<string, string>, body = init.body as string;
  const value = JSON.stringify(payload), route = new URL(url).pathname;
  const context = JSON.stringify([launch.challenge, launch.sourceSha, launch.expiresAtMillis, "POST", route,
    headers["X-Catch-Request"], createHash("sha256").update(body).digest("hex"), 200, value]);
  const signature = sign("sha256", Buffer.from(context), {key: privateKey, padding: constants.RSA_PKCS1_PSS_PADDING, saltLength: 32}).toString("base64url");
  return new Response(JSON.stringify({payload: value, signature}), {status: 200});
}
it("pins private-file material once, scrubs the fragment and severs opener authority", () => {
  const launch = anchor(); let hash = fragment(launch);
  const target = {location: {get hash() {return hash;}, protocol: "https:", pathname: "/operator-session"},
    history: {replaceState: vi.fn(() => {hash = "";})}, opener: {}} as unknown as Window;
  const first = takeSessionLaunch(target); expect(first).toEqual(launch); expect(hash).toBe(""); expect(target.opener).toBeNull();
  hash = fragment({...launch, serverEncryptionKey: replacement.publicKey.export({type: "spki", format: "der"}).toString("base64url")});
  expect(takeSessionLaunch(target)).toBe(first); expect(Object.isFrozen(first)).toBe(true);
  expect(() => sessionLaunch(fragment({...launch, serverSigningKey: launch.serverEncryptionKey}))).toThrow();
});
it("encrypts even the first bootstrap before any HTTP interaction, with no redirects or browser credentials", async () => {
  const launch = anchor(); let input: RequestInit | undefined;
  const dispatch = vi.fn(async (url, init) => {
    input = init;
    const encrypted = JSON.parse(init!.body as string).encryptedBootstrap;
    expect(init!.body).not.toContain(launch.bootstrapCapability);
    expect(privateDecrypt({key: encryption.privateKey, oaepHash: "sha256", oaepLabel: Buffer.from("catch-operator-session/bootstrap/" + launch.challenge)}, Buffer.from(encrypted, "base64url")).toString()).toBe(launch.bootstrapCapability);
    expect(() => privateDecrypt({key: replacement.privateKey, oaepHash: "sha256"}, Buffer.from(encrypted, "base64url"))).toThrow();
    return response(launch, String(url), init!, {state: "bound"});
  }) as typeof fetch;
  expect(await createSessionTransport(launch, dispatch).bootstrap()).toEqual({state: "bound"});
  expect(input).toMatchObject({method: "POST", redirect: "error", credentials: "omit", mode: "cors", referrerPolicy: "no-referrer"});
});
it.each(["replacement", "payload", "request-id", "request-body", "path", "status"])("rejects %s response substitution before trusting data", async mutation => {
  const launch = anchor();
  const dispatch = vi.fn(async (url, init) => {
    const different = {...init!, headers: {...init!.headers}};
    if (mutation === "request-id") (different.headers as Record<string, string>)["X-Catch-Request"] = "d".repeat(64);
    if (mutation === "request-body") different.body = "{}";
    const signed = response(launch, mutation === "path" ? launch.localOrigin + "/configure" : String(url), different,
      {state: "bound"}, mutation === "replacement" ? replacement.privateKey : signing.privateKey);
    const value = JSON.parse(await signed.text());
    if (mutation === "payload") value.payload = JSON.stringify({state: "forged"});
    return new Response(JSON.stringify(value), {status: mutation === "status" ? 201 : 200});
  }) as typeof fetch;
  await expect(createSessionTransport(launch, dispatch).bootstrap()).rejects.toThrow();
});
it("rejects a previously signed response when another request has a fresh ID", async () => {
  const launch = anchor(); let saved: string | undefined;
  const dispatch = vi.fn(async (url, init) => {
    saved ??= await response(launch, String(url), init!, {state: "bound"}).text();
    return new Response(saved, {status: 200});
  }) as typeof fetch;
  const transport = createSessionTransport(launch, dispatch);
  await transport.post("/configure", {fake: true}, "d".repeat(64));
  await expect(transport.post("/configure", {fake: true}, "d".repeat(64))).rejects.toThrow();
});
it("does not retry a lost response or local-network denial", async () => {
  const launch = anchor(); const dispatch = vi.fn().mockRejectedValue(new Error("network unavailable"));
  await expect(createSessionTransport(launch, dispatch).bootstrap()).rejects.toThrow(); expect(dispatch).toHaveBeenCalledOnce();
});
it("dispatches an unload cancellation immediately without trusting its response", () => {
  const dispatch = vi.fn().mockResolvedValue(new Response("forged response"));
  createSessionTransport(anchor(), dispatch).cancelOnUnload("d".repeat(64));
  expect(dispatch).toHaveBeenCalledOnce();
  expect(dispatch.mock.calls[0]![1]).toMatchObject({method: "POST", body: "{}", keepalive: true, credentials: "omit", redirect: "error"});
});

it.each([300001, 899000, 900000])("accepts a private launch and request with %i milliseconds remaining", remaining => {
  const now = Date.now(), launch = {...anchor(), expiresAtMillis: now + remaining};
  expect(sessionLaunch(fragment(launch), now)).toEqual(launch);
  const request = {kind: "catch-operator-session-request", schemaVersion: 1,
    challenge: launch.challenge, projectId: "demo-catch-setup", actorUid: "actor",
    actorEmailSha256: "d".repeat(64), scopeSha256: "e".repeat(64), sourceSha: launch.sourceSha,
    expiresAtMillis: launch.expiresAtMillis, serverEncryptionKey: launch.serverEncryptionKey,
    serverSigningKey: launch.serverSigningKey};
  expect(sessionRequest(request, now)).toEqual(request);
  for (const invalid of [now, now - 1, now + 900001]) {
    expect(() => sessionLaunch(fragment({...launch, expiresAtMillis: invalid}), now)).toThrow();
    expect(() => sessionRequest({...request, expiresAtMillis: invalid}, now)).toThrow();
  }
});
