#!/usr/bin/env node

import fs from "node:fs";
import path from "node:path";
import {fileURLToPath} from "node:url";
import {
  repoRoot as defaultRepoRoot,
} from "../lib/repo_paths.mjs";

const defaultArbRelativePath = "lib/l10n/app_en.arb";
const defaultSourceRootRelativePath = "lib";
const defaultBaselineRelativePath = "tool/copy/l10n_orphan_baseline.json";
const defaultInventoryRelativePath =
  "docs/audit_registry/l10n_key_usage.json";

const generatedSuffixPattern =
  /\.(?:freezed|g|gen|gr|mocks)\.dart$/u;
const generatedHeaderPattern =
  /(?:GENERATED CODE\s*-\s*DO NOT (?:EDIT|MODIFY)|DO NOT MODIFY BY HAND)/iu;
const dartIdentifierPattern = /^[A-Za-z_$][A-Za-z0-9_$]*$/u;

const isCliEntrypoint =
  process.argv[1] != null &&
  path.resolve(process.argv[1]) === fileURLToPath(import.meta.url);

if (isCliEntrypoint) {
  try {
    runCli();
  } catch (error) {
    console.error(error instanceof Error ? error.message : String(error));
    process.exitCode = error instanceof CliUsageError ? 64 : 1;
  }
}

export function scanL10nKeyUsage({
  repoRoot = defaultRepoRoot,
  arbPath = path.join(repoRoot, defaultArbRelativePath),
  sourceRoot = path.join(repoRoot, defaultSourceRootRelativePath),
} = {}) {
  const resolvedRepoRoot = path.resolve(repoRoot);
  const resolvedArbPath = path.resolve(arbPath);
  const resolvedSourceRoot = path.resolve(sourceRoot);
  const catalog = parseArbCatalog(
    fs.readFileSync(resolvedArbPath, "utf8"),
    displayPath(resolvedArbPath, resolvedRepoRoot),
  );
  const catalogKeySet = new Set(catalog.keys);
  const usagesByKey = new Map(catalog.keys.map((key) => [key, []]));
  const scannedFiles = [];
  const excludedFiles = [];

  for (const filePath of collectDartFiles(resolvedSourceRoot)) {
    const source = fs.readFileSync(filePath, "utf8");
    const relativePath = displayPath(filePath, resolvedRepoRoot);
    const exclusionReason = generatedFileExclusionReason({
      relativePath,
      source,
    });
    if (exclusionReason != null) {
      excludedFiles.push({path: relativePath, reason: exclusionReason});
      continue;
    }

    scannedFiles.push(relativePath);
    const lineStarts = lineStartOffsets(source);
    for (const token of tokenizeDartIdentifiers(source)) {
      if (!catalogKeySet.has(token.identifier)) continue;
      const location = lineColumnForOffset(lineStarts, token.offset);
      usagesByKey.get(token.identifier).push({
        path: relativePath,
        line: location.line,
        column: location.column,
      });
    }
  }

  const keys = catalog.keys.map((key) => {
    const usages = usagesByKey.get(key);
    return {
      key,
      status: usages.length === 0 ? "orphaned" : "used",
      usageCount: usages.length,
      usages,
    };
  });
  const orphanedKeys = keys
    .filter((entry) => entry.status === "orphaned")
    .map((entry) => entry.key);
  const usageReferenceCount = keys.reduce(
    (total, entry) => total + entry.usageCount,
    0,
  );
  const inventory = {
    schemaVersion: 1,
    generatedBy: "node tool/copy/check_l10n_key_usage.mjs",
    catalog: displayPath(resolvedArbPath, resolvedRepoRoot),
    sourceRoot: displayPath(resolvedSourceRoot, resolvedRepoRoot),
    scope: {
      included: "exact ARB-key identifiers in handwritten production Dart",
      excluded: [
        "Dart files under generated directories",
        "lib/l10n/generated/**",
        "*.g.dart, *.freezed.dart, *.gen.dart, *.gr.dart, and *.mocks.dart",
        "Dart files with a generated-code do-not-edit header",
        "comments and non-interpolated string contents",
      ],
    },
    summary: {
      catalogKeys: keys.length,
      usedKeys: keys.length - orphanedKeys.length,
      orphanedKeys: orphanedKeys.length,
      usageReferences: usageReferenceCount,
      scannedDartFiles: scannedFiles.length,
      excludedGeneratedDartFiles: excludedFiles.length,
    },
    orphanedKeys,
    keys,
  };

  return {
    inventory,
    orphanedKeys,
    scannedFiles,
    excludedFiles,
  };
}

