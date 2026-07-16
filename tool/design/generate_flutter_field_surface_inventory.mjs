#!/usr/bin/env node
import crypto from "node:crypto";
import fs from "node:fs";
import path from "node:path";
import {fileURLToPath} from "node:url";

const DEFAULT_MANIFEST =
  "docs/audit_registry/flutter_field_surface_adoption.json";
const DEFAULT_OUTPUT =
  "docs/audit_registry/flutter_field_surface_inventory.json";
const DEFAULT_ROUTES = "tool/ui_capture/route_inventory.json";
const DEFAULT_SCREENS = "design/screens/catch.screens.json";
const ALLOWED_STATUSES = new Set([
  "approval_ready",
  "needs_domain_approval",
  "deferred_specialized",
  "owner_decision",
  "completed",
]);
const ALLOWED_RISKS = new Set(["low", "medium", "high"]);
const ALLOWED_REACHABILITY = new Set([
  "production_route",
  "production_embedded",
  "widgetbook_only",
]);

export function buildInventory({
  repoRoot = process.cwd(),
  manifestPath = DEFAULT_MANIFEST,
  routeInventoryPath = DEFAULT_ROUTES,
  screenContractsPath = DEFAULT_SCREENS,
} = {}) {
  const manifestFile = resolveFrom(repoRoot, manifestPath);
  const routeFile = resolveFrom(repoRoot, routeInventoryPath);
  const screenFile = resolveFrom(repoRoot, screenContractsPath);
  const manifestSource = fs.readFileSync(manifestFile, "utf8");
  const routeSource = fs.readFileSync(routeFile, "utf8");
  const screenSource = fs.readFileSync(screenFile, "utf8");
  const manifest = JSON.parse(manifestSource);
  const routeInventory = JSON.parse(routeSource);
  const screenContracts = JSON.parse(screenSource);

  validateManifest(manifest);
  const routeIds = new Set(routeInventory.routes.map((route) => route.id));
  const screenIds = new Set(screenContracts.screens.map((screen) => screen.id));

  const rankedCandidates = manifest.candidates
    .slice()
    .sort((left, right) => left.rank - right.rank || left.id.localeCompare(right.id))
    .map((candidate) => ({
      ...candidate,
      bindings: candidate.bindings.map((binding) =>
        resolveBinding(repoRoot, binding),
      ),
      observedAnchors: candidate.anchors.map((anchor) =>
        resolveAnchor(repoRoot, anchor),
      ),
    }));
  const reviewedExclusions = manifest.reviewedExclusions
    .slice()
    .sort((left, right) => left.id.localeCompare(right.id))
    .map((exclusion) => ({
      ...exclusion,
      observedAnchors: exclusion.anchors.map((anchor) =>
        resolveAnchor(repoRoot, anchor),
      ),
    }));

  for (const candidate of rankedCandidates) {
    for (const routeId of candidate.routeIds) {
      if (!routeIds.has(routeId)) {
        throw new Error(`${candidate.id}: route ${routeId} was not found`);
      }
    }
    for (const screenId of candidate.screenIds) {
      if (!screenIds.has(screenId)) {
        throw new Error(`${candidate.id}: screen ${screenId} was not found`);
      }
    }
  }

  const legacyCallsites = scanLegacyCallsites({repoRoot, manifest});
  const classifications = [
    ...rankedCandidates.flatMap((candidate) =>
      candidate.observedAnchors.map((anchor) => ({
        owner: candidate.id,
        file: anchor.file,
        symbol: anchor.symbol,
      })),
    ),
    ...reviewedExclusions.flatMap((exclusion) =>
      exclusion.observedAnchors.map((anchor) => ({
        owner: exclusion.id,
        file: anchor.file,
        symbol: anchor.symbol,
      })),
    ),
  ].filter((entry) => manifest.legacySymbols.includes(entry.symbol));
  const classification = classifyLegacyCallsites(
    legacyCallsites,
    classifications,
  );
  if (classification.duplicates.length > 0) {
    const detail = classification.duplicates
      .map((entry) => `${entry.file}:${entry.symbol} -> ${entry.owners.join(", ")}`)
      .join("; ");
    throw new Error(`duplicate legacy classification: ${detail}`);
  }
  if (classification.unclassified.length > 0) {
    const detail = classification.unclassified
      .map((entry) => `${entry.file}:${entry.line} ${entry.symbol}`)
      .join("; ");
    throw new Error(`unclassified legacy call: ${detail}`);
  }

  const statusCounts = countBy(rankedCandidates, (row) => row.status);
  const riskCounts = countBy(rankedCandidates, (row) => row.risk);
  const exclusionKeys = new Set(
    reviewedExclusions.flatMap((row) =>
      row.observedAnchors
        .filter((anchor) => manifest.legacySymbols.includes(anchor.symbol))
        .map((anchor) => `${anchor.file}:${anchor.symbol}`),
    ),
  );
  const reviewedExclusionCallsites = legacyCallsites.filter((callsite) =>
    exclusionKeys.has(`${callsite.file}:${callsite.symbol}`),
  ).length;

  return {
    schemaVersion: 1,
    generatedBy: "tool/design/generate_flutter_field_surface_inventory.mjs",
    source: {
      manifest: normalizePath(path.relative(repoRoot, manifestFile)),
      manifestSha256: sha256(manifestSource),
      routeInventory: normalizePath(path.relative(repoRoot, routeFile)),
      routeInventorySha256: sha256(routeSource),
      screenContracts: normalizePath(path.relative(repoRoot, screenFile)),
      screenContractsSha256: sha256(screenSource),
    },
    summary: {
      candidateCount: rankedCandidates.length,
      activeCandidateCount: rankedCandidates.filter(
        (candidate) => candidate.status !== "completed",
      ).length,
      completedCandidateCount: rankedCandidates.filter(
        (candidate) => candidate.status === "completed",
      ).length,
      statusCounts,
      riskCounts,
      legacyCallsites: legacyCallsites.length,
      reviewedExclusionCallsites,
      unclassifiedLegacyCallsites: classification.unclassified.length,
    },
    rankedCandidates,
    reviewedExclusions,
    scopeExclusions: manifest.scopeExclusions,
    unclassifiedLegacyCallsites: classification.unclassified,
  };
}

