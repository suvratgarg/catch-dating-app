import test from "node:test";
import assert from "node:assert/strict";
import {toolCategoryCoverage} from "./check_tool_category_coverage.mjs";

test("coverage fails for both unknown workflow and missing active categories", () => {
  const result = toolCategoryCoverage({
    manifest: {
      tools: [
        {status: "active", category: "meta"},
        {status: "active", category: "design"},
        {status: "archived", category: "legacy"},
      ],
    },
    workflowText: "categories: meta scanners\n",
  });
  assert.equal(result.ok, false);
  assert.deepEqual(result.unknown, ["scanners"]);
  assert.deepEqual(result.missing, ["design"]);
});

test("coverage passes when every active category is declared exactly", () => {
  const result = toolCategoryCoverage({
    manifest: {
      tools: [
        {status: "active", category: "meta"},
        {status: "active", category: "design"},
      ],
    },
    workflowText: "categories: meta design\n",
  });
  assert.equal(result.ok, true);
  assert.deepEqual(result.unknown, []);
  assert.deepEqual(result.missing, []);
});
