import assert from "node:assert/strict";
import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import {spawnSync} from "node:child_process";
import test from "node:test";
import vm from "node:vm";
import {extractSteps} from "../harness/lib/workflow_steps.mjs";
import {fromRepo} from "../lib/repo_paths.mjs";
import {isAdmissionEvent} from "../ci/pr_ci_admission.mjs";
import {canonicalInventory, exportHostedCaptures, resolveCaptureRequest} from "./export_hosted_captures.mjs";

const repository = "owner/repo";
function labelEvent() {
  return {repository: {full_name: repository}, action: "labeled", label: {name: "capture:requested"},
    number: 543, pull_request: {number: 543, state: "open", draft: true,
      head: {sha: "a".repeat(40), repo: {full_name: repository}},
      base: {sha: "b".repeat(40), ref: "main", repo: {full_name: repository}}}};
}
const requestOptions = event => ({eventName: "pull_request", event, repository,
  runSha: "c".repeat(40), workflowDefinitionSha: "d".repeat(40)});
function evaluate(expression, options) {
  return vm.runInNewContext(expression, {
    github: {event_name: options.eventName, event: options.event, repository: options.repository,
      sha: options.runSha, workflow_sha: options.workflowDefinitionSha, run_id: "123", run_attempt: "2"},
    env: {CAPTURE_SOURCE_SHA: options.sourceSha},
    inputs: options.event.inputs ?? {}, cancelled: () => false,
    contains: (values, value) => values.includes(value), fromJSON: JSON.parse,
  }, {timeout: 1000});
}

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
    "tool/marketing/export_app_screenshots.mjs", "tool/marketing/export_hosted_captures.mjs",
    "tool/marketing/lib/capture_provenance.mjs",
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
  const event = labelEvent();
  event.pull_request.head.sha = f.options.sourceSha;
  event.pull_request.base.sha = f.options.workflowSha;
  const request = resolveCaptureRequest(requestOptions(event));
  const result = exportHostedCaptures({...f.options, request});
  assert.deepEqual(result.request, request);
  assert.equal(result.workflowSha, f.options.workflowSha);
  assert.equal(result.workflowDefinitionSha, "d".repeat(40));
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

test("hosted workflow keeps manual dispatch and limits PR events to explicit capture requests", () => {
  const source = fs.readFileSync(fromRepo(".github/workflows/marketing-captures.yml"), "utf8");
  const events = source.slice(source.indexOf("on:"), source.indexOf("permissions:"));
  assert.match(events, /^on:\n  workflow_dispatch:/u);
  assert.match(events, /  pull_request:\n    types: \[labeled\]\n/u);
  assert.doesNotMatch(events, /push:|schedule:|workflow_run|pull_request_target|synchronize|opened/u);
  assert.match(source, /^permissions:\n  contents: read\n\n/mu);
  assert.match(source, /runs-on: macos-26\n/u);
  assert.match(source, /timeout-minutes: 45\n/u);
  const steps = extractSteps(source);
  assert.equal(steps.filter(s => s.uses?.startsWith("actions/checkout@")).length, 2);
  assert.equal(source.match(/persist-credentials: false/gu)?.length, 2);
  assert.match(source, /ref: \$\{\{ env.CAPTURE_WORKFLOW_SHA \}\}/u);
  assert.match(source, /ref: \$\{\{ env.CAPTURE_SOURCE_SHA \}\}/u);
  assert.ok(steps.findIndex(s => s.name === "Validate capture request and controller identity") <
    steps.findIndex(s => s.name === "Checkout exact capture source separately"));
  assert.match(source, /if-no-files-found: error/u);
  assert.match(source, /retention-days: 7/u);
  assert.ok(source.includes("--enforce-lockfile"));
  assert.ok(source.includes("artifact-digest"));
  assert.doesNotMatch(source, /secrets\.|id-token|pull_request_target|git push|update-goldens|firebase deploy/u);
  // Exercise the actual shell guard, including attempted shell substitutions.
  const guard = steps.find(s => s.name === "Validate immutable source selection").run;
  for (const [sha, accepted] of [["a".repeat(40), true], ["main", false],
    ["543a4512e862", false], ["$(touch /tmp/cat159-must-not-exist)", false]]) {
    const result = spawnSync("bash", ["-c", guard], {env: {...process.env, CAPTURE_SOURCE_SHA: sha,
      CAPTURE_WORKFLOW_SHA: "b".repeat(40), CAPTURE_WORKFLOW_DEFINITION_SHA: "c".repeat(40)}});
    assert.equal(result.status === 0, accepted);
  }
  for (const variable of ["CAPTURE_WORKFLOW_SHA", "CAPTURE_WORKFLOW_DEFINITION_SHA"]) {
    const result = spawnSync("bash", ["-c", guard], {env: {...process.env,
      CAPTURE_SOURCE_SHA: "a".repeat(40), CAPTURE_WORKFLOW_SHA: "b".repeat(40),
      CAPTURE_WORKFLOW_DEFINITION_SHA: "c".repeat(40), [variable]: "main"}});
    assert.notEqual(result.status, 0);
  }
});

