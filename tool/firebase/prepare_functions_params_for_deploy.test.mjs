import assert from "node:assert/strict";
import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import test from "node:test";

import {prepareFunctionsParamsForDeploy} from
  "./prepare_functions_params_for_deploy.mjs";

const publicIds = {
  ALGOLIA_APPLICATION_ID: "CATCHDEV01",
  RAZORPAY_PUBLIC_KEY_ID: "rzp_test_example123",
};

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
    environment: publicIds,
  });
  assert.equal(result.enabled, false);
  assert.equal(path.basename(result.outputPath), ".env.catchdates-dev");
  assert.equal(fs.readFileSync(result.outputPath, "utf8"), [
    'ALGOLIA_APPLICATION_ID="CATCHDEV01"',
    'RAZORPAY_PUBLIC_KEY_ID="rzp_test_example123"',
    "META_WHATSAPP_APP_ID=\" \"",
    "META_WHATSAPP_EMBEDDED_SIGNUP_CONFIG_ID=\" \"",
    "META_WHATSAPP_GRAPH_VERSION=\"v23.0\"",
    "META_WHATSAPP_ENABLED=\"false\"",
    "",
  ].join("\n"));
  assert.equal(fs.statSync(result.outputPath).mode & 0o777, 0o600);
});

test("empty GitHub repository variables default Meta to disabled", () => {
  const functionsDir = fixture();
  const result = prepareFunctionsParamsForDeploy({
    functionsDir,
    projectId: "catchdates-staging",
    environment: {
      ...publicIds,
      META_WHATSAPP_ENABLED: "",
      META_WHATSAPP_APP_ID: "",
      META_WHATSAPP_EMBEDDED_SIGNUP_CONFIG_ID: "",
      META_WHATSAPP_GRAPH_VERSION: "",
    },
  });
  assert.equal(result.enabled, false);
  assert.equal(fs.readFileSync(result.outputPath, "utf8"), [
    'ALGOLIA_APPLICATION_ID="CATCHDEV01"',
    'RAZORPAY_PUBLIC_KEY_ID="rzp_test_example123"',
    "META_WHATSAPP_APP_ID=\" \"",
    "META_WHATSAPP_EMBEDDED_SIGNUP_CONFIG_ID=\" \"",
    "META_WHATSAPP_GRAPH_VERSION=\"v23.0\"",
    "META_WHATSAPP_ENABLED=\"false\"",
    "",
  ].join("\n"));
});

test("enabled provider requires and preserves real non-secret ids", () => {
  const functionsDir = fixture();
  const environment = {
    ...publicIds,
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
    environment: {...publicIds, META_WHATSAPP_ENABLED: "true"},
  }), /real Meta app and embedded-signup config ids are required/);
});

test("invalid project names and parameter shapes are rejected", () => {
  assert.throws(() => prepareFunctionsParamsForDeploy({
    functionsDir: fixture(),
    projectId: "../prod",
    environment: publicIds,
  }), /invalid Firebase project id/);
  assert.throws(() => prepareFunctionsParamsForDeploy({
    functionsDir: fixture(),
    projectId: "catchdates-prod",
    environment: {...publicIds, META_WHATSAPP_GRAPH_VERSION: "latest"},
  }), /must look like v23.0/);
});

test("plain provider ids never collide with legacy secret parameter names", () => {
  const result = prepareFunctionsParamsForDeploy({
    functionsDir: fixture(),
    projectId: "catchdates-dev",
    environment: {
      ...publicIds,
      ALGOLIA_APP_ID: "legacy-id",
      RAZORPAY_KEY_ID: "legacy-key-id",
      ALGOLIA_SEARCH_API_KEY: "must-not-be-emitted",
      RAZORPAY_KEY_SECRET: "must-not-be-emitted",
    },
  });
  const contents = fs.readFileSync(result.outputPath, "utf8");
  assert.match(contents, /ALGOLIA_APPLICATION_ID="CATCHDEV01"/);
  assert.match(contents, /RAZORPAY_PUBLIC_KEY_ID="rzp_test_example123"/);
  assert.doesNotMatch(contents,
    /ALGOLIA_APP_ID=|RAZORPAY_KEY_ID=|API_KEY=|KEY_SECRET=|must-not-be-emitted/);
});

test("missing or unsafe public provider ids fail before writing deployment config", () => {
  for (const environment of [
    {},
    {...publicIds, ALGOLIA_APPLICATION_ID: ""},
    {...publicIds, ALGOLIA_APPLICATION_ID: "INVALID\nENV"},
    {...publicIds, RAZORPAY_PUBLIC_KEY_ID: ""},
    {...publicIds, RAZORPAY_PUBLIC_KEY_ID: "rzp_test_key\nINJECTED=value"},
  ]) {
    const functionsDir = fixture();
    assert.throws(() => prepareFunctionsParamsForDeploy({
      functionsDir,
      projectId: "catchdates-dev",
      environment,
    }), /ALGOLIA_APPLICATION_ID|RAZORPAY_PUBLIC_KEY_ID/);
    assert.equal(fs.existsSync(path.join(functionsDir, ".env.catchdates-dev")),
      false);
  }
});
