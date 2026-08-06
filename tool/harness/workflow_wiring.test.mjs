import assert from "node:assert/strict";
import test from "node:test";
import {createRepositorySnapshot} from "../lib/repository_snapshot.mjs";

const repositorySnapshot = createRepositorySnapshot();
const graph = repositorySnapshot.readJson(
  "tool/harness/component_graph.json",
  {required: true},
);
const workflow = (name) => repositorySnapshot.readText(
  `.github/workflows/${name}`,
  {required: true},
);
const retiredPlanner = ["plan", "ci.mjs"].join("_");

function namedStep(source, name) {
  const marker = `      - name: ${name}`;
  const start = source.indexOf(marker);
  assert.notEqual(start, -1, `missing workflow step ${name}`);
  const end = source.indexOf("\n      - ", start + marker.length);
  return source.slice(start, end === -1 ? source.length : end);
}

function literalSparsePaths(step) {
  const match = /sparse-checkout: \|\n((?: {12}\S.*(?:\n|$))+)/u.exec(step);
  assert.ok(match, "missing literal sparse-checkout block");
  return match[1]
    .trimEnd()
    .split("\n")
    .map((line) => line.trim());
}

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
  assert.match(ci, /docs_checkout: \$\{\{ steps\.plan\.outputs\.docs_checkout \}\}/);
  assert.match(ci, /base_sha: \$\{\{ needs\.plan\.outputs\.base_sha \}\}/);
  assert.match(ci, /mode: \$\{\{ needs\.plan\.outputs\.mode \}\}/);
  assert.match(ci, /full: \$\{\{ needs\.plan\.outputs\.full == 'true' \}\}/);
});

test("planner and ordinary docs consume the graph-owned checkout closure", () => {
  const ci = workflow("ci.yml");
  const planner = namedStep(ci, "Checkout planner closure");
  assert.deepEqual(literalSparsePaths(planner), graph.ciCheckout.planner.paths);
  assert.match(
    planner,
    new RegExp(`timeout-minutes: ${graph.ciCheckout.planner.timeoutMinutes}`),
  );
  assert.match(
    planner,
    new RegExp(`fetch-depth: ${graph.ciCheckout.planner.fetchDepth}`),
  );
  assert.match(
    planner,
    new RegExp(`sparse-checkout-cone-mode: ${graph.ciCheckout.planner.coneMode}`),
  );

  const decode = namedStep(ci, "Decode graph-projected docs checkout");
  assert.match(decode, /DOCS_CHECKOUT: \$\{\{ needs\.plan\.outputs\.docs_checkout \}\}/);
  assert.match(decode, /fromJSON\(needs\.plan\.outputs\.docs_checkout\)\.mode == 'sparse'/);

  const ordinaryDocs = namedStep(ci, "Checkout ordinary-doc closure");
  assert.match(ordinaryDocs, /steps\.docs-checkout\.outcome == 'success'/);
  assert.match(ordinaryDocs, /steps\.docs-checkout\.outputs\.paths/);
  assert.match(ordinaryDocs, /steps\.docs-checkout\.outputs\.fetch_depth/);
  assert.match(ordinaryDocs, /steps\.docs-checkout\.outputs\.cone_mode/);
  assert.match(ordinaryDocs, /fromJSON\(steps\.docs-checkout\.outputs\.timeout_minutes\)/);

  const fullPolicy = namedStep(ci, "Checkout full policy closure");
  assert.match(fullPolicy, /needs\.plan\.outputs\.policy_docs == 'true'/);
  assert.match(fullPolicy, /fromJSON\(needs\.plan\.outputs\.docs_checkout\)\.mode == 'full'/);
  assert.doesNotMatch(fullPolicy, /sparse-checkout/);
  assert.match(
    fullPolicy,
    new RegExp(`timeout-minutes: ${graph.ciCheckout.default.timeoutMinutes}`),
  );
  assert.match(
    fullPolicy,
    new RegExp(`fetch-depth: ${graph.ciCheckout.default.fetchDepth}`),
  );
});

test("tools fanout selects exactly one affected or full execution path", () => {
  const tools = workflow("tools-ci.yml");
  assert.match(tools, /base_sha:\s*\n\s+required: true\s*\n\s+type: string/);
  assert.match(tools, /mode:\s*\n\s+required: true\s*\n\s+type: string/);
  assert.match(tools, /full:\s*\n\s+required: true\s*\n\s+type: boolean/);
  assert.match(tools, /node tool\/run\.mjs affected-tools/);
  assert.match(tools, /--mode "\$MODE"/);
  assert.match(
    tools,
    /needs\.preflight\.outputs\.tool_mode == 'affected'/,
  );
  assert.match(
    tools,
    /needs\.preflight\.outputs\.tool_mode == 'full'/,
  );
  assert.match(tools, /- affected-tools\s*\n\s+- tool-buckets/);
  assert.match(
    tools,
    /Exactly one affected or full tool execution path must succeed/,
  );
  assert.match(
    tools,
    /strategy:\s*\n\s+fail-fast:\s+false\s*\n\s+matrix:/,
  );
  for (const bucket of [
    "core-audit",
    "lint-scanners",
    "contracts-data",
    "platform-env",
    "marketing-design",
    "organizer-intake",
  ]) {
    assert.match(tools, new RegExp(`name: ${bucket}`));
  }
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
