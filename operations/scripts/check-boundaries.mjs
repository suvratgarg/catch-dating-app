#!/usr/bin/env node
import fs from "node:fs/promises";
import path from "node:path";
import {fileURLToPath} from "node:url";

const scriptDirectory = path.dirname(fileURLToPath(import.meta.url));
const operationsRoot = path.resolve(scriptDirectory, "..");
const defaultRepoRoot = path.resolve(operationsRoot, "..");

if (isMain()) {
  const repoRoot = path.resolve(valueAfter(process.argv.slice(2), "--repo-root") ?? defaultRepoRoot);
  const baseline = JSON.parse(await fs.readFile(path.join(operationsRoot, "governance", "legacy_tool_baseline.json"), "utf8"));
  const result = await checkBoundaries({repoRoot, baseline});
  if (!result.ok) {
    process.stderr.write(`${JSON.stringify(result, null, 2)}\n`);
    process.exitCode = 1;
  } else {
    process.stdout.write(`${JSON.stringify(result)}\n`);
  }
}

export async function checkBoundaries({repoRoot, baseline}) {
  const findings = [];
  const toolFiles = await codeFiles(
    path.join(repoRoot, baseline.toolRoot ?? "tool"),
    baseline.codeExtensions
  );
  const markerGroups = new Map();
  for (const file of toolFiles) {
    const fileRelative = relative(repoRoot, file);
    const content = await fs.readFile(file, "utf8");
    for (const forbidden of baseline.forbiddenLegacyImports) {
      if (content.includes(forbidden)) {
        findings.push({
          id: "tool-imports-operations-runtime",
          path: fileRelative,
          token: forbidden,
          message: "Durable business workflows belong under operations/, not tool/.",
        });
      }
    }
    const matchedMarkers = (baseline.durableWorkflowMarkers ?? [])
      .filter((marker) => content.includes(marker));
    if (matchedMarkers.length > 0) {
      const group = firstToolSubtree(fileRelative);
      const evidence = markerGroups.get(group) ?? {
        markers: new Set(),
        paths: new Set(),
      };
      matchedMarkers.forEach((marker) => evidence.markers.add(marker));
      evidence.paths.add(fileRelative);
      markerGroups.set(group, evidence);
    }
    if (matchedMarkers.length >=
        (baseline.durableWorkflowMarkerThreshold ?? 2)) {
      findings.push({
        id: "durable-workflow-markers-under-tool",
        path: relative(repoRoot, file),
        markers: matchedMarkers,
        message: "Business-workflow orchestration must be implemented under operations/.",
      });
    }
  }
  for (const [toolSubtree, evidence] of markerGroups) {
    if (evidence.markers.size <
        (baseline.durableWorkflowMarkerThreshold ?? 2)) continue;
    findings.push({
      id: "durable-workflow-markers-under-tool-root",
      path: toolSubtree,
      markers: [...evidence.markers].sort(),
      evidencePaths: [...evidence.paths].sort(),
      message: "Split business-workflow orchestration must be implemented under operations/.",
    });
  }
  for (const legacyRoot of baseline.legacyRoots) {
    const files = await codeFiles(path.join(repoRoot, legacyRoot.path), baseline.codeExtensions);
    if (files.length > legacyRoot.codeFileCeiling) {
      findings.push({
        id: "legacy-code-ceiling-exceeded",
        path: legacyRoot.path,
        expectedMaximum: legacyRoot.codeFileCeiling,
        actual: files.length,
        message: "New runtime code belongs under operations/, not a legacy tool workflow.",
      });
    }
  }

  const operationsSourceRoot = path.join(repoRoot, "operations", "src");
  const operationFiles = await codeFiles(operationsSourceRoot, baseline.codeExtensions);
  const legacyPathTokens = baseline.legacyRoots.map((root) => root.path);
  for (const file of operationFiles) {
    const fileRelative = relative(repoRoot, file);
    const content = await fs.readFile(file, "utf8");
    const isAllowedReader = baseline.allowedLegacyPathReaders.includes(fileRelative);
    for (const token of legacyPathTokens) {
      if (content.includes(token) && !isAllowedReader) {
        findings.push({
          id: "legacy-path-outside-adapter",
          path: fileRelative,
          token,
          message: "Legacy artifact paths may only appear in the declared adapter boundary.",
        });
      }
    }
    if (/\b(?:import|export)\s[\s\S]{0,160}\bfrom\s*["'][^"']*\/tool\//u.test(content)) {
      findings.push({
        id: "operations-imports-tool-code",
        path: fileRelative,
        message: "Operations may read legacy JSON artifacts but must not import executable tool code.",
      });
    }
    const loaderKinds = [];
    if (/\bimport\s*\(/u.test(content)) loaderKinds.push("dynamic_import");
    if (/(?:^|[^\w$])(?:module\.)?require\s*\(/u.test(content)) loaderKinds.push("commonjs_require");
    if (/\bcreateRequire\b/u.test(content)) loaderKinds.push("create_require");
    if (loaderKinds.length > 0) {
      findings.push({
        id: "operations-executable-loader-not-allowed",
        path: fileRelative,
        loaderKinds,
        message: "Operations runtime dependencies must use statically inspectable ESM imports.",
      });
    }
  }
  return {
    schemaVersion: 1,
    policyId: baseline.policyId,
    ok: findings.length === 0,
    findings,
    checked: {
      legacyRoots: baseline.legacyRoots.length,
      toolCodeFiles: toolFiles.length,
      operationsSourceFiles: operationFiles.length,
    },
  };
}

async function codeFiles(root, extensions) {
  const output = [];
  async function visit(directory) {
    let entries;
    try {
      entries = await fs.readdir(directory, {withFileTypes: true});
    } catch (error) {
      if (error?.code === "ENOENT") return;
      throw error;
    }
    for (const entry of entries.sort((left, right) => left.name.localeCompare(right.name))) {
      const current = path.join(directory, entry.name);
      if (entry.isDirectory()) await visit(current);
      else if (entry.isFile() && extensions.includes(path.extname(entry.name))) output.push(current);
    }
  }
  await visit(root);
  return output.sort();
}

function relative(root, file) {
  return path.relative(root, file).split(path.sep).join("/");
}

function firstToolSubtree(file) {
  const parts = file.split("/");
  return parts.length > 2 ? parts.slice(0, 2).join("/") : parts[0];
}

function valueAfter(argv, flag) {
  const index = argv.indexOf(flag);
  return index === -1 ? null : argv[index + 1];
}

function isMain() {
  return process.argv[1] && path.resolve(process.argv[1]) === fileURLToPath(import.meta.url);
}
