import assert from "node:assert/strict";
import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import test from "node:test";
import {spawnSync} from "node:child_process";

import {
  deriveTargetWorkflows,
  extractSteps,
  planCodegenFreshness,
  workflowForTarget,
} from "./lib/workflow_steps.mjs";

const WORKFLOWS = ".github/workflows";

test("extracts a plain scalar run step", () => {
  const steps = extractSteps([
    "jobs:",
    "  build:",
    "    steps:",
    "      - name: Analyze",
    "        run: dart analyze --fatal-infos",
  ].join("\n"));
  assert.equal(steps.length, 1);
  assert.equal(steps[0].name, "Analyze");
  assert.equal(steps[0].run, "dart analyze --fatal-infos");
  assert.equal(steps[0].runnable, true);
});

test("extracts a block scalar run step and dedents it", () => {
  const steps = extractSteps([
    "jobs:",
    "  build:",
    "    steps:",
    "      - name: Multi",
    "        run: |",
    "          mkdir -p build/ci",
    "          node tool/x.mjs --check",
    "      - name: After",
    "        run: echo done",
  ].join("\n"));
  assert.equal(steps.length, 2);
  assert.equal(steps[0].run, "mkdir -p build/ci\nnode tool/x.mjs --check");
  assert.equal(steps[1].run, "echo done");
});

test("skips steps coupled to the Actions runtime, including via env", () => {
  const steps = extractSteps([
    "jobs:",
    "  build:",
    "    steps:",
    "      - name: Aggregate",
    "        env:",
    "          NEEDS_JSON: ${{ toJSON(needs) }}",
    "        run: |",
    "          echo \"$NEEDS_JSON\"",
    "      - name: Upload",
    "        uses: actions/upload-artifact@v7",
  ].join("\n"));
  const byName = Object.fromEntries(steps.map((s) => [s.name, s]));
  // The run body alone looks like ordinary shell; only the env block reveals
  // that this step cannot execute outside CI.
  assert.equal(byName.Aggregate.runnable, false);
  assert.match(byName.Aggregate.skipReason, /GitHub Actions runtime/);
  assert.equal(byName.Upload.runnable, false);
  assert.match(byName.Upload.skipReason, /composite action/);
});

test("an unsupported run scalar remains an explicit skipped obligation", () => {
  const steps = extractSteps(`jobs:\n  build:\n    steps:\n      - name: New syntax\n        run: >+\n          echo verify\n`);
  assert.equal(steps.length, 1);
  assert.equal(steps[0].runnable, false);
  assert.match(steps[0].skipReason, /unsupported run block style/u);
});

test("derives the ciTarget to workflow mapping from the orchestrator", () => {
  const mapping = deriveTargetWorkflows([
    "jobs:",
    "  plan:",
    "    runs-on: ubuntu-latest",
    "  flutter:",
    "    if: ${{ needs.plan.outputs.flutter == 'true' }}",
    "    uses: ./.github/workflows/flutter-ci.yml",
    "  admin:",
    "    if: ${{ needs.plan.outputs.admin == 'true' }}",
    "    uses: ./.github/workflows/react-surface-validation.yml",
  ].join("\n"));
  assert.deepEqual(mapping.get("flutter"), ["flutter-ci.yml"]);
  assert.deepEqual(mapping.get("admin"), ["react-surface-validation.yml"]);
});

test("an unmapped target resolves to nothing so callers can fail closed", () => {
  assert.deepEqual(workflowForTarget("nonexistent", ["flutter-ci.yml"], new Map()), []);
});

// --- Anti-vacuity: assert against the real workflows, not just fixtures. ---
// A parser that silently returns zero steps would pass every test above.

test("the real flutter workflow yields its known gates", () => {
  const steps = extractSteps(fs.readFileSync(`${WORKFLOWS}/flutter-ci.yml`, "utf8"));
  const runnable = steps.filter((s) => s.runnable);
  assert.ok(runnable.length >= 20, `expected 20+ runnable steps, got ${runnable.length}`);

  const commands = runnable.map((s) => s.run).join("\n");
  // The analyzer gate is the specific one that has drifted from local practice
  // before: CI promotes info-level Catch lints to failures and `flutter analyze`
  // does not. If this assertion ever fails, local guidance must be re-derived.
  assert.match(commands, /check_flutter_workspace_analysis\.mjs/);
  assert.match(commands, /check_flutter_test_size\.mjs|flutter test/);
});

