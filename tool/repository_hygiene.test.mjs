import test from "node:test";
import assert from "node:assert/strict";
import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import {sizeOf} from "./repository_hygiene.mjs";

test("size inspection counts nested symlinks without traversing them", (t) => {
  const root = fs.mkdtempSync(path.join(os.tmpdir(), "catch-hygiene-"));
  t.after(() => fs.rmSync(root, {recursive: true, force: true}));
  fs.writeFileSync(path.join(root, "payload.txt"), "payload");
  fs.symlinkSync("payload.txt", path.join(root, "nested-link"));
  assert.ok(sizeOf(root) >= Buffer.byteLength("payload"));
});

test("a cleanup candidate that is itself a symlink is rejected", (t) => {
  const root = fs.mkdtempSync(path.join(os.tmpdir(), "catch-hygiene-"));
  t.after(() => fs.rmSync(root, {recursive: true, force: true}));
  fs.writeFileSync(path.join(root, "payload.txt"), "payload");
  const link = path.join(root, "candidate-link");
  fs.symlinkSync("payload.txt", link);
  assert.throws(() => sizeOf(link), /refusing symlink candidate/);
});
