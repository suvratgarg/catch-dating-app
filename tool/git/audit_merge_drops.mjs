#!/usr/bin/env node
import fs from "node:fs";
import path from "node:path";
import {spawnSync} from "node:child_process";
import {fileURLToPath} from "node:url";

const categoryOrder = [
  "discarded-ours",
  "discarded-theirs",
  "both-diverged",
  "resolved-equivalent",
  "retained-ours",
  "retained-theirs",
];
const discardedCategories = new Set([
  "discarded-ours",
  "discarded-theirs",
]);
const defaultRepoRoot = path.resolve(
  path.dirname(fileURLToPath(import.meta.url)),
  "../..",
);
const isCliEntrypoint =
  process.argv[1] != null &&
  path.resolve(process.argv[1]) === fileURLToPath(import.meta.url);

/**
 * Parses `git ls-tree -r -z --full-tree` output into exact Git tree entries.
 * A missing path is represented by absence from the returned map, which the
 * classifier normalizes to null so additions and deletions remain explicit.
 */
export function parseLsTree(output) {
  const entries = new Map();
  for (const row of String(output).split("\0")) {
    if (!row) continue;
    const separator = row.indexOf("\t");
    if (separator < 0) throw new Error(`Malformed git ls-tree row: ${row}`);
    const header = row.slice(0, separator);
    const filePath = row.slice(separator + 1);
    const match = /^(\d{6}) ([^ ]+) ([0-9a-f]+)$/u.exec(header);
    if (!match) throw new Error(`Malformed git ls-tree header: ${header}`);
    entries.set(filePath, {
      mode: match[1],
      type: match[2],
      oid: match[3],
    });
  }
  return entries;
}

/**
 * Classifies one path by exact Git tree-entry identity. The object id catches
 * content changes, while mode/type keep executable-bit and submodule changes
 * from being silently treated as equivalent.
 */
export function classifyMergePath({path: filePath, base, ours, theirs, merged}) {
  const identities = {
    base: entryIdentity(base),
    ours: entryIdentity(ours),
    theirs: entryIdentity(theirs),
    merged: entryIdentity(merged),
  };
  const changed = {
    ours: identities.ours !== identities.base,
    theirs: identities.theirs !== identities.base,
    merged: identities.merged !== identities.base,
  };

  let category;
  if (
    identities.ours === identities.theirs &&
    identities.merged === identities.ours
  ) {
    category = "resolved-equivalent";
  } else if (
    identities.merged === identities.theirs &&
    identities.merged !== identities.ours
  ) {
    category = changed.ours ? "discarded-ours" : "retained-theirs";
  } else if (
    identities.merged === identities.ours &&
    identities.merged !== identities.theirs
  ) {
    category = changed.theirs ? "discarded-theirs" : "retained-ours";
  } else {
    category = "both-diverged";
  }

  return {
    path: filePath,
    category,
    changed,
    entries: {
      base: publicEntry(base),
      ours: publicEntry(ours),
      theirs: publicEntry(theirs),
      merged: publicEntry(merged),
    },
  };
}

/** Pure four-tree classifier used by the CLI and fixture tests. */
export function classifyMergeTrees({base, ours, theirs, merged}) {
  const trees = {
    base: toEntryMap(base),
    ours: toEntryMap(ours),
    theirs: toEntryMap(theirs),
    merged: toEntryMap(merged),
  };
  const allPaths = new Set();
  for (const tree of Object.values(trees)) {
    for (const filePath of tree.keys()) allPaths.add(filePath);
  }

  const paths = [];
  for (const filePath of [...allPaths].sort(compareText)) {
    const values = {
      path: filePath,
      base: trees.base.get(filePath) ?? null,
      ours: trees.ours.get(filePath) ?? null,
      theirs: trees.theirs.get(filePath) ?? null,
      merged: trees.merged.get(filePath) ?? null,
    };
    const identities = [values.base, values.ours, values.theirs, values.merged]
      .map(entryIdentity);
    if (identities.every((identity) => identity === identities[0])) continue;
    paths.push(classifyMergePath(values));
  }
  return paths;
}

/**
 * Validates explicit discarded-file acknowledgements. Receipt rows use the
 * stable key (category, path) and require a non-empty reason.
 */