test("every ciTarget in the component graph resolves to a workflow", () => {
  const graph = JSON.parse(fs.readFileSync("tool/harness/component_graph.json", "utf8"));
  const available = fs.readdirSync(WORKFLOWS).filter((f) => f.endsWith(".yml"));
  const derived = deriveTargetWorkflows(fs.readFileSync(`${WORKFLOWS}/ci.yml`, "utf8"));

  const targets = new Set();
  const walk = (node) => {
    if (Array.isArray(node)) return node.forEach(walk);
    if (node && typeof node === "object") {
      for (const [key, value] of Object.entries(node)) {
        if (key === "ciTargets" && Array.isArray(value)) value.forEach((t) => targets.add(t));
        else walk(value);
      }
    }
  };
  walk(graph);

  const unresolved = [...targets].filter(
    (target) => workflowForTarget(target, available, derived).length === 0,
  );
  assert.deepEqual(
    unresolved, [],
    `ciTargets with no workflow: ${unresolved.join(", ")}. The harness graph and ` +
    `${WORKFLOWS}/ have diverged; local verification would silently skip these.`,
  );
});

test("folds a `>-` block into a single command", () => {
  // Regression: folded scalars were joined with newlines, so a multi-line
  // `run: >-` command executed its continuations as separate shell commands
  // ("audit:dependency-direction: command not found"). Emitting a wrong
  // command is worse than emitting none.
  const steps = extractSteps([
    "jobs:",
    "  build:",
    "    steps:",
    "      - name: Structural gates",
    "        run: >-",
    "          node tool/run.mjs check",
    "          audit:dependency-direction",
    "          audit:widget-cleanup",
  ].join("\n"));
  assert.equal(
    steps[0].run,
    "node tool/run.mjs check audit:dependency-direction audit:widget-cleanup",
  );
});

test("keeps line breaks in a `|` block", () => {
  const steps = extractSteps([
    "jobs:",
    "  build:",
    "    steps:",
    "      - name: Two commands",
    "        run: |",
    "          mkdir -p build/ci",
    "          node tool/x.mjs",
  ].join("\n"));
  assert.equal(steps[0].run, "mkdir -p build/ci\nnode tool/x.mjs");
});

test("no extracted command spans lines unless it came from a literal block", () => {
  // Anti-vacuity against the real workflows: any multi-line command must
  // originate from `|`, never from a folded scalar we mis-joined.
  const fs2 = fs;
  for (const file of fs2.readdirSync(WORKFLOWS).filter((f) => f.endsWith(".yml"))) {
    const source = fs2.readFileSync(`${WORKFLOWS}/${file}`, "utf8");
    for (const step of extractSteps(source)) {
      if (!step.run || !step.run.includes("\n")) continue;
      assert.ok(
        source.includes("run: |"),
        `${file}: step "${step.name}" yielded a multi-line command but the ` +
        `workflow declares no literal block`,
      );
    }
  }
});


test("a final literal block stops before the next job and preserves blank lines", () => {
  const steps = extractSteps(`jobs:
  first:
    steps:
      - name: First
        run: |
          echo first

          echo second
  next:
    runs-on: ubuntu-latest
    steps:
      - name: Next
        run: echo next
`);
  assert.equal(steps[0].run, "echo first\n\necho second");
  assert.equal(steps[1].run, "echo next");
});

test("literal working directories survive extraction and unresolved step context is explicit", () => {
  const steps = extractSteps(`jobs:
  first:
    steps:
      - name: Host tests
        working-directory: apps/host
        run: flutter test
      - name: Environment required
        env:
          MODE: test
        run: echo "$MODE"
`);
  assert.equal(steps[0].workingDirectory, "apps/host");
  assert.equal(steps[0].runnable, true);
  assert.equal(steps[1].runnable, false);
  assert.match(steps[1].skipReason, /explicit environment/);
});

