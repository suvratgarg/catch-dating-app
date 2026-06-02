#!/usr/bin/env node
import crypto from "node:crypto";
import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import {spawnSync} from "node:child_process";
import {fromRepo, repoRoot} from "../lib/repo_paths.mjs";

const args = process.argv.slice(2);

if (args.includes("--help") || args.includes("-h")) {
  printHelp();
  process.exit(0);
}

const mode = args.includes("--check") ? "check" : "update";
const outputDir = path.resolve(repoRoot, valueAfter("--output-dir") ?? "design_context_pack");
const renderGallery = args.includes("--render-gallery");

if (mode === "check") {
  const tempDir = fs.mkdtempSync(path.join(os.tmpdir(), "catch-design-context-pack-"));
  try {
    buildPack(tempDir, {renderGallery});
    writeManifest(tempDir, {includeGalleryPngs: renderGallery});
    checkPack(tempDir, outputDir, {includeGalleryPngs: renderGallery});
  } finally {
    fs.rmSync(tempDir, {recursive: true, force: true});
  }
} else {
  buildPack(outputDir, {renderGallery});
  writeManifest(outputDir, {includeGalleryPngs: renderGallery});
  console.log(`Wrote ${path.relative(repoRoot, outputDir)}`);
}

function buildPack(targetDir, {renderGallery}) {
  const testResult = spawnSync(
    "flutter",
    [
      "test",
      "tool/design/context_pack_builder_test.dart",
      `--dart-define=DESIGN_CONTEXT_PACK_OUTPUT_DIR=${targetDir}`,
    ],
    {cwd: repoRoot, stdio: "inherit"}
  );
  if (testResult.status !== 0) process.exit(testResult.status ?? 1);

  if (!renderGallery) return;
  const captureResult = spawnSync(
    "node",
    [
      "tool/ui_capture/run_captures.mjs",
      "--profile",
      "design-gallery",
      "--output-dir",
      path.join(targetDir, "gallery"),
    ],
    {cwd: repoRoot, stdio: "inherit"}
  );
  if (captureResult.status !== 0) process.exit(captureResult.status ?? 1);
}

function writeManifest(targetDir, {includeGalleryPngs}) {
  const files = listPackFiles(targetDir, {includeGalleryPngs});
  const manifest = {
    version: 1,
    generatedBy: "tool/design/build_context_pack.mjs",
    includesGalleryPngs: includeGalleryPngs,
    files: files.map((relativePath) => ({
      path: relativePath,
      sha256: sha256(path.join(targetDir, relativePath)),
      bytes: fs.statSync(path.join(targetDir, relativePath)).size,
    })),
  };
  fs.writeFileSync(
    path.join(targetDir, "MANIFEST.json"),
    `${JSON.stringify(manifest, null, 2)}\n`
  );
}

function checkPack(expectedDir, actualDir, {includeGalleryPngs}) {
  if (!fs.existsSync(actualDir)) {
    console.error(`Missing context pack directory: ${path.relative(repoRoot, actualDir)}`);
    process.exit(1);
  }

  const expectedFiles = [...listPackFiles(expectedDir, {includeGalleryPngs}), "MANIFEST.json"].sort();
  const actualFiles = new Set([...listPackFiles(actualDir, {includeGalleryPngs}), "MANIFEST.json"]);
  const failures = [];

  for (const file of expectedFiles) {
    const expectedPath = path.join(expectedDir, file);
    const actualPath = path.join(actualDir, file);
    if (!fs.existsSync(actualPath)) {
      failures.push(`missing ${file}`);
      continue;
    }
    if (!fs.readFileSync(expectedPath).equals(fs.readFileSync(actualPath))) {
      failures.push(`stale ${file}`);
    }
    actualFiles.delete(file);
  }

  for (const extra of [...actualFiles].sort()) {
    if (!includeGalleryPngs && extra.startsWith("gallery/") && extra.endsWith(".png")) {
      continue;
    }
    failures.push(`extra ${extra}`);
  }

  if (failures.length > 0) {
    console.error("Design context pack check failed:");
    for (const failure of failures) console.error(`- ${failure}`);
    console.error("Run: node tool/design/build_context_pack.mjs");
    process.exit(1);
  }

  console.log("Design context pack check passed.");
}

function listPackFiles(root, {includeGalleryPngs}) {
  if (!fs.existsSync(root)) return [];
  const files = [];
  walk(root, files);
  return files
    .map((file) => path.relative(root, file).split(path.sep).join("/"))
    .filter((file) => file !== "MANIFEST.json")
    .filter((file) => !file.endsWith(".DS_Store"))
    .filter((file) => includeGalleryPngs || !file.endsWith(".png"))
    .sort();
}

function walk(dir, files) {
  for (const entry of fs.readdirSync(dir, {withFileTypes: true})) {
    const fullPath = path.join(dir, entry.name);
    if (entry.isDirectory()) walk(fullPath, files);
    else if (entry.isFile()) files.push(fullPath);
  }
}

function sha256(file) {
  return crypto.createHash("sha256").update(fs.readFileSync(file)).digest("hex");
}

function valueAfter(flag) {
  const index = args.indexOf(flag);
  if (index === -1) return null;
  const value = args[index + 1];
  if (!value || value.startsWith("--")) {
    console.error(`${flag} requires a value.`);
    process.exit(64);
  }
  return value;
}

function printHelp() {
  console.log(`Usage: node tool/design/build_context_pack.mjs [options]

Options:
  --check                 Rebuild in a temp dir and fail if committed files are stale.
  --output-dir <path>     Output directory. Default: design_context_pack.
  --render-gallery        Also render high-DPR gallery PNGs via ui-capture.

Examples:
  node tool/design/build_context_pack.mjs
  node tool/design/build_context_pack.mjs --check
  node tool/design/build_context_pack.mjs --render-gallery
`);
}
