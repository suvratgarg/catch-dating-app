#!/usr/bin/env node
import assert from "node:assert/strict";
import fs from "node:fs";
import path from "node:path";
import {fromRepo} from "../lib/repo_paths.mjs";

const args = parseArgs(process.argv.slice(2));

if (args.help) {
  printHelp();
  process.exit(0);
}

if (args.selfTest) {
  runSelfTest();
  process.exit(0);
}

const componentsPath = fromRepo(args.components ?? "design/admin/components.json");
const schemaPath = fromRepo("design/admin/admin.components.schema.json");
const adoptionPath = fromRepo("docs/audit_registry/admin_console_design_adoption.json");

const errors = [];
const warnings = [];

const registry = readJson(componentsPath, "admin component registry");

validateRegistryShape(registry);
validateComponents(registry.components ?? []);
validateExportCoverage(registry.components ?? []);
validateAdminChrome();
validateAdminPresentationCopy();
const adoptionRegistry = readJson(adoptionPath, "admin console design adoption registry");
validateProposalProof(adoptionRegistry);
errors.push(...adminDebtErrors(adoptionRegistry));

if (errors.length > 0) {
  console.error("Admin component registry check failed:");
  for (const error of errors) console.error(`- ${error}`);
  process.exit(1);
}

if (args.summary || warnings.length > 0) {
  for (const warning of warnings) console.warn(`Warning: ${warning}`);
  console.log(
    [
      `Admin component registry ok: ${registry.components.length} component contract(s).`,
      `Preview-ready components: ${registry.components.filter((component) => component.preview?.status === "ready").length}.`,
      `Contract: ${path.relative(fromRepo("."), componentsPath)}`,
    ].join("\n"),
  );
}

function validateRegistryShape(value) {
  if (!value || typeof value !== "object" || Array.isArray(value)) {
    errors.push("components.json must be a JSON object.");
    return;
  }
  if (value.$schema !== "./admin.components.schema.json") {
    errors.push("components.json must reference ./admin.components.schema.json.");
  }
  if (!fs.existsSync(schemaPath)) {
    errors.push("missing design/admin/admin.components.schema.json.");
  }
  if (!Number.isInteger(value.version) || value.version < 1) {
    errors.push("components.json version must be a positive integer.");
  }
  if (value.owner !== "admin_dashboard") {
    errors.push("components.json owner must be admin_dashboard.");
  }
  if (value.coverage?.strategy !== "route-workspace-plus-shared-primitives") {
    errors.push("components.json coverage.strategy must be route-workspace-plus-shared-primitives.");
  }
  if (!Array.isArray(value.components) || value.components.length === 0) {
    errors.push("components.json must declare at least one component.");
  }
}

function validateComponents(components) {
  const componentIds = new Set();
  const componentById = new Map();
  const readyStorySources = new Map();
  const sourceExportsByPath = new Map();
  const allowedKinds = new Set(["route", "workspace", "shared-primitive", "provider"]);
  const allowedPreviewStatuses = new Set(["ready", "planned", "not-required"]);

  for (const component of components) {
    if (!component || typeof component !== "object" || Array.isArray(component)) {
      errors.push("component entries must be objects.");
      continue;
    }

    const label = component.id ?? "<missing-id>";
    if (!component.id) errors.push("component missing id.");
    if (component.id && componentIds.has(component.id)) {
      errors.push(`${label}: duplicate component id.`);
    }
    if (component.id) componentIds.add(component.id);
    if (component.id) componentById.set(component.id, component);

    if (!allowedKinds.has(component.kind)) errors.push(`${label}: invalid kind ${component.kind}.`);
    if (!component.owner) errors.push(`${label}: missing owner.`);
    if (!component.source) errors.push(`${label}: missing source.`);
    if (!component.exportName) errors.push(`${label}: missing exportName.`);

    const preview = component.preview;
    if (!preview || typeof preview !== "object" || Array.isArray(preview)) {
      errors.push(`${label}: missing preview coverage object.`);
    } else {
      if (!allowedPreviewStatuses.has(preview.status)) {
        errors.push(`${label}: invalid preview.status ${preview.status}.`);
      }
      if (!Array.isArray(preview.states) || preview.states.length === 0) {
        errors.push(`${label}: preview.states must list at least one state.`);
      }
      if (preview.status === "ready" && (!preview.story || !preview.exportName)) {
        errors.push(`${label}: ready preview coverage needs story and exportName.`);
      } else if (preview.status === "ready") {
        validateReadyPreview(label, preview, component, readyStorySources);
      }
      if (preview.status !== "ready" && (preview.story || preview.exportName)) {
        warnings.push(`${label}: preview story metadata is ignored because status is ${preview.status}.`);
      }
    }

    if (!Array.isArray(component.css)) {
      errors.push(`${label}: css must be an array, even when empty.`);
    } else {
      for (const cssPath of component.css) {
        if (!fs.existsSync(fromRepo(cssPath))) {
          errors.push(`${label}: css file does not exist: ${cssPath}.`);
        }
      }
    }

    const sourcePath = component.source ? fromRepo(component.source) : null;
    if (!sourcePath || !fs.existsSync(sourcePath)) {
      errors.push(`${label}: source file does not exist: ${component.source}.`);
      continue;
    }

    let exports = sourceExportsByPath.get(sourcePath);
    if (!exports) {
      exports = exportedReactComponents(fs.readFileSync(sourcePath, "utf8"));
      sourceExportsByPath.set(sourcePath, exports);
    }
    if (!exports.has(component.exportName)) {
      errors.push(`${label}: source does not export ${component.exportName}.`);
    }

    validateKindAgainstSource(component, label);
  }

  validateStoryDeclarations({componentById, readyStorySources});
}