test("local verification resolves Tools matrix checks and preserves package test directories", () => {
  const result = spawnSync("node", ["tool/harness/verify_local.mjs", "--target", "tools", "--target", "flutter", "--json"], {encoding: "utf8"});
  assert.equal(result.status, 0, result.stderr);
  const plan = JSON.parse(result.stdout);
  assert.equal(plan.gates.find((gate) => gate.target === "tools").command, "node tool/run.mjs check");
  assert.equal(plan.skipped.some((step) => step.workflow === "tools-ci.yml"), false);
  assert.deepEqual(plan.localRunnableChecks, plan.gates);
  assert.ok(plan.githubOnlyObligations.some((item) => item.target === "flutter"));
  assert.ok(plan.githubOnlyObligations.some((item) => item.workflow === "flutter-ci.yml"));
  assert.ok(plan.skipped.some((step) => step.reason.startsWith("composite action")));
  for (const directory of ["apps/consumer", "apps/host"]) {
    assert.ok(plan.gates.some((gate) => gate.workingDirectory === directory && gate.command.includes("flutter test")), directory);
  }
});

test("structural preflight runs from the declared sparse closure and fails closed", () => {
  const root = fs.mkdtempSync(path.join(os.tmpdir(), "catch-shared-preflight-"));
  const git = (args, options = {}) => spawnSync("git", args, {
    cwd: root, encoding: "utf8", maxBuffer: 32 * 1024 * 1024, ...options,
  });
  const expectGit = (args, options) => {
    const result = git(args, options);
    assert.equal(result.status, 0, result.stderr);
  };
  const sourceRoot = process.cwd();
  const graphPath = "tool/harness/component_graph.json";
  const manifestPath = "tool/tools_manifest.json";
  const run = () => spawnSync(process.execPath, [
    "tool/harness/verify_local.mjs", "--preflight", "--base", "HEAD",
    "--head", "HEAD", "--mode", "pr", "--json",
  ], {cwd: root, encoding: "utf8"});
  try {
    expectGit(["clone", "--quiet", "--shared", "--no-checkout", sourceRoot, "."]);
    const graph = JSON.parse(fs.readFileSync(path.join(sourceRoot, graphPath), "utf8"));
    expectGit(["sparse-checkout", "set", "--no-cone", "--stdin"], {
      input: `${graph.ciCheckout.planner.paths.join("\n")}\n`,
    });
    expectGit(["checkout", "--quiet", "HEAD"]);
    for (const relativePath of [graphPath, "tool/harness/component_graph.schema.json",
      "tool/harness/verify_local.mjs", "tool/harness/lib/component_graph.mjs",
      "tool/harness/lib/workflow_steps.mjs"]) {
      fs.copyFileSync(path.join(sourceRoot, relativePath), path.join(root, relativePath));
    }
    expectGit(["add", "--sparse", "--", "tool/harness"]);
    expectGit(["-c", "user.name=Preflight fixture", "-c", "user.email=fixture@example.invalid",
      "commit", "--quiet", "--allow-empty", "-m", "Use current preflight implementation"]);
    // A clean checkout copies identical files. Make the intended changed
    // source explicit so the planner selects real CI targets in every run.
    fs.appendFileSync(path.join(root, "tool/harness/verify_local.mjs"),
      "\n// Sparse preflight test change.\n");
    assert.equal(git(["diff", "--name-only"]).stdout.trim(),
      "tool/harness/verify_local.mjs");
    assert.equal(fs.existsSync(path.join(root, "node_modules")), false);
    assert.equal(fs.existsSync(path.join(root, "lib/main.dart")), false);
    const good = run();
    assert.equal(good.status, 0, good.stderr);
    const report = JSON.parse(good.stdout);
    assert.deepEqual(report.localRunnableChecks.map((check) => check.status),
      ["passed", "passed"]);
    assert.ok(report.githubOnlyObligations.some((item) => item.target === "tools"));
    assert.equal(report.baseSha, report.headSha);
    assert.deepEqual(report.codegenIds, []);
    assert.equal(report.validationComplete, false);

    const materialize = (files) => {
      for (const file of files) {
        const blob = git(["show", `HEAD:${file}`]);
        assert.equal(blob.status, 0, blob.stderr);
        const destination = path.join(root, file);
        fs.mkdirSync(path.dirname(destination), {recursive: true});
        fs.writeFileSync(destination, blob.stdout);
      }
      expectGit(["update-index", "--no-skip-worktree", "--", ...files]);
    };
    const ios = graph.compileCodegen.find((entry) => entry.id === "platform.ios-pod-policy");
    const notification = graph.compileCodegen.find((entry) => entry.id === "copy.notification");
    materialize([...ios.inputs, ...ios.outputs, ...notification.inputs, ...notification.outputs]);
    fs.appendFileSync(path.join(root, ios.inputs.at(-1)), "\n");
    fs.appendFileSync(path.join(root, notification.inputs[0]), "\n");
    const current = run();
    assert.equal(current.status, 0, current.stderr);
    const selected = JSON.parse(current.stdout);
    assert.deepEqual(selected.codegenIds, ["copy.notification", "platform.ios-pod-policy"]);
    assert.equal(selected.freshnessComplete, true);
    assert.equal(selected.validationComplete, false);
    assert.deepEqual(selected.freshnessChecks.map((check) => check.status), ["passed", "passed"]);
    assert.ok(selected.githubOnlyObligations.some((item) => item.target === "functions"));
    assert.equal(git(["diff", "--name-only", "--", ...ios.outputs, ...notification.outputs])
      .stdout.trim(), "", "freshness checks must not write generated outputs");

    const arb = "lib/l10n/app_en.arb";
    materialize([arb]);
    fs.appendFileSync(path.join(root, arb), "\n");
    const unavailable = run();
    assert.equal(unavailable.status, 0, unavailable.stderr);
    const partial = JSON.parse(unavailable.stdout);
    assert.equal(partial.freshnessComplete, false);
    assert.equal(partial.validationComplete, false);
    assert.ok(partial.githubOnlyObligations.some((item) =>
      item.codegenId === "flutter.l10n" && /unmaterialized/u.test(item.reason)));
    fs.appendFileSync(path.join(root, notification.outputs[0]), "// Stale output fixture.\n");
    const stale = run();
    assert.notEqual(stale.status, 0);
    assert.match(stale.stderr, /Freshness preflight failed for copy\.notification/u);
    assert.match(stale.stderr, /Regenerate with:/u);
    fs.unlinkSync(path.join(root, notification.outputs[0]));
    const missingOutput = run();
    assert.notEqual(missingOutput.status, 0);
    assert.match(missingOutput.stderr, /Freshness preflight failed for copy\.notification/u);
    expectGit(["restore", "--", ...ios.inputs, ...notification.inputs,
      ...notification.outputs, arb]);

    const unknownPath = path.join(root, "unowned-preflight-fixture");
    fs.writeFileSync(unknownPath, "unknown\n");
    assert.match(run().stderr, /complete, unambiguous Harness plan/u);
    fs.unlinkSync(unknownPath);

    const originalManifest = fs.readFileSync(path.join(root, manifestPath), "utf8");
    const manifest = JSON.parse(originalManifest);
    manifest.tools[0].path = "tool/missing-preflight-script.mjs";
    fs.writeFileSync(path.join(root, manifestPath), JSON.stringify(manifest));
    assert.match(run().stderr, /missing path tool\/missing-preflight-script\.mjs/u);
    manifest.tools[0].path = JSON.parse(originalManifest).tools[0].path;
    manifest.tools.push({...manifest.tools.at(-1)});
    fs.writeFileSync(path.join(root, manifestPath), JSON.stringify(manifest));
    assert.match(run().stderr, /Duplicate tool id/u);
    fs.writeFileSync(path.join(root, manifestPath), originalManifest);

    graph.classifications.push(...["first", "second"].map((id) => ({
      id: `preflight-ambiguous-${id}`,
      paths: {include: ["tool/harness/verify_local.mjs"]},
      components: ["ci.workflow.flutter"], terminal: true,
    })));
    fs.writeFileSync(path.join(root, graphPath), JSON.stringify(graph));
    assert.match(run().stderr, /complete, unambiguous Harness plan/u);

    const workflows = path.join(root, ".github/workflows");
    fs.mkdirSync(workflows, {recursive: true});
    fs.copyFileSync(path.join(sourceRoot, ".github/workflows/ci.yml"),
      path.join(workflows, "ci.yml"));
    const flutterSource = fs.readFileSync(
      path.join(sourceRoot, ".github/workflows/flutter-ci.yml"), "utf8");
    fs.writeFileSync(path.join(workflows, "flutter-ci.yml"),
      `${flutterSource}\n  preflight-probe:\n    steps:\n      - name: Unsupported preflight fixture\n        run: >+\n          echo check\n`);
    const listed = spawnSync(process.execPath, [
      "tool/harness/verify_local.mjs", "--target", "flutter", "--json",
    ], {cwd: root, encoding: "utf8"});
    assert.equal(listed.status, 0, listed.stderr);
    assert.ok(JSON.parse(listed.stdout).githubOnlyObligations.some((item) =>
      item.name === "Unsupported preflight fixture" &&
      item.reason.includes("unsupported run block style")));
  } finally {
    fs.rmSync(root, {recursive: true, force: true});
  }
});

