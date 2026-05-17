#!/usr/bin/env node
import fs from "node:fs";
import path from "node:path";
import {fileURLToPath} from "node:url";
import {
  createSavedRunClientWriteSchema,
  swipeDocumentSchema,
  userProfileDocumentSchema,
} from "./generated/schema_contract_registry.mjs";

const toolDir = path.dirname(fileURLToPath(import.meta.url));
const repoRoot = path.resolve(toolDir, "..");
const rules = fs.readFileSync(path.join(repoRoot, "firestore.rules"), "utf8");

const errors = [];

checkUserProfileRules();
checkProfileDecisionRules();
checkSavedRunRules();

if (errors.length > 0) {
  console.error("Firestore rules semantic check failed:");
  for (const error of errors) console.error(`- ${error}`);
  process.exit(1);
}

console.log("Firestore rules semantic check passed.");

function checkUserProfileRules() {
  const body = extractFunction("hasValidUserShape");
  const schema = userProfileDocumentSchema;
  const fields = modelFields(schema);
  const required = requiredModelFields(schema);

  expectSet({
    actual: extractFirstMethodFields(body, "hasOnly"),
    expected: fields,
    label: "hasValidUserShape hasOnly fields",
  });
  expectSet({
    actual: extractFirstMethodFields(body, "hasAll"),
    expected: required,
    label: "hasValidUserShape hasAll required fields",
  });

  checkListMax(body, "profilePrompts", schema);
  checkListMax(body, "photoUrls", schema);
  checkListMax(body, "photoThumbnailUrls", schema);
  checkListMax(body, "photoPrompts", schema);
  checkListMax(body, "profilePhotos", schema);
  checkListMax(body, "interestedInGenders", schema);
  checkListMax(body, "languages", schema);
  checkListMax(body, "preferredDistances", schema);
  checkListMax(body, "runningReasons", schema);
  checkListMax(body, "preferredRunTimes", schema);

  checkNumericBounds(body, "minAgePreference", schema);
  checkNumericBounds(body, "maxAgePreference", schema);
  checkHelperNumericBounds("optionalHeightCm", "height", schema);

  checkEnum(body, "gender", schema);
  checkEnum(body, "education", schema);
  checkEnum(body, "religion", schema);
  checkEnum(body, "relationshipGoal", schema);
  checkEnum(body, "drinking", schema);
  checkEnum(body, "smoking", schema);
  checkEnum(body, "workout", schema);
  checkEnum(body, "diet", schema);
  checkEnum(body, "children", schema);
}

function checkProfileDecisionRules() {
  const body = extractFunction("hasValidSwipeCreate");
  const schema = swipeDocumentSchema;
  expectSet({
    actual: extractFirstMethodFields(body, "hasOnly"),
    expected: modelFields(schema),
    label: "hasValidSwipeCreate hasOnly fields",
  });
  expectSet({
    actual: extractFirstMethodFields(body, "hasAll"),
    expected: requiredModelFields(schema),
    label: "hasValidSwipeCreate hasAll required fields",
  });

  checkEnum(body, "direction", schema, {dataExpression: "request.resource.data"});
  checkEnum(body, "reactionTargetType", schema, {
    dataExpression: "request.resource.data",
  });
  checkSwipeTextMax(body, "reactionTargetId", schema);
  checkSwipeTextMax(body, "reactionTargetLabel", schema);
  checkSwipeTextMax(body, "reactionTargetPreview", schema);
  checkSwipeTextMax(body, "comment", schema);
}

function checkSavedRunRules() {
  const body = extractMatchBlock("/savedRuns/{savedRunId}");
  const dataSchema = createSavedRunClientWriteSchema.properties.data;
  expectSet({
    actual: extractFirstMethodFields(body, "hasOnly"),
    expected: Object.keys(dataSchema.properties ?? {}).sort(),
    label: "savedRuns create hasOnly fields",
  });
  expectSet({
    actual: extractFirstMethodFields(body, "hasAll"),
    expected: [...(dataSchema.required ?? [])].sort(),
    label: "savedRuns create hasAll required fields",
  });
}

function checkListMax(body, field, schema) {
  const maxItems = schema.properties?.[field]?.maxItems;
  if (typeof maxItems !== "number") return;
  const directNeedle = `data.${field}.size() <= ${maxItems}`;
  const optionalNeedle = `optionalListMax(data, '${field}', ${maxItems})`;
  if (!body.includes(directNeedle) && !body.includes(optionalNeedle)) {
    errors.push(`${field}: rules must enforce maxItems ${maxItems}`);
  }
}

function checkNumericBounds(body, field, schema) {
  const property = schema.properties?.[field];
  if (!property) return;
  if (typeof property.minimum === "number" &&
      !body.includes(`data.${field} >= ${property.minimum}`)) {
    errors.push(`${field}: rules must enforce minimum ${property.minimum}`);
  }
  if (typeof property.maximum === "number" &&
      !body.includes(`data.${field} <= ${property.maximum}`)) {
    errors.push(`${field}: rules must enforce maximum ${property.maximum}`);
  }
}

function checkHelperNumericBounds(helperName, field, schema) {
  const body = extractFunction(helperName);
  const property = schema.properties?.[field];
  if (!property) return;
  if (typeof property.minimum === "number" &&
      !body.includes(`data[field] >= ${property.minimum}`)) {
    errors.push(
      `${helperName}: rules must enforce ${field} minimum ${property.minimum}`
    );
  }
  if (typeof property.maximum === "number" &&
      !body.includes(`data[field] <= ${property.maximum}`)) {
    errors.push(
      `${helperName}: rules must enforce ${field} maximum ${property.maximum}`
    );
  }
}

