"use strict";

const assert = require("node:assert/strict");
const fs = require("node:fs");
const os = require("node:os");
const path = require("node:path");
const test = require("node:test");
const {discoverTestFiles} = require("../scripts/run-tests.cjs");

test("discovers every compiled and harness test without a folder allowlist", () => {
  const root = fs.mkdtempSync(path.join(os.tmpdir(), "catch-functions-tests-"));
  try {
    for (const relativePath of [
      "lib/existing/one.test.js",
      "lib/newDomain/nested/two.test.js",
      "lib/newDomain/not-a-test.js",
      "test/callable.test.cjs",
      "test/firestore.rules.test.cjs",
    ]) {
      const absolutePath = path.join(root, relativePath);
      fs.mkdirSync(path.dirname(absolutePath), {recursive: true});
      fs.writeFileSync(absolutePath, "");
    }

    assert.deepEqual(discoverTestFiles(root), [
      "lib/existing/one.test.js",
      "lib/newDomain/nested/two.test.js",
      "test/callable.test.cjs",
    ]);
  } finally {
    fs.rmSync(root, {recursive: true, force: true});
  }
});
