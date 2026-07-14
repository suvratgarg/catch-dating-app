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

if (result.findings.length > 0) {
  console.error("Admin bundle budget failed:");
  result.findings.forEach((finding) => console.error(`- ${finding}`));
  process.exit(1);
}

console.log(
  `Admin bundle budget passed: entry ${formatBytes(result.entryBytes)} / ` +
  `${formatBytes(result.entryMaxBytes)}; largest async ${formatBytes(result.asyncBytes)} / ` +
  `${formatBytes(result.asyncChunkMaxBytes)} (${result.asyncFile}).`
);

export function validateBundleBudget({budget, manifest, sizeForFile}) {
  const findings = [];
  if (budget.schemaVersion !== 1) findings.push("bundle budget schemaVersion must be 1");
  const entryMaxBytes = positiveInteger(budget.entryMaxBytes, "entryMaxBytes", findings);
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

  const entryBytes = entry ? sizeForFile(entry.file) : 0;
  const largestAsync = asyncChunks
    .map((chunk) => ({file: chunk.file, bytes: sizeForFile(chunk.file)}))
    .sort((left, right) => right.bytes - left.bytes)[0] ?? {file: "none", bytes: 0};

  if (entryBytes > entryMaxBytes) {
    findings.push(
      `entry ${entry?.file} is ${entryBytes} bytes; budget is ${entryMaxBytes}`
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
    entryBytes,
    entryMaxBytes,
    findings,
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
    "index.html": {file: "assets/index.js", isEntry: true},
    "feature.tsx": {file: "assets/feature.js", isDynamicEntry: true},
  };
  const sizes = new Map([
    ["assets/index.js", 101],
    ["assets/feature.js", 201],
  ]);
  const result = validateBundleBudget({
    budget: {schemaVersion: 1, entryMaxBytes: 100, asyncChunkMaxBytes: 200},
    manifest,
    sizeForFile: (file) => sizes.get(file) ?? 0,
  });
  if (!result.findings.some((finding) => finding.startsWith("entry "))) {
    throw new Error("self-test failed to reject an oversized entry chunk");
  }
  if (!result.findings.some((finding) => finding.startsWith("async chunk "))) {
    throw new Error("self-test failed to reject an oversized async chunk");
  }
  const boundaryFindings = validateAppBoundary(
    'import {useThing} from "../features/thing/controllers/useThing";\n'
  );
  if (!boundaryFindings.some((finding) => finding.includes("feature controller"))) {
    throw new Error("self-test failed to reject a feature controller in the app shell");
  }
  console.log("Admin bundle budget self-test passed.");
}
