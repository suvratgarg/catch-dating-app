import assert from "node:assert/strict";
import test from "node:test";
import {buildWorkspaceAnalysisPlan, runWorkspaceAnalysis} from "./check_flutter_workspace_analysis.mjs";

function snapshot(pubspecs) {
  return {
    root: "/repo",
    listFiles: () => Object.keys(pubspecs),
    readText: (relativePath) => pubspecs[relativePath],
  };
}

const repositoryPubspecs = {
  "widgetbook/pubspec.yaml": "name: widgetbook_workspace\n",
  "apps/host/pubspec.yaml": "name: catch_host_app\nresolution: workspace\n",
  "pubspec.yaml": "name: catch_dating_app\nworkspace:\n  - apps/host\n",
  "tool/widget_dedupe/pubspec.yaml": "name: widget_dedupe\n",
};

test("workspace plan discovers every pubspec and resolves workspace members once", () => {
  const plan = buildWorkspaceAnalysisPlan(snapshot(repositoryPubspecs));
  assert.deepEqual(
    plan.packages.map((entry) => entry.directory),
    ["", "apps/host", "tool/widget_dedupe", "widgetbook"],
  );
  assert.deepEqual(
    plan.steps.filter((step) => step.phase === "resolve").map((step) => step.directory),
    ["", "tool/widget_dedupe", "widgetbook"],
  );
  assert.equal(plan.steps.filter((step) => step.phase === "analyze").length, 4);
  assert.deepEqual(plan.steps.find((step) => step.directory === "" && step.phase === "analyze"), {
    phase: "analyze",
    directory: "",
    command: "dart",
    args: ["analyze", "--format", "machine", "--fatal-infos"],
  });
});

test("workspace plan fails closed without the root package", () => {
  assert.throws(
    () => buildWorkspaceAnalysisPlan(snapshot({"nested/pubspec.yaml": "name: nested\n"})),
    /repository-root pubspec/u,
  );
});

test("every nested package is analyzed from its own package boundary", () => {
  const plan = buildWorkspaceAnalysisPlan(snapshot(repositoryPubspecs));
  const analyzedDirectories = plan.steps
    .filter((step) => step.phase === "analyze")
    .map((step) => step.directory);
  assert.deepEqual(
    analyzedDirectories,
    ["", "apps/host", "tool/widget_dedupe", "widgetbook"],
  );
});

test("workspace runner stops at the first nonzero package analysis", () => {
  const calls = [];
  assert.throws(
    () => runWorkspaceAnalysis({
      snapshot: snapshot(repositoryPubspecs),
      runner(command, args, options) {
        calls.push({command, args, cwd: options.cwd});
        const isHostAnalysis = options.cwd === "/repo/apps/host" && args[0] === "analyze";
        return {status: isHostAnalysis ? 2 : 0};
      },
    }),
    /analyze failed for apps\/host with status 2/u,
  );
  assert.equal(calls.at(-1).cwd, "/repo/apps/host");
});
