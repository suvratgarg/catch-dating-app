import assert from "node:assert/strict";
import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import test from "node:test";

import {
  classifyLegacyCallsites,
  findCallLines,
  resolveAnchor,
  scanLegacyCallsites,
  validateManifest,
} from "./generate_flutter_field_surface_inventory.mjs";

test("ignores comment and string false positives", () => {
  const source = `
// CatchSelectChip(label: "comment")
final sample = "CatchSelectChip(label: 'string')";
/* CatchSelectChip(label: "block") */
CatchSelectChip(label: "real");
`;
  assert.deepEqual(findCallLines(source, "CatchSelectChip"), [5]);
});

test("finds generic constructor calls", () => {
  const source = "CatchChipField<ExampleValue>(values: values);\n";
  assert.deepEqual(findCallLines(source, "CatchChipField"), [1]);
});

test("finds named generic constructor calls", () => {
  const source = "CatchField.choices<ExampleValue>(values: values);\n";
  assert.deepEqual(findCallLines(source, "CatchField.choices"), [1]);
});

test("requires completion metadata and canonical anchors", () => {
  const candidate = {
    id: "FIELD-SURFACE-COMPLETE",
    rank: 1,
    status: "completed",
    risk: "low",
    reachability: "production_route",
    bindings: [{file: "lib/feature.dart", symbol: "FeatureScreen"}],
    anchors: [
      {
        file: "lib/feature.dart",
        symbol: "CatchField.input",
        expected: 1,
      },
    ],
    completedAt: "2026-07-16",
    verification: ["focused test"],
  };
  assert.doesNotThrow(() =>
    validateManifest({
      schemaVersion: 1,
      legacySymbols: ["CatchSelectChip"],
      candidates: [candidate],
    }),
  );
  assert.throws(
    () =>
      validateManifest({
        schemaVersion: 1,
        legacySymbols: ["CatchSelectChip"],
        candidates: [{...candidate, verification: []}],
      }),
    /verification is required/u,
  );
  assert.throws(
    () =>
      validateManifest({
        schemaVersion: 1,
        legacySymbols: ["CatchSelectChip"],
        candidates: [
          {
            ...candidate,
            anchors: [
              {
                file: "lib/feature.dart",
                symbol: "CatchSelectChip",
                expected: 1,
              },
            ],
          },
        ],
      }),
    /cannot retain legacy anchors/u,
  );
});

test("rejects an unclassified legacy callsite", () => {
  const result = classifyLegacyCallsites(
    [{file: "lib/feature.dart", line: 4, symbol: "CatchSelectChip"}],
    [],
  );
  assert.deepEqual(result.unclassified, [
    {file: "lib/feature.dart", line: 4, symbol: "CatchSelectChip"},
  ]);
});

test("rejects duplicate callsite classifications", () => {
  const result = classifyLegacyCallsites(
    [{file: "lib/feature.dart", line: 4, symbol: "CatchSelectChip"}],
    [
      {
        owner: "FIELD-SURFACE-ONE",
        file: "lib/feature.dart",
        symbol: "CatchSelectChip",
      },
      {
        owner: "FIELD-SURFACE-TWO",
        file: "lib/feature.dart",
        symbol: "CatchSelectChip",
      },
    ],
  );
  assert.deepEqual(result.duplicates, [
    {
      file: "lib/feature.dart",
      symbol: "CatchSelectChip",
      owners: ["FIELD-SURFACE-ONE", "FIELD-SURFACE-TWO"],
    },
  ]);
});

test("rejects stale expected anchor counts", () => {
  const repoRoot = fs.mkdtempSync(
    path.join(os.tmpdir(), "catch-field-anchor-test-"),
  );
  try {
    fs.mkdirSync(path.join(repoRoot, "lib"), {recursive: true});
    fs.writeFileSync(
      path.join(repoRoot, "lib/feature.dart"),
      "CatchSelectChip(label: 'one');\n",
    );
    assert.throws(
      () =>
        resolveAnchor(repoRoot, {
          file: "lib/feature.dart",
          symbol: "CatchSelectChip",
          expected: 2,
        }),
      /expected 2, observed 1/u,
    );
  } finally {
    fs.rmSync(repoRoot, {recursive: true, force: true});
  }
});

test("ignores constructor definition files", () => {
  const repoRoot = fs.mkdtempSync(
    path.join(os.tmpdir(), "catch-field-definition-test-"),
  );
  try {
    const definition = "lib/widgets/host_picker_tile.dart";
    fs.mkdirSync(path.join(repoRoot, "lib/widgets"), {recursive: true});
    fs.writeFileSync(
      path.join(repoRoot, definition),
      "class HostPickerTile { const HostPickerTile(); }\n",
    );
    assert.deepEqual(
      scanLegacyCallsites({
        repoRoot,
        manifest: {
          definitionFiles: [definition],
          scopeExclusions: [],
          legacySymbols: ["HostPickerTile"],
        },
      }),
      [],
    );
  } finally {
    fs.rmSync(repoRoot, {recursive: true, force: true});
  }
});
