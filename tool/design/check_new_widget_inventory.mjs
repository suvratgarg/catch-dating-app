#!/usr/bin/env node
import fs from "node:fs";
import path from "node:path";
import {spawnSync} from "node:child_process";
import {fromRepo, repoRoot} from "../lib/repo_paths.mjs";

const args = process.argv.slice(2);
const explicitBaseRef = valueAfter("--base");
const baseRef = explicitBaseRef ?? "HEAD^";
const writePath = valueAfter("--write") ?? "docs/audit_registry/new_widget_inventory_scan.json";
const shouldCheck = args.includes("--check");
const shouldJson = args.includes("--json");
const shouldNoWrite = args.includes("--no-write");

if (args.includes("--help") || args.includes("-h")) {
  console.log(`Usage:
  node tool/design/check_new_widget_inventory.mjs [--base <ref>] [--write <path>] [--json] [--check] [--no-write]

Compares current lib/**/*.dart against a base ref, HEAD^ by default. Reports
new widget classes, new private widget classes, new Widget-returning helper
functions/methods, and whether new public widget classes are present in
Widgetbook plus docs/widget_catalog.md.
`);
  process.exit(0);
}

const currentFiles = listCurrentDartFiles(fromRepo("lib"));
const baseInput = resolveBaseInput({
  ref: baseRef,
  explicit: explicitBaseRef !== null,
  currentFiles,
});
const baseSnapshot = scanSnapshot({
  files: baseInput.files,
  readFile: baseInput.readFile,
});
const currentSnapshot = scanSnapshot({
  label: "working tree",
  files: currentFiles,
  readFile: (file) => fs.readFileSync(fromRepo(file), "utf8"),
});
const widgetbookNames = readWidgetbookNames();
const catalogSource = fs.readFileSync(fromRepo("docs/widget_catalog.md"), "utf8");

const addedWidgets = currentSnapshot.widgetClasses
  .filter((entry) => !baseSnapshot.widgetClassKeys.has(widgetClassKey(entry)))
  .map((entry) => classifyWidget(entry))
  .sort(compareByFileLine);

const addedWidgetHelpers = currentSnapshot.widgetHelpers
  .filter((entry) => !baseSnapshot.widgetHelperKeys.has(widgetHelperKey(entry)))
  .map(classifyWidgetHelper)
  .sort(compareByFileLine);

const summary = summarize({addedWidgets, addedWidgetHelpers});
const report = {
  generatedAt: new Date().toISOString(),
  baseRef,
  baseStatus: baseInput.status,
  baseWarning: baseInput.warning,
  current: "working tree",
  sourceOfTruth: {
    widgetbook: "widgetbook/lib/main.directories.g.dart",
    catalog: "docs/widget_catalog.md",
    policy:
      "New public widget classes need Widgetbook and widget catalog coverage. New private widget classes and Widget-returning helpers must be inlined/deleted, merged into an existing primitive, or promoted to public cataloged widgets.",
  },
  summary,
  addedWidgets,
  addedWidgetHelpers,
};

if (!shouldNoWrite) {
  fs.writeFileSync(fromRepo(writePath), JSON.stringify(report, null, 2) + "\n");
}

if (shouldJson) {
  console.log(JSON.stringify(report, null, 2));
} else {
  printSummary(report, writePath);
}

if (shouldCheck && summary.unresolved > 0) {
  console.error(
    `New widget inventory check failed: ${summary.unresolved} unresolved new widget inventory item(s).`,
  );
  process.exit(1);
}

function scanSnapshot({files, readFile}) {
  const widgetClasses = [];
  const widgetHelpers = [];

  for (const file of files) {
    if (shouldSkip(file)) continue;
    const source = readFile(file);
    const lineStarts = buildLineStarts(source);
    const classRanges = collectClassRanges(source, lineStarts);

    for (const declaration of collectWidgetClasses(source, lineStarts)) {
      widgetClasses.push({...declaration, file});
    }

    for (const helper of collectWidgetHelpers(source, lineStarts, classRanges)) {
      widgetHelpers.push({...helper, file});
    }
  }

  return {
    widgetClasses,
    widgetHelpers,
    widgetClassKeys: new Set(widgetClasses.map(widgetClassKey)),
    widgetHelperKeys: new Set(widgetHelpers.map(widgetHelperKey)),
  };
}

function collectWidgetClasses(source, lineStarts) {
  const rows = [];
  const regex =
    /class\s+([A-Za-z_][A-Za-z0-9_]*)(?:<[^>{}]+>)?\s+extends\s+(?:[A-Za-z_][A-Za-z0-9_]*\.)?(StatelessWidget|StatefulWidget|ConsumerWidget|ConsumerStatefulWidget|HookWidget|HookConsumerWidget)\b/gu;

  for (const match of source.matchAll(regex)) {
    rows.push({
      name: match[1],
      baseClass: match[2],
      visibility: match[1].startsWith("_") ? "private" : "public",
      line: lineForOffset(lineStarts, match.index ?? 0),
    });
  }

  return rows;
}

