#!/usr/bin/env node

import {spawnSync} from "node:child_process";
import fs from "node:fs";
import path from "node:path";
import {fileURLToPath} from "node:url";

const READY = "READY";
const FAILED_STATES = new Set(["ERROR", "NEEDS_REPAIR"]);

function assert(condition, message) {
  if (!condition) throw new Error(message);
}

function normalizedField(field) {
  assert(field && typeof field === "object", "index fields must be objects");
  assert(typeof field.fieldPath === "string" && field.fieldPath !== "",
    "index fieldPath must be non-empty");
  const mode = field.mode ?? field.order;
  const result = {fieldPath: field.fieldPath};
  if (mode != null) result.order = String(mode).toUpperCase();
  if (field.arrayConfig != null) {
    result.arrayConfig = String(field.arrayConfig).toUpperCase();
  }
  if (field.vectorConfig != null) result.vectorConfig = field.vectorConfig;
  assert(
    result.order != null ||
      result.arrayConfig != null ||
      result.vectorConfig != null,
    `index field ${field.fieldPath} has no mode`,
  );
  return result;
}

function inferredNameOrder(fields) {
  for (let index = fields.length - 1; index >= 0; index -= 1) {
    if (fields[index].order != null) return fields[index].order;
  }
  return "ASCENDING";
}

function withImplicitNameField(fields) {
  if (fields.some((field) => field.fieldPath === "__name__")) return fields;
  return [
    ...fields,
    {fieldPath: "__name__", order: inferredNameOrder(fields)},
  ];
}

function collectionGroup(index) {
  if (typeof index.collectionGroup === "string" && index.collectionGroup !== "") {
    return index.collectionGroup;
  }
  const name = String(index.name ?? "");
  const match = /\/collectionGroups\/([^/]+)\/indexes\//u.exec(name);
  assert(match, "live index has no collectionGroup identity");
  return decodeURIComponent(match[1]);
}

export function normalizeIndex(index, {desired = false} = {}) {
  const fields = (index.fields ?? []).map(normalizedField);
  assert(fields.length > 0, "composite index must contain fields");
  return {
    collectionGroup: collectionGroup(index),
    queryScope: String(index.queryScope ?? "COLLECTION").toUpperCase(),
    apiScope: String(index.apiScope ?? "ANY_API").toUpperCase(),
    fields: desired ? withImplicitNameField(fields) : fields,
  };
}

export function indexSignature(index, options) {
  return JSON.stringify(normalizeIndex(index, options));
}

export function inspectIndexReadiness(desiredDocument, liveIndexes) {
  assert(Array.isArray(desiredDocument?.indexes),
    "firestore index configuration must contain indexes");
  assert(Array.isArray(liveIndexes), "gcloud index response must be an array");
  const desired = desiredDocument.indexes.map((index) => ({
    index,
    signature: indexSignature(index, {desired: true}),
  }));
  const liveBySignature = new Map();
  for (const live of liveIndexes) {
    const signature = indexSignature(live);
    const previous = liveBySignature.get(signature);
    assert(previous == null, "live Firestore indexes contain a duplicate signature");
    liveBySignature.set(signature, live);
  }

  const ready = [];
  const pending = [];
  const failed = [];
  for (const entry of desired) {
    const live = liveBySignature.get(entry.signature);
    const label = entry.index.collectionGroup;
    if (live == null) {
      pending.push({collectionGroup: label, state: "MISSING"});
      continue;
    }
    const state = String(live.state ?? "UNKNOWN").toUpperCase();
    if (state === READY) ready.push({collectionGroup: label, state});
    else if (FAILED_STATES.has(state) || state === "UNKNOWN") {
      failed.push({collectionGroup: label, state});
    } else {
      pending.push({collectionGroup: label, state});
    }
  }
  return {
    complete: pending.length === 0 && failed.length === 0,
    desiredCount: desired.length,
    ready,
    pending,
    failed,
  };
}

export function gcloudIndexList({
  projectId,
  database = "(default)",
  spawn = spawnSync,
}) {
  assert(/^[a-z][a-z0-9-]{4,29}$/u.test(projectId),
    "project id must be a valid lowercase Google Cloud project id");
  const result = spawn("gcloud", [
    "firestore",
    "indexes",
    "composite",
    "list",
    `--project=${projectId}`,
    `--database=${database}`,
    "--format=json",
    "--quiet",
  ], {
    encoding: "utf8",
    timeout: 60_000,
    maxBuffer: 16 * 1024 * 1024,
  });
  assert(result.status === 0,
    "could not read Firestore composite-index metadata");
  try {
    return JSON.parse(result.stdout);
  } catch {
    throw new Error("gcloud returned invalid composite-index JSON");
  }
}