test("label request binds exact PR head, base controller and distinct workflow/event provenance", () => {
  const event = labelEvent();
  event.inputs = {source_sha: "e".repeat(40)};
  assert.deepEqual(resolveCaptureRequest(requestOptions(event)), {
    eventName: "pull_request", sourceSha: "a".repeat(40), workflowSha: "b".repeat(40),
    workflowDefinitionSha: "d".repeat(40), eventSha: "c".repeat(40),
    prNumber: 543, label: "capture:requested",
  });
  const manual = {...requestOptions({repository: {full_name: repository},
    inputs: {source_sha: "e".repeat(40)}}), eventName: "workflow_dispatch"};
  const result = resolveCaptureRequest(manual);
  assert.equal(result.sourceSha, "e".repeat(40));
  assert.equal(result.workflowSha, manual.runSha);
  assert.equal(result.prNumber, undefined);
});

test("unrelated, forked, closed, malformed and mutable capture requests are refused", () => {
  for (const mutate of [
    e => {e.action = "synchronize";}, e => {e.action = "unlabeled";},
    e => {e.label.name = "ci:admitted";}, e => {e.label.name = "documentation";},
    e => {e.label.name = "CAPTURE:REQUESTED";}, e => {delete e.label;},
    e => {e.repository.full_name = "foreign/repo";},
    e => {e.pull_request.head.repo.full_name = "fork/repo";},
    e => {e.pull_request.base.repo.full_name = "foreign/repo";},
    e => {e.pull_request.head.repo = null;}, e => {e.pull_request.state = "closed";},
    e => {e.pull_request.base.ref = "develop";}, e => {e.number = 42;},
    e => {e.pull_request.number = Number.MAX_SAFE_INTEGER + 1;},
    e => {delete e.pull_request;},
    e => {e.pull_request.head.sha = "main";},
    e => {e.pull_request.base.sha = "$(touch /tmp/cat159-must-not-exist)";},
  ]) {
    const event = labelEvent();
    mutate(event);
    assert.throws(() => resolveCaptureRequest(requestOptions(event)));
  }
  for (const eventName of ["push", "pull_request_target", "workflow_run", "schedule"]) {
    assert.throws(() => resolveCaptureRequest({...requestOptions(labelEvent()), eventName}), /Unsupported/);
  }
  for (const variable of ["runSha", "workflowDefinitionSha"]) {
    assert.throws(() => resolveCaptureRequest({...requestOptions(labelEvent()), [variable]: "main"}), /immutable/);
  }
  for (const source_sha of ["main", "07d331e", "A".repeat(40), "a".repeat(40) + "\n"]) {
    assert.throws(() => resolveCaptureRequest({...requestOptions({repository: {full_name: repository},
      inputs: {source_sha}}), eventName: "workflow_dispatch"}), /immutable/);
  }
});

test("actual job guard and source-keyed concurrency exclude unrelated PR metadata and forks", () => {
  const source = fs.readFileSync(fromRepo(".github/workflows/marketing-captures.yml"), "utf8");
  const guard = source.match(/^    if: >-\n([\s\S]*?)^    concurrency:/mu)?.[1].trim();
  assert.ok(guard);
  const expression = key => source.match(new RegExp(`^      ${key}: \\$\\{\\{ (.*) \\}\\}$`, "m"))?.[1];
  const group = source.match(/^      group: marketing-captures-\$\{\{ (.*) \}\}$/mu)?.[1];
  assert.ok(group);
  assert.doesNotMatch(source, /^concurrency:/mu, "ineligible jobs must never enter capture concurrency");
  const good = requestOptions(labelEvent());
  assert.equal(evaluate(guard, good), true);
  assert.equal(evaluate(expression("CAPTURE_SOURCE_SHA"), good), good.event.pull_request.head.sha);
  assert.equal(evaluate(expression("CAPTURE_WORKFLOW_SHA"), good), good.event.pull_request.base.sha);
  assert.equal(evaluate(expression("CAPTURE_WORKFLOW_DEFINITION_SHA"), good), good.workflowDefinitionSha);
  const manual = {...good, eventName: "workflow_dispatch", event: {inputs: {source_sha: "a".repeat(40)}}};
  assert.equal(evaluate(guard, manual), true);
  assert.equal(evaluate(group, manual), evaluate(group, good));
  for (const mutate of [e => {e.action = "unlabeled";}, e => {e.action = "synchronize";},
    e => {e.label.name = "ci:admitted";}, e => {e.pull_request.state = "closed";},
    e => {e.pull_request.base.ref = "develop";}, e => {e.pull_request.head.repo.full_name = "fork/repo";},
    e => {e.pull_request.base.repo.full_name = "foreign/repo";}]) {
    const event = labelEvent(); mutate(event);
    assert.equal(evaluate(guard, requestOptions(event)), false);
  }
  const newer = labelEvent(); newer.pull_request.head.sha = "e".repeat(40);
  assert.notEqual(evaluate(group, requestOptions(newer)), evaluate(group, good));
  assert.match(source, /      cancel-in-progress: false\n/u);
});

