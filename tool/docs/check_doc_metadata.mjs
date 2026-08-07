#!/usr/bin/env node

import fs from "node:fs";
import path from "node:path";
import {spawnSync} from "node:child_process";
import {fileURLToPath} from "node:url";

const repoRoot = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "../..");
const governedKeys = ["doc_id", "version", "updated", "owner", "status"];
const isCliEntrypoint =
  process.argv[1] != null &&
  path.resolve(process.argv[1]) === fileURLToPath(import.meta.url);

export class DocumentMetadataError extends Error {}

export function parseSemanticVersion(value) {
  if (typeof value !== "string" || value.trim() !== value || value === "") {
    throw new DocumentMetadataError(`Invalid semantic version: ${JSON.stringify(value)}`);
  }
  const match = new RegExp(
    "^(0|[1-9]\\d*)(?:\\.(0|[1-9]\\d*))?(?:\\.(0|[1-9]\\d*))?" +
      "(?:-([0-9A-Za-z-]+(?:\\.[0-9A-Za-z-]+)*))?" +
      "(?:\\+([0-9A-Za-z-]+(?:\\.[0-9A-Za-z-]+)*))?$",
    "u",
  ).exec(value);
  if (!match) throw new DocumentMetadataError(`Invalid semantic version: ${value}`);
  const prerelease = match[4] == null ? [] : match[4].split(".");
  for (const identifier of prerelease) {
    if (/^\\d+$/u.test(identifier) && identifier.length > 1 && identifier.startsWith("0")) {
      throw new DocumentMetadataError(
        `Invalid semantic version prerelease identifier: ${value}`,
      );
    }
  }
  return {
    raw: value,
    major: Number(match[1]),
    minor: Number(match[2] ?? 0),
    patch: Number(match[3] ?? 0),
    prerelease,
  };
}

export function compareSemanticVersions(left, right) {
  const a = typeof left === "string" ? parseSemanticVersion(left) : left;
  const b = typeof right === "string" ? parseSemanticVersion(right) : right;
  for (const field of ["major", "minor", "patch"]) {
    if (a[field] < b[field]) return -1;
    if (a[field] > b[field]) return 1;
  }
  if (a.prerelease.length === 0 && b.prerelease.length === 0) return 0;
  if (a.prerelease.length === 0) return 1;
  if (b.prerelease.length === 0) return -1;
  const length = Math.max(a.prerelease.length, b.prerelease.length);
  for (let index = 0; index < length; index += 1) {
    const leftPart = a.prerelease[index];
    const rightPart = b.prerelease[index];
    if (leftPart == null) return -1;
    if (rightPart == null) return 1;
    if (leftPart === rightPart) continue;
    const leftNumeric = /^\\d+$/u.test(leftPart);
    const rightNumeric = /^\\d+$/u.test(rightPart);
    if (leftNumeric && rightNumeric) {
      return Number(leftPart) < Number(rightPart) ? -1 : 1;
    }
    if (leftNumeric !== rightNumeric) return leftNumeric ? -1 : 1;
    return leftPart < rightPart ? -1 : 1;
  }
  return 0;
}

export function parseFrontmatter(source) {
  if (typeof source !== "string") return null;
  const lines = source.replaceAll("\r\n", "\n").split("\n");
  if (lines[0] !== "---") return null;
  const values = new Map();
  for (let index = 1; index < lines.length; index += 1) {
    const line = lines[index];
    if (line === "---") return {values, endLine: index + 1};
    const match = /^([A-Za-z][A-Za-z0-9_-]*):\s*(.*)$/u.exec(line);
    if (!match) continue;
    const key = match[1];
    if (values.has(key)) {
      throw new DocumentMetadataError(`Frontmatter key appears more than once: ${key}`);
    }
    values.set(key, parseScalar(match[2]));
  }
  throw new DocumentMetadataError("Frontmatter is missing its closing delimiter.");
}

/** Returns the normalized lifecycle token, or null for an ungoverned document. */
export function parseDocumentLifecycleStatus(source) {
  let frontmatter;
  try {
    frontmatter = parseFrontmatter(source);
  } catch {
    return null;
  }
  const raw = frontmatter?.values.get("status");
  return normalizeLifecycleStatus(raw);
}

