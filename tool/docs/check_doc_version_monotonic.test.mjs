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
  parseDocumentLifecycleStatus,
  parseSemanticVersion,
  runSelfTest,
} from "./check_doc_version_monotonic.mjs";
import {createRepositorySnapshot} from "../lib/repository_snapshot.mjs";

const scriptPath = fileURLToPath(
  new URL("./check_doc_version_monotonic.mjs", import.meta.url),
);

test("widget catalog keeps current inventory ahead of Git-owned history", () => {
  const catalog = createRepositorySnapshot().readText("docs/widget_catalog.md", {
    required: true,
  });
  assert.doesNotMatch(catalog, /^## Rule Changelog$/mu);
  assert.doesNotMatch(catalog, /^### \d+\.\d+\.\d+$/mu);
  assert.match(catalog, /^## Maintenance Contract$/mu);
  const inventoryOffset = catalog.indexOf("\n## App Entry Point\n");
  assert.notEqual(inventoryOffset, -1, "widget inventory marker is missing");
  const inventoryLine = catalog.slice(0, inventoryOffset).split("\n").length + 1;
  assert.ok(
    inventoryLine <= 350,
    `current widget inventory starts too late at line ${inventoryLine}`,
  );
});

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
  assert.equal(result.retirements.length, 0);
  assert.deepEqual(result.catalogVersion, {
    baseVersion: "4.6.204",
    currentVersion: "4.6.205",
    status: "increased",
  });
});

test("catalog comparator allows only proven retirement-ready deletions", () => {
  const allowed = compareDocVersionCatalogs({
    baseCatalog: {
      retired: {
        path: "governance/retired.json",
        version: "1.0.0",
        status: "retirement_ready",
      },
    },
    currentCatalog: {},
    currentDocumentPaths: new Set(),
  });
  assert.equal(allowed.pass, true);
  assert.deepEqual(allowed.retirements, [
    {
      id: "retired",
      path: "governance/retired.json",
      baseVersion: "1.0.0",
      baseStatus: "retirement_ready",
      statusAuthority: "catalog",
    },
  ]);

  const catalogOnly = compareDocVersionCatalogs({
    baseCatalog: {
      retired: {
        path: "governance/retired.json",
        version: "1.0.0",
        status: "retirement_ready",
      },
    },
    currentCatalog: {},
    currentDocumentPaths: new Set(["governance/retired.json"]),
  });
  assert.equal(catalogOnly.pass, false);
  assert.match(catalogOnly.findings[0].reason, /document remains/u);

  const activeDeletion = compareDocVersionCatalogs({
    baseCatalog: {
      active: {path: "governance/active.json", version: "1.0.0", status: "active"},
    },
    currentCatalog: {},
    currentDocumentPaths: new Set(),
  });
  assert.equal(activeDeletion.pass, false);
  assert.match(activeDeletion.findings[0].reason, /without retirement_ready/u);
});

test("source frontmatter is the canonical Markdown retirement authority", () => {
  assert.equal(
    parseDocumentLifecycleStatus(
      "---\ndoc_id: retired\nstatus: retirement_ready\n---\n\n# Retired\n",
    ),
    "retirement_ready",
  );
  assert.equal(parseDocumentLifecycleStatus("# No frontmatter\n"), null);
  assert.equal(
    parseDocumentLifecycleStatus("---\r\nstatus: \"retirement_ready\" # reviewed\r\n---\r\n"),
    "retirement_ready",
  );
  assert.equal(
    parseDocumentLifecycleStatus("---\nstatus: retirement_ready\n# missing close\n"),
    null,
  );
  assert.equal(
    parseDocumentLifecycleStatus(
      "---\nstatus: retirement_ready\nstatus: active\n---\n",
    ),
    null,
  );

  const allowed = compareDocVersionCatalogs({
    baseCatalog: {
      retired: {path: "docs/retired.md", version: "1.0.0", status: "implemented"},
    },
    currentCatalog: {},
    currentDocumentPaths: new Set(),
    baseDocumentStatuses: new Map([["docs/retired.md", "retirement_ready"]]),
  });
  assert.equal(allowed.pass, true);
  assert.equal(allowed.retirements[0].statusAuthority, "source-frontmatter");

  const blocked = compareDocVersionCatalogs({
    baseCatalog: {
      active: {path: "docs/active.md", version: "1.0.0", status: "retirement_ready"},
    },
    currentCatalog: {},
    currentDocumentPaths: new Set(),
    baseDocumentStatuses: new Map([["docs/active.md", "active"]]),
  });
  assert.equal(blocked.pass, false);
  assert.match(blocked.findings[0].reason, /source status is active/u);

  const missingSourceStatus = compareDocVersionCatalogs({
    baseCatalog: {
      stale: {
        path: "docs/stale.md",
        version: "1.0.0",
        status: "retirement_ready",
      },
    },
    currentCatalog: {},
    currentDocumentPaths: new Set(),
    baseDocumentStatuses: new Map([["docs/stale.md", null]]),
  });
  assert.equal(missingSourceStatus.pass, false);
  assert.match(missingSourceStatus.findings[0].reason, /no single valid lifecycle status/u);
});

test("current lifecycle catalog rejects duplicate or missing authority", () => {
  assert.throws(
    () => compareDocVersionCatalogs({
      baseCatalog: {doc: {path: "docs/doc.md", version: "1.0.0", status: "active"}},
      currentCatalog: {
        doc: {path: "docs/doc.md", version: "1.0.1", status: "active"},
      },
      currentDocumentPaths: new Set(["docs/doc.md"]),
    }),
    /must omit Markdown lifecycle status/u,
  );
  assert.throws(
    () => compareDocVersionCatalogs({
      baseCatalog: {doc: {path: "docs/doc.md", version: "1.0.0", status: "active"}},
      currentCatalog: {doc: {path: "docs/doc.md", version: "1.0.1"}},
      currentDocumentPaths: new Set(["docs/doc.md"]),
      currentDocumentStatuses: new Map([["docs/doc.md", null]]),
    }),
    /no single valid source-frontmatter lifecycle status/u,
  );
  assert.throws(
    () => compareDocVersionCatalogs({
      baseCatalog: {
        contract: {path: "contracts/contract.json", version: "1.0.0", status: "active"},
      },
      currentCatalog: {
        contract: {path: "contracts/contract.json", version: "1.0.1"},
      },
      currentDocumentPaths: new Set(["contracts/contract.json"]),
    }),
    /non-Markdown.*missing lifecycle status/u,
  );
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
    retirements: 0,
    versionDecreases: 0,
    removalInconsistencies: 0,
    pass: true,
  });
  assert.equal(report.catalogVersion.status, "not-governed");
});

