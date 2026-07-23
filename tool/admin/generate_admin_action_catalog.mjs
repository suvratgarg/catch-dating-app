#!/usr/bin/env node
import fs from "node:fs";
import path from "node:path";
import {fileURLToPath} from "node:url";

const scriptDirectory = path.dirname(fileURLToPath(import.meta.url));
const repoRoot = path.resolve(scriptDirectory, "..", "..");
const sourcePath = path.join(
  repoRoot,
  "contracts",
  "admin",
  "admin_action_catalog.json"
);
const outputs = new Map([
  [
    path.join(repoRoot, "admin", "src", "generated", "adminActionCatalog.ts"),
    renderAdmin,
  ],
  [
    path.join(
      repoRoot,
      "functions",
      "src",
      "shared",
      "generated",
      "adminActionCatalog.ts"
    ),
    renderFunctions,
  ],
]);
const checkOnly = process.argv.includes("--check");
const selfTest = process.argv.includes("--self-test");
const catalog = JSON.parse(fs.readFileSync(sourcePath, "utf8"));

if (selfTest) {
  const changed = structuredClone(catalog);
  changed.actions[0].summary = "simulated drift";
  if (renderAdmin(changed) === renderAdmin(catalog)) {
    throw new Error("Admin action catalog self-test did not detect drift.");
  }
  console.log("Admin action catalog generator self-test detected drift.");
  process.exit(0);
}

let stale = false;
for (const [outputPath, render] of outputs) {
  const output = render(catalog);
  if (checkOnly) {
    const current = fs.existsSync(outputPath) ?
      fs.readFileSync(outputPath, "utf8") : "";
    if (current !== output) {
      stale = true;
      console.error(`${path.relative(repoRoot, outputPath)} is stale.`);
    }
    continue;
  }
  fs.mkdirSync(path.dirname(outputPath), {recursive: true});
  fs.writeFileSync(outputPath, output);
}
if (stale) process.exitCode = 1;
else console.log(checkOnly ?
  `Admin action catalog outputs are current (${catalog.actions.length} actions).` :
  `Generated admin action catalog outputs (${catalog.actions.length} actions).`);

function renderAdmin(value) {
  const publicCatalog = {
    schemaVersion: value.schemaVersion,
    catalogVersion: value.catalogVersion,
    actions: value.actions.map((action) => ({
      actionId: action.actionId,
      callable: action.callable,
      workflowIds: action.workflowIds,
      guiPath: action.guiPath,
      kind: action.kind,
      risk: action.risk,
      roles: action.roles,
      summary: action.summary,
      controlPlane: action.controlPlane === true,
    })),
    workflows: value.workflows,
  };
  return header() +
    `export const adminActionCatalog = ${JSON.stringify(publicCatalog, null, 2)} as const;\n\n` +
    "export type AdminActionId = typeof adminActionCatalog.actions[number][\"actionId\"];\n";
}

function renderFunctions(value) {
  const actions = Object.fromEntries(value.actions.map((action) => [
    action.actionId,
    {
      callable: action.callable,
      controlPlane: action.controlPlane === true,
      kind: action.kind,
      roles: action.roles,
    },
  ]));
  return header() +
    `export const ADMIN_ACTION_CATALOG = ${JSON.stringify(actions, null, 2)} as const;\n\n` +
    "export type AdminActionId = keyof typeof ADMIN_ACTION_CATALOG;\n";
}

function header() {
  return "// GENERATED FILE. Run: node tool/admin/generate_admin_action_catalog.mjs\n";
}