export function parseGovernedDocument(
  documentPath,
  source,
  {validateCurrentContracts = true} = {},
) {
  let frontmatter;
  try {
    frontmatter = parseFrontmatter(source);
  } catch (error) {
    if (!source.startsWith("---")) return null;
    throw new DocumentMetadataError(`${documentPath}: ${error.message}`);
  }
  if (frontmatter == null) return null;
  if (
    validateCurrentContracts &&
    normalizePath(documentPath) === "docs/widget_catalog.md"
  ) {
    const violation = widgetCatalogViolation(source);
    if (violation != null) {
      throw new DocumentMetadataError(`${documentPath}: ${violation}`);
    }
  }
  const values = frontmatter.values;
  const participates = ["doc_id", "version", "updated", "owner"].some((key) =>
    values.has(key));
  if (!participates) return null;

  const missing = governedKeys.filter((key) => !values.get(key));
  if (missing.length > 0) {
    throw new DocumentMetadataError(
      `${documentPath}: governed frontmatter is missing ${missing.join(", ")}.`,
    );
  }
  const docId = values.get("doc_id");
  if (!/^[A-Za-z0-9_.-]+$/u.test(docId)) {
    throw new DocumentMetadataError(`${documentPath}: invalid doc_id ${JSON.stringify(docId)}.`);
  }
  const version = values.get("version");
  parseSemanticVersion(version);
  const updated = values.get("updated");
  const parsedDate = /^\d{4}-\d{2}-\d{2}$/u.test(updated)
    ? new Date(`${updated}T00:00:00Z`)
    : null;
  if (parsedDate == null || Number.isNaN(parsedDate.valueOf()) || parsedDate.toISOString().slice(0, 10) !== updated) {
    throw new DocumentMetadataError(`${documentPath}: invalid updated date ${JSON.stringify(updated)}.`);
  }
  const status = normalizeLifecycleStatus(values.get("status"));
  if (status == null) {
    throw new DocumentMetadataError(`${documentPath}: invalid lifecycle status.`);
  }
  return {
    id: docId,
    path: normalizePath(documentPath),
    version,
    updated,
    owner: values.get("owner"),
    status,
  };
}

export function widgetCatalogViolation(source) {
  if (/^## Rule Changelog$/mu.test(source) || /^### \d+\.\d+\.\d+$/mu.test(source)) {
    return "current inventory must not contain an inline changelog";
  }
  if (!/^## Maintenance Contract$/mu.test(source)) {
    return "maintenance contract is missing";
  }
  const marker = source.indexOf("\n## App Entry Point\n");
  if (marker === -1) return "current widget inventory marker is missing";
  const line = source.slice(0, marker).split("\n").length + 1;
  if (line > 350) return `current widget inventory starts too late at line ${line}`;
  return null;
}

export function collectGovernedDocuments({
  paths,
  readSource,
  validateCurrentContracts = true,
}) {
  const documents = [];
  const byId = new Map();
  for (const documentPath of [...paths].filter((entry) => entry.endsWith(".md")).sort()) {
    const metadata = parseGovernedDocument(documentPath, readSource(documentPath), {
      validateCurrentContracts,
    });
    if (metadata == null) continue;
    const previous = byId.get(metadata.id);
    if (previous != null) {
      throw new DocumentMetadataError(
        `Duplicate doc_id ${metadata.id}: ${previous.path} and ${metadata.path}.`,
      );
    }
    byId.set(metadata.id, metadata);
    documents.push(metadata);
  }
  return documents;
}

