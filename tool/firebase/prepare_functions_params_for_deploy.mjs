#!/usr/bin/env node

import fs from "node:fs";
import path from "node:path";
import {fileURLToPath} from "node:url";

function assert(condition, message) {
  if (!condition) throw new Error(message);
}

function option(name) {
  const offset = process.argv.indexOf(name);
  assert(offset >= 0 && process.argv[offset + 1], `${name} is required`);
  return process.argv[offset + 1];
}

function normalizedProviderParams(environment = process.env) {
  const algoliaApplicationId = environment.ALGOLIA_APPLICATION_ID?.trim() ?? "";
  const razorpayPublicKeyId = environment.RAZORPAY_PUBLIC_KEY_ID?.trim() ?? "";
  assert(/^[A-Za-z0-9]{10}$/.test(algoliaApplicationId),
    "ALGOLIA_APPLICATION_ID must be a 10-character application identifier");
  assert(/^rzp_(test|live)_[A-Za-z0-9]+$/.test(razorpayPublicKeyId),
    "RAZORPAY_PUBLIC_KEY_ID must be a Razorpay test or live public key id");
  const enabled = environment.META_WHATSAPP_ENABLED?.trim().toLowerCase() ||
    "false";
  assert(enabled === "true" || enabled === "false",
    "META_WHATSAPP_ENABLED must be true or false");

  const appId = environment.META_WHATSAPP_APP_ID?.trim() ?? "";
  const configId = environment.META_WHATSAPP_EMBEDDED_SIGNUP_CONFIG_ID
    ?.trim() ?? "";
  const graphVersion = environment.META_WHATSAPP_GRAPH_VERSION?.trim() ||
    "v23.0";
  assert(/^v[1-9][0-9]*\.[0-9]+$/.test(graphVersion),
    "META_WHATSAPP_GRAPH_VERSION must look like v23.0");
  assert(!appId || /^[A-Za-z0-9_-]+$/.test(appId),
    "META_WHATSAPP_APP_ID contains unsupported characters");
  assert(!configId || /^[A-Za-z0-9_-]+$/.test(configId),
    "META_WHATSAPP_EMBEDDED_SIGNUP_CONFIG_ID contains unsupported characters");
  if (enabled === "true") {
    assert(appId && configId,
      "real Meta app and embedded-signup config ids are required when enabled");
  }

  return {
    // Distinct names coexist with the SecretParams in immutable older packages.
    ALGOLIA_APPLICATION_ID: algoliaApplicationId,
    RAZORPAY_PUBLIC_KEY_ID: razorpayPublicKeyId,
    // Quoted whitespace satisfies legacy Firebase parameter discovery while
    // remaining unconfigured under the source-owned trim checks.
    META_WHATSAPP_APP_ID: appId || " ",
    META_WHATSAPP_EMBEDDED_SIGNUP_CONFIG_ID: configId || " ",
    META_WHATSAPP_GRAPH_VERSION: graphVersion,
    META_WHATSAPP_ENABLED: enabled,
  };
}

export function prepareFunctionsParamsForDeploy({
  functionsDir,
  projectId,
  environment = process.env,
}) {
  assert(/^[a-z][a-z0-9-]{4,28}[a-z0-9]$/.test(projectId),
    "invalid Firebase project id");
  const resolvedFunctionsDir = fs.realpathSync(functionsDir);
  assert(fs.statSync(resolvedFunctionsDir).isDirectory(),
    "Functions deploy path must be a directory");
  assert(fs.existsSync(path.join(resolvedFunctionsDir, "package.json")),
    "Functions deploy path must contain package.json");
  const params = normalizedProviderParams(environment);
  const outputPath = path.join(resolvedFunctionsDir, `.env.${projectId}`);
  const contents = Object.entries(params)
    .map(([key, value]) => `${key}=${JSON.stringify(value)}`)
    .join("\n") + "\n";
  fs.writeFileSync(outputPath, contents, {encoding: "utf8", mode: 0o600});
  fs.chmodSync(outputPath, 0o600);
  return {outputPath, enabled: params.META_WHATSAPP_ENABLED === "true"};
}

function runCli() {
  const result = prepareFunctionsParamsForDeploy({
    functionsDir: path.resolve(option("--functions-dir")),
    projectId: option("--project"),
  });
  console.log(JSON.stringify({
    ok: true,
    path: result.outputPath,
    metaWhatsappEnabled: result.enabled,
  }));
}

if (process.argv[1] === fileURLToPath(import.meta.url)) runCli();