function validateReadyPreview(label, preview, component, readyStorySources) {
  const storyPath = fromRepo(preview.story);
  if (!fs.existsSync(storyPath)) {
    errors.push(`${label}: preview story file does not exist: ${preview.story}.`);
    return;
  }

  let source = readyStorySources.get(storyPath);
  if (!source) {
    source = fs.readFileSync(storyPath, "utf8");
    readyStorySources.set(storyPath, source);
  }

  const storyExportPattern = new RegExp(`export\\s+const\\s+${escapeRegExp(preview.exportName)}\\b`, "u");
  if (!storyExportPattern.test(source)) {
    errors.push(`${label}: preview story file does not export ${preview.exportName}.`);
  }

  const coveredStates = storyStatesForComponent(source, component.id);
  for (const state of preview.states ?? []) {
    if (coveredStates.has(state)) continue;
    errors.push(`${label}: preview story does not declare state ${state}.`);
  }
}

function validateStoryDeclarations({componentById, readyStorySources}) {
  const exportsByComponent = new Map();

  for (const [storyPath, source] of readyStorySources.entries()) {
    const declarations = storyComponentDeclarations(source);
    for (const declaration of declarations) {
      const storyLabel = `${path.relative(fromRepo("."), storyPath)}:${declaration.exportName}`;
      const component = componentById.get(declaration.id);
      if (!component) {
        errors.push(`${storyLabel}: declares unknown catchComponent.id ${declaration.id}.`);
        continue;
      }
      if (component.preview?.status !== "ready") {
        errors.push(
          `${storyLabel}: declares ${declaration.id}, but registry status is ${component.preview?.status}.`,
        );
      }
      if (component.preview?.story && fromRepo(component.preview.story) !== storyPath) {
        errors.push(
          `${storyLabel}: declares ${declaration.id}, but registry points to ${component.preview.story}.`,
        );
      }
      if (declaration.states.length === 0) {
        errors.push(`${storyLabel}: catchComponent.states must list at least one state.`);
      }
      for (const state of declaration.states) {
        if (!component.preview.states.includes(state)) {
          errors.push(`${storyLabel}: state ${state} is not registered for ${declaration.id}.`);
        }
      }

      const exports = exportsByComponent.get(declaration.id) ?? new Set();
      exports.add(declaration.exportName);
      exportsByComponent.set(declaration.id, exports);
    }
  }

  for (const component of componentById.values()) {
    if (component.preview?.status !== "ready") continue;
    const exports = exportsByComponent.get(component.id) ?? new Set();
    if (!exports.has(component.preview.exportName)) {
      errors.push(
        `${component.id}: ready preview export ${component.preview.exportName} must declare catchComponent.id ${component.id}.`,
      );
    }
  }
}

