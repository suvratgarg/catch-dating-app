#!/usr/bin/env node
import fs from "node:fs";
import path from "node:path";
import {fileURLToPath} from "node:url";

const toolDir = path.dirname(fileURLToPath(import.meta.url));
const repoRoot = path.resolve(toolDir, "..");
const contractRoot = path.join(repoRoot, "contracts");
const overlayPath = path.join(toolDir, "firestore_ts_overlay.json");
const firestoreFacadePath = path.join(
  repoRoot,
  "functions/src/shared/firestore.ts"
);

const overlay = readJson(overlayPath);
const schemaTitles = loadSchemaTitles(contractRoot);
const exceptions = overlay.schemaOwnedExceptions ?? {};
const errors = [];
const requiredExceptionKeys = new Set();

for (const [interfaceName, fields] of Object.entries(
  overlay.extraFields ?? {}
)) {
  for (const field of fields) {
    if (!field || typeof field !== "object") continue;
    if (isFieldOverride(interfaceName, field.name)) {
      requiredExceptionKeys.add(`extraFields.${interfaceName}.${field.name}`);
    }
  }
}

for (const [interfaceName, fields] of Object.entries(
  overlay.fieldOverrides ?? {}
)) {
  for (const fieldName of fields) {
    requiredExceptionKeys.add(`fieldOverrides.${interfaceName}.${fieldName}`);
  }
}

for (const extraInterface of overlay.extraInterfaces ?? []) {
  if (!extraInterface || typeof extraInterface !== "object") continue;
  const name = extraInterface.name;
  if (schemaTitles.has(name)) {
    requiredExceptionKeys.add(`extraInterfaces.${name}`);
  }
}

for (const key of requiredExceptionKeys) {
  const reason = exceptions[key];
  if (typeof reason !== "string" || reason.trim().length < 20) {
    errors.push(
      `firestore_ts_overlay.json schema-owned exception ${key} needs a ` +
        "specific reason."
    );
  }
}

for (const key of Object.keys(exceptions)) {
  if (!requiredExceptionKeys.has(key)) {
    errors.push(
      `firestore_ts_overlay.json schemaOwnedExceptions contains unused key ${key}`
    );
  }
}

const facade = fs.readFileSync(firestoreFacadePath, "utf8");
if (!facade.toLowerCase().includes("transitional")) {
  errors.push(
    "functions/src/shared/firestore.ts must describe itself as transitional " +
      "so new code does not treat it as canonical schema truth."
  );
}

if (errors.length > 0) {
  console.error("Schema/type boundary check failed:");
  for (const error of errors) console.error(`- ${error}`);
  process.exit(1);
}

console.log("Schema/type boundary check passed.");

function readJson(filePath) {
  return JSON.parse(fs.readFileSync(filePath, "utf8"));
}

function loadSchemaTitles(root) {
  const titles = new Set();
  for (const filePath of walk(root)) {
    if (!filePath.endsWith(".schema.json")) continue;
    const schema = readJson(filePath);
    if (typeof schema.title === "string" && schema.title.length > 0) {
      titles.add(schema.title);
    }
  }
  return titles;
}

function* walk(dir) {
  for (const entry of fs.readdirSync(dir, {withFileTypes: true})) {
    const childPath = path.join(dir, entry.name);
    if (entry.isDirectory()) yield* walk(childPath);
    else if (entry.isFile()) yield childPath;
  }
}

function isFieldOverride(interfaceName, fieldName) {
  const overrides = overlay.fieldOverrides?.[interfaceName] ?? [];
  return overrides.includes(fieldName);
}