export function compareDocumentMetadata({baseDocuments, currentDocuments}) {
  const currentById = new Map(currentDocuments.map((entry) => [entry.id, entry]));
  const currentByPath = new Map(currentDocuments.map((entry) => [entry.path, entry]));
  const findings = [];
  const deletions = [];
  const increases = [];
  const unchanged = [];
  for (const base of baseDocuments) {
    const current = currentById.get(base.id);
    if (current == null) {
      const replacement = currentByPath.get(base.path);
      if (replacement != null) {
        findings.push({
          kind: "doc-id-changed",
          id: base.id,
          path: base.path,
          currentId: replacement.id,
          reason: "document identity changed at an existing path",
        });
      } else {
        deletions.push({
          id: base.id,
          path: base.path,
          version: base.version,
          baseStatus: base.status,
        });
      }
      continue;
    }
    const comparison = compareSemanticVersions(current.version, base.version);
    const row = {
      id: base.id,
      basePath: base.path,
      currentPath: current.path,
      baseVersion: base.version,
      currentVersion: current.version,
    };
    if (comparison < 0) {
      findings.push({
        kind: "version-decrease",
        ...row,
        reason: "source frontmatter version decreased",
      });
    } else if (comparison > 0) {
      increases.push(row);
    } else {
      unchanged.push(row);
    }
  }
  const baseIds = new Set(baseDocuments.map((entry) => entry.id));
  const additions = currentDocuments
    .filter((entry) => !baseIds.has(entry.id))
    .map(({id, path: documentPath, version}) => ({id, path: documentPath, version}));
  for (const rows of [findings, deletions, increases, unchanged, additions]) {
    rows.sort((left, right) =>
      String(left.id).localeCompare(String(right.id)) ||
      String(left.path ?? left.currentPath ?? "").localeCompare(
        String(right.path ?? right.currentPath ?? ""),
      ));
  }
  return {
    pass: findings.length === 0,
    findings,
    deletions,
    increases,
    unchanged,
    additions,
  };
}

export function runSelfTest() {
  const base = [
    {id: "decrease", path: "docs/decrease.md", version: "2.0.0", status: "active"},
    {id: "deleted", path: "docs/deleted.md", version: "1.0.0", status: "active"},
  ];
  const current = [
    {id: "decrease", path: "docs/decrease.md", version: "1.9.9", status: "active"},
  ];
  const result = compareDocumentMetadata({baseDocuments: base, currentDocuments: current});
  return {
    pass:
      !result.pass &&
      result.findings.some((entry) => entry.kind === "version-decrease") &&
      result.deletions.some((entry) => entry.id === "deleted"),
    findings: result.findings,
  };
}

