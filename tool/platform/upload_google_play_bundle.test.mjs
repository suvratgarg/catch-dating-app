import assert from "node:assert/strict";
import {createHash} from "node:crypto";
import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import test from "node:test";
import {
  preflightGooglePlayBundle,
  uploadGooglePlayBundle,
} from "./upload_google_play_bundle.mjs";

const expectedSha256 = createHash("sha256").update("signed-bundle").digest("hex");
const otherSha256 = "b".repeat(64);

function response(payload = {}, status = 200) {
  return {
    ok: status >= 200 && status < 300,
    status,
    statusText: status === 200 ? "OK" : "Failure",
    text: async () => status === 204 ? "" : JSON.stringify(payload),
  };
}

function bundleFile(contents = "signed-bundle") {
  const directory = fs.mkdtempSync(path.join(os.tmpdir(), "catch-play-upload-"));
  const bundlePath = path.join(directory, "app.aab");
  fs.writeFileSync(bundlePath, contents);
  return bundlePath;
}

function completedTrack(versionCode = "100021", status = "completed") {
  return {
    track: "qa",
    releases: [{status, versionCodes: [String(versionCode)]}],
  };
}

function exactBundles(sha256 = expectedSha256, versionCode = "100021") {
  return {bundles: [{versionCode: Number(versionCode), sha256}]};
}

function queueFetch(responses, requests) {
  return async (url, options = {}) => {
    requests.push({url, options});
    assert.ok(responses.length > 0, `Unexpected request: ${options.method ?? "GET"} ${url}`);
    return responses.shift();
  };
}

test("Play uploader binds exact AAB bytes and verifies completed qa readback", async () => {
  const requests = [];
  const responses = [
    response({id: "edit-1"}),
    response({track: "qa", releases: []}),
    response({bundles: []}),
    response({versionCode: 100021, sha256: expectedSha256}),
    response(completedTrack()),
    response({id: "edit-1"}),
    response({id: "verify-1"}),
    response(completedTrack()),
    response(exactBundles()),
    response({}, 204),
  ];
  const result = await uploadGooglePlayBundle({
    packageName: "com.catchdates.host",
    bundlePath: bundleFile(),
    versionCode: "100021",
    sha256: expectedSha256,
    accessToken: "token",
    releaseName: "Test release",
    fetchImpl: queueFetch(responses, requests),
  });

  assert.equal(result.operation, "uploaded");
  assert.equal(result.versionCode, "100021");
  const upload = requests.find((request) => request.url.includes("uploadType=media"));
  assert.ok(upload);
  const update = requests.find((request) => request.options.method === "PUT");
  assert.deepEqual(JSON.parse(update.options.body).releases[0], {
    name: "Test release",
    versionCodes: ["100021"],
    status: "completed",
  });
  assert.equal(responses.length, 0);
});

test("exact completed qa package is idempotent and performs no upload or track mutation", async () => {
  const requests = [];
  const result = await uploadGooglePlayBundle({
    packageName: "com.catchdates.app",
    bundlePath: bundleFile(),
    versionCode: "100021",
    sha256: expectedSha256,
    accessToken: "token",
    fetchImpl: queueFetch([
      response({id: "edit-1"}),
      response(completedTrack()),
      response(exactBundles()),
      response({}, 204),
    ], requests),
  });
  assert.equal(result.operation, "already-promoted");
  assert.equal(requests.some((request) => request.url.includes("uploadType=media")), false);
  assert.equal(requests.some((request) => request.options.method === "PUT"), false);
  assert.equal(requests.some((request) => request.url.includes(":commit")), false);
});

test("same version code with different remote SHA fails before track mutation", async () => {
  const requests = [];
  await assert.rejects(
    preflightGooglePlayBundle({
      packageName: "com.catchdates.app",
      versionCode: "100021",
      sha256: expectedSha256,
      accessToken: "token",
      fetchImpl: queueFetch([
        response({id: "edit-1"}),
        response(completedTrack()),
        response(exactBundles(otherSha256)),
        response({}, 204),
      ], requests),
    }),
    /different AAB bytes/u,
  );
  assert.equal(requests.some((request) => request.options.method === "PUT"), false);
});

test("wrong local AAB bytes fail before any Google Play request", async () => {
  let requests = 0;
  await assert.rejects(
    uploadGooglePlayBundle({
      packageName: "com.catchdates.app",
      bundlePath: bundleFile("substituted-bundle"),
      versionCode: "100021",
      sha256: expectedSha256,
      accessToken: "token",
      fetchImpl: async () => {
        requests += 1;
        return response({});
      },
    }),
    /Local Android App Bundle SHA-256/u,
  );
  assert.equal(requests, 0);
});

test("symlinked local AAB fails before any Google Play request", async () => {
  const target = bundleFile();
  const symlink = `${target}.link`;
  fs.symlinkSync(target, symlink);
  let requests = 0;
  await assert.rejects(
    uploadGooglePlayBundle({
      packageName: "com.catchdates.app",
      bundlePath: symlink,
      versionCode: "100021",
      sha256: expectedSha256,
      accessToken: "token",
      fetchImpl: async () => {
        requests += 1;
        return response({});
      },
    }),
    /regular non-symlink/u,
  );
  assert.equal(requests, 0);
});

