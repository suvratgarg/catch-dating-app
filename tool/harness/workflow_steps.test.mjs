import assert from "node:assert/strict";
import fs from "node:fs";
import test from "node:test";
import {spawnSync} from "node:child_process";

import {
  deriveTargetWorkflows,
  extractSteps,
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
  for (const directory of ["apps/consumer", "apps/host"]) {
    assert.ok(plan.gates.some((gate) => gate.workingDirectory === directory && gate.command.includes("flutter test")), directory);
  }
});
