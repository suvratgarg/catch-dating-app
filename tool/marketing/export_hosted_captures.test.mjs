import assert from "node:assert/strict";
import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import {spawnSync} from "node:child_process";
import test from "node:test";
import {extractSteps} from "../harness/lib/workflow_steps.mjs";
import {fromRepo} from "../lib/repo_paths.mjs";
import {canonicalInventory, exportHostedCaptures} from "./export_hosted_captures.mjs";

function fixture(t) {
  const directory = fs.mkdtempSync(path.join(os.tmpdir(), "hosted-captures-"));
  t.after(() => fs.rmSync(directory, {recursive: true, force: true}));
  const root = path.join(directory, "source");
  const write = (file, bytes) => {
    const destination = path.join(root, file);
    fs.mkdirSync(path.dirname(destination), {recursive: true});
    fs.writeFileSync(destination, bytes);
    return destination;
  };
  for (const file of ["tool/lib/repo_paths.mjs", "tool/ui_capture/run_captures.mjs",
    "tool/marketing/export_app_screenshots.mjs", "tool/marketing/lib/capture_provenance.mjs",
    "tool/marketing/sync_website_media.mjs", "tool/ci/toolchain.env"]) {
    write(file, fs.readFileSync(fromRepo(file)));
  }
  const manifest = JSON.parse(fs.readFileSync(fromRepo("tool/marketing/capture_manifest.json"), "utf8"));
  const png = fs.readFileSync(fromRepo(manifest.captures[0].sourcePath));
  write("tool/marketing/capture_manifest.json", JSON.stringify(manifest));
  write("tool/marketing/app_screenshots_design_context.json", "{}");
  write("website/public/assets/app-screenshots/manifest.json", "{}");
  for (const capture of manifest.captures) {
    write(capture.sourcePath, png);
    write(capture.websitePath, png);
  }
  write("test/ui_captures/catalog/screen_capture_catalog.dart", manifest.captures.map((c, i) =>
    `ScreenCaptureEntry(id: 'screen_${i}', routeIds: const <String>['today'],
      marketingFixtureKeys: const <String>['${c.fixtureKey}'], device: CaptureDevice.iphone17Pro)`).join("\n"));
  write("test/ui_captures/capture_runner_test.dart", "import 'package:catch_dating_app/leaf.dart';\n");
  write("test/ui_captures/flutter_test_config.dart", "");
  write("tool/marketing/frame_device_capture.dart", "");
  write("lib/leaf.dart", "const title = 'Today';\n");
  write("pubspec.yaml", "name: catch_dating_app\n");
  write("pubspec.lock", "pinned fixture\n");
  write("packages/sample/pubspec.yaml", "name: sample\n");
  write("tool/demo/demo_seed/scenarios/sample.json", "{}");
  write("tool/demo/demo_seed/personas/sample.json", "{}");
  write("test/goldens/baseline.png", png);
  write(".gitignore", "/artifacts/marketing/app-screenshots/raw/\n");
  const git = (...args) => {
    const result = spawnSync("git", args, {cwd: root, encoding: "utf8"});
    assert.equal(result.status, 0, result.stderr);
    return result.stdout.trim();
  };
  git("init", "-q");
  git("add", ".");
  git("-c", "user.name=Capture Test", "-c", "user.email=capture@example.invalid", "commit", "-qm", "fixture");
  const bin = path.join(directory, "bin");
  fs.mkdirSync(bin);
  const calls = path.join(directory, "calls.jsonl");
  const executable = (name, script) => {
    const file = path.join(bin, name);
    fs.writeFileSync(file, `#!${process.execPath}\n${script}\n`);
    fs.chmodSync(file, 0o755);
  };
  executable("flutter", `const fs = require('node:fs'); const args = process.argv.slice(2);
    if (args.includes('--version')) process.stdout.write(JSON.stringify({frameworkVersion:'3.44.9'}));
    else fs.appendFileSync(${JSON.stringify(calls)}, JSON.stringify({command:'flutter', args})+'\\n');`);
  executable("dart", `const fs = require('node:fs'); const args = process.argv.slice(2);
    fs.writeFileSync(args[args.indexOf('--output')+1], Buffer.from(${JSON.stringify(png.toString("base64"))},'base64'));
    fs.appendFileSync(${JSON.stringify(calls)}, JSON.stringify({command:'dart', args})+'\\n');`);
  executable("sw_vers", "process.stdout.write('macOS test fixture');");
  const previousPath = process.env.PATH;
  process.env.PATH = `${bin}${path.delimiter}${previousPath}`;
  t.after(() => { process.env.PATH = previousPath; });
  const sfFont = path.join(directory, "native.ttf");
  fs.writeFileSync(sfFont, "test font, never exported");
  const options = {sourceDir: root, sourceSha: git("rev-parse", "HEAD"),
    workflowSha: "a".repeat(40), outputDir: path.join(directory, "bundle"),
    repository: "owner/repo", runId: "123", runAttempt: "2", platform: "darwin", sfFont};
  return {root, write, git, calls, options, executable, manifest};
}

