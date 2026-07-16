#!/usr/bin/env node

import fs from "node:fs";
import path from "node:path";
import {fileURLToPath} from "node:url";
import ts from "typescript";

const GENERATOR_PATH = "tool/web/react_dependency_graph.mjs";
const DEFAULT_OUTPUT_PATH = "docs/generated/react_dependency_graph";
const ARTIFACT_NAMES = [
  "react_dependency_graph.json",
  "react_dependency_graph.mmd",
  "README.md",
];
const SOURCE_EXTENSIONS = new Set([".ts", ".tsx", ".mts", ".cts"]);
const MODULE_EXTENSIONS = [".ts", ".tsx", ".d.ts", ".mts", ".cts", ".json"];
const SURFACE_DEFINITIONS = [
  {
    id: "website",
    root: "website/src",
    tsconfig: "website/tsconfig.json",
  },
  {
    id: "admin",
    root: "admin/src",
    tsconfig: "admin/tsconfig.json",
  },
  {
    id: "web-ui",
    root: "packages/web-ui/src",
    tsconfig: "packages/web-ui/tsconfig.json",
  },
];

export function buildReactDependencyGraph({repoRoot = defaultRepoRoot()} = {}) {
  const absoluteRepoRoot = path.resolve(repoRoot);
  const surfaces = loadSurfaces(absoluteRepoRoot);
  const workspaces = loadWorkspacePackages(absoluteRepoRoot);
  const sourceFiles = surfaces
    .flatMap((surface) => walkSourceFiles(surface.absoluteRoot))
    .sort(compareStrings);
  const sourceFileSet = new Set(sourceFiles);
  const nodeById = new Map();
  const moduleEdges = [];
  const externalEdges = [];
  const unresolvedImports = [];
  const nonLiteralDynamicImports = [];

  for (const absolutePath of sourceFiles) {
    addNode(nodeById, classifyNode({absolutePath, absoluteRepoRoot, surfaces, scanned: true}));
  }

  for (const sourceAbsolutePath of sourceFiles) {
    const sourceId = repoRelative(absoluteRepoRoot, sourceAbsolutePath);
    const surface = surfaceForPath(surfaces, sourceAbsolutePath);
    const references = parseModuleReferences({
      source: fs.readFileSync(sourceAbsolutePath, "utf8"),
      fileName: sourceAbsolutePath,
    });

    for (const reference of references) {
      if (reference.specifier === null) {
        nonLiteralDynamicImports.push({
          source: sourceId,
          kind: reference.kind,
          line: reference.line,
          column: reference.column,
        });
        continue;
      }

      const resolution = resolveImport({
        specifier: reference.specifier,
        sourceAbsolutePath,
        surface,
        repoRoot: absoluteRepoRoot,
        workspaces,
      });

      if (resolution.kind === "external") {
        externalEdges.push({
          source: sourceId,
          package: externalPackageName(reference.specifier),
          specifier: reference.specifier,
          kind: reference.kind,
          typeOnly: reference.typeOnly,
          line: reference.line,
          column: reference.column,
        });
        continue;
      }

      if (resolution.kind === "unresolved") {
        unresolvedImports.push({
          source: sourceId,
          specifier: reference.specifier,
          kind: reference.kind,
          line: reference.line,
          column: reference.column,
          reason: resolution.reason,
        });
        continue;
      }

      const targetId = repoRelative(absoluteRepoRoot, resolution.absolutePath);
      addNode(
        nodeById,
        classifyNode({
          absolutePath: resolution.absolutePath,
          absoluteRepoRoot,
          surfaces,
          scanned: sourceFileSet.has(resolution.absolutePath),
        })
      );
      moduleEdges.push({
        source: sourceId,
        target: targetId,
        specifier: reference.specifier,
        kind: reference.kind,
        typeOnly: reference.typeOnly,
        line: reference.line,
        column: reference.column,
      });
    }
  }

  const modules = [...nodeById.values()].sort((left, right) =>
    compareStrings(left.id, right.id)
  );
  moduleEdges.sort(compareEdges);
  externalEdges.sort(compareExternalEdges);
  unresolvedImports.sort(compareLocations);
  nonLiteralDynamicImports.sort(compareLocations);

  const nodeIndex = new Map(modules.map((node) => [node.id, node]));
  const featureGroups = aggregateFeatureGroups(modules);
  const featureDependencies = aggregateFeatureDependencies(moduleEdges, nodeIndex);
  const layerDependencies = aggregateLayerDependencies(moduleEdges, nodeIndex);
  const externalDependencies = aggregateExternalDependencies(externalEdges, nodeIndex);
  const crossSurfaceViolations = findCrossSurfaceViolations(moduleEdges, nodeIndex);
  const runtimeCycles = findModuleCycles({modules, moduleEdges, includeTypeOnly: false});
  const allModuleCycles = findModuleCycles({modules, moduleEdges, includeTypeOnly: true});
  const health = {
    healthy:
      unresolvedImports.length === 0 &&
      crossSurfaceViolations.length === 0,
    unresolvedImports,
    crossSurfaceViolations,
    runtimeCycles,
    allModuleCycles,
    nonLiteralDynamicImports,
  };

  return {
    schemaVersion: 1,
    generator: GENERATOR_PATH,
    sourceRoots: surfaces.map((surface) => surface.root),
    configFiles: surfaces.map((surface) => surface.tsconfig),
    policy: {
      unresolvedRepoLocalImports: "error",
      directWebsiteAdminImports: "error",
      runtimeModuleCycles: "report",
      typeOnlyModuleCycles: "report",
      nonLiteralDynamicImports: "report",
    },
    summary: {
      scannedSourceModules: modules.filter((node) => node.scanned).length,
      dependencyLeafNodes: modules.filter((node) => !node.scanned).length,
      moduleNodes: modules.length,
      moduleEdges: moduleEdges.length,
      runtimeModuleEdges: moduleEdges.filter((edge) => !edge.typeOnly).length,
      typeOnlyModuleEdges: moduleEdges.filter((edge) => edge.typeOnly).length,
      dynamicImportEdges: moduleEdges.filter((edge) => edge.kind === "dynamic-import").length,
      reExportEdges: moduleEdges.filter((edge) => edge.kind === "export").length,
      featureGroups: featureGroups.length,
      featureDependencies: featureDependencies.length,
      crossSurfaceDependencies: featureDependencies.filter(
        (dependency) => dependency.sourceSurface !== dependency.targetSurface
      ).length,
      externalPackages: externalDependencies.length,
      unresolvedImports: unresolvedImports.length,
      crossSurfaceViolations: crossSurfaceViolations.length,
      runtimeCycles: runtimeCycles.length,
      allModuleCycles: allModuleCycles.length,
      nonLiteralDynamicImports: nonLiteralDynamicImports.length,
    },
    health,
    featureGroups,
    featureDependencies,
    layerDependencies,
    externalDependencies,
    modules,
    moduleEdges,
    externalEdges,
  };
}

