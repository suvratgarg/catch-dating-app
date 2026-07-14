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
    for (const file of files) {
      const content = await fs.readFile(file, "utf8");
      for (const forbidden of baseline.forbiddenLegacyImports) {
        if (content.includes(forbidden)) {
          findings.push({
            id: "legacy-imports-operations-runtime",
            path: relative(repoRoot, file),
            token: forbidden,
            message: "Legacy tools are adapter inputs and must not become an operations runtime host.",
          });
        }
      }
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
  }
  return {
    schemaVersion: 1,
    policyId: baseline.policyId,
    ok: findings.length === 0,
    findings,
    checked: {
      legacyRoots: baseline.legacyRoots.length,
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

function valueAfter(argv, flag) {
  const index = argv.indexOf(flag);
  return index === -1 ? null : argv[index + 1];
}

function isMain() {
  return process.argv[1] && path.resolve(process.argv[1]) === fileURLToPath(import.meta.url);
}
