#!/usr/bin/env node
import fs from "node:fs";
import path from "node:path";
import {fileURLToPath} from "node:url";

const adminRoot = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "..");
const args = new Set(process.argv.slice(2));

if (args.has("--self-test")) {
  runSelfTest();
  process.exit(0);
}

const manifestPath = path.join(adminRoot, "dist/.vite/manifest.json");
const budgetPath = path.join(adminRoot, "bundle-budget.json");
const result = validateBundleBudget({
  budget: readJson(budgetPath),
  manifest: readJson(manifestPath),
  sizeForFile: (file) => fs.statSync(path.join(adminRoot, "dist", file)).size,
});
result.findings.push(...validateAppBoundary(
  fs.readFileSync(path.join(adminRoot, "src/app/App.tsx"), "utf8")
));
result.findings.push(...validateLiveOperationalAssets({
  dataMode: process.env.VITE_ADMIN_DATA_MODE,
  manifest: readJson(manifestPath),
}));

if (result.findings.length > 0) {
  console.error("Admin bundle budget failed:");
  result.findings.forEach((finding) => console.error(`- ${finding}`));
  process.exit(1);
}

console.log(
  `Admin bundle budget passed: initial ${formatBytes(result.initialBytes)} / ` +
  `${formatBytes(result.initialMaxBytes)} (entry and ${result.initialImports} static imports); ` +
  `largest async ${formatBytes(result.asyncBytes)} / ` +
  `${formatBytes(result.asyncChunkMaxBytes)} (${result.asyncFile}).`
);

/**
 * The initial budget covers every byte of JavaScript loaded before the first
 * lazy route: the entry and its static imports. Measuring the entry file alone
 * moved with the bundler's chunking (folding a shared chunk into the entry
 * changed the number without changing what the browser downloads).
 */
export function validateBundleBudget({budget, manifest, sizeForFile}) {
  const findings = [];
  if (budget.schemaVersion !== 1) findings.push("bundle budget schemaVersion must be 1");
  const initialMaxBytes = positiveInteger(budget.initialMaxBytes, "initialMaxBytes", findings);
  const asyncChunkMaxBytes = positiveInteger(
    budget.asyncChunkMaxBytes,
    "asyncChunkMaxBytes",
    findings
  );
  const chunks = Object.values(manifest ?? {}).filter((entry) =>
    entry && typeof entry === "object" && typeof entry.file === "string" &&
    entry.file.endsWith(".js")
  );
  const entry = chunks.find((chunk) => chunk.isEntry === true);
  if (!entry) findings.push("Vite manifest has no JavaScript entry chunk");
  const asyncChunks = chunks.filter((chunk) => chunk !== entry);
  if (asyncChunks.length === 0) findings.push("Vite manifest has no async JavaScript chunks");

  const initialKeys = new Set();
  const entryKey = Object.keys(manifest ?? {}).find((key) => manifest[key] === entry);
  const collect = (key) => {
    if (!key || initialKeys.has(key) || !manifest[key]) return;
    initialKeys.add(key);
    for (const next of manifest[key].imports ?? []) collect(next);
  };
  collect(entryKey);
  const initialBytes = [...initialKeys].reduce((total, key) => total + sizeForFile(manifest[key].file), 0);
  const initialFiles = new Set([...initialKeys].map((key) => manifest[key].file));
  const largestAsync = asyncChunks
    .filter((chunk) => !initialFiles.has(chunk.file))
    .map((chunk) => ({file: chunk.file, bytes: sizeForFile(chunk.file)}))
    .sort((left, right) => right.bytes - left.bytes)[0] ?? {file: "none", bytes: 0};

  if (initialBytes > initialMaxBytes) {
    findings.push(
      `initial JavaScript (${entry?.file} and ${initialKeys.size - 1} static imports) is ` +
      `${initialBytes} bytes; budget is ${initialMaxBytes}`
    );
  }
  if (largestAsync.bytes > asyncChunkMaxBytes) {
    findings.push(
      `async chunk ${largestAsync.file} is ${largestAsync.bytes} bytes; budget is ` +
      `${asyncChunkMaxBytes}`
    );
  }
  return {
    asyncBytes: largestAsync.bytes,
    asyncChunkMaxBytes,
    asyncFile: largestAsync.file,
    findings,
    initialBytes,
    initialImports: Math.max(initialKeys.size - 1, 0),
    initialMaxBytes,
  };
}

