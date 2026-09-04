const assert = require("node:assert/strict");
const fs = require("node:fs");
const path = require("node:path");
const test = require("node:test");

const sourceRoot = path.resolve(__dirname, "../src");
const allowedPrefixes = [
  "onCall(appCheckCallableOptions",
  "onCall(appCheckCallableOptionsWithLimits",
  "onCall(appCheckCallableOptionsWithSecrets",
];

function tsFiles(dir) {
  return fs.readdirSync(dir, {withFileTypes: true}).flatMap((entry) => {
    const entryPath = path.join(dir, entry.name);
    if (entry.isDirectory()) return tsFiles(entryPath);
    return entry.name.endsWith(".ts") ? [entryPath] : [];
  });
}

test("callable functions use shared App Check enforcement options", () => {
  const missing = [];

  for (const filePath of tsFiles(sourceRoot)) {
    const source = fs.readFileSync(filePath, "utf8");
    let index = source.indexOf("onCall(");
    while (index !== -1) {
      const snippet = source.slice(index, index + 64).replace(/\s+/g, " ");
      const normalizedSnippet = snippet.replace(/^onCall\(\s+/, "onCall(");
      if (!allowedPrefixes.some((prefix) =>
        normalizedSnippet.startsWith(prefix)
      )) {
        missing.push(`${path.relative(sourceRoot, filePath)}: ${snippet}`);
      }
      index = source.indexOf("onCall(", index + 1);
    }
  }

  assert.deepEqual(missing, []);
});

test("shared callable options declare App Check and public invoker intent", () => {
  const source = fs.readFileSync(
    path.join(sourceRoot, "shared", "callableOptions.ts"),
    "utf8",
  );

  const {enforceAppCheckForRuntime, appCheckCallableOptions} = require("../lib/shared/callableOptions.js");
  assert.equal(appCheckCallableOptions.enforceAppCheck, true);
  assert.equal(enforceAppCheckForRuntime({}), true);
  const local = {FUNCTIONS_EMULATOR: "true", GCLOUD_PROJECT: "demo-catch",
    FIREBASE_AUTH_EMULATOR_HOST: "127.0.0.1:9099", FIRESTORE_EMULATOR_HOST: "127.0.0.1:8080",
    FIREBASE_STORAGE_EMULATOR_HOST: "127.0.0.1:9199"};
  assert.equal(enforceAppCheckForRuntime(local), false);
  for (const key of Object.keys(local)) {
    const missing = {...local}; delete missing[key];
    assert.equal(enforceAppCheckForRuntime(missing), true, key);
  }
  assert.equal(enforceAppCheckForRuntime({...local, GCLOUD_PROJECT: "catchdates-dev"}), true);
  assert.equal(enforceAppCheckForRuntime({...local, GCLOUD_PROJECT: "catch-dating-app-64e51"}), true);
  assert.equal(enforceAppCheckForRuntime({...local, FIRESTORE_EMULATOR_HOST: "cloud.example:8080"}), true);
  assert.match(source, /invoker:\s*"public"/);
});