function collectWidgetHelpers(source, lineStarts, classRanges) {
  const rows = [];
  const regex = /(?:^|\n)([ \t]*(?:static\s+)?Widget\s+([A-Za-z_][A-Za-z0-9_]*)\s*\()/gu;

  for (const match of source.matchAll(regex)) {
    const offset = (match.index ?? 0) + (match[0].startsWith("\n") ? 1 : 0);
    const name = match[2];
    if (name === "build") continue;
    const owner = classRanges.find((range) => offset > range.open && offset < range.close);
    rows.push({
      name,
      owner: owner?.name ?? null,
      ownerBaseClass: owner?.baseClass ?? null,
      visibility: name.startsWith("_") ? "private" : "public",
      line: lineForOffset(lineStarts, offset),
      scope: owner ? "class-method" : "top-level",
    });
  }

  return rows;
}

function collectClassRanges(source, lineStarts) {
  const rows = [];
  const regex =
    /class\s+([A-Za-z_][A-Za-z0-9_]*)(?:<[^>{}]+>)?\s+extends\s+([A-Za-z_][A-Za-z0-9_<>?, ]*)/gu;

  for (const match of source.matchAll(regex)) {
    const open = source.indexOf("{", match.index);
    if (open === -1) continue;
    const close = findMatchingBrace(source, open);
    if (close === -1) continue;
    rows.push({
      name: match[1],
      baseClass: match[2].trim(),
      open,
      close,
      line: lineForOffset(lineStarts, match.index ?? 0),
    });
  }

  return rows.sort((a, b) => a.open - b.open);
}

function classifyWidget(entry) {
  const widgetbookCovered = widgetbookNames.has(entry.name);
  const catalogMentioned = mentionsSymbol(catalogSource, entry.name);
  const issues = [];

  if (entry.visibility === "private") {
    issues.push("private-widget-class");
  } else {
    if (!widgetbookCovered) issues.push("missing-widgetbook");
    if (!catalogMentioned) issues.push("missing-widget-catalog");
  }

  return {
    ...entry,
    widgetbookCovered,
    catalogMentioned,
    status: issues.length === 0 ? "covered" : "unresolved",
    issues,
    recommendedAction: recommendationForWidget(entry, issues),
  };
}

function classifyWidgetHelper(entry) {
  return {
    ...entry,
    status: "unresolved",
    issues: ["widget-returning-helper"],
    recommendedAction:
      "Inline into the owning build method when purely local, merge into an existing primitive when duplicated, or extract a public Widgetbook/cataloged widget when reusable.",
  };
}

function recommendationForWidget(entry, issues) {
  if (issues.includes("private-widget-class")) {
    return "Inline/delete the private widget, merge it into an existing public primitive, or promote it to a public widget with Widgetbook and catalog coverage.";
  }
  if (issues.includes("missing-widgetbook") && issues.includes("missing-widget-catalog")) {
    return "Either add Widgetbook plus docs/widget_catalog.md coverage, or merge/delete the redundant public widget.";
  }
  if (issues.includes("missing-widgetbook")) {
    return "Add an exact-name Widgetbook component or merge/delete the redundant public widget.";
  }
  if (issues.includes("missing-widget-catalog")) {
    return "Add docs/widget_catalog.md inventory guidance or merge/delete the redundant public widget.";
  }
  return "Covered by Widgetbook and docs/widget_catalog.md.";
}

function summarize({addedWidgets, addedWidgetHelpers}) {
  const widgetsByStatus = countBy(addedWidgets, (entry) => entry.status);
  const helpersByStatus = countBy(addedWidgetHelpers, (entry) => entry.status);
  const issues = countIssues([...addedWidgets, ...addedWidgetHelpers]);
  const unresolved =
    addedWidgets.filter((entry) => entry.status !== "covered").length +
    addedWidgetHelpers.length;

  return {
    addedWidgetClasses: addedWidgets.length,
    addedPublicWidgetClasses: addedWidgets.filter((entry) => entry.visibility === "public").length,
    addedPrivateWidgetClasses: addedWidgets.filter((entry) => entry.visibility === "private").length,
    addedWidgetReturningHelpers: addedWidgetHelpers.length,
    coveredNewWidgets: addedWidgets.filter((entry) => entry.status === "covered").length,
    unresolved,
    widgetsByStatus,
    helpersByStatus,
    issues,
  };
}

function printSummary(report, outputPath) {
  const {summary} = report;
  console.log(`New widget inventory scan (${report.baseRef} -> working tree)`);
  console.log(`  Added widget classes: ${summary.addedWidgetClasses}`);
  console.log(`    public: ${summary.addedPublicWidgetClasses}`);
  console.log(`    private: ${summary.addedPrivateWidgetClasses}`);
  console.log(`    covered: ${summary.coveredNewWidgets}`);
  console.log(`  Added Widget-returning helpers: ${summary.addedWidgetReturningHelpers}`);
  console.log(`  Unresolved items: ${summary.unresolved}`);
  console.log(`  Issues: ${JSON.stringify(summary.issues)}`);
  if (!shouldNoWrite) console.log(`Report written to: ${outputPath}`);

  const blockers = [...report.addedWidgets, ...report.addedWidgetHelpers].filter(
    (entry) => entry.status !== "covered",
  );
  if (blockers.length === 0) return;

  console.log("");
  console.log("First unresolved items:");
  for (const item of blockers.slice(0, 25)) {
    const owner = item.owner ? `${item.owner}.` : "";
    console.log(
      `  ${item.file}:${item.line} ${owner}${item.name} [${item.issues.join(", ")}]`,
    );
  }
}

function resolveBaseInput({ref, explicit, currentFiles}) {
  const result = spawnGit(["ls-tree", "-r", "--name-only", ref, "lib"], {allowFailure: true});
  if (result.status === 0) {
    return {
      status: "git-ref",
      warning: null,
      files: dartFilesFromGitList(result.stdout),
      readFile: (file) => readGitFile(ref, file),
    };
  }

  if (explicit) {
    console.error(result.stderr || `git ls-tree ${ref} failed`);
    process.exit(result.status ?? 1);
  }

  const warning = `Base ref ${ref} is unavailable; using the working tree as the baseline. This commonly happens in shallow CI checkouts.`;
  console.warn(warning);
  return {
    status: "working-tree-fallback",
    warning,
    files: currentFiles,
    readFile: (file) => fs.readFileSync(fromRepo(file), "utf8"),
  };
}

function dartFilesFromGitList(stdout) {
  return stdout
    .split("\n")
    .filter((file) => file.endsWith(".dart"))
    .sort();
}

function listCurrentDartFiles(root) {
  const rows = [];
  for (const entry of fs.readdirSync(root, {withFileTypes: true})) {
    const absolute = path.join(root, entry.name);
    if (entry.isDirectory()) {
      rows.push(...listCurrentDartFiles(absolute));
    } else if (entry.isFile() && entry.name.endsWith(".dart")) {
      rows.push(path.relative(repoRoot, absolute));
    }
  }
  return rows.sort();
}

function readGitFile(ref, file) {
  return spawnGit(["show", `${ref}:${file}`]);
}

function spawnGit(args, options = {}) {
  const result = spawnSync("git", args, {
    cwd: repoRoot,
    encoding: "utf8",
    maxBuffer: 64 * 1024 * 1024,
  });
  if (result.status !== 0) {
    if (options.allowFailure) return result;
    console.error(result.stderr || `git ${args.join(" ")} failed`);
    process.exit(result.status ?? 1);
  }
  if (options.allowFailure) return result;
  return result.stdout;
}

function readWidgetbookNames() {
  const source = fs.readFileSync(fromRepo("widgetbook/lib/main.directories.g.dart"), "utf8");
  return new Set(
    [...source.matchAll(/WidgetbookComponent\(\s*name:\s*'([^']+)'/gu)].map(
      (match) => match[1],
    ),
  );
}

function mentionsSymbol(source, symbol) {
  const escaped = symbol.replace(/[.*+?^${}()|[\]\\]/gu, "\\$&");
  return new RegExp(`(^|[^A-Za-z0-9_])${escaped}([^A-Za-z0-9_]|$)`, "u").test(source);
}

function shouldSkip(file) {
  return (
    file.endsWith(".g.dart") ||
    file.endsWith(".freezed.dart") ||
    file.includes("/labs/") ||
    file.includes("/generated/")
  );
}

function buildLineStarts(source) {
  const starts = [0];
  for (let index = 0; index < source.length; index += 1) {
    if (source[index] === "\n") starts.push(index + 1);
  }
  return starts;
}

function lineForOffset(lineStarts, offset) {
  let low = 0;
  let high = lineStarts.length - 1;
  while (low <= high) {
    const mid = Math.floor((low + high) / 2);
    if (lineStarts[mid] <= offset) low = mid + 1;
    else high = mid - 1;
  }
  return high + 1;
}

function findMatchingBrace(source, open) {
  let depth = 0;
  for (let index = open; index < source.length; index += 1) {
    if (source[index] === "{") depth += 1;
    else if (source[index] === "}") {
      depth -= 1;
      if (depth === 0) return index;
    }
  }
  return -1;
}

function widgetClassKey(entry) {
  return `${entry.file}::${entry.name}::${entry.baseClass}`;
}

function widgetHelperKey(entry) {
  return `${entry.file}::${entry.owner ?? "<top-level>"}::${entry.name}`;
}

function compareByFileLine(a, b) {
  return a.file.localeCompare(b.file) || a.line - b.line || a.name.localeCompare(b.name);
}

function countBy(values, keyFor) {
  const counts = {};
  for (const value of values) {
    const key = keyFor(value);
    counts[key] = (counts[key] ?? 0) + 1;
  }
  return counts;
}

function countIssues(values) {
  const counts = {};
  for (const value of values) {
    for (const issue of value.issues ?? []) {
      counts[issue] = (counts[issue] ?? 0) + 1;
    }
  }
  return counts;
}

function valueAfter(flag) {
  const index = args.indexOf(flag);
  if (index === -1) return null;
  const value = args[index + 1];
  if (!value || value.startsWith("--")) {
    console.error(`${flag} requires a value`);
    process.exit(64);
  }
  return value;
}
