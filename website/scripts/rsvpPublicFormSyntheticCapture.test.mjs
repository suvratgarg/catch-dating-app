import assert from "node:assert/strict";
import {execFileSync} from "node:child_process";
import {mkdtemp, mkdir, readFile, writeFile, rm, symlink} from "node:fs/promises";
import {tmpdir} from "node:os";
import path from "node:path";
import test from "node:test";
import {assertNoSymlinks, extractSnapshot, publishCaptures, scenarioNames,
  selectScenarios, validateOutput} from "./rsvpPublicFormSyntheticCapture.mjs";

async function temporary(t) {
  const root = await mkdtemp(path.join(tmpdir(), "rsvp-capture-test-"));
  t.after(() => rm(root, {recursive: true, force: true}));
  return root;
}

test("scenario selection fails closed for empty, unknown, and repeated names", () => {
  assert.deepEqual(selectScenarios(undefined), scenarioNames);
  assert.deepEqual(selectScenarios("purpose-review-mobile, audience-form-desktop"),
    ["purpose-review-mobile", "audience-form-desktop"]);
  for (const invalid of ["", " ", "unknown", "purpose-review-mobile,", "purpose-review-mobile,purpose-review-mobile"]) {
    assert.throws(() => selectScenarios(invalid), /unique known scenarios/);
  }
});

test("renderer snapshot reads committed dependencies even when the source checkout is dirty", async (t) => {
  const root = await temporary(t);
  const source = path.join(root, "repo");
  const snapshot = path.join(root, "snapshot");
  await mkdir(source); await mkdir(snapshot);
  const git = (...args) => execFileSync("git", args, {cwd: source, encoding: "utf8"}).trim();
  git("init", "-q");
  git("config", "user.name", "Fixture"); git("config", "user.email", "fixture@example.com");
  git("config", "core.hooksPath", "/dev/null");
  for (const file of ["package.json", "package-lock.json", "admin/package.json", "website/src/shared/ui/primitives.ts", "packages/web-config/styles/tokens.css", "functions/src/shared/generated/fixture.ts"]) {
    await mkdir(path.dirname(path.join(source, file)), {recursive: true});
    await writeFile(path.join(source, file), file.endsWith("json") ? "{}" : "committed content");
  }
  git("add", "."); git("commit", "-qm", "Pinned renderer fixture");
  const sha = git("rev-parse", "HEAD");
  await writeFile(path.join(source, "website/src/shared/ui/primitives.ts"), "DIRTY renderer");
  await writeFile(path.join(source, "packages/web-config/styles/tokens.css"), "DIRTY shared tokens");
  await writeFile(path.join(source, "website/src/untracked.ts"), "untracked renderer");
  const result = extractSnapshot(source, sha, snapshot, path.join(root, "snapshot.tar"));
  assert.equal(result.sourceSha, sha);
  assert.equal(result.sourceTree, git("rev-parse", "HEAD^{tree}"));
  assert.match(result.packageLockSha256, /^[a-f0-9]{64}$/);
  assert.equal(await readFile(path.join(snapshot, "website/src/shared/ui/primitives.ts"), "utf8"), "committed content");
  assert.equal(await readFile(path.join(snapshot, "packages/web-config/styles/tokens.css"), "utf8"), "committed content");
  await assert.rejects(readFile(path.join(snapshot, "website/src/untracked.ts")), {code: "ENOENT"});
  assert.throws(() => extractSnapshot(source, "HEAD", snapshot, path.join(root, "invalid.tar")), /full commit SHA/);
});

test("archived source cannot escape through a symlink", async (t) => {
  const root = await temporary(t);
  await symlink(tmpdir(), path.join(root, "outside"));
  assert.throws(() => assertNoSymlinks(root), /contains a symlink/);
});

test("capture output must be a fresh absolute directory", async (t) => {
  const root = await temporary(t);
  assert.throws(() => validateOutput("relative", root), /absolute new directory/);
  assert.throws(() => validateOutput(root, root), /already exists/);
  assert.doesNotThrow(() => validateOutput(path.join(root, "result"), path.join(root, "elsewhere")));
});

test("partial selection publishes its exact manifest alongside captures and preserves existing evidence", async (t) => {
  const root = await temporary(t);
  const staging = path.join(root, "staging");
  const output = path.join(root, "output");
  await mkdir(staging);
  await writeFile(path.join(staging, "purpose-review-mobile.png"), "synthetic screenshot bytes");
  const manifest = {sourceSha: "a".repeat(40), scenarios: [{name: "purpose-review-mobile", file: "purpose-review-mobile.png"}]};
  await publishCaptures(staging, output, manifest);
  assert.deepEqual(JSON.parse(await readFile(path.join(output, "manifest.json"), "utf8")), manifest);
  await assert.rejects(readFile(path.join(staging, "manifest.json")), {code: "ENOENT"});
  const next = path.join(root, "next"); await mkdir(next);
  await assert.rejects(publishCaptures(next, output, {sourceSha: "b".repeat(40)}), /refusing to replace/);
  assert.deepEqual(JSON.parse(await readFile(path.join(output, "manifest.json"), "utf8")), manifest);
});
