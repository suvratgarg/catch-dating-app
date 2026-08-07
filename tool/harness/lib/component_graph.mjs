const operationKeys = [
  "ciTargets",
  "checkIds",
  "codegenIds",
  "buildTargets",
  "releaseTargets",
  "deployGroups",
  "releaseRoles",
];
const signedMobileReleaseTargets = new Set([
  "consumer-android",
  "consumer-ios",
  "host-android",
  "host-ios",
]);
const ciCheckoutKeys = ["planner", "default", "targetOverrides"];
const checkoutRequirementKeys = [
  "mode",
  "fetchDepth",
  "coneMode",
  "timeoutMinutes",
  "paths",
];

export function matchesGlob(value, pattern) {
  const normalizedValue = normalizePath(value);
  const normalizedPattern = normalizePath(pattern);
  const doubleStar = "\u0000";
  const escaped = normalizedPattern
    .replace(/[.+^${}()|[\]\\]/g, "\\$&")
    .replaceAll("**", doubleStar)
    .replaceAll("*", "[^/]*")
    .replaceAll("?", "[^/]")
    .replaceAll(doubleStar, ".*");
  return new RegExp(`^${escaped}$`).test(normalizedValue);
}

export function validateComponentGraph(graph, {knownCheckIds} = {}) {
  const errors = [];
  if (!graph || typeof graph !== "object" || Array.isArray(graph)) {
    return ["Component graph must be a JSON object."];
  }

  const modes = uniqueStringSet(graph.modes, "modes", errors, {required: true});
  const targets = uniqueStringSet(graph.targets, "targets", errors, {required: true});
  const profiles = graph.operationProfiles;
  const components = Array.isArray(graph.components) ? graph.components : [];
  const classifications = Array.isArray(graph.classifications)
    ? graph.classifications
    : [];
  const generators = Array.isArray(graph.compileCodegen) ? graph.compileCodegen : [];
  const deployGroupRequirements = validateDeployGroupRequirements(
    graph.deployGroupRequirements,
    targets,
    errors,
  );

  validateCiCheckout(graph.ciCheckout, targets, errors);

  if (!profiles || typeof profiles !== "object" || Array.isArray(profiles)) {
    errors.push("operationProfiles must be an object.");
  }
  if (!Array.isArray(graph.components) || components.length === 0) {
    errors.push("components must be a non-empty array.");
  }
  if (!Array.isArray(graph.classifications)) {
    errors.push("classifications must be an array.");
  }
  if (!Array.isArray(graph.compileCodegen)) {
    errors.push("compileCodegen must be an array.");
  }

  const componentIds = collectUniqueIds(components, "component", errors);
  const classificationIds = collectUniqueIds(
    classifications,
    "classification",
    errors,
  );
  const generatorIds = collectUniqueIds(generators, "compileCodegen entry", errors);
  void classificationIds;

  for (const [profileId, profile] of Object.entries(profiles ?? {})) {
    if (!profile || typeof profile !== "object" || Array.isArray(profile)) {
      errors.push(`Operation profile ${profileId} must be an object.`);
      continue;
    }
    for (const relationship of ["direct", "affected"]) {
      const modeOperations = profile[relationship];
      if (!modeOperations || typeof modeOperations !== "object" || Array.isArray(modeOperations)) {
        errors.push(`${profileId}.${relationship} must be an object.`);
        continue;
      }
      for (const [mode, operation] of Object.entries(modeOperations)) {
        if (!modes.has(mode)) {
          errors.push(`${profileId}.${relationship} uses unknown mode "${mode}".`);
        }
        validateOperation({
          operation,
          location: `${profileId}.${relationship}.${mode}`,
          relationship,
          mode,
          targets,
          generatorIds,
          deployGroupRequirements,
          knownCheckIds,
          errors,
        });
      }
    }
  }

  const referencedProfiles = new Set();
  for (const component of components) {
    if (!component || typeof component !== "object" || Array.isArray(component)) continue;
    const location = component.id ?? "<missing component>";
    if (!component.owner) errors.push(`${location} must declare owner.`);
    if (!["low", "standard", "high"].includes(component.risk)) {
      errors.push(`${location} has invalid risk "${component.risk}".`);
    }
    if (!["terminal", "component", "consumer"].includes(component.pathType)) {
      errors.push(`${location} has invalid pathType "${component.pathType}".`);
    }
    if (!Object.hasOwn(profiles ?? {}, component.operationProfile)) {
      errors.push(`${location} references unknown operation profile "${component.operationProfile}".`);
    } else {
      referencedProfiles.add(component.operationProfile);
    }
    validateReferences(component.dependsOn, `${location}.dependsOn`, componentIds, errors);
    validateReferences(component.alsoAffects, `${location}.alsoAffects`, componentIds, errors);
    if (component.pathType === "component") {
      validatePathSet(component.ownedPaths, `${location}.ownedPaths`, errors);
    } else if (component.ownedPaths !== undefined) {
      errors.push(`${location} is ${component.pathType} and must not own paths.`);
    }
  }

  for (const profileId of Object.keys(profiles ?? {})) {
    if (!referencedProfiles.has(profileId)) {
      errors.push(`Operation profile "${profileId}" is not used by any component.`);
    }
  }

  const classifiedTerminalComponents = new Set();
  for (const classification of classifications) {
    if (!classification || typeof classification !== "object" || Array.isArray(classification)) {
      continue;
    }
    const location = classification.id ?? "<missing classification>";
    validatePathSet(classification.paths, `${location}.paths`, errors);
    if (classification.terminal !== true) {
      errors.push(`${location}.terminal must be true.`);
    }
    const references = uniqueStringSet(
      classification.components,
      `${location}.components`,
      errors,
      {required: true},
    );
    if (references.size !== 1) {
      errors.push(`${location} must resolve to exactly one terminal component.`);
    }
    for (const componentId of references) {
      if (!componentIds.has(componentId)) {
        errors.push(`${location} references unknown component "${componentId}".`);
        continue;
      }
      const component = components.find((candidate) => candidate.id === componentId);
      if (component?.pathType !== "terminal") {
        errors.push(`${location} references non-terminal component "${componentId}".`);
      } else {
        classifiedTerminalComponents.add(componentId);
      }
    }
  }

  for (const component of components) {
    if (component?.pathType === "terminal" && !classifiedTerminalComponents.has(component.id)) {
      errors.push(`Terminal component "${component.id}" has no classification.`);
    }
  }

  for (const generator of generators) {
    validateCodegen(generator, errors);
  }
  errors.push(...findPropagationCycles(components));
  return [...new Set(errors)];
}

