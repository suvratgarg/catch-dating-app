#!/usr/bin/env node
import fs from "node:fs";
import path from "node:path";
import {spawnSync} from "node:child_process";
import {fromRepo, repoRoot} from "../lib/repo_paths.mjs";

const manifestPath = fromRepo("tool/marketing/capture_manifest.json");
const catalogPath = fromRepo("test/ui_captures/catalog/screen_capture_catalog.dart");
const rawOutputDir = "artifacts/marketing/app-screenshots/raw";
const supportedDevices = new Set(["iphone-17-pro"]);
const args = process.argv.slice(2);
const command = args[0] ?? "--help";

if (command === "--help" || command === "-h" || command === "help") {
  printHelp();
} else if (command === "--list" || command === "list") {
  listExports();
} else if (command === "--check" || command === "check") {
  checkExports();
} else if (command === "--design-json" || command === "design-json") {
  printDesignJson();
} else if (command === "--update" || command === "update") {
  updateExports();
} else {
  console.error(`Unknown command: ${command}`);
  printHelp();
  process.exit(64);
}

function listExports() {
  const {manifest, catalog} = loadContext();
  for (const capture of manifest.captures) {
    const entry = findCatalogEntry(catalog, capture.fixtureKey);
    console.log(
      [
        capture.id.padEnd(28),
        capture.status.padEnd(16),
        capture.device.padEnd(14),
        entry ? entry.id : "<missing-catalog>",
      ].join(" ")
    );
  }
}

function checkExports() {
  const {manifest, catalog} = loadContext();
  const errors = validateExports(manifest, catalog, {requireSources: true});
  if (errors.length > 0) fail("Marketing app screenshot export check failed.", errors);
  console.log("Marketing app screenshot exports are ready.");
}

function printDesignJson() {
  const {manifest, catalog} = loadContext();
  const errors = validateExports(manifest, catalog, {requireSources: false});
  if (errors.length > 0) fail("Marketing app design context export failed.", errors);

  const captures = (manifest.captures ?? []).map((capture) => {
    const entry = findCatalogEntry(catalog, capture.fixtureKey);
    const deviceFrame = deviceFrameSpec(capture.device);
    return {
      type: "marketing-app-capture",
      id: capture.id,
      status: capture.status,
      audience: capture.audience,
      surface: capture.surface,
      fixtureKey: capture.fixtureKey,
      captureId: entry?.id ?? null,
      routeIds: entry?.routeIds ?? [],
      device: deviceFrame,
      assets: {
        sourcePath: capture.sourcePath,
        websitePath: capture.websitePath,
        placeholderPath: capture.placeholderPath,
      },
      copy: {
        alt: capture.alt,
        caption: capture.caption,
        walkthroughStep: capture.walkthroughStep,
      },
    };
  });

  console.log(JSON.stringify({
    version: 1,
    generatedBy: "tool/marketing/export_app_screenshots.mjs design-json",
    coordinateSystem: "px",
    description:
      "Figma/AI-friendly design context for app-derived marketing screenshots.",
    captures,
  }, null, 2));
}

function updateExports() {
  const {manifest, catalog} = loadContext();
  const errors = validateExports(manifest, catalog, {requireSources: false});
  if (errors.length > 0) fail("Marketing app screenshot export failed.", errors);

  const selectedCaptures = selectCaptures(manifest);
  if (selectedCaptures.length === 0) {
    console.log("No active marketing captures selected.");
    return;
  }

  const selected = selectedCaptures.map((capture) => ({
    capture,
    entry: findCatalogEntry(catalog, capture.fixtureKey),
  }));
  for (const item of selected) {
    if (!item.entry) {
      fail("Marketing app screenshot export failed.", [
        `${item.capture.id}: fixtureKey ${item.capture.fixtureKey} has no capture catalog entry.`,
      ]);
    }
  }

  const groups = groupBy(selected, (item) => item.capture.device);
  for (const [device, items] of groups) {
    const captureIds = [...new Set(items.map((item) => item.entry.id))];
    const result = spawnSync(
      "node",
      [
        "tool/ui_capture/run_captures.mjs",
        "--ids",
        captureIds.join(","),
        "--output-dir",
        rawOutputDir,
        "--device",
        device,
      ],
      {cwd: repoRoot, stdio: "inherit"}
    );
    if ((result.status ?? 1) !== 0) process.exit(result.status ?? 1);
  }

  for (const {capture, entry} of selected) {
    const inputPath = path.join(rawOutputDir, entry.id, "light.png");
    const result = spawnSync(
      "dart",
      [
        "run",
        "tool/marketing/frame_device_capture.dart",
        "--input",
        inputPath,
        "--output",
        capture.sourcePath,
        "--device",
        capture.device,
      ],
      {cwd: repoRoot, stdio: "inherit"}
    );
    if ((result.status ?? 1) !== 0) process.exit(result.status ?? 1);
  }
}

