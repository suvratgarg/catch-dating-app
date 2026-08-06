import assert from "node:assert/strict";
import fs from "node:fs";
import path from "node:path";
import {spawnSync} from "node:child_process";
import test from "node:test";
import {fileURLToPath} from "node:url";
import {buildWidgetVariantInventory} from "./generate_widget_variant_inventory.mjs";

const testDir = path.dirname(fileURLToPath(import.meta.url));
const repoRoot = path.resolve(testDir, "../..");
const scriptPath = path.join(testDir, "generate_widget_variant_inventory.mjs");
const retiredInventoryPath = path.join(
  repoRoot,
  "docs/audit_registry/widget_variant_inventory.json",
);

function fixtureSnapshot() {
  const files = new Map([
    [
      "widgetbook/lib/primary.dart",
      `
@widgetbook.UseCase(
  name: 'Primary',
  type: SampleCard,
  path: '[Features]/Sample',
)
Widget samplePrimary(BuildContext context) {
  return Column(children: [
    _StateCard(label: 'Default'),
    _StateCard(label: 'Error'),
    _StateCard(label: 'Repeated label'),
  ]);
}
`,
    ],
    [
      "widgetbook/lib/secondary.dart",
      `
@widgetbook.UseCase(
  name: 'Secondary',
  type: SampleCard,
  path: '[Features]/Sample',
)
Widget sampleSecondary(BuildContext context) {
  return Column(children: [
    _StateCard(label: 'Loading'),
    _StateCard(label: 'Success'),
    _StateCard(label: 'Repeated-label'),
  ]);
}
`,
    ],
    ["widgetbook/lib/main.directories.g.dart", "// generated"],
  ]);

  return {
    listFiles({prefix = ""} = {}) {
      return [...files.keys()].filter((relativePath) =>
        relativePath.startsWith(prefix),
      );
    },
    readTexts(relativePaths, {required = false} = {}) {
      return new Map(
        [...relativePaths].map((relativePath) => {
          if (required && !files.has(relativePath)) {
            throw new Error(`Missing fixture path: ${relativePath}`);
          }
          return [relativePath, files.get(relativePath) ?? null];
        }),
      );
    },
  };
}

test("logical repository snapshot drives deterministic variant review candidates", () => {
  const first = buildWidgetVariantInventory(fixtureSnapshot());
  const second = buildWidgetVariantInventory(fixtureSnapshot());

  assert.deepEqual(first, second);
  assert.deepEqual(first.summary, {
    useCases: 2,
    components: 1,
    stateCards: 6,
    reviewCandidates: 1,
    oversizedUseCases: 0,
    multiUseCaseComponents: 1,
  });
  assert.deepEqual(first.reviewCandidates[0].review.reasons, [
    "duplicate-state-labels",
    "split-across-use-cases",
  ]);
  assert.deepEqual(
    first.reviewCandidates[0].useCases.map((useCase) => useCase.file),
    ["widgetbook/lib/primary.dart", "widgetbook/lib/secondary.dart"],
  );
});

test("CLI modes stay read-only while JSON remains available on demand", () => {
  assert.equal(fs.existsSync(retiredInventoryPath), false);

  const check = spawnSync(process.execPath, [scriptPath, "--check"], {
    cwd: repoRoot,
    encoding: "utf8",
    maxBuffer: 4 * 1024 * 1024,
  });
  assert.equal(check.status, 0, check.stderr);
  assert.match(check.stdout, /Widget variant inventory: \d+ use cases/u);

  const json = spawnSync(process.execPath, [scriptPath, "--json"], {
    cwd: repoRoot,
    encoding: "utf8",
    maxBuffer: 4 * 1024 * 1024,
  });
  assert.equal(json.status, 0, json.stderr);
  const inventory = JSON.parse(json.stdout);
  assert.ok(inventory.summary.useCases > 0);
  assert.equal(inventory.summary.components, inventory.components.length);
  assert.equal(fs.existsSync(retiredInventoryPath), false);
});
