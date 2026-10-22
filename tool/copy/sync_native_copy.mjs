#!/usr/bin/env node
import fs from "node:fs";
import path from "node:path";
import {fromRepo, relativeToRepo} from "../lib/repo_paths.mjs";

const catalogPath = fromRepo("copy/native_en.json");
// Each iOS project reads the permission prose of the app role it ships.
const iosTargets = [
  {role: "consumer", runner: "ios/Runner"},
  {role: "consumer", runner: "apps/consumer/ios/Runner"},
  {role: "host", runner: "apps/host/ios/Runner"},
];

const write = process.argv.includes("--write");
const catalog = JSON.parse(fs.readFileSync(catalogPath, "utf8"));
validateCatalog(catalog);

const drift = [];
let messageCount = 0;
for (const target of iosTargets) {
  const entries = catalog.iosInfoPlist[target.role];
  const plistPath = fromRepo(target.runner, "Info.plist");
  const stringsPath = fromRepo(target.runner, "en.lproj/InfoPlist.strings");
  const actualPlist = fs.readFileSync(plistPath, "utf8");
  const expectedPlist = renderInfoPlist(actualPlist, entries, plistPath);
  const expectedStrings = renderInfoPlistStrings(entries);
  messageCount += Object.keys(entries).length;

  if (write) {
    fs.mkdirSync(path.dirname(stringsPath), {recursive: true});
    fs.writeFileSync(plistPath, expectedPlist);
    fs.writeFileSync(stringsPath, expectedStrings);
    continue;
  }
  const actualStrings = fs.existsSync(stringsPath)
    ? fs.readFileSync(stringsPath, "utf8")
    : "";
  if (actualPlist !== expectedPlist) drift.push(relativeToRepo(plistPath));
  if (actualStrings !== expectedStrings) drift.push(relativeToRepo(stringsPath));
}

if (write) {
  console.log("Synchronized native English copy into the iOS bundle resources.");
} else if (drift.length > 0) {
  console.error(
    `Native copy drift: ${drift.join(", ")}. Run node tool/copy/sync_native_copy.mjs --write.`,
  );
  process.exitCode = 1;
} else {
  console.log(
    `Native copy valid: ${messageCount} iOS permission messages across ${iosTargets.length} projects.`,
  );
}

function validateCatalog(value) {
  if (
    value?.version !== 2 ||
    value?.locale !== "en" ||
    !value.iosInfoPlist ||
    typeof value.iosInfoPlist !== "object"
  ) {
    throw new Error("copy/native_en.json must be a version 2 English native catalog.");
  }
  const roles = new Set(iosTargets.map((target) => target.role));
  const catalogRoles = Object.keys(value.iosInfoPlist);
  if (
    catalogRoles.length !== roles.size ||
    !catalogRoles.every((role) => roles.has(role))
  ) {
    throw new Error(
      `copy/native_en.json must declare iOS permission copy for exactly: ${[...roles].join(", ")}.`,
    );
  }
  for (const [role, entries] of Object.entries(value.iosInfoPlist)) {
    for (const [key, message] of Object.entries(entries ?? {})) {
      if (!key.endsWith("UsageDescription") || typeof message !== "string" || !message.trim()) {
        throw new Error(`Invalid ${role} native copy entry: ${key}.`);
      }
    }
  }
}

// The catalog owns every permission key: declared values are projected and any
// undeclared purpose string is removed, so a role cannot inherit another
// role's permissions by copy.
function renderInfoPlist(source, entries, plistPath) {
  let rendered = source;
  for (const key of usageDescriptionKeys(source)) {
    if (Object.hasOwn(entries, key)) continue;
    rendered = rendered.replace(
      new RegExp(`\\n[\\t ]*<key>${escapeRegex(key)}</key>\\s*<string>[\\s\\S]*?</string>`),
      "",
    );
  }
  for (const [key, value] of Object.entries(entries)) {
    const pattern = new RegExp(
      `(\\s*<key>${escapeRegex(key)}</key>\\s*<string>)[\\s\\S]*?(</string>)`,
    );
    if (!pattern.test(rendered)) {
      throw new Error(`${relativeToRepo(plistPath)} is missing ${key}.`);
    }
    rendered = rendered.replace(pattern, `$1${escapeXml(value)}$2`);
  }
  return rendered;
}

function usageDescriptionKeys(source) {
  return [...source.matchAll(/<key>([A-Za-z]+UsageDescription)<\/key>/g)].map(
    (match) => match[1],
  );
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