export function parseModuleReferences({source, fileName = "module.ts"}) {
  const sourceFile = ts.createSourceFile(
    fileName,
    source,
    ts.ScriptTarget.Latest,
    true,
    scriptKindFor(fileName)
  );
  const references = [];

  function addReference(node, moduleSpecifier, kind, typeOnly = false) {
    const position = sourceFile.getLineAndCharacterOfPosition(node.getStart(sourceFile));
    references.push({
      specifier: stringLiteralValue(moduleSpecifier),
      kind,
      typeOnly,
      line: position.line + 1,
      column: position.character + 1,
    });
  }

  function visit(node) {
    if (ts.isImportDeclaration(node)) {
      addReference(
        node,
        node.moduleSpecifier,
        "import",
        importDeclarationIsTypeOnly(node)
      );
    } else if (ts.isExportDeclaration(node) && node.moduleSpecifier) {
      addReference(node, node.moduleSpecifier, "export", exportDeclarationIsTypeOnly(node));
    } else if (
      ts.isImportEqualsDeclaration(node) &&
      ts.isExternalModuleReference(node.moduleReference)
    ) {
      addReference(
        node,
        node.moduleReference.expression,
        "import-equals",
        Boolean(node.isTypeOnly)
      );
    } else if (
      ts.isCallExpression(node) &&
      node.expression.kind === ts.SyntaxKind.ImportKeyword
    ) {
      addReference(node, node.arguments[0], "dynamic-import", false);
    }
    ts.forEachChild(node, visit);
  }

  visit(sourceFile);
  return references.sort((left, right) =>
    left.line - right.line ||
    left.column - right.column ||
    compareStrings(left.kind, right.kind) ||
    compareStrings(left.specifier ?? "", right.specifier ?? "")
  );
}

export function renderReactDependencyGraphArtifacts(graph) {
  return new Map([
    ["react_dependency_graph.json", `${JSON.stringify(graph, null, 2)}\n`],
    ["react_dependency_graph.mmd", renderMermaid(graph)],
    ["README.md", renderReadme(graph)],
  ]);
}

export function writeReactDependencyGraphArtifacts({graph, outputDir}) {
  const artifacts = renderReactDependencyGraphArtifacts(graph);
  fs.mkdirSync(outputDir, {recursive: true});
  for (const [name, content] of artifacts) {
    const outputPath = path.join(outputDir, name);
    const temporaryPath = `${outputPath}.tmp`;
    fs.writeFileSync(temporaryPath, content);
    fs.renameSync(temporaryPath, outputPath);
  }
  return [...artifacts.keys()];
}

export function checkReactDependencyGraphArtifacts({graph, outputDir}) {
  const expected = renderReactDependencyGraphArtifacts(graph);
  const findings = [];
  for (const name of ARTIFACT_NAMES) {
    const outputPath = path.join(outputDir, name);
    if (!fs.existsSync(outputPath)) {
      findings.push({name, reason: "missing"});
      continue;
    }
    const actual = fs.readFileSync(outputPath, "utf8");
    if (actual !== expected.get(name)) {
      findings.push({name, reason: "stale"});
    }
  }
  return findings;
}