function validateExports(manifest, catalog, {requireSources}) {
  const errors = [];
  for (const capture of manifest.captures ?? []) {
    if (capture.status !== "active") continue;

    if (!supportedDevices.has(capture.device)) {
      errors.push(
        `${capture.id}: unsupported marketing device ${capture.device}; supported: ${[
          ...supportedDevices,
        ].join(", ")}.`
      );
    }

    const entry = findCatalogEntry(catalog, capture.fixtureKey);
    if (!entry) {
      errors.push(
        `${capture.id}: fixtureKey ${capture.fixtureKey} has no capture catalog entry.`
      );
      continue;
    }

    if (entry.marketingFixtureKeys.filter((key) => key === capture.fixtureKey).length !== 1) {
      errors.push(`${capture.id}: fixtureKey ${capture.fixtureKey} must map once.`);
    }

    if (requireSources && !fs.existsSync(fromRepo(capture.sourcePath))) {
      errors.push(
        `${capture.id}: sourcePath is missing at ${capture.sourcePath}; run node tool/marketing/export_app_screenshots.mjs --update.`
      );
    }
  }
  return errors;
}

function selectCaptures(manifest) {
  const idsArg = valueAfter("--ids");
  const ids = idsArg
    ? new Set(idsArg.split(",").map((id) => id.trim()).filter(Boolean))
    : null;
  const selected = [];
  for (const capture of manifest.captures ?? []) {
    if (capture.status !== "active") continue;
    if (ids && !ids.has(capture.id)) continue;
    selected.push(capture);
  }
  if (ids) {
    const known = new Set((manifest.captures ?? []).map((capture) => capture.id));
    for (const id of ids) {
      if (!known.has(id)) {
        fail("Marketing app screenshot export failed.", [`Unknown capture id: ${id}`]);
      }
    }
  }
  return selected;
}

function loadContext() {
  return {
    manifest: readJson(manifestPath),
    catalog: parseCaptureCatalog(fs.readFileSync(catalogPath, "utf8")),
  };
}

function findCatalogEntry(catalog, fixtureKey) {
  return catalog.find((entry) => entry.marketingFixtureKeys.includes(fixtureKey)) ?? null;
}

function groupBy(values, keyFor) {
  const groups = new Map();
  for (const value of values) {
    const key = keyFor(value);
    const bucket = groups.get(key) ?? [];
    bucket.push(value);
    groups.set(key, bucket);
  }
  return groups;
}

function parseCaptureCatalog(source) {
  const entries = [];
  for (const block of extractCallBlocks(source, "ScreenCaptureEntry")) {
    const id = matchString(block, /\bid:\s*'([^']+)'/u);
    const routeIdsBlock = matchString(block, /\brouteIds:\s*const\s*<String>\s*\[([\s\S]*?)\]/u);
    const marketingBlock = matchString(
      block,
      /\bmarketingFixtureKeys:\s*const\s*<String>\s*\[([\s\S]*?)\]/u
    );
    const deviceToken = matchString(block, /\bdevice:\s*CaptureDevice\.([a-zA-Z0-9_]+)/u);
    if (!id) continue;
    entries.push({
      id,
      routeIds: parseStringList(routeIdsBlock),
      marketingFixtureKeys: parseStringList(marketingBlock),
      device: deviceIdFromToken(deviceToken),
    });
  }
  return entries;
}

