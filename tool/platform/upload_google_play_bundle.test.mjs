import assert from "node:assert/strict";
import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import test from "node:test";
import {uploadGooglePlayBundle} from "./upload_google_play_bundle.mjs";

function jsonResponse(payload, status = 200) {
  return {
    ok: status >= 200 && status < 300,
    status,
    statusText: status === 200 ? "OK" : "Failure",
    text: async () => JSON.stringify(payload),
  };
}

test("Play uploader commits a signed bundle to the qa track", async () => {
  const directory = fs.mkdtempSync(path.join(os.tmpdir(), "catch-play-upload-"));
  const bundlePath = path.join(directory, "app.aab");
  fs.writeFileSync(bundlePath, "bundle");
  const requests = [];
  const responses = [
    jsonResponse({id: "edit-1"}),
    jsonResponse({versionCode: 100021}),
    jsonResponse({track: "qa"}),
    jsonResponse({id: "edit-1"}),
  ];
  const fetchImpl = async (url, options) => {
    requests.push({url, options});
    return responses.shift();
  };

  const result = await uploadGooglePlayBundle({
    packageName: "com.catchdates.host",
    bundlePath,
    accessToken: "token",
    releaseName: "Test release",
    fetchImpl,
  });

  assert.equal(result.versionCode, "100021");
  assert.equal(result.track, "qa");
  assert.equal(requests.length, 4);
  assert.match(requests[1].url, /\/bundles\?uploadType=media$/u);
  assert.match(requests[2].url, /\/tracks\/qa$/u);
  assert.deepEqual(JSON.parse(requests[2].options.body).releases[0].versionCodes, ["100021"]);
  assert.match(requests[3].url, /edit-1:commit\?changesInReviewBehavior=ERROR_IF_IN_REVIEW$/u);
  assert.equal(requests[3].options.body, undefined);
});

test("Play uploader refuses production-track publishing", async () => {
  await assert.rejects(
    uploadGooglePlayBundle({
      packageName: "com.catchdates.app",
      bundlePath: "/missing.aab",
      accessToken: "token",
      track: "production",
    }),
    /cannot publish to the production track/u,
  );
});
