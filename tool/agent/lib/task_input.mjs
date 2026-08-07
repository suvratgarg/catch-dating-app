import {createHash} from "node:crypto";
import {
  hasExecutableChecks,
  toolChecksAreLocalReadonly,
  validateToolCiRequirements,
} from "../../lib/tool_impact.mjs";

export const CONTEXT_PACK_SCHEMA_V2 = "catch.agent-context-pack/v2";
export const CONTEXT_PACK_SCHEMA_V3 = "catch.agent-context-pack/v3";
export const TASK_INPUT_SCHEMA_V1 = "catch.harness-task-input/v1";
export const TASK_INPUT_SCHEMA_V2 = "catch.harness-task-input/v2";
export const TASK_START_MODE = "parallel-delegation";
const TASK_ID_PATTERN = /^[a-z0-9][a-z0-9._-]{2,79}$/u;

export function isValidTaskId(value) {
  return typeof value === "string" && value !== "unspecified" && TASK_ID_PATTERN.test(value);
}

export function normalizeTaskScopePaths(values) {
  if (!Array.isArray(values)) throw new Error("Task scope paths must be an array.");
  const normalized = [];
  for (const rawValue of values) {
    if (typeof rawValue !== "string") throw new Error("Task scope paths must be strings.");
    for (const rawPart of rawValue.split(",")) {
      const rawPath = rawPart.trim().replaceAll("\\", "/");
      if (/^(?:\/+|[A-Za-z]:\/)/u.test(rawPath)) {
        throw new Error(`Task scope path must be repository-relative and explicit: ${rawPart}`);
      }
      const value = rawPath.replace(/^\.\//u, "").replace(/\/+$/gu, "");
      if (value === "") continue;
      if (!isCanonicalTaskPath(value)) {
        throw new Error(`Task scope path must be repository-relative and explicit: ${rawPart}`);
      }
      normalized.push(value);
    }
  }
  return uniqueSorted(normalized);
}

export function isCanonicalTaskPath(value) {
  if (typeof value !== "string" || value === "" || value.startsWith("/") || value.includes("\\")) {
    return false;
  }
  const segments = value.split("/");
  return !/[\u0000-\u001f*?\[\]]/u.test(value) &&
    !segments.some((segment) => segment === "" || segment === "." || segment === ".." || segment === ".git") &&
    !/^[A-Za-z]:/u.test(value);
}

export function taskStartabilityBlockers({taskId, scopePaths, inspectPath}) {
  const blockers = [];
  if (!isValidTaskId(taskId)) blockers.push("invalid_task_id");
  let normalizedScopePaths;
  try {
    normalizedScopePaths = normalizeTaskScopePaths(scopePaths);
  } catch {
    return [...new Set([...blockers, "invalid_task_scope_path"])].sort();
  }
  if (normalizedScopePaths.length === 0) blockers.push("task_scope_empty");
  if (typeof inspectPath !== "function") {
    blockers.push("task_scope_inspection_unavailable");
    return [...new Set(blockers)].sort();
  }
  const records = new Map();
  const selectedTrees = [];
  try {
    for (const scopePath of normalizedScopePaths) {
      const record = inspectPath(scopePath);
      const type = typeof record === "string" ? record : record?.type ?? null;
      records.set(scopePath, type);
      if (type === "tree") selectedTrees.push(scopePath);
      else if (type != null && type !== "blob") {
        blockers.push(`task_scope_path_unsupported:${scopePath}`);
      }
    }
  } catch {
    blockers.push("task_scope_inspection_unavailable");
    return [...new Set(blockers)].sort();
  }
  for (const scopePath of normalizedScopePaths) {
    if (records.get(scopePath) != null) continue;
    const selectedParent = selectedTrees.some((tree) => scopePath.startsWith(`${tree}/`));
    if (!selectedParent) blockers.push(`task_scope_path_missing:${scopePath}`);
  }
  return [...new Set(blockers)].sort();
}

export function taskImpactBlockers({ownedPaths, plannedImpactPaths, inspectPath}) {
  const blockers = [];
  let normalizedOwnedPaths;
  let normalizedPlannedImpactPaths;
  try {
    normalizedOwnedPaths = normalizeTaskScopePaths(ownedPaths);
    normalizedPlannedImpactPaths = normalizeTaskScopePaths(plannedImpactPaths);
  } catch {
    return ["invalid_planned_impact_path"];
  }
  if (normalizedPlannedImpactPaths.length === 0) blockers.push("planned_impact_empty");
  if (typeof inspectPath !== "function") {
    return [...new Set([...blockers, "planned_impact_inspection_unavailable"])].sort();
  }
  const owned = [];
  try {
    for (const ownedPath of normalizedOwnedPaths) {
      const record = inspectPath(ownedPath);
      const type = typeof record === "string" ? record : record?.type ?? null;
      owned.push({path: ownedPath, tree: type === "tree"});
    }
    for (const impactPath of normalizedPlannedImpactPaths) {
      const record = inspectPath(impactPath);
      const type = typeof record === "string" ? record : record?.type ?? null;
      if (type != null && !["blob", "tree"].includes(type)) {
        blockers.push(`planned_impact_path_unsupported:${impactPath}`);
      }
      const covered = owned.some((entry) => impactPath === entry.path ||
        (entry.tree && impactPath.startsWith(`${entry.path}/`)));
      if (!covered) blockers.push(`planned_impact_outside_owned_scope:${impactPath}`);
    }
  } catch {
    blockers.push("planned_impact_inspection_unavailable");
  }
  return [...new Set(blockers)].sort();
}

export function deriveTaskCheckSelection({
  task,
  mode,
  impactPaths,
  skills,
  regressions,
}) {
  const normalizedImpactPaths = normalizeTaskScopePaths(impactPaths);
  const matchedSkills = selectTaskSkills(skills ?? [], task, normalizedImpactPaths);
  const matchedRegressions = selectTaskRegressions(regressions ?? [], normalizedImpactPaths);
  const requests = new Map();
  const deferredRegressionIds = [];
  addStructuredCheck(requests, "agent:readiness", "baseline");
  if (mode === TASK_START_MODE) {
    addStructuredCheck(requests, "agent:harness-v2", `mode:${TASK_START_MODE}`);
    addStructuredCheck(requests, "agent:record-delegation", `mode:${TASK_START_MODE}`);
  }
  for (const skill of matchedSkills) {
    for (const id of skill.required_tools ?? []) {
      addStructuredCheck(requests, id, `skill:${skill.skill_id}`);
    }
  }
  for (const regression of matchedRegressions) {
    if (regression.guard?.type !== "command") continue;
    const ids = regression.guard.check_ids;
    if (!Array.isArray(ids) || ids.length === 0) {
      deferredRegressionIds.push(regression.id);
      continue;
    }
    for (const id of ids) addStructuredCheck(requests, id, `regression:${regression.id}`);
  }
  return {
    mode,
    matchedSkills,
    matchedRegressions,
    requests: [...requests.entries()].map(([id, sources]) => ({
      id,
      sources: [...sources].sort(),
    })),
    deferredRegressionIds: uniqueSorted(deferredRegressionIds),
  };
}

export function selectTaskSkills(skills, task, scopePaths) {
  const scoped = skills.filter((skill) => matchesTaskScopePatterns(scopePaths, skill.applies_to ?? []));
  if (scoped.length > 0) return scoped;
  const taskText = String(task ?? "").toLowerCase();
  const selected = skills.filter((skill) => {
    const id = String(skill.skill_id ?? "").toLowerCase();
    return taskText.split(/[^a-z0-9]+/u).some((part) => part.length > 2 && id.includes(part));
  });
  return selected;
}

export function selectTaskRegressions(entries, scopePaths) {
  return entries
    .filter((entry) => ["active", "watch"].includes(entry.status))
    .filter((entry) =>
      scopePaths.length === 0 || matchesTaskScopePatterns(scopePaths, entry.applies_to ?? []));
}

export function matchesTaskScopePatterns(candidates, patterns) {
  if (!Array.isArray(candidates) || !Array.isArray(patterns) || patterns.length === 0) return false;
  return candidates.some((candidate) => patterns.some((pattern) => matchesPattern(candidate, pattern)));
}

export function resolveStructuredCheckPlan({manifest, requestedChecks}) {
  if (!Array.isArray(manifest?.tools)) {
    throw new Error("Tool manifest must contain a tools array.");
  }
  const activeById = new Map();
  const duplicateActiveIds = new Set();
  for (const tool of manifest.tools.filter((entry) => entry?.status === "active")) {
    if (activeById.has(tool.id)) duplicateActiveIds.add(tool.id);
    else activeById.set(tool.id, tool);
  }
  const sourcesById = new Map();
  const pending = [];
  for (const request of requestedChecks ?? []) {
    if (typeof request?.id !== "string" || request.id === "") {
      throw new Error("Structured check requests require a non-empty id.");
    }
    if (!Array.isArray(request.sources) || request.sources.some(
      (source) => typeof source !== "string" || source === "",
    )) {
      throw new Error(`Structured check request ${request.id} requires string sources.`);
    }
    const sources = sourcesById.get(request.id) ?? new Set();
    for (const source of request.sources) sources.add(source);
    sourcesById.set(request.id, sources);
    pending.push(request.id);
  }

  const resolvedIds = new Set();
  const blockers = [];
  while (pending.length > 0) {
    const id = pending.shift();
    if (resolvedIds.has(id)) continue;
    resolvedIds.add(id);
    const tool = activeById.get(id);
    if (!tool) {
      blockers.push(`unknown_or_inactive_check:${id}`);
      continue;
    }
    if (duplicateActiveIds.has(id)) {
      blockers.push(`duplicate_active_check_id:${id}`);
      continue;
    }
    if (tool.alsoCheckIds != null && (!Array.isArray(tool.alsoCheckIds) || tool.alsoCheckIds.some(
      (dependencyId) => typeof dependencyId !== "string" || dependencyId === "",
    ))) {
      blockers.push(`invalid_check_dependencies:${id}`);
      continue;
    }
    for (const dependencyId of tool.alsoCheckIds ?? []) {
      const dependencySources = sourcesById.get(dependencyId) ?? new Set();
      dependencySources.add(`transitive:${id}`);
      sourcesById.set(dependencyId, dependencySources);
      pending.push(dependencyId);
    }
  }

  const task = [];
  const integration = [];
  for (const id of [...resolvedIds].sort()) {
    const tool = activeById.get(id);
    if (!tool) continue;
    if (duplicateActiveIds.has(id)) continue;
    const repositoryView = tool.ciRequirements?.repositoryView ?? "full";
    if (validateToolCiRequirements(tool).length > 0) {
      blockers.push(`invalid_ci_requirements:${id}`);
      continue;
    }
    if (!["index", "full"].includes(repositoryView)) {
      blockers.push(`invalid_repository_view:${id}`);
      continue;
    }
    if (!isCanonicalTaskPath(tool.path)) {
      blockers.push(`invalid_check_entrypoint:${id}`);
      continue;
    }
    if (!hasExecutableChecks(tool)) {
      blockers.push(`check_has_no_executable_commands:${id}`);
      continue;
    }
    if (!toolChecksAreLocalReadonly(tool)) {
      blockers.push(`unsafe_structured_check:${id}`);
      continue;
    }
    if (tool.taskPaths != null && (!Array.isArray(tool.taskPaths) || tool.taskPaths.some(
      (entry) => typeof entry !== "string" || entry === "",
    ))) {
      blockers.push(`invalid_task_path:${id}`);
      continue;
    }
    const taskPaths = uniqueSorted(tool.taskPaths ?? []);
    if (taskPaths.some((entry) => !isCanonicalTaskPath(entry))) {
      blockers.push(`invalid_task_path:${id}`);
      continue;
    }
    const entry = {
      id,
      sources: [...(sourcesById.get(id) ?? [])].sort(),
      repositoryView,
      entrypoint: tool.path,
      taskPaths,
    };
    if (repositoryView === "index") task.push(entry);
    else integration.push(entry);
  }
  return {task, integration, blockers: [...new Set(blockers)].sort()};
}

export function buildTaskStartContract({
  taskId,
  mode,
  sourceSha,
  ownedPaths,
  plannedImpactPaths,
  checkPlan,
  sourceClean,
  blockers = [],
  deferredRegressionIds = [],
  schema = TASK_INPUT_SCHEMA_V2,
}) {
  const normalizedOwnedPaths = normalizeTaskScopePaths(ownedPaths ?? []);
  const normalizedPlannedImpactPaths = normalizeTaskScopePaths(
    plannedImpactPaths ?? normalizedOwnedPaths,
  );
  const taskChecks = checkPlan?.task ?? [];
  const integrationChecks = checkPlan?.integration ?? [];
  const requiredEntrypoints = uniqueSorted(taskChecks.map((entry) => entry.entrypoint));
  const supportPaths = uniqueSorted([
    "tool",
    ...taskChecks.flatMap((entry) => entry.taskPaths ?? []),
    ...requiredEntrypoints.filter((entry) => !entry.startsWith("tool/")),
  ]);
  const common = {
    schema,
    taskId,
    mode,
    baseSha: sourceSha,
    checkIds: uniqueSorted(taskChecks.map((entry) => entry.id)),
    requiredEntrypoints,
    supportPaths,
    deferredCheckIds: uniqueSorted(integrationChecks.map((entry) => entry.id)),
    deferredRegressionIds: uniqueSorted(deferredRegressionIds),
    complete: sourceClean === true && blockers.length === 0,
    blockers: uniqueSorted([
      ...(sourceClean === true ? [] : ["source_worktree_not_clean"]),
      ...blockers,
    ]),
  };
  const payload = schema === TASK_INPUT_SCHEMA_V1
    ? {...common, scopePaths: normalizedOwnedPaths}
    : {
        ...common,
        ownedPaths: normalizedOwnedPaths,
        plannedImpactPaths: normalizedPlannedImpactPaths,
      };
  return {...payload, digest: digestTaskStart(payload)};
}

export function validateTaskStartContract({
  pack,
  manifest,
  taskId,
  baseSha,
  ownedPaths,
  plannedImpactPaths,
  selection,
  receiptOnly = false,
}) {
  const errors = [];
  let normalizedOwnedPaths = [];
  let normalizedPlannedImpactPaths = [];
  try {
    normalizedOwnedPaths = normalizeTaskScopePaths(ownedPaths);
    normalizedPlannedImpactPaths = normalizeTaskScopePaths(
      plannedImpactPaths ?? normalizedOwnedPaths,
    );
  } catch {
    errors.push("invalid_requested_scope");
  }
  const legacyPack = pack?.schema === CONTEXT_PACK_SCHEMA_V2;
  const currentPack = pack?.schema === CONTEXT_PACK_SCHEMA_V3;
  if (!legacyPack && !currentPack) errors.push("unsupported_context_pack_schema");
  if (pack?.task !== taskId) errors.push("context_pack_task_mismatch");
  if (pack?.sourceSha !== baseSha) errors.push("context_pack_base_mismatch");
  if (pack?.mode !== TASK_START_MODE || selection?.mode !== TASK_START_MODE) {
    errors.push("context_pack_task_mode_invalid");
  }
  if (!receiptOnly) {
    if (pack?.sourceClean !== true) errors.push("context_pack_source_not_clean");
    if (legacyPack && !sameStringArray(pack?.scope?.paths, normalizedOwnedPaths)) {
      errors.push("context_pack_envelope_scope_mismatch");
    }
    if (currentPack && !sameStringArray(pack?.scope?.ownedPaths, normalizedOwnedPaths)) {
      errors.push("context_pack_envelope_ownership_mismatch");
    }
    if (currentPack && !sameStringArray(
      pack?.scope?.plannedImpactPaths,
      normalizedPlannedImpactPaths,
    )) {
      errors.push("context_pack_envelope_impact_mismatch");
    }
  }
  const input = pack?.taskStart;
  const legacyInput = input?.schema === TASK_INPUT_SCHEMA_V1;
  const currentInput = input?.schema === TASK_INPUT_SCHEMA_V2;
  if (!legacyInput && !currentInput) errors.push("unsupported_task_input_schema");
  if (legacyPack !== legacyInput || currentPack !== currentInput) {
    errors.push("context_pack_task_input_schema_mismatch");
  }
  if (input?.taskId !== taskId) errors.push("context_pack_task_input_task_mismatch");
  if (input?.mode !== TASK_START_MODE) errors.push("context_pack_task_input_mode_invalid");
  if (input?.complete !== true) errors.push("context_pack_incomplete");
  const arrayFields = [
    ...(legacyInput ? ["scopePaths"] : ["ownedPaths", "plannedImpactPaths"]),
    "checkIds",
    "requiredEntrypoints",
    "supportPaths",
    "deferredCheckIds",
    "deferredRegressionIds",
    "blockers",
  ];
  for (const field of arrayFields) {
    if (!isUniqueStringArray(input?.[field])) errors.push(`invalid_task_input_${field}`);
  }
  if (legacyInput && !sameStringArray(input?.scopePaths, normalizedOwnedPaths)) {
    errors.push("context_pack_scope_mismatch");
  }
  if (currentInput && !sameStringArray(input?.ownedPaths, normalizedOwnedPaths)) {
    errors.push("context_pack_owned_paths_mismatch");
  }
  if (currentInput && !sameStringArray(input?.plannedImpactPaths, normalizedPlannedImpactPaths)) {
    errors.push("context_pack_planned_impact_paths_mismatch");
  }
  if (normalizedPlannedImpactPaths.length === 0) errors.push("planned_impact_empty");
  if (!normalizedPlannedImpactPaths.every((impactPath) => normalizedOwnedPaths.some(
    (ownedPath) => impactPath === ownedPath || impactPath.startsWith(`${ownedPath}/`),
  ))) errors.push("context_pack_planned_impact_outside_owned_scope");
  if (!safeStringArray(input?.deferredRegressionIds).every(
    (id) => typeof id === "string" && /^REG-[A-Z0-9-]+$/u.test(id),
  )) errors.push("invalid_deferred_regression_id");
  for (const field of [
    ...(legacyInput ? ["scopePaths"] : ["ownedPaths", "plannedImpactPaths"]),
    "requiredEntrypoints",
    "supportPaths",
  ]) {
    if (safeStringArray(input?.[field]).some((entry) => !isCanonicalTaskPath(entry))) {
      errors.push(`invalid_task_input_${field}`);
    }
  }
  if (typeof input?.digest !== "string" || !/^[0-9a-f]{64}$/u.test(input.digest)) {
    errors.push("invalid_task_input_digest");
  }

  let expected = null;
  let expectedPlan = null;
  try {
    if (!selection || !Array.isArray(selection.requests)) {
      throw new Error("Trusted task selection is unavailable.");
    }
    expectedPlan = resolveStructuredCheckPlan({manifest, requestedChecks: selection.requests});
    expected = buildTaskStartContract({
      taskId,
      mode: selection.mode,
      sourceSha: baseSha,
      ownedPaths: normalizedOwnedPaths,
      plannedImpactPaths: normalizedPlannedImpactPaths,
      checkPlan: expectedPlan,
      sourceClean: true,
      blockers: expectedPlan.blockers,
      deferredRegressionIds: selection.deferredRegressionIds,
      schema: input?.schema,
    });
  } catch {
    errors.push("context_pack_check_plan_invalid");
  }
  if (!receiptOnly && expectedPlan && !sameCheckPlanEnvelope(pack?.checkPlan, expectedPlan)) {
    errors.push("context_pack_envelope_check_plan_mismatch");
  }
  if (!receiptOnly && selection && !sameSelectedIds(
    pack?.skills,
    selection.matchedSkills,
    "skill_id",
  )) errors.push("context_pack_envelope_skills_mismatch");
  if (!receiptOnly && selection && !sameSelectedIds(
    pack?.regressionGuards,
    selection.matchedRegressions,
    "id",
  )) errors.push("context_pack_envelope_regressions_mismatch");
  if (expected && !sameTaskStart(input, expected)) errors.push("context_pack_closure_mismatch");
  if (input && typeof input === "object" && !Array.isArray(input) &&
      input.digest !== digestTaskStart(withoutDigest(input))) {
    errors.push("context_pack_digest_mismatch");
  }
  return {errors: [...new Set(errors)].sort(), expected};
}

export function digestTaskStart(value) {
  return createHash("sha256").update(stableStringify(value)).digest("hex");
}

function sameTaskStart(actual, expected) {
  if (actual == null) return false;
  return stableStringify(withoutDigest(actual)) === stableStringify(withoutDigest(expected)) &&
    actual.digest === expected.digest;
}

function withoutDigest(value) {
  if (value == null || typeof value !== "object" || Array.isArray(value)) return value;
  const {digest: _digest, ...rest} = value;
  return rest;
}

function stableStringify(value) {
  return JSON.stringify(sortValue(value));
}

function sortValue(value) {
  if (Array.isArray(value)) return value.map(sortValue);
  if (value == null || typeof value !== "object") return value;
  return Object.fromEntries(
    Object.keys(value).sort().map((key) => [key, sortValue(value[key])]),
  );
}

function sameStringArray(left, right) {
  return isUniqueStringArray(left) && isUniqueStringArray(right) &&
    JSON.stringify([...left].sort()) === JSON.stringify([...right].sort());
}

function sameCheckPlanEnvelope(actual, expected) {
  if (!isCheckPlan(actual)) return false;
  return stableStringify(projectCheckPlan(actual)) === stableStringify(projectCheckPlan(expected));
}

function projectCheckPlan(plan) {
  const project = (entry) => ({
    id: entry.id,
    repositoryView: entry.repositoryView,
    entrypoint: entry.entrypoint,
    taskPaths: [...(entry.taskPaths ?? [])].sort(),
  });
  return {
    task: plan.task.map(project),
    integration: plan.integration.map(project),
    blockers: [...plan.blockers].sort(),
  };
}

function isCheckPlan(value) {
  if (value == null || typeof value !== "object" || Array.isArray(value)) return false;
  if (!Array.isArray(value.task) || !Array.isArray(value.integration) ||
      !isUniqueStringArray(value.blockers)) return false;
  return [...value.task, ...value.integration].every((entry) =>
    entry != null && typeof entry === "object" && !Array.isArray(entry) &&
    typeof entry.id === "string" && entry.id !== "" &&
    ["index", "full"].includes(entry.repositoryView) &&
    isCanonicalTaskPath(entry.entrypoint) &&
    isUniqueStringArray(entry.taskPaths) && entry.taskPaths.every(isCanonicalTaskPath) &&
    isUniqueStringArray(entry.sources));
}

function isUniqueStringArray(value) {
  return Array.isArray(value) && value.every((entry) => typeof entry === "string" && entry !== "") &&
    new Set(value).size === value.length;
}

function safeStringArray(value) {
  return Array.isArray(value) ? value.filter((entry) => typeof entry === "string") : [];
}

function sameSelectedIds(actual, expected, key) {
  if (!Array.isArray(actual) || !Array.isArray(expected)) return false;
  const actualIds = actual.map((entry) => entry?.[key]);
  const expectedIds = expected.map((entry) => entry?.[key]);
  return isUniqueStringArray(actualIds) && isUniqueStringArray(expectedIds) &&
    JSON.stringify([...actualIds].sort()) === JSON.stringify([...expectedIds].sort());
}

function addStructuredCheck(requests, id, source) {
  const sources = requests.get(id) ?? new Set();
  sources.add(source);
  requests.set(id, sources);
}

function matchesPattern(candidate, pattern) {
  if (!candidate || !pattern) return false;
  const normalizedCandidate = candidate.replace(/^\.\//u, "");
  const normalizedPattern = pattern.replace(/^\.\//u, "");
  if (normalizedPattern === normalizedCandidate) return true;
  if (normalizedPattern.endsWith("/**") && !normalizedPattern.slice(0, -3).includes("*")) {
    const prefix = normalizedPattern.slice(0, -3);
    return normalizedCandidate === prefix || normalizedCandidate.startsWith(`${prefix}/`);
  }
  if (!normalizedPattern.includes("*")) {
    return normalizedCandidate.startsWith(`${normalizedPattern}/`);
  }
  const globPattern = escapeRegex(normalizedPattern)
    .replaceAll("**", "__DOUBLE_STAR__")
    .replaceAll("*", "[^/]*")
    .replaceAll("__DOUBLE_STAR__", ".*");
  return new RegExp(`^${globPattern}$`, "u").test(normalizedCandidate);
}

function escapeRegex(value) {
  return value.replace(/[.+?^${}()|[\]\\]/gu, "\\$&");
}

function uniqueSorted(values) {
  return [...new Set((values ?? []).filter((value) => typeof value === "string" && value !== ""))].sort();
}