export function resolveTargetCheckout({graph, target}) {
  const errors = [];
  const targets = uniqueStringSet(graph?.targets, "targets", errors, {required: true});
  validateCiCheckout(graph?.ciCheckout, targets, errors);
  if (!targets.has(target)) {
    errors.push(`Cannot resolve checkout for unknown CI target "${target}".`);
  }
  if (errors.length > 0) throw new Error([...new Set(errors)].join("\n"));
  const requirement = graph.ciCheckout.targetOverrides[target] ??
    graph.ciCheckout.default;
  return cloneCheckoutRequirement(requirement);
}

export function classifyPaths({changedPaths, graph}) {
  const componentById = new Map(graph.components.map((component) => [component.id, component]));
  const directComponents = new Set();
  const pathMatches = {};
  const unknownPaths = [];
  const ambiguousPaths = [];

  for (const changedPath of [...new Set(changedPaths.map(normalizePath))].sort()) {
    const classifications = graph.classifications.filter((classification) =>
      matchesPathSet(changedPath, classification.paths)
    );
    if (classifications.length > 1) {
      ambiguousPaths.push({
        path: changedPath,
        kind: "classification",
        matches: classifications.map((classification) => classification.id).sort(),
      });
      continue;
    }
    if (classifications.length === 1) {
      const classification = classifications[0];
      const components = [...classification.components].sort();
      for (const component of components) directComponents.add(component);
      pathMatches[changedPath] = {
        kind: "classification",
        owner: classification.id,
        components,
      };
      continue;
    }

    const owners = graph.components.filter((component) =>
      component.pathType === "component" &&
      matchesPathSet(changedPath, component.ownedPaths)
    );
    if (owners.length === 0) {
      unknownPaths.push(changedPath);
      continue;
    }
    if (owners.length > 1) {
      ambiguousPaths.push({
        path: changedPath,
        kind: "component",
        matches: owners.map((component) => component.id).sort(),
      });
      continue;
    }
    const owner = owners[0];
    if (!componentById.has(owner.id)) {
      unknownPaths.push(changedPath);
      continue;
    }
    directComponents.add(owner.id);
    pathMatches[changedPath] = {
      kind: "component",
      owner: owner.id,
      components: [owner.id],
    };
  }

  return {
    pathMatches,
    directComponents: [...directComponents].sort(),
    unknownPaths,
    ambiguousPaths,
  };
}

