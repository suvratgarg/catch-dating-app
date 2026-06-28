#!/usr/bin/env node
import fs from "node:fs";
import {spawnSync} from "node:child_process";
import {fromRepo, relativeToRepo} from "../lib/repo_paths.mjs";

const args = process.argv.slice(2);
const writeIndex = args.indexOf("--write");
const writePath = writeIndex === -1 ? null : args[writeIndex + 1];
const decisionsIndex = args.indexOf("--decisions");
const decisionsPath =
  decisionsIndex === -1
    ? "docs/design_parity/widgetbook_widget_decisions.json"
    : args[decisionsIndex + 1];
const shouldCheck = args.includes("--check");
const shouldJson = args.includes("--json");

if (args.includes("--help") || args.includes("-h")) {
  console.log(`Usage:
  node tool/design/check_widgetbook_coverage.mjs [--json] [--write <path>] [--decisions <path>] [--check]

Scans lib/**/*.dart widget classes and compares them to generated Widgetbook
component names. A public widget class is mechanically covered by direct name
match. Private widget classes always remain in the decision queue because
Widgetbook cannot import library-private Dart symbols directly. Explicit
replacement/promotion/delete decisions are loaded from the decision ledger when
present.
`);
  process.exit(0);
}

if (writeIndex !== -1 && !writePath) {
  console.error("--write requires a path");
  process.exit(64);
}

if (decisionsIndex !== -1 && !decisionsPath) {
  console.error("--decisions requires a path");
  process.exit(64);
}

const widgetClasses = scanWidgetClasses();
const widgetbookNames = parseWidgetbookComponentNames();
const decisionLedger = loadDecisionLedger(decisionsPath);
const rows = widgetClasses.map((entry) => {
  const publicName = entry.name.replace(/^_/, "");
  const exactNameMatched = widgetbookNames.has(entry.name);
  const publicNameMatched = widgetbookNames.has(publicName);
  const mechanicalStatus = classifyMechanicalCoverage({
    exactNameMatched,
    publicNameMatched,
    visibility: entry.visibility,
  });
  const decision = decisionLedger.decisionsByKey.get(decisionKey(entry));
  const status = decision?.status ?? mechanicalStatus;

  return {
    ...entry,
    publicName,
    exactNameMatched,
    publicNameMatched,
    mechanicalStatus,
    decision: decision ?? null,
    status,
  };
});
const liveKeys = new Set(rows.map(decisionKey));
const staleDecisions = decisionLedger.decisions.filter(
  (decision) => !liveKeys.has(decisionKey(decision)),
);

const result = {
  generatedAt: new Date().toISOString(),
  decisionLedgerPath: decisionsPath,
  total: rows.length,
  stats: countBy(rows, (row) => row.status),
  decisionStats: countBy(
    rows.filter((row) => row.decision !== null),
    (row) => row.status,
  ),
  areaStats: buildAreaStats(rows),
  staleDecisions,
  rows,
};

if (writePath) {
  fs.writeFileSync(fromRepo(writePath), JSON.stringify(result, null, 2) + "\n");
}

if (shouldJson) {
  console.log(JSON.stringify(result, null, 2));
} else {
  printSummary(result);
}

const uncovered =
  (result.stats.PRIVATE_NAME_MATCH_NEEDS_EXPLICIT_DECISION ?? 0) +
  (result.stats.PRIVATE_NEEDS_RENAME_OR_REPLACE ?? 0) +
  (result.stats.PUBLIC_NEEDS_CATALOG_OR_REPLACE ?? 0);
if (shouldCheck && (uncovered > 0 || staleDecisions.length > 0)) {
  const parts = [];
  if (uncovered > 0) {
    parts.push(`${uncovered} widget class(es) need catalog-or-replace decisions`);
  }
  if (staleDecisions.length > 0) {
    parts.push(`${staleDecisions.length} stale decision(s) no longer match live widget classes`);
  }
  console.error(`Widgetbook coverage check failed: ${parts.join("; ")}.`);
  process.exit(1);
}

