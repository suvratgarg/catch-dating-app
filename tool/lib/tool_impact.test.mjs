import assert from "node:assert/strict";
import fs from "node:fs";
import test from "node:test";
import {
  canonicalHarnessFullPaths,
  duplicateCanonicalFullPathOverrides,
  formatAffectedToolGithubOutputs,
  hasExecutableChecks,
  planAffectedToolChecks,
} from "./tool_impact.mjs";

const productionGraph = JSON.parse(
  fs.readFileSync(new URL("../harness/component_graph.json", import.meta.url), "utf8"),
);

function componentGraph() {
  return productionGraph;
}

function manifest(tools, overrides = {}) {
  return {
    version: 1,
    ciImpact: {
      mandatoryCheckIds: ["guard"],
      additionalFullPaths: ["tool/run.mjs"],
      ...overrides,
    },
    tools: [
      {
        id: "guard",
        path: "tool/guard.mjs",
        status: "active",
        checks: ["node tool/guard.mjs"],
      },
      ...tools,
    ],
  };
}

test("primary and declared impact paths select their active owner plus guards", () => {
  const fixture = manifest([
    {
      id: "docs-check",
      path: "tool/docs/check.mjs",
      impactPaths: ["tool/docs/check.test.mjs", "tool/docs/fixtures/**"],
      status: "active",
      checks: ["node tool/docs/check.mjs"],
    },
  ]);
  for (const changedPath of [
    "tool/docs/check.mjs",
    "tool/docs/check.test.mjs",
    "tool/docs/fixtures/example.json",
  ]) {
    const plan = planAffectedToolChecks({
      changedPaths: [changedPath],
      manifest: fixture,
      componentGraph: componentGraph(),
    });
    assert.equal(plan.mode, "affected");
    assert.deepEqual(plan.toolIds, ["docs-check", "guard"]);
  }
});

test("transitive check dependencies are selected once", () => {
  const fixture = manifest([
    {
      id: "owner",
      path: "tool/owner.mjs",
      status: "active",
      checks: ["node tool/owner.mjs"],
      alsoCheckIds: ["dependency"],
    },
    {
      id: "dependency",
      path: "tool/dependency.mjs",
      status: "active",
      checks: ["node tool/dependency.mjs"],
      alsoCheckIds: ["guard"],
    },
  ]);
  const plan = planAffectedToolChecks({
    changedPaths: ["tool/owner.mjs"],
    manifest: fixture,
    componentGraph: componentGraph(),
  });
  assert.deepEqual(plan.toolIds, ["dependency", "guard", "owner"]);
});

test("unmapped lane inputs and control-plane changes fail closed to full", () => {
  const fixture = manifest([]);
  const unmapped = planAffectedToolChecks({
    changedPaths: ["design/screens/catch.screens.json"],
    manifest: fixture,
    componentGraph: componentGraph(),
  });
  assert.equal(unmapped.mode, "full");
  assert.deepEqual(unmapped.unmappedPaths, ["design/screens/catch.screens.json"]);

  const controlPlane = planAffectedToolChecks({
    changedPaths: [".github/workflows/ci.yml"],
    manifest: fixture,
    componentGraph: componentGraph(),
  });
  assert.equal(controlPlane.mode, "full");
  assert.match(controlPlane.fullReasons[0], /control-plane/u);

  const noChecks = planAffectedToolChecks({
    changedPaths: ["tool/no-checks.mjs"],
    manifest: manifest([
      {
        id: "no-checks",
        path: "tool/no-checks.mjs",
        status: "active",
      },
    ]),
    componentGraph: componentGraph(),
  });
  assert.equal(noChecks.mode, "full");
  assert.deepEqual(noChecks.unmappedPaths, ["tool/no-checks.mjs"]);
});

test("a mixed plan cannot hide an unowned lane input behind an owned tool", () => {
  const fixture = manifest([
    {
      id: "docs-check",
      path: "tool/docs/check.mjs",
      status: "active",
      checks: ["node tool/docs/check.mjs"],
    },
  ]);
  const plan = planAffectedToolChecks({
    changedPaths: ["tool/docs/check.mjs", "design/screens/catch.screens.json"],
    manifest: fixture,
    componentGraph: componentGraph(),
  });
  assert.equal(plan.mode, "full");
  assert.deepEqual(plan.unmappedPaths, ["design/screens/catch.screens.json"]);
});

