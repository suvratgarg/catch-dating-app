import assert from "node:assert/strict";
import fs from "node:fs/promises";
import os from "node:os";
import path from "node:path";
import test from "node:test";
import {collectSchema} from "../src/platform/schema-dependencies.mjs";

test("local schema loading follows fragments and cyclic shared dependencies", async () => {
  const root = await fs.mkdtemp(path.join(os.tmpdir(), "operations-schemas-"));
  try {
    await fs.writeFile(path.join(root, "root.json"), JSON.stringify({
      allOf: [{$ref: "shared.json#/definitions/one"},
        {$ref: "shared.json#/definitions/two"}],
    }));
    await fs.writeFile(path.join(root, "shared.json"), JSON.stringify({
      definitions: {one: {$ref: "root.json"}, two: {$ref: "#/definitions/one"}},
    }));
    const schemas = new Map();
    await collectSchema(path.join(root, "root.json"), schemas);
    assert.equal(schemas.size, 2);
    await collectSchema(path.join(root, "root.json"), schemas);
    assert.equal(schemas.size, 2);
    await fs.rm(path.join(root, "shared.json"));
    await assert.rejects(collectSchema(path.join(root, "root.json"), new Map()),
      {code: "ENOENT"});
  } finally {
    await fs.rm(root, {recursive: true, force: true});
  }
});