export function scanLegacyCallsites({repoRoot, manifest}) {
  const definitionFiles = new Set(manifest.definitionFiles);
  const results = [];
  for (const file of listDartFiles(path.join(repoRoot, "lib"))) {
    const relative = normalizePath(path.relative(repoRoot, file));
    if (
      definitionFiles.has(relative) ||
      manifest.scopeExclusions.some((row) => relative.startsWith(row.pathPrefix)) ||
      relative.endsWith(".g.dart") ||
      relative.endsWith(".freezed.dart")
    ) {
      continue;
    }
    const source = fs.readFileSync(file, "utf8");
    for (const symbol of manifest.legacySymbols) {
      for (const line of findCallLines(source, symbol)) {
        results.push({file: relative, line, symbol});
      }
    }
  }
  return results.sort(
    (left, right) =>
      left.file.localeCompare(right.file) ||
      left.line - right.line ||
      left.symbol.localeCompare(right.symbol),
  );
}

export function classifyLegacyCallsites(callsites, classifications) {
  const ownersByKey = new Map();
  for (const entry of classifications) {
    const key = `${entry.file}:${entry.symbol}`;
    const owners = ownersByKey.get(key) ?? new Set();
    owners.add(entry.owner);
    ownersByKey.set(key, owners);
  }
  const duplicates = [...ownersByKey.entries()]
    .filter(([, owners]) => owners.size > 1)
    .map(([key, owners]) => {
      const separator = key.lastIndexOf(":");
      return {
        file: key.slice(0, separator),
        symbol: key.slice(separator + 1),
        owners: [...owners].sort(),
      };
    });
  const unclassified = callsites.filter(
    (callsite) =>
      !ownersByKey.has(`${callsite.file}:${callsite.symbol}`),
  );
  return {duplicates, unclassified};
}

export function resolveAnchor(repoRoot, anchor) {
  const file = resolveFrom(repoRoot, anchor.file);
  if (!fs.existsSync(file)) {
    throw new Error(`${anchor.file}: anchor file was not found`);
  }
  const source = fs.readFileSync(file, "utf8");
  const lines = findCallLines(source, anchor.symbol);
  if (lines.length !== anchor.expected) {
    throw new Error(
      `${anchor.file}:${anchor.symbol} expected ${anchor.expected}, observed ${lines.length}`,
    );
  }
  return {
    file: anchor.file,
    kind: "call",
    symbol: anchor.symbol,
    expected: anchor.expected,
    observed: lines.length,
    lines,
  };
}