export function summarizeCoverage({paths, graph, sampleLimit = 25}) {
  const classification = classifyPaths({changedPaths: paths, graph});
  const totalPaths = [...new Set(paths.map(normalizePath))].length;
  const mappedPaths = Object.keys(classification.pathMatches).length;
  const unknownByRoot = {};
  for (const unknownPath of classification.unknownPaths) {
    const root = unknownPath.includes("/") ? unknownPath.split("/")[0] : "<root>";
    unknownByRoot[root] = (unknownByRoot[root] ?? 0) + 1;
  }
  return {
    totalPaths,
    mappedPaths,
    unknownPathCount: classification.unknownPaths.length,
    ambiguousPathCount: classification.ambiguousPaths.length,
    coveragePercent: totalPaths === 0
      ? 100
      : Number(((mappedPaths / totalPaths) * 100).toFixed(1)),
    unknownByRoot: Object.fromEntries(
      Object.entries(unknownByRoot).sort((left, right) =>
        right[1] - left[1] || left[0].localeCompare(right[0])
      ),
    ),
    unknownPathSample: classification.unknownPaths.slice(0, sampleLimit),
    ambiguousPathSample: classification.ambiguousPaths.slice(0, sampleLimit),
  };
}

export function planAffected({changedPaths, graph, mode = "pr", full = false}) {
  const validationErrors = validateComponentGraph(graph);
  if (validationErrors.length > 0) throw new Error(validationErrors.join("\n"));
  if (!graph.modes.includes(mode)) throw new Error(`Unknown harness mode "${mode}".`);
  if (full && mode !== "nightly") {
    throw new Error("Full component selection is validation-only and requires nightly mode.");
  }

  const classification = full
    ? {
        pathMatches: {},
        directComponents: graph.components.map((component) => component.id).sort(),
        unknownPaths: [],
        ambiguousPaths: [],
      }
    : classifyPaths({changedPaths, graph});
  const componentById = new Map(graph.components.map((component) => [component.id, component]));
  const direct = new Set(classification.directComponents);
  const selected = new Set(direct);
  const dependents = buildDependents(graph.components);
  const explanationEdges = [];
  const seenEdges = new Set();
  const queue = [...direct].sort();

  while (queue.length > 0) {
    const source = queue.shift();
    const component = componentById.get(source);
    const edges = [
      ...(dependents.get(source) ?? []).map((target) => ({target, kind: "dependsOn"})),
      ...(component.alsoAffects ?? []).map((target) => ({target, kind: "alsoAffects"})),
    ].sort((left, right) =>
      left.target.localeCompare(right.target) || left.kind.localeCompare(right.kind)
    );
    for (const edge of edges) {
      const key = `${source}\u0000${edge.target}\u0000${edge.kind}`;
      if (!seenEdges.has(key)) {
        seenEdges.add(key);
        explanationEdges.push({from: source, to: edge.target, kind: edge.kind});
      }
      if (selected.has(edge.target)) continue;
      selected.add(edge.target);
      queue.push(edge.target);
      queue.sort();
    }
  }

  const operations = Object.fromEntries(operationKeys.map((key) => [key, []]));
  const operationSources = Object.fromEntries(operationKeys.map((key) => [key, []]));
  for (const componentId of [...selected].sort()) {
    const component = componentById.get(componentId);
    const relationship = direct.has(componentId) ? "direct" : "affected";
    const profile = graph.operationProfiles[component.operationProfile];
    const operation = profile[relationship][mode] ?? {};
    for (const key of operationKeys) {
      for (const value of operation[key] ?? []) {
        if (!operations[key].includes(value)) operations[key].push(value);
        operationSources[key].push({component: componentId, relationship, value});
      }
    }
  }
  const normalizedChangedPaths = [...new Set(changedPaths.map(normalizePath))].sort();
  for (const entry of graph.compileCodegen) {
    const matchedPath = full
      ? "<nightly-full>"
      : normalizedChangedPaths.find((changedPath) =>
          [...entry.inputs, ...entry.outputs].some((pattern) =>
            matchesGlob(changedPath, pattern)
          )
        );
    if (!matchedPath) continue;
    if (!operations.codegenIds.includes(entry.id)) operations.codegenIds.push(entry.id);
    operationSources.codegenIds.push({
      component: `compile-codegen:${entry.owner}`,
      relationship: "input-output",
      value: entry.id,
      path: matchedPath,
    });
  }
  for (const values of Object.values(operations)) values.sort();
  for (const values of Object.values(operationSources)) {
    values.sort((left, right) =>
      left.value.localeCompare(right.value) || left.component.localeCompare(right.component)
    );
  }

  const affectedComponents = [...selected].filter((componentId) => !direct.has(componentId)).sort();
  const highRiskDirectComponents = [...direct]
    .filter((componentId) => componentById.get(componentId).risk === "high")
    .sort();

  return {
    schemaVersion: graph.version,
    graphStatus: graph.status,
    mode,
    full,
    changedPaths: normalizedChangedPaths,
    pathMatches: classification.pathMatches,
    directComponents: [...direct].sort(),
    affectedComponents,
    selectedComponents: [...selected].sort(),
    explanationEdges,
    operations,
    operationSources,
    highRiskDirectComponents,
    unknownPaths: classification.unknownPaths,
    ambiguousPaths: classification.ambiguousPaths,
    complete: classification.unknownPaths.length === 0 &&
      classification.ambiguousPaths.length === 0,
  };
}

