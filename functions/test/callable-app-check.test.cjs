const assert = require("node:assert/strict");
const fs = require("node:fs");
const path = require("node:path");
const test = require("node:test");

const sourceRoot = path.resolve(__dirname, "../src");
const allowedPrefixes = [
  "onCall(appCheckCallableOptions",
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
