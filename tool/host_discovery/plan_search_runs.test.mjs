import assert from "node:assert/strict";
import fs from "node:fs";
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

test("search intent generation delegates freshness to Operations runs", () => {
  const result = spawnSync(
    process.execPath,
    [script, "--as-of", "2026-07-26"],
    {encoding: "utf8"}
  );

  assert.equal(result.status, 0, result.stderr);
  const plan = JSON.parse(
    fs.readFileSync(
      "tool/host_discovery/generated/search_plan.json",
      "utf8"
    )
  );
  assert.equal(
    plan.freshnessAuthority,
    "immutable completed supply-intake operation runs"
  );
  assert.equal("freshForDays" in plan, false);
  assert.equal("runs" in plan.generatedFrom, false);
  assert.equal(plan.skippedFreshCount, 0);
  assert.equal(plan.skippedFresh.length, 0);
});