function parseScalar(rawValue) {
  const value = rawValue.trim();
  const doubleQuoted = /^"([^"\\]*(?:\\.[^"\\]*)*)"(?:\s+#.*)?$/u.exec(value);
  if (doubleQuoted) return JSON.parse(`"${doubleQuoted[1]}"`);
  const singleQuoted = /^'([^']*)'(?:\s+#.*)?$/u.exec(value);
  if (singleQuoted) return singleQuoted[1].replaceAll("''", "'");
  return value.replace(/\s+#.*$/u, "").trim();
}

function normalizeLifecycleStatus(value) {
  if (typeof value !== "string") return null;
  return /^([A-Za-z0-9_-]+)/u.exec(value)?.[1] ?? null;
}

function parseArgs(argv) {
  const args = {
    base: null,
    help: false,
    json: false,
    ref: null,
    repo: repoRoot,
    selfTest: false,
  };
  for (let index = 0; index < argv.length; index += 1) {
    const arg = argv[index];
    if (arg === "--base") args.base = requireValue(argv, (index += 1), arg);
    else if (arg === "--ref") args.ref = requireValue(argv, (index += 1), arg);
    else if (arg === "--repo") args.repo = path.resolve(requireValue(argv, (index += 1), arg));
    else if (arg === "--json") args.json = true;
    else if (arg === "--self-test") args.selfTest = true;
    else if (arg === "--help" || arg === "-h") args.help = true;
    else throw new DocumentMetadataError(`Unknown argument: ${arg}`);
  }
  return args;
}

function requireValue(argv, index, flag) {
  const value = argv[index];
  if (value == null || value.startsWith("--")) {
    throw new DocumentMetadataError(`${flag} requires a value.`);
  }
  return value;
}

function targetSnapshot({repo, ref}) {
  const paths = ref == null ? listWorkingTreePaths(repo) : listRefPaths(repo, ref);
  const sourceRevision = ref == null
    ? runGit(repo, ["rev-parse", "HEAD"]).trim()
    : runGit(repo, ["rev-parse", `${ref}^{commit}`]).trim();
  const readSource = ref == null
    ? (documentPath) => {
        const workingPath = path.join(repo, documentPath);
        return fs.existsSync(workingPath)
          ? fs.readFileSync(workingPath, "utf8")
          : runGit(repo, ["show", `:${documentPath}`]);
      }
    : (documentPath) => runGit(repo, ["show", `${ref}:${documentPath}`]);
  return {
    paths,
    sourceRevision,
    readSource,
  };
}

function listWorkingTreePaths(repo) {
  const paths = new Set(
    runGit(repo, ["ls-files", "-z", "--cached", "--others", "--exclude-standard"])
      .split("\0")
      .filter(Boolean)
      .map(normalizePath),
  );
  for (const deleted of runGit(repo, ["ls-files", "-z", "--deleted"])
    .split("\0")
    .filter(Boolean)
    .map(normalizePath)) {
    paths.delete(deleted);
  }
  return paths;
}

function listRefPaths(repo, ref) {
  return new Set(
    runGit(repo, ["ls-tree", "-r", "-z", "--name-only", "--full-tree", ref])
      .split("\0")
      .filter(Boolean)
      .map(normalizePath),
  );
}

function normalizePath(value) {
  return value.split(path.sep).join("/").replace(/^\.\//u, "");
}

function runGit(repo, args) {
  const result = spawnSync("git", args, {
    cwd: repo,
    encoding: "utf8",
    maxBuffer: 64 * 1024 * 1024,
  });
  if (result.status !== 0) {
    throw new DocumentMetadataError(
      (result.stderr || `git ${args.join(" ")} failed with status ${result.status}`).trim(),
    );
  }
  return result.stdout;
}

function printHelp() {
  console.log(`Usage: node tool/docs/check_doc_metadata.mjs [options]

Options:
  --base <ref>    Reject source-frontmatter identity swaps and version decreases.
  --ref <ref>     Inspect an exact Git revision instead of the working tree.
  --json          Print the comparison report as JSON.
  --self-test     Prove known-bad decrease and deletion detection.
`);
}

function main() {
  try {
    const args = parseArgs(process.argv.slice(2));
    if (args.help) {
      printHelp();
      return;
    }
    if (args.selfTest) {
      const selfTest = runSelfTest();
      if (args.json) console.log(JSON.stringify({selfTest}, null, 2));
      else console.log(selfTest.pass ? "Document metadata self-test passed." : "Document metadata self-test failed.");
      if (!selfTest.pass) process.exitCode = 1;
      return;
    }

    const target = targetSnapshot({repo: args.repo, ref: args.ref});
    const currentDocuments = collectGovernedDocuments(target);
    let comparison = {
      pass: true,
      findings: [],
      deletions: [],
      increases: [],
      unchanged: [],
      additions: currentDocuments.map(({id, path: documentPath, version}) => ({
        id,
        path: documentPath,
        version,
      })),
    };
    let baseRevision = null;
    if (args.base != null) {
      const base = targetSnapshot({repo: args.repo, ref: args.base});
      baseRevision = base.sourceRevision;
      comparison = compareDocumentMetadata({
        baseDocuments: collectGovernedDocuments({
          ...base,
          validateCurrentContracts: false,
        }),
        currentDocuments,
      });
    }
    const report = {
      schemaVersion: "1.0.0",
      baseRevision,
      targetRevision: target.sourceRevision,
      governedDocuments: currentDocuments.length,
      ...comparison,
    };
    if (args.json) console.log(JSON.stringify(report, null, 2));
    else if (!comparison.pass) {
      console.error("Document metadata check failed:");
      for (const finding of comparison.findings) {
        console.error(`- ${finding.id}: ${finding.reason}`);
      }
    } else {
      console.log(
        `Document metadata passed: ${currentDocuments.length} source-governed Markdown files.`,
      );
    }
    if (!comparison.pass) process.exitCode = 1;
  } catch (error) {
    console.error(error instanceof Error ? error.message : String(error));
    process.exitCode = error instanceof DocumentMetadataError ? 1 : 2;
  }
}

if (isCliEntrypoint) main();
