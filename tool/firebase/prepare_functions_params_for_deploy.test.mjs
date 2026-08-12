import assert from "node:assert/strict";
import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import test from "node:test";

import {prepareFunctionsParamsForDeploy} from
  "./prepare_functions_params_for_deploy.mjs";

function fixture() {
  const directory = fs.mkdtempSync(path.join(os.tmpdir(), "catch-params-"));
  fs.writeFileSync(path.join(directory, "package.json"), "{}\n");
  return directory;
}

test("disabled legacy Meta params remain visibly unconfigured", () => {
  const functionsDir = fixture();
  const result = prepareFunctionsParamsForDeploy({
    functionsDir,
    projectId: "catchdates-dev",
    environment: {},
  });
  assert.equal(result.enabled, false);
  assert.equal(path.basename(result.outputPath), ".env.catchdates-dev");
  assert.equal(fs.readFileSync(result.outputPath, "utf8"), [
    "META_WHATSAPP_APP_ID=\" \"",
    "META_WHATSAPP_EMBEDDED_SIGNUP_CONFIG_ID=\" \"",
    "META_WHATSAPP_GRAPH_VERSION=\"v23.0\"",
    "META_WHATSAPP_ENABLED=\"false\"",
    "",
  ].join("\n"));
  assert.equal(fs.statSync(result.outputPath).mode & 0o777, 0o600);
});

test("enabled provider requires and preserves real non-secret ids", () => {
  const functionsDir = fixture();
  const environment = {
    META_WHATSAPP_ENABLED: "true",
    META_WHATSAPP_APP_ID: "12345",
    META_WHATSAPP_EMBEDDED_SIGNUP_CONFIG_ID: "67890",
    META_WHATSAPP_GRAPH_VERSION: "v24.0",
  };
  const result = prepareFunctionsParamsForDeploy({
    functionsDir,
    projectId: "catchdates-prod",
    environment,
  });
  assert.equal(result.enabled, true);
  const contents = fs.readFileSync(result.outputPath, "utf8");
  assert.match(contents, /META_WHATSAPP_APP_ID="12345"/);
  assert.match(contents, /META_WHATSAPP_ENABLED="true"/);
});

test("provider enablement without real ids fails closed", () => {
  assert.throws(() => prepareFunctionsParamsForDeploy({
    functionsDir: fixture(),
    projectId: "catchdates-prod",
    environment: {META_WHATSAPP_ENABLED: "true"},
  }), /real Meta app and embedded-signup config ids are required/);
});

test("invalid project names and parameter shapes are rejected", () => {
  assert.throws(() => prepareFunctionsParamsForDeploy({
    functionsDir: fixture(),
    projectId: "../prod",
    environment: {},
  }), /invalid Firebase project id/);
  assert.throws(() => prepareFunctionsParamsForDeploy({
    functionsDir: fixture(),
    projectId: "catchdates-prod",
    environment: {META_WHATSAPP_GRAPH_VERSION: "latest"},
  }), /must look like v23.0/);
});