function validateKindAgainstSource(component, label) {
  const source = normalizeRepoPath(component.source);
  if (component.kind === "route" && !source.startsWith("admin/src/features/")) {
    errors.push(`${label}: route components must live under admin/src/features.`);
  }
  if (component.kind === "workspace" && !source.startsWith("admin/src/features/")) {
    errors.push(`${label}: workspace components must live under admin/src/features.`);
  }
  if (component.kind === "shared-primitive" && !source.startsWith("admin/src/shared/ui/")) {
    errors.push(`${label}: shared-primitive components must live under admin/src/shared/ui.`);
  }
  if (component.kind === "provider" && !source.startsWith("admin/src/shared/feedback/")) {
    errors.push(`${label}: provider components must live under admin/src/shared/feedback.`);
  }
}

function validateExportCoverage(components) {
  const registeredExports = new Set(
    components.map((component) =>
      `${normalizeRepoPath(component.source)}::${component.exportName}`,
    ),
  );

  const requiredExports = [
    ...featureComponentExports(),
    ...sharedComponentExports("admin/src/shared/ui", "shared UI primitive"),
    ...sharedComponentExports("admin/src/shared/feedback", "shared feedback provider"),
  ];

  for (const exported of requiredExports) {
    if (registeredExports.has(`${exported.source}::${exported.name}`)) continue;
    errors.push(
      `${exported.source}: exported ${exported.label} ${exported.name} must be registered in design/admin/components.json.`,
    );
  }
}

function validateAdminChrome() {
  const appPath = fromRepo("admin/src/app/App.tsx");
  if (!fs.existsSync(appPath)) {
    errors.push("missing admin/src/app/App.tsx for admin chrome validation.");
    return;
  }
  errors.push(...adminChromeErrors(fs.readFileSync(appPath, "utf8")));
}

function validateAdminPresentationCopy() {
  const sourcePaths = [
    ...walkFiles(fromRepo("admin/src"), ".ts"),
    ...walkFiles(fromRepo("admin/src"), ".tsx"),
  ];
  for (const filePath of sourcePaths) {
    if (filePath.endsWith(".test.ts") || filePath.endsWith(".test.tsx")) continue;
    errors.push(...adminPresentationCopyErrors(
      fs.readFileSync(filePath, "utf8"),
      relativeToRepo(filePath),
    ));
  }
}

function adminPresentationCopyErrors(source, label = "admin source") {
  const forbiddenCopy = [
    "sample access application",
    "sample safety item",
    "sample organizer",
    "sample event",
    "sample draft created",
    "sample queue item",
    "generated sample",
    "generated sample bridge",
    "sample-mode review",
  ];
  const normalizedSource = source.toLowerCase();
  const copyErrors = [];
  for (const phrase of forbiddenCopy) {
    if (!normalizedSource.includes(phrase)) continue;
    copyErrors.push(`${label}: admin-facing copy must not expose prototype phrase ${phrase}.`);
  }
  return copyErrors;
}

function validateProposalProof(value) {
  errors.push(...proposalProofErrors(value));
}

function proposalProofErrors(value) {
  const proofErrors = [];
  const expectedCount = value?.approvedProposalTranche?.approvedReadyCount;
  const groups = value?.proposalProofGroups;

  if (expectedCount !== 68) {
    proofErrors.push("admin console adoption registry must declare exactly 68 approved-ready proposals.");
  }
  if (!Array.isArray(groups) || groups.length === 0) {
    proofErrors.push("admin console adoption registry must include proposalProofGroups.");
    return proofErrors;
  }

  const proposalIds = [];
  for (const [index, group] of groups.entries()) {
    const label = group?.area ?? `group ${index + 1}`;
    if (group?.status !== "implemented") {
      proofErrors.push(`${label}: proposal proof status must be implemented.`);
    }
    for (const property of ["proposalIds", "repoEvidence", "verification"]) {
      const values = group?.[property];
      if (!Array.isArray(values) || values.length === 0 || values.some((entry) => typeof entry !== "string" || entry.trim() === "")) {
        proofErrors.push(`${label}: ${property} must be a non-empty string array.`);
      }
    }
    for (const proposalId of group?.proposalIds ?? []) proposalIds.push(proposalId);
    for (const evidencePath of group?.repoEvidence ?? []) {
      if (!fs.existsSync(fromRepo(evidencePath))) {
        proofErrors.push(`${label}: repo evidence does not exist: ${evidencePath}.`);
      }
    }
  }

  if (proposalIds.length !== expectedCount) {
    proofErrors.push(`admin console proposal proof count ${proposalIds.length} does not match approvedReadyCount ${expectedCount}.`);
  }
  if (new Set(proposalIds).size !== proposalIds.length) {
    proofErrors.push("admin console proposal proof IDs must be unique.");
  }
  for (const proposalId of proposalIds) {
    if (/^ADM-PROP-[A-Z0-9]+-[0-9]{3}$/u.test(proposalId)) continue;
    proofErrors.push(`invalid admin console proposal proof ID: ${proposalId}.`);
  }

  return proofErrors;
}

