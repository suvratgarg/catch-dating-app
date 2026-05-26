#!/usr/bin/env node
import fs from "node:fs";
import path from "node:path";
import {fileURLToPath} from "node:url";

const toolDir = path.dirname(fileURLToPath(import.meta.url));
const repoRoot = path.resolve(toolDir, "../..");
const contractRoot = path.join(repoRoot, "contracts");
const draft07 = "http://json-schema.org/draft-07/schema#";

const errors = [];

function main() {
  if (!fs.existsSync(contractRoot)) {
    fail(`Missing contracts directory: ${relative(contractRoot)}`);
    finish();
    return;
  }

  const jsonFiles = walk(contractRoot).filter((file) => file.endsWith(".json"));
  const parsed = new Map();
  for (const file of jsonFiles) {
    try {
      parsed.set(file, readJson(file));
    } catch (error) {
      fail(`${relative(file)}: ${error.message}`);
    }
  }

  checkSchemaFiles(parsed);
  checkLocalRefs(parsed);
  checkCallableShapeMarkers(parsed);
  checkWireShapeExtensions(parsed);
  checkPromptCatalogs(parsed);
  checkFixturePlacement(parsed);
  checkCurrentCodeDrift(parsed);

  finish({
    jsonFiles: parsed.size,
    schemaFiles: [...parsed.keys()].filter((file) =>
      file.endsWith(".schema.json")
    ).length,
  });
}

function checkSchemaFiles(parsed) {
  for (const [file, json] of parsed.entries()) {
    if (!file.endsWith(".schema.json")) continue;
    if (json.$schema !== draft07) {
      fail(`${relative(file)}: expected draft-07 $schema.`);
    }
    if (typeof json.$id !== "string" || json.$id.length === 0) {
      fail(`${relative(file)}: missing string $id.`);
    }
  }
}

function checkCallableShapeMarkers(parsed) {
  for (const [file, json] of parsed.entries()) {
    if (!file.endsWith(".schema.json")) continue;
    const shape = json["x-callable-shape"];
    if (shape === undefined) continue;
    if (shape !== "patch") {
      fail(`${relative(file)}: x-callable-shape must be "patch" when present.`);
      continue;
    }
    if (!isCallableSchemaPath(file)) {
      fail(
        `${relative(file)}: x-callable-shape is only valid under ` +
        `contracts/callables/ or contracts/patches/.`
      );
    }
    if (
      json.type !== "object" ||
      !Array.isArray(json.required) ||
      !json.required.includes("fields") ||
      json.properties?.fields?.type !== "object" ||
      !json.properties?.fields?.properties
    ) {
      fail(
        `${relative(file)}: x-callable-shape "patch" requires a top-level ` +
        `required fields object.`
      );
    }
  }
}

function isCallableSchemaPath(file) {
  return file.startsWith(path.join(contractRoot, "callables") + path.sep) ||
    file.startsWith(path.join(contractRoot, "patches") + path.sep);
}

function checkWireShapeExtensions(parsed) {
  for (const [file, json] of parsed.entries()) {
    if (!file.endsWith(".schema.json")) continue;
    visitWireShapeNode(json, file, "#", parsed);
  }
}

function visitWireShapeNode(node, file, pointer, parsed) {
  if (Array.isArray(node)) {
    node.forEach((item, index) => {
      visitWireShapeNode(item, file, `${pointer}/${index}`, parsed);
    });
    return;
  }
  if (!node || typeof node !== "object") return;

  if (
    node["x-wire-shape-extends"] !== undefined ||
    node["x-wire-shape-injects"] !== undefined
  ) {
    validateWireShapeNode(node, file, pointer, parsed);
  }

  for (const [key, value] of Object.entries(node)) {
    visitWireShapeNode(value, file, `${pointer}/${escapeJsonPointer(key)}`, parsed);
  }
}

