import assert from "node:assert/strict";
import test from "node:test";
import {
  buildTaskStartContract,
  CONTEXT_PACK_SCHEMA_V3,
  deriveTaskCheckSelection,
  matchesTaskScopePatterns,
  normalizeTaskScopePaths,
  resolveStructuredCheckPlan,
  TASK_START_MODE,
  taskImpactBlockers,
  taskStartabilityBlockers,
  validateTaskStartContract,
} from "./lib/task_input.mjs";

const manifest = {
  tools: [
    {
      id: "task-check",
      status: "active",
      path: "tool/check.mjs",
      safety: "local-readonly",
      checks: ["node tool/check.mjs"],
      taskPaths: ["contracts/runtime.json"],
      alsoCheckIds: ["task-dependency"],
      ciRequirements: {repositoryView: "index", setup: ["node"]},
    },
    {
      id: "task-dependency",
      status: "active",
      path: "tool/dependency.mjs",
      safety: "local-readonly",
      checks: ["node tool/dependency.mjs"],
      alsoCheckIds: ["task-check"],
      ciRequirements: {repositoryView: "index", setup: ["node"]},
    },
    {
      id: "integration-check",
      status: "active",
      path: "operations/full-scan.mjs",
      safety: "local-readonly",
      checks: ["node operations/full-scan.mjs"],
    },
    {
      id: "inactive-check",
      status: "retired",
      path: "tool/retired.mjs",
    },
  ],
};

test("structured check plans deduplicate cycles and defer full-view checks", () => {
  const plan = resolveStructuredCheckPlan({
    manifest,
    requestedChecks: [
      {id: "task-check", sources: ["skill:one"]},
      {id: "task-check", sources: ["regression:two"]},
      {id: "integration-check", sources: ["regression:full"]},
    ],
  });
  assert.deepEqual(plan.blockers, []);
  assert.deepEqual(plan.task.map((entry) => entry.id), ["task-check", "task-dependency"]);
  assert.deepEqual(plan.integration.map((entry) => entry.id), ["integration-check"]);
  assert.deepEqual(plan.task[0].sources, ["regression:two", "skill:one", "transitive:task-dependency"]);
  assert.deepEqual(plan.task[1].sources, ["transitive:task-check"]);
});

test("task scope normalization makes equivalent directory spelling identical", () => {
  assert.deepEqual(
    normalizeTaskScopePaths(["./tool/", "docs/plan.md", "tool"]),
    ["docs/plan.md", "tool"],
  );
  assert.throws(() => normalizeTaskScopePaths(["../../outside"]), /repository-relative/u);
  for (const absolutePath of ["/tmp/x", "//server/share", "C:\\tmp\\x"]) {
    assert.throws(() => normalizeTaskScopePaths([absolutePath]), /repository-relative/u);
  }
});

test("recursive scope patterns match nested feature files without treating globs as literals", () => {
  assert.equal(matchesTaskScopePatterns(
    ["lib/explore/presentation/screen.dart"],
    ["lib/**/presentation/**"],
  ), true);
  const selection = deriveTaskCheckSelection({
    task: "explore-feature",
    mode: TASK_START_MODE,
    impactPaths: [
      "lib/explore",
      "lib/explore/data/repository.dart",
      "lib/explore/presentation/screen.dart",
    ],
    skills: [
      {skill_id: "ui", applies_to: ["lib/**/presentation/**"], required_tools: []},
      {skill_id: "contract", applies_to: ["lib/**/data/**"], required_tools: []},
    ],
    regressions: [],
  });
  assert.deepEqual(selection.matchedSkills.map((skill) => skill.skill_id), ["ui", "contract"]);
});

test("task startability uses the same task-id and materialized-scope contract", () => {
  const inspectPath = (relativePath) => ({
    docs: "tree",
    "docs/plan.md": "blob",
  })[relativePath] ?? null;
  assert.deepEqual(taskStartabilityBlockers({
    taskId: "valid-task",
    scopePaths: ["docs", "docs/new.md"],
    inspectPath,
  }), []);
  assert.deepEqual(taskStartabilityBlockers({
    taskId: "Not A Task",
    scopePaths: [],
    inspectPath,
  }), ["invalid_task_id", "task_scope_empty"]);
  assert.deepEqual(taskStartabilityBlockers({
    taskId: "valid-task",
    scopePaths: ["missing/path.md"],
    inspectPath,
  }), ["task_scope_path_missing:missing/path.md"]);
});