function adminDebtErrors(value) {
  const debtErrors = [];
  const debts = value?.knownDebt;
  if (!Array.isArray(debts) || debts.length === 0) {
    return ["admin console adoption registry must record knownDebt with stable IDs."];
  }
  const ids = [];
  const allowedStatuses = new Set(["contract-first", "planned", "watch"]);
  for (const [index, debt] of debts.entries()) {
    const label = debt?.id ?? `knownDebt ${index + 1}`;
    ids.push(debt?.id);
    if (!/^ADM-DEBT-[A-Z0-9-]+-[0-9]{3}$/u.test(debt?.id ?? "")) {
      debtErrors.push(`${label}: invalid stable debt ID.`);
    }
    if (!allowedStatuses.has(debt?.status)) {
      debtErrors.push(`${label}: invalid debt status ${debt?.status}.`);
    }
    for (const property of ["area", "impact", "mitigation", "nextAction"]) {
      if (typeof debt?.[property] === "string" && debt[property].trim() !== "") continue;
      debtErrors.push(`${label}: ${property} must be a non-empty string.`);
    }
  }
  if (new Set(ids).size !== ids.length) {
    debtErrors.push("admin console known debt IDs must be unique.");
  }
  return debtErrors;
}

function adminChromeErrors(source) {
  const chromeErrors = [];
  if (!source.includes("<AdminBrandTitle>Catch Admin</AdminBrandTitle>")) {
    chromeErrors.push("admin shell brand must be the single product label Catch Admin.");
  }

  const topbar = source.match(/<AdminTopbar>[\s\S]*?<\/AdminTopbar>/u)?.[0] ?? "";
  if (!topbar.includes("<h1>{topbarTitle}</h1>")) {
    chromeErrors.push("admin top bar must render the route-owned topbarTitle as its single heading.");
  }
  if (/<AdminEyebrow\b|<PageHeader\b|<p\b/u.test(topbar)) {
    chromeErrors.push("admin top bar must not add a kicker, secondary PageHeader, or subtitle.");
  }

  const forbiddenLabels = ["Catch Ops", "sample console", "dev · sample"];
  for (const label of forbiddenLabels) {
    if (!source.toLowerCase().includes(label.toLowerCase())) continue;
    chromeErrors.push(`admin shell must not expose prototype label ${label}.`);
  }
  return chromeErrors;
}

function featureComponentExports() {
  const exports = [];
  for (const filePath of walkFiles(fromRepo("admin/src/features"), ".tsx")) {
    const source = fs.readFileSync(filePath, "utf8");
    const relativePath = relativeToRepo(filePath);
    for (const name of exportedReactComponents(source)) {
      if (!/(?:Screen|Workspace)$/u.test(name)) continue;
      exports.push({source: relativePath, name, label: "feature route/workspace component"});
    }
  }
  return exports;
}

function sharedComponentExports(root, label) {
  const exports = [];
  for (const filePath of walkFiles(fromRepo(root), ".tsx")) {
    const source = fs.readFileSync(filePath, "utf8");
    const relativePath = relativeToRepo(filePath);
    for (const name of exportedReactComponents(source)) {
      exports.push({source: relativePath, name, label});
    }
  }
  return exports;
}

function exportedReactComponents(source) {
  const components = new Set();
  const pattern =
    /\bexport\s+(?:default\s+)?function\s+([A-Z][A-Za-z0-9_]*)\b|\bexport\s+const\s+([A-Z][A-Za-z0-9_]*)\b|\bexport\s+class\s+([A-Z][A-Za-z0-9_]*)\b/gu;
  for (const match of source.matchAll(pattern)) {
    components.add(match[1] ?? match[2] ?? match[3]);
  }
  return components;
}

