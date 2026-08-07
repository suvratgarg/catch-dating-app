import assert from "node:assert/strict";
import fs from "node:fs";
import path from "node:path";
import test from "node:test";
import {fileURLToPath} from "node:url";

import {validateWidgetClassification} from "./check_widget_classification.mjs";
import {buildWidgetClassification} from "./generate_widget_classification.mjs";

const repoRoot = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "../..");
const contracts = JSON.parse(
  fs.readFileSync(path.join(repoRoot, "design/components/catch.components.json"), "utf8"),
).components ?? [];
const widgetbookNames = readWidgetbookNames();
const classification = buildWidgetClassification({
  repoRoot,
  updated: "2026-08-07",
});
const sourceDeclarations = classification.widgets.map(({file, name, baseClass}) => ({
  file,
  name,
  baseClass,
}));

test("source-derived widget classification passes its structural and semantic contract", () => {
  assert.equal(Object.hasOwn(classification, "$schema"), false);
  assert.equal(classification.widgets.length > 0, true);
  assert.deepEqual(validate(classification), []);
});

test("rejects undeclared properties and invalid enum values", () => {
  const extraProperty = clone(classification);
  extraProperty.untrackedSnapshotField = true;
  assert.ok(validate(extraProperty).some((failure) => failure.startsWith("registry must contain exactly")));

  const invalidRole = clone(classification);
  invalidRole.widgets[0].role = "molecule";
  assert.ok(validate(invalidRole).some((failure) => failure.includes("role has invalid value")));
});

test("rejects duplicate remediation values and summary drift", () => {
  const duplicateRemediation = clone(classification);
  duplicateRemediation.widgets[0].remediationOptions = ["inlineDelete", "inlineDelete"];
  assert.ok(validate(duplicateRemediation).some((failure) => failure.includes("remediationOptions must be unique")));

  const summaryDrift = clone(classification);
  summaryDrift.summary.total += 1;
  assert.ok(validate(summaryDrift).includes(
    `summary.total must equal ${classification.widgets.length}`,
  ));
});

test("retains the private-widget remediation rule", () => {
  const privateIndex = classification.widgets.findIndex(
    (widget) => widget.classKind === "widget" && widget.visibility === "private",
  );
  assert.notEqual(privateIndex, -1, "fixture requires a current private widget");
  const invalid = clone(classification);
  invalid.widgets[privateIndex].decision = "keep-public-cataloged";
  assert.ok(validate(invalid).some((failure) =>
    failure.includes("private widget classes must be review-promote-or-inline"),
  ));
});

test("rejects missing and stale source classifications", () => {
  const missing = clone(classification);
  const removed = missing.widgets.pop();
  assert.ok(validate(missing).includes(`${removed.file}:${removed.name}: missing classification`));

  const staleSource = sourceDeclarations.slice(0, -1);
  const failures = validateWidgetClassification(classification, {
    contracts,
    widgetbookNames,
    sourceDeclarations: staleSource,
  });
  const stale = classification.widgets.at(-1);
  assert.ok(failures.includes(`${stale.file}:${stale.name}: stale classification`));
});

function validate(value) {
  return validateWidgetClassification(value, {
    contracts,
    widgetbookNames,
    sourceDeclarations,
  });
}

function readWidgetbookNames() {
  const source = fs.readFileSync(
    path.join(repoRoot, "widgetbook/lib/main.directories.g.dart"),
    "utf8",
  );
  const names = new Set();
  for (const match of source.matchAll(/WidgetbookComponent\(\s*name: '([^']+)'/gu)) {
    names.add(match[1]);
    names.add(match[1].replace(/<.*>$/u, ""));
  }
  return names;
}

function clone(value) {
  return structuredClone(value);
}