export function parseArbCatalog(source, label = "ARB catalog") {
  let value;
  try {
    value = JSON.parse(source);
  } catch (error) {
    throw new Error(
      `${label} is not valid JSON: ${
        error instanceof Error ? error.message : String(error)
      }`,
    );
  }
  if (value == null || typeof value !== "object" || Array.isArray(value)) {
    throw new Error(`${label} must be a JSON object.`);
  }

  const keys = Object.keys(value)
    .filter((key) => !key.startsWith("@"))
    .sort(compareText);
  for (const key of keys) {
    if (!dartIdentifierPattern.test(key)) {
      throw new Error(
        `${label} key ${JSON.stringify(key)} is not a Dart identifier.`,
      );
    }
    if (typeof value[key] !== "string") {
      throw new Error(
        `${label} message ${JSON.stringify(key)} must be a string.`,
      );
    }
  }
  return {keys, value};
}

export function tokenizeDartIdentifiers(source) {
  const tokens = [];

  function addToken(start, end) {
    tokens.push({identifier: source.slice(start, end), offset: start});
  }

  function scanCode(start, stopAtInterpolationBrace = false) {
    let index = start;
    let nestedBraceDepth = 0;
    while (index < source.length) {
      const character = source[index];
      const next = source[index + 1];

      if (stopAtInterpolationBrace && character === "}") {
        if (nestedBraceDepth === 0) return index + 1;
        nestedBraceDepth -= 1;
        index += 1;
        continue;
      }
      if (stopAtInterpolationBrace && character === "{") {
        nestedBraceDepth += 1;
        index += 1;
        continue;
      }

      if (character === "/" && next === "/") {
        index = skipLineComment(source, index + 2);
        continue;
      }
      if (character === "/" && next === "*") {
        index = skipBlockComment(source, index + 2);
        continue;
      }

      if (
        (character === "r" || character === "R") &&
        isQuote(source[index + 1])
      ) {
        index = scanString(index + 1, true);
        continue;
      }
      if (isQuote(character)) {
        index = scanString(index, false);
        continue;
      }

      if (isIdentifierStart(character)) {
        const tokenStart = index;
        index += 1;
        while (isIdentifierPart(source[index])) index += 1;
        addToken(tokenStart, index);
        continue;
      }

      index += 1;
    }
    return index;
  }

  function scanString(quoteIndex, raw) {
    const quote = source[quoteIndex];
    const triple =
      source[quoteIndex + 1] === quote && source[quoteIndex + 2] === quote;
    const delimiterLength = triple ? 3 : 1;
    let index = quoteIndex + delimiterLength;

    while (index < source.length) {
      if (source[index] === quote) {
        if (!triple || source.slice(index, index + 3) === quote.repeat(3)) {
          return index + delimiterLength;
        }
      }
      if (!raw && source[index] === "\\") {
        index += Math.min(2, source.length - index);
        continue;
      }
      if (!raw && source[index] === "$") {
        if (source[index + 1] === "{") {
          index = scanCode(index + 2, true);
          continue;
        }
        if (isInterpolationIdentifierStart(source[index + 1])) {
          const tokenStart = index + 1;
          index = tokenStart + 1;
          while (isIdentifierPart(source[index])) index += 1;
          addToken(tokenStart, index);
          continue;
        }
      }
      index += 1;
    }
    return index;
  }

  scanCode(0);
  return tokens;
}

export function evaluateOrphanRatchet(orphanedKeys, baseline) {
  const current = [...new Set(orphanedKeys)].sort(compareText);
  const allowed = [...new Set(baseline.allowedOrphanedKeys ?? [])].sort(
    compareText,
  );
  const currentSet = new Set(current);
  const allowedSet = new Set(allowed);
  const newOrphanedKeys = current.filter((key) => !allowedSet.has(key));
  const baselineOrphanedKeys = current.filter((key) => allowedSet.has(key));
  const resolvedBaselineKeys = allowed.filter((key) => !currentSet.has(key));
  return {
    passed: newOrphanedKeys.length === 0,
    newOrphanedKeys,
    baselineOrphanedKeys,
    resolvedBaselineKeys,
  };
}

