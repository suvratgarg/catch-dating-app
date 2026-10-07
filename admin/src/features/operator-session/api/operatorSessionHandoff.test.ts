import {webcrypto, createHash, generateKeyPairSync, privateDecrypt, createDecipheriv} from "node:crypto";
import type {Auth, User, IdTokenResult} from "firebase/auth";
import {beforeEach, describe, expect, it, vi} from "vitest";
import {loopbackOrigin, sessionRequest, transferSession, type SessionRequest} from "./operatorSessionHandoff";
const mocks = vi.hoisted(() => ({getIdTokenResult: vi.fn()}));
vi.mock("firebase/auth", () => ({getIdTokenResult: mocks.getIdTokenResult}));
const now = 1800000000000;
const encryptionKeys = generateKeyPairSync("rsa", {modulusLength: 2048});
const signingKeys = generateKeyPairSync("rsa", {modulusLength: 2048});
const request: SessionRequest = {kind: "catch-operator-session-request", schemaVersion: 1,
  challenge: "a".repeat(64), projectId: "demo-catch-setup", actorUid: "fake-google-actor",
  actorEmailSha256: createHash("sha256").update(JSON.stringify("actor@example.invalid")).digest("hex"),
  scopeSha256: "b".repeat(64), sourceSha: "c".repeat(40), expiresAtMillis: now + 300000,
  serverEncryptionKey: encryptionKeys.publicKey.export({type: "spki", format: "der"}).toString("base64url"),
  serverSigningKey: signingKeys.publicKey.export({type: "spki", format: "der"}).toString("base64url")};
const user = {uid: request.actorUid, email: "Actor@example.invalid", emailVerified: true,
  providerData: [{providerId: "google.com"}]} as User;
const auth = () => ({currentUser: user, app: {options: {projectId: request.projectId}}, tenantId: null}) as Auth;
const result = () => ({token: "synthetic.private.signature", claims: {sub: user.uid, aud: request.projectId,
  iss: "https://securetoken.google.com/" + request.projectId, firebase: {sign_in_provider: "google.com"},
  auth_time: now / 1000 - 1, iat: now / 1000, exp: now / 1000 + 3600}}) as unknown as IdTokenResult;
beforeEach(() => {vi.stubGlobal("crypto", webcrypto); mocks.getIdTokenResult.mockResolvedValue(result());});

describe("protected session protocol", () => {
  it("requires exact loopback origins, strict request shape and a bounded deadline", () => {
    expect(loopbackOrigin("http://127.0.0.1:12345")).toBe(true);
    for (const origin of ["https://127.0.0.1:12345", "http://localhost:12345", "http://127.0.0.1:80", "http://127.0.0.1:12345/path", "http://user@127.0.0.1:12345", "http://127.0.0.1:12345#fragment"]) expect(loopbackOrigin(origin)).toBe(false);
    expect(sessionRequest(request, now)).toEqual(request);
    for (const invalid of [{...request, extra: true}, {...request, expiresAtMillis: now},
      {...request, expiresAtMillis: now + 300001}, {...request, sourceSha: "bad"},
      {...request, challenge: "bad"}, {...request, challenge: [request.challenge]},
      {...request, actorUid: 12345}]) expect(() => sessionRequest(invalid, now)).toThrow("Protected session handoff unavailable.");
  });
  it("exports only the exact signed-in user's current token after forced public SDK verification", async () => {
    const value = await transferSession(auth(), request, () => true, () => now);
    expect(value.challenge).toBe(request.challenge);
    expect(JSON.stringify(value)).not.toContain("synthetic.private.signature");
    const context = JSON.stringify(Object.keys(request).sort().map(k => [k, request[k as keyof SessionRequest]]));
    const aes = privateDecrypt({key: encryptionKeys.privateKey, oaepHash: "sha256", oaepLabel: Buffer.from("catch-operator-session/token/" + context)}, Buffer.from(value.sealedSession.wrappedKey, "base64url"));
    const ciphertext = Buffer.from(value.sealedSession.ciphertext, "base64url");
    const decipher = createDecipheriv("aes-256-gcm", aes, Buffer.from(value.sealedSession.iv, "base64url"));
    decipher.setAAD(Buffer.from(context)); decipher.setAuthTag(ciphertext.subarray(-16));
    expect(Buffer.concat([decipher.update(ciphertext.subarray(0, -16)), decipher.final()]).toString()).toBe("synthetic.private.signature");
    expect(mocks.getIdTokenResult).toHaveBeenCalledExactlyOnceWith(user, true);
  });
  it("rejects missing/different accounts, project, email, provider and tenant without requesting a token", async () => {
    for (const mutation of [{currentUser: null}, {currentUser: {...user, uid: "other"}},
      {currentUser: {...user, emailVerified: false}}, {currentUser: {...user, email: "other@example.invalid"}},
      {currentUser: {...user, providerData: [{providerId: "phone"}]}},
      {app: {options: {projectId: "other-project"}}}, {tenantId: "tenant"}]) {
      await expect(transferSession({...auth(), ...mutation} as Auth, request, () => true, () => now)).rejects.toThrow("Protected session handoff unavailable.");
    }
    expect(mocks.getIdTokenResult).not.toHaveBeenCalled();
  });
  it("rejects stale auth_time even with a freshly issued token and rejects incorrect signed metadata", async () => {
    for (const mutation of [{auth_time: now / 1000 - 301}, {sub: "other"}, {aud: "other-project"},
      {iss: "bad"}, {firebase: {sign_in_provider: "phone"}}, {firebase: {sign_in_provider: "google.com", tenant: "tenant"}},
      {tenant_id: "tenant"}, {exp: now / 1000}, {auth_time: -1}, {iat: now / 1000 + 1}, {exp: now / 1000 + 3601}]) {
      mocks.getIdTokenResult.mockResolvedValue({...result(), claims: {...result().claims, ...mutation}});
      await expect(transferSession(auth(), request, () => true, () => now)).rejects.toThrow("Protected session handoff unavailable.");
    }
  });
  it.each(["cancel", "account", "expiry"])("rechecks %s after asynchronous token refresh", async drift => {
    let resolve!: (value: IdTokenResult) => void, current = true, time = now;
    const session = auth();
    mocks.getIdTokenResult.mockReturnValue(new Promise(r => {resolve = r;}));
    const pending = transferSession(session, request, () => current, () => time);
    await vi.waitFor(() => expect(mocks.getIdTokenResult).toHaveBeenCalledOnce());
    if (drift === "cancel") current = false;
    if (drift === "account") Object.assign(session, {currentUser: {...user}});
    if (drift === "expiry") time = request.expiresAtMillis;
    resolve(result());
    await expect(pending).rejects.toThrow("Protected session handoff unavailable.");
  });
  it("keeps SDK exceptions private to the protected UI's fixed error handling", async () => {
    mocks.getIdTokenResult.mockRejectedValue(new Error("synthetic.private.signature"));
    await expect(transferSession(auth(), request, () => true, () => now)).rejects.toThrow();
  });
});
