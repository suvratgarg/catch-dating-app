#!/usr/bin/env node
import fs from "node:fs";
import path from "node:path";
import {fileURLToPath} from "node:url";

const toolDir = path.dirname(fileURLToPath(import.meta.url));
const repoRoot = path.resolve(toolDir, "../..");
const storageSchemaDir = path.join(repoRoot, "contracts/storage");
const storageRulesPath = path.join(repoRoot, "storage.rules");

const errors = [];

if (!fs.existsSync(storageSchemaDir)) {
  console.error(`Storage contract dir missing: ${storageSchemaDir}`);
  process.exit(1);
}
if (!fs.existsSync(storageRulesPath)) {
  console.error(`storage.rules missing at ${storageRulesPath}`);
  process.exit(1);
}

const rules = fs.readFileSync(storageRulesPath, "utf8");

const matchPatternsInRules = new Set();
for (const m of rules.matchAll(/match\s+(\/[^\s]+)\s*\{/g)) {
  // Skip the global catch-all and the bucket scope wrapper.
  if (m[1].includes("{bucket}") || m[1] === "/{allPaths=**}") continue;
  matchPatternsInRules.add(`match ${m[1]}`);
}

const matchPatternsInSchemas = new Set();

for (const entry of fs.readdirSync(storageSchemaDir)) {
  if (!entry.endsWith(".schema.json")) continue;
  const filePath = path.join(storageSchemaDir, entry);
  const schema = JSON.parse(fs.readFileSync(filePath, "utf8"));
  const label = `contracts/storage/${entry}`;

  if (typeof schema["x-storage-rules-match"] !== "string") {
    errors.push(`${label}: missing x-storage-rules-match`);
    continue;
  }
  if (typeof schema["x-storage-read"] !== "string") {
    errors.push(`${label}: missing x-storage-read`);
  }
  if (typeof schema["x-storage-write"] !== "string") {
    errors.push(`${label}: missing x-storage-write`);
  }
  if (typeof schema["x-storage-rules-test-file"] !== "string") {
    errors.push(`${label}: missing x-storage-rules-test-file`);
  } else {
    const testPath = path.join(repoRoot, schema["x-storage-rules-test-file"]);
    if (!fs.existsSync(testPath)) {
      errors.push(
        `${label}: x-storage-rules-test-file points at missing file: ` +
        schema["x-storage-rules-test-file"]
      );
    }
  }

  const matchPattern = schema["x-storage-rules-match"];
  matchPatternsInSchemas.add(matchPattern);
  if (!rules.includes(matchPattern)) {
    errors.push(
      `${label}: storage.rules does not contain "${matchPattern}"`
    );
  }
}

for (const rulesMatch of matchPatternsInRules) {
  if (!matchPatternsInSchemas.has(rulesMatch)) {
    errors.push(
      `storage.rules has "${rulesMatch}" with no matching contracts/storage/*.schema.json`
    );
  }
}

if (errors.length > 0) {
  console.error("Storage contract check failed:");
  for (const e of errors) console.error(`- ${e}`);
  process.exit(1);
}

console.log("Storage contract check passed.");