test("capture label does not admit full CI or replace the Required CI context", () => {
  const event = labelEvent();
  assert.equal(isAdmissionEvent(event), false);
  const ci = fs.readFileSync(fromRepo(".github/workflows/ci.yml"), "utf8");
  const required = ci.slice(ci.indexOf("  required:\n"));
  const condition = required.match(/^    if: \$\{\{ (.*) \}\}$/mu)?.[1];
  const name = required.match(/^    name: \$\{\{ (.*) \}\}$/mu)?.[1];
  assert.equal(evaluate(condition, requestOptions(event)), false);
  assert.equal(evaluate(name, requestOptions(event)), "Ignored PR metadata");
  event.label.name = "ci:admitted";
  assert.equal(isAdmissionEvent(event), true);
  assert.equal(evaluate(condition, requestOptions(event)), true);
  assert.equal(evaluate(name, requestOptions(event)), "Required CI");
});

test("actual artifact name includes exact selected source SHA for both dispatch and PR labels", () => {
  const source = fs.readFileSync(fromRepo(".github/workflows/marketing-captures.yml"), "utf8");
  const selection = source.match(/^      CAPTURE_SOURCE_SHA: \$\{\{ (.*) \}\}$/mu)?.[1];
  const template = source.match(/^          name: (canonical-marketing-.*)$/mu)?.[1];
  assert.ok(selection && template);
  const labeled = requestOptions(labelEvent());
  const manual = {...labeled, eventName: "workflow_dispatch",
    event: {inputs: {source_sha: "e".repeat(40)}}};
  for (const context of [labeled, manual]) {
    const sourceSha = evaluate(selection, context);
    const name = template.replace(/\$\{\{\s*(.*?)\s*\}\}/gu,
      (_, expression) => evaluate(expression, {...context, sourceSha}));
    assert.equal(name, `canonical-marketing-${sourceSha}-123-2`);
  }
});

test("actual request-check step verifies controller checkout and event binding before rendering", t => {
  const f = fixture(t);
  const event = labelEvent(); event.pull_request.base.sha = f.options.sourceSha;
  const eventPath = path.join(path.dirname(f.options.outputDir), "event.json");
  fs.writeFileSync(eventPath, JSON.stringify(event));
  const source = fs.readFileSync(fromRepo(".github/workflows/marketing-captures.yml"), "utf8");
  const step = extractSteps(source).find(s => s.name === "Validate capture request and controller identity");
  const env = {...process.env, GITHUB_EVENT_NAME: "pull_request", GITHUB_EVENT_PATH: eventPath,
    GITHUB_REPOSITORY: repository, GITHUB_SHA: "c".repeat(40),
    CAPTURE_SOURCE_SHA: event.pull_request.head.sha, CAPTURE_WORKFLOW_SHA: event.pull_request.base.sha,
    CAPTURE_WORKFLOW_DEFINITION_SHA: "d".repeat(40)};
  const run = (overrides = {}) => spawnSync("bash", ["-c", step.run], {
    cwd: f.root, env: {...env, ...overrides}, encoding: "utf8"});
  const accepted = run();
  assert.equal(accepted.status, 0, accepted.stderr);
  const request = JSON.parse(accepted.stdout);
  assert.equal(request.sourceSha, event.pull_request.head.sha);
  assert.equal(request.workflowSha, f.options.sourceSha);
  assert.notEqual(request.workflowSha, env.GITHUB_SHA);
  assert.match(run({CAPTURE_SOURCE_SHA: "e".repeat(40)}).stderr, /environment differs/);
  assert.match(run({CAPTURE_WORKFLOW_SHA: "e".repeat(40)}).stderr, /environment differs/);
  event.pull_request.base.sha = "e".repeat(40);
  fs.writeFileSync(eventPath, JSON.stringify(event));
  assert.match(run({CAPTURE_WORKFLOW_SHA: event.pull_request.base.sha}).stderr, /controller checkout/);
  event.pull_request.head.repo.full_name = "fork/repo";
  fs.writeFileSync(eventPath, JSON.stringify(event));
  assert.match(run().stderr, /same-repository/);
  assert.ok(!fs.existsSync(f.calls));
  assert.ok(!fs.existsSync(f.options.outputDir));
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
