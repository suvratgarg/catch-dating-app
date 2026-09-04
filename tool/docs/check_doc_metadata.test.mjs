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
  documentReferences,
  buildDocumentInventory,
  retiredDocumentReferences,
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

test("literal document references respect Markdown relativity and repository code paths", () => {
  const refs = documentReferences("docs/plans/current.md", [
    "[Owner](../owner.md#policy)",
    "`docs/owner.md:42` and `../../lib/README.md`",
    "[nested](docs/owner.md)",
    "[External](https://example.com/docs/owner.md)",
    "[space](<../old%20plan.md>)",
    "[ref]: ../owner.md#policy",
    "[not-doc](../owner.json) and `not a path`",
  ].join("\n"), new Set(["docs/owner.md"]));
  assert.deepEqual(refs, [
    {path: "docs/owner.md", line: 1},
    {path: "docs/owner.md", line: 2},
    {path: "lib/README.md", line: 2},
    {path: "docs/plans/docs/owner.md", line: 3},
    {path: "docs/old plan.md", line: 5},
    {path: "docs/owner.md", line: 6},
  ]);
});

test("inventory includes ungoverned Markdown and exposes headings and incoming references", () => {
  const sources = new Map([
    ["docs/README.md", "# Docs\n\n[Guide](guide.md)\n"],
    ["docs/guide.md", "<!-- GENERATED FROM contract.json. DO NOT EDIT. -->\n# Guide\n\n```md\n## Not a heading\n```\n## Usage\n"],
    ["lib/example.dart", "not Markdown"],
  ]);
  const inventory = buildDocumentInventory({paths: sources.keys(), readSource: (p) => sources.get(p)});
  assert.equal(inventory.documents.length, 2);
  const guide = inventory.documents.find((d) => d.path === "docs/guide.md");
  assert.equal(guide.metadata, null);
  assert.match(guide.generatedMarker, /GENERATED FROM/u);
  assert.deepEqual(guide.headings.map((h) => h.title), ["Guide", "Usage"]);
  assert.deepEqual(guide.referencedBy, [{path: "docs/README.md", line: 3}]);
  assert.match(inventory.coverage, /no semantic freshness/u);
});

test("retirement finds remaining references without blocking unrelated historical broken links", () => {
  const findings = retiredDocumentReferences({
    paths: new Set(["docs/README.md", "lib/README.md"]),
    readSource: (p) => p === "docs/README.md"
      ? "[Old](plans/old.md#acceptance)\n[Existing broken](already-missing.md)"
      : "See `docs/plans/old.md`.\n",
    retiredPaths: ["docs/plans/old.md"],
  });
  assert.deepEqual(findings.map((f) => [f.path, f.line, f.target]), [
    ["docs/README.md", 1, "docs/plans/old.md"],
    ["lib/README.md", 1, "docs/plans/old.md"],
  ]);
});

test("CLI retirement protects ungoverned docs and handles dirty, committed, and renamed files", () => {
  const repo = fs.mkdtempSync(path.join(os.tmpdir(), "catch-doc-retirement-"));
  try {
    git(repo, ["init", "-q"]);
    git(repo, ["config", "user.email", "test@example.com"]);
    git(repo, ["config", "user.name", "Catch Test"]);
    fs.mkdirSync(path.join(repo, "docs"));
    fs.writeFileSync(path.join(repo, "docs/old.md"), "# Old\n");
    fs.writeFileSync(path.join(repo, "docs/README.md"), "[Old](old.md)\n");
    git(repo, ["add", "."]);
    git(repo, ["commit", "-qm", "base"]);
    const base = git(repo, ["rev-parse", "HEAD"]).trim();
    fs.renameSync(path.join(repo, "docs/old.md"), path.join(repo, "docs/new.md"));
    const run = (...args) => spawnSync(process.execPath, [scriptPath, "--repo", repo, "--base", base, "--json", ...args], {encoding: "utf8"});
    const bad = run();
    assert.equal(bad.status, 1, bad.stderr);
    assert.equal(JSON.parse(bad.stdout).findings[0].kind, "retired-document-reference");
    fs.writeFileSync(path.join(repo, "docs/README.md"), "[Current](new.md)\n");
    const good = run("--inventory");
    assert.equal(good.status, 0, good.stderr);
    assert.equal(JSON.parse(good.stdout).inventory.documents.length, 2);
    git(repo, ["add", "-A"]);
    git(repo, ["commit", "-qm", "rename and repair"]);
    assert.equal(run("--ref", "HEAD").status, 0);
    fs.writeFileSync(path.join(repo, "docs/README.md"), "[Old](old.md)\n");
    assert.equal(run().status, 1);
    assert.equal(run("--ref", "HEAD").status, 0);
    assert.equal(run("--ref", "").status, 1);
  } finally {
    fs.rmSync(repo, {recursive: true, force: true});
  }
});

test("references handle nested and escaped destinations, root literals, and fenced samples", () => {
  const refs = documentReferences("docs/guide.md", [
    "[other](image.png) [one](notes/a(b(c)).md) [two](<notes/a(b).md>)",
    String.raw`[escaped](notes/a\(b\).md "Title")`,
    "`AGENTS.md` and `README.md`",
    "```md",
    "[Sample](old.md) and `docs/old.md`",
    "```",
    "[real]: <notes/a(b).md> \"Title\"",
  ].join("\n"), new Set(["AGENTS.md", "README.md", "docs/README.md"]));
  assert.deepEqual(refs, [
    {path: "docs/notes/a(b(c)).md", line: 1},
    {path: "docs/notes/a(b).md", line: 1},
    {path: "docs/notes/a(b).md", line: 2},
    {path: "AGENTS.md", line: 3},
    {path: "docs/README.md", line: 3},
    {path: "docs/notes/a(b).md", line: 7},
  ]);
  assert.equal(retiredDocumentReferences({
    paths: ["docs/guide.md"], readSource: () => "Read `AGENTS.md` and `operations/README.md`.",
    retiredPaths: ["AGENTS.md", "operations/README.md"],
  }).length, 2);
});
