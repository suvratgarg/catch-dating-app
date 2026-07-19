import assert from "node:assert/strict";
import fs from "node:fs";
import test from "node:test";

import {
  extractCatchFieldFacades,
  extractCatchSectionContract,
  extractCatchSectionVariants,
  facadeUseWhen,
} from "./generate_field_inventory.mjs";

const source = fs.readFileSync("lib/core/widgets/catch_field.dart", "utf8");
const sectionSource = fs.readFileSync(
  "lib/core/widgets/catch_section_layout.dart",
  "utf8",
);

test("extracts every current facade and semantic slot", () => {
  const facades = extractCatchFieldFacades(source);
  assert.deepEqual(
    facades.map((entry) => entry.mode),
    [
      "read",
      "content",
      "nav",
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
    "contained",
    "plain",
  ]);
  assert.deepEqual(extractCatchSectionContract(sectionSource).slots, [
    "title",
    "subtitle",
    "trailing",
    "count",
    "footer",
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
  assert.equal(modes.length, 12);
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