test("real canonical wrappers export all 12 with exact provenance and complete byte inventory", t => {
  const f = fixture(t);
  const baseline = fs.readFileSync(path.join(f.root, "test/goldens/baseline.png"));
  const authored = fs.readFileSync(path.join(f.root, "tool/marketing/capture_manifest.json"));
  const result = exportHostedCaptures(f.options);
  assert.equal(result.captures.length, 12);
  assert.equal(result.files.length, 27);
  assert.equal(result.sourceTree, f.git("rev-parse", "HEAD^{tree}"));
  for (const capture of result.captures) assert.equal(capture.provenance.sourceRevision, f.options.sourceSha);
  for (const file of result.files) {
    assert.deepEqual(fs.readFileSync(path.join(f.options.outputDir, file.path)), fs.readFileSync(path.join(f.root, file.path)));
    assert.equal(file.sha256.length, 64);
  }
  const calls = fs.readFileSync(f.calls, "utf8").trim().split("\n").map(JSON.parse);
  assert.equal(calls.filter(c => c.command === "flutter").length, 1);
  assert.equal(calls.filter(c => c.command === "dart").length, 12);
  const render = calls[0].args;
  assert.ok(render.includes("--dart-define=CAPTURE_PLATFORM=ios"));
  assert.equal(render.find(a => a.startsWith("--dart-define=CAPTURE_IDS=")).slice("--dart-define=CAPTURE_IDS=".length).split(",").length, 12);
  assert.ok(!calls.some(c => c.args.includes("--update-goldens")));
  assert.deepEqual(fs.readFileSync(path.join(f.root, "test/goldens/baseline.png")), baseline);
  assert.deepEqual(fs.readFileSync(path.join(f.root, "tool/marketing/capture_manifest.json")), authored);
  assert.deepEqual(JSON.parse(fs.readFileSync(path.join(f.options.outputDir, "capture-receipt.json"))), result);
  assert.throws(() => exportHostedCaptures(f.options), /new absolute directory/);
});

test("mutable refs, source mismatch, dirty inputs and Linux fail before rendering", t => {
  const f = fixture(t);
  for (const sourceSha of ["main", "543a4512e862", "$(false)"]) {
    assert.throws(() => exportHostedCaptures({...f.options, sourceSha}), /immutable/);
  }
  assert.throws(() => exportHostedCaptures({...f.options, sourceSha: "b".repeat(40)}), /does not match/);
  assert.throws(() => exportHostedCaptures({...f.options, platform: "linux"}), /requires macOS/);
  f.write("lib/leaf.dart", "dirty source");
  assert.throws(() => exportHostedCaptures(f.options), /must be clean/);
  assert.ok(!fs.existsSync(f.calls));
  assert.ok(!fs.existsSync(f.options.outputDir));
});

test("bounded inventory rejects subsets, duplicate fixtures and traversal paths", t => {
  const f = fixture(t);
  assert.throws(() => canonicalInventory({...f.manifest, captures: f.manifest.captures.slice(1)}), /exactly 12/);
  for (const change of [{id: f.manifest.captures[1].id}, {fixtureKey: f.manifest.captures[1].fixtureKey},
    {sourcePath: "../../outside.png"}, {websitePath: "/tmp/outside.png"}, {status: "paused"}]) {
    const manifest = structuredClone(f.manifest);
    Object.assign(manifest.captures[0], change);
    assert.throws(() => canonicalInventory(manifest), /Invalid, duplicate or unsafe/);
  }
});

test("tracked symlink cannot redirect final capture writes", t => {
  const f = fixture(t);
  const file = f.manifest.captures[0].sourcePath;
  fs.unlinkSync(path.join(f.root, file));
  fs.symlinkSync(f.options.sfFont, path.join(f.root, file));
  f.git("add", file);
  f.git("-c", "user.name=Capture Test", "-c", "user.email=capture@example.invalid", "commit", "-qm", "symlink");
  f.options.sourceSha = f.git("rev-parse", "HEAD");
  assert.throws(() => exportHostedCaptures(f.options), /Symlink refused/);
  assert.equal(fs.readFileSync(f.options.sfFont, "utf8"), "test font, never exported");
});

test("render failure cannot package stale captures", t => {
  const f = fixture(t);
  f.executable("flutter", `if (process.argv.includes('--version')) process.stdout.write(JSON.stringify({frameworkVersion:'3.44.9'})); else process.exit(1);`);
  assert.throws(() => exportHostedCaptures(f.options), /failed/);
  assert.ok(!fs.existsSync(f.options.outputDir));
  for (const c of f.manifest.captures) assert.ok(!fs.existsSync(path.join(f.root, c.sourcePath)));
});

