import assert from "node:assert/strict";
import test from "node:test";
import {
  buildMultipartUpload,
  canaryObjectName,
  CanaryStageError,
  parseArgs,
  probeStorage,
  redact,
} from "./probe_chat_storage_rules.mjs";

test("dry-run arguments are non-mutating and prod apply is guarded", () => {
  const dryRun = parseArgs([
    "--env", "prod", "--uid", "user-1", "--match-id", "match-1",
  ], {});
  assert.equal(dryRun.apply, false);
  assert.throws(
    () => parseArgs([
      "--env", "prod", "--uid", "user-1", "--match-id", "match-1", "--apply",
    ], {}),
    /requires --allow-prod/u
  );
});

test("multipart upload carries uploader ownership metadata", () => {
  const body = buildMultipartUpload({
    objectPath: `matches/match-1/images/${canaryObjectName}`,
    uploaderUid: "user-1",
    boundary: "boundary",
  }).toString("latin1");
  assert.match(body, /"uploaderUid":"user-1"/u);
  assert.match(body, /Content-Type: image\/png/u);
  assert.match(canaryObjectName, /^[A-Za-z0-9_-]{1,180}_[0-9]+\.png$/u);
});

test("probe sends Auth and App Check then deletes the same object", async () => {
  const calls = [];
  const fetchImpl = async (url, options) => {
    calls.push({url, options});
    return response(200, {});
  };
  const result = await probeStorage({
    fetchImpl,
    bucket: "demo.firebasestorage.app",
    objectPath: `matches/match-1/images/${canaryObjectName}`,
    uid: "user-1",
    idToken: "auth-secret",
    appId: "1:123:web:abc",
    appCheckToken: "app-check-secret",
  });
  assert.deepEqual(result, {uploaded: true, deleted: true});
  assert.equal(calls.length, 2);
  assert.equal(calls[0].options.headers.Authorization, "Firebase auth-secret");
  assert.equal(calls[0].options.headers["X-Firebase-GMPID"], "1:123:web:abc");
  assert.equal(
    calls[0].options.headers["X-Firebase-AppCheck"],
    "app-check-secret"
  );
  assert.equal(calls[1].options.method, "DELETE");
  assert.equal(calls[0].url.split("?name=")[1], encodeURIComponent(
    `matches/match-1/images/${canaryObjectName}`
  ));
  assert.match(calls[1].url, new RegExp(encodeURIComponent(canaryObjectName)));
});

test("unauthorized upload is reported at the upload stage", async () => {
  const fetchImpl = async () => response(403, {
    error: {message: "permission denied"},
  });
  await assert.rejects(
    probeStorage({
      fetchImpl,
      bucket: "demo.firebasestorage.app",
      objectPath: `matches/match-1/images/${canaryObjectName}`,
      uid: "user-1",
      idToken: "auth-secret",
      appId: "1:123:web:abc",
      appCheckToken: null,
    }),
    (error) => error instanceof CanaryStageError &&
      error.stage === "upload" && /permission denied/u.test(error.message)
  );
});

test("credential redaction covers every supplied token", () => {
  assert.equal(
    redact("auth-secret app-check-secret", ["auth-secret", "app-check-secret"]),
    "[redacted] [redacted]"
  );
});

function response(status, body) {
  return {
    ok: status >= 200 && status < 300,
    status,
    async json() {
      return body;
    },
  };
}
