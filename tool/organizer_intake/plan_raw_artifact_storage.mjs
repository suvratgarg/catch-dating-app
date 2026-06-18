#!/usr/bin/env node
import crypto from "node:crypto";
import fs from "node:fs";
import path from "node:path";
import {fileURLToPath} from "node:url";
import {buildRawArtifactStorageManifest} from
  "./lib/raw_artifact_storage_core.mjs";

const scriptDir = path.dirname(fileURLToPath(import.meta.url));
const repoRoot = path.resolve(scriptDir, "..", "..");
const defaultOutputPath = path.join(
  scriptDir,
  "generated",
  "raw_artifact_storage_manifest.json"
);
const defaultArtifactRoots = [
  "raw_artifacts",
  "fixtures",
  "search_result_batches",
  "event_source_batches",
  "batches",
  "curation_decisions",
  "review_decisions",
  "event_review_decisions",
  "event_location_resolutions",
  "policy_gap_decisions",
].map((root) => path.join(scriptDir, root));

const args = parseArgs(process.argv.slice(2));
if (args.help) {
  printHelp();
  process.exit(0);
}

const outputPath = path.resolve(args.output ?? defaultOutputPath);
const artifactRoots = args.roots.length > 0 ?
  args.roots.map((root) => path.resolve(root)) :
  defaultArtifactRoots;
const artifactFiles = collectArtifactFiles(artifactRoots);
const manifest = buildRawArtifactStorageManifest({artifactFiles});
const rendered = `${stableStringify(manifest)}\n`;

if (args.check) {
  if (!fs.existsSync(outputPath)) {
    fail(`Missing raw artifact storage manifest: ${relative(outputPath)}`);
  }
  const current = fs.readFileSync(outputPath, "utf8");
  if (current !== rendered) {
    fail(
      `Raw artifact storage manifest is stale: ${relative(outputPath)}\n` +
        "Run node tool/organizer_intake/plan_raw_artifact_storage.mjs"
    );
  }
  console.log(`Raw artifact storage manifest is current: ${relative(outputPath)}`);
  process.exit(0);
}

fs.mkdirSync(path.dirname(outputPath), {recursive: true});
fs.writeFileSync(outputPath, rendered);
console.log(
  `Raw artifact storage manifest ready: ${manifest.summary.artifacts} ` +
    `artifact(s), ${manifest.summary.rawProviderPayloads} raw payload(s), ` +
    `${manifest.summary.remoteUploadBlocked} upload-blocked.`
);
console.log(`Wrote ${relative(outputPath)}.`);

export function collectArtifactFiles(roots) {
  const files = [];
  for (const root of roots) {
    if (!fs.existsSync(root)) continue;
    for (const filePath of walkJsonFiles(root)) {
      files.push(fileRecord(filePath));
    }
  }
  return files.sort((a, b) => a.path.localeCompare(b.path));
}

function walkJsonFiles(root) {
  const entries = fs.readdirSync(root, {withFileTypes: true})
    .sort((a, b) => a.name.localeCompare(b.name));
  const files = [];
  for (const entry of entries) {
    const fullPath = path.join(root, entry.name);
    if (entry.isDirectory()) {
      files.push(...walkJsonFiles(fullPath));
    } else if (entry.isFile() && entry.name.endsWith(".json")) {
      files.push(fullPath);
    }
  }
  return files;
}

function fileRecord(filePath) {
  const content = fs.readFileSync(filePath);
  return {
    path: relative(filePath),
    sizeBytes: content.length,
    sha256: crypto.createHash("sha256").update(content).digest("hex"),
  };
}

function parseArgs(argv) {
  const parsed = {
    check: false,
    help: false,
    output: null,
    roots: [],
  };

  for (let index = 0; index < argv.length; index += 1) {
    const arg = argv[index];
    if (arg === "--check") parsed.check = true;
    else if (arg === "--help" || arg === "-h") parsed.help = true;
    else if (arg === "--output") parsed.output = requiredValue(argv, ++index, arg);
    else if (arg === "--root") parsed.roots.push(requiredValue(argv, ++index, arg));
    else fail(`Unknown argument: ${arg}`);
  }

  return parsed;
}

function requiredValue(argv, index, flag) {
  const value = argv[index];
  if (!value || value.startsWith("--")) fail(`${flag} requires a value.`);
  return value;
}

function stableStringify(value) {
  return JSON.stringify(sortValue(value), null, 2);
}

function sortValue(value) {
  if (Array.isArray(value)) return value.map(sortValue);
  if (!value || typeof value !== "object") return value;
  return Object.fromEntries(
    Object.entries(value)
      .sort(([a], [b]) => a.localeCompare(b))
      .map(([key, nested]) => [key, sortValue(nested)])
  );
}

function relative(file) {
  return path.relative(repoRoot, file).replaceAll("\\", "/");
}

function fail(message) {
  console.error(message);
  process.exit(1);
}

function printHelp() {
  console.log(`Usage: node tool/organizer_intake/plan_raw_artifact_storage.mjs [options]

Options:
  --check           Check generated raw artifact storage manifest drift.
  --output <path>   Write or check a specific output path.
  --root <path>     Scan an additional/specific artifact root. Repeatable.
`);
}