export function deriveAppRoles(plan) {
  const roles = new Set(plan.operations.releaseRoles ?? []);
  for (const target of [
    ...(plan.operations.buildTargets ?? []),
    ...(plan.operations.releaseTargets ?? []),
  ]) {
    if (target.startsWith("consumer-")) roles.add("consumer");
    if (target.startsWith("host-")) roles.add("host");
  }
  const selectsPlatformBuild = (plan.operations.ciTargets ?? []).some((target) =>
    [
      "flutter_build_android",
      "flutter_build_ios",
      "flutter_build_web",
      "flutter_web_smoke",
    ].includes(target)
  );
  if (roles.size === 0 && selectsPlatformBuild) {
    roles.add("consumer");
    roles.add("host");
  }
  return [...roles].sort();
}

function validateOperation({
  operation,
  location,
  relationship,
  mode,
  targets,
  generatorIds,
  deployGroupRequirements,
  knownCheckIds,
  errors,
}) {
  if (!operation || typeof operation !== "object" || Array.isArray(operation)) {
    errors.push(`${location} must be an object.`);
    return;
  }
  for (const key of Object.keys(operation)) {
    if (!operationKeys.includes(key)) errors.push(`${location} uses unknown key "${key}".`);
  }
  for (const key of operationKeys) {
    uniqueStringSet(operation[key], `${location}.${key}`, errors);
  }
  for (const target of operation.ciTargets ?? []) {
    if (!targets.has(target)) errors.push(`${location} references unknown CI target "${target}".`);
  }
  for (const generatorId of operation.codegenIds ?? []) {
    if (!generatorIds.has(generatorId)) {
      errors.push(`${location} references unknown compile-codegen id "${generatorId}".`);
    }
  }
  for (const checkId of operation.checkIds ?? []) {
    if (knownCheckIds && !knownCheckIds.has(checkId)) {
      errors.push(`${location} references unknown tool check id "${checkId}".`);
    }
  }
  for (const role of operation.releaseRoles ?? []) {
    if (!["consumer", "host"].includes(role)) {
      errors.push(`${location} references unknown release role "${role}".`);
    }
  }
  const declaredReleaseRoles = new Set(operation.releaseRoles ?? []);
  const impliedReleaseRoles = new Set();
  for (const releaseTarget of operation.releaseTargets ?? []) {
    if (!signedMobileReleaseTargets.has(releaseTarget)) {
      errors.push(`${location} references unknown signed mobile release target "${releaseTarget}".`);
      continue;
    }
    const [role, platform] = releaseTarget.split("-");
    impliedReleaseRoles.add(role);
    if (mode === "main" && !(operation.ciTargets ?? []).includes(`flutter_build_${platform}`)) {
      errors.push(
        `${location} release target "${releaseTarget}" requires CI target "flutter_build_${platform}".`,
      );
    }
    if (mode === "release" && !(operation.buildTargets ?? []).includes(releaseTarget)) {
      errors.push(
        `${location} release target "${releaseTarget}" requires matching build target "${releaseTarget}".`,
      );
    }
  }
  if ((operation.releaseTargets ?? []).length > 0 && !["main", "release"].includes(mode)) {
    errors.push(`${location} can authorize signed mobile release only in main or release mode.`);
  }
  if (declaredReleaseRoles.size > 0 && impliedReleaseRoles.size === 0) {
    errors.push(`${location}.releaseRoles must be backed by exact releaseTargets.`);
  }
  if (
    declaredReleaseRoles.size !== impliedReleaseRoles.size ||
    [...declaredReleaseRoles].some((role) => !impliedReleaseRoles.has(role))
  ) {
    errors.push(`${location}.releaseRoles must exactly match roles implied by releaseTargets.`);
  }
  const selectedTargets = new Set(operation.ciTargets ?? []);
  for (const deployGroup of operation.deployGroups ?? []) {
    const requiredTargets = deployGroupRequirements.get(deployGroup);
    if (!requiredTargets) {
      errors.push(`${location} references unknown deploy group "${deployGroup}".`);
      continue;
    }
    if (mode === "main") {
      for (const requiredTarget of requiredTargets) {
        if (!selectedTargets.has(requiredTarget)) {
          errors.push(
            `${location} deploy group "${deployGroup}" requires CI target "${requiredTarget}".`,
          );
        }
      }
    }
  }
  if (relationship === "affected") {
    if ((operation.deployGroups ?? []).length > 0) {
      errors.push(`${location} cannot authorize deployment from an affected edge.`);
    }
    if ((operation.releaseRoles ?? []).length > 0) {
      errors.push(`${location} cannot authorize release from an affected edge.`);
    }
    if ((operation.releaseTargets ?? []).length > 0) {
      errors.push(`${location} cannot authorize signed mobile release from an affected edge.`);
    }
  }
}

