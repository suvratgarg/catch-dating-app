import assert from "node:assert/strict";
import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import {spawnSync} from "node:child_process";
import test from "node:test";

const packageJson = JSON.parse(fs.readFileSync(new URL("../package.json", import.meta.url), "utf8"));
const runner = new URL("../scripts/run-tests.mjs", import.meta.url);
const pass = 'import test from "node:test"; test("selected sentinel", () => {});\n';
const fail = 'import test from "node:test"; test("selected sentinel", () => { throw Error("selected failure"); });\n';

function runFixture(files, args = []) {
  const root = fs.mkdtempSync(path.join(os.tmpdir(), "catch-ops-runner-"));
  try {
    fs.mkdirSync(path.join(root, "scripts"));
    fs.copyFileSync(runner, path.join(root, "scripts/run-tests.mjs"));
    fs.writeFileSync(path.join(root, "package.json"), JSON.stringify({
      private: true, type: "module", scripts: {test: packageJson.scripts.test},
    }));
    for (const [relative, source] of Object.entries(files)) {
      const file = path.join(root, relative);
      fs.mkdirSync(path.dirname(file), {recursive: true});
      fs.writeFileSync(file, source);
    }
    const env = {...process.env, npm_config_update_notifier: "false"};
    // A fixture is an independent supported npm invocation, not a nested test worker.
    delete env.NODE_TEST_CONTEXT;
    return spawnSync("npm", ["--prefix", root, "test", ...args], {
      cwd: root, env, encoding: "utf8", timeout: 15000,
    });
  } finally {
    fs.rmSync(root, {recursive: true, force: true});
  }
}

test("supported Operations command rejects an empty file selection", () => {
  for (const files of [{}, {"test/helpers.mjs": "export {};\n"}]) {
    const result = runFixture(files);
    assert.equal(result.status, 1, result.stdout + result.stderr);
    assert.match(result.stderr, /No Operations test files were discovered/u);
  }
});

for (const directory of ["test", "src/workflows/outreach-drafting"]) {
  test(`supported Operations command executes passing and failing ${directory} tests`, () => {
    const selected = `${directory}/sentinel.test.mjs`;
    const passing = runFixture({[selected]: pass});
    assert.equal(passing.status, 0, passing.stdout + passing.stderr);
    assert.match(passing.stdout, /selected sentinel/u);
    const failing = runFixture({[selected]: fail});
    assert.equal(failing.status, 1, failing.stdout + failing.stderr);
    assert.match(failing.stdout, /selected failure/u);
  });
}

test("supported Operations command retains both roots and intentional exclusions", () => {
  const result = runFixture({
    "test/first.test.mjs": pass,
    "src/workflows/outreach-drafting/second.test.mjs": pass,
    "test/nested/excluded.test.mjs": fail,
    "test/.hidden.test.mjs": fail,
    "test/helper.mjs": fail,
    "src/workflows/other/excluded.test.mjs": fail,
  });
  assert.equal(result.status, 0, result.stdout + result.stderr);
  assert.match(result.stdout, /Running 2 discovered Operations test files/u);
});

test("supported Operations command fails when a selected test child is terminated", () => {
  const result = runFixture({
    "test/killed.test.mjs": 'process.kill(process.pid, "SIGTERM");\n',
  });
  assert.equal(result.status, 1, result.stdout + result.stderr);
  assert.match(result.stdout, /killed.test.mjs/u);
});

test("supported Operations command fails when the Node test runner is terminated", () => {
  const result = runFixture({
    "test/killed-runner.test.mjs": 'process.kill(process.ppid, "SIGKILL");\n',
  });
  assert.equal(result.status, 1, result.stdout + result.stderr);
  assert.match(result.stderr, /Operations test process terminated by SIGKILL/u);
});