test("non-Tools companion files do not broaden an owned tool change", () => {
  const fixture = manifest([
    {
      id: "docs-check",
      path: "tool/docs/check.mjs",
      status: "active",
      checks: ["node tool/docs/check.mjs"],
    },
  ]);
  const plan = planAffectedToolChecks({
    changedPaths: ["tool/docs/check.mjs", "docs/audit_registry/passes.jsonl"],
    manifest: fixture,
    componentGraph: componentGraph(),
  });
  assert.equal(plan.mode, "affected");
  assert.deepEqual(plan.toolLanePaths, ["tool/docs/check.mjs"]);
  assert.deepEqual(plan.ignoredPaths, ["docs/audit_registry/passes.jsonl"]);
});

test("declared full-impact paths cannot be hidden as non-Tools companions", () => {
  const fixture = manifest([
    {
      id: "docs-check",
      path: "tool/docs/check.mjs",
      status: "active",
      checks: ["node tool/docs/check.mjs"],
    },
  ], {
    additionalFullPaths: ["pubspec.lock", "functions/package-lock.json"],
  });

  for (const fullPath of ["pubspec.lock", "functions/package-lock.json"]) {
    const plan = planAffectedToolChecks({
      changedPaths: ["tool/docs/check.mjs", fullPath],
      manifest: fixture,
      componentGraph: componentGraph(),
    });
    assert.equal(plan.mode, "full");
    assert.ok(plan.ignoredPaths.includes(fullPath));
    assert.ok(
      plan.fullReasons.includes(`control-plane path changed: ${fullPath}`),
    );
  }
});

test("tool-lane classification uses the authoritative Harness mode", () => {
  const graph = structuredClone(componentGraph());
  graph.operationProfiles["repo-tooling"].direct.pr = {ciTargets: []};
  const fixture = manifest([
    {
      id: "docs-check",
      path: "tool/docs/check.mjs",
      status: "active",
      checks: ["node tool/docs/check.mjs"],
    },
  ]);
  const main = planAffectedToolChecks({
    changedPaths: ["tool/docs/check.mjs"],
    manifest: fixture,
    componentGraph: graph,
    mode: "main",
  });
  assert.equal(main.mode, "affected");
  assert.equal(main.harnessMode, "main");
  assert.deepEqual(main.toolLanePaths, ["tool/docs/check.mjs"]);

  const pr = planAffectedToolChecks({
    changedPaths: ["tool/docs/check.mjs"],
    manifest: fixture,
    componentGraph: graph,
    mode: "pr",
  });
  assert.equal(pr.mode, "full");
  assert.deepEqual(pr.ignoredPaths, ["tool/docs/check.mjs"]);
});

test("explicit full remains full and affected outputs stay bounded", () => {
  const plan = planAffectedToolChecks({
    changedPaths: [],
    manifest: manifest([]),
    componentGraph: componentGraph(),
    full: true,
  });
  assert.equal(plan.mode, "full");
  assert.equal(
    formatAffectedToolGithubOutputs(plan),
    "tool_mode=full\naffected=false\nfull=true\n",
  );
  assert.throws(
    () => formatAffectedToolGithubOutputs({complete: false, mode: "affected"}),
    /incomplete affected-tool plan/u,
  );
});

test("inactive or unknown dependencies cannot be selected", () => {
  const fixture = manifest([
    {
      id: "owner",
      path: "tool/owner.mjs",
      status: "active",
      checks: ["node tool/owner.mjs"],
      alsoCheckIds: ["missing"],
    },
  ]);
  assert.throws(
    () => planAffectedToolChecks({
      changedPaths: ["tool/owner.mjs"],
      manifest: fixture,
      componentGraph: componentGraph(),
    }),
    /inactive or unknown tool id: missing/u,
  );
});

test("canonical harness full paths come only from the component graph", () => {
  assert.deepEqual(canonicalHarnessFullPaths(componentGraph()), [
    ".github/**",
    "tool/ci/**",
    "tool/harness/**",
    "tool/harness.mjs",
    "tool/repository_root_manifest.json",
    "tool/tools_manifest.json",
  ]);
  assert.throws(
    () => canonicalHarnessFullPaths({components: []}),
    /must declare non-empty repo\.harness/u,
  );
});

test("active check ownership rejects vacuous shell commands", () => {
  assert.equal(hasExecutableChecks({checks: ["node tool/check.mjs"]}), true);
  for (const checks of [undefined, [], [""], ["   "]]) {
    assert.equal(hasExecutableChecks({checks}), false);
  }
});

test("additional full paths cannot duplicate canonical harness authority", () => {
  const fixture = manifest([], {additionalFullPaths: ["tool/ci/**", "tool/run.mjs"]});
  assert.deepEqual(
    duplicateCanonicalFullPathOverrides({
      manifest: fixture,
      componentGraph: componentGraph(),
    }),
    ["tool/ci/**"],
  );
});