function walkFiles(directory, extension) {
  const files = [];
  if (!fs.existsSync(directory)) return files;
  for (const entry of fs.readdirSync(directory, {withFileTypes: true})) {
    const fullPath = path.join(directory, entry.name);
    if (entry.isDirectory()) {
      if (entry.name === "dist" || entry.name === "storybook-static") continue;
      files.push(...walkFiles(fullPath, extension));
      continue;
    }
    if (entry.name.endsWith(extension)) files.push(fullPath);
  }
  return files;
}

function readJson(filePath, label) {
  try {
    return JSON.parse(fs.readFileSync(filePath, "utf8"));
  } catch (error) {
    throw new Error(`Unable to read ${label} at ${filePath}: ${error.message}`);
  }
}

function normalizeRepoPath(value) {
  return String(value ?? "").split(path.sep).join("/");
}

function relativeToRepo(filePath) {
  return normalizeRepoPath(path.relative(fromRepo("."), filePath));
}

function storyStatesForComponent(source, componentId) {
  const states = new Set();
  for (const declaration of storyComponentDeclarations(source)) {
    if (declaration.id !== componentId) continue;
    for (const state of declaration.states) states.add(state);
  }
  return states;
}

function storyComponentDeclarations(source) {
  const declarations = [];
  const constants = stringArrayConstants(source);
  const exportPattern = /^export\s+const\s+([A-Za-z0-9_]+)\b/gmu;
  const matches = [...source.matchAll(exportPattern)];

  for (let index = 0; index < matches.length; index += 1) {
    const match = matches[index];
    const exportName = match[1];
    const start = match.index ?? 0;
    const end = matches[index + 1]?.index ?? source.length;
    const block = source.slice(start, end);
    if (!block.includes("catchComponent")) continue;

    const catchComponentIndex = block.indexOf("catchComponent");
    const catchComponentBlock = block.slice(catchComponentIndex);
    const id = firstStringProperty(catchComponentBlock, "id");
    if (!id) continue;

    declarations.push({
      exportName,
      id,
      states: stringArrayProperty(catchComponentBlock, "states", constants),
    });
  }

  return declarations;
}

function stringArrayConstants(source) {
  const constants = new Map();
  const constPattern =
    /const\s+([A-Za-z0-9_]+)\s*=\s*\[([\s\S]*?)\]\s*(?:as\s+const)?\s*;/gu;
  for (const match of source.matchAll(constPattern)) {
    constants.set(match[1], stringValues(match[2]));
  }
  return constants;
}

function firstStringProperty(source, propertyName) {
  const pattern = new RegExp(`${escapeRegExp(propertyName)}:\\s*"([^"]+)"`, "u");
  return source.match(pattern)?.[1] ?? null;
}

function stringArrayProperty(source, propertyName, constants) {
  const inlinePattern = new RegExp(
    `${escapeRegExp(propertyName)}:\\s*\\[([\\s\\S]*?)\\]`,
    "u",
  );
  const inline = source.match(inlinePattern);
  if (inline) return stringValues(inline[1]);

  const referencePattern = new RegExp(
    `${escapeRegExp(propertyName)}:\\s*([A-Za-z0-9_]+)`,
    "u",
  );
  const reference = source.match(referencePattern)?.[1] ?? null;
  return reference ? constants.get(reference) ?? [] : [];
}

function stringValues(source) {
  return [...source.matchAll(/"([^"]+)"/gu)].map((match) => match[1]);
}

function escapeRegExp(value) {
  return String(value).replace(/[.*+?^${}()|[\]\\]/g, "\\$&");
}

function parseArgs(argv) {
  const parsed = {components: null, help: false, selfTest: false, summary: false};
  for (let index = 0; index < argv.length; index += 1) {
    const arg = argv[index];
    if (arg === "--help" || arg === "-h") parsed.help = true;
    else if (arg === "--self-test") parsed.selfTest = true;
    else if (arg === "--summary") parsed.summary = true;
    else if (arg === "--check") {
      // Default mode; accepted for parity with other repo checkers.
    } else if (arg === "--components") parsed.components = requiredValue(argv, ++index, arg);
    else fail(`Unknown argument: ${arg}`);
  }
  return parsed;
}

function requiredValue(argv, index, flag) {
  const value = argv[index];
  if (!value || value.startsWith("--")) fail(`${flag} requires a value.`);
  return value;
}

