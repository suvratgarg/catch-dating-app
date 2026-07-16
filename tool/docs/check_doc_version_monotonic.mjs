#!/usr/bin/env node
import fs from "node:fs";
import path from "node:path";
import {spawnSync} from "node:child_process";
import {fileURLToPath} from "node:url";

const defaultCatalogPath = "docs/audit_registry/doc_versions.json";
const defaultRepoRoot = path.resolve(
  path.dirname(fileURLToPath(import.meta.url)),
  "../..",
);
const isCliEntrypoint =
  process.argv[1] != null &&
  path.resolve(process.argv[1]) === fileURLToPath(import.meta.url);

/**
 * Parses SemVer with one, two, or three numeric core components. Catch's
 * governed catalog historically contains both `16` and `1.2.3`; omitted minor
 * or patch components are normalized to zero before comparison.
 */
export function parseSemanticVersion(value) {
  if (typeof value !== "string" || value.trim() !== value || value === "") {
    throw new Error(`Invalid semantic version: ${JSON.stringify(value)}`);
  }
  const match = new RegExp(
    "^(0|[1-9]\\d*)(?:\\.(0|[1-9]\\d*))?(?:\\.(0|[1-9]\\d*))?" +
      "(?:-([0-9A-Za-z-]+(?:\\.[0-9A-Za-z-]+)*))?" +
      "(?:\\+([0-9A-Za-z-]+(?:\\.[0-9A-Za-z-]+)*))?$",
    "u",
  ).exec(value);
  if (!match) throw new Error(`Invalid semantic version: ${value}`);
  const prerelease = match[4] == null ? [] : match[4].split(".");
  for (const identifier of prerelease) {
    if (/^\d+$/u.test(identifier) && identifier.length > 1 && identifier.startsWith("0")) {
      throw new Error(`Invalid semantic version prerelease identifier: ${value}`);
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

/** Returns -1, 0, or 1 using Semantic Version precedence. */
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
    const leftNumeric = /^\d+$/u.test(leftPart);
    const rightNumeric = /^\d+$/u.test(rightPart);
    if (leftNumeric && rightNumeric) {
      return Number(leftPart) < Number(rightPart) ? -1 : 1;
    }
    if (leftNumeric !== rightNumeric) return leftNumeric ? -1 : 1;
    return compareText(leftPart, rightPart);
  }
  return 0;
}

/**
 * Pure catalog comparator. It fails only when an existing governed identity
 * decreases semantically or loses its catalog/path governance. Increases,
 * unchanged versions, and newly governed docs are explicitly reported and
 * allowed.
 */
export function compareDocVersionCatalogs({
  baseCatalog,
  currentCatalog,
  currentDocumentPaths = null,
}) {
  const baseEntries = normalizeCatalog(baseCatalog, "base");
  const currentEntries = normalizeCatalog(currentCatalog, "current", {
    allowIncomplete: true,
  });
  const currentById = new Map(currentEntries.map((entry) => [entry.id, entry]));
  const currentByPath = new Map();
  for (const entry of currentEntries) {
    if (entry.path == null) continue;
    if (currentByPath.has(entry.path)) {
      throw new Error(`Current catalog has duplicate governed path: ${entry.path}`);
    }
    currentByPath.set(entry.path, entry);
  }

  const matchedCurrentIds = new Set();
  const increases = [];
  const unchanged = [];
  const catalogVersion = compareCatalogMetadataVersion(
    baseCatalog.version,
    currentCatalog.version,
  );
  const findings = [...catalogVersion.findings];

  for (const base of baseEntries) {
    const current = currentById.get(base.id) ?? currentByPath.get(base.path);
    if (!current) {
      findings.push({
        kind: "removal-inconsistency",
        id: base.id,
        path: base.path,
        baseVersion: base.version,
        currentVersion: null,
        reason: "governed catalog entry was removed",
      });
      continue;
    }
    matchedCurrentIds.add(current.id);
    if (current.incompleteReason != null) {
      findings.push({
        kind: "removal-inconsistency",
        id: base.id,
        currentId: current.id,
        path: current.path ?? base.path,
        baseVersion: base.version,
        currentVersion: current.version,
        reason: current.incompleteReason,
      });
      continue;
    }
    if (currentDocumentPaths != null && !currentDocumentPaths.has(current.path)) {
      findings.push({
        kind: "removal-inconsistency",
        id: base.id,
        currentId: current.id,
        path: current.path,
        baseVersion: base.version,
        currentVersion: current.version,
        reason: "governed document path is missing from the target",
      });
      continue;
    }
    const comparison = compareSemanticVersions(current.version, base.version);
    const row = {
      id: base.id,
      currentId: current.id,
      basePath: base.path,
      currentPath: current.path,
      baseVersion: base.version,
      currentVersion: current.version,
    };
    if (comparison < 0) {
      findings.push({
        kind: "version-decrease",
        ...row,
        reason: "governed document version decreased",
      });
    } else if (comparison > 0) {
      increases.push(row);
    } else {
      unchanged.push(row);
    }
  }

  const unmatchedCurrent = currentEntries.filter(
    (entry) => !matchedCurrentIds.has(entry.id),
  );
  const incompleteAddition = unmatchedCurrent.find(
    (entry) => entry.incompleteReason != null,
  );
  if (incompleteAddition) {
    throw new Error(
      `Current catalog addition ${incompleteAddition.id} is incomplete: ` +
        incompleteAddition.incompleteReason,
    );
  }
  const additions = unmatchedCurrent
    .map(({id, path: entryPath, version}) => ({id, path: entryPath, version}))
    .sort(compareCatalogRows);
  increases.sort(compareCatalogRows);
  unchanged.sort(compareCatalogRows);
  findings.sort(compareFindings);
  return {
    baseGoverned: baseEntries.length,
    currentGoverned: currentEntries.length,
    increases,
    unchanged,
    additions,
    findings,
    catalogVersion: {
      baseVersion: catalogVersion.baseVersion,
      currentVersion: catalogVersion.currentVersion,
      status: catalogVersion.status,
    },
    pass: findings.length === 0,
  };
}

/** Pure stable report builder used by CLI and tests. */
export function buildDocVersionReport({
  base,
  target,
  baseCatalog,
  currentCatalog,
  currentDocumentPaths = null,
}) {
  const comparison = compareDocVersionCatalogs({
    baseCatalog,
    currentCatalog,
    currentDocumentPaths,
  });
  return {
    schemaVersion: 1,
    tool: "doc-version-monotonic",
    base,
    target,
    summary: {
      baseGoverned: comparison.baseGoverned,
      currentGoverned: comparison.currentGoverned,
      catalogVersionStatus: comparison.catalogVersion.status,
      increases: comparison.increases.length,
      unchanged: comparison.unchanged.length,
      additions: comparison.additions.length,
      versionDecreases: comparison.findings.filter(
        (finding) => finding.kind === "version-decrease",
      ).length,
      removalInconsistencies: comparison.findings.filter(
        (finding) => finding.kind === "removal-inconsistency",
      ).length,
      pass: comparison.pass,
    },
    increases: comparison.increases,
    unchanged: comparison.unchanged,
    additions: comparison.additions,
    catalogVersion: comparison.catalogVersion,
    findings: comparison.findings,
  };
}

/** Known-bad anti-vacuity proof used by --self-test and manifest wiring. */
export function runSelfTest() {
  const baseCatalog = {
    decreasing: {path: "docs/decreasing.md", version: "2.4.0"},
    removed: {path: "docs/removed.md", version: "1"},
    increasing: {path: "docs/increasing.md", version: "1.2"},
    unchanged: {path: "docs/unchanged.md", version: "3.0.0"},
  };
  const currentCatalog = {
    decreasing: {path: "docs/decreasing.md", version: "2.3.9"},
    increasing: {path: "docs/increasing.md", version: "1.3.0"},
    unchanged: {path: "docs/unchanged.md", version: "3"},
  };
  const result = compareDocVersionCatalogs({
    baseCatalog,
    currentCatalog,
    currentDocumentPaths: new Set([
      "docs/decreasing.md",
      "docs/increasing.md",
      "docs/unchanged.md",
    ]),
  });
  const kinds = result.findings.map((finding) => finding.kind);
  if (
    kinds.filter((kind) => kind === "version-decrease").length !== 1 ||
    kinds.filter((kind) => kind === "removal-inconsistency").length !== 1 ||
    result.increases.length !== 1 ||
    result.unchanged.length !== 1
  ) {
    throw new Error("Doc-version self-test failed to detect the known-bad fixture.");
  }
  return {
    schemaVersion: 1,
    tool: "doc-version-monotonic",
    selfTest: {
      pass: true,
      knownBadFindings: result.findings,
      allowedIncreases: result.increases.length,
      allowedUnchanged: result.unchanged.length,
    },
  };
}

function runCli() {
  try {
    const args = parseArgs(process.argv.slice(2));
    if (args.help) {
      printHelp();
      return;
    }
    if (args.selfTest) {
      const result = runSelfTest();
      if (args.json) console.log(JSON.stringify(result, null, 2));
      else {
        console.log(
          "Doc-version monotonic self-test passed " +
            "(known-bad decrease and removal detected).",
        );
      }
      return;
    }
    if (!args.base) throw new CliUsageError("Missing required --base ref.");

    const catalogPath = repoRelativePath(args.repo, args.catalog);
    const baseCommit = resolveCommit(args.repo, args.base);
    const baseCatalog = readCatalogFromRef(args.repo, baseCommit, catalogPath);
    const base = {
      input: args.base,
      commit: baseCommit,
      catalog: catalogPath,
    };

    let currentCatalog;
    let currentDocumentPaths;
    let target;
    if (args.target) {
      const targetCommit = resolveCommit(args.repo, args.target);
      currentCatalog = readCatalogFromRef(args.repo, targetCommit, catalogPath);
      currentDocumentPaths = listRefPaths(args.repo, targetCommit);
      target = {
        kind: "git-ref",
        input: args.target,
        commit: targetCommit,
        catalog: catalogPath,
      };
    } else {
      currentCatalog = readCatalogFromWorkingTree(args.repo, catalogPath);
      currentDocumentPaths = existingCatalogPaths(args.repo, currentCatalog);
      target = {kind: "working-tree", input: null, commit: null, catalog: catalogPath};
    }

    const report = buildDocVersionReport({
      base,
      target,
      baseCatalog,
      currentCatalog,
      currentDocumentPaths,
    });
    if (args.json) console.log(JSON.stringify(report, null, 2));
    else printHumanReport(report);
    if (!report.summary.pass) process.exitCode = 1;
  } catch (error) {
    console.error(error instanceof Error ? error.message : String(error));
    if (error instanceof CliUsageError) printHelp();
    process.exitCode = error instanceof CliUsageError ? 64 : 2;
  }
}

function normalizeCatalog(catalog, label, {allowIncomplete = false} = {}) {
  if (catalog == null || typeof catalog !== "object" || Array.isArray(catalog)) {
    throw new Error(`${label} doc-version catalog must be a JSON object.`);
  }
  return Object.entries(catalog)
    .map(([id, value]) => {
      // doc_versions.json carries its own version as top-level metadata. The
      // audit_doc_versions governed entry tracks that file as a document, so
      // this scalar is validated but is not a second governed document row.
      if (id === "version") {
        if (typeof value === "string") parseSemanticVersion(value);
        return null;
      }
      if (value == null || typeof value !== "object" || Array.isArray(value)) {
        if (allowIncomplete) {
          return {
            id,
            path: null,
            version: null,
            incompleteReason: "governed catalog metadata was removed",
          };
        }
        throw new Error(`${label} catalog entry ${id} must be an object.`);
      }
      if (typeof value.path !== "string" || value.path === "") {
        if (allowIncomplete) {
          return {
            id,
            path: null,
            version: typeof value.version === "string" ? value.version : null,
            incompleteReason: "governed document path metadata was removed",
          };
        }
        throw new Error(`${label} catalog entry ${id} is missing path governance.`);
      }
      if (typeof value.version !== "string" || value.version === "") {
        if (allowIncomplete) {
          return {
            id,
            path: normalizePath(value.path),
            version: null,
            incompleteReason: "governed document version metadata was removed",
          };
        }
        throw new Error(`${label} catalog entry ${id} is missing version governance.`);
      }
      parseSemanticVersion(value.version);
      return {
        id,
        path: normalizePath(value.path),
        version: value.version,
        incompleteReason: null,
      };
    })
    .filter(Boolean)
    .sort(compareCatalogRows);
}

function compareCatalogMetadataVersion(baseVersion, currentVersion) {
  if (baseVersion == null) {
    if (currentVersion != null && typeof currentVersion !== "string") {
      throw new Error("Current catalog top-level version must be a semantic version string.");
    }
    if (typeof currentVersion === "string") parseSemanticVersion(currentVersion);
    return {
      baseVersion: null,
      currentVersion: currentVersion ?? null,
      status: currentVersion == null ? "not-governed" : "added",
      findings: [],
    };
  }
  if (typeof baseVersion !== "string") {
    throw new Error("Base catalog top-level version must be a semantic version string.");
  }
  parseSemanticVersion(baseVersion);
  if (typeof currentVersion !== "string") {
    return {
      baseVersion,
      currentVersion: null,
      status: "removed",
      findings: [
        {
          kind: "removal-inconsistency",
          id: "$catalog",
          path: null,
          baseVersion,
          currentVersion: null,
          reason: "catalog top-level version metadata was removed",
        },
      ],
    };
  }
  const comparison = compareSemanticVersions(currentVersion, baseVersion);
  if (comparison < 0) {
    return {
      baseVersion,
      currentVersion,
      status: "decreased",
      findings: [
        {
          kind: "version-decrease",
          id: "$catalog",
          path: null,
          baseVersion,
          currentVersion,
          reason: "catalog top-level version decreased",
        },
      ],
    };
  }
  return {
    baseVersion,
    currentVersion,
    status: comparison > 0 ? "increased" : "unchanged",
    findings: [],
  };
}

function parseArgs(argv) {
  const parsed = {
    base: null,
    catalog: defaultCatalogPath,
    help: false,
    json: false,
    repo: defaultRepoRoot,
    selfTest: false,
    target: null,
  };
  for (let index = 0; index < argv.length; index += 1) {
    const arg = argv[index];
    if (arg === "--help" || arg === "-h") parsed.help = true;
    else if (arg === "--json") parsed.json = true;
    else if (arg === "--self-test") parsed.selfTest = true;
    else if (arg === "--base") parsed.base = requireValue(argv, (index += 1), arg);
    else if (arg === "--target") parsed.target = requireValue(argv, (index += 1), arg);
    else if (arg === "--repo") parsed.repo = path.resolve(requireValue(argv, (index += 1), arg));
    else if (arg === "--catalog") parsed.catalog = requireValue(argv, (index += 1), arg);
    else throw new CliUsageError(`Unknown argument: ${arg}`);
  }
  return parsed;
}

function readCatalogFromRef(repo, ref, catalogPath) {
  return parseCatalogJson(runGit(repo, ["show", `${ref}:${catalogPath}`]), `${ref}:${catalogPath}`);
}

function readCatalogFromWorkingTree(repo, catalogPath) {
  const file = path.join(repo, catalogPath);
  if (!fs.existsSync(file)) throw new Error(`Working-tree catalog does not exist: ${catalogPath}`);
  return parseCatalogJson(fs.readFileSync(file, "utf8"), catalogPath);
}

function parseCatalogJson(source, label) {
  try {
    return JSON.parse(source);
  } catch (error) {
    throw new Error(`Failed to parse ${label}: ${error.message}`);
  }
}

function existingCatalogPaths(repo, catalog) {
  const result = new Set();
  for (const value of Object.values(catalog)) {
    if (value && typeof value.path === "string" && fs.existsSync(path.join(repo, value.path))) {
      result.add(normalizePath(value.path));
    }
  }
  return result;
}

function listRefPaths(repo, ref) {
  return new Set(
    runGit(repo, ["ls-tree", "-r", "-z", "--name-only", "--full-tree", ref])
      .split("\0")
      .filter(Boolean)
      .map(normalizePath),
  );
}

function resolveCommit(repo, ref) {
  return runGit(repo, ["rev-parse", "--verify", `${ref}^{commit}`]).trim();
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

function repoRelativePath(repo, catalogPath) {
  const absolute = path.isAbsolute(catalogPath)
    ? path.resolve(catalogPath)
    : path.resolve(repo, catalogPath);
  const relative = path.relative(repo, absolute);
  if (relative === "" || relative.startsWith("..") || path.isAbsolute(relative)) {
    throw new CliUsageError("--catalog must name a file inside --repo.");
  }
  return normalizePath(relative);
}

function printHumanReport(report) {
  const summary = report.summary;
  if (summary.pass) {
    console.log(
      `Doc-version monotonic check passed (${summary.unchanged} unchanged, ` +
        `${summary.increases} increase(s), ${summary.additions} addition(s)).`,
    );
    return;
  }
  console.error(
    `Doc-version monotonic check failed (${summary.versionDecreases} decrease(s), ` +
      `${summary.removalInconsistencies} removal inconsistency(s)).`,
  );
  for (const finding of report.findings) {
    const versions = `${finding.baseVersion} -> ${finding.currentVersion ?? "missing"}`;
    const label = finding.path ?? finding.basePath ?? finding.id;
    console.error(`- ${finding.kind}: ${label} (${versions}): ${finding.reason}`);
  }
}

function printHelp() {
  console.log(`Usage:
  node tool/docs/check_doc_version_monotonic.mjs --base <ref> \\
    [--target <ref>] [--catalog <repo-relative-json>] [--repo <path>] [--json]
  node tool/docs/check_doc_version_monotonic.mjs --self-test [--json]

Compares governed versions in docs/audit_registry/doc_versions.json (or an
explicit catalog) between a base Git ref and the working tree by default. Pass
--target to compare two Git refs. Semantic decreases and removed governance
fail; increases, unchanged versions, and new entries pass.`);
}

function compareCatalogRows(left, right) {
  return compareText(left.id, right.id);
}

function compareFindings(left, right) {
  return compareText(left.kind, right.kind) ||
    compareText(left.id ?? "", right.id ?? "") ||
    compareText(left.path ?? left.basePath ?? "", right.path ?? right.basePath ?? "");
}

function compareText(left, right) {
  return left < right ? -1 : left > right ? 1 : 0;
}

function normalizePath(filePath) {
  return filePath.split(path.sep).join("/");
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
