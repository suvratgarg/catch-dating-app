#!/usr/bin/env node
import {
  applyFirestoreEmulatorHost,
  assertProdWriteAllowed,
  readFirebaseProjectAliases,
  resolveFirebaseProjectId,
} from "../lib/firebase_project.mjs";
import {createFunctionsRequire} from "../lib/repo_paths.mjs";
import {parseCommonArgs} from "../lib/cli_args.mjs";

const requireFromFunctions = createFunctionsRequire();
const admin = requireFromFunctions("firebase-admin");

const cities = [
  ["mumbai", "Mumbai", 19.076, 72.8777, "IN", "INR", "+91", "Asia/Kolkata"],
  ["delhi", "Delhi", 28.7041, 77.1025, "IN", "INR", "+91", "Asia/Kolkata"],
  ["bangalore", "Bangalore", 12.9716, 77.5946, "IN", "INR", "+91", "Asia/Kolkata"],
  ["hyderabad", "Hyderabad", 17.385, 78.4867, "IN", "INR", "+91", "Asia/Kolkata"],
  ["chennai", "Chennai", 13.0827, 80.2707, "IN", "INR", "+91", "Asia/Kolkata"],
  ["kolkata", "Kolkata", 22.5726, 88.3639, "IN", "INR", "+91", "Asia/Kolkata"],
  ["pune", "Pune", 18.5204, 73.8567, "IN", "INR", "+91", "Asia/Kolkata"],
  ["ahmedabad", "Ahmedabad", 23.0225, 72.5714, "IN", "INR", "+91", "Asia/Kolkata"],
  ["indore", "Indore", 22.7196, 75.8577, "IN", "INR", "+91", "Asia/Kolkata"],
  ["kathmandu", "Kathmandu", 27.7172, 85.324, "NP", "NPR", "+977", "Asia/Kathmandu"],
  ["pokhara", "Pokhara", 28.2096, 83.9856, "NP", "NPR", "+977", "Asia/Kathmandu"],
  ["sydney", "Sydney", -33.8688, 151.2093, "AU", "AUD", "+61", "Australia/Sydney"],
  ["melbourne", "Melbourne", -37.8136, 144.9631, "AU", "AUD", "+61", "Australia/Melbourne"],
  ["brisbane", "Brisbane", -27.4698, 153.0251, "AU", "AUD", "+61", "Australia/Brisbane"],
  ["new-york", "New York", 40.7128, -74.006, "US", "USD", "+1", "America/New_York"],
  ["san-francisco", "San Francisco", 37.7749, -122.4194, "US", "USD", "+1", "America/Los_Angeles"],
  ["los-angeles", "Los Angeles", 34.0522, -118.2437, "US", "USD", "+1", "America/Los_Angeles"],
].map(([
  name,
  label,
  latitude,
  longitude,
  countryIsoCode,
  currencyCode,
  dialCode,
  timeZone,
]) => ({
  name,
  label,
  latitude,
  longitude,
  countryIsoCode,
  currencyCode,
  dialCode,
  timeZone,
}));

const citiesDoc = {
  cityNames: cities.map((city) => city.name),
  cities,
};

const args = parseArgs(process.argv.slice(2));
if (args.help) {
  printHelp();
  process.exit(0);
}

const targets = resolveTargets(args);
if (args.json) {
  console.log(JSON.stringify({
    apply: args.apply,
    targets,
    cityCount: cities.length,
  }, null, 2));
} else {
  console.log("Config/cities plan");
  console.log(`Mode: ${args.apply ? "apply" : "dry-run"}`);
  console.log(`Targets: ${targets.map((target) => target.env).join(", ")}`);
  console.log(`Cities: ${cities.length}`);
}

if (!args.apply) {
  console.log("\nDry run only. Re-run with --apply to write config/cities.");
  process.exit(0);
}

applyFirestoreEmulatorHost(args.emulatorHost);
for (const target of targets) {
  assertProdWriteAllowed({
    env: target.env,
    projectId: target.projectId,
    apply: args.apply,
    allowProd: args.allowProd,
    action: "write config/cities to",
  });
  await writeConfigDoc(target);
}
console.log("\nConfig/cities writes applied.");

function parseArgs(argv) {
  const parsed = parseCommonArgs(argv, {booleanFlags: ["--all"]});
  parsed.all = parsed.all ?? false;
  return parsed;
}

function resolveTargets(parsed) {
  if (parsed.project) {
    return [{
      env: parsed.env ?? "custom",
      projectId: parsed.project,
    }];
  }

  if (parsed.all) {
    const aliases = readFirebaseProjectAliases();
    return ["dev", "staging", "prod"].map((env) => ({
      env,
      projectId: aliases[env],
    })).filter((target) => target.projectId);
  }

  const env = parsed.env ?? "dev";
  return [{
    env,
    projectId: resolveFirebaseProjectId({env}),
  }];
}

async function writeConfigDoc({env, projectId}) {
  const app = admin.initializeApp({projectId}, `config-cities-${env}`);
  const db = app.firestore();
  await db.collection("config").doc("cities").set(citiesDoc);
  console.log(`  OK  ${env}: ${projectId}`);
  await app.delete();
}

function printHelp() {
  console.log(`Usage: node tool/firebase/create_config_cities.mjs [options]

Writes config/cities for one Firebase environment. The tool is dry-run by
default; use --all intentionally for dev, staging, and prod.

Options:
  --apply                 Write the config doc. Default is dry-run.
  --allow-prod            Required when --apply targets prod.
  --all                   Target dev, staging, and prod.
  --json                  Print compact summary as JSON.
  --env <dev|staging|prod> Resolve project id from .firebaserc. Defaults to dev.
  --project <id>          Firebase project id override.
  --emulator              Use Firestore emulator at 127.0.0.1:8080.
  --emulator-host <host>  Use a custom Firestore emulator host.
  -h, --help              Show this help.
`);
}