function printHelp() {
  console.log(`Usage: node tool/web/check_admin_components.mjs [--check] [--summary] [--self-test]

Validates design/admin/components.json against admin feature route/workspace
exports, shared UI primitive exports, shared feedback provider exports, and
ready Storybook catchComponent coverage. It also enforces the restrained admin
shell brand, single-title top-bar contract, and complete approved-proposal proof.
`);
}

function runSelfTest() {
  const source = `
export function AccessReviewScreen() {
  return null;
}

export const AdminMetricCard = () => null;
function PrivateCard() {
  return null;
}
`;
  assert.deepEqual([...exportedReactComponents(source)], ["AccessReviewScreen", "AdminMetricCard"]);

  const relative = relativeToRepo(fromRepo("admin/src/shared/ui/AdminPrimitives/index.ts"));
  assert.equal(relative, "admin/src/shared/ui/AdminPrimitives/index.ts");

  const declarations = storyComponentDeclarations(`
const metricStates = ["default", "attention"];

export const MetricCardStory = {
  parameters: {
    catchComponent: {
      id: "shared_admin_metric_card",
      states: metricStates,
    },
  },
};

export const StatusBannerStory = {
  parameters: {
    catchComponent: {
      id: "shared_status_banner",
      states: ["success", "error"],
    },
  },
};
`);
  assert.deepEqual(declarations, [
    {
      exportName: "MetricCardStory",
      id: "shared_admin_metric_card",
      states: ["default", "attention"],
    },
    {
      exportName: "StatusBannerStory",
      id: "shared_status_banner",
      states: ["success", "error"],
    },
  ]);

  const validChrome = `
    <AdminBrandTitle>Catch Admin</AdminBrandTitle>
    <AdminTopbar><h1>{topbarTitle}</h1><AdminTopbarActions /></AdminTopbar>
  `;
  assert.deepEqual(adminChromeErrors(validChrome), []);
  assert.deepEqual(adminChromeErrors(`
    <AdminBrandTitle>Catch Ops</AdminBrandTitle>
    <AdminTopbar><AdminEyebrow>Supply</AdminEyebrow><h1>Organizers</h1><p>Copy</p></AdminTopbar>
    <span>dev · sample</span>
  `), [
    "admin shell brand must be the single product label Catch Admin.",
    "admin top bar must render the route-owned topbarTitle as its single heading.",
    "admin top bar must not add a kicker, secondary PageHeader, or subtitle.",
    "admin shell must not expose prototype label Catch Ops.",
    "admin shell must not expose prototype label dev · sample.",
  ]);
  assert.deepEqual(adminPresentationCopyErrors("Local preview data is read-only."), []);
  assert.ok(adminPresentationCopyErrors(
    "Sample access application was not found. Generated sample bridge.",
    "fixture.ts",
  ).every((error) => error.startsWith("fixture.ts:")));

  const proofGroup = {
    area: "shared",
    proposalIds: Array.from({length: 68}, (_, index) =>
      `ADM-PROP-SHARED-${String(index + 1).padStart(3, "0")}`),
    status: "implemented",
    repoEvidence: ["admin/src/app/App.tsx"],
    verification: ["web:admin-components"],
  };
  assert.deepEqual(proposalProofErrors({
    approvedProposalTranche: {approvedReadyCount: 68},
    proposalProofGroups: [proofGroup],
  }), []);
  const invalidProofErrors = proposalProofErrors({
    approvedProposalTranche: {approvedReadyCount: 68},
    proposalProofGroups: [{
      ...proofGroup,
      proposalIds: [...proofGroup.proposalIds.slice(0, 67), proofGroup.proposalIds[0]],
      repoEvidence: [],
      verification: [],
    }],
  });
  assert.ok(invalidProofErrors.some((error) => error.includes("unique")));
  assert.ok(invalidProofErrors.some((error) => error.includes("repoEvidence")));
  assert.ok(invalidProofErrors.some((error) => error.includes("verification")));
  assert.deepEqual(adminDebtErrors({knownDebt: [{
    id: "ADM-DEBT-STORYBOOK-STATE-COVERAGE-001",
    status: "planned",
    area: "visual qa",
    impact: "Alternate states need fixtures.",
    mitigation: "Controller tests cover behavior.",
    nextAction: "Add deterministic stories.",
  }]}), []);
  assert.ok(adminDebtErrors({knownDebt: []}).some((error) => error.includes("knownDebt")));

  console.log("Admin component registry checker self-test passed.");
}

function fail(message) {
  console.error(message);
  process.exit(64);
}
