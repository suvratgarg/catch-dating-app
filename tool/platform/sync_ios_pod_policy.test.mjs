import assert from "node:assert/strict";
import {spawnSync} from "node:child_process";
import {createHash} from "node:crypto";
import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import test from "node:test";
import {iosPodPolicyOutputs, syncIosPodPolicy} from "./sync_ios_pod_policy.mjs";

const sourceRoot = new URL("../../", import.meta.url);
const outputPaths = iosPodPolicyOutputs.flatMap(({outputs}) => outputs);

function fixture(t) {
  const repoRoot = fs.mkdtempSync(path.join(os.tmpdir(), "catch ios policy "));
  t.after(() => fs.rmSync(repoRoot, {recursive: true, force: true}));
  for (const {template} of iosPodPolicyOutputs) {
    const target = path.join(repoRoot, template);
    fs.mkdirSync(path.dirname(target), {recursive: true});
    fs.copyFileSync(new URL(template, sourceRoot), target);
  }
  syncIosPodPolicy({repoRoot, write: true});
  return repoRoot;
}

test("checked-in iOS policies match their authored templates byte for byte", () => {
  assert.deepEqual(syncIosPodPolicy(), []);
  assert.equal(outputPaths.length, 6);
});

test("no-op generation preserves every generated file and its warm-checkout timestamp", (t) => {
  const repoRoot = fixture(t);
  const before = outputPaths.map((output) => {
    const filename = path.join(repoRoot, output);
    fs.utimesSync(filename, 1000, 1000);
    return {bytes: fs.readFileSync(filename), stat: fs.statSync(filename)};
  });
  assert.deepEqual(syncIosPodPolicy({repoRoot, write: true}), []);
  for (const [i, output] of outputPaths.entries()) {
    const filename = path.join(repoRoot, output);
    assert.deepEqual(fs.readFileSync(filename), before[i].bytes);
    assert.equal(fs.statSync(filename).mtimeMs, before[i].stat.mtimeMs);
    assert.equal(fs.statSync(filename).ino, before[i].stat.ino);
  }
});

test("stale or missing output fails read-only check and write repairs exactly those files", (t) => {
  const repoRoot = fixture(t);
  const modified = "apps/consumer/ios/Podfile";
  const missing = "apps/host/ios/Flutter/CatchBuildSettings.xcconfig";
  fs.appendFileSync(path.join(repoRoot, modified), "# stale\n");
  fs.unlinkSync(path.join(repoRoot, missing));
  assert.deepEqual(syncIosPodPolicy({repoRoot}), [modified, missing]);
  assert.match(fs.readFileSync(path.join(repoRoot, modified), "utf8"), /# stale/);
  assert.equal(fs.existsSync(path.join(repoRoot, missing)), false);
  assert.deepEqual(syncIosPodPolicy({repoRoot, write: true}), [modified, missing]);
  assert.deepEqual(syncIosPodPolicy({repoRoot}), []);
});

test("policy edits change all actual Podfiles while leaving locks and installation state alone", (t) => {
  const repoRoot = fixture(t);
  const podfiles = iosPodPolicyOutputs[0].outputs;
  const digest = (filename) => createHash("sha1").update(fs.readFileSync(filename)).digest("hex");
  const before = new Map();
  for (const output of podfiles) {
    const podfile = path.join(repoRoot, output);
    before.set(output, digest(podfile));
    fs.utimesSync(podfile, 1000, 1000);
    fs.writeFileSync(`${podfile}.lock`, "locked role-specific graph\n");
    fs.utimesSync(`${podfile}.lock`, 2000, 2000);
    const manifest = path.join(path.dirname(podfile), "Pods/Manifest.lock");
    fs.mkdirSync(path.dirname(manifest), {recursive: true});
    fs.copyFileSync(`${podfile}.lock`, manifest);
    fs.utimesSync(manifest, 2000, 2000);
  }
  const template = path.join(repoRoot, "ios/Podfile.template");
  fs.appendFileSync(template, "\n# changed native policy\n");
  assert.deepEqual(syncIosPodPolicy({repoRoot}), podfiles);
  assert.deepEqual(syncIosPodPolicy({repoRoot, write: true}), podfiles);
  for (const output of podfiles) {
    const podfile = path.join(repoRoot, output);
    const manifest = path.join(path.dirname(podfile), "Pods/Manifest.lock");
    assert.notEqual(digest(podfile), before.get(output));
    assert.deepEqual(fs.readFileSync(podfile), fs.readFileSync(template));
    // Flutter observes the actual Podfile as newer than its lock. Generation
    // must not claim pod-install success, even when installation later fails.
    assert.ok(fs.statSync(podfile).mtimeMs > fs.statSync(`${podfile}.lock`).mtimeMs);
    assert.equal(fs.readFileSync(manifest, "utf8"), "locked role-specific graph\n");
    assert.equal(fs.statSync(manifest).mtimeMs, 2000000);
  }
  // An interrupted install leaves the same unresolved platform inputs on retry.
  assert.deepEqual(syncIosPodPolicy({repoRoot, write: true}), []);
  for (const output of podfiles) {
    assert.equal(fs.statSync(path.join(repoRoot, `${output}.lock`)).mtimeMs, 2000000);
  }
});

test("Runner settings changes preserve all Podfiles and propagate to every Runner", (t) => {
  const repoRoot = fixture(t);
  for (const output of iosPodPolicyOutputs[0].outputs) {
    fs.utimesSync(path.join(repoRoot, output), 1000, 1000);
  }
  fs.appendFileSync(path.join(repoRoot, iosPodPolicyOutputs[1].template), "// updated Runner setting\n");
  assert.deepEqual(syncIosPodPolicy({repoRoot, write: true}), iosPodPolicyOutputs[1].outputs);
  for (const output of iosPodPolicyOutputs[0].outputs) {
    assert.equal(fs.statSync(path.join(repoRoot, output)).mtimeMs, 1000000);
  }
});

test("invalid authored input fails before any generated output can change", (t) => {
  const repoRoot = fixture(t);
  fs.appendFileSync(path.join(repoRoot, "ios/Podfile.template"), "# pending\n");
  fs.writeFileSync(path.join(repoRoot, iosPodPolicyOutputs[1].template), "");
  assert.throws(() => syncIosPodPolicy({repoRoot, write: true}), /Empty iOS policy template/);
  for (const output of iosPodPolicyOutputs[0].outputs) {
    assert.doesNotMatch(fs.readFileSync(path.join(repoRoot, output), "utf8"), /# pending/);
  }
});

test("CLI defaults to check and rejects stale files and conflicting modes", (t) => {
  const repoRoot = fixture(t);
  const script = path.join(repoRoot, "tool/platform/sync_ios_pod_policy.mjs");
  fs.mkdirSync(path.dirname(script), {recursive: true});
  fs.copyFileSync(new URL("./sync_ios_pod_policy.mjs", import.meta.url), script);
  fs.appendFileSync(path.join(repoRoot, "ios/Podfile"), "# stale\n");
  const run = (...args) => spawnSync(process.execPath, [script, ...args], {cwd: os.tmpdir(), encoding: "utf8"});
  const stale = run();
  assert.equal(stale.status, 1);
  assert.match(stale.stderr, /Stale generated iOS policy/);
  assert.match(stale.stderr, /--write/);
  assert.equal(run("--check", "--write").status, 1);
  assert.equal(run("--write").status, 0);
  assert.equal(run("--check").status, 0);
});