function extractCallBlocks(source, callName) {
  const blocks = [];
  let searchIndex = 0;
  while (searchIndex < source.length) {
    const callIndex = source.indexOf(`${callName}(`, searchIndex);
    if (callIndex === -1) break;
    const openIndex = source.indexOf("(", callIndex);
    const endIndex = findBalancedEnd(source, openIndex, "(", ")");
    blocks.push(source.slice(callIndex, endIndex + 1));
    searchIndex = endIndex + 1;
  }
  return blocks;
}

function findBalancedEnd(source, openIndex, openChar, closeChar) {
  let depth = 0;
  let stringQuote = null;
  let escaped = false;
  for (let index = openIndex; index < source.length; index += 1) {
    const char = source[index];
    if (stringQuote) {
      if (escaped) escaped = false;
      else if (char === "\\") escaped = true;
      else if (char === stringQuote) stringQuote = null;
      continue;
    }
    if (char === "'" || char === '"') {
      stringQuote = char;
      continue;
    }
    if (char === openChar) depth += 1;
    if (char === closeChar) {
      depth -= 1;
      if (depth === 0) return index;
    }
  }
  throw new Error(`Could not parse balanced call block starting at ${openIndex}.`);
}

function matchString(value, pattern) {
  return value.match(pattern)?.[1] ?? null;
}

function parseStringList(value) {
  if (!value) return [];
  return [...value.matchAll(/'([^']+)'/gu)].map((match) => match[1]);
}

function deviceIdFromToken(token) {
  if (!token) return null;
  return token
    .replace(/([a-z0-9])([A-Z])/gu, "$1-$2")
    .replace(/([a-z])([0-9])/gu, "$1-$2")
    .toLowerCase();
}

function deviceFrameSpec(deviceId) {
  if (deviceId !== "iphone-17-pro") {
    throw new Error(`Unsupported design metadata device: ${deviceId}`);
  }
  const logicalWidth = 402;
  const logicalHeight = 874;
  const outputScale = 2;
  const canvasMargin = 32;
  const frameInset = 22;
  const screenWidth = logicalWidth * outputScale;
  const screenHeight = logicalHeight * outputScale;
  const framedWidth = screenWidth + (frameInset + canvasMargin) * outputScale * 2;
  const framedHeight = screenHeight + (frameInset + canvasMargin) * outputScale * 2;
  return {
    id: deviceId,
    logicalSize: {width: logicalWidth, height: logicalHeight},
    outputScale,
    safeArea: {top: 59, right: 0, bottom: 34, left: 0},
    frame: {
      framedSize: {width: framedWidth, height: framedHeight},
      canvasMargin: canvasMargin * outputScale,
      frameInset: frameInset * outputScale,
      outerRadius: 68 * outputScale,
      screenRadius: 52 * outputScale,
      dynamicIsland: {
        width: 126 * outputScale,
        height: 37 * outputScale,
        top: 12 * outputScale,
      },
    },
  };
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

function readJson(filePath) {
  return JSON.parse(fs.readFileSync(filePath, "utf8"));
}

function fail(title, errors) {
  console.error(title);
  for (const error of errors) console.error(`- ${error}`);
  process.exit(1);
}

function printHelp() {
  console.log(`Usage: node tool/marketing/export_app_screenshots.mjs <command> [options]

Commands:
  --list             Show marketing slots and catalog mapping.
  --update           Render active app captures and write framed source PNGs.
  --check            Verify active marketing captures have source PNGs.
  --design-json      Print Figma/AI-friendly capture metadata and frame geometry.

Options:
  --ids <ids>        Comma-separated marketing capture ids for --update.

Raw captures are written under ${rawOutputDir}/ and framed source PNGs are
written to each active manifest sourcePath.
`);
}
