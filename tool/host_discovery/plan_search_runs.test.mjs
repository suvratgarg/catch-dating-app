import assert from "node:assert/strict";
import {spawnSync} from "node:child_process";
import test from "node:test";

const script = "tool/host_discovery/plan_search_runs.mjs";

test("current-date check ignores the generated as-of label when classifications match", () => {
  const result = spawnSync(
    process.execPath,
    [script, "--check-current", "--as-of", "2026-07-11"],
    {encoding: "utf8"}
  );

  assert.equal(result.status, 0, result.stderr);
  assert.match(result.stdout, /Host discovery search plan ready/);
});

test("search planner rejects malformed operational dates", () => {
  const result = spawnSync(
    process.execPath,
    [script, "--check-current", "--as-of", "not-a-date"],
    {encoding: "utf8"}
  );

  assert.equal(result.status, 64);
  assert.match(result.stderr, /must use YYYY-MM-DD/);
});