test("planned impact is nonempty, exact, and contained by the owned write boundary", () => {
  const inspectPath = (relativePath) => ({
    docs: "tree",
    "lib/profile.txt": "blob",
  })[relativePath] ?? null;
  assert.deepEqual(taskImpactBlockers({
    ownedPaths: ["docs"],
    plannedImpactPaths: ["docs/new.md"],
    inspectPath,
  }), []);
  assert.deepEqual(taskImpactBlockers({
    ownedPaths: ["lib/profile.txt"],
    plannedImpactPaths: ["lib/profile.txt/new.md"],
    inspectPath,
  }), ["planned_impact_outside_owned_scope:lib/profile.txt/new.md"]);
  assert.deepEqual(taskImpactBlockers({
    ownedPaths: ["docs"],
    plannedImpactPaths: ["lib/explore/new.dart"],
    inspectPath,
  }), ["planned_impact_outside_owned_scope:lib/explore/new.dart"]);
  assert.deepEqual(taskImpactBlockers({
    ownedPaths: ["docs"],
    plannedImpactPaths: [],
    inspectPath,
  }), ["planned_impact_empty"]);
});

test("broad ownership does not broaden impact-based skill and regression selection", () => {
  const selection = deriveTaskCheckSelection({
    task: "narrow-presentation-change",
    mode: TASK_START_MODE,
    impactPaths: ["lib/explore/presentation/screen.dart"],
    skills: [
      {skill_id: "ui", applies_to: ["lib/**/presentation/**"], required_tools: []},
      {skill_id: "data", applies_to: ["lib/**/data/**"], required_tools: []},
    ],
    regressions: [
      {id: "REG-UI", status: "active", applies_to: ["lib/**/presentation/**"]},
      {id: "REG-DATA", status: "active", applies_to: ["lib/**/data/**"]},
    ],
  });
  assert.deepEqual(selection.matchedSkills.map((entry) => entry.skill_id), ["ui"]);
  assert.deepEqual(selection.matchedRegressions.map((entry) => entry.id), ["REG-UI"]);
});

test("task-start contracts separate scope, support paths, and deferred checks", () => {
  const requests = [
    {id: "task-check", sources: ["skill:one"]},
    {id: "integration-check", sources: ["regression:full"]},
  ];
  const selection = trustedSelection(requests);
  const plan = resolveStructuredCheckPlan({manifest, requestedChecks: requests});
  const taskStart = buildTaskStartContract({
    taskId: "profile-task",
    mode: TASK_START_MODE,
    sourceSha: "a".repeat(40),
    ownedPaths: ["lib/profile", "docs/plan.md"],
    plannedImpactPaths: ["lib/profile", "docs/plan.md"],
    checkPlan: plan,
    sourceClean: true,
    blockers: plan.blockers,
  });
  assert.equal(taskStart.complete, true);
  assert.deepEqual(taskStart.checkIds, ["task-check", "task-dependency"]);
  assert.deepEqual(taskStart.deferredCheckIds, ["integration-check"]);
  assert.deepEqual(taskStart.requiredEntrypoints, ["tool/check.mjs", "tool/dependency.mjs"]);
  assert.deepEqual(taskStart.supportPaths, ["contracts/runtime.json", "tool"]);

  const pack = {
    schema: CONTEXT_PACK_SCHEMA_V3,
    sourceSha: "a".repeat(40),
    sourceClean: true,
    task: "profile-task",
    mode: TASK_START_MODE,
    scope: {
      ownedPaths: ["docs/plan.md", "lib/profile"],
      plannedImpactPaths: ["docs/plan.md", "lib/profile"],
    },
    skills: [],
    regressionGuards: [],
    checkPlan: plan,
    taskStart,
  };
  assert.deepEqual(validateTaskStartContract({
    pack,
    manifest,
    taskId: "profile-task",
    baseSha: "a".repeat(40),
    ownedPaths: ["docs/plan.md", "lib/profile"],
    plannedImpactPaths: ["docs/plan.md", "lib/profile"],
    selection,
  }).errors, []);

  pack.taskStart.requiredEntrypoints = ["tool/other.mjs"];
  assert.ok(validateTaskStartContract({
    pack,
    manifest,
    taskId: "profile-task",
    baseSha: "a".repeat(40),
    ownedPaths: ["docs/plan.md", "lib/profile"],
    plannedImpactPaths: ["docs/plan.md", "lib/profile"],
    selection,
  }).errors.includes("context_pack_closure_mismatch"));
});

