#!/usr/bin/env node

import fs from "node:fs";
import path from "node:path";
import {fileURLToPath} from "node:url";

function assert(condition, message) {
  if (!condition) throw new Error(message);
}

function modeForField(field) {
  return field.mode ?? field.order ?? field.arrayConfig ?? field.vectorConfig;
}

export function indexSignature(index) {
  return JSON.stringify({
    collectionGroup: index.collectionGroup,
    queryScope: String(index.queryScope ?? "COLLECTION").toUpperCase(),
    fields: (index.fields ?? []).map((field) => ({
      fieldPath: field.fieldPath,
      mode: modeForField(field),
    })),
  });
}

export function isRedundantSingleFieldComposite(index) {
  const fields = index?.fields ?? [];
  const userFields = fields.filter((field) => field.fieldPath !== "__name__");
  return String(index?.queryScope ?? "COLLECTION").toUpperCase() === "COLLECTION" &&
    userFields.length === 1 &&
    fields.length <= 2 &&
    userFields.every((field) => field.vectorConfig == null);
}

function hasFieldOverride(document, index) {
  const userField = index.fields.find((field) => field.fieldPath !== "__name__");
  return (document.fieldOverrides ?? []).some((override) =>
    override.collectionGroup === index.collectionGroup &&
    override.fieldPath === userField?.fieldPath
  );
}

export function sanitizeFirestoreIndexesForDeploy({packaged, current}) {
  assert(Array.isArray(packaged?.indexes),
    "packaged Firestore index configuration must contain indexes");
  assert(Array.isArray(current?.indexes),
    "current Firestore index configuration must contain indexes");
  const currentSignatures = new Set(current.indexes.map(indexSignature));
  const removed = [];
  const indexes = [];
  for (const index of packaged.indexes) {
    const signature = indexSignature(index);
    if (isRedundantSingleFieldComposite(index) &&
        !hasFieldOverride(packaged, index) &&
        !hasFieldOverride(current, index) &&
        !currentSignatures.has(signature)) {
      removed.push(signature);
      continue;
    }
    indexes.push(index);
  }
  return {
    document: {...packaged, indexes},
    removed,
  };
}

function readJson(filePath) {
  return JSON.parse(fs.readFileSync(filePath, "utf8"));
}

function runCli() {
  const indexesOffset = process.argv.indexOf("--indexes");
  const currentOffset = process.argv.indexOf("--current-indexes");
  assert(indexesOffset >= 0 && process.argv[indexesOffset + 1],
    "--indexes is required");
  assert(currentOffset >= 0 && process.argv[currentOffset + 1],
    "--current-indexes is required");
  const indexesPath = path.resolve(process.argv[indexesOffset + 1]);
  const currentPath = path.resolve(process.argv[currentOffset + 1]);
  const result = sanitizeFirestoreIndexesForDeploy({
    packaged: readJson(indexesPath),
    current: readJson(currentPath),
  });
  fs.writeFileSync(indexesPath, `${JSON.stringify(result.document, null, 2)}\n`);
  console.log(JSON.stringify({
    ok: true,
    removedCount: result.removed.length,
    removed: result.removed,
  }));
}

if (process.argv[1] === fileURLToPath(import.meta.url)) runCli();
