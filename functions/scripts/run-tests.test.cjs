"use strict";

const assert = require("node:assert/strict");
const fs = require("node:fs");
const os = require("node:os");
const path = require("node:path");
const {spawnSync} = require("node:child_process");
const {test} = require("node:test");

const runner = require.resolve("./run-tests.cjs");
function fixture(source, {emulators = true, files = ["case.test.cjs"]} = {}) {
  const root = fs.mkdtempSync(path.join(os.tmpdir(), "catch-strict-tests-"));
  try {
    fs.writeFileSync(path.join(root, "case.test.cjs"), source);
    const env = {...process.env};
    delete env.NODE_TEST_CONTEXT;
    delete env.FIRESTORE_EMULATOR_HOST;
    delete env.FIREBASE_STORAGE_EMULATOR_HOST;
    if (emulators) {
      env.FIRESTORE_EMULATOR_HOST = "127.0.0.1:1";
      env.FIREBASE_STORAGE_EMULATOR_HOST = "127.0.0.1:2";
    }
    const launcher = path.join(root, "launcher.cjs");
    fs.writeFileSync(launcher,
      `require(${JSON.stringify(runner)}).runStrictFiles(${JSON.stringify(files)}, {root: ${JSON.stringify(root)}}).then(code => process.exitCode = code).catch(error => {console.error(error); process.exitCode = 1;});`);
    return spawnSync(process.execPath, [launcher], {env, encoding: "utf8", timeout: 15000});
  } finally {
    fs.rmSync(root, {recursive: true, force: true});
  }
}

test("strict integration emits actual executed test IDs and counts", () => {
  const result = fixture("require('node:test').test('permission denied', () => { const assert = require('node:assert/strict'); assert.ok(process.env.FIRESTORE_EMULATOR_HOST); assert.ok(process.env.FIREBASE_STORAGE_EMULATOR_HOST); });");
  assert.equal(result.status, 0, result.stderr);
  const evidence = JSON.parse(result.stdout.trim().split("\n").at(-1));
  assert.equal(evidence.success, true);
  assert.equal(evidence.selected.length, 1);
  assert.equal(evidence.executed[0].name, "permission denied");
  assert.equal(evidence.executed[0].status, "pass");
  assert.equal(Object.values(evidence.summaries)[0].passed, 1);
});

for (const [name, source] of [
  ["assertion failure", "require('node:test').test('rules deny', () => require('node:assert/strict').equal(true, false));"],
  ["skip", "require('node:test').test('emulator permission', {skip: true}, () => {});"],
  ["todo", "require('node:test').test.todo('pending permission');"],
  ["empty skip reason", "require('node:test').test('permission', {skip: ''}, () => {});"],
  ["empty todo reason", "require('node:test').test('permission', {todo: ''}, () => {});"],
  ["empty file", "// No tests"],
  ["nested skip", "require('node:test').test('suite', async t => { await t.test('permission', {skip:true}, () => {}); });"],
]) {
  test(`strict integration fails closed on ${name}`, () => {
    const result = fixture(source);
    assert.equal(result.status, 1, `${result.stdout}\n${result.stderr}`);
    const evidence = JSON.parse(result.stdout.trim().split("\n").at(-1));
    assert.equal(evidence.success, false);
    if (name === "empty file") {
      assert.match(result.stderr, /No executed tests proved/u);
    } else {
      assert.ok(evidence.executed.some(event =>
        event.status === (name === "assertion failure" ? "fail" : name.includes("todo") ? "todo" : "skipped")),
      JSON.stringify(evidence));
    }
  });
}

test("missing emulators fail before test code runs", () => {
  const result = fixture("throw new Error('should not execute');", {emulators: false});
  assert.equal(result.status, 1);
  assert.match(result.stderr, /FIRESTORE_EMULATOR_HOST is required/u);
  assert.doesNotMatch(result.stderr, /should not execute/u);
});

test("empty and duplicate selections fail before execution", () => {
  for (const files of [[], ["case.test.cjs", "case.test.cjs"]]) {
    const result = fixture("", {files});
    assert.equal(result.status, 1);
    assert.match(result.stderr, /nonempty, unique test files/u);
  }
});