test("freshness selection uses explicit graph requirements and never loses unavailable checks", () => {
  const graph = JSON.parse(fs.readFileSync("tool/harness/component_graph.json", "utf8"));
  const repositoryPaths = spawnSync("git", ["ls-files", "-z"], {encoding: "utf8",
    maxBuffer: 32 * 1024 * 1024}).stdout.split("\0").filter(Boolean);
  const options = {graph, codegenIds: graph.compileCodegen.map((entry) => entry.id),
    repositoryPaths, platform: "linux", fileAvailable: () => true,
    executableAvailable: () => true, packageAvailable: () => true};
  const available = planCodegenFreshness(options);
  assert.equal(available.length, 8);
  assert.ok(available.every((check) => check.runnable), JSON.stringify(available));
  const noFlutter = planCodegenFreshness({...options,
    executableAvailable: (executable) => executable !== "flutter" && executable !== "dart"});
  for (const id of ["flutter.l10n", "copy.structured-domain"]) {
    const check = noFlutter.find((entry) => entry.codegenId === id);
    assert.equal(check.runnable, false);
    assert.match(check.reasons.join("; "), /missing runtime/u);
    assert.ok(check.command && check.writeCommand);
  }
  const noPackages = planCodegenFreshness({...options, packageAvailable: () => false});
  assert.deepEqual(noPackages.filter((check) => !check.runnable).map((check) => check.codegenId),
    ["contracts.schema-projections", "copy.structured-domain"]);
  const sparse = planCodegenFreshness({...options,
    sparsePaths: repositoryPaths.filter((file) => file.startsWith("lib/l10n/generated/")),
    fileAvailable: (file) => !file.startsWith("lib/l10n/generated/")});
  assert.match(sparse.find((entry) => entry.codegenId === "flutter.l10n").reasons.join("; "),
    /unmaterialized output/u);
  const missingOutput = planCodegenFreshness({...options,
    fileAvailable: () => false});
  assert.ok(missingOutput.every((check) => check.runnable),
    "Missing full-checkout files must execute and fail their freshness command");
  const indirectOmission = planCodegenFreshness({...options,
    codegenIds: ["admin.callable-validators"],
    sparsePaths: ["contracts/firestore/sales_quotes.schema.json"],
    fileAvailable: (file) => file !== "contracts/firestore/sales_quotes.schema.json"});
  assert.equal(indirectOmission[0].runnable, false);
  assert.match(indirectOmission[0].reasons.join("; "), /unmaterialized input contracts/u);
  const wrongPlatform = planCodegenFreshness({...options, platform: "win32"});
  assert.ok(wrongPlatform.every((check) => !check.runnable));
  assert.deepEqual(planCodegenFreshness({...options, codegenIds: []}), []);
  assert.throws(() => planCodegenFreshness({...options, codegenIds: ["unknown"]}),
    /Unknown required compile-codegen/u);
  const invalid = structuredClone(graph);
  delete invalid.compileCodegen[0].checkRequirements;
  assert.throws(() => planCodegenFreshness({...options, graph: invalid}), /checkRequirements/u);
  // No command-string heuristic may hide a declared transitive runtime.
  const explicit = structuredClone(graph);
  explicit.compileCodegen.find((entry) => entry.id === "copy.notification")
    .checkRequirements.executables.push("flutter");
  const declared = planCodegenFreshness({...options, graph: explicit,
    codegenIds: ["copy.notification"], executableAvailable: (name) => name === "node"});
  assert.deepEqual(declared[0].reasons, ["missing runtime flutter"]);
});
