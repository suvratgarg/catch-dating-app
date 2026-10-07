"use strict";
const assert = require("node:assert/strict");
const {test} = require("node:test");
const fs = require("node:fs");
const os = require("node:os");
const path = require("node:path");
const {spawnSync} = require("node:child_process");
const root = path.resolve(__dirname, "..");
const command = path.join(root, "scripts/operations/setup-catch-whatsapp-reply.cjs");
function fixture() {
  return {schemaVersion: 1, planId: "synthetic-review", scope: {
    projectId: "demo-catch-setup", actorUid: "operator",
    actorEmailSha256: "a".repeat(64), recipientUid: "recipient",
    endpointHash: "b".repeat(64), appId: "10001", wabaId: "10002",
    phoneNumberId: "10003", credentialVersionSha256: "c".repeat(64)},
  sourceSha: "d".repeat(40), createdAtMillis: 1800000000000,
  expiresAtMillis: 1800000600000, actorCreationTimeMillis: 1001,
  recipientCreationTimeMillis: 1002, actorTokensValidAfterMillis: 0,
  recipientTokensValidAfterMillis: 0, googleSubjectSha256: "e".repeat(64),
  beforeClaimsSha256: "f".repeat(64), desiredClaimsSha256: "1".repeat(64),
  recipientClaimsSha256: "2".repeat(64), grantNonce: "3".repeat(64),
  createReviewRef: "review-create", revokeReviewRef: "review-revoke",
  expectedActorRevision: 0, expectedRecipientRevision: 0};
}
test("offline CLI inspects without ADC, networking or exposing operator scope", () => {
  const directory = fs.mkdtempSync(path.join(os.tmpdir(), "catch-offline-plan-"));
  try {
    const file = path.join(directory, "plan.json");
    const adc = path.join(directory, "forbidden-adc.json");
    const sentinel = path.join(directory, "sentinel.cjs");
    fs.writeFileSync(file, JSON.stringify(fixture()));
    fs.writeFileSync(adc, "synthetic-credential-marker");
    fs.writeFileSync(sentinel, `
      const fs = require('node:fs');
      const read = fs.readFileSync;
      fs.readFileSync = function(file, ...args) {
        if (String(file) === process.env.GOOGLE_APPLICATION_CREDENTIALS)
          throw new Error('ADC read forbidden');
        return read.call(this, file, ...args);
      };
      global.fetch = () => {throw new Error('network forbidden');};
      for (const name of ['node:http', 'node:https', 'node:net']) {
        const module = require(name);
        for (const key of ['request', 'get', 'connect', 'createConnection']) {
          if (typeof module[key] === 'function')
            module[key] = () => {throw new Error('network forbidden');};
        }
      }
    `);
    const result = spawnSync(process.execPath, ["--require", sentinel, command,
      "inspect-plan", "--plan-file", file], {encoding: "utf8", cwd: root,
    env: {...process.env, GOOGLE_APPLICATION_CREDENTIALS: adc}});
    assert.equal(result.status, 0, result.stderr);
    const receipt = JSON.parse(result.stdout);
    assert.equal(receipt.liveApplyAvailable, false);
    assert.match(receipt.planSha256, /^[a-f0-9]{64}$/u);
    for (const privateValue of ["synthetic-credential-marker", "operator",
      "recipient", "10001", "10002", "10003"]) {
      assert.ok(!result.stdout.includes('"' + privateValue + '"'));
    }
  } finally {fs.rmSync(directory, {recursive: true, force: true});}
});
test("live commands and caller facts fail without echoing private input", () => {
  for (const argv of [[], ["apply", "synthetic-private-token"],
    ["inspect-plan", "--plan-file", "/missing", "synthetic-private-token"]]) {
    const result = spawnSync(process.execPath, [command, ...argv],
      {encoding: "utf8", cwd: root});
    assert.equal(result.status, 1);
    assert.ok(!result.stderr.includes("synthetic-private-token"));
  }
  const directory = fs.mkdtempSync(path.join(os.tmpdir(), "catch-plan-invalid-"));
  try {
    const file = path.join(directory, "plan.json");
    fs.writeFileSync(file, JSON.stringify({...fixture(), roles: ["adminOwner"]}));
    const result = spawnSync(process.execPath, [command, "inspect-plan",
      "--plan-file", file], {encoding: "utf8"});
    assert.equal(result.status, 1);
    assert.ok(!result.stderr.includes("adminOwner"));
  } finally {fs.rmSync(directory, {recursive: true, force: true});}
});