test("pack envelope scope, cleanliness, and check plan are bound to authorization", () => {
  const requests = [{id: "task-check", sources: ["fixture"]}];
  const selection = trustedSelection(requests);
  const plan = resolveStructuredCheckPlan({manifest, requestedChecks: requests});
  const taskStart = buildTaskStartContract({
    taskId: "bound-pack",
    mode: TASK_START_MODE,
    sourceSha: "c".repeat(40),
    ownedPaths: ["tool/"],
    plannedImpactPaths: ["tool/"],
    checkPlan: plan,
    sourceClean: true,
    blockers: plan.blockers,
  });
  const basePack = {
    schema: CONTEXT_PACK_SCHEMA_V3,
    sourceSha: "c".repeat(40),
    sourceClean: true,
    task: "bound-pack",
    mode: TASK_START_MODE,
    scope: {ownedPaths: ["tool"], plannedImpactPaths: ["tool"]},
    skills: [],
    regressionGuards: [],
    checkPlan: plan,
    taskStart,
  };
  const validate = (pack) => validateTaskStartContract({
    pack,
    manifest,
    taskId: "bound-pack",
    baseSha: "c".repeat(40),
    ownedPaths: ["tool"],
    plannedImpactPaths: ["tool"],
    selection,
  }).errors;
  assert.deepEqual(validate(basePack), []);
  assert.ok(validate({...basePack, sourceClean: false}).includes("context_pack_source_not_clean"));
  assert.ok(validate({...basePack, scope: {
    ...basePack.scope,
    ownedPaths: ["../../outside"],
  }}).includes(
    "context_pack_envelope_ownership_mismatch",
  ));
  assert.ok(validate({...basePack, scope: {
    ...basePack.scope,
    plannedImpactPaths: ["tool/other.mjs"],
  }}).includes(
    "context_pack_envelope_impact_mismatch",
  ));
  assert.ok(validate({
    ...basePack,
    taskStart: {...basePack.taskStart, plannedImpactPaths: ["tool/other.mjs"]},
  }).includes("context_pack_digest_mismatch"));
  assert.ok(validate({...basePack, checkPlan: {task: [], integration: [], blockers: []}}).includes(
    "context_pack_envelope_check_plan_mismatch",
  ));
});

test("malformed task input arrays fail validation without throwing", () => {
  const requests = [{id: "task-check", sources: ["fixture"]}];
  const selection = trustedSelection(requests);
  const plan = resolveStructuredCheckPlan({manifest, requestedChecks: requests});
  const taskStart = buildTaskStartContract({
    taskId: "malformed-pack",
    mode: TASK_START_MODE,
    sourceSha: "d".repeat(40),
    ownedPaths: ["tool"],
    plannedImpactPaths: ["tool"],
    checkPlan: plan,
    sourceClean: true,
    blockers: plan.blockers,
  });
  const pack = {
    schema: CONTEXT_PACK_SCHEMA_V3,
    sourceSha: "d".repeat(40),
    sourceClean: true,
    task: "malformed-pack",
    mode: TASK_START_MODE,
    scope: {ownedPaths: ["tool"], plannedImpactPaths: ["tool"]},
    skills: [],
    regressionGuards: [],
    checkPlan: plan,
    taskStart: {...taskStart, checkIds: "task-check"},
  };
  const result = validateTaskStartContract({
    pack,
    manifest,
    taskId: "malformed-pack",
    baseSha: "d".repeat(40),
    ownedPaths: ["tool"],
    plannedImpactPaths: ["tool"],
    selection,
  });
  assert.ok(result.errors.includes("invalid_task_input_checkIds"));
});

test("only unique active executable local-readonly checks can authorize a task", () => {
  const cases = [
    {
      tools: [{id: "bad", status: "active", path: "tool/bad.mjs", safety: "local-readonly"}],
      blocker: "check_has_no_executable_commands:bad",
    },
    {
      tools: [
        {id: "bad", status: "active", path: "tool/a.mjs", safety: "local-readonly", checks: ["node tool/a.mjs"]},
        {id: "bad", status: "active", path: "tool/b.mjs", safety: "local-readonly", checks: ["node tool/b.mjs"]},
      ],
      blocker: "duplicate_active_check_id:bad",
    },
    {
      tools: [{id: "bad", status: "active", path: "tool/bad.mjs", safety: "remote-write-explicit", checks: ["node tool/bad.mjs"]}],
      blocker: "unsafe_structured_check:bad",
    },
    {
      tools: [{
        id: "bad",
        status: "active",
        path: "tool/bad.mjs",
        safety: "local-readonly",
        checks: ["node tool/bad.mjs"],
        ciRequirements: {repositoryView: "index", setup: []},
      }],
      blocker: "invalid_ci_requirements:bad",
    },
  ];
  for (const fixture of cases) {
    const plan = resolveStructuredCheckPlan({
      manifest: {tools: fixture.tools},
      requestedChecks: [{id: "bad", sources: ["fixture"]}],
    });
    assert.ok(plan.blockers.includes(fixture.blocker), JSON.stringify(plan));
    assert.deepEqual(plan.task, []);
    assert.deepEqual(plan.integration, []);
  }
});