test("golden mutation fails publication even when canonical capture checks pass", t => {
  const f = fixture(t);
  const dart = fs.readFileSync(path.join(path.dirname(f.calls), "bin/dart"), "utf8");
  f.executable("dart", dart.split("\n").slice(1).join("\n") + "\nrequire('node:fs').writeFileSync('test/goldens/baseline.png','mutated');");
  assert.throws(() => exportHostedCaptures(f.options), /changed source or goldens/);
  assert.ok(!fs.existsSync(f.options.outputDir));
});

test("hosted workflow uses standard macOS with manual immutable source and read-only permissions", () => {
  const source = fs.readFileSync(fromRepo(".github/workflows/marketing-captures.yml"), "utf8");
  const events = source.slice(source.indexOf("on:"), source.indexOf("permissions:"));
  assert.match(events, /^on:\n  workflow_dispatch:/u);
  assert.doesNotMatch(events, /pull_request|push:|schedule:|workflow_run/u);
  assert.match(source, /^permissions:\n  contents: read\n\n/mu);
  assert.match(source, /runs-on: macos-26\n/u);
  assert.match(source, /timeout-minutes: 45\n/u);
  const steps = extractSteps(source);
  assert.equal(steps.filter(s => s.uses?.startsWith("actions/checkout@")).length, 2);
  assert.equal(source.match(/persist-credentials: false/gu)?.length, 2);
  assert.match(source, /ref: \$\{\{ github.sha \}\}/u);
  assert.match(source, /ref: \$\{\{ inputs.source_sha \}\}/u);
  assert.match(source, /if-no-files-found: error/u);
  assert.match(source, /retention-days: 7/u);
  assert.ok(source.includes("--enforce-lockfile"));
  assert.ok(source.includes("artifact-digest"));
  assert.doesNotMatch(source, /secrets\.|id-token|pull_request_target|git push|update-goldens|firebase deploy/u);
  // Exercise the actual shell guard, including attempted shell substitutions.
  const guard = steps.find(s => s.name === "Validate immutable source selection").run;
  for (const [sha, accepted] of [["a".repeat(40), true], ["main", false],
    ["543a4512e862", false], ["$(touch /tmp/cat159-must-not-exist)", false]]) {
    const result = spawnSync("bash", ["-c", guard], {env: {...process.env, CAPTURE_SOURCE_SHA: sha}});
    assert.equal(result.status === 0, accepted);
  }
});

test("runner output path is initialized on the runner, never in job-level env", t => {
  const source = fs.readFileSync(fromRepo(".github/workflows/marketing-captures.yml"), "utf8");
  const jobEnv = source.match(/^    env:\n([\s\S]*?)^    steps:/mu)?.[1];
  assert.ok(jobEnv, "expected export job env block");
  // GitHub evaluates job env before assigning a runner. These are its allowed
  // contexts; runner belongs to step scope (GitHub context-availability table).
  const allowed = new Set(["github", "needs", "strategy", "matrix", "vars", "secrets", "inputs"]);
  const assertContexts = block => {
    for (const match of block.matchAll(/\$\{\{\s*([a-z_]+)\./gu)) {
      assert.ok(allowed.has(match[1]), `context ${match[1]} is unavailable in job-level env`);
    }
  };
  assertContexts(jobEnv);
  assert.throws(() => assertContexts(`${jobEnv}\n      CAPTURE_OUTPUT_DIR: \u0024{{ runner.temp }}/canonical-marketing-captures`), /runner is unavailable/);
  const steps = extractSteps(source);
  const initializeIndex = steps.findIndex(s => s.name === "Initialize runner output directory");
  const exportIndex = steps.findIndex(s => s.name === "Render, frame, validate and package canonical outputs");
  assert.ok(initializeIndex >= 0 && initializeIndex < exportIndex);
  const directory = fs.mkdtempSync(path.join(os.tmpdir(), "capture-runner-env-"));
  t.after(() => fs.rmSync(directory, {recursive: true, force: true}));
  const envFile = path.join(directory, "env");
  const runnerTemp = path.join(directory, "runner temp with spaces");
  const result = spawnSync("bash", ["-c", steps[initializeIndex].run], {
    env: {...process.env, RUNNER_TEMP: runnerTemp, GITHUB_ENV: envFile}, encoding: "utf8",
  });
  assert.equal(result.status, 0, result.stderr);
  assert.equal(fs.readFileSync(envFile, "utf8"), `CAPTURE_OUTPUT_DIR=${runnerTemp}/canonical-marketing-captures\n`);
  assert.match(source, /path: \$\{\{ env.CAPTURE_OUTPUT_DIR \}\}\//u);
});
