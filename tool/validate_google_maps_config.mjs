#!/usr/bin/env node
import fs from "node:fs";
import path from "node:path";
import {fileURLToPath} from "node:url";

const toolDir = path.dirname(fileURLToPath(import.meta.url));
const repoRoot = path.resolve(toolDir, "..");

const args = parseArgs(process.argv.slice(2));
const envs = args.env ? [args.env] : ["dev", "staging", "prod"];
const platforms = args.platform === "all" ? ["ios", "android"] : [args.platform];
const errors = [];

for (const platform of platforms) {
  if (platform === "ios") validateIos(envs);
  else if (platform === "android") validateAndroid(envs);
  else errors.push(`Unsupported platform: ${platform}`);
}

if (errors.length > 0) {
  console.error("Google Maps config validation failed:");
  for (const error of errors) console.error(`- ${error}`);
  process.exit(1);
}

console.log(
  `Google Maps config validation passed for ${platforms.join(", ")} ` +
    `(${envs.join(", ")}).`
);

function parseArgs(argv) {
  const parsed = {env: null, platform: "all"};
  for (let i = 0; i < argv.length; i += 1) {
    const arg = argv[i];
    if (arg === "--env") parsed.env = requireValue(argv, ++i, arg);
    else if (arg === "--platform") {
      parsed.platform = requireValue(argv, ++i, arg);
    } else if (arg === "--help" || arg === "-h") {
      printHelp();
      process.exit(0);
    } else {
      throw new Error(`Unknown argument: ${arg}`);
    }
  }
  if (parsed.env && !["dev", "staging", "prod"].includes(parsed.env)) {
    throw new Error(`Unsupported env: ${parsed.env}`);
  }
  if (!["ios", "android", "all"].includes(parsed.platform)) {
    throw new Error(`Unsupported platform: ${parsed.platform}`);
  }
  return parsed;
}

function requireValue(argv, index, flag) {
  const value = argv[index];
  if (!value || value.startsWith("--")) {
    throw new Error(`${flag} requires a value.`);
  }
  return value;
}

function validateIos(targetEnvs) {
  const filePath = path.join(repoRoot, "ios/Flutter/GoogleMapsKeys.xcconfig");
  const values = readKeyValueFile(filePath, "iOS Google Maps key file");
  for (const env of targetEnvs) {
    const key = `GOOGLE_MAPS_IOS_API_KEY_${env.toUpperCase()}`;
    validateApiKey({
      label: `ios ${key}`,
      value: values.get(key),
      source: "ios/Flutter/GoogleMapsKeys.xcconfig",
    });
  }
}

function validateAndroid(targetEnvs) {
  const filePath = path.join(repoRoot, "android/local.properties");
  const values = readKeyValueFile(filePath, "Android local.properties");
  for (const env of targetEnvs) {
    const specificKey = `GOOGLE_MAPS_ANDROID_API_KEY_${env.toUpperCase()}`;
    const fallbackKey = "GOOGLE_MAPS_ANDROID_API_KEY";
    const value = values.get(specificKey) ?? values.get(fallbackKey);
    validateApiKey({
      label: `android ${specificKey} or ${fallbackKey}`,
      value,
      source: "android/local.properties",
    });
  }
}

function readKeyValueFile(filePath, label) {
  if (!fs.existsSync(filePath)) {
    errors.push(`Missing ${label}: ${path.relative(repoRoot, filePath)}`);
    return new Map();
  }
  const values = new Map();
  for (const line of fs.readFileSync(filePath, "utf8").split(/\r?\n/)) {
    const trimmed = line.trim();
    if (!trimmed || trimmed.startsWith("#") || trimmed.startsWith("//")) {
      continue;
    }
    const equals = trimmed.indexOf("=");
    if (equals === -1) continue;
    values.set(trimmed.slice(0, equals).trim(), trimmed.slice(equals + 1).trim());
  }
  return values;
}

function validateApiKey({label, value, source}) {
  if (!value) {
    errors.push(`Missing ${label} in ${source}.`);
    return;
  }
  if (value.includes("keyString:")) {
    errors.push(`${label} in ${source} includes the invalid keyString prefix.`);
  }
  if (value.includes("$(") || value.startsWith("replace-with")) {
    errors.push(`${label} in ${source} is still a placeholder.`);
  }
  if (!/^AIza[0-9A-Za-z_-]{20,}$/.test(value)) {
    errors.push(`${label} in ${source} does not look like a raw Google API key.`);
  }
}

function printHelp() {
  console.log(`Usage: node tool/validate_google_maps_config.mjs [options]

Options:
  --env <dev|staging|prod>       Validate one environment. Defaults to all.
  --platform <ios|android|all>   Validate one platform. Defaults to all.

The validator never prints API key values. It checks that local ignored config
files contain raw Google Maps API keys, not placeholders or keyString wrappers.`);
}
