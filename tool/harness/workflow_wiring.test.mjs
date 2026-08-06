import assert from "node:assert/strict";
import fs from "node:fs";
import test from "node:test";

const graph = JSON.parse(
  fs.readFileSync(new URL("./component_graph.json", import.meta.url), "utf8"),
);
const workflow = (name) => fs.readFileSync(`.github/workflows/${name}`, "utf8");
const retiredPlanner = ["plan", "ci.mjs"].join("_");

test("required CI consumes every bounded Harness v2 target", () => {
  const ci = workflow("ci.yml");
  assert.match(ci, /name: Required CI/);
  assert.match(ci, /node tool\/harness\.mjs plan/);
  assert.doesNotMatch(ci, new RegExp(`${retiredPlanner}|harness\\.mjs shadow`));
  for (const target of graph.targets) {
    assert.match(ci, new RegExp(`steps\\.plan\\.outputs\\.${target}`));
  }
  assert.match(ci, /docs-policy:/);
  assert.match(ci, /- docs-policy/);
});

test("web smoke compiles dev roles without compiling production web", () => {
  const builds = workflow("app-build-matrix.yml");
  assert.match(builds, /inputs\.build_web \|\| inputs\.web_smoke/);
  assert.match(
    builds,
    /inputs\.build_web && contains\(fromJSON\(inputs\.app_roles\), 'consumer'\)/,
  );
  assert.match(
    builds,
    /inputs\.build_web && contains\(fromJSON\(inputs\.app_roles\), 'host'\)/,
  );
});

test("deploy and mobile release workflows consume authorization outputs", () => {
  const firebase = workflow("firebase-dev-deploy.yml");
  assert.match(firebase, /steps\.impact\.outputs\.deploy_required/);
  assert.match(firebase, /steps\.impact\.outputs\.deploy_groups/);
  assert.match(firebase, /node tool\/harness\.mjs plan/);
  assert.match(firebase, /--mode main/);
  assert.doesNotMatch(firebase, new RegExp(retiredPlanner));
  assert.doesNotMatch(
    firebase,
    /steps\.impact\.outputs\.(contracts|firestore_rules|functions)/,
  );

  const mobile = workflow("mobile-internal-release.yml");
  assert.match(mobile, /steps\.impact\.outputs\.release_roles/);
  assert.match(mobile, /node tool\/harness\.mjs plan/);
  assert.match(mobile, /--mode main/);
  assert.doesNotMatch(mobile, new RegExp(`mobile_release_roles|${retiredPlanner}`));
});

test("reusable fanout workflows cannot cancel sibling lanes", () => {
  for (const name of [
    "app-build-matrix.yml",
    "flutter-ci.yml",
    "operations-ci.yml",
    "tools-ci.yml",
    "visual-integration-ci.yml",
  ]) {
    const source = workflow(name);
    assert.doesNotMatch(
      source,
      /^concurrency:\s*\n\s+group:.*github\.workflow/m,
      `${name} must inherit concurrency from the CI orchestrator`,
    );
  }
});
