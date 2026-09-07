import assert from "node:assert/strict";
import fs from "node:fs";
import test from "node:test";

import {
  buildFieldFacadeInventory,
  buildFromRepo,
  extractCatchFieldFacades,
  extractCatchSectionContract,
  extractCatchSectionVariants,
  facadeUseWhen,
} from "./generate_field_inventory.mjs";

const source = fs.readFileSync("lib/core/widgets/catch_field.dart", "utf8");
const sectionSource = fs.readFileSync(
  "packages/catch_ui/lib/src/components/catch_section.dart",
  "utf8",
);
const statusPath = "packages/catch_ui/lib/src/components/catch_field_status.dart";
const statusSource = fs.readFileSync(statusPath, "utf8");
const {interactionContracts} = JSON.parse(
  fs.readFileSync("design/components/catch.components.json", "utf8"),
);

test("builds the live inventory from the package-owned status enum", () => {
  const inventory = buildFromRepo();
  assert.equal(inventory.summary.facadeCount, 14);
  assert.equal(inventory.summary.saveStateCount, 3);
  assert.equal(inventory.source.catchFieldStatus, statusPath);
  assert.match(inventory.source.catchFieldStatusApiSha256, /^[a-f0-9]{64}$/u);
});

test("rejects package status drift even when the former owner has a matching enum", () => {
  assert.throws(
    () => buildFieldFacadeInventory({
      fieldSource: `${source}\n${statusSource}`,
      sectionSource,
      statusSource: statusSource.replace(/\bsaved\b/u, "synced"),
      interactionContracts,
    }),
    /interactionContracts\.field_row\.saveStates drifted/u,
  );
});

test("does not fall back to a status enum in the former owner", () => {
  assert.throws(
    () => buildFieldFacadeInventory({
      fieldSource: `${source}\n${statusSource}`,
      sectionSource,
      statusSource: "",
      interactionContracts,
    }),
    /Unable to find enum CatchFieldStatus/u,
  );
});

test("extracts every current facade and semantic slot", () => {
  const facades = extractCatchFieldFacades(source);
  assert.deepEqual(
    facades.map((entry) => entry.mode),
    [
      "read",
      "content",
      "nav",
      "sortable",
      "action",
      "toggle",
      "input",
      "control",
      "choices",
      "optionCards",
      "stepper",
      "inputActions",
      "add",
      "select",
    ],
  );
  assert.ok(facades.find((entry) => entry.mode === "input").slots.includes("error"));
  assert.ok(facades.find((entry) => entry.mode === "choices").slots.includes("control"));
  assert.deepEqual(extractCatchSectionVariants(sectionSource), [
    "divided",
    "fieldRows",
    "containedFieldRows",
    "containedFieldGroups",
    "contained",
    "plain",
  ]);
  assert.deepEqual(extractCatchSectionContract(sectionSource).slots, [
    "title",
    "subtitle",
    "trailing",
    "count",
    "footer",
    "groups",
    "children",
    "child",
  ]);
});

test("known-bad deleted facade changes generated inventory", () => {
  const deleted = source.replace(
    /\n  const factory CatchField\.add\([\s\S]*?\) = _RowConfig\.add;\n/u,
    "\n",
  );
  const modes = extractCatchFieldFacades(deleted).map((entry) => entry.mode);
  assert.ok(!modes.includes("add"));
  assert.equal(modes.length, 13);
});

test("known-bad added slot parameter changes generated inventory", () => {
  const changed = source.replace(
    "const factory CatchField.read({",
    "const factory CatchField.read({\n    Widget? feedback,",
  );
  const read = extractCatchFieldFacades(changed).find((entry) => entry.mode === "read");
  assert.ok(read.parameters.some((parameter) => parameter.name === "feedback"));
  assert.ok(read.slots.includes("feedback"));
});

test("rejects a facade without owner-reviewed use-when metadata", () => {
  const metadata = {...facadeUseWhen};
  delete metadata.optionCards;
  assert.throws(
    () => extractCatchFieldFacades(source, {useWhen: metadata}),
    /optionCards is missing owner-reviewed use-when metadata/u,
  );
});