export function graphHealthErrors(graph) {
  const errors = [];
  for (const unresolved of graph.health.unresolvedImports) {
    errors.push(
      `${unresolved.source}:${unresolved.line}:${unresolved.column} cannot resolve repo-local ` +
        `${unresolved.kind} '${unresolved.specifier}' (${unresolved.reason})`
    );
  }
  for (const violation of graph.health.crossSurfaceViolations) {
    errors.push(
      `${violation.source}:${violation.line}:${violation.column} directly imports ` +
        `${violation.target}; website and admin must remain separate deployable apps`
    );
  }
  return errors;
}

export function assertReactDependencyGraphHealthy(graph) {
  const errors = graphHealthErrors(graph);
  if (errors.length > 0) {
    throw new Error(`React dependency graph is unhealthy:\n- ${errors.join("\n- ")}`);
  }
}

function loadSurfaces(repoRoot) {
  return SURFACE_DEFINITIONS.map((definition) => {
    const absoluteRoot = path.join(repoRoot, definition.root);
    const absoluteTsconfig = path.join(repoRoot, definition.tsconfig);
    if (!fs.existsSync(absoluteRoot)) {
      throw new Error(`React dependency graph source root is missing: ${definition.root}`);
    }
    if (!fs.existsSync(absoluteTsconfig)) {
      throw new Error(`React dependency graph tsconfig is missing: ${definition.tsconfig}`);
    }
    const config = ts.readConfigFile(absoluteTsconfig, ts.sys.readFile);
    if (config.error) {
      throw new Error(formatTypeScriptDiagnostic(config.error));
    }
    const parsed = ts.parseJsonConfigFileContent(
      config.config,
      ts.sys,
      path.dirname(absoluteTsconfig)
    );
    if (parsed.errors.length > 0) {
      throw new Error(parsed.errors.map(formatTypeScriptDiagnostic).join("\n"));
    }
    return {
      ...definition,
      absoluteRoot,
      absoluteTsconfig,
      compilerOptions: parsed.options,
    };
  });
}

function loadWorkspacePackages(repoRoot) {
  const rootPackagePath = path.join(repoRoot, "package.json");
  if (!fs.existsSync(rootPackagePath)) return new Map();
  const document = JSON.parse(fs.readFileSync(rootPackagePath, "utf8"));
  const declarations = Array.isArray(document.workspaces)
    ? document.workspaces
    : document.workspaces?.packages ?? [];
  const packageDirectories = [];
  for (const declaration of declarations) {
    if (declaration.endsWith("/*")) {
      const parent = path.join(repoRoot, declaration.slice(0, -2));
      if (!fs.existsSync(parent)) continue;
      for (const entry of fs.readdirSync(parent, {withFileTypes: true})) {
        if (entry.isDirectory()) packageDirectories.push(path.join(parent, entry.name));
      }
    } else if (!declaration.includes("*")) {
      packageDirectories.push(path.join(repoRoot, declaration));
    }
  }

  const packages = new Map();
  for (const directory of packageDirectories.sort(compareStrings)) {
    const packagePath = path.join(directory, "package.json");
    if (!fs.existsSync(packagePath)) continue;
    const packageDocument = JSON.parse(fs.readFileSync(packagePath, "utf8"));
    if (typeof packageDocument.name !== "string") continue;
    packages.set(packageDocument.name, {directory, document: packageDocument});
  }
  return packages;
}

function walkSourceFiles(directory) {
  const files = [];
  for (const entry of fs.readdirSync(directory, {withFileTypes: true}).sort((left, right) =>
    compareStrings(left.name, right.name)
  )) {
    const absolutePath = path.join(directory, entry.name);
    if (entry.isDirectory()) {
      files.push(...walkSourceFiles(absolutePath));
    } else if (SOURCE_EXTENSIONS.has(path.extname(entry.name))) {
      files.push(absolutePath);
    }
  }
  return files;
}