export function findCallLines(source, symbol) {
  const sanitized = stripCommentsAndStrings(source);
  const expression = new RegExp(
    `(^|[^A-Za-z0-9_])${escapeRegExp(symbol)}(?:<[^>{}()]+>)?\\s*\\(`,
    "gmu",
  );
  const lineStarts = [0];
  for (let index = 0; index < source.length; index += 1) {
    if (source[index] === "\n") lineStarts.push(index + 1);
  }
  const lines = [];
  for (const match of sanitized.matchAll(expression)) {
    const symbolIndex = match.index + match[1].length;
    lines.push(lineForOffset(lineStarts, symbolIndex));
  }
  return lines;
}

export function stripCommentsAndStrings(source) {
  const output = source.split("");
  let state = "code";
  let quote = "";
  for (let index = 0; index < source.length; index += 1) {
    const char = source[index];
    const next = source[index + 1];
    const nextTwo = source.slice(index, index + 3);
    if (state === "code") {
      if (char === "/" && next === "/") {
        output[index] = " ";
        output[index + 1] = " ";
        index += 1;
        state = "line-comment";
      } else if (char === "/" && next === "*") {
        output[index] = " ";
        output[index + 1] = " ";
        index += 1;
        state = "block-comment";
      } else if (nextTwo === "'''" || nextTwo === '\"\"\"') {
        quote = nextTwo;
        output[index] = " ";
        output[index + 1] = " ";
        output[index + 2] = " ";
        index += 2;
        state = "triple-string";
      } else if (char === "'" || char === '\"') {
        quote = char;
        output[index] = " ";
        state = "string";
      }
    } else if (state === "line-comment") {
      if (char === "\n") {
        state = "code";
      } else {
        output[index] = " ";
      }
    } else if (state === "block-comment") {
      if (char === "*" && next === "/") {
        output[index] = " ";
        output[index + 1] = " ";
        index += 1;
        state = "code";
      } else if (char !== "\n") {
        output[index] = " ";
      }
    } else if (state === "string") {
      if (char === "\\") {
        output[index] = " ";
        if (next != null) {
          output[index + 1] = next === "\n" ? "\n" : " ";
          index += 1;
        }
      } else {
        if (char === quote) state = "code";
        if (char !== "\n") output[index] = " ";
      }
    } else if (state === "triple-string") {
      if (source.slice(index, index + 3) === quote) {
        output[index] = " ";
        output[index + 1] = " ";
        output[index + 2] = " ";
        index += 2;
        state = "code";
      } else if (char !== "\n") {
        output[index] = " ";
      }
    }
  }
  return output.join("");
}

export function validateManifest(manifest) {
  if (manifest.schemaVersion !== 1) {
    throw new Error("field-surface manifest schemaVersion must be 1");
  }
  if (!Array.isArray(manifest.candidates) || manifest.candidates.length === 0) {
    throw new Error("field-surface manifest requires candidates");
  }
  const ids = new Set();
  const ranks = new Set();
  for (const candidate of manifest.candidates) {
    if (ids.has(candidate.id)) throw new Error(`duplicate candidate ${candidate.id}`);
    ids.add(candidate.id);
    if (ranks.has(candidate.rank)) throw new Error(`duplicate rank ${candidate.rank}`);
    ranks.add(candidate.rank);
    if (!ALLOWED_STATUSES.has(candidate.status)) {
      throw new Error(`${candidate.id}: invalid status ${candidate.status}`);
    }
    if (!ALLOWED_RISKS.has(candidate.risk)) {
      throw new Error(`${candidate.id}: invalid risk ${candidate.risk}`);
    }
    if (!ALLOWED_REACHABILITY.has(candidate.reachability)) {
      throw new Error(
        `${candidate.id}: invalid reachability ${candidate.reachability}`,
      );
    }
    if (!Array.isArray(candidate.bindings) || candidate.bindings.length === 0) {
      throw new Error(`${candidate.id}: bindings are required`);
    }
    if (!Array.isArray(candidate.anchors)) {
      throw new Error(`${candidate.id}: anchors must be an array`);
    }
    if (candidate.status === "completed") {
      if (
        typeof candidate.completedAt !== "string" ||
        candidate.completedAt.trim().length === 0
      ) {
        throw new Error(`${candidate.id}: completedAt is required when completed`);
      }
      if (
        !Array.isArray(candidate.verification) ||
        candidate.verification.length === 0
      ) {
        throw new Error(
          `${candidate.id}: verification is required when completed`,
        );
      }
      const legacyAnchors = candidate.anchors.filter((anchor) =>
        manifest.legacySymbols.includes(anchor.symbol),
      );
      if (legacyAnchors.length > 0) {
        throw new Error(
          `${candidate.id}: completed candidates cannot retain legacy anchors`,
        );
      }
    }
  }
  for (let rank = 1; rank <= manifest.candidates.length; rank += 1) {
    if (!ranks.has(rank)) throw new Error(`candidate rank ${rank} is missing`);
  }
}

