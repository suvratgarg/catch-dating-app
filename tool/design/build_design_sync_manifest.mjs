#!/usr/bin/env node
import crypto from "node:crypto";
import fs from "node:fs";
import path from "node:path";
import {fileURLToPath} from "node:url";
import {conceptMetrics} from "./component_concepts.mjs";
import {fromRepo, relativeToRepo} from "../lib/repo_paths.mjs";

const outputPath = fromRepo("design/sync/catch.design-sync.json");
const componentPath = fromRepo("design/components/catch.components.json");
const capabilityPath = fromRepo("design/sync/live_capabilities.json");

export function buildDesignSyncManifest({componentsDocument, capabilities}) {
  const components = componentsDocument.components ?? [];
  const metrics = conceptMetrics(components);
  const mappings = components.map((component) => ({
    contractId: component.id,
    conceptRole: component.governance?.conceptRole,
    conceptId: component.governance?.conceptId ?? null,
    dartSymbol: component.dart?.symbol,
    dartFile: component.dart?.file,
    figmaName: component.design?.figma?.componentName,
    figmaStatus: component.design?.figma?.status,
    figmaUrl: component.design?.figma?.componentUrl ?? null,
    figmaNodeId: nodeIdFromUrl(component.design?.figma?.componentUrl),
    codeConnectStatus: component.design?.codeConnect?.status,
    codeConnectTemplate: component.design?.codeConnect?.template ?? null,
    claudeHandoffName: component.design?.claude?.handoffName,
    claudeAllowed: component.design?.claude?.allowed === true,
    contractDigest: digest(contractFingerprint(component)),
  }));
  const mappingStates = countBy(mappings, (entry) => entry.figmaStatus ?? "missing");
  const codeConnectStates = countBy(mappings, (entry) => entry.codeConnectStatus ?? "missing");
  return {
    version: 1,
    updated: new Date().toISOString().slice(0, 10),
    sourceOfTruth: {
      behavior: "Flutter sources named by design/components/catch.components.json",
      componentContracts: "design/components/catch.components.json",
      tokens: "design/tokens/catch.tokens.json",
      claudeContext: "design_context_pack/design_system/components.json",
      liveCapabilities: "design/sync/live_capabilities.json",
      generator: "tool/design/build_design_sync_manifest.mjs",
    },
    sourceDigest: digest(componentsDocument),
    capabilities,
    metrics: {
      ...metrics,
      figmaMappingStates: mappingStates,
      codeConnectMappingStates: codeConnectStates,
      claudeAllowed: mappings.filter((entry) => entry.claudeAllowed).length,
      figmaMappedConcepts: mappings.filter(
        (entry) => entry.conceptRole === "concept" && entry.figmaStatus === "mapped",
      ).length,
    },
    spike: {
      componentIds: ["catch.badge", "catch.field"],
      purpose: "Prove code-to-Figma identity, state coverage, Claude handoff, and drift detection before scaling.",
      status: capabilities.figma.fileKey ? "figma-file-ready" : "awaiting-figma-file-approval",
      codeConnectStatus: capabilities.codeConnect.status,
      acceptance: [
        "Figma component exists with variable-bound states",
        "registry componentUrl resolves to the published component node",
        "contract digest matches the generated Claude context",
        "Code Connect is mapped only when the account tier supports publication",
        "a deliberately stale or incomplete mapping fails the gate",
      ],
    },
    mappings,
  };
}

export function validateDesignSyncManifest(manifest, {requireLive = false} = {}) {
  const problems = [];
  const ids = new Set();
  for (const entry of manifest.mappings ?? []) {
    if (ids.has(entry.contractId)) problems.push(`${entry.contractId}: duplicate mapping`);
    ids.add(entry.contractId);
    if (entry.figmaStatus === "mapped" && (!entry.figmaUrl || !entry.figmaNodeId)) {
      problems.push(`${entry.contractId}: mapped Figma entry requires a node-specific URL`);
    }
    if (entry.codeConnectStatus === "mapped" && !entry.codeConnectTemplate) {
      problems.push(`${entry.contractId}: mapped Code Connect entry requires a template`);
    }
    if (!entry.contractDigest) problems.push(`${entry.contractId}: missing contract digest`);
  }
  for (const spikeId of manifest.spike?.componentIds ?? []) {
    const entry = (manifest.mappings ?? []).find((mapping) => mapping.contractId === spikeId);
    if (!entry) problems.push(`${spikeId}: missing spike mapping`);
    if (requireLive && entry?.figmaStatus !== "mapped") {
      problems.push(`${spikeId}: live Figma mapping is required`);
    }
  }
  if (
    requireLive &&
    manifest.capabilities?.codeConnect?.status !== "available" &&
    (manifest.spike?.componentIds ?? []).some((id) =>
      (manifest.mappings ?? []).find((entry) => entry.contractId === id)?.codeConnectStatus !== "mapped"
    )
  ) {
    problems.push("Badge + Field Code Connect spike is blocked by live account capability");
  }
  return problems.sort();
}

function main() {
  const check = process.argv.includes("--check");
  const requireLive = process.argv.includes("--require-live");
  const document = JSON.parse(fs.readFileSync(componentPath, "utf8"));
  const capabilities = JSON.parse(fs.readFileSync(capabilityPath, "utf8"));
  const manifest = buildDesignSyncManifest({componentsDocument: document, capabilities});
  const problems = validateDesignSyncManifest(manifest, {requireLive});
  if (problems.length > 0) fail(problems);
  if (check) {
    if (!fs.existsSync(outputPath)) fail([`${relativeToRepo(outputPath)} is missing`]);
    const current = JSON.parse(fs.readFileSync(outputPath, "utf8"));
    const comparable = {...current, updated: manifest.updated};
    if (JSON.stringify(comparable, null, 2) !== JSON.stringify(manifest, null, 2)) {
      fail([`${relativeToRepo(outputPath)} is stale; run node tool/design/build_design_sync_manifest.mjs`]);
    }
    console.log(`Design sync manifest check passed (${manifest.metrics.conceptCount} concepts, ${manifest.metrics.figmaMappingStates.mapped ?? 0} Figma mappings).`);
    return;
  }
  fs.mkdirSync(path.dirname(outputPath), {recursive: true});
  fs.writeFileSync(outputPath, `${JSON.stringify(manifest, null, 2)}\n`);
  console.log(`Wrote ${relativeToRepo(outputPath)} (${manifest.mappings.length} contracts).`);
}

function contractFingerprint(component) {
  return {
    id: component.id,
    dart: component.dart,
    concept: component.governance,
    props: component.contract?.props,
    states: component.contract?.states,
    members: component.contract?.members,
    tokens: component.contract?.tokens,
  };
}

function digest(value) {
  return crypto.createHash("sha256").update(JSON.stringify(value)).digest("hex");
}

function nodeIdFromUrl(value) {
  if (!value) return null;
  try {
    const url = new URL(value);
    return url.searchParams.get("node-id")?.replace(/-/gu, ":") ?? null;
  } catch {
    return null;
  }
}

function countBy(values, keyFor) {
  const counts = {};
  for (const value of values) {
    const key = keyFor(value);
    counts[key] = (counts[key] ?? 0) + 1;
  }
  return Object.fromEntries(Object.entries(counts).sort(([a], [b]) => a.localeCompare(b)));
}

function fail(problems) {
  console.error("Design sync manifest check failed:");
  for (const problem of problems) console.error(`- ${problem}`);
  process.exit(1);
}

if (process.argv[1] && path.resolve(process.argv[1]) === fileURLToPath(import.meta.url)) main();