test("old exact bundle inventory cannot roll back a newer qa release", async () => {
  const requests = [];
  await assert.rejects(
    preflightGooglePlayBundle({
      packageName: "com.catchdates.app",
      versionCode: "100021",
      sha256: expectedSha256,
      accessToken: "token",
      fetchImpl: queueFetch([
        response({id: "edit-1"}),
        response(completedTrack("100022")),
        response(exactBundles()),
        response({}, 204),
      ], requests),
    }),
    /newer version code/u,
  );
  assert.equal(requests.some((request) => request.options.method === "PUT"), false);
});

test("upload response version or digest mismatch aborts before qa update", async () => {
  for (const uploadPayload of [
    {versionCode: 100022, sha256: expectedSha256},
    {versionCode: 100021, sha256: otherSha256},
  ]) {
    const requests = [];
    await assert.rejects(
      uploadGooglePlayBundle({
        packageName: "com.catchdates.app",
        bundlePath: bundleFile(),
        versionCode: "100021",
        sha256: expectedSha256,
        accessToken: "token",
        fetchImpl: queueFetch([
          response({id: "edit-1"}),
          response({track: "qa", releases: []}),
          response({bundles: []}),
          response(uploadPayload),
          response({}, 204),
        ], requests),
      }),
      /Refusing track mutation|upload response SHA-256/u,
    );
    assert.equal(requests.some((request) => request.options.method === "PUT"), false);
    assert.equal(requests.some((request) => request.url.includes(":commit")), false);
  }
});

test("track update retaining a newer qa version aborts before commit", async () => {
  const requests = [];
  await assert.rejects(
    uploadGooglePlayBundle({
      packageName: "com.catchdates.app",
      bundlePath: bundleFile(),
      versionCode: "100021",
      sha256: expectedSha256,
      accessToken: "token",
      fetchImpl: queueFetch([
        response({id: "edit-1"}),
        response({track: "qa", releases: []}),
        response({bundles: []}),
        response({versionCode: 100021, sha256: expectedSha256}),
        response({
          track: "qa",
          releases: [
            {status: "completed", versionCodes: ["100021"]},
            {status: "completed", versionCodes: ["100022"]},
          ],
        }),
        response({}, 204),
      ], requests),
    }),
    /retained a newer qa version/u,
  );
  assert.equal(requests.some((request) => request.url.includes(":commit")), false);
});

test("draft or halted qa entry is not treated as delivered", async () => {
  for (const status of ["draft", "inProgress", "halted"]) {
    const requests = [];
    const result = await preflightGooglePlayBundle({
      packageName: "com.catchdates.app",
      versionCode: "100021",
      sha256: expectedSha256,
      accessToken: "token",
      fetchImpl: queueFetch([
        response({id: `edit-${status}`}),
        response(completedTrack("100021", status)),
        response(exactBundles()),
        response({}, 204),
      ], requests),
    });
    assert.equal(result.action, "resume-required");
  }
});

test("post-commit readback must contain exact digest and completed qa status", async () => {
  for (const [track, bundles] of [
    [completedTrack("100021", "draft"), exactBundles()],
    [completedTrack(), exactBundles(otherSha256)],
  ]) {
    await assert.rejects(
      uploadGooglePlayBundle({
        packageName: "com.catchdates.app",
        bundlePath: bundleFile(),
        versionCode: "100021",
        sha256: expectedSha256,
        accessToken: "token",
        fetchImpl: queueFetch([
          response({id: "edit-1"}),
          response({track: "qa", releases: []}),
          response({bundles: []}),
          response({versionCode: 100021, sha256: expectedSha256}),
          response(completedTrack()),
          response({id: "edit-1"}),
          response({id: "verify-1"}),
          response(track),
          response(bundles),
          response({}, 204),
        ], []),
      }),
      /post-commit readback|different AAB bytes/u,
    );
  }
});

test("ambiguous first result can retry without a second upload after exact store commit", async () => {
  const requests = [];
  const result = await uploadGooglePlayBundle({
    packageName: "com.catchdates.app",
    bundlePath: bundleFile(),
    versionCode: "100021",
    sha256: expectedSha256,
    accessToken: "token",
    fetchImpl: queueFetch([
      response({id: "retry-edit"}),
      response(completedTrack()),
      response(exactBundles()),
      response({}, 204),
    ], requests),
  });
  assert.equal(result.operation, "already-promoted");
  assert.equal(requests.some((request) => request.url.includes("uploadType=media")), false);
});

test("Play uploader refuses production-track publishing", async () => {
  await assert.rejects(
    uploadGooglePlayBundle({
      packageName: "com.catchdates.app",
      bundlePath: bundleFile(),
      versionCode: "100021",
      sha256: expectedSha256,
      accessToken: "token",
      track: "production",
    }),
    /restricted to the qa track/u,
  );
});
