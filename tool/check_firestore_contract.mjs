#!/usr/bin/env node
import fs from "node:fs";
import path from "node:path";
import {fileURLToPath} from "node:url";

const toolDir = path.dirname(fileURLToPath(import.meta.url));
const repoRoot = path.resolve(toolDir, "..");

const contractPath = path.join(toolDir, "firestore_contract.json");
const rulesPath = path.join(repoRoot, "firestore.rules");
const generatedTypesPath = path.join(
  repoRoot,
  "functions/src/shared/firestore.ts"
);
const functionsIndexPath = path.join(repoRoot, "functions/src/index.ts");
const contractRoot = path.join(repoRoot, "contracts");

const contract = readJson(contractPath);
const rules = readText(rulesPath);
const generatedTypes = readText(generatedTypesPath);
const functionsIndex = readText(functionsIndexPath);
const schemaByCollectionId = loadFirestoreSchemas();

const errors = [];

assert(contract.schemaVersion === 2, "schemaVersion must be 2");
assert(Array.isArray(contract.collections), "collections must be an array");

const seenIds = new Set();
const seenPaths = new Set();

for (const collection of contract.collections ?? []) {
  const label = collection.id ?? collection.path ?? "<unknown>";

  requireString(collection.id, `${label}.id`);
  requireString(collection.path, `${label}.path`);
  requireString(collection.rulesMatch, `${label}.rulesMatch`);
  requireString(collection.owner, `${label}.owner`);
  requireString(collection.read, `${label}.read`);
  requireString(collection.write, `${label}.write`);

  assertUnique(seenIds, collection.id, `collection id ${collection.id}`);
  assertUnique(seenPaths, collection.path, `collection path ${collection.path}`);

  if (!rules.includes(`match ${collection.rulesMatch}`)) {
    errors.push(`${label}: Firestore rules are missing match ${collection.rulesMatch}`);
  }

  if (collection.dartModel) {
    requireExistingRepoPath(collection.dartModel, `${label}.dartModel`);
  }

  if (collection.rulesTestFile) {
    requireExistingRepoPath(collection.rulesTestFile, `${label}.rulesTestFile`);
  }

  validateFieldGroups(collection, label);
  validateTypeContract(collection, label);
  validateSchemaFieldProjection(collection, label);
  validateRulesFieldAllowList(collection, label);
  validateExportedFunctions(collection, label);
  validateOperations(collection, label);

  for (const embeddedType of collection.embeddedTypes ?? []) {
    validateTypeContract(embeddedType, `${label}.${embeddedType.typescriptInterface}`);
  }
}

if (errors.length > 0) {
  console.error("Firestore contract check failed:");
  for (const error of errors) {
    console.error(`- ${error}`);
  }
  process.exit(1);
}

console.log("Firestore contract check passed.");

function readJson(filePath) {
  return JSON.parse(readText(filePath));
}

function readText(filePath) {
  return fs.readFileSync(filePath, "utf8");
}

function loadFirestoreSchemas() {
  const schemas = new Map();
  const firestoreSchemaDir = path.join(contractRoot, "firestore");
  for (const entry of fs.readdirSync(firestoreSchemaDir, {withFileTypes: true})) {
    if (!entry.isFile() || !entry.name.endsWith(".schema.json")) continue;
    const schema = readJson(path.join(firestoreSchemaDir, entry.name));
    const collectionId = schema["x-firestore-collection"];
    if (typeof collectionId === "string" && collectionId.length > 0) {
      schemas.set(collectionId, schema);
    }
  }
  return schemas;
}

function requireString(value, label) {
  assert(typeof value === "string" && value.length > 0, `${label} is required`);
}

function requireExistingRepoPath(relativePath, label) {
  const absolutePath = path.join(repoRoot, relativePath);
  if (!fs.existsSync(absolutePath)) {
    errors.push(`${label} points at missing file: ${relativePath}`);
  }
}

function assert(condition, message) {
  if (!condition) {
    errors.push(message);
  }
}

function assertUnique(seen, value, label) {
  if (seen.has(value)) {
    errors.push(`duplicate ${label}`);
    return;
  }
  seen.add(value);
}