function validateWireShapeNode(node, file, pointer, parsed) {
  const label = `${relative(file)}${pointer}`;
  const extendsPath = node["x-wire-shape-extends"];
  const injects = node["x-wire-shape-injects"];

  if (typeof extendsPath !== "string" || extendsPath.length === 0) {
    fail(`${label}: x-wire-shape-extends must be a non-empty string.`);
    return;
  }
  if (!Array.isArray(injects) || injects.length === 0) {
    fail(`${label}: x-wire-shape-injects must be a non-empty array.`);
    return;
  }

  const targetPath = resolveContractMetadataPath(extendsPath, file);
  const target = parsed.get(targetPath);
  if (!target) {
    fail(`${label}: x-wire-shape-extends target not found: ${extendsPath}`);
    return;
  }
  if (target.type !== "object" || !target.properties) {
    fail(`${label}: x-wire-shape-extends target must be an object schema.`);
  }
  if (node.type !== "object" || !node.properties) {
    fail(`${label}: wire extension node must be an object with properties.`);
    return;
  }

  const required = new Set(node.required ?? []);
  const seen = new Set();
  for (const field of injects) {
    if (typeof field !== "string" || field.length === 0) {
      fail(`${label}: x-wire-shape-injects contains a non-string field.`);
      continue;
    }
    if (seen.has(field)) {
      fail(`${label}: duplicate injected wire field ${field}.`);
      continue;
    }
    seen.add(field);
    if (!node.properties[field]) {
      fail(`${label}: injected wire field ${field} is not declared.`);
    }
    if (!required.has(field)) {
      fail(`${label}: injected wire field ${field} must be required.`);
    }
    if (target.properties?.[field]) {
      fail(
        `${label}: injected wire field ${field} already exists in ` +
        `${extendsPath}.`
      );
    }
  }
}