function classifyMechanicalCoverage({
  exactNameMatched,
  publicNameMatched,
  visibility,
}) {
  if (visibility === "public" && exactNameMatched) {
    return "PUBLIC_ALREADY_CATALOGED_NAME_MATCH";
  }
  if (visibility === "private" && (exactNameMatched || publicNameMatched)) {
    return "PRIVATE_NAME_MATCH_NEEDS_EXPLICIT_DECISION";
  }
  return visibility === "private"
    ? "PRIVATE_NEEDS_RENAME_OR_REPLACE"
    : "PUBLIC_NEEDS_CATALOG_OR_REPLACE";
}

function scanWidgetClasses() {
  const pattern =
    String.raw`class _?[A-Z][A-Za-z0-9_]+ extends (StatelessWidget|StatefulWidget|ConsumerWidget|ConsumerStatefulWidget|HookWidget|HookConsumerWidget)`;
  const scan = spawnSync("rg", ["-n", pattern, "lib", "--glob", "*.dart"], {
    cwd: fromRepo(),
    encoding: "utf8",
  });

  if (scan.status !== 0 && scan.stdout.trim() === "") {
    console.error(scan.stderr || "Failed to scan widget classes with rg.");
    process.exit(scan.status ?? 1);
  }

  const entries = [];
  for (const line of scan.stdout.trim().split("\n")) {
    if (!line) continue;
    const match =
      /^(.*?):(\d+):.*?class\s+(_?[A-Z][A-Za-z0-9_]+)\s+extends\s+([A-Za-z0-9_]+)/u.exec(
        line,
      );
    if (!match) continue;
    const [, file, lineNumber, name, base] = match;
    entries.push({
      file,
      line: Number(lineNumber),
      name,
      base,
      area: areaFor(file),
      visibility: name.startsWith("_") ? "private" : "public",
    });
  }
  return entries.sort((a, b) => a.file.localeCompare(b.file) || a.line - b.line);
}

function parseWidgetbookComponentNames() {
  const source = fs.readFileSync(
    fromRepo("widgetbook/lib/main.directories.g.dart"),
    "utf8",
  );
  return new Set(
    [...source.matchAll(/WidgetbookComponent\(\s*name:\s*'([^']+)'/gu)].map(
      (match) => match[1],
    ),
  );
}

function loadDecisionLedger(path) {
  const resolvedPath = fromRepo(path);
  if (!fs.existsSync(resolvedPath)) {
    return {decisions: [], decisionsByKey: new Map()};
  }

  const parsed = JSON.parse(fs.readFileSync(resolvedPath, "utf8"));
  const decisions = Array.isArray(parsed.decisions) ? parsed.decisions : [];
  const decisionsByKey = new Map();
  for (const decision of decisions) {
    validateDecision(decision);
    const key = decisionKey(decision);
    if (decisionsByKey.has(key)) {
      console.error(`Duplicate widgetbook decision for ${key}`);
      process.exit(65);
    }
    decisionsByKey.set(key, decision);
  }
  return {decisions, decisionsByKey};
}

function validateDecision(decision) {
  const validStatuses = new Set([
    "ALREADY_CATALOGED",
    "REPLACE_WITH_EXISTING_CATALOG_ENTRY",
    "PROMOTE_TO_WIDGETBOOK_CATALOG",
    "DELETE_OR_MERGE_DUPLICATE",
  ]);
  const missing = ["file", "name", "status", "target", "rationale"].filter(
    (field) => typeof decision[field] !== "string" || decision[field] === "",
  );
  if (missing.length > 0) {
    console.error(
      `Invalid widgetbook decision for ${decision.file ?? "<missing file>"}:${decision.name ?? "<missing name>"}; missing ${missing.join(", ")}`,
    );
    process.exit(65);
  }
  if (!validStatuses.has(decision.status)) {
    console.error(
      `Invalid widgetbook decision status ${decision.status} for ${decision.file}:${decision.name}`,
    );
    process.exit(65);
  }
}

function areaFor(file) {
  const parts = file.split("/");
  if (parts[1] === "core") return `core/${parts[2] ?? ""}`;
  return parts[1] ?? "unknown";
}

function decisionKey(entry) {
  return `${entry.file}::${entry.name}`;
}

function countBy(values, keyFor) {
  const counts = {};
  for (const value of values) {
    const key = keyFor(value);
    counts[key] = (counts[key] ?? 0) + 1;
  }
  return counts;
}

