#!/usr/bin/env node

import assert from "node:assert/strict";
import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import {spawnSync} from "node:child_process";
import {fileURLToPath} from "node:url";
import test from "node:test";
import {
  baselineFromOrphans,
  checkInventoryFile,
  evaluateOrphanRatchet,
  readOrphanBaseline,
  scanL10nKeyUsage,
  stableJson,
  tokenizeDartIdentifiers,
} from "./check_l10n_key_usage.mjs";

const copyRoot = path.dirname(fileURLToPath(import.meta.url));
const scannerPath = path.join(copyRoot, "check_l10n_key_usage.mjs");

test("known-bad fixture reports only the newly orphaned key", () => {
  const root = fixtureRoot("new_orphan");
  const result = scanFixture(root);
  const entries = Object.fromEntries(
    result.inventory.keys.map((entry) => [entry.key, entry]),
  );

  assert.equal(entries.usedKey.status, "used");
  assert.equal(entries.usedInInterpolation.status, "used");
  assert.deepEqual(entries.usedKey.usages, [
    {path: "lib/sample.dart", line: 6, column: 23},
  ]);
  assert.deepEqual(entries.usedInInterpolation.usages, [
    {path: "lib/sample.dart", line: 7, column: 32},
  ]);
  assert.equal(entries.knownOrphan.status, "orphaned");
  assert.equal(entries.stringOnly.status, "orphaned");
  assert.equal(entries.generatedOnly.status, "orphaned");
  assert.equal(entries.newOrphan.status, "orphaned");
  assert.deepEqual(
    result.excludedFiles.map(({path: filePath, reason}) => [filePath, reason]),
    [
      ["lib/l10n/generated/app_localizations.dart", "l10n-generated-directory"],
      ["lib/secondary.g.dart", "generated-suffix"],
    ],
  );

  const baseline = readFixtureBaseline(root);
  const ratchet = evaluateOrphanRatchet(result.orphanedKeys, baseline);
  assert.equal(ratchet.passed, false);
  assert.deepEqual(ratchet.newOrphanedKeys, ["newOrphan"]);
  assert.deepEqual(ratchet.baselineOrphanedKeys, [
    "generatedOnly",
    "knownOrphan",
    "stringOnly",
  ]);
  assert.deepEqual(ratchet.resolvedBaselineKeys, []);
});

test("reduction fixture passes when an orphan is used or removed", () => {
  const root = fixtureRoot("reduction");
  const result = scanFixture(root);
  const ratchet = evaluateOrphanRatchet(
    result.orphanedKeys,
    readFixtureBaseline(root),
  );

  assert.deepEqual(result.orphanedKeys, []);
  assert.equal(ratchet.passed, true);
  assert.deepEqual(ratchet.newOrphanedKeys, []);
  assert.deepEqual(ratchet.baselineOrphanedKeys, []);
  assert.deepEqual(ratchet.resolvedBaselineKeys, [
    "recoveredKey",
    "removedCatalogKey",
  ]);
  const reducedBaseline = baselineFromOrphans(result.orphanedKeys);
  assert.deepEqual(reducedBaseline.allowedOrphanedKeys, []);
  assert.match(reducedBaseline.refreshCommand, /--write-baseline/u);
});

test("Dart lexer ignores comments and strings but scans interpolation code", () => {
  const source = [
    "// commentOnly",
    "/* outer /* nestedOnly */ blockOnly */",
    "const ordinary = 'stringOnly';",
    "const raw = r'rawOnly';",
    "final direct = l10n.usedKey;",
    "final interpolated = '${l10n.usedInInterpolation}';",
  ].join("\n");
  const identifiers = tokenizeDartIdentifiers(source).map(
    (token) => token.identifier,
  );

  assert.ok(identifiers.includes("usedKey"));
  assert.ok(identifiers.includes("usedInInterpolation"));
  for (const ignored of [
    "commentOnly",
    "nestedOnly",
    "blockOnly",
    "stringOnly",
    "rawOnly",
  ]) {
    assert.equal(identifiers.includes(ignored), false, ignored);
  }
});

