import assert from "node:assert/strict";
import fs from "node:fs/promises";
import os from "node:os";
import path from "node:path";
import {spawnSync} from "node:child_process";
import test from "node:test";
const packageJson = JSON.parse(await fs.readFile(new URL("../package.json", import.meta.url), "utf8"));

test("supported Operations test selection includes the nested Sales adapter suite", () => {
  assert.equal(packageJson.scripts.test,
    "node --test test/*.test.mjs src/workflows/outreach-drafting/*.test.mjs");
});

test("a failing nested adapter sentinel fails the unchanged supported npm test command", async (t) => {
  const directory = await fs.mkdtemp(path.join(os.tmpdir(), "catch-outreach-discovery-"));
  t.after(() => fs.rm(directory, {recursive: true, force: true}));
  await fs.mkdir(path.join(directory, "test"));
  const nested = path.join(directory, "src/workflows/outreach-drafting");
  await fs.mkdir(nested, {recursive: true});
  await fs.writeFile(path.join(directory, "package.json"), JSON.stringify({
    private: true, scripts: {test: packageJson.scripts.test}}));
  await fs.writeFile(path.join(directory, "test/pass.test.mjs"),
    'import test from "node:test"; test("top-level pass", () => {});');
  await fs.writeFile(path.join(nested, "sales-adapter.test.mjs"),
    'import test from "node:test"; test("nested discovery sentinel", () => {throw new Error("expected sentinel");});');
  // This fixture is a separate supported-command invocation. Inheriting the
  // parent runner marker makes Node skip its files as a recursive test run.
  const env = {...process.env};
  delete env.NODE_TEST_CONTEXT;
  const result = spawnSync("npm", ["test", "--ignore-scripts"], {
    cwd: directory, env, encoding: "utf8", timeout: 20_000});
  assert.equal(result.error, undefined);
  assert.equal(result.status, 1, result.stdout + result.stderr);
  assert.match(result.stdout + result.stderr, /nested discovery sentinel/u);
  assert.match(result.stdout + result.stderr, /expected sentinel/u);
});
