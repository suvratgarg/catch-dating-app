import assert from "node:assert/strict";
import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import {execFileSync, spawnSync} from "node:child_process";
import {fileURLToPath} from "node:url";
import test from "node:test";
import {
  collectGovernedDocuments,
  compareDocumentMetadata,
  compareSemanticVersions,
  parseDocumentLifecycleStatus,
  parseGovernedDocument,
  parseSemanticVersion,
  runSelfTest,
  widgetCatalogViolation,
} from "./check_doc_metadata.mjs";

const scriptPath = fileURLToPath(new URL("./check_doc_metadata.mjs", import.meta.url));

test("source frontmatter is the sole governed Markdown authority", () => {
  const source = `---
doc_id: release_operations
version: 1.12.0
updated: 2026-08-07
owner: release_operations
status: active — current runbook
---

# Release operations
`;
  assert.deepEqual(parseGovernedDocument("docs/release_operations.md", source), {
    id: "release_operations",
    path: "docs/release_operations.md",
    version: "1.12.0",
    updated: "2026-08-07",
    owner: "release_operations",
    status: "active",
  });
  assert.equal(parseDocumentLifecycleStatus(source), "active");
  assert.equal(parseDocumentLifecycleStatus("# no metadata\n"), null);
});

test("governed source requires complete metadata and unique identity", () => {
  assert.throws(
    () => parseGovernedDocument(
      "docs/incomplete.md",
      "---\ndoc_id: incomplete\nversion: 1.0.0\n---\n",
    ),
    /missing updated, owner, status/u,
  );
  const source = "---\ndoc_id: duplicate\nversion: 1.0.0\nupdated: 2026-08-07\nowner: docs\nstatus: active\n---\n";
  assert.throws(
    () => collectGovernedDocuments({
      paths: ["docs/a.md", "docs/b.md"],
      readSource: () => source,
    }),
    /Duplicate doc_id duplicate/u,
  );
});

test("widget catalog stays current inventory instead of inline history", () => {
  const current = "## Maintenance Contract\n\n## App Entry Point\n";
  assert.equal(widgetCatalogViolation(current), null);
  assert.match(
    widgetCatalogViolation("## Maintenance Contract\n\n## Rule Changelog\n\n## App Entry Point\n"),
    /inline changelog/u,
  );

  const historical = `---
doc_id: widget_catalog
version: 1.0.0
updated: 2026-08-06
owner: design_system
status: active
---

## Maintenance Contract

## Rule Changelog

## App Entry Point
`;
  assert.doesNotThrow(() => parseGovernedDocument(
    "docs/widget_catalog.md",
    historical,
    {validateCurrentContracts: false},
  ));
  assert.throws(
    () => parseGovernedDocument("docs/widget_catalog.md", historical),
    /inline changelog/u,
  );
});

test("semantic versions compare without a duplicate catalog", () => {
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

test("comparison rejects decreases and identity swaps while reporting deletions", () => {
  const result = compareDocumentMetadata({
    baseDocuments: [
      doc("decrease", "docs/decrease.md", "2.0.0", "active"),
      doc("identity", "docs/identity.md", "1.0.0", "active"),
      doc("deleted", "docs/deleted.md", "1.0.0", "active"),
    ],
    currentDocuments: [
      doc("decrease", "docs/decrease.md", "1.9.9", "active"),
      doc("replacement", "docs/identity.md", "1.0.1", "active"),
    ],
  });
  assert.equal(result.pass, false);
  assert.deepEqual(
    result.findings.map((entry) => entry.kind).sort(),
    ["doc-id-changed", "version-decrease"],
  );
  assert.deepEqual(result.deletions.map((entry) => entry.id), ["deleted"]);
});

test("comparison allows additions, version increases, renames, and reviewed deletion", () => {
  const result = compareDocumentMetadata({
    baseDocuments: [
      doc("renamed", "docs/old.md", "1.0.0", "active"),
      doc("retired", "docs/retired.md", "1.0.0", "retirement_ready"),
    ],
    currentDocuments: [
      doc("renamed", "docs/new.md", "1.1.0", "active"),
      doc("addition", "docs/addition.md", "0.1.0", "draft"),
    ],
  });
  assert.equal(result.pass, true);
  assert.equal(result.increases.length, 1);
  assert.equal(result.additions.length, 1);
  assert.equal(result.deletions.length, 1);
});

test("known-bad self-test proves decrease detection and deletion reporting", () => {
  const selfTest = runSelfTest();
  assert.equal(selfTest.pass, true);
  const cli = spawnSync(process.execPath, [scriptPath, "--self-test", "--json"], {
    encoding: "utf8",
  });
  assert.equal(cli.status, 0, cli.stderr);
  assert.equal(JSON.parse(cli.stdout).selfTest.pass, true);
});

test("CLI compares source metadata at the working tree and an exact ref", () => {
  const repo = fs.mkdtempSync(path.join(os.tmpdir(), "catch-doc-metadata-"));
  git(repo, ["init", "-q"]);
  git(repo, ["config", "user.email", "test@example.com"]);
  git(repo, ["config", "user.name", "Catch Test"]);
  writeDoc(repo, "1.2.0", "active");
  git(repo, ["add", "."]);
  git(repo, ["commit", "-qm", "base"]);
  const base = git(repo, ["rev-parse", "HEAD"]).trim();

  writeDoc(repo, "1.1.9", "active");
  const bad = spawnSync(process.execPath, [scriptPath, "--repo", repo, "--base", base, "--json"], {
    encoding: "utf8",
  });
  assert.equal(bad.status, 1, bad.stderr);
  assert.equal(JSON.parse(bad.stdout).findings[0].kind, "version-decrease");

  writeDoc(repo, "1.3.0", "active");
  git(repo, ["add", "."]);
  git(repo, ["commit", "-qm", "increase"]);
  const target = git(repo, ["rev-parse", "HEAD"]).trim();
  const good = spawnSync(process.execPath, [
    scriptPath,
    "--repo",
    repo,
    "--base",
    base,
    "--ref",
    target,
    "--json",
  ], {encoding: "utf8"});
  assert.equal(good.status, 0, good.stderr);
  assert.equal(JSON.parse(good.stdout).pass, true);
  assert.equal(JSON.parse(good.stdout).targetRevision, target);
});

function doc(id, documentPath, version, status) {
  return {
    id,
    path: documentPath,
    version,
    updated: "2026-08-07",
    owner: "docs",
    status,
  };
}

function writeDoc(repo, version, status) {
  const documentPath = path.join(repo, "docs", "sample.md");
  fs.mkdirSync(path.dirname(documentPath), {recursive: true});
  fs.writeFileSync(
    documentPath,
    `---\ndoc_id: sample\nversion: ${version}\nupdated: 2026-08-07\nowner: docs\nstatus: ${status}\n---\n\n# Sample\n`,
  );
}

function git(repo, args) {
  return execFileSync("git", args, {cwd: repo, encoding: "utf8"});
}
