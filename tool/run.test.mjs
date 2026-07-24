import test from "node:test";
import assert from "node:assert/strict";
import {spawnSync} from "node:child_process";
import fs from "node:fs";
import path from "node:path";
import {
  supportedToolPlatforms,
  toolSupportsPlatform,
  validateToolPlatforms,
} from "./lib/tool_platform.mjs";

function run(args) {
  return spawnSync("node", ["tool/run.mjs", ...args], {
    cwd: process.cwd(),
    encoding: "utf8",
  });
}

test("filtered checks fail when a category matches no tools", () => {
  const result = run(["check", "--category", "definitely-missing"]);
  assert.equal(result.status, 64);
  assert.match(result.stderr, /No active tools matched category definitely-missing/);
});

test("platform-specific tools run only on declared operating systems", () => {
  const tool = {id: "fixture:darwin-only", platforms: ["darwin"]};
  assert.equal(toolSupportsPlatform(tool, "darwin"), true);
  assert.equal(toolSupportsPlatform(tool, "linux"), false);
  assert.equal(toolSupportsPlatform({id: "fixture:anywhere"}, "linux"), true);
  assert.deepEqual(validateToolPlatforms(tool), []);
  assert.deepEqual(
    validateToolPlatforms({platforms: ["darwin", "darwin"]}),
    ["platforms must not contain duplicates"],
  );
  assert.deepEqual(
    validateToolPlatforms({platforms: ["plan9"]}),
    ['platforms contains unsupported value "plan9"'],
  );
  assert.deepEqual(
    [...supportedToolPlatforms],
    ["darwin", "linux", "win32"],
  );
});

test("impact routing reports the owning relationship and checks", () => {
  const result = run(["impacted", "--paths", "contracts/firestore/users.schema.json", "--json"]);
  assert.equal(result.status, 0, result.stderr);
  const payload = JSON.parse(result.stdout);
  assert.ok(payload.relationships.includes("backend-contracts"));
  assert.ok(payload.toolIds.includes("contracts:validate-schemas"));
  assert.deepEqual(payload.unmatchedPaths, []);
});

test("impact routing includes field inventory for Flutter design consumers", () => {
  const result = run(["impacted", "--paths", "lib/routing/go_router.dart", "--json"]);
  assert.equal(result.status, 0, result.stderr);
  const payload = JSON.parse(result.stdout);
  assert.ok(payload.relationships.includes("design-system"));
  assert.ok(payload.toolIds.includes("design:flutter-field-surface-inventory"));
  assert.deepEqual(payload.unmatchedPaths, []);
});

test("impact routing fails closed for an unmapped changed path", () => {
  const result = run(["impacted", "--paths", "unowned/example.txt", "--json"]);
  assert.equal(result.status, 1);
  assert.match(result.stderr, /Unmapped changed paths/);
});

test("impact routing includes untracked files", (context) => {
  const probe = path.join(process.cwd(), "unowned-impact-probe.tmp");
  fs.writeFileSync(probe, "probe\n");
  context.after(() => fs.rmSync(probe, {force: true}));
  const result = run(["impacted", "--json"]);
  assert.equal(result.status, 1);
  assert.match(result.stderr, /unowned-impact-probe\.tmp/);
});