export function baselineFromOrphans(orphanedKeys) {
  return {
    version: 1,
    generatedBy: "node tool/copy/check_l10n_key_usage.mjs --write-baseline",
    checkCommand:
      "node tool/copy/check_l10n_key_usage.mjs --check --check-inventory",
    refreshCommand:
      "node tool/copy/check_l10n_key_usage.mjs --write-baseline",
    description:
      "Existing orphaned Flutter ARB keys. Normal checks fail only when a newly orphaned key is not listed here; this list may only shrink.",
    allowedOrphanedKeys: [...new Set(orphanedKeys)].sort(compareText),
  };
}

export function readOrphanBaseline(filePath) {
  if (!fs.existsSync(filePath)) {
    return baselineFromOrphans([]);
  }
  const value = JSON.parse(fs.readFileSync(filePath, "utf8"));
  if (
    value == null ||
    typeof value !== "object" ||
    Array.isArray(value) ||
    value.version !== 1 ||
    !Array.isArray(value.allowedOrphanedKeys)
  ) {
    throw new Error(
      `${filePath} must be a version 1 l10n orphan baseline with allowedOrphanedKeys.`,
    );
  }
  const seen = new Set();
  for (const [index, key] of value.allowedOrphanedKeys.entries()) {
    if (typeof key !== "string" || !dartIdentifierPattern.test(key)) {
      throw new Error(
        `${filePath} allowedOrphanedKeys[${index}] must be a Dart identifier.`,
      );
    }
    if (seen.has(key)) {
      throw new Error(`${filePath} contains duplicate orphan key ${key}.`);
    }
    seen.add(key);
  }
  return value;
}

export function stableJson(value) {
  return `${JSON.stringify(value, null, 2)}\n`;
}

export function checkInventoryFile(inventory, inventoryPath) {
  if (!fs.existsSync(inventoryPath)) {
    return {current: false, reason: "missing"};
  }
  const expected = stableJson(inventory);
  const actual = fs.readFileSync(inventoryPath, "utf8");
  return {
    current: actual === expected,
    reason: actual === expected ? null : "stale",
  };
}

function generatedFileExclusionReason({relativePath, source}) {
  const normalizedPath = normalizePath(relativePath);
  if (normalizedPath.startsWith("lib/l10n/generated/")) {
    return "l10n-generated-directory";
  }
  if (normalizedPath.split("/").includes("generated")) {
    return "generated-directory";
  }
  if (generatedSuffixPattern.test(normalizedPath)) {
    return "generated-suffix";
  }
  const header = source.split(/\r?\n/u, 8).join("\n");
  if (generatedHeaderPattern.test(header)) {
    return "generated-header";
  }
  return null;
}

function collectDartFiles(root) {
  if (!fs.existsSync(root)) {
    throw new Error(`Dart source root does not exist: ${root}`);
  }
  const files = [];
  walk(root, files);
  return files
    .filter((filePath) => filePath.endsWith(".dart"))
    .sort(compareText);
}

function walk(directory, files) {
  for (const entry of fs
    .readdirSync(directory, {withFileTypes: true})
    .sort((a, b) => compareText(a.name, b.name))) {
    const filePath = path.join(directory, entry.name);
    if (entry.isDirectory()) walk(filePath, files);
    else if (entry.isFile()) files.push(filePath);
  }
}

function skipLineComment(source, start) {
  const newline = source.indexOf("\n", start);
  return newline === -1 ? source.length : newline + 1;
}

function skipBlockComment(source, start) {
  let index = start;
  let depth = 1;
  while (index < source.length && depth > 0) {
    if (source[index] === "/" && source[index + 1] === "*") {
      depth += 1;
      index += 2;
    } else if (source[index] === "*" && source[index + 1] === "/") {
      depth -= 1;
      index += 2;
    } else {
      index += 1;
    }
  }
  return index;
}

function lineStartOffsets(source) {
  const starts = [0];
  for (let index = 0; index < source.length; index += 1) {
    if (source.charCodeAt(index) === 10) starts.push(index + 1);
  }
  return starts;
}

function lineColumnForOffset(lineStarts, offset) {
  let low = 0;
  let high = lineStarts.length;
  while (low + 1 < high) {
    const middle = Math.floor((low + high) / 2);
    if (lineStarts[middle] <= offset) low = middle;
    else high = middle;
  }
  return {line: low + 1, column: offset - lineStarts[low] + 1};
}

