#!/usr/bin/env node
import fs from "node:fs";
import path from "node:path";
import {fileURLToPath} from "node:url";

const toolDir = path.dirname(fileURLToPath(import.meta.url));
const repoRoot = path.resolve(toolDir, "../..");

const allowedPhaseStatuses = new Set([
  "pending",
  "complete",
  "complete_remote",
]);

export function checkMigrationContracts({root = repoRoot} = {}) {
  const migrationDir = path.join(root, "contracts/migrations");
  const errors = [];
  let phaseCount = 0;

  if (!fs.existsSync(migrationDir)) {
    return {
      ok: false,
      errors: [`${relative(root, migrationDir)}: migration directory is missing.`],
      migrationCount: 0,
      phaseCount,
    };
  }

  const files = fs.readdirSync(migrationDir)
    .filter((entry) => entry.endsWith(".json"))
    .sort((a, b) => a.localeCompare(b));

  for (const entry of files) {
    const filePath = path.join(migrationDir, entry);
    const label = relative(root, filePath);
    let data;
    try {
      data = JSON.parse(fs.readFileSync(filePath, "utf8"));
    } catch (error) {
      errors.push(`${label}: ${error.message}`);
      continue;
    }

    if (!Number.isInteger(data.schemaVersion) || data.schemaVersion < 1) {
      errors.push(`${label}: schemaVersion must be a positive integer.`);
    }
    requireString(errors, label, data, "logicalName");
    requireString(errors, label, data, "currentPhase");
    requireString(errors, label, data, "reason", {minLength: 20});

    if (!Array.isArray(data.phases) || data.phases.length === 0) {
      errors.push(`${label}: phases must be a non-empty array.`);
      continue;
    }

    const phaseIds = new Set();
    let hasPendingPhase = false;
    let hasRemoteCompletePhase = false;
    for (const [index, phase] of data.phases.entries()) {
      phaseCount += 1;
      const phaseLabel = `${label}: phases[${index}]`;
      if (!phase || typeof phase !== "object" || Array.isArray(phase)) {
        errors.push(`${phaseLabel} must be an object.`);
        continue;
      }
      const id = phase.id;
      if (typeof id !== "string" || id.length === 0) {
        errors.push(`${phaseLabel}.id must be a non-empty string.`);
      } else if (phaseIds.has(id)) {
        errors.push(`${label}: duplicate phase id "${id}".`);
      } else {
        phaseIds.add(id);
      }

      const status = phase.status;
      if (!allowedPhaseStatuses.has(status)) {
        errors.push(
          `${phaseLabel}.status must be one of ` +
          `${[...allowedPhaseStatuses].join(", ")}.`,
        );
      }
      hasPendingPhase = hasPendingPhase || status === "pending";
      hasRemoteCompletePhase = hasRemoteCompletePhase ||
        status === "complete_remote";
      requireString(errors, phaseLabel, phase, "description", {minLength: 20});
    }

    if (String(data.currentPhase).endsWith("_complete") && hasPendingPhase) {
      errors.push(
        `${label}: currentPhase ${data.currentPhase} is marked complete but ` +
        "at least one phase is still pending.",
      );
    }
    if (hasRemoteCompletePhase && !isPlainObject(data.liveApply)) {
      errors.push(
        `${label}: complete_remote phases require a liveApply evidence object.`,
      );
    }
    if (!hasOperationalEvidence(data)) {
      errors.push(
        `${label}: migration contract must list knownConsumers, guards, ` +
        "guardsCompletedBeforeApply, or rulesAndIndexes.",
      );
    }
  }

  return {
    ok: errors.length === 0,
    errors,
    migrationCount: files.length,
    phaseCount,
  };
}

function requireString(errors, label, object, key, {minLength = 1} = {}) {
  const value = object[key];
  if (typeof value !== "string" || value.trim().length < minLength) {
    errors.push(
      `${label}.${key} must be a string with at least ${minLength} character(s).`,
    );
  }
}

function hasOperationalEvidence(data) {
  return nonEmptyArray(data.knownConsumers) ||
    nonEmptyArray(data.guards) ||
    nonEmptyArray(data.guardsCompletedBeforeApply) ||
    isPlainObject(data.rulesAndIndexes);
}

function nonEmptyArray(value) {
  return Array.isArray(value) && value.length > 0;
}

function isPlainObject(value) {
  return Boolean(value) && typeof value === "object" && !Array.isArray(value);
}

function relative(root, filePath) {
  return path.relative(root, filePath).replaceAll(path.sep, "/");
}

function runCli() {
  const result = checkMigrationContracts();
  if (!result.ok) {
    console.error("Migration contract check failed:");
    for (const error of result.errors) console.error(`- ${error}`);
    process.exitCode = 1;
    return;
  }
  console.log(
    `Migration contract check passed ` +
    `(migrations=${result.migrationCount}, phases=${result.phaseCount}).`,
  );
}

if (process.argv[1] === fileURLToPath(import.meta.url)) {
  runCli();
}
