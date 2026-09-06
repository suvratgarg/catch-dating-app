#!/usr/bin/env node
import fs from "node:fs";
import path from "node:path";
import {fileURLToPath} from "node:url";
import ts from "typescript";

const repoRoot = fileURLToPath(new URL("../../", import.meta.url));
const checkOnly = process.argv.includes("--check");
const policySource =
  "functions/src/eventSuccess/operations/lateJoinPolicy.ts";
const policyCode = fs.readFileSync(path.join(repoRoot, policySource), "utf8");
const parsedPolicy = ts.createSourceFile(
  policySource, policyCode, ts.ScriptTarget.ES2022, true
);
for (const statement of parsedPolicy.statements) {
  if (ts.isImportDeclaration(statement) &&
      !statement.importClause?.isTypeOnly) {
    throw new Error("Shared assistance policy must have no runtime imports.");
  }
  if (ts.isExportDeclaration(statement) && statement.moduleSpecifier) {
    throw new Error("Shared assistance policy cannot re-export dependencies.");
  }
}
const policyModule = ts.transpileModule(policyCode, {
  compilerOptions: {target: ts.ScriptTarget.ES2022, module: ts.ModuleKind.ES2022},
  reportDiagnostics: true,
  fileName: policySource,
});
if (policyModule.diagnostics?.some((issue) =>
  issue.category === ts.DiagnosticCategory.Error)) {
  throw new Error("Shared assistance policy could not be transpiled.");
}
addTextOutput(
  "operations/src/workflows/event-assistance/generated/late-join.mjs",
  "// GENERATED CODE - DO NOT MODIFY BY HAND.\n" +
    "// Source: " + policySource + "\n" +
    "// Regenerate: node operations/scripts/generate-event-assistance-runtime.mjs\n\n" +
    policyModule.outputText
);

function addTextOutput(relativePath, content) {
  const target = path.join(repoRoot, relativePath);
  if (checkOnly) {
    const current = fs.existsSync(target) ? fs.readFileSync(target, "utf8") : null;
    if (current !== content) {
      process.stderr.write("Stale shared policy runtime: " + relativePath + "\n");
      process.exitCode = 1;
      return;
    }
    process.stdout.write("Shared event-assistance runtime is current.\n");
    return;
  }
  fs.mkdirSync(path.dirname(target), {recursive: true});
  fs.writeFileSync(target, content);
  process.stdout.write("Generated " + relativePath + "\n");
}