function isQuote(character) {
  return character === "'" || character === '"';
}

function isIdentifierStart(character) {
  return character != null && /[A-Za-z_$]/u.test(character);
}

function isInterpolationIdentifierStart(character) {
  return character != null && /[A-Za-z_]/u.test(character);
}

function isIdentifierPart(character) {
  return character != null && /[A-Za-z0-9_$]/u.test(character);
}

function compareText(a, b) {
  return a < b ? -1 : a > b ? 1 : 0;
}

function normalizePath(value) {
  return value.split(path.sep).join("/");
}

function displayPath(filePath, repoRoot) {
  const relativePath = path.relative(repoRoot, filePath);
  if (
    relativePath === "" ||
    (!relativePath.startsWith(`..${path.sep}`) && relativePath !== "..")
  ) {
    return normalizePath(relativePath || ".");
  }
  return normalizePath(path.resolve(filePath));
}

function parseArgs(argv) {
  const parsed = {
    arb: defaultArbRelativePath,
    baseline: defaultBaselineRelativePath,
    check: false,
    checkInventory: false,
    help: false,
    inventory: defaultInventoryRelativePath,
    json: false,
    repoRoot: defaultRepoRoot,
    sourceRoot: defaultSourceRootRelativePath,
    writeBaseline: false,
    writeInventory: false,
  };
  for (let index = 0; index < argv.length; index += 1) {
    const argument = argv[index];
    if (argument === "--arb") parsed.arb = requiredValue(argv, ++index, argument);
    else if (argument === "--baseline") {
      parsed.baseline = requiredValue(argv, ++index, argument);
    } else if (argument === "--check") parsed.check = true;
    else if (argument === "--check-inventory") parsed.checkInventory = true;
    else if (argument === "--help" || argument === "-h") parsed.help = true;
    else if (argument === "--inventory") {
      parsed.inventory = requiredValue(argv, ++index, argument);
    } else if (argument === "--json") parsed.json = true;
    else if (argument === "--repo-root") {
      parsed.repoRoot = path.resolve(requiredValue(argv, ++index, argument));
    } else if (argument === "--source-root") {
      parsed.sourceRoot = requiredValue(argv, ++index, argument);
    } else if (argument === "--write-baseline") parsed.writeBaseline = true;
    else if (argument === "--write-inventory") parsed.writeInventory = true;
    else throw new CliUsageError(`Unknown argument: ${argument}`);
  }

  if (parsed.writeBaseline && parsed.writeInventory) {
    throw new CliUsageError(
      "--write-baseline and --write-inventory must run as separate review steps.",
    );
  }
  if (
    (parsed.writeBaseline || parsed.writeInventory) &&
    (parsed.check || parsed.checkInventory)
  ) {
    throw new CliUsageError(
      "Write modes cannot be combined with --check or --check-inventory.",
    );
  }
  return parsed;
}

function requiredValue(argv, index, flag) {
  const value = argv[index];
  if (value == null || value.startsWith("--")) {
    throw new CliUsageError(`${flag} requires a value.`);
  }
  return value;
}

function resolveFromRoot(root, value) {
  return path.isAbsolute(value) ? path.resolve(value) : path.resolve(root, value);
}

