#!/usr/bin/env node
import fs from "node:fs";
import path from "node:path";
import {fileURLToPath} from "node:url";

const toolDir = path.dirname(fileURLToPath(import.meta.url));
const repoRoot = path.resolve(toolDir, "../..");
const overlayPath = path.join(toolDir, "firestore_ts_overlay.json");
const legacyFirestoreFacadePath = path.join(
  repoRoot,
  "functions/src/shared/firestore.ts"
);
const firestoreAdminTypesPath = path.join(
  repoRoot,
  "functions/src/shared/generated/firestoreAdminTypes.ts"
);

const errors = [];

if (fs.existsSync(overlayPath)) {
  errors.push(
    "tool/contracts/firestore_ts_overlay.json should not exist; Admin SDK " +
      "types now come from generate_schema_contracts.mjs."
  );
}

if (fs.existsSync(legacyFirestoreFacadePath)) {
  errors.push(
    "functions/src/shared/firestore.ts should not exist; import " +
      "schema-derived Admin SDK types from " +
      "functions/src/shared/generated/firestoreAdminTypes.ts."
  );
}

if (!fs.existsSync(firestoreAdminTypesPath)) {
  errors.push(
    "functions/src/shared/generated/firestoreAdminTypes.ts is missing."
  );
} else {
  const source = fs.readFileSync(firestoreAdminTypesPath, "utf8");
  const sourceLower = source.toLowerCase();
  if (
    !sourceLower.includes("schema-derived admin sdk firestore document types") ||
    !source.includes("FirebaseFirestore.Timestamp")
  ) {
    errors.push(
      "firestoreAdminTypes.ts must describe itself as the schema-derived " +
        "Admin SDK Timestamp projection."
    );
  }
}

if (hasLegacyFirestoreImports()) {
  errors.push(
    "Functions code still imports ../shared/firestore; use " +
      "../shared/generated/firestoreAdminTypes instead."
  );
}

if (errors.length > 0) {
  console.error("Schema/type boundary check failed:");
  for (const error of errors) console.error(`- ${error}`);
  process.exit(1);
}

console.log("Schema/type boundary check passed.");

function hasLegacyFirestoreImports() {
  const srcRoot = path.join(repoRoot, "functions/src");
  if (!fs.existsSync(srcRoot)) return false;
  for (const filePath of walk(srcRoot)) {
    if (!filePath.endsWith(".ts")) continue;
    const relativePath = path.relative(repoRoot, filePath);
    if (relativePath === "functions/src/shared/generated/firestoreAdminTypes.ts") {
      continue;
    }
    const source = fs.readFileSync(filePath, "utf8");
    if (source.includes("../shared/firestore")) return true;
  }
  return false;
}

function* walk(dir) {
  for (const entry of fs.readdirSync(dir, {withFileTypes: true})) {
    const childPath = path.join(dir, entry.name);
    if (entry.isDirectory()) yield* walk(childPath);
    else if (entry.isFile()) yield childPath;
  }
}