function validateFieldGroups(collection, label) {
  const allFields = new Set(effectiveAllFields(collection));
  for (const groupName of [
    "allFields",
    "clientWritableFields",
    "clientRuntimeWritableFields",
    "callableOwnedFields",
    "triggerOwnedFields",
    "serverOwnedFields",
    "internalDemoFields",
  ]) {
    const fields = collection[groupName] ?? [];
    if (!Array.isArray(fields)) {
      errors.push(`${label}.${groupName} must be an array when present`);
      continue;
    }
    const seen = new Set();
    for (const field of fields) {
      if (typeof field !== "string" || field.length === 0) {
        errors.push(`${label}.${groupName} contains a non-string field`);
        continue;
      }
      assertUnique(seen, field, `${label}.${groupName}.${field}`);
      if (
        groupName !== "allFields" &&
        groupName !== "internalDemoFields" &&
        allFields.size > 0 &&
        !allFields.has(field)
      ) {
        errors.push(`${label}.${groupName}.${field} is missing from allFields`);
      }
    }
  }

  assertNoOverlap(
    collection.clientWritableFields ?? [],
    [
      ...(collection.callableOwnedFields ?? []),
      ...(collection.triggerOwnedFields ?? []),
      ...(collection.serverOwnedFields ?? []),
    ],
    `${label}: clientWritableFields overlap backend-owned fields`
  );
}

function validateSchemaFieldProjection(collection, label) {
  const schema = schemaByCollectionId.get(collection.id);
  if (!schema) return;

  const modelSchemaFields = schemaModelFields(schema);
  const contractFields = [...(collection.allFields ?? [])].sort();
  if (
    collection.allFields &&
    modelSchemaFields.join("\n") !== contractFields.join("\n")
  ) {
    errors.push(
      `${label}: allFields differ from JSON schema model fields. ` +
      `expected [${modelSchemaFields.join(", ")}], actual ` +
      `[${contractFields.join(", ")}]`
    );
  }

  const internalDemoFields = new Set(schema["x-internal-demo-fields"] ?? []);
  const contractInternalDemoFields = [
    ...(collection.internalDemoFields ?? []),
  ].sort();
  const schemaInternalDemoFields = [...internalDemoFields].sort();
  if (
    schemaInternalDemoFields.join("\n") !==
    contractInternalDemoFields.join("\n")
  ) {
    errors.push(
      `${label}: internalDemoFields differ from JSON schema. expected ` +
      `[${schemaInternalDemoFields.join(", ")}], actual ` +
      `[${contractInternalDemoFields.join(", ")}]`
    );
  }
}

function validateRulesFieldAllowList(collection, label) {
  if (collection.id !== "users") return;

  const rulesFields = extractFirstHasOnlyFields(
    rules,
    "function hasValidUserShape(data)"
  );
  if (!rulesFields) {
    errors.push(`${label}: could not find hasValidUserShape hasOnly fields.`);
    return;
  }
  const expected = [...effectiveAllFields(collection)].sort();
  const actual = [...rulesFields].sort();
  if (expected.join("\n") !== actual.join("\n")) {
    errors.push(
      `${label}: firestore.rules hasValidUserShape fields differ from ` +
      `ownership contract. expected [${expected.join(", ")}], actual ` +
      `[${actual.join(", ")}]`
    );
  }
}

function assertNoOverlap(left, right, label) {
  const rightSet = new Set(right);
  for (const value of left) {
    if (rightSet.has(value)) {
      errors.push(`${label}: ${value}`);
    }
  }
}

function validateTypeContract(collection, label) {
  if (!collection.typescriptInterface) {
    return;
  }

  const generatedFields = extractInterfaceFields(
    generatedTypes,
    collection.typescriptInterface
  );
  if (!generatedFields) {
    errors.push(`${label}: generated TS interface not found: ${collection.typescriptInterface}`);
    return;
  }

  const fields = effectiveAllFields(collection);
  if (fields.length > 0) {
    const expected = [...fields].sort();
    const actual = [...generatedFields].sort();
    if (expected.join("\n") !== actual.join("\n")) {
      errors.push(
        `${label}: allFields differ from ${collection.typescriptInterface}. ` +
        `expected [${expected.join(", ")}], actual [${actual.join(", ")}]`
      );
    }
  }
}

function effectiveAllFields(collection) {
  const schema = schemaByCollectionId.get(collection.id);
  if (schema) return schemaModelFields(schema);
  return collection.allFields ?? [];
}

function schemaModelFields(schema) {
  const schemaFields = new Set(Object.keys(schema.properties ?? {}));
  const internalDemoFields = new Set(schema["x-internal-demo-fields"] ?? []);
  return [...schemaFields]
    .filter((field) => !internalDemoFields.has(field))
    .sort();
}

function extractInterfaceFields(source, interfaceName) {
  const escapedName = interfaceName.replace(/[.*+?^${}()|[\]\\]/g, "\\$&");
  const match = new RegExp(
    `export interface ${escapedName} \\{([\\s\\S]*?)\\n\\}`,
    "m"
  ).exec(source);
  if (!match) {
    return null;
  }

  const fields = new Set();
  for (const line of match[1].split("\n")) {
    const fieldMatch = /^\s*([A-Za-z_$][A-Za-z0-9_$]*)\??:/.exec(line);
    if (fieldMatch) {
      fields.add(fieldMatch[1]);
    }
  }
  return fields;
}

