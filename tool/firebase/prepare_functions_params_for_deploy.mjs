#!/usr/bin/env node

import fs from "node:fs";
import path from "node:path";
import {fileURLToPath} from "node:url";

function assert(condition, message) {
  if (!condition) throw new Error(message);
}

// Every non-secret param declared in Functions source must appear here:
// firebase-tools ignores `default:` values in non-interactive mode, so an
// unmaterialized param fails the whole Delivery lane. The colocated coverage
// scanner fails closed when source declarations drift from this list.
export const materializedNonSecretParams = [
  "ALGOLIA_APPLICATION_ID",
  "RAZORPAY_PUBLIC_KEY_ID",
  "FORM_RAZORPAY_PARTNER_CONFIG_VERSION",
  "META_WHATSAPP_APP_ID",
  "META_WHATSAPP_EMBEDDED_SIGNUP_CONFIG_ID",
  "META_WHATSAPP_GRAPH_VERSION",
  "META_WHATSAPP_ENABLED",
  "EVENT_ASSISTANCE_RCS_ENABLED",
  "EVENT_ASSISTANCE_RCS_WEBHOOK_ENABLED",
  "EVENT_ASSISTANCE_SMS_REPORTS_ENABLED",
  "FLIGHT_WEBHOOK_BASE_URL",
];

function option(name) {
  const offset = process.argv.indexOf(name);
  assert(offset >= 0 && process.argv[offset + 1], `${name} is required`);
  return process.argv[offset + 1];
}

function normalizedBooleanParam(environment, name) {
  const value = environment[name]?.trim().toLowerCase() || "false";
  assert(value === "true" || value === "false",
    `${name} must be true or false`);
  return value;
}

function normalizedProviderParams(environment = process.env, projectId) {
  const algoliaApplicationId = environment.ALGOLIA_APPLICATION_ID?.trim() ?? "";
  const razorpayPublicKeyId = environment.RAZORPAY_PUBLIC_KEY_ID?.trim() ?? "";
  assert(/^[A-Za-z0-9]{10}$/.test(algoliaApplicationId),
    "ALGOLIA_APPLICATION_ID must be a 10-character application identifier");
  assert(/^rzp_(test|live)_[A-Za-z0-9]+$/.test(razorpayPublicKeyId),
    "RAZORPAY_PUBLIC_KEY_ID must be a Razorpay test or live public key id");
  const formPartnerVersion = environment.FORM_RAZORPAY_PARTNER_CONFIG_VERSION
    ?.trim() || "";
  const secretPrefix = `projects/${projectId}/secrets/`;
  assert(!formPartnerVersion || (formPartnerVersion.startsWith(secretPrefix) &&
    /^[A-Za-z0-9_-]{1,255}\/versions\/[1-9][0-9]*$/.test(
      formPartnerVersion.slice(secretPrefix.length))),
  "FORM_RAZORPAY_PARTNER_CONFIG_VERSION must pin a secret in this project");
  const enabled = normalizedBooleanParam(environment, "META_WHATSAPP_ENABLED");

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

  const eventAssistance = {
    EVENT_ASSISTANCE_RCS_ENABLED: normalizedBooleanParam(
      environment, "EVENT_ASSISTANCE_RCS_ENABLED"),
    EVENT_ASSISTANCE_RCS_WEBHOOK_ENABLED: normalizedBooleanParam(
      environment, "EVENT_ASSISTANCE_RCS_WEBHOOK_ENABLED"),
    EVENT_ASSISTANCE_SMS_REPORTS_ENABLED: normalizedBooleanParam(
      environment, "EVENT_ASSISTANCE_SMS_REPORTS_ENABLED"),
  };

  const flightWebhookBaseUrl =
    environment.FLIGHT_WEBHOOK_BASE_URL?.trim() ?? "";
  assert(!flightWebhookBaseUrl || /^https:\/\/[^\s/?#]+/.test(
    flightWebhookBaseUrl),
  "FLIGHT_WEBHOOK_BASE_URL must be an https URL when configured");

  const params = {
    // Distinct names coexist with the SecretParams in immutable older packages.
    ALGOLIA_APPLICATION_ID: algoliaApplicationId,
    RAZORPAY_PUBLIC_KEY_ID: razorpayPublicKeyId,
    FORM_RAZORPAY_PARTNER_CONFIG_VERSION: formPartnerVersion || " ",
    // Quoted whitespace satisfies legacy Firebase parameter discovery while
    // remaining unconfigured under the source-owned trim checks.
    META_WHATSAPP_APP_ID: appId || " ",
    META_WHATSAPP_EMBEDDED_SIGNUP_CONFIG_ID: configId || " ",
    META_WHATSAPP_GRAPH_VERSION: graphVersion,
    META_WHATSAPP_ENABLED: enabled,
    ...eventAssistance,
    // Empty lets the function derive the URL from GCLOUD_PROJECT.
    FLIGHT_WEBHOOK_BASE_URL: flightWebhookBaseUrl || " ",
  };
  assert(
    Object.keys(params).join(",") === materializedNonSecretParams.join(","),
    "materialized params drifted from materializedNonSecretParams");
  return params;
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
  const params = normalizedProviderParams(environment, projectId);
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