export function evaluateDiscardReceipts(paths, receiptDocument = null) {
  const expected = paths
    .filter((entry) => discardedCategories.has(entry.category))
    .map(({path: filePath, category}) => ({path: filePath, category}))
    .sort(compareReceiptRows);
  const expectedKeys = new Set(expected.map(receiptKey));
  const rows = receiptDocument?.discardedFiles ?? [];
  const acknowledged = [];
  const invalid = [];
  const seen = new Set();

  if (receiptDocument != null && receiptDocument.schemaVersion !== 1) {
    invalid.push({
      reason: "receipt schemaVersion must be 1",
      value: receiptDocument.schemaVersion ?? null,
    });
  }
  if (!Array.isArray(rows)) {
    invalid.push({reason: "receipt discardedFiles must be an array"});
  } else {
    for (const [index, row] of rows.entries()) {
      if (
        row == null ||
        typeof row !== "object" ||
        typeof row.path !== "string" ||
        !discardedCategories.has(row.category) ||
        typeof row.reason !== "string" ||
        row.reason.trim() === ""
      ) {
        invalid.push({
          index,
          reason:
            "receipt row requires path, discarded-ours/discarded-theirs category, and non-empty reason",
        });
        continue;
      }
      const normalized = {
        path: row.path,
        category: row.category,
        reason: row.reason.trim(),
      };
      const key = receiptKey(normalized);
      if (seen.has(key)) {
        invalid.push({index, path: row.path, category: row.category, reason: "duplicate receipt"});
        continue;
      }
      seen.add(key);
      if (!expectedKeys.has(key)) {
        invalid.push({
          index,
          path: row.path,
          category: row.category,
          reason: "receipt does not match a discarded path",
        });
        continue;
      }
      acknowledged.push(normalized);
    }
  }

  acknowledged.sort(compareReceiptRows);
  const acknowledgedKeys = new Set(acknowledged.map(receiptKey));
  const missing = expected.filter((entry) => !acknowledgedKeys.has(receiptKey(entry)));
  return {
    provided: receiptDocument != null,
    expected,
    acknowledged,
    missing,
    invalid,
    strictPass: missing.length === 0 && invalid.length === 0,
  };
}

/** Pure report builder with a stable JSON schema. */
export function buildMergeAuditReport({refs, trees, receiptDocument = null}) {
  const paths = classifyMergeTrees(trees);
  const categoryCounts = Object.fromEntries(categoryOrder.map((name) => [name, 0]));
  for (const entry of paths) categoryCounts[entry.category] += 1;
  const receipts = evaluateDiscardReceipts(paths, receiptDocument);
  return {
    schemaVersion: 1,
    tool: "audit-merge-drops",
    refs,
    summary: {
      changedPaths: paths.length,
      ...categoryCounts,
      discardedPaths: receipts.expected.length,
      unreceiptedDiscardedPaths: receipts.missing.length,
      invalidReceipts: receipts.invalid.length,
    },
    categories: Object.fromEntries(
      categoryOrder.map((name) => [
        name,
        paths.filter((entry) => entry.category === name).map((entry) => entry.path),
      ]),
    ),
    paths,
    receipts,
  };
}

function runCli() {
  try {
    const args = parseArgs(process.argv.slice(2));
    if (args.help) {
      printHelp();
      return;
    }
    for (const name of ["base", "ours", "theirs", "merged"]) {
      if (!args[name]) throw new CliUsageError(`Missing required --${name} ref.`);
    }

    const refs = {};
    const trees = {};
    for (const name of ["base", "ours", "theirs", "merged"]) {
      refs[name] = resolveRef(args.repo, args[name]);
      trees[name] = readTree(args.repo, refs[name].commit);
    }
    const receiptDocument = args.receipt
      ? JSON.parse(fs.readFileSync(args.receipt, "utf8"))
      : null;
    const report = buildMergeAuditReport({refs, trees, receiptDocument});

    if (args.json) console.log(JSON.stringify(report, null, 2));
    else printHumanReport(report, args.receipt);
    if (args.strict && !report.receipts.strictPass) process.exitCode = 1;
  } catch (error) {
    console.error(error instanceof Error ? error.message : String(error));
    if (error instanceof CliUsageError) printHelp();
    process.exitCode = error instanceof CliUsageError ? 64 : 2;
  }
}