function validateDeployGroupRequirements(value, targets, errors) {
  const result = new Map();
  if (!value || typeof value !== "object" || Array.isArray(value)) {
    errors.push("deployGroupRequirements must be an object.");
    return result;
  }
  for (const [deployGroup, requiredTargets] of Object.entries(value)) {
    if (!deployGroup) {
      errors.push("deployGroupRequirements uses an empty deploy group id.");
      continue;
    }
    const validatedTargets = uniqueStringSet(
      requiredTargets,
      `deployGroupRequirements.${deployGroup}`,
      errors,
      {required: true},
    );
    for (const target of validatedTargets) {
      if (!targets.has(target)) {
        errors.push(
          `deployGroupRequirements.${deployGroup} references unknown CI target "${target}".`,
        );
      }
    }
    result.set(deployGroup, validatedTargets);
  }
  return result;
}

function validateCiCheckout(ciCheckout, targets, errors) {
  if (!ciCheckout || typeof ciCheckout !== "object" || Array.isArray(ciCheckout)) {
    errors.push("ciCheckout must be an object.");
    return;
  }
  for (const key of Object.keys(ciCheckout)) {
    if (!ciCheckoutKeys.includes(key)) errors.push(`ciCheckout uses unknown key "${key}".`);
  }
  validateCheckoutRequirement(ciCheckout.planner, "ciCheckout.planner", errors);
  validateCheckoutRequirement(ciCheckout.default, "ciCheckout.default", errors);
  if (ciCheckout.default?.mode !== "full") {
    errors.push("ciCheckout.default.mode must be \"full\" so undeclared targets widen safely.");
  }
  const overrides = ciCheckout.targetOverrides;
  if (!overrides || typeof overrides !== "object" || Array.isArray(overrides)) {
    errors.push("ciCheckout.targetOverrides must be an object.");
    return;
  }
  for (const [target, requirement] of Object.entries(overrides)) {
    if (!targets.has(target)) {
      errors.push(`ciCheckout.targetOverrides references unknown CI target "${target}".`);
    }
    validateCheckoutRequirement(
      requirement,
      `ciCheckout.targetOverrides.${target}`,
      errors,
    );
  }
}