function resolveBinding(repoRoot, binding) {
  const file = resolveFrom(repoRoot, binding.file);
  if (!fs.existsSync(file)) {
    throw new Error(`${binding.file}: binding file was not found`);
  }
  const source = fs.readFileSync(file, "utf8");
  if (!new RegExp(`\\b${escapeRegExp(binding.symbol)}\\b`, "u").test(source)) {
    throw new Error(`${binding.file}: symbol ${binding.symbol} was not found`);
  }
  return binding;
}

function listDartFiles(root) {
  if (!fs.existsSync(root)) return [];
  const results = [];
  for (const entry of fs.readdirSync(root, {withFileTypes: true})) {
    const fullPath = path.join(root, entry.name);
    if (entry.isDirectory()) {
      results.push(...listDartFiles(fullPath));
    } else if (entry.isFile() && entry.name.endsWith(".dart")) {
      results.push(fullPath);
    }
  }
  return results;
}

function lineForOffset(lineStarts, offset) {
  let low = 0;
  let high = lineStarts.length;
  while (low + 1 < high) {
    const middle = Math.floor((low + high) / 2);
    if (lineStarts[middle] <= offset) low = middle;
    else high = middle;
  }
  return low + 1;
}

function countBy(rows, keyFor) {
  const counts = {};
  for (const row of rows) {
    const key = keyFor(row);
    counts[key] = (counts[key] ?? 0) + 1;
  }
  return Object.fromEntries(
    Object.entries(counts).sort(([left], [right]) => left.localeCompare(right)),
  );
}

function sha256(value) {
  return crypto.createHash("sha256").update(value).digest("hex");
}

function resolveFrom(root, target) {
  return path.isAbsolute(target) ? target : path.join(root, target);
}

function normalizePath(value) {
  return value.split(path.sep).join("/");
}

function escapeRegExp(value) {
  return value.replace(/[.*+?^${}()|[\]\\]/gu, "\\$&");
}

function parseArgs(argv) {
  const valueFor = (flag, fallback) => {
    const index = argv.indexOf(flag);
    if (index === -1) return fallback;
    if (!argv[index + 1]) throw new Error(`${flag} requires a value`);
    return argv[index + 1];
  };
  return {
    check: argv.includes("--check"),
    json: argv.includes("--json"),
    help: argv.includes("--help") || argv.includes("-h"),
    repoRoot: path.resolve(valueFor("--repo-root", process.cwd())),
    manifestPath: valueFor("--manifest", DEFAULT_MANIFEST),
    outputPath: valueFor("--write", DEFAULT_OUTPUT),
  };
}

function main() {
  const args = parseArgs(process.argv.slice(2));
  if (args.help) {
    console.log(`Usage:
  node tool/design/generate_flutter_field_surface_inventory.mjs [--check] [--json]
    [--repo-root <path>] [--manifest <path>] [--write <path>]

Validates the human-owned Flutter field-surface adoption ledger, proves all
legacy product callsites are classified, and writes deterministic evidence.
`);
    return;
  }
  const inventory = buildInventory({
    repoRoot: args.repoRoot,
    manifestPath: args.manifestPath,
  });
  const outputFile = resolveFrom(args.repoRoot, args.outputPath);
  const output = `${JSON.stringify(inventory, null, 2)}\n`;
  if (args.check) {
    const current = fs.existsSync(outputFile)
      ? fs.readFileSync(outputFile, "utf8")
      : null;
    if (current !== output) {
      throw new Error(
        `${normalizePath(path.relative(args.repoRoot, outputFile))} is stale; ` +
          "run npm run design:fields:inventory",
      );
    }
  } else {
    fs.mkdirSync(path.dirname(outputFile), {recursive: true});
    fs.writeFileSync(outputFile, output);
  }
  if (args.json) {
    process.stdout.write(output);
  } else {
    console.log(
      `Flutter field surfaces: ${inventory.summary.candidateCount} candidates, ` +
        `${inventory.summary.legacyCallsites} classified legacy callsites.`,
    );
  }
}

const isMain =
  process.argv[1] != null &&
  path.resolve(process.argv[1]) === fileURLToPath(import.meta.url);
if (isMain) {
  try {
    main();
  } catch (error) {
    console.error(error instanceof Error ? error.message : String(error));
    process.exitCode = 1;
  }
}