function runCli() {
  const args = parseArgs(process.argv.slice(2));
  if (args.help) {
    printHelp();
    return;
  }

  const repoRoot = path.resolve(args.repoRoot);
  const arbPath = resolveFromRoot(repoRoot, args.arb);
  const sourceRoot = resolveFromRoot(repoRoot, args.sourceRoot);
  const baselinePath = resolveFromRoot(repoRoot, args.baseline);
  const inventoryPath = resolveFromRoot(repoRoot, args.inventory);
  const result = scanL10nKeyUsage({repoRoot, arbPath, sourceRoot});

  if (args.writeBaseline) {
    if (fs.existsSync(baselinePath)) {
      const currentBaseline = readOrphanBaseline(baselinePath);
      const refreshCheck = evaluateOrphanRatchet(
        result.orphanedKeys,
        currentBaseline,
      );
      if (!refreshCheck.passed) {
        throw new Error(
          "Refusing to grow the l10n orphan baseline with new key(s): " +
            refreshCheck.newOrphanedKeys.join(", "),
        );
      }
    }
    const baseline = baselineFromOrphans(result.orphanedKeys);
    fs.mkdirSync(path.dirname(baselinePath), {recursive: true});
    fs.writeFileSync(baselinePath, stableJson(baseline));
    console.log(
      `Wrote l10n orphan baseline with ${baseline.allowedOrphanedKeys.length} key(s): ${displayPath(baselinePath, repoRoot)}`,
    );
    return;
  }

  if (args.writeInventory) {
    fs.mkdirSync(path.dirname(inventoryPath), {recursive: true});
    fs.writeFileSync(inventoryPath, stableJson(result.inventory));
    console.log(
      `Wrote l10n key-usage inventory: ${displayPath(inventoryPath, repoRoot)}`,
    );
    return;
  }

  const baseline = readOrphanBaseline(baselinePath);
  const ratchet = evaluateOrphanRatchet(result.orphanedKeys, baseline);
  const inventoryCheck = args.checkInventory
    ? checkInventoryFile(result.inventory, inventoryPath)
    : null;

  if (args.json) {
    console.log(
      stableJson({
        inventory: result.inventory,
        baseline: displayPath(baselinePath, repoRoot),
        ratchet,
        inventoryCheck,
        excludedFiles: result.excludedFiles,
      }).trimEnd(),
    );
  } else {
    const summary = result.inventory.summary;
    console.log(
      `Flutter l10n key usage: ${summary.catalogKeys} catalog key(s), ` +
        `${summary.usedKeys} used, ${summary.orphanedKeys} orphaned, ` +
        `${summary.scannedDartFiles} handwritten Dart file(s), ` +
        `${summary.excludedGeneratedDartFiles} generated Dart file(s) excluded.`,
    );
    console.log(
      `Orphan ratchet: ${ratchet.newOrphanedKeys.length} new, ` +
        `${ratchet.baselineOrphanedKeys.length} baseline, ` +
        `${ratchet.resolvedBaselineKeys.length} resolved baseline key(s).`,
    );
  }

  if (args.check && !ratchet.passed) {
    console.error("New orphaned Flutter ARB keys:");
    for (const key of ratchet.newOrphanedKeys) console.error(`- ${key}`);
    console.error(
      "Restore a handwritten production use or remove the obsolete ARB entry. Do not refresh the baseline to hide new debt.",
    );
    process.exitCode = 1;
  }

  if (ratchet.resolvedBaselineKeys.length > 0 && !args.json) {
    console.log(
      `Baseline can shrink by ${ratchet.resolvedBaselineKeys.length} key(s); after reviewing the cleanup, run:`,
    );
    console.log(
      "node tool/copy/check_l10n_key_usage.mjs --write-baseline",
    );
  }

  if (args.checkInventory && !inventoryCheck.current) {
    console.error(
      `L10n key-usage inventory is ${inventoryCheck.reason}: ${displayPath(inventoryPath, repoRoot)}`,
    );
    console.error(
      "Refresh and review it with: node tool/copy/check_l10n_key_usage.mjs --write-inventory",
    );
    process.exitCode = 1;
  }
}

function printHelp() {
  console.log(`Usage: node tool/copy/check_l10n_key_usage.mjs [options]

Scans exact app_en.arb key identifiers in handwritten production Dart. Generated
Dart, comments, and ordinary string contents cannot make an orphan appear used.

Check options:
  --check                 Fail when an orphan is outside the baseline.
  --check-inventory       Fail when the generated key-usage inventory is stale.
  --json                  Print the complete inventory and ratchet result.

Reviewed write options (run separately):
  --write-inventory       Write docs/audit_registry/l10n_key_usage.json.
  --write-baseline        Replace the baseline with current orphaned keys after
                          pruning or restoring usages; the baseline may only shrink.

Path options:
  --arb <path>            Override lib/l10n/app_en.arb.
  --source-root <path>    Override the lib source root.
  --baseline <path>       Override tool/copy/l10n_orphan_baseline.json.
  --inventory <path>      Override docs/audit_registry/l10n_key_usage.json.
  --repo-root <path>      Override the checkout root (used by fixture tests).
  --help, -h              Show this help.

Parent integration loop:
  node tool/copy/check_l10n_key_usage.mjs --write-inventory
  node tool/copy/check_l10n_key_usage.mjs --check --check-inventory
  # After deleting obsolete ARB keys or restoring real usages:
  node tool/copy/check_l10n_key_usage.mjs --write-baseline
`);
}

class CliUsageError extends Error {}
