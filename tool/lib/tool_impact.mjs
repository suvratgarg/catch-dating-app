import {matchesGlob, planAffected} from "../harness/lib/component_graph.mjs";

export function planAffectedToolChecks({
  changedPaths,
  manifest,
  componentGraph,
  mode = "pr",
  full = false,
}) {
  const paths = [...new Set(changedPaths)].sort();
  const activeTools = manifest.tools.filter(
    (tool) => tool.status === "active" && hasExecutableChecks(tool),
  );
  const activeById = new Map(activeTools.map((tool) => [tool.id, tool]));
  const fullPaths = [
    ...canonicalHarnessFullPaths(componentGraph),
    ...(manifest.ciImpact?.additionalFullPaths ?? []),
  ];
  const fullReasons = [];
  const toolLanePaths = [];
  const ignoredPaths = [];

  for (const changedPath of paths) {
    const pathPlan = planAffected({
      changedPaths: [changedPath],
      graph: componentGraph,
      mode,
    });
    if (!pathPlan.complete) {
      fullReasons.push(`incomplete Harness ownership: ${changedPath}`);
    } else if (pathPlan.operations.ciTargets.includes("tools")) {
      toolLanePaths.push(changedPath);
    } else {
      ignoredPaths.push(changedPath);
    }
  }

  if (full) fullReasons.push("full execution was explicitly requested");
  if (!full && toolLanePaths.length === 0) {
    fullReasons.push("no changed path is owned by the Tools lane");
  }
  for (const changedPath of paths) {
    if (fullPaths.some((pattern) => matchesGlob(changedPath, pattern))) {
      fullReasons.push(`control-plane path changed: ${changedPath}`);
    }
  }

  const ownersByPath = {};
  const unmappedPaths = [];
  const selectedIds = new Set(manifest.ciImpact?.mandatoryCheckIds ?? []);
  for (const changedPath of toolLanePaths) {
    const owners = activeTools.filter((tool) =>
      tool.path === changedPath ||
      (tool.impactPaths ?? []).some((pattern) => matchesGlob(changedPath, pattern))
    );
    if (owners.length > 0) {
      ownersByPath[changedPath] = owners.map((tool) => tool.id).sort();
      for (const owner of owners) selectedIds.add(owner.id);
    } else if (!fullPaths.some((pattern) => matchesGlob(changedPath, pattern))) {
      unmappedPaths.push(changedPath);
    }
  }

  if (unmappedPaths.length > 0) {
    fullReasons.push(
      `unmapped affected path(s): ${unmappedPaths.join(", ")}`,
    );
  }

  if (fullReasons.length > 0) {
    return {
      schemaVersion: 1,
      harnessMode: mode,
      mode: "full",
      full: true,
      complete: true,
      changedPaths: paths,
      toolLanePaths,
      ignoredPaths,
      toolIds: [],
      ownersByPath,
      unmappedPaths,
      fullReasons: [...new Set(fullReasons)].sort(),
    };
  }

  const pending = [...selectedIds];
  while (pending.length > 0) {
    const id = pending.shift();
    const tool = activeById.get(id);
    if (!tool) {
      throw new Error(`Affected-tool plan references inactive or unknown tool id: ${id}`);
    }
    for (const dependencyId of tool.alsoCheckIds ?? []) {
      if (selectedIds.has(dependencyId)) continue;
      selectedIds.add(dependencyId);
      pending.push(dependencyId);
    }
  }

  return {
    schemaVersion: 1,
    harnessMode: mode,
    mode: "affected",
    full: false,
    complete: true,
    changedPaths: paths,
    toolLanePaths,
    ignoredPaths,
    toolIds: [...selectedIds].sort(),
    ownersByPath,
    unmappedPaths: [],
    fullReasons: [],
  };
}

export function canonicalHarnessFullPaths(componentGraph) {
  const harness = componentGraph?.components?.find(
    (component) => component.id === "repo.harness",
  );
  const patterns = harness?.ownedPaths?.include;
  if (!Array.isArray(patterns) || patterns.length === 0) {
    throw new Error(
      "Component graph must declare non-empty repo.harness ownedPaths.include.",
    );
  }
  return [...patterns];
}

export function duplicateCanonicalFullPathOverrides({manifest, componentGraph}) {
  const canonical = canonicalHarnessFullPaths(componentGraph);
  return (manifest.ciImpact?.additionalFullPaths ?? []).filter(
    (pattern) => canonical.includes(pattern),
  );
}

export function hasExecutableChecks(tool) {
  return Array.isArray(tool.checks) &&
    tool.checks.length > 0 &&
    tool.checks.every(
      (check) => typeof check === "string" && check.trim().length > 0,
    );
}

export function formatAffectedToolGithubOutputs(plan) {
  if (plan.complete !== true || !["affected", "full"].includes(plan.mode)) {
    throw new Error("Refusing to project outputs from an incomplete affected-tool plan.");
  }
  return [
    `tool_mode=${plan.mode}`,
    `affected=${plan.mode === "affected"}`,
    `full=${plan.mode === "full"}`,
  ].map((line) => `${line}\n`).join("");
}
