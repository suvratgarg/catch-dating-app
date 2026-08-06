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
  assert.match(ci, /base_sha: \$\{\{ needs\.plan\.outputs\.base_sha \}\}/);
  assert.match(ci, /mode: \$\{\{ needs\.plan\.outputs\.mode \}\}/);
  assert.match(ci, /full: \$\{\{ needs\.plan\.outputs\.full == 'true' \}\}/);
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

test("affected tools install only planner-declared setup requirements", () => {
  const tools = workflow("tools-ci.yml");
  assert.match(
    tools,
    /repository_view: \$\{\{ steps\.impact\.outputs\.repository_view \}\}/,
  );
  assert.match(
    tools,
    /setup_requirements: \$\{\{ steps\.impact\.outputs\.setup_requirements \}\}/,
  );
  const affectedJob = tools.match(
    /  affected-tools:\n(?<body>[\s\S]*?)\n  tool-buckets:/u,
  )?.groups?.body;
  assert.ok(affectedJob, "affected-tools job must remain present");
  assert.match(affectedJob, /- uses: actions\/setup-node@v6/u);
  assert.match(
    affectedJob,
    /cache: \$\{\{ \(contains\(fromJSON\(needs\.preflight\.outputs\.setup_requirements\), 'root-npm'\) \|\| contains\(fromJSON\(needs\.preflight\.outputs\.setup_requirements\), 'functions-npm'\)\) && 'npm' \|\| '' \}\}/u,
  );
  for (const [stepMarker, requirement] of [
    ["uses: ./.github/actions/setup-flutter", "flutter"],
    ["name: Install scanner dependencies", "ripgrep"],
    ["run: flutter pub get", "flutter-pub"],
    ["run: npm ci", "root-npm"],
    ["run: npm --prefix functions ci", "functions-npm"],
    ["name: Install marketing design browser", "playwright"],
  ]) {
    const step = affectedJob.match(
      new RegExp(
        `      - ${escapeRegex(stepMarker)}(?<body>[\\s\\S]*?)(?=\\n      - |$)`,
        "u",
      ),
    )?.groups?.body;
    assert.ok(step != null, `${stepMarker} step must remain present`);
    assert.match(
      step,
      new RegExp(
        `if: \\$\\{\\{ contains\\(fromJSON\\(needs\\.preflight\\.outputs\\.setup_requirements\\), '${requirement}'\\) \\}\\}`,
        "u",
      ),
    );
  }
});

function escapeRegex(value) {
  return value.replace(/[.*+?^${}()|[\]\\]/gu, "\\$&");
}

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