function parsePositiveNumber(value, label) {
  const parsed = Number(value);
  assert(Number.isFinite(parsed) && parsed > 0, `${label} must be positive`);
  return parsed;
}

function parseArgs(argv) {
  if (argv.length === 1 && argv[0] === "--self-test") {
    return {selfTest: true};
  }
  const values = {};
  for (let index = 0; index < argv.length; index += 2) {
    const flag = argv[index];
    const value = argv[index + 1];
    assert(flag?.startsWith("--") && value != null,
      "arguments must be --name value pairs");
    values[flag.slice(2)] = value;
  }
  return {
    indexesPath: values.indexes,
    projectId: values.project ?? process.env.CATCH_FIREBASE_PROJECT_ID,
    database: values.database ?? "(default)",
    timeoutMs: parsePositiveNumber(
      values["timeout-seconds"] ?? "1800",
      "timeout-seconds",
    ) * 1000,
    pollMs: parsePositiveNumber(
      values["poll-seconds"] ?? "20",
      "poll-seconds",
    ) * 1000,
  };
}

export function runSelfTest() {
  const desiredDocument = {
    indexes: [{
      collectionGroup: "self_test",
      queryScope: "COLLECTION",
      fields: [
        {fieldPath: "status", order: "ASCENDING"},
        {fieldPath: "createdAt", order: "DESCENDING"},
      ],
    }],
  };
  const liveIndexes = [{
    collectionGroup: "self_test",
    queryScope: "COLLECTION",
    apiScope: "ANY_API",
    state: "READY",
    fields: [
      {fieldPath: "status", order: "ASCENDING"},
      {fieldPath: "createdAt", order: "DESCENDING"},
      {fieldPath: "__name__", order: "DESCENDING"},
    ],
  }];
  const report = inspectIndexReadiness(desiredDocument, liveIndexes);
  assert(report.complete && report.ready.length === 1,
    "Firestore index readiness self-test did not reach READY");
  return report;
}

const delay = (milliseconds) =>
  new Promise((resolve) => setTimeout(resolve, milliseconds));

export async function waitForIndexes({
  desiredDocument,
  projectId,
  database = "(default)",
  timeoutMs,
  pollMs,
  listIndexes = gcloudIndexList,
  sleep = delay,
  now = () => Date.now(),
  onProgress = () => {},
}) {
  const startedAt = now();
  while (true) {
    const report = inspectIndexReadiness(
      desiredDocument,
      listIndexes({projectId, database}),
    );
    onProgress(report);
    if (report.failed.length > 0) {
      const states = [...new Set(report.failed.map((entry) => entry.state))].join(",");
      throw new Error(`Firestore composite indexes entered a failed state: ${states}`);
    }
    if (report.complete) return report;
    if (now() - startedAt >= timeoutMs) {
      throw new Error(
        `Timed out waiting for ${report.pending.length} Firestore composite indexes`,
      );
    }
    await sleep(pollMs);
  }
}

async function main() {
  const args = parseArgs(process.argv.slice(2));
  if (args.selfTest) {
    console.log(JSON.stringify({ok: true, report: runSelfTest()}));
    return;
  }
  assert(args.indexesPath, "--indexes is required");
  assert(args.projectId, "--project or CATCH_FIREBASE_PROJECT_ID is required");
  const desiredDocument = JSON.parse(
    fs.readFileSync(path.resolve(args.indexesPath), "utf8"),
  );
  const report = await waitForIndexes({
    desiredDocument,
    ...args,
    onProgress(current) {
      const states = [...new Set(current.pending.map((entry) => entry.state))]
        .sort()
        .join(",") || "none";
      console.log(
        `Firestore indexes: ${current.ready.length}/${current.desiredCount} READY; pending states: ${states}`,
      );
    },
  });
  console.log(
    `Firestore composite indexes READY: ${report.ready.length}/${report.desiredCount}.`,
  );
}

const isMain =
  process.argv[1] != null &&
  path.resolve(process.argv[1]) === fileURLToPath(import.meta.url);
if (isMain) {
  main().catch((error) => {
    console.error(error instanceof Error ? error.message : String(error));
    process.exitCode = 1;
  });
}