test("unknown checks and dirty source state make task input incomplete", () => {
  const plan = resolveStructuredCheckPlan({
    manifest,
    requestedChecks: [{id: "inactive-check", sources: ["regression:unknown"]}],
  });
  assert.deepEqual(plan.blockers, ["unknown_or_inactive_check:inactive-check"]);
  const taskStart = buildTaskStartContract({
    taskId: "dirty-task",
    mode: TASK_START_MODE,
    sourceSha: "b".repeat(40),
    ownedPaths: ["tool"],
    plannedImpactPaths: ["tool"],
    checkPlan: plan,
    sourceClean: false,
    blockers: plan.blockers,
  });
  assert.equal(taskStart.complete, false);
  assert.deepEqual(taskStart.blockers, [
    "source_worktree_not_clean",
    "unknown_or_inactive_check:inactive-check",
  ]);
});

test("trusted selection prevents a caller from dropping mandatory checks", () => {
  const authorityManifest = {
    tools: [
      ...manifest.tools,
      {
        id: "agent:readiness",
        status: "active",
        path: "tool/agent/check_agent_readiness.mjs",
        safety: "local-readonly",
        checks: ["node tool/agent/check_agent_readiness.mjs"],
        ciRequirements: {repositoryView: "index", setup: ["node"]},
      },
    ],
  };
  const underscopedRequests = [{id: "task-check", sources: ["fixture"]}];
  const underscopedPlan = resolveStructuredCheckPlan({
    manifest: authorityManifest,
    requestedChecks: underscopedRequests,
  });
  const taskStart = buildTaskStartContract({
    taskId: "under-scoped",
    mode: TASK_START_MODE,
    sourceSha: "e".repeat(40),
    ownedPaths: ["tool"],
    plannedImpactPaths: ["tool"],
    checkPlan: underscopedPlan,
    sourceClean: true,
    blockers: underscopedPlan.blockers,
  });
  const pack = {
    schema: CONTEXT_PACK_SCHEMA_V3,
    sourceSha: "e".repeat(40),
    sourceClean: true,
    task: "under-scoped",
    mode: TASK_START_MODE,
    scope: {ownedPaths: ["tool"], plannedImpactPaths: ["tool"]},
    skills: [],
    regressionGuards: [],
    checkPlan: underscopedPlan,
    taskStart,
  };
  const trusted = trustedSelection([
    {id: "agent:readiness", sources: ["baseline"]},
    ...underscopedRequests,
  ]);
  const result = validateTaskStartContract({
    pack,
    manifest: authorityManifest,
    taskId: "under-scoped",
    baseSha: "e".repeat(40),
    ownedPaths: ["tool"],
    plannedImpactPaths: ["tool"],
    selection: trusted,
  });
  assert.ok(result.errors.includes("context_pack_closure_mismatch"));
  assert.ok(result.errors.includes("context_pack_envelope_check_plan_mismatch"));
});

test("noncanonical manifest task paths fail closed", () => {
  const plan = resolveStructuredCheckPlan({
    manifest: {
      tools: [{
        id: "unsafe",
        status: "active",
        path: "tool/unsafe.mjs",
        safety: "local-readonly",
        checks: ["node tool/unsafe.mjs"],
        taskPaths: ["../outside"],
        ciRequirements: {repositoryView: "index", setup: ["node"]},
      }],
    },
    requestedChecks: [{id: "unsafe", sources: ["fixture"]}],
  });
  assert.deepEqual(plan.blockers, ["invalid_task_path:unsafe"]);
  assert.deepEqual(plan.task, []);
});

function trustedSelection(requests, deferredRegressionIds = []) {
  return {
    mode: TASK_START_MODE,
    requests,
    deferredRegressionIds,
    matchedSkills: [],
    matchedRegressions: [],
  };
}
