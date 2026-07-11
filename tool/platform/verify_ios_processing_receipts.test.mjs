import assert from "node:assert/strict";
import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import test from "node:test";
import {verifyIosProcessingReceipts} from "./verify_ios_processing_receipts.mjs";

function fixture() {
  const root = fs.mkdtempSync(path.join(os.tmpdir(), "catch-ios-receipts-"));
  const directory = path.join(root, "receipts");
  fs.mkdirSync(path.join(root, "tool"), {recursive: true});
  fs.mkdirSync(directory);
  fs.writeFileSync(path.join(root, "tool/app_targets.json"), JSON.stringify({
    targets: [
      {id: "consumer-prod", role: "consumer", environment: "prod", release: {appStoreConnectAppId: "app-consumer"}},
      {id: "host-prod", role: "host", environment: "prod", release: {appStoreConnectAppId: "app-host"}},
    ],
  }));
  for (const [role, appId, buildNumber] of [
    ["consumer", "app-consumer", "202607110000002601"],
    ["host", "app-host", "202607110000002601"],
  ]) {
    fs.writeFileSync(path.join(directory, `${role}-testflight.json`), JSON.stringify({
      $schema: "catch.app-store-build-processing/v1",
      appId,
      buildNumber,
      processingState: "VALID",
      githubRunId: "12345",
    }));
  }
  return {root, directory};
}

test("accepts both processing receipts from the declared GitHub run", () => {
  const {root, directory} = fixture();
  try {
    const result = verifyIosProcessingReceipts({
      root,
      directory,
      githubRunId: "12345",
      builds: {consumer: "202607110000002601", host: "202607110000002601"},
    });
    assert.equal(result.receipts.host.appId, "app-host");
  } finally {
    fs.rmSync(root, {recursive: true, force: true});
  }
});

test("rejects a processed build not proven by the declared GitHub run", () => {
  const {root, directory} = fixture();
  try {
    const hostPath = path.join(directory, "host-testflight.json");
    const host = JSON.parse(fs.readFileSync(hostPath, "utf8"));
    host.githubRunId = "99999";
    fs.writeFileSync(hostPath, JSON.stringify(host));
    assert.throws(
      () => verifyIosProcessingReceipts({
        root,
        directory,
        githubRunId: "12345",
        builds: {consumer: "202607110000002601", host: "202607110000002601"},
      }),
      /GitHub run id/u,
    );
  } finally {
    fs.rmSync(root, {recursive: true, force: true});
  }
});