function parseArgs(argv) {
  const parsed = {
    base: null,
    help: false,
    json: false,
    merged: null,
    ours: null,
    receipt: null,
    repo: defaultRepoRoot,
    strict: false,
    theirs: null,
  };
  for (let index = 0; index < argv.length; index += 1) {
    const arg = argv[index];
    if (arg === "--help" || arg === "-h") parsed.help = true;
    else if (arg === "--json") parsed.json = true;
    else if (arg === "--strict") parsed.strict = true;
    else if (["--base", "--ours", "--theirs", "--merged"].includes(arg)) {
      parsed[arg.slice(2)] = requireValue(argv, (index += 1), arg);
    } else if (arg === "--repo") {
      parsed.repo = path.resolve(requireValue(argv, (index += 1), arg));
    } else if (arg === "--receipt") {
      parsed.receipt = path.resolve(requireValue(argv, (index += 1), arg));
    } else {
      throw new CliUsageError(`Unknown argument: ${arg}`);
    }
  }
  return parsed;
}

function resolveRef(repo, ref) {
  const commit = runGit(repo, [
    "rev-parse",
    "--verify",
    `${ref}^{commit}`,
  ]).trim();
  return {
    input: ref,
    commit,
    tree: runGit(repo, ["rev-parse", "--verify", `${commit}^{tree}`]).trim(),
  };
}

function readTree(repo, ref) {
  return parseLsTree(runGit(repo, ["ls-tree", "-r", "-z", "--full-tree", ref]));
}

function runGit(repo, args) {
  const result = spawnSync("git", args, {
    cwd: repo,
    encoding: "utf8",
    maxBuffer: 64 * 1024 * 1024,
  });
  if (result.status !== 0) {
    throw new Error(
      (result.stderr || `git ${args.join(" ")} failed with status ${result.status}`).trim(),
    );
  }
  return result.stdout;
}

function printHumanReport(report, receiptPath) {
  console.log(
    `Merge-drop audit: ${report.summary.changedPaths} changed path(s), ` +
      `${report.summary.discardedPaths} exact discard(s).`,
  );
  for (const category of categoryOrder) {
    const rows = report.categories[category];
    console.log(`${category}: ${rows.length}`);
    for (const filePath of rows) console.log(`  ${filePath}`);
  }
  if (report.receipts.missing.length > 0) {
    console.log("Unreceipted discarded paths:");
    for (const row of report.receipts.missing) {
      console.log(`  ${row.category}: ${row.path}`);
    }
    if (!receiptPath) {
      console.log("Pass --receipt <json> and --strict to enforce acknowledgements.");
    }
  }
  if (report.receipts.invalid.length > 0) {
    console.log(`Invalid receipt row(s): ${report.receipts.invalid.length}`);
  }
}

function printHelp() {
  console.log(`Usage:
  node tool/git/audit_merge_drops.mjs \\
    --base <ref> --ours <ref> --theirs <ref> --merged <ref> \\
    [--receipt <json>] [--strict] [--json] [--repo <path>]

Classifies every path whose exact Git tree entry differs across the four refs.
Additions and deletions are represented as null entries. In --strict mode,
every discarded-ours/discarded-theirs path must appear in a schemaVersion 1
receipt document:

  {"schemaVersion":1,"discardedFiles":[
    {"path":"path/to/file","category":"discarded-ours","reason":"why"}
  ]}`);
}

function entryIdentity(entry) {
  if (entry == null) return null;
  return `${entry.mode}:${entry.type}:${entry.oid}`;
}

function publicEntry(entry) {
  if (entry == null) return null;
  return {mode: entry.mode, type: entry.type, oid: entry.oid};
}

function toEntryMap(value) {
  if (value instanceof Map) return value;
  return new Map(Object.entries(value ?? {}));
}

function receiptKey(row) {
  return `${row.category}\0${row.path}`;
}

function compareReceiptRows(left, right) {
  return compareText(left.category, right.category) || compareText(left.path, right.path);
}

function compareText(left, right) {
  return left < right ? -1 : left > right ? 1 : 0;
}

function requireValue(argv, index, flag) {
  const value = argv[index];
  if (!value || value.startsWith("--")) {
    throw new CliUsageError(`${flag} requires a value.`);
  }
  return value;
}

class CliUsageError extends Error {}

if (isCliEntrypoint) runCli();
