#!/usr/bin/env node
import crypto from "node:crypto";
import fs from "node:fs";
import path from "node:path";
import {fromRepo, relativeToRepo} from "../lib/repo_paths.mjs";

const sourceManifestPath = fromRepo("tool/marketing/capture_manifest.json");
const websitePublicPrefix = "website/public/";
const websiteScreenshotPrefix = `${websitePublicPrefix}assets/app-screenshots/`;
const websiteManifestPath = fromRepo(`${websiteScreenshotPrefix}manifest.json`);
const allowedStatuses = new Set(["active", "pending-fixture", "paused"]);
const args = process.argv.slice(2);
const command = args[0] ?? "--help";

if (command === "--help" || command === "-h" || command === "help") {
  printHelp();
} else if (command === "--list" || command === "list") {
  listCaptures(loadSourceManifest());
} else if (command === "--update" || command === "update") {
  updateWebsiteMedia(loadSourceManifest());
} else if (command === "--check" || command === "check") {
  checkWebsiteMedia(loadSourceManifest());
} else {
  console.error(`Unknown command: ${command}`);
  printHelp();
  process.exit(64);
}

function loadSourceManifest() {
  return readJson(sourceManifestPath);
}

function listCaptures(manifest) {
  validateSourceManifest(manifest);
  for (const capture of manifest.captures) {
    console.log(
      `${capture.id.padEnd(28)} ${capture.status.padEnd(16)} ${capture.surface}`
    );
  }
}

function updateWebsiteMedia(manifest) {
  const errors = validateSourceManifest(manifest);
  if (errors.length > 0) fail("Marketing capture manifest is invalid.", errors);

  for (const capture of manifest.captures) {
    if (capture.status !== "active") continue;
    const sourcePath = fromRepo(capture.sourcePath);
    const targetPath = fromRepo(capture.websitePath);
    fs.mkdirSync(path.dirname(targetPath), {recursive: true});
    fs.copyFileSync(sourcePath, targetPath);
  }

  const websiteManifest = buildWebsiteManifest(manifest);
  writeJson(websiteManifestPath, websiteManifest);
  console.log(
    `Synced ${websiteManifest.captures.length} marketing capture records to ${relativeToRepo(
      websiteManifestPath
    )}.`
  );
}

function checkWebsiteMedia(manifest) {
  const errors = validateSourceManifest(manifest);
  if (!fs.existsSync(websiteManifestPath)) {
    errors.push(
      `${relativeToRepo(websiteManifestPath)} is missing; run node tool/marketing/sync_website_media.mjs --update.`
    );
  }

  if (errors.length > 0) fail("Marketing website media check failed.", errors);

  const expected = stableJson(buildWebsiteManifest(manifest));
  const actual = fs.readFileSync(websiteManifestPath, "utf8");
  if (actual !== expected) {
    fail("Marketing website media manifest is stale.", [
      "Run node tool/marketing/sync_website_media.mjs --update and commit the result.",
    ]);
  }

  console.log("Marketing website media is in sync.");
}

function validateSourceManifest(manifest) {
  const errors = [];
  if (!manifest || typeof manifest !== "object") {
    return ["tool/marketing/capture_manifest.json must contain an object."];
  }
  if (!Number.isInteger(manifest.version)) {
    errors.push("Manifest version must be an integer.");
  }
  if (!Array.isArray(manifest.captures)) {
    errors.push("Manifest captures must be an array.");
    return errors;
  }

  const ids = new Set();
  for (const capture of manifest.captures) {
    const label = capture && capture.id ? capture.id : "<missing id>";
    if (!capture || typeof capture !== "object") {
      errors.push("Every capture entry must be an object.");
      continue;
    }
    if (!/^[a-z0-9]+(?:-[a-z0-9]+)*$/.test(capture.id ?? "")) {
      errors.push(`${label}: id must be lowercase kebab-case.`);
    }
    if (ids.has(capture.id)) errors.push(`${label}: duplicate id.`);
    ids.add(capture.id);

    for (const key of [
      "audience",
      "surface",
      "device",
      "fixtureKey",
      "sourcePath",
      "websitePath",
      "placeholderPath",
      "alt",
      "caption",
      "walkthroughStep",
    ]) {
      if (typeof capture[key] !== "string" || capture[key].trim() === "") {
        errors.push(`${label}: ${key} is required.`);
      }
    }

    if (!allowedStatuses.has(capture.status)) {
      errors.push(
        `${label}: status must be one of ${[...allowedStatuses].join(", ")}.`
      );
    }

    const websitePath = capture.websitePath ?? "";
    if (!websitePath.startsWith(websiteScreenshotPrefix)) {
      errors.push(
        `${label}: websitePath must stay under ${websiteScreenshotPrefix}.`
      );
    }
    if (websitePath.includes("/placeholders/")) {
      errors.push(`${label}: websitePath must not point at a placeholder.`);
    }

    if (capture.status === "active") {
      requireFile(errors, label, "sourcePath", capture.sourcePath);
    } else if (capture.status === "pending-fixture") {
      requireFile(errors, label, "placeholderPath", capture.placeholderPath);
    }
  }
  return errors;
}

function buildWebsiteManifest(manifest) {
  const captures = manifest.captures
    .filter((capture) => capture.status !== "paused")
    .map((capture) => {
      const isActive = capture.status === "active";
      const sourcePath = isActive ? capture.sourcePath : capture.placeholderPath;
      const sourceAbs = fromRepo(sourcePath);
      const webPath = toWebPath(isActive ? capture.websitePath : sourcePath);
      const hash = sha256(sourceAbs);
      return {
        id: capture.id,
        audience: capture.audience,
        surface: capture.surface,
        device: capture.device,
        webPath,
        alt: capture.alt,
        caption: capture.caption,
        walkthroughStep: capture.walkthroughStep,
      };
    });

  return {
    version: manifest.version,
    updated: manifest.updated,
    captures,
  };
}

function requireFile(errors, label, key, repoPath) {
  if (typeof repoPath !== "string" || repoPath.trim() === "") return;
  if (!fs.existsSync(fromRepo(repoPath))) {
    errors.push(`${label}: ${key} is missing at ${repoPath}.`);
  }
}

function toWebPath(repoPath) {
  const normalized = repoPath.replaceAll(path.sep, "/");
  if (!normalized.startsWith(websitePublicPrefix)) {
    throw new Error(`Cannot expose non-website asset path: ${repoPath}`);
  }
  return `/${normalized.slice(websitePublicPrefix.length)}`;
}

function readJson(filePath) {
  return JSON.parse(fs.readFileSync(filePath, "utf8"));
}

function writeJson(filePath, value) {
  fs.mkdirSync(path.dirname(filePath), {recursive: true});
  fs.writeFileSync(filePath, stableJson(value));
}

function stableJson(value) {
  return `${JSON.stringify(value, null, 2)}\n`;
}

function sha256(filePath) {
  return crypto.createHash("sha256").update(fs.readFileSync(filePath)).digest("hex");
}

function fail(title, errors) {
  console.error(title);
  for (const error of errors) console.error(`- ${error}`);
  process.exit(1);
}

function printHelp() {
  console.log(`Usage: node tool/marketing/sync_website_media.mjs <command>

Commands:
  --list     Show capture slots and lifecycle status.
  --update   Copy active app captures into website assets and write manifest.
  --check    Verify active captures and generated website manifest are current.

Capture statuses:
  pending-fixture  Website uses a checked-in placeholder until synthetic data exists.
  active           sourcePath is required and must match the website asset bytes.
  paused           Excluded from the generated website manifest.
`);
}
