import {matchesGlob, planAffected} from "../harness/lib/component_graph.mjs";

export const supportedToolSetupRequirements = Object.freeze([
  "node",
  "flutter",
  "ripgrep",
  "flutter-pub",
  "root-npm",
  "functions-npm",
  "playwright",
]);

export const supportedToolCheckSafety = Object.freeze([
  "local-readonly",
]);

const supportedRepositoryViews = new Set(["full", "index"]);
const supportedSetupRequirements = new Set(supportedToolSetupRequirements);
const supportedCheckSafety = new Set(supportedToolCheckSafety);
const fullCiRequirements = Object.freeze({
  repositoryView: "full",
  setup: supportedToolSetupRequirements,
});

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
      schemaVersion: 2,
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
      repositoryView: fullCiRequirements.repositoryView,
      setupRequirements: [...fullCiRequirements.setup],
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

  const toolIds = [...selectedIds].sort();
  const requirements = projectToolCiRequirements(
    toolIds.map((id) => activeById.get(id)),
  );

  return {
    schemaVersion: 2,
    harnessMode: mode,
    mode: "affected",
    full: false,
    complete: true,
    changedPaths: paths,
    toolLanePaths,
    ignoredPaths,
    toolIds,
    ownersByPath,
    unmappedPaths: [],
    fullReasons: [],
    repositoryView: requirements.repositoryView,
    setupRequirements: requirements.setup,
  };
}

export function validateToolCiRequirements(tool) {
  if (!Object.hasOwn(tool ?? {}, "ciRequirements")) return [];
  const requirements = tool.ciRequirements;
  const errors = [];
  if (
    requirements == null ||
    typeof requirements !== "object" ||
    Array.isArray(requirements)
  ) {
    return ["ciRequirements must be an object when present."];
  }
  const unknownKeys = Object.keys(requirements).filter(
    (key) => !["repositoryView", "setup"].includes(key),
  );
  if (unknownKeys.length > 0) {
    errors.push(`ciRequirements has unknown fields: ${unknownKeys.sort().join(", ")}.`);
  }
  if (!supportedRepositoryViews.has(requirements.repositoryView)) {
    errors.push("ciRequirements.repositoryView must be full or index.");
  }
  if (
    !Array.isArray(requirements.setup) ||
    requirements.setup.length === 0 ||
    requirements.setup.some((entry) => typeof entry !== "string" || entry === "")
  ) {
    errors.push("ciRequirements.setup must be a non-empty string array.");
    return errors;
  }
  if (new Set(requirements.setup).size !== requirements.setup.length) {
    errors.push("ciRequirements.setup must not contain duplicates.");
  }
  const unknownSetup = requirements.setup.filter(
    (entry) => !supportedSetupRequirements.has(entry),
  );
  if (unknownSetup.length > 0) {
    errors.push(
      `ciRequirements.setup has unknown requirements: ${[...new Set(unknownSetup)].sort().join(", ")}.`,
    );
  }
  if (!requirements.setup.includes("node")) {
    errors.push("ciRequirements.setup must include node.");
  }
  if (
    requirements.setup.includes("flutter-pub") &&
    !requirements.setup.includes("flutter")
  ) {
    errors.push("ciRequirements.setup flutter-pub requires flutter.");
  }
  if (
    requirements.setup.includes("playwright") &&
    !requirements.setup.includes("root-npm")
  ) {
    errors.push("ciRequirements.setup playwright requires root-npm.");
  }
  return errors;
}

export function validateToolCheckSafety(tool) {
  if (!Object.hasOwn(tool ?? {}, "checkSafety")) return [];
  const errors = [];
  if (!supportedCheckSafety.has(tool.checkSafety)) {
    errors.push(
      `checkSafety must be one of ${supportedToolCheckSafety.join(", ")}.`,
    );
  }
  if (!hasExecutableChecks(tool)) {
    errors.push("checkSafety requires non-empty executable checks.");
  }
  if (isLocalOnlySafety(tool?.safety)) {
    errors.push(
      "checkSafety must be omitted when safety already declares local-only behavior.",
    );
  }
  return errors;
}

export function toolChecksAreLocalReadonly(tool) {
  if (Object.hasOwn(tool ?? {}, "checkSafety")) {
    return supportedCheckSafety.has(tool.checkSafety);
  }
  return isLocalOnlySafety(tool?.safety);
}

export function collectLocalReadonlyCheckIds(toolsManifest) {
  const tools = Array.isArray(toolsManifest?.tools) ? toolsManifest.tools : [];
  const counts = new Map();
  for (const tool of tools) counts.set(tool?.id, (counts.get(tool?.id) ?? 0) + 1);
  return new Set(tools
    .filter((tool) =>
      counts.get(tool.id) === 1 &&
      tool.status === "active" &&
      hasExecutableChecks(tool) &&
      toolChecksAreLocalReadonly(tool) &&
      validateToolCiRequirements(tool).length === 0)
    .map((tool) => tool.id));
}

function isLocalOnlySafety(safety) {
  return typeof safety === "string" &&
    safety.startsWith("local") &&
    !safety.includes("remote");
}

export function projectToolCiRequirements(tools) {
  if (tools.length === 0) {
    return {
      repositoryView: fullCiRequirements.repositoryView,
      setup: [...fullCiRequirements.setup],
    };
  }
  const requirements = tools.map((tool) => resolveToolCiRequirements(tool));
  return {
    repositoryView: requirements.every(
      (entry) => entry.repositoryView === "index",
    ) ? "index" : "full",
    setup: supportedToolSetupRequirements.filter((requirement) =>
      requirements.some((entry) => entry.setup.includes(requirement))
    ),
  };
}

function resolveToolCiRequirements(tool) {
  if (!Object.hasOwn(tool ?? {}, "ciRequirements")) return fullCiRequirements;
  const errors = validateToolCiRequirements(tool);
  if (errors.length > 0) {
    throw new Error(`${tool?.id ?? "<unknown tool>"}: ${errors.join(" ")}`);
  }
  return tool.ciRequirements;
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
  const requirementErrors = validateToolCiRequirements({
    ciRequirements: {
      repositoryView: plan.repositoryView,
      setup: plan.setupRequirements,
    },
  });
  const canonicalSetup = Array.isArray(plan.setupRequirements)
    ? supportedToolSetupRequirements.filter((requirement) =>
      plan.setupRequirements.includes(requirement)
    )
    : [];
  const nonCanonicalSetup =
    !Array.isArray(plan.setupRequirements) ||
    canonicalSetup.length !== plan.setupRequirements.length ||
    canonicalSetup.some(
      (requirement, index) => requirement !== plan.setupRequirements[index],
    );
  const incompleteFullPlan = plan.mode === "full" && (
    plan.repositoryView !== fullCiRequirements.repositoryView ||
    canonicalSetup.length !== supportedToolSetupRequirements.length
  );
  if (
    requirementErrors.length > 0 ||
    nonCanonicalSetup ||
    incompleteFullPlan
  ) {
    throw new Error("Refusing to project invalid affected-tool CI requirements.");
  }
  return [
    `tool_mode=${plan.mode}`,
    `affected=${plan.mode === "affected"}`,
    `full=${plan.mode === "full"}`,
    `repository_view=${plan.repositoryView}`,
    `setup_requirements=${JSON.stringify(plan.setupRequirements)}`,
  ].map((line) => `${line}\n`).join("");
}
