import test from "node:test";
import assert from "node:assert/strict";
import {
  buildInventory,
  classifyTest,
  renderInventory,
} from "./test_inventory.mjs";

test("classifies test surfaces without generated build output", () => {
  assert.equal(classifyTest("test/auth/login_test.dart"), "flutter_unit_widget");
  assert.equal(classifyTest("functions/src/admin/foo.test.ts"), "functions_source");
  assert.equal(classifyTest("functions/lib/admin/foo.test.js"), null);
});

test("inventory is deterministic", () => {
  const inventory = buildInventory(["test/z_test.dart", "test/a_test.dart"]);
  assert.deepEqual(inventory.categories.flutter_unit_widget.files, ["test/a_test.dart", "test/z_test.dart"]);
  assert.equal(renderInventory(inventory).endsWith("\n"), true);
});