function resolveImport({specifier, sourceAbsolutePath, surface, repoRoot, workspaces}) {
  const cleanSpecifier = specifier.replace(/[?#].*$/u, "");
  if (cleanSpecifier.startsWith(".")) {
    return resolveRepoCandidate({
      candidates: [path.resolve(path.dirname(sourceAbsolutePath), cleanSpecifier)],
      repoRoot,
      reason: "relative import did not match a file, extension, or index module",
    });
  }

  const aliasCandidates = configuredAliasCandidates(surface, cleanSpecifier);
  if (aliasCandidates !== null) {
    return resolveRepoCandidate({
      candidates: aliasCandidates,
      repoRoot,
      reason: "configured TypeScript path alias did not match a file, extension, or index module",
    });
  }

  const workspaceName = workspacePackageName(cleanSpecifier, workspaces);
  if (workspaceName !== null) {
    const workspace = workspaces.get(workspaceName);
    return resolveRepoCandidate({
      candidates: workspaceCandidates({specifier: cleanSpecifier, workspaceName, workspace}),
      repoRoot,
      reason: "workspace package import did not resolve to a declared export or source module",
    });
  }

  if (path.isAbsolute(cleanSpecifier)) {
    return resolveRepoCandidate({
      candidates: [path.join(surface.absoluteRoot, cleanSpecifier.replace(/^\/+/, ""))],
      repoRoot,
      reason: "absolute app import did not match a source module",
    });
  }

  return {kind: "external"};
}

function configuredAliasCandidates(surface, specifier) {
  const paths = surface.compilerOptions.paths ?? {};
  const basePath = surface.compilerOptions.pathsBasePath ?? path.dirname(surface.absoluteTsconfig);
  const candidates = [];
  let matched = false;
  for (const [pattern, replacements] of Object.entries(paths).sort(([left], [right]) =>
    compareStrings(left, right)
  )) {
    const capture = aliasCapture(pattern, specifier);
    if (capture === null) continue;
    matched = true;
    for (const replacement of replacements) {
      candidates.push(path.resolve(basePath, replacement.replace("*", capture)));
    }
  }
  if (!matched && surface.compilerOptions.baseUrl) {
    const baseUrlCandidate = path.resolve(surface.compilerOptions.baseUrl, specifier);
    if (resolveModuleCandidate(baseUrlCandidate) !== null) return [baseUrlCandidate];
  }
  return matched ? candidates : null;
}

function aliasCapture(pattern, specifier) {
  const starIndex = pattern.indexOf("*");
  if (starIndex < 0) return pattern === specifier ? "" : null;
  const prefix = pattern.slice(0, starIndex);
  const suffix = pattern.slice(starIndex + 1);
  if (!specifier.startsWith(prefix) || !specifier.endsWith(suffix)) return null;
  return specifier.slice(prefix.length, specifier.length - suffix.length);
}

function workspacePackageName(specifier, workspaces) {
  for (const name of [...workspaces.keys()].sort(compareStrings)) {
    if (specifier === name || specifier.startsWith(`${name}/`)) return name;
  }
  return null;
}

function workspaceCandidates({specifier, workspaceName, workspace}) {
  const subpath = specifier.slice(workspaceName.length);
  const exportKey = subpath.length === 0 ? "." : `.${subpath}`;
  const declaredExport = workspace.document.exports?.[exportKey] ??
    (exportKey === "." && typeof workspace.document.exports === "string"
      ? workspace.document.exports
      : null);
  const candidates = exportTargets(declaredExport).map((target) =>
    path.resolve(workspace.directory, target)
  );
  if (subpath.length > 0) candidates.push(path.join(workspace.directory, subpath));
  if (subpath.length === 0) {
    for (const key of ["types", "module", "main"]) {
      if (typeof workspace.document[key] === "string") {
        candidates.push(path.resolve(workspace.directory, workspace.document[key]));
      }
    }
    candidates.push(path.join(workspace.directory, "src/index"));
  }
  return candidates;
}

function exportTargets(value) {
  if (typeof value === "string") return [value];
  if (Array.isArray(value)) return value.flatMap(exportTargets);
  if (value && typeof value === "object") {
    return ["types", "import", "default", "development", "production"]
      .flatMap((key) => exportTargets(value[key]))
      .filter(Boolean);
  }
  return [];
}

function resolveRepoCandidate({candidates, repoRoot, reason}) {
  let escapedRepository = false;
  for (const candidate of candidates) {
    const absoluteCandidate = path.resolve(candidate);
    if (!isInside(repoRoot, absoluteCandidate)) {
      escapedRepository = true;
      continue;
    }
    const resolved = resolveModuleCandidate(absoluteCandidate);
    if (resolved !== null) return {kind: "resolved", absolutePath: resolved};
  }
  return {
    kind: "unresolved",
    reason: escapedRepository ? `${reason}; candidate leaves repository root` : reason,
  };
}

function resolveModuleCandidate(candidate) {
  if (fs.existsSync(candidate) && fs.statSync(candidate).isFile()) return candidate;

  const extension = path.extname(candidate);
  if (extension === ".js" || extension === ".jsx" || extension === ".mjs" || extension === ".cjs") {
    const stem = candidate.slice(0, -extension.length);
    for (const sourceExtension of MODULE_EXTENSIONS) {
      const sourceCandidate = `${stem}${sourceExtension}`;
      if (fs.existsSync(sourceCandidate) && fs.statSync(sourceCandidate).isFile()) {
        return sourceCandidate;
      }
    }
  }

  if (extension.length === 0) {
    for (const sourceExtension of MODULE_EXTENSIONS) {
      const sourceCandidate = `${candidate}${sourceExtension}`;
      if (fs.existsSync(sourceCandidate) && fs.statSync(sourceCandidate).isFile()) {
        return sourceCandidate;
      }
    }
    if (fs.existsSync(candidate) && fs.statSync(candidate).isDirectory()) {
      for (const sourceExtension of MODULE_EXTENSIONS) {
        const indexCandidate = path.join(candidate, `index${sourceExtension}`);
        if (fs.existsSync(indexCandidate) && fs.statSync(indexCandidate).isFile()) {
          return indexCandidate;
        }
      }
    }
  }
  return null;
}

function classifyNode({absolutePath, absoluteRepoRoot, surfaces, scanned}) {
  const id = repoRelative(absoluteRepoRoot, absolutePath);
  const surface = surfaceForPath(surfaces, absolutePath);
  const extension = path.extname(absolutePath);
  if (surface === null) {
    const generatedContractPrefix = "functions/src/shared/generated/";
    const generatedContract = id.startsWith(generatedContractPrefix);
    return {
      id,
      surface: generatedContract ? "contracts" : "repo",
      layer: generatedContract ? "generated" : "dependency",
      scope: generatedContract ? "shared" : "support",
      feature: null,
      group: generatedContract ? "contracts:shared" : "repo:support",
      extension,
      scanned,
      test: isTestPath(id),
      story: isStoryPath(id),
    };
  }

  const relativePath = toPosix(path.relative(surface.absoluteRoot, absolutePath));
  const parts = relativePath.split("/");
  const first = parts[0];
  let layer = "support";
  let scope = "support";
  let feature = null;

  if (surface.id === "web-ui") {
    layer = "shared";
    scope = "shared";
  } else if (first === "features") {
    layer = "feature";
    scope = "feature";
    feature = parts[1] ?? "unknown";
  } else if (first === "app" || relativePath === "App.tsx" || relativePath === "main.tsx") {
    layer = "app";
    scope = "app";
  } else if (first === "shared") {
    layer = "shared";
    scope = "shared";
  } else if (first === "content") {
    layer = "content";
    scope = "shared";
  } else if (first === "generated") {
    layer = "generated";
    scope = "shared";
  } else if (first === "stories" || isStoryPath(relativePath)) {
    layer = "story";
    scope = "support";
  } else if (first === "styles" || extension === ".css") {
    layer = "style";
    scope = "shared";
  } else if (first === "firebase.ts" || first === "firebaseConfig.ts") {
    layer = "service";
    scope = "app";
  }

  const group = feature === null
    ? `${surface.id}:${scope === "support" ? layer : scope}`
    : `${surface.id}:feature:${feature}`;
  return {
    id,
    surface: surface.id,
    layer,
    scope,
    feature,
    group,
    extension,
    scanned,
    test: isTestPath(relativePath),
    story: isStoryPath(relativePath),
  };
}

function addNode(nodeById, node) {
  const existing = nodeById.get(node.id);
  if (existing?.scanned && !node.scanned) return;
  nodeById.set(node.id, node);
}

function aggregateFeatureGroups(modules) {
  const groups = new Map();
  for (const module of modules) {
    const group = groups.get(module.group) ?? {
      id: module.group,
      surface: module.surface,
      scope: module.scope,
      feature: module.feature,
      modules: 0,
      tests: 0,
      stories: 0,
    };
    group.modules += 1;
    if (module.test) group.tests += 1;
    if (module.story) group.stories += 1;
    groups.set(module.group, group);
  }
  return [...groups.values()].sort((left, right) => compareStrings(left.id, right.id));
}

function aggregateFeatureDependencies(edges, nodeIndex) {
  return aggregateDependencies({
    edges,
    nodeIndex,
    keyFor: (node) => node.group,
    describe: (source, target) => ({
      sourceSurface: source.surface,
      sourceScope: source.scope,
      sourceFeature: source.feature,
      targetSurface: target.surface,
      targetScope: target.scope,
      targetFeature: target.feature,
    }),
  });
}

function aggregateLayerDependencies(edges, nodeIndex) {
  return aggregateDependencies({
    edges,
    nodeIndex,
    keyFor: (node) => `${node.surface}:${node.layer}`,
    describe: (source, target) => ({
      sourceSurface: source.surface,
      sourceLayer: source.layer,
      targetSurface: target.surface,
      targetLayer: target.layer,
    }),
  });
}

function aggregateDependencies({edges, nodeIndex, keyFor, describe}) {
  const dependencies = new Map();
  for (const edge of edges) {
    const source = nodeIndex.get(edge.source);
    const target = nodeIndex.get(edge.target);
    if (!source || !target) continue;
    const sourceGroup = keyFor(source);
    const targetGroup = keyFor(target);
    if (sourceGroup === targetGroup) continue;
    const id = `${sourceGroup}->${targetGroup}`;
    const dependency = dependencies.get(id) ?? {
      id,
      source: sourceGroup,
      target: targetGroup,
      ...describe(source, target),
      edges: 0,
      runtimeEdges: 0,
      typeOnlyEdges: 0,
      dynamicImports: 0,
      reExports: 0,
      sourceModules: new Set(),
      targetModules: new Set(),
    };
    dependency.edges += 1;
    if (edge.typeOnly) dependency.typeOnlyEdges += 1;
    else dependency.runtimeEdges += 1;
    if (edge.kind === "dynamic-import") dependency.dynamicImports += 1;
    if (edge.kind === "export") dependency.reExports += 1;
    dependency.sourceModules.add(edge.source);
    dependency.targetModules.add(edge.target);
    dependencies.set(id, dependency);
  }
  return [...dependencies.values()]
    .map((dependency) => ({
      ...dependency,
      sourceModules: [...dependency.sourceModules].sort(compareStrings),
      targetModules: [...dependency.targetModules].sort(compareStrings),
    }))
    .sort((left, right) => compareStrings(left.id, right.id));
}

function aggregateExternalDependencies(edges, nodeIndex) {
  const dependencies = new Map();
  for (const edge of edges) {
    const source = nodeIndex.get(edge.source);
    const id = edge.package;
    const dependency = dependencies.get(id) ?? {
      package: id,
      edges: 0,
      runtimeEdges: 0,
      typeOnlyEdges: 0,
      dynamicImports: 0,
      surfaces: new Set(),
      sourceModules: new Set(),
    };
    dependency.edges += 1;
    if (edge.typeOnly) dependency.typeOnlyEdges += 1;
    else dependency.runtimeEdges += 1;
    if (edge.kind === "dynamic-import") dependency.dynamicImports += 1;
    if (source) dependency.surfaces.add(source.surface);
    dependency.sourceModules.add(edge.source);
    dependencies.set(id, dependency);
  }
  return [...dependencies.values()]
    .map((dependency) => ({
      ...dependency,
      surfaces: [...dependency.surfaces].sort(compareStrings),
      sourceModules: [...dependency.sourceModules].sort(compareStrings),
    }))
    .sort((left, right) => compareStrings(left.package, right.package));
}

function findCrossSurfaceViolations(edges, nodeIndex) {
  const appSurfaces = new Set(["website", "admin"]);
  return edges
    .filter((edge) => {
      const source = nodeIndex.get(edge.source);
      const target = nodeIndex.get(edge.target);
      return source &&
        target &&
        source.surface !== target.surface &&
        appSurfaces.has(source.surface) &&
        appSurfaces.has(target.surface);
    })
    .map((edge) => ({
      source: edge.source,
      target: edge.target,
      specifier: edge.specifier,
      kind: edge.kind,
      line: edge.line,
      column: edge.column,
    }))
    .sort(compareLocations);
}

function findModuleCycles({modules, moduleEdges, includeTypeOnly}) {
  const scannedIds = new Set(modules.filter((module) => module.scanned).map((module) => module.id));
  const adjacency = new Map([...scannedIds].map((id) => [id, new Set()]));
  for (const edge of moduleEdges) {
    if (!includeTypeOnly && edge.typeOnly) continue;
    if (scannedIds.has(edge.source) && scannedIds.has(edge.target)) {
      adjacency.get(edge.source).add(edge.target);
    }
  }

  let index = 0;
  const indexes = new Map();
  const lowLinks = new Map();
  const stack = [];
  const onStack = new Set();
  const components = [];

  function visit(node) {
    indexes.set(node, index);
    lowLinks.set(node, index);
    index += 1;
    stack.push(node);
    onStack.add(node);

    for (const target of [...adjacency.get(node)].sort(compareStrings)) {
      if (!indexes.has(target)) {
        visit(target);
        lowLinks.set(node, Math.min(lowLinks.get(node), lowLinks.get(target)));
      } else if (onStack.has(target)) {
        lowLinks.set(node, Math.min(lowLinks.get(node), indexes.get(target)));
      }
    }

    if (lowLinks.get(node) !== indexes.get(node)) return;
    const component = [];
    let popped;
    do {
      popped = stack.pop();
      onStack.delete(popped);
      component.push(popped);
    } while (popped !== node);
    component.sort(compareStrings);
    const selfCycle = component.length === 1 && adjacency.get(component[0]).has(component[0]);
    if (component.length > 1 || selfCycle) components.push({modules: component});
  }

  for (const node of [...scannedIds].sort(compareStrings)) {
    if (!indexes.has(node)) visit(node);
  }
  return components.sort((left, right) =>
    compareStrings(left.modules.join("\u0000"), right.modules.join("\u0000"))
  );
}

function renderMermaid(graph) {
  const groups = graph.featureGroups;
  const ids = new Map(groups.map((group, index) => [group.id, `g${index}`]));
  const lines = [
    `%% Generated by ${GENERATOR_PATH}`,
    "flowchart LR",
  ];
  for (const group of groups) {
    const label = `${group.id}<br/>${group.modules} modules`;
    lines.push(`  ${ids.get(group.id)}["${escapeMermaid(label)}"]`);
  }
  for (const dependency of graph.featureDependencies) {
    lines.push(
      `  ${ids.get(dependency.source)} -->|"${dependency.edges}"| ${ids.get(dependency.target)}`
    );
  }
  return `${lines.join("\n")}\n`;
}

function renderReadme(graph) {
  const summary = graph.summary;
  const healthStatus = graph.health.healthy ? "healthy" : "unhealthy";
  return `# React dependency graph

Generated from TypeScript ASTs under \`${graph.sourceRoots.join("\`, \`")}\` by
\`node ${GENERATOR_PATH} --write\`. The JSON file is the complete module graph;
the Mermaid file is the aggregated feature and shared-layer map.

## Current inventory

| Measure | Count |
|---|---:|
| Scanned TypeScript modules | ${summary.scannedSourceModules} |
| Dependency leaf nodes | ${summary.dependencyLeafNodes} |
| Module edges | ${summary.moduleEdges} |
| Dynamic imports | ${summary.dynamicImportEdges} |
| Re-exports | ${summary.reExportEdges} |
| Feature/shared groups | ${summary.featureGroups} |
| Aggregated feature dependencies | ${summary.featureDependencies} |
| External packages | ${summary.externalPackages} |
| Unresolved repo-local imports | ${summary.unresolvedImports} |
| Direct website/admin violations | ${summary.crossSurfaceViolations} |
| Runtime module cycles | ${summary.runtimeCycles} |
| Type-inclusive module cycles | ${summary.allModuleCycles} |

Blocking gate health: **${healthStatus}**.

## Refresh and check

    node ${GENERATOR_PATH} --write
    node ${GENERATOR_PATH} --check
    node ${GENERATOR_PATH} --summary

The check fails when generated artifacts are stale, a repo-local relative,
TypeScript-path, or workspace import cannot be resolved, or website and admin
import one another directly. Runtime and type-only cycles plus non-literal
dynamic imports remain visible in JSON health data. Cycles are report-only while
the existing graph has unresolved cycle debt, rather than hidden behind a
baseline that would make new cycles look acceptable.
`;
}

function printSummary(graph) {
  const summary = graph.summary;
  console.log("React dependency graph summary");
  console.log(`- source modules: ${summary.scannedSourceModules}`);
  console.log(`- module edges: ${summary.moduleEdges}`);
  console.log(`- feature/shared groups: ${summary.featureGroups}`);
  console.log(`- feature dependencies: ${summary.featureDependencies}`);
  console.log(`- external packages: ${summary.externalPackages}`);
  console.log(`- unresolved imports: ${summary.unresolvedImports}`);
  console.log(`- direct website/admin violations: ${summary.crossSurfaceViolations}`);
  console.log(`- runtime cycles: ${summary.runtimeCycles}`);
  console.log(`- type-inclusive cycles: ${summary.allModuleCycles}`);
}

function formatHealthErrors(errors) {
  return `React dependency graph validation failed:\n- ${errors.join("\n- ")}`;
}

function surfaceForPath(surfaces, absolutePath) {
  return surfaces.find((surface) => isInside(surface.absoluteRoot, absolutePath)) ?? null;
}

function scriptKindFor(fileName) {
  if (fileName.endsWith(".tsx")) return ts.ScriptKind.TSX;
  if (fileName.endsWith(".ts")) return ts.ScriptKind.TS;
  return ts.ScriptKind.Unknown;
}

function stringLiteralValue(node) {
  return node && (ts.isStringLiteral(node) || ts.isNoSubstitutionTemplateLiteral(node))
    ? node.text
    : null;
}

function importDeclarationIsTypeOnly(node) {
  const clause = node.importClause;
  if (!clause) return false;
  if (clause.isTypeOnly) return true;
  return Boolean(
    !clause.name &&
      clause.namedBindings &&
      ts.isNamedImports(clause.namedBindings) &&
      clause.namedBindings.elements.length > 0 &&
      clause.namedBindings.elements.every((element) => element.isTypeOnly)
  );
}

function exportDeclarationIsTypeOnly(node) {
  if (node.isTypeOnly) return true;
  return Boolean(
    node.exportClause &&
      ts.isNamedExports(node.exportClause) &&
      node.exportClause.elements.length > 0 &&
      node.exportClause.elements.every((element) => element.isTypeOnly)
  );
}

function externalPackageName(specifier) {
  if (specifier.startsWith("node:")) return specifier;
  const parts = specifier.split("/");
  return specifier.startsWith("@") ? parts.slice(0, 2).join("/") : parts[0];
}

function isInside(parent, child) {
  const relative = path.relative(parent, child);
  return relative === "" || (!relative.startsWith("..") && !path.isAbsolute(relative));
}

function repoRelative(repoRoot, absolutePath) {
  return toPosix(path.relative(repoRoot, absolutePath));
}

function toPosix(value) {
  return value.split(path.sep).join("/");
}

function isTestPath(value) {
  return /(?:^|\/)(?:__tests__\/|[^/]+\.(?:test|spec)\.[^.]+$)/u.test(value);
}

function isStoryPath(value) {
  return /(?:^|\/)(?:stories\/|[^/]+\.stories\.[^.]+$)/u.test(value);
}

function escapeMermaid(value) {
  return value.replaceAll('"', "&quot;");
}

function compareStrings(left, right) {
  if (left < right) return -1;
  if (left > right) return 1;
  return 0;
}

function compareEdges(left, right) {
  return compareStrings(left.source, right.source) ||
    left.line - right.line ||
    left.column - right.column ||
    compareStrings(left.target, right.target) ||
    compareStrings(left.kind, right.kind);
}

function compareExternalEdges(left, right) {
  return compareStrings(left.source, right.source) ||
    left.line - right.line ||
    left.column - right.column ||
    compareStrings(left.specifier, right.specifier);
}

function compareLocations(left, right) {
  return compareStrings(left.source, right.source) ||
    left.line - right.line ||
    left.column - right.column ||
    compareStrings(left.specifier ?? "", right.specifier ?? "");
}

function formatTypeScriptDiagnostic(diagnostic) {
  return ts.flattenDiagnosticMessageText(diagnostic.messageText, "\n");
}

function defaultRepoRoot() {
  return path.resolve(path.dirname(fileURLToPath(import.meta.url)), "../..");
}

function parseArgs(argv) {
  const parsed = {
    mode: null,
    repoRoot: defaultRepoRoot(),
    outputDir: null,
    help: false,
  };
  for (let index = 0; index < argv.length; index += 1) {
    const argument = argv[index];
    if (["--write", "--check", "--summary"].includes(argument)) {
      if (parsed.mode !== null) throw new Error("Choose exactly one of --write, --check, or --summary.");
      parsed.mode = argument.slice(2);
    } else if (argument === "--repo-root") {
      parsed.repoRoot = requiredValue(argv, ++index, argument);
    } else if (argument === "--output-dir") {
      parsed.outputDir = requiredValue(argv, ++index, argument);
    } else if (argument === "--help" || argument === "-h") {
      parsed.help = true;
    } else {
      throw new Error(`Unknown argument: ${argument}`);
    }
  }
  if (!parsed.help && parsed.mode === null) {
    throw new Error("Choose exactly one of --write, --check, or --summary.");
  }
  parsed.repoRoot = path.resolve(parsed.repoRoot);
  parsed.outputDir = path.resolve(
    parsed.repoRoot,
    parsed.outputDir ?? DEFAULT_OUTPUT_PATH
  );
  return parsed;
}

function requiredValue(argv, index, flag) {
  const value = argv[index];
  if (!value || value.startsWith("--")) throw new Error(`${flag} requires a value.`);
  return value;
}

function printHelp() {
  console.log(`Usage: node ${GENERATOR_PATH} --write|--check|--summary [options]

Options:
  --write                 Regenerate JSON, Mermaid, and README artifacts.
  --check                 Fail when graph health or generated artifacts drift.
  --summary               Print current graph counts without reading artifacts.
  --repo-root <path>      Override the repository root (fixture/testing support).
  --output-dir <path>     Override ${DEFAULT_OUTPUT_PATH}.
  --help                  Show this help.
`);
}

async function main() {
  let args;
  try {
    args = parseArgs(process.argv.slice(2));
  } catch (error) {
    console.error(error.message);
    process.exitCode = 64;
    return;
  }
  if (args.help) {
    printHelp();
    return;
  }

  try {
    const graph = buildReactDependencyGraph({repoRoot: args.repoRoot});
    const healthErrors = graphHealthErrors(graph);
    if (healthErrors.length > 0) {
      console.error(formatHealthErrors(healthErrors));
      process.exitCode = 1;
      return;
    }
    if (args.mode === "write") {
      const names = writeReactDependencyGraphArtifacts({graph, outputDir: args.outputDir});
      console.log(`Wrote React dependency graph: ${names.join(", ")}`);
    } else if (args.mode === "check") {
      const findings = checkReactDependencyGraphArtifacts({graph, outputDir: args.outputDir});
      if (findings.length > 0) {
        console.error("React dependency graph artifacts are stale:");
        for (const finding of findings) console.error(`- ${finding.name}: ${finding.reason}`);
        console.error(`Run: node ${GENERATOR_PATH} --write`);
        process.exitCode = 1;
        return;
      }
      console.log(
        `React dependency graph is current (${graph.summary.scannedSourceModules} modules, ` +
          `${graph.summary.moduleEdges} edges).`
      );
    } else {
      printSummary(graph);
    }
  } catch (error) {
    console.error(error.stack ?? error.message);
    process.exitCode = 1;
  }
}

if (fileURLToPath(import.meta.url) === path.resolve(process.argv[1] ?? "")) {
  await main();
}