function validateCheckoutRequirement(requirement, location, errors) {
  if (!requirement || typeof requirement !== "object" || Array.isArray(requirement)) {
    errors.push(`${location} must be an object.`);
    return;
  }
  for (const key of Object.keys(requirement)) {
    if (!checkoutRequirementKeys.includes(key)) {
      errors.push(`${location} uses unknown key "${key}".`);
    }
  }
  if (!["full", "sparse"].includes(requirement.mode)) {
    errors.push(`${location}.mode must be "full" or "sparse".`);
  }
  if (
    !Number.isInteger(requirement.fetchDepth) ||
    requirement.fetchDepth < 0 ||
    requirement.fetchDepth > 1000
  ) {
    errors.push(`${location}.fetchDepth must be an integer from 0 through 1000.`);
  }
  if (
    !Number.isInteger(requirement.timeoutMinutes) ||
    requirement.timeoutMinutes < 1 ||
    requirement.timeoutMinutes > 10
  ) {
    errors.push(`${location}.timeoutMinutes must be an integer from 1 through 10.`);
  }
  if (requirement.mode === "sparse") {
    if (typeof requirement.coneMode !== "boolean") {
      errors.push(`${location}.coneMode must be a boolean for sparse checkout.`);
    }
    const paths = uniqueStringSet(
      requirement.paths,
      `${location}.paths`,
      errors,
      {required: true},
    );
    for (const checkoutPath of paths) {
      validateCheckoutPath(checkoutPath, `${location}.paths`, errors);
    }
  } else {
    if (requirement.coneMode !== undefined) {
      errors.push(`${location}.coneMode is only valid for sparse checkout.`);
    }
    if (requirement.paths !== undefined) {
      errors.push(`${location}.paths is only valid for sparse checkout.`);
    }
  }
}

function validateCheckoutPath(checkoutPath, location, errors) {
  const repoPath = checkoutPath.startsWith("/") ? checkoutPath.slice(1) : "";
  const segments = repoPath.split("/");
  if (
    !checkoutPath.startsWith("/") ||
    repoPath !== normalizePath(repoPath) ||
    repoPath.startsWith("!") ||
    repoPath.endsWith("/") ||
    segments.some((segment) => segment === "" || segment === "." || segment === "..") ||
    /[\u0000-\u001f*?\[\]]/u.test(repoPath)
  ) {
    errors.push(
      `${location} contains unsafe or non-canonical root pattern ${JSON.stringify(checkoutPath)}.`,
    );
  }
}

function cloneCheckoutRequirement(requirement) {
  return {
    mode: requirement.mode,
    fetchDepth: requirement.fetchDepth,
    ...(requirement.coneMode === undefined ? {} : {coneMode: requirement.coneMode}),
    timeoutMinutes: requirement.timeoutMinutes,
    ...(requirement.paths === undefined ? {} : {paths: [...requirement.paths]}),
  };
}

function validateCodegen(entry, errors) {
  if (!entry || typeof entry !== "object" || Array.isArray(entry)) return;
  const location = entry.id ?? "<missing compileCodegen entry>";
  if (!entry.owner) errors.push(`${location} must declare owner.`);
  uniqueStringSet(entry.inputs, `${location}.inputs`, errors, {required: true});
  uniqueStringSet(entry.outputs, `${location}.outputs`, errors, {required: true});
  uniqueStringSet(entry.platforms, `${location}.platforms`, errors, {required: true});
  if (entry.deterministic !== true) errors.push(`${location}.deterministic must be true.`);
  if (entry.network !== false) errors.push(`${location}.network must be false.`);
  if (!Number.isInteger(entry.timeoutSeconds) || entry.timeoutSeconds < 1 || entry.timeoutSeconds > 600) {
    errors.push(`${location}.timeoutSeconds must be an integer from 1 through 600.`);
  }
  if (!entry.checkCommand || !entry.writeCommand) {
    errors.push(`${location} must declare checkCommand and writeCommand.`);
    return;
  }
  if (entry.checkCommand === entry.writeCommand) {
    errors.push(`${location} checkCommand and writeCommand must differ.`);
  }
  for (const [kind, command] of [
    ["checkCommand", entry.checkCommand],
    ["writeCommand", entry.writeCommand],
  ]) {
    try {
      parseCommand(command);
    } catch (error) {
      errors.push(`${location}.${kind}: ${error.message}`);
    }
  }
  const check = entry.checkCommand.toLowerCase();
  if (!/(--check|check:|:check|--self-test|\btest\b)/.test(check)) {
    errors.push(`${location}.checkCommand must use an explicit check or test mode.`);
  }
  if (/\b(firebase|gcloud|curl|wget)\b/.test(check)) {
    errors.push(`${location}.checkCommand may not invoke a network or deployment CLI.`);
  }
  if (/(deploy|secrets?\s+versions?\s+access|--apply|\bbackfill\b|\brepair\b|\bmigrate\b|\bseed\b)/.test(check)) {
    errors.push(`${location}.checkCommand contains a forbidden mutation token.`);
  }
}