function buildAreaStats(rows) {
  const byArea = new Map();
  for (const row of rows) {
    const entry =
      byArea.get(row.area) ??
      {
        area: row.area,
        total: 0,
        publicAlreadyCataloged: 0,
        privateNameMatchNeedsDecision: 0,
        privateNeedsRenameOrReplace: 0,
        publicNeedsCatalogOrReplace: 0,
        replacedWithCatalogEntry: 0,
        promotedToWidgetbookCatalog: 0,
        deletedOrMergedDuplicate: 0,
      };
    entry.total += 1;
    if (
      row.status === "PUBLIC_ALREADY_CATALOGED_NAME_MATCH" ||
      row.status === "ALREADY_CATALOGED"
    ) {
      entry.publicAlreadyCataloged += 1;
    } else if (row.status === "PRIVATE_NAME_MATCH_NEEDS_EXPLICIT_DECISION") {
      entry.privateNameMatchNeedsDecision += 1;
    } else if (row.status === "PRIVATE_NEEDS_RENAME_OR_REPLACE") {
      entry.privateNeedsRenameOrReplace += 1;
    } else if (row.status === "PUBLIC_NEEDS_CATALOG_OR_REPLACE") {
      entry.publicNeedsCatalogOrReplace += 1;
    } else if (row.status === "REPLACE_WITH_EXISTING_CATALOG_ENTRY") {
      entry.replacedWithCatalogEntry += 1;
    } else if (row.status === "PROMOTE_TO_WIDGETBOOK_CATALOG") {
      entry.promotedToWidgetbookCatalog += 1;
    } else if (row.status === "DELETE_OR_MERGE_DUPLICATE") {
      entry.deletedOrMergedDuplicate += 1;
    }
    byArea.set(row.area, entry);
  }
  return [...byArea.values()].sort(
    (a, b) => b.total - a.total || a.area.localeCompare(b.area),
  );
}

function printSummary(result) {
  const decisionQueue =
    (result.stats.PRIVATE_NAME_MATCH_NEEDS_EXPLICIT_DECISION ?? 0) +
    (result.stats.PRIVATE_NEEDS_RENAME_OR_REPLACE ?? 0) +
    (result.stats.PUBLIC_NEEDS_CATALOG_OR_REPLACE ?? 0);
  console.log(`Widget classes: ${result.total}`);
  console.log(
    [
      `Public already cataloged by name: ${result.stats.PUBLIC_ALREADY_CATALOGED_NAME_MATCH ?? 0}`,
      `Explicit already cataloged: ${result.stats.ALREADY_CATALOGED ?? 0}`,
      `Explicit replaced with catalog entry: ${result.stats.REPLACE_WITH_EXISTING_CATALOG_ENTRY ?? 0}`,
      `Explicit promote to Widgetbook catalog: ${result.stats.PROMOTE_TO_WIDGETBOOK_CATALOG ?? 0}`,
      `Explicit delete/merge duplicate: ${result.stats.DELETE_OR_MERGE_DUPLICATE ?? 0}`,
      `Private name match needs explicit decision: ${result.stats.PRIVATE_NAME_MATCH_NEEDS_EXPLICIT_DECISION ?? 0}`,
      `Private needs rename/replace: ${result.stats.PRIVATE_NEEDS_RENAME_OR_REPLACE ?? 0}`,
      `Public needs catalog/replace: ${result.stats.PUBLIC_NEEDS_CATALOG_OR_REPLACE ?? 0}`,
      `Total decision queue: ${decisionQueue}`,
      `Stale decisions: ${result.staleDecisions.length}`,
    ].join("\n"),
  );
  console.log("\nLargest unresolved areas:");
  for (const area of result.areaStats.slice(0, 12)) {
    const unresolved =
      area.privateNameMatchNeedsDecision +
      area.privateNeedsRenameOrReplace + area.publicNeedsCatalogOrReplace;
    console.log(
      [
        `- ${area.area}: ${unresolved} unresolved`,
        `(${area.publicAlreadyCataloged}/${area.total} public cataloged by name)`,
      ].join(" "),
    );
  }
  if (writePath) {
    console.log(`\nWrote ${relativeToRepo(fromRepo(writePath))}`);
  }
}
