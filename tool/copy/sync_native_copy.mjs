#!/usr/bin/env node
import fs from "node:fs";
import {fromRepo, relativeToRepo} from "../lib/repo_paths.mjs";

const catalogPath = fromRepo("copy/native_en.json");
const plistPath = fromRepo("ios/Runner/Info.plist");
const stringsPath = fromRepo("ios/Runner/en.lproj/InfoPlist.strings");

const write = process.argv.includes("--write");
const catalog = JSON.parse(fs.readFileSync(catalogPath, "utf8"));
validateCatalog(catalog);

const expectedStrings = renderInfoPlistStrings(catalog.iosInfoPlist);
let expectedPlist = fs.readFileSync(plistPath, "utf8");
for (const [key, value] of Object.entries(catalog.iosInfoPlist)) {
  const pattern = new RegExp(
    `(\\s*<key>${escapeRegex(key)}</key>\\s*<string>)[\\s\\S]*?(</string>)`,
  );
  if (!pattern.test(expectedPlist)) {
    throw new Error(`${relativeToRepo(plistPath)} is missing ${key}.`);
  }
  expectedPlist = expectedPlist.replace(pattern, `$1${escapeXml(value)}$2`);
}

if (write) {
  fs.mkdirSync(new URL("../../ios/Runner/en.lproj/", import.meta.url), {
    recursive: true,
  });
  fs.writeFileSync(plistPath, expectedPlist);
  fs.writeFileSync(stringsPath, expectedStrings);
  console.log("Synchronized native English copy into the iOS bundle resources.");
} else {
  const actualPlist = fs.readFileSync(plistPath, "utf8");
  const actualStrings = fs.existsSync(stringsPath)
    ? fs.readFileSync(stringsPath, "utf8")
    : "";
  const drift = [];
  if (actualPlist !== expectedPlist) drift.push(relativeToRepo(plistPath));
  if (actualStrings !== expectedStrings) drift.push(relativeToRepo(stringsPath));
  if (drift.length > 0) {
    console.error(
      `Native copy drift: ${drift.join(", ")}. Run node tool/copy/sync_native_copy.mjs --write.`,
    );
    process.exitCode = 1;
  } else {
    console.log(
      `Native copy valid: ${Object.keys(catalog.iosInfoPlist).length} iOS permission messages.`,
    );
  }
}

function validateCatalog(value) {
  if (
    value?.version !== 1 ||
    value?.locale !== "en" ||
    !value.iosInfoPlist ||
    typeof value.iosInfoPlist !== "object"
  ) {
    throw new Error("copy/native_en.json must be a version 1 English native catalog.");
  }
  for (const [key, message] of Object.entries(value.iosInfoPlist)) {
    if (!key.endsWith("UsageDescription") || typeof message !== "string" || !message.trim()) {
      throw new Error(`Invalid native copy entry: ${key}.`);
    }
  }
}

function renderInfoPlistStrings(entries) {
  const lines = [
    "/* Generated from copy/native_en.json. Edit the catalog, then run the native copy sync. */",
  ];
  for (const key of Object.keys(entries).sort((a, b) => a.localeCompare(b))) {
    lines.push(`"${key}" = "${escapeStrings(entries[key])}";`);
  }
  return `${lines.join("\n")}\n`;
}

function escapeStrings(value) {
  return value.replaceAll("\\", "\\\\").replaceAll('"', '\\"');
}

function escapeXml(value) {
  return value
    .replaceAll("&", "&amp;")
    .replaceAll("<", "&lt;")
    .replaceAll(">", "&gt;");
}

function escapeRegex(value) {
  return value.replace(/[.*+?^${}()|[\]\\]/g, "\\$&");
}