function resolveContractMetadataPath(value, fromFile) {
  if (/^[a-z]+:\/\//i.test(value)) return value;
  if (value.startsWith("contracts/")) {
    return path.join(repoRoot, value);
  }
  return path.resolve(path.dirname(fromFile), value);
}

function escapeJsonPointer(value) {
  return value.replace(/~/g, "~0").replace(/\//g, "~1");
}

function checkLocalRefs(parsed) {
  for (const [file, json] of parsed.entries()) {
    for (const ref of collectRefs(json)) {
      if (ref.startsWith("#") || /^[a-z]+:\/\//i.test(ref)) continue;
      const target = ref.split("#")[0];
      if (!target) continue;
      const targetPath = path.resolve(path.dirname(file), target);
      if (!fs.existsSync(targetPath)) {
        fail(`${relative(file)}: $ref target not found: ${ref}`);
      }
    }
  }
}

function checkPromptCatalogs(parsed) {
  const profileCatalogPath = path.join(
    contractRoot,
    "catalogs/profile_prompts.json"
  );
  const photoCatalogPath = path.join(contractRoot, "catalogs/photo_prompts.json");
  const profilePhotoPolicyPath = path.join(
    contractRoot,
    "catalogs/profile_photo_policy.json"
  );
  const profileSchemaPath = path.join(
    contractRoot,
    "embedded/profile_prompt_answer.schema.json"
  );
  const photoSchemaPath = path.join(
    contractRoot,
    "embedded/photo_prompt_answer.schema.json"
  );
  const usersSchemaPath = path.join(contractRoot, "firestore/users.schema.json");
  const publicSchemaPath = path.join(
    contractRoot,
    "firestore/public_profiles.schema.json"
  );
  const patchSchemaPath = path.join(
    contractRoot,
    "patches/update_user_profile.schema.json"
  );

  const profileCatalog = parsed.get(profileCatalogPath);
  const photoCatalog = parsed.get(photoCatalogPath);
  const profilePhotoPolicy = parsed.get(profilePhotoPolicyPath);
  const profileSchema = parsed.get(profileSchemaPath);
  const photoSchema = parsed.get(photoSchemaPath);
  const usersSchema = parsed.get(usersSchemaPath);
  const publicSchema = parsed.get(publicSchemaPath);
  const patchSchema = parsed.get(patchSchemaPath);

  if (!profileCatalog || !photoCatalog || !profilePhotoPolicy) {
    fail("Missing prompt catalog files.");
    return;
  }
  if (!profileSchema || !photoSchema || !usersSchema || !publicSchema ||
      !patchSchema) {
    fail("Missing first-slice schema files.");
    return;
  }

  checkCatalog({
    file: profileCatalogPath,
    catalog: profileCatalog,
    expectedKind: "profilePrompts",
    maxItemKey: "maxAnswers",
  });
  checkCatalog({
    file: photoCatalogPath,
    catalog: photoCatalog,
    expectedKind: "photoPrompts",
  });

  const profileLimits = profileCatalog.limits ?? {};
  if (!Number.isInteger(profilePhotoPolicy.maxPhotos)) {
    fail(`${relative(profilePhotoPolicyPath)}: maxPhotos must be an integer.`);
  }
  const photoLimits = {
    ...(photoCatalog.limits ?? {}),
    maxCaptions: profilePhotoPolicy.maxPhotos,
  };
  assertEqual(
    profileSchema.properties?.promptId?.maxLength,
    profileLimits.maxPromptIdLength,
    "profile prompt id max length"
  );
  assertEqual(
    profileSchema.properties?.prompt?.maxLength,
    profileLimits.maxPromptTitleLength,
    "profile prompt title max length"
  );
  assertEqual(
    profileSchema.properties?.answer?.maxLength,
    profileLimits.maxAnswerLength,
    "profile prompt answer max length"
  );
  assertEqual(
    photoSchema.properties?.promptId?.maxLength,
    photoLimits.maxPromptIdLength,
    "photo prompt id max length"
  );
  assertEqual(
    photoSchema.properties?.prompt?.maxLength,
    photoLimits.maxPromptTitleLength,
    "photo prompt title max length"
  );
  assertEqual(
    photoSchema.properties?.caption?.maxLength,
    photoLimits.maxCaptionLength,
    "photo prompt caption max length"
  );
  const photoIndexMax =
    photoSchema.properties?.photoIndex?.maximum ??
    (photoSchema.properties?.photoIndex?.["x-catch-maximumFrom"] ===
      "profilePhotoPolicy.maxPhotosMinusOne" ?
      profilePhotoPolicy.maxPhotos - 1 :
      undefined);
  assertEqual(
    photoIndexMax,
    photoLimits.maxCaptions - 1,
    "photo prompt max index"
  );

  for (const [schemaFile, schema] of [
    [usersSchemaPath, usersSchema],
    [publicSchemaPath, publicSchema],
  ]) {
    assertEqual(
      schema.properties?.profilePrompts?.maxItems,
      profileLimits.maxAnswers,
      `${relative(schemaFile)} profilePrompts maxItems`
    );
  }

  assertEqual(
    patchSchema.properties?.fields?.properties?.profilePrompts?.maxItems,
    profileLimits.maxAnswers,
    "updateUserProfile profilePrompts maxItems"
  );
}

function checkCatalog({file, catalog, expectedKind, maxItemKey}) {
  if (catalog.schemaVersion !== 1) {
    fail(`${relative(file)}: schemaVersion must be 1.`);
  }
  if (catalog.kind !== expectedKind) {
    fail(`${relative(file)}: kind must be ${expectedKind}.`);
  }
  if (!Array.isArray(catalog.prompts) || catalog.prompts.length === 0) {
    fail(`${relative(file)}: prompts must be a non-empty array.`);
    return;
  }
  const ids = new Set();
  for (const [index, prompt] of catalog.prompts.entries()) {
    if (typeof prompt.id !== "string" || prompt.id.length === 0) {
      fail(`${relative(file)}: prompt ${index} has invalid id.`);
    }
    if (ids.has(prompt.id)) {
      fail(`${relative(file)}: duplicate prompt id ${prompt.id}.`);
    }
    ids.add(prompt.id);
    if (typeof prompt.title !== "string" || prompt.title.length === 0) {
      fail(`${relative(file)}: prompt ${prompt.id} has invalid title.`);
    }
    if (
      typeof prompt.placeholder !== "string" ||
      prompt.placeholder.length === 0
    ) {
      fail(`${relative(file)}: prompt ${prompt.id} has invalid placeholder.`);
    }
  }
  if (maxItemKey && !Number.isInteger(catalog.limits?.[maxItemKey])) {
    fail(`${relative(file)}: limits.${maxItemKey} must be an integer.`);
  }
  if (Array.isArray(catalog.defaultPromptIds)) {
    for (const id of catalog.defaultPromptIds) {
      if (!ids.has(id)) {
        fail(`${relative(file)}: defaultPromptIds contains unknown id ${id}.`);
      }
    }
  }
}

function checkFixturePlacement(parsed) {
  const validDir = path.join(contractRoot, "fixtures/valid");
  const invalidDir = path.join(contractRoot, "fixtures/invalid");
  const validFiles = [...parsed.keys()].filter((file) =>
    file.startsWith(`${validDir}${path.sep}`)
  );
  const invalidFiles = [...parsed.keys()].filter((file) =>
    file.startsWith(`${invalidDir}${path.sep}`)
  );

  if (validFiles.length === 0) {
    fail("contracts/fixtures/valid must contain at least one fixture.");
  }
  if (invalidFiles.length === 0) {
    fail("contracts/fixtures/invalid must contain at least one fixture.");
  }

  for (const file of validFiles) {
    if (containsKey(parsed.get(file), "bio")) {
      fail(`${relative(file)}: valid fixtures must not contain legacy bio.`);
    }
  }

  const overlongPrompt = parsed.get(
    path.join(invalidDir, "profile_prompt_answer_overlong.json")
  );
  const profileSchema = parsed.get(
    path.join(contractRoot, "embedded/profile_prompt_answer.schema.json")
  );
  const maxAnswerLength = profileSchema?.properties?.answer?.maxLength;
  if (
    typeof overlongPrompt?.answer === "string" &&
    Number.isInteger(maxAnswerLength) &&
    overlongPrompt.answer.length <= maxAnswerLength
  ) {
    fail("profile_prompt_answer_overlong.json must exceed maxAnswerLength.");
  }
}

function checkCurrentCodeDrift(parsed) {
  const commonSchema = parsed.get(
    path.join(contractRoot, "shared/profile_common.schema.json")
  );
  const heightCm = commonSchema?.definitions?.heightCm;
  if (
    !Number.isInteger(heightCm?.minimum) ||
    !Number.isInteger(heightCm?.maximum)
  ) {
    fail("profile_common.schema.json heightCm must define integer bounds.");
    return;
  }

  const updateUserProfilePath = path.join(
    repoRoot,
    "functions/src/profiles/updateUserProfile.ts"
  );
  const updateUserProfileSource = fs.readFileSync(
    updateUserProfilePath,
    "utf8"
  );
  assertContains(
    updateUserProfileSource,
    "validateUpdateUserProfileCallablePayload",
    `${relative(updateUserProfilePath)} generated profile validator`
  );
  if (updateUserProfileSource.includes("UserProfilePatchSchema")) {
    fail(`${relative(updateUserProfilePath)} must use generated schema validation.`);
  }
  if (
    updateUserProfileSource.includes("SexualOrientationSchema") ||
    /sexualOrientation\s*:/.test(updateUserProfileSource)
  ) {
    fail(`${relative(updateUserProfilePath)} must not accept sexualOrientation.`);
  }

  const rulesPath = path.join(repoRoot, "firestore.rules");
  const rulesSource = fs.readFileSync(rulesPath, "utf8");
  if (rulesSource.includes("sexualOrientation")) {
    fail(`${relative(rulesPath)} must not accept sexualOrientation.`);
  }
  assertContains(
    rulesSource,
    `data[field] >= ${heightCm.minimum}`,
    `${relative(rulesPath)} minimum height`
  );
  assertContains(
    rulesSource,
    `data[field] <= ${heightCm.maximum}`,
    `${relative(rulesPath)} maximum height`
  );

  const seedPath = path.join(repoRoot, "tool/demo/seed_demo_data.mjs");
  const seedSource = fs.readFileSync(seedPath, "utf8");
  if (/\bbio\s*:/.test(seedSource)) {
    fail(`${relative(seedPath)} must not emit legacy bio fields.`);
  }
  assertContains(
    seedSource,
    "profilePromptsForIndex",
    `${relative(seedPath)} profile prompts`
  );
  assertContains(
    seedSource,
    "photoPromptsForIndex",
    `${relative(seedPath)} photo prompts`
  );
}

function walk(dir) {
  const files = [];
  for (const entry of fs.readdirSync(dir, {withFileTypes: true})) {
    const fullPath = path.join(dir, entry.name);
    if (entry.isDirectory()) {
      files.push(...walk(fullPath));
    } else if (entry.isFile()) {
      files.push(fullPath);
    }
  }
  return files;
}

function readJson(file) {
  return JSON.parse(fs.readFileSync(file, "utf8"));
}

function collectRefs(value) {
  const refs = [];
  visit(value);
  return refs;

  function visit(node) {
    if (Array.isArray(node)) {
      node.forEach(visit);
      return;
    }
    if (!node || typeof node !== "object") return;
    if (typeof node.$ref === "string") refs.push(node.$ref);
    Object.values(node).forEach(visit);
  }
}

function containsKey(value, key) {
  if (Array.isArray(value)) return value.some((item) => containsKey(item, key));
  if (!value || typeof value !== "object") return false;
  if (Object.prototype.hasOwnProperty.call(value, key)) return true;
  return Object.values(value).some((item) => containsKey(item, key));
}

function assertEqual(actual, expected, label) {
  if (actual !== expected) {
    fail(`${label}: expected ${expected}, got ${actual}.`);
  }
}

function assertContains(source, expected, label) {
  if (!source.includes(expected)) {
    fail(`${label}: expected to contain ${expected}`);
  }
}

function fail(message) {
  errors.push(message);
}

function finish(stats = {}) {
  if (errors.length > 0) {
    console.error("Schema contract validation failed:");
    for (const error of errors) {
      console.error(`- ${error}`);
    }
    process.exitCode = 1;
    return;
  }
  const suffix = Object.entries(stats)
    .map(([key, value]) => `${key}=${value}`)
    .join(", ");
  console.log(`Schema contract validation passed${suffix ? ` (${suffix})` : ""}.`);
}

function relative(file) {
  return path.relative(repoRoot, file);
}

main();
