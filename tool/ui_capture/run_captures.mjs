#!/usr/bin/env node
import fs from "node:fs";
import {spawnSync} from "node:child_process";
import {fromRepo, repoRoot} from "../lib/repo_paths.mjs";

const args = process.argv.slice(2);
const catalogPath = fromRepo("test/ui_captures/catalog/screen_capture_catalog.dart");

if (args.includes("--help") || args.includes("-h")) {
  printHelp();
  process.exit(0);
}

const idsArg = valueAfter("--ids");
const ids =
  args.includes("--all") || idsArg === "all" ? readCatalogIds().join(",") : idsArg ?? "profile_self";
const outputDir = valueAfter("--output-dir") ?? "artifacts/ui-captures/review";
const deviceId = valueAfter("--device");
const textScale = valueAfter("--text-scale");
const testPath = "test/ui_captures/capture_runner_test.dart";

const flutterArgs = [
  "test",
  testPath,
  `--dart-define=CAPTURE_IDS=${ids}`,
  `--dart-define=CAPTURE_OUTPUT_DIR=${outputDir}`,
];
if (deviceId) flutterArgs.push(`--dart-define=CAPTURE_DEVICE_ID=${deviceId}`);
if (textScale) flutterArgs.push(`--dart-define=CAPTURE_TEXT_SCALE=${textScale}`);

console.log(`Rendering UI captures: ${ids}`);
console.log(`Output directory: ${outputDir}`);
if (deviceId) console.log(`Device override: ${deviceId}`);
if (textScale) console.log(`Text scale: ${textScale}`);

const result = spawnSync("flutter", flutterArgs, {
  cwd: repoRoot,
  stdio: "inherit",
});

process.exit(result.status ?? 1);

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

function readCatalogIds() {
  const source = fs.readFileSync(catalogPath, "utf8");
  const ids = [...source.matchAll(/\bScreenCaptureEntry\(\s*id:\s*'([^']+)'/gu)].map(
    (match) => match[1]
  );
  if (ids.length === 0) {
    console.error(`No ScreenCaptureEntry ids found in ${catalogPath}.`);
    process.exit(65);
  }
  return ids;
}

function printHelp() {
  console.log(`Usage: node tool/ui_capture/run_captures.mjs [options]

Options:
  --ids <ids>              Comma-separated capture ids, or "all". Default: profile_self.
  --all                    Render every capture id declared in the catalog.
  --output-dir <path>      Artifact output directory. Default: artifacts/ui-captures/review.
  --device <id>            Override catalog devices, e.g. iphone-17-pro.
  --text-scale <scale>     MediaQuery text scale, e.g. 1.5 or 2.0.

Examples:
  node tool/ui_capture/run_captures.mjs --ids profile_self
  node tool/ui_capture/run_captures.mjs --all
  node tool/ui_capture/run_captures.mjs --ids match_chat_context --device iphone-17-pro
  node tool/ui_capture/run_captures.mjs --ids member_event_discovery --text-scale 2.0
`);
}
