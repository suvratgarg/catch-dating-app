import assert from "node:assert/strict";
import {spawnSync} from "node:child_process";
import test from "node:test";

test("admin action catalog generator has a non-vacuous drift self-test", () => {
  const result = spawnSync(process.execPath, [
    "tool/admin/generate_admin_action_catalog.mjs",
    "--self-test",
  ], {encoding: "utf8"});
  assert.equal(result.status, 0, result.stderr);
  assert.match(result.stdout, /detected drift/u);
});