export function validateAppBoundary(source) {
  const findings = [];
  if (/from\s+["'][^"']*features\/[^"']*\/controllers\//u.test(source)) {
    findings.push("admin app shell imports a feature controller outside its lazy route");
  }
  if (/from\s+["'][^"']*shared\/api\/adminApi["']/u.test(source)) {
    findings.push("admin app shell imports the feature API boundary into the entry chunk");
  }
  return findings;
}

export function validateLiveOperationalAssets({dataMode, manifest}) {
  if (dataMode !== "live") return [];
  const serialized = JSON.stringify(manifest);
  const fixtureNames = [
    "eventIntakeBridge",
    "externalEventImportExecutionPlan",
    "externalEventImportPlan",
    "marketingOpsBridge",
    "organizerIntakeBridge",
  ];
  return fixtureNames
    .filter((name) => serialized.includes(name))
    .map((name) =>
      `live Admin bundle contains generated operational fixture ${name}`);
}

function positiveInteger(value, label, findings) {
  if (!Number.isInteger(value) || value <= 0) {
    findings.push(`${label} must be a positive integer`);
    return 0;
  }
  return value;
}

function readJson(filePath) {
  if (!fs.existsSync(filePath)) {
    throw new Error(`Missing required bundle artifact: ${path.relative(adminRoot, filePath)}`);
  }
  return JSON.parse(fs.readFileSync(filePath, "utf8"));
}

function formatBytes(value) {
  return `${(value / 1000).toFixed(1)} KB`;
}

function runSelfTest() {
  const manifest = {
    "index.html": {file: "assets/index.js", isEntry: true, imports: ["_vendor.js"]},
    "_vendor.js": {file: "assets/vendor.js"},
    "feature.tsx": {file: "assets/feature.js", isDynamicEntry: true, imports: ["_vendor.js"]},
  };
  const sizes = new Map([
    ["assets/index.js", 60],
    ["assets/vendor.js", 41],
    ["assets/feature.js", 201],
  ]);
  const result = validateBundleBudget({
    budget: {schemaVersion: 1, initialMaxBytes: 100, asyncChunkMaxBytes: 200},
    manifest,
    sizeForFile: (file) => sizes.get(file) ?? 0,
  });
  if (!result.findings.some((finding) => finding.startsWith("initial JavaScript "))) {
    throw new Error("self-test failed to count an entry's static imports toward the initial budget");
  }
  if (!result.findings.some((finding) => finding.startsWith("async chunk "))) {
    throw new Error("self-test failed to reject an oversized async chunk");
  }
  // Folding the shared chunk into the entry changes no downloaded byte.
  const folded = validateBundleBudget({
    budget: {schemaVersion: 1, initialMaxBytes: 101, asyncChunkMaxBytes: 201},
    manifest: {
      "index.html": {file: "assets/index.js", isEntry: true},
      "feature.tsx": {file: "assets/feature.js", isDynamicEntry: true},
    },
    sizeForFile: (file) => (file === "assets/index.js" ? 101 : sizes.get(file) ?? 0),
  });
  if (folded.findings.length !== 0 || folded.initialBytes !== result.initialBytes) {
    throw new Error("self-test failed: chunk folding changed the initial measure");
  }
  const boundaryFindings = validateAppBoundary(
    'import {useThing} from "../features/thing/controllers/useThing";\n'
  );
  if (!boundaryFindings.some((finding) => finding.includes("feature controller"))) {
    throw new Error("self-test failed to reject a feature controller in the app shell");
  }
  const liveFixtureFindings = validateLiveOperationalAssets({
    dataMode: "live",
    manifest: {
      "src/generated/eventIntakeBridge.json": {
        file: "assets/eventIntakeBridge-sample.json",
      },
    },
  });
  if (!liveFixtureFindings.some((finding) =>
    finding.includes("eventIntakeBridge"))) {
    throw new Error(
      "self-test failed to reject a generated fixture in the live bundle"
    );
  }
  console.log("Admin bundle budget self-test passed.");
}
