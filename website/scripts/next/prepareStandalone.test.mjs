import assert from "node:assert/strict";
import {mkdtemp, mkdir, writeFile, readFile, readdir, rm} from "node:fs/promises";
import os from "node:os";
import path from "node:path";
import test from "node:test";
import {prepareStandalone} from "./prepareStandalone.mjs";

test("standalone packaging preserves source and replaces stale runtime chunks", async () => {
  const root = await mkdtemp(path.join(os.tmpdir(), "catch-next-package-"));
  async function file(name, text) {
    await mkdir(path.dirname(path.join(root, name)), {recursive: true});
    await writeFile(path.join(root, name), text);
  }
  try {
    await file("public/.well-known/apple-app-site-association", "association");
    await file(".next-legacy/assets/current.js", "private flow");
    await file(".next-legacy/index.html", "generic shell");
    await file(".next/static/current.js", "public route");
    await file(".next/standalone/website/public/_legacy/assets/stale.js", "old");
    await file(".next/standalone/website/.next/static/stale.js", "old");
    const runtime = await prepareStandalone(root);
    await prepareStandalone(root);
    assert.deepEqual(await readdir(path.join(root, "public")), [".well-known"]);
    assert.deepEqual(await readdir(path.join(runtime, "public/_legacy/assets")), ["current.js"]);
    assert.deepEqual(await readdir(path.join(runtime, ".next/static")), ["current.js"]);
    assert.equal(await readFile(path.join(runtime, "public/.well-known/apple-app-site-association"), "utf8"), "association");
    assert.equal(await readFile(path.join(runtime, "public/_legacy/index.html"), "utf8"), "generic shell");
  } finally {await rm(root, {recursive: true, force: true});}
});
