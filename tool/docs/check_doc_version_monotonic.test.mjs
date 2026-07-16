import assert from "node:assert/strict";
import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import {execFileSync, spawnSync} from "node:child_process";
import {fileURLToPath} from "node:url";
import test from "node:test";
import {
  buildDocVersionReport,
  compareDocVersionCatalogs,
  compareSemanticVersions,
  parseSemanticVersion,
  runSelfTest,
} from "./check_doc_version_monotonic.mjs";

const scriptPath = fileURLToPath(
  new URL("./check_doc_version_monotonic.mjs", import.meta.url),
);

test("semantic parser normalizes partial versions and honors prerelease precedence", () => {
  assert.deepEqual(parseSemanticVersion("16"), {
    raw: "16",
    major: 16,
    minor: 0,
    patch: 0,
    prerelease: [],
  });
  assert.equal(compareSemanticVersions("1.2", "1.2.0"), 0);
  assert.equal(compareSemanticVersions("1.2.1", "1.2"), 1);
  assert.equal(compareSemanticVersions("2.0.0-rc.1", "2.0.0"), -1);
  assert.throws(() => parseSemanticVersion("1.02.0"), /Invalid semantic version/u);
});

test("catalog comparator allows increases, unchanged versions, and additions", () => {
  const result = compareDocVersionCatalogs({
    baseCatalog: {
      version: "4.6.204",
      stable: {path: "docs/stable.md", version: "1.2"},
      growing: {path: "docs/growing.md", version: "2.0.0"},
    },
    currentCatalog: {
      version: "4.6.205",
      stable: {path: "docs/stable.md", version: "1.2.0"},
      growing: {path: "docs/growing.md", version: "2.1.0"},
      new_doc: {path: "docs/new.md", version: "0.1.0"},
    },
    currentDocumentPaths: new Set([
      "docs/stable.md",
      "docs/growing.md",
      "docs/new.md",
    ]),
  });

  assert.equal(result.pass, true);
  assert.equal(result.unchanged.length, 1);
  assert.equal(result.increases.length, 1);
  assert.equal(result.additions.length, 1);
  assert.deepEqual(result.catalogVersion, {
    baseVersion: "4.6.204",
    currentVersion: "4.6.205",
    status: "increased",
  });
});

test("catalog comparator fails only semantic decreases and removal inconsistencies", () => {
  const result = compareDocVersionCatalogs({
    baseCatalog: {
      decreasing: {path: "docs/decreasing.md", version: "3.0.0"},
      removed: {path: "docs/removed.md", version: "1.0.0"},
      missing_file: {path: "docs/missing.md", version: "2"},
      version_metadata_removed: {
        path: "docs/version-metadata-removed.md",
        version: "4.0.0",
      },
    },
    currentCatalog: {
      decreasing: {path: "docs/decreasing.md", version: "2.9.9"},
      missing_file: {path: "docs/missing.md", version: "2.0.0"},
      version_metadata_removed: {path: "docs/version-metadata-removed.md"},
    },
    currentDocumentPaths: new Set(["docs/decreasing.md"]),
  });

  assert.deepEqual(
    result.findings.map((finding) => finding.kind),
    [
      "removal-inconsistency",
      "removal-inconsistency",
      "removal-inconsistency",
      "version-decrease",
    ],
  );
  assert.equal(result.pass, false);
});

test("buildDocVersionReport returns stable summary fields", () => {
  const report = buildDocVersionReport({
    base: {input: "main", commit: "base", catalog: "catalog.json"},
    target: {kind: "working-tree", input: null, commit: null, catalog: "catalog.json"},
    baseCatalog: {doc: {path: "docs/doc.md", version: "1.0.0"}},
    currentCatalog: {doc: {path: "docs/doc.md", version: "1.1.0"}},
    currentDocumentPaths: new Set(["docs/doc.md"]),
  });

  assert.equal(report.schemaVersion, 1);
  assert.deepEqual(report.summary, {
    baseGoverned: 1,
    currentGoverned: 1,
    catalogVersionStatus: "not-governed",
    increases: 1,
    unchanged: 0,
    additions: 0,
    versionDecreases: 0,
    removalInconsistencies: 0,
    pass: true,
  });
  assert.equal(report.catalogVersion.status, "not-governed");
});