function parseCommand(command) {
  if (typeof command !== "string" || command.trim() === "") {
    throw new Error("command must be a non-empty string.");
  }
  if (/[;&|><`\n\r$()]/.test(command)) {
    throw new Error("shell operators, substitutions, and redirections are forbidden.");
  }
  const tokens = command.trim().split(/\s+/);
  if (!["node", "npm", "dart", "flutter", "bash"].includes(tokens[0])) {
    throw new Error(`unsupported executable "${tokens[0]}".`);
  }
  return tokens;
}

function validatePathSet(pathSet, location, errors) {
  if (!pathSet || typeof pathSet !== "object" || Array.isArray(pathSet)) {
    errors.push(`${location} must be an object.`);
    return;
  }
  uniqueStringSet(pathSet.include, `${location}.include`, errors, {required: true});
  uniqueStringSet(pathSet.exclude, `${location}.exclude`, errors);
}

function matchesPathSet(changedPath, pathSet) {
  if (!pathSet) return false;
  const included = (pathSet.include ?? []).some((pattern) => matchesGlob(changedPath, pattern));
  if (!included) return false;
  return !(pathSet.exclude ?? []).some((pattern) => matchesGlob(changedPath, pattern));
}

function collectUniqueIds(entries, label, errors) {
  const ids = new Set();
  for (const entry of entries) {
    if (!entry || typeof entry !== "object" || Array.isArray(entry) || !entry.id) {
      errors.push(`${label} is missing id.`);
      continue;
    }
    if (ids.has(entry.id)) errors.push(`Duplicate ${label} id "${entry.id}".`);
    ids.add(entry.id);
  }
  return ids;
}

function uniqueStringSet(value, location, errors, {required = false} = {}) {
  if (value === undefined && !required) return new Set();
  if (!Array.isArray(value)) {
    errors.push(`${location} must be an array.`);
    return new Set();
  }
  if (required && value.length === 0) errors.push(`${location} must not be empty.`);
  const result = new Set();
  for (const item of value) {
    if (typeof item !== "string" || item.length === 0) {
      errors.push(`${location} entries must be non-empty strings.`);
      continue;
    }
    if (result.has(item)) errors.push(`${location} contains duplicate "${item}".`);
    result.add(item);
  }
  return result;
}

function validateReferences(values, location, componentIds, errors) {
  if (!Array.isArray(values)) {
    errors.push(`${location} must be an array.`);
    return;
  }
  const references = uniqueStringSet(values, location, errors);
  for (const reference of references) {
    if (!componentIds.has(reference)) errors.push(`${location} references unknown "${reference}".`);
  }
}

function buildDependents(components) {
  const dependents = new Map(components.map((component) => [component.id, []]));
  for (const component of components) {
    for (const dependency of component.dependsOn ?? []) {
      dependents.get(dependency)?.push(component.id);
    }
  }
  for (const entries of dependents.values()) entries.sort();
  return dependents;
}

function findPropagationCycles(components) {
  const adjacency = new Map(components.map((component) => [component.id, new Set()]));
  for (const component of components) {
    for (const dependency of component.dependsOn ?? []) {
      adjacency.get(dependency)?.add(component.id);
    }
    for (const target of component.alsoAffects ?? []) adjacency.get(component.id)?.add(target);
  }
  const visiting = new Set();
  const visited = new Set();
  const errors = [];

  function visit(node, stack) {
    if (visiting.has(node)) {
      const start = stack.indexOf(node);
      errors.push(`Propagation cycle: ${[...stack.slice(start), node].join(" -> ")}.`);
      return;
    }
    if (visited.has(node)) return;
    visiting.add(node);
    stack.push(node);
    for (const next of adjacency.get(node) ?? []) visit(next, stack);
    stack.pop();
    visiting.delete(node);
    visited.add(node);
  }
  for (const component of components) visit(component.id, []);
  return errors;
}

function normalizePath(value) {
  return String(value).replaceAll("\\", "/").replace(/^\.\//, "");
}