test("CLI requires both catalog removal and working-tree deletion for retirement", () => {
  const repo = fs.mkdtempSync(path.join(os.tmpdir(), "catch-doc-retirement-"));
  const catalogPath = "governance/docs.json";
  git(repo, ["init", "-q"]);
  git(repo, ["config", "user.email", "test@example.com"]);
  git(repo, ["config", "user.name", "Catch Test"]);
  write(
    repo,
    "docs/retired.md",
    "---\ndoc_id: retired\nversion: 1.0.0\nstatus: retirement_ready\n---\n\n# Retired\n",
  );
  writeCatalog(repo, catalogPath, {
    retired: {
      path: "docs/retired.md",
      version: "1.0.0",
      status: "implemented",
    },
  });
  commitAll(repo, "base");
  const base = git(repo, ["rev-parse", "HEAD"]);

  writeCatalog(repo, catalogPath, {});
  const catalogOnly = runCli(repo, catalogPath, base);
  assert.equal(catalogOnly.status, 1, catalogOnly.stderr);
  assert.equal(JSON.parse(catalogOnly.stdout).summary.removalInconsistencies, 1);

  fs.rmSync(path.join(repo, "docs/retired.md"));
  const retired = runCli(repo, catalogPath, base);
  assert.equal(retired.status, 0, retired.stderr);
  const report = JSON.parse(retired.stdout);
  assert.equal(report.summary.retirements, 1);
  assert.equal(report.retirements[0].id, "retired");
  assert.equal(report.retirements[0].statusAuthority, "source-frontmatter");
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
  write(repo, "docs/a.md", "---\nstatus: active\n---\n\n# A\n");
  write(repo, "docs/b.md", "---\nstatus: active\n---\n\n# B\n");
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

  write(repo, "docs/b.md", "---\nstatus: active\n---\n\n# B restored\n");
  write(repo, "docs/c.md", "---\nstatus: active\n---\n\n# C\n");
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