test("catalog top-level version is itself monotonic", () => {
  const result = compareDocVersionCatalogs({
    baseCatalog: {
      version: "4.6.204",
      doc: {path: "docs/doc.md", version: "1.0.0"},
    },
    currentCatalog: {
      version: "4.6.203",
      doc: {path: "docs/doc.md", version: "1.0.0"},
    },
    currentDocumentPaths: new Set(["docs/doc.md"]),
  });

  assert.equal(result.catalogVersion.status, "decreased");
  assert.equal(result.findings.length, 1);
  assert.equal(result.findings[0].id, "$catalog");
  assert.equal(result.findings[0].kind, "version-decrease");
});

test("known-bad self-test proves decrease and removal detection", () => {
  const result = runSelfTest();
  assert.equal(result.selfTest.pass, true);
  assert.deepEqual(
    result.selfTest.knownBadFindings.map((finding) => finding.kind),
    ["removal-inconsistency", "version-decrease"],
  );

  const cli = spawnSync(process.execPath, [scriptPath, "--self-test", "--json"], {
    encoding: "utf8",
  });
  assert.equal(cli.status, 0, cli.stderr);
  assert.equal(JSON.parse(cli.stdout).selfTest.pass, true);
});

test("CLI compares an explicit catalog from base to working tree and target ref", () => {
  const repo = fs.mkdtempSync(path.join(os.tmpdir(), "catch-doc-ratchet-"));
  const catalogPath = "governance/docs.json";
  git(repo, ["init", "-q"]);
  git(repo, ["config", "user.email", "test@example.com"]);
  git(repo, ["config", "user.name", "Catch Test"]);
  write(repo, "docs/a.md", "# A\n");
  write(repo, "docs/b.md", "# B\n");
  writeCatalog(repo, catalogPath, {
    a: {path: "docs/a.md", version: "1.2.0"},
    b: {path: "docs/b.md", version: "2"},
  });
  commitAll(repo, "base");
  const base = git(repo, ["rev-parse", "HEAD"]);

  writeCatalog(repo, catalogPath, {
    a: {path: "docs/a.md", version: "1.1.9"},
    b: {path: "docs/b.md", version: "2.0.0"},
  });
  fs.rmSync(path.join(repo, "docs/b.md"));
  const bad = runCli(repo, catalogPath, base);
  assert.equal(bad.status, 1, bad.stderr);
  const badReport = JSON.parse(bad.stdout);
  assert.equal(badReport.summary.versionDecreases, 1);
  assert.equal(badReport.summary.removalInconsistencies, 1);

  write(repo, "docs/b.md", "# B restored\n");
  write(repo, "docs/c.md", "# C\n");
  writeCatalog(repo, catalogPath, {
    a: {path: "docs/a.md", version: "1.3.0"},
    b: {path: "docs/b.md", version: "2.0.0"},
    c: {path: "docs/c.md", version: "0.1.0"},
  });
  const goodWorkingTree = runCli(repo, catalogPath, base);
  assert.equal(goodWorkingTree.status, 0, goodWorkingTree.stderr);
  const goodReport = JSON.parse(goodWorkingTree.stdout);
  assert.equal(goodReport.summary.increases, 1);
  assert.equal(goodReport.summary.unchanged, 1);
  assert.equal(goodReport.summary.additions, 1);

  commitAll(repo, "good target");
  const target = git(repo, ["rev-parse", "HEAD"]);
  writeCatalog(repo, catalogPath, {
    a: {path: "docs/a.md", version: "0.1.0"},
  });
  const goodRef = runCli(repo, catalogPath, base, target);
  assert.equal(goodRef.status, 0, goodRef.stderr);
  assert.equal(JSON.parse(goodRef.stdout).target.commit, target);
});

function runCli(repo, catalogPath, base, target = null) {
  const args = [
    scriptPath,
    "--repo",
    repo,
    "--catalog",
    catalogPath,
    "--base",
    base,
    "--json",
  ];
  if (target) args.push("--target", target);
  return spawnSync(process.execPath, args, {encoding: "utf8"});
}

function git(repo, args) {
  return execFileSync("git", args, {cwd: repo, encoding: "utf8"}).trim();
}

function write(repo, relativePath, source) {
  const file = path.join(repo, relativePath);
  fs.mkdirSync(path.dirname(file), {recursive: true});
  fs.writeFileSync(file, source);
}

function writeCatalog(repo, relativePath, value) {
  write(repo, relativePath, `${JSON.stringify(value, null, 2)}\n`);
}

function commitAll(repo, message) {
  git(repo, ["add", "-A"]);
  git(repo, ["commit", "-q", "-m", message]);
}