test("inventory generation is deterministic and exact-file checkable", () => {
  const root = fixtureRoot("reduction");
  const first = scanFixture(root).inventory;
  const second = scanFixture(root).inventory;
  assert.equal(stableJson(first), stableJson(second));

  const temporaryRoot = fs.mkdtempSync(
    path.join(os.tmpdir(), "catch-l10n-inventory-"),
  );
  try {
    const inventoryPath = path.join(temporaryRoot, "inventory.json");
    fs.writeFileSync(inventoryPath, stableJson(first));
    assert.deepEqual(checkInventoryFile(second, inventoryPath), {
      current: true,
      reason: null,
    });
    fs.writeFileSync(inventoryPath, "{}\n");
    assert.deepEqual(checkInventoryFile(second, inventoryPath), {
      current: false,
      reason: "stale",
    });
  } finally {
    fs.rmSync(temporaryRoot, {recursive: true, force: true});
  }
});

test("CLI fails the new-orphan fixture and passes the reduction fixture", () => {
  const failing = runFixtureCli("new_orphan", "--check");
  assert.equal(failing.status, 1, failing.stderr);
  assert.match(failing.stderr, /New orphaned Flutter ARB keys:/u);
  assert.match(failing.stderr, /- newOrphan/u);

  const passing = runFixtureCli("reduction", "--check");
  assert.equal(passing.status, 0, passing.stderr);
  assert.match(passing.stdout, /0 new, 0 baseline, 2 resolved/u);
});

test("baseline refresh refuses to bless a newly orphaned key", () => {
  const root = fixtureRoot("new_orphan");
  const baselinePath = path.join(
    root,
    "tool",
    "copy",
    "l10n_orphan_baseline.json",
  );
  const before = fs.readFileSync(baselinePath, "utf8");
  const refresh = runFixtureCli("new_orphan", "--write-baseline");

  assert.equal(refresh.status, 1, refresh.stderr);
  assert.match(refresh.stderr, /Refusing to grow/u);
  assert.match(refresh.stderr, /newOrphan/u);
  assert.equal(fs.readFileSync(baselinePath, "utf8"), before);
});

test("CLI write flags produce reviewable inventory and reduced baseline", () => {
  const root = fixtureRoot("reduction");
  const temporaryRoot = fs.mkdtempSync(
    path.join(os.tmpdir(), "catch-l10n-writes-"),
  );
  try {
    const inventoryPath = path.join(temporaryRoot, "inventory.json");
    const baselinePath = path.join(temporaryRoot, "baseline.json");
    const inventoryWrite = runCli([
      "--repo-root",
      root,
      "--inventory",
      inventoryPath,
      "--write-inventory",
    ]);
    assert.equal(inventoryWrite.status, 0, inventoryWrite.stderr);
    assert.equal(
      fs.readFileSync(inventoryPath, "utf8"),
      stableJson(scanFixture(root).inventory),
    );

    const inventoryCheck = runCli([
      "--repo-root",
      root,
      "--inventory",
      inventoryPath,
      "--check-inventory",
    ]);
    assert.equal(inventoryCheck.status, 0, inventoryCheck.stderr);

    const baselineWrite = runCli([
      "--repo-root",
      root,
      "--baseline",
      baselinePath,
      "--write-baseline",
    ]);
    assert.equal(baselineWrite.status, 0, baselineWrite.stderr);
    assert.deepEqual(
      JSON.parse(fs.readFileSync(baselinePath, "utf8")).allowedOrphanedKeys,
      [],
    );
  } finally {
    fs.rmSync(temporaryRoot, {recursive: true, force: true});
  }
});

function fixtureRoot(name) {
  return path.join(copyRoot, "fixtures", "l10n_key_usage", name);
}

function scanFixture(root) {
  return scanL10nKeyUsage({
    repoRoot: root,
    arbPath: path.join(root, "lib", "l10n", "app_en.arb"),
    sourceRoot: path.join(root, "lib"),
  });
}

function readFixtureBaseline(root) {
  return readOrphanBaseline(
    path.join(root, "tool", "copy", "l10n_orphan_baseline.json"),
  );
}

function runFixtureCli(name, ...args) {
  return runCli(["--repo-root", fixtureRoot(name), ...args]);
}

function runCli(args) {
  return spawnSync(process.execPath, [scannerPath, ...args], {
    encoding: "utf8",
  });
}