function checkEnum(body, field, schema, options = {}) {
  const values = enumValues(schema.properties?.[field]);
  if (values.length === 0) return;
  const dataExpression = options.dataExpression ?? "data";
  const directMarker = `${dataExpression}.${field} in [`;
  const optionalMarker = `optionalIn(${dataExpression}, '${field}', [`;
  const marker = body.includes(optionalMarker) ? optionalMarker : directMarker;
  const actual = extractListAfter(body, marker, {
    label: `${field} enum in firestore.rules`,
    allowMissing: true,
  });
  if (!actual) {
    errors.push(`${field}: rules must enforce enum [${values.join(", ")}]`);
    return;
  }
  expectSet({
    actual,
    expected: values,
    label: `${field} enum values`,
  });
}

function checkSwipeTextMax(body, field, schema) {
  const maxLength = maxLengthFor(schema.properties?.[field]);
  if (typeof maxLength !== "number") return;
  const pattern = new RegExp(
    `optionalSwipeText\\s*\\(\\s*request\\.resource\\.data\\s*,` +
      `\\s*'${escapeRegex(field)}'\\s*,\\s*${maxLength}\\s*\\)`
  );
  if (!pattern.test(body)) {
    errors.push(`${field}: rules must enforce maxLength ${maxLength}`);
  }
}

function modelFields(schema) {
  const internal = new Set(schema["x-internal-demo-fields"] ?? []);
  return Object.keys(schema.properties ?? {})
    .filter((field) => !internal.has(field))
    .sort();
}

function requiredModelFields(schema) {
  const fields = new Set(modelFields(schema));
  return [...(schema.required ?? [])].filter((field) => fields.has(field)).sort();
}

function enumValues(schema) {
  if (!schema || typeof schema !== "object") return [];
  if (Array.isArray(schema.enum)) {
    return schema.enum.filter((value) => value !== null).sort();
  }
  if (Array.isArray(schema.anyOf)) {
    return schema.anyOf.flatMap(enumValues).sort();
  }
  return [];
}

function maxLengthFor(schema) {
  if (!schema || typeof schema !== "object") return null;
  if (typeof schema.maxLength === "number") return schema.maxLength;
  if (Array.isArray(schema.anyOf)) {
    for (const option of schema.anyOf) {
      const maxLength = maxLengthFor(option);
      if (typeof maxLength === "number") return maxLength;
    }
  }
  return null;
}

function expectSet({actual, expected, label}) {
  if (!actual) {
    errors.push(`${label}: could not extract rules values`);
    return;
  }
  const actualValues = [...actual].sort();
  const expectedValues = [...expected].sort();
  if (actualValues.join("\n") !== expectedValues.join("\n")) {
    errors.push(
      `${label} differ. expected [${expectedValues.join(", ")}], ` +
        `actual [${actualValues.join(", ")}]`
    );
  }
}

function extractFunction(functionName) {
  const index = rules.indexOf(`function ${functionName}`);
  if (index === -1) {
    throw new Error(`Missing firestore.rules function ${functionName}`);
  }
  return extractBracedBlock(rules, rules.indexOf("{", index));
}

function extractMatchBlock(matchPath) {
  const marker = `match ${matchPath}`;
  const index = rules.indexOf(marker);
  if (index === -1) {
    throw new Error(`Missing firestore.rules match ${matchPath}`);
  }
  return extractBracedBlock(rules, rules.indexOf("{", index + marker.length));
}

function extractBracedBlock(source, openIndex) {
  if (openIndex === -1) throw new Error("Missing opening brace.");
  let depth = 0;
  for (let index = openIndex; index < source.length; index += 1) {
    const char = source[index];
    if (char === "{") depth += 1;
    if (char === "}") {
      depth -= 1;
      if (depth === 0) return source.slice(openIndex, index + 1);
    }
  }
  throw new Error("Missing closing brace.");
}

function extractFirstMethodFields(body, methodName) {
  return extractListAfter(body, `.${methodName}([`, {
    label: `${methodName} fields`,
  });
}

function extractListAfter(body, marker, {label, allowMissing = false}) {
  const index = body.indexOf(marker);
  if (index === -1) {
    if (allowMissing) return null;
    throw new Error(`Missing ${label}: ${marker}`);
  }
  const openIndex = body.indexOf("[", index);
  const closeIndex = findMatchingBracket(body, openIndex);
  const values = new Set();
  for (const match of body.slice(openIndex + 1, closeIndex).matchAll(/'([^']+)'/g)) {
    values.add(match[1]);
  }
  return values;
}

function findMatchingBracket(source, openIndex) {
  if (openIndex === -1) throw new Error("Missing opening bracket.");
  let depth = 0;
  for (let index = openIndex; index < source.length; index += 1) {
    const char = source[index];
    if (char === "[") depth += 1;
    if (char === "]") {
      depth -= 1;
      if (depth === 0) return index;
    }
  }
  throw new Error("Missing closing bracket.");
}

function escapeRegex(value) {
  return String(value).replace(/[.*+?^${}()|[\]\\]/g, "\\$&");
}