function extractFirstHasOnlyFields(source, functionHeader) {
  const functionIndex = source.indexOf(functionHeader);
  if (functionIndex === -1) return null;
  const hasOnlyIndex = source.indexOf(".hasOnly([", functionIndex);
  if (hasOnlyIndex === -1) return null;
  const arrayStart = source.indexOf("[", hasOnlyIndex);
  const arrayEnd = source.indexOf("]", arrayStart);
  if (arrayStart === -1 || arrayEnd === -1) return null;
  const body = source.slice(arrayStart + 1, arrayEnd);
  const fields = new Set();
  for (const match of body.matchAll(/'([^']+)'/g)) {
    fields.add(match[1]);
  }
  return fields;
}

function validateExportedFunctions(collection, label) {
  const exportedFunctions = collection.exportedFunctions ?? [];
  if (!Array.isArray(exportedFunctions)) {
    errors.push(`${label}.exportedFunctions must be an array when present`);
    return;
  }

  for (const functionName of exportedFunctions) {
    if (typeof functionName !== "string" || functionName.length === 0) {
      errors.push(`${label}.exportedFunctions contains a non-string value`);
      continue;
    }
    if (!hasNamedExport(functionName)) {
      errors.push(`${label}: functions/src/index.ts does not export ${functionName}`);
    }
  }
}

function validateOperations(collection, label) {
  const operations = collection.operations ?? [];
  if (!Array.isArray(operations)) {
    errors.push(`${label}.operations must be an array when present`);
    return;
  }

  const allFields = new Set(collection.allFields ?? []);
  const rulesTestSource = collection.rulesTestFile ?
    readText(path.join(repoRoot, collection.rulesTestFile)) :
    null;
  const seenOperationIds = new Set();

  for (const operation of operations) {
    const operationLabel = `${label}.operations.${operation.id ?? "<unknown>"}`;
    requireString(operation.id, `${operationLabel}.id`);
    requireString(operation.type, `${operationLabel}.type`);
    requireString(operation.owner, `${operationLabel}.owner`);
    assertUnique(
      seenOperationIds,
      operation.id,
      `${label}.operations.${operation.id}`
    );

    if (operation.function && !hasNamedExport(operation.function)) {
      errors.push(
        `${operationLabel}: functions/src/index.ts does not export ` +
        operation.function
      );
    }

    for (const fieldGroup of [
      "allowedFields",
      "deniedFields",
      "pathDataFields",
      "serverOwnedFields",
    ]) {
      validateOperationFieldGroup(
        operation[fieldGroup],
        allFields,
        `${operationLabel}.${fieldGroup}`
      );
    }

    validateRequiredStrings(
      operation.rulesMustContain,
      rules,
      `${operationLabel}.rulesMustContain`,
      "firestore.rules"
    );

    if (operation.rulesTestNames && !rulesTestSource) {
      errors.push(`${operationLabel}.rulesTestNames requires rulesTestFile`);
    }
    validateRequiredStrings(
      operation.rulesTestNames,
      rulesTestSource,
      `${operationLabel}.rulesTestNames`,
      collection.rulesTestFile
    );
  }
}

function validateOperationFieldGroup(fields, allFields, label) {
  if (fields === undefined) return;
  if (!Array.isArray(fields)) {
    errors.push(`${label} must be an array when present`);
    return;
  }
  const seen = new Set();
  for (const field of fields) {
    if (typeof field !== "string" || field.length === 0) {
      errors.push(`${label} contains a non-string field`);
      continue;
    }
    assertUnique(seen, field, `${label}.${field}`);
    if (allFields.size > 0 && !allFields.has(field)) {
      errors.push(`${label}.${field} is missing from allFields`);
    }
  }
}

function validateRequiredStrings(values, source, label, sourceLabel) {
  if (values === undefined) return;
  if (!Array.isArray(values)) {
    errors.push(`${label} must be an array when present`);
    return;
  }
  if (source === null) return;
  for (const value of values) {
    if (typeof value !== "string" || value.length === 0) {
      errors.push(`${label} contains a non-string value`);
      continue;
    }
    if (!source.includes(value)) {
      errors.push(`${label}: ${sourceLabel} does not contain "${value}"`);
    }
  }
}

function hasNamedExport(functionName) {
  const escapedName = functionName.replace(/[.*+?^${}()|[\]\\]/g, "\\$&");
  return new RegExp(`export \\{[^}]*\\b${escapedName}\\b[^}]*\\}`).test(
    functionsIndex
  );
}
