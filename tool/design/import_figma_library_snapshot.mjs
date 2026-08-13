#!/usr/bin/env node
import crypto from "node:crypto";
import fs from "node:fs";
import path from "node:path";
import {fileURLToPath} from "node:url";
import {fromRepo, relativeToRepo} from "../lib/repo_paths.mjs";

const defaultOutputPath = fromRepo("design/sync/figma_library_snapshot.json");

export function normalizeFigmaLibrarySnapshot({
  webhook,
  fileResponse,
  reviewSnapshots = {},
}) {
  if (webhook?.event_type !== "LIBRARY_PUBLISH") {
    throw new Error("webhook event_type must be LIBRARY_PUBLISH");
  }
  if (!webhook.file_key) throw new Error("webhook file_key is required");
  if (!fileResponse?.document && !fileResponse?.nodes) {
    throw new Error("hydrated Figma file response must contain document or nodes");
  }

  const metadataByNodeId = new Map([
    ...Object.entries(fileResponse.components ?? {}),
    ...Object.entries(fileResponse.componentSets ?? {}),
  ]);
  const nodes = [];
  const roots = fileResponse.document
    ? [fileResponse.document]
    : Object.values(fileResponse.nodes ?? {}).map((entry) => entry?.document).filter(Boolean);
  for (const root of roots) collectComponentNodes(root, nodes, metadataByNodeId);

  const components = [...new Map(nodes.map((node) => [node.nodeId, node])).values()]
    .sort((a, b) => a.name.localeCompare(b.name) || a.nodeId.localeCompare(b.nodeId));
  const snapshotRows = components
    .filter((component) => reviewSnapshots[component.nodeId])
    .map((component) => ({
      nodeId: component.nodeId,
      ...normalizeReviewSnapshot(reviewSnapshots[component.nodeId]),
    }));
  const publishedComponentKeys = [
    ...(webhook.created_components ?? []),
    ...(webhook.modified_components ?? []),
    ...(webhook.deleted_components ?? []),
  ].map((entry) => entry.key).filter(Boolean).sort();
  const core = {
    version: 1,
    status: "captured",
    capturedAt: webhook.timestamp ?? new Date().toISOString(),
    source: {
      captureMethod: "library-publish-webhook",
      eventType: webhook.event_type,
      fileKey: webhook.file_key,
      fileName: webhook.file_name ?? fileResponse.name ?? null,
      fileVersion: fileResponse.version ?? null,
      lastModified: fileResponse.lastModified ?? null,
      webhookId: webhook.webhook_id === undefined ? null : String(webhook.webhook_id),
      versionHistoryId: null,
      publishedComponentKeys,
    },
    components,
    reviewSnapshots: snapshotRows,
  };
  return {...core, snapshotDigest: digest(core)};
}

export function normalizeFigmaMcpSnapshot({
  capture,
  reviewSnapshots = {},
}) {
  if (capture?.version !== 1) throw new Error("MCP capture version must be 1");
  if (!capture.capturedAt) throw new Error("MCP capture capturedAt is required");
  if (!capture.source?.fileKey) throw new Error("MCP capture source.fileKey is required");
  if (!(capture.components?.length > 0)) {
    throw new Error("MCP capture requires at least one component");
  }
  const components = capture.components.map((component) => {
    const boundVariableIds = [...new Set(
      (component.boundVariableIds ?? []).map(String).filter(Boolean),
    )].sort();
    return {
      nodeId: String(component.nodeId ?? ""),
      componentKey: component.componentKey ?? null,
      name: String(component.name ?? ""),
      type: component.type,
      description: component.description ?? "",
      publishStatus: component.publishStatus ?? null,
      propertyDefinitions: normalizeCapturedPropertyDefinitions(
        component.propertyDefinitions ?? [],
      ),
      boundVariableRefs: [],
      boundVariableIds,
      boundVariableCount: component.boundVariableCount ?? 0,
      variantCount: component.variantCount ?? null,
    };
  }).sort((a, b) => a.name.localeCompare(b.name) || a.nodeId.localeCompare(b.nodeId));
  const snapshotRows = components
    .filter((component) => reviewSnapshots[component.nodeId])
    .map((component) => ({
      nodeId: component.nodeId,
      ...normalizeReviewSnapshot(reviewSnapshots[component.nodeId]),
    }));
  const core = {
    version: 1,
    status: "captured",
    capturedAt: capture.capturedAt,
    source: {
      captureMethod: "figma-mcp",
      eventType: null,
      fileKey: capture.source.fileKey,
      fileName: capture.source.fileName ?? null,
      fileVersion: capture.source.fileVersion ?? null,
      lastModified: capture.source.lastModified ?? null,
      webhookId: null,
      versionHistoryId: capture.source.versionHistoryId ?? null,
      publishedComponentKeys: [...new Set(
        (capture.source.publishedComponentKeys ?? []).map(String).filter(Boolean),
      )].sort(),
    },
    components,
    reviewSnapshots: snapshotRows,
  };
  return {...core, snapshotDigest: digest(core)};
}

export function validateFigmaLibrarySnapshot(snapshot) {
  const problems = [];
  if (snapshot?.version !== 1) problems.push("snapshot version must be 1");
  if (!["unavailable", "captured"].includes(snapshot?.status)) {
    problems.push("snapshot status must be unavailable or captured");
  }
  if (snapshot?.status === "captured") {
    if (!snapshot.source?.fileKey) problems.push("captured snapshot requires source.fileKey");
    if (!snapshot.capturedAt) problems.push("captured snapshot requires capturedAt");
    if (![
      "figma-mcp",
      "library-publish-webhook",
    ].includes(snapshot.source?.captureMethod)) {
      problems.push("captured snapshot requires a supported source.captureMethod");
    }
    const comparable = {...snapshot};
    delete comparable.snapshotDigest;
    if (snapshot.snapshotDigest !== digest(comparable)) {
      problems.push("captured snapshot digest is stale");
    }
  }
  const nodeIds = new Set();
  for (const component of snapshot?.components ?? []) {
    if (!component.nodeId || !component.name) {
      problems.push("each Figma component requires nodeId and name");
      continue;
    }
    if (nodeIds.has(component.nodeId)) problems.push(`${component.nodeId}: duplicate node id`);
    nodeIds.add(component.nodeId);
    if (!["COMPONENT", "COMPONENT_SET"].includes(component.type)) {
      problems.push(`${component.nodeId}: unsupported component type ${component.type}`);
    }
    if (
      component.publishStatus !== null &&
      component.publishStatus !== undefined &&
      !/^[A-Z_]+$/u.test(component.publishStatus)
    ) {
      problems.push(`${component.nodeId}: invalid publish status ${component.publishStatus}`);
    }
    if (snapshot.source?.captureMethod === "figma-mcp") {
      const distinctIds = new Set(component.boundVariableIds ?? []);
      if (distinctIds.size !== (component.boundVariableIds ?? []).length) {
        problems.push(`${component.nodeId}: duplicate bound variable id`);
      }
      if (component.boundVariableCount < distinctIds.size) {
        problems.push(`${component.nodeId}: bound variable count is smaller than distinct ids`);
      }
    } else {
      const bindingCount = (component.boundVariableRefs ?? [])
        .reduce((total, reference) => total + (reference.variableIds?.length ?? 0), 0);
      if (component.boundVariableCount !== bindingCount) {
        problems.push(`${component.nodeId}: bound variable count is stale`);
      }
    }
  }
  for (const review of snapshot?.reviewSnapshots ?? []) {
    if (!nodeIds.has(review.nodeId)) problems.push(`${review.nodeId}: review snapshot has no component`);
    if (!review.path || !review.sha256) problems.push(`${review.nodeId}: review snapshot requires path and sha256`);
    if (!/^[a-f0-9]{64}$/u.test(review.sha256 ?? "")) {
      problems.push(`${review.nodeId}: review snapshot sha256 must be a lowercase digest`);
    }
  }
  return [...new Set(problems)].sort();
}

function collectComponentNodes(node, output, metadataByNodeId) {
  if (!node || typeof node !== "object") return;
  if (node.type === "COMPONENT" || node.type === "COMPONENT_SET") {
    const metadata = metadataByNodeId.get(node.id) ?? {};
    const boundVariableRefs = collectBoundVariableRefs(node);
    output.push({
      nodeId: node.id,
      componentKey: metadata.key ?? null,
      name: node.name,
      type: node.type,
      description: node.description ?? metadata.description ?? "",
      publishStatus: "CURRENT",
      propertyDefinitions: normalizePropertyDefinitions(node.componentPropertyDefinitions ?? {}),
      boundVariableRefs,
      boundVariableIds: [...new Set(
        boundVariableRefs.flatMap((reference) => reference.variableIds),
      )].sort(),
      boundVariableCount: boundVariableRefs
        .reduce((total, reference) => total + reference.variableIds.length, 0),
    });
  }
  for (const child of node.children ?? []) collectComponentNodes(child, output, metadataByNodeId);
}

function normalizeCapturedPropertyDefinitions(definitions) {
  return definitions.map((definition) => ({
    name: String(definition.name ?? ""),
    normalizedName: normalizePropertyName(definition.name ?? ""),
    type: definition.type,
    defaultValue: definition.defaultValue ?? null,
    variantOptions: [...(definition.variantOptions ?? [])].map(String).sort(),
  })).sort((a, b) =>
    a.normalizedName.localeCompare(b.normalizedName) || a.name.localeCompare(b.name));
}

function normalizePropertyDefinitions(definitions) {
  return Object.entries(definitions).map(([name, definition]) => ({
    name,
    normalizedName: normalizePropertyName(name),
    type: definition.type,
    defaultValue: definition.defaultValue ?? null,
    variantOptions: [...(definition.variantOptions ?? [])].map(String).sort(),
  })).sort((a, b) => a.normalizedName.localeCompare(b.normalizedName) || a.name.localeCompare(b.name));
}

function collectBoundVariableRefs(root) {
  const references = [];
  visit(root);
  return references.sort((a, b) =>
    a.nodeId.localeCompare(b.nodeId) || a.field.localeCompare(b.field));

  function visit(node) {
    for (const [field, value] of Object.entries(node.boundVariables ?? {})) {
      const aliases = Array.isArray(value) ? value : [value];
      const variableIds = aliases
        .map((alias) => alias?.id)
        .filter(Boolean)
        .map(String)
        .sort();
      if (variableIds.length > 0) {
        references.push({nodeId: node.id, field, variableIds});
      }
    }
    for (const child of node.children ?? []) visit(child);
  }
}

function normalizePropertyName(value) {
  return String(value).split("#", 1)[0]
    .replace(/([a-z0-9])([A-Z])/gu, "$1_$2")
    .replace(/[^A-Za-z0-9]+/gu, "_")
    .replace(/^_+|_+$/gu, "")
    .toLowerCase();
}

function normalizeReviewSnapshot(value) {
  const snapshotPath = typeof value === "string" ? value : value.path;
  const suppliedDigest = typeof value === "string" ? null : value.sha256;
  const sourceNodeId = typeof value === "string" ? null : value.sourceNodeId ?? null;
  if (suppliedDigest) return {path: snapshotPath, sha256: suppliedDigest, sourceNodeId};
  const absolutePath = fromRepo(snapshotPath);
  if (!fs.existsSync(absolutePath)) {
    throw new Error(`${snapshotPath}: review snapshot file is missing`);
  }
  return {
    path: snapshotPath,
    sha256: crypto.createHash("sha256").update(fs.readFileSync(absolutePath)).digest("hex"),
    sourceNodeId,
  };
}

function digest(value) {
  return crypto.createHash("sha256").update(JSON.stringify(value)).digest("hex");
}

function runSelfTest() {
  const snapshot = normalizeFigmaLibrarySnapshot({
    webhook: {
      event_type: "LIBRARY_PUBLISH",
      file_key: "file-key",
      file_name: "Catch Design System",
      timestamp: "2026-07-18T00:00:00Z",
      webhook_id: "42",
      created_components: [{key: "component-key", name: "Catch/Badge"}],
    },
    fileResponse: {
      name: "Catch Design System",
      version: "7",
      components: {"1:2": {key: "component-key"}},
      document: {
        id: "0:0",
        type: "DOCUMENT",
        children: [{
          id: "1:2",
          type: "COMPONENT_SET",
          name: "Catch/Badge",
          componentPropertyDefinitions: {
            "Tone#123": {type: "VARIANT", defaultValue: "neutral", variantOptions: ["danger", "neutral"]},
          },
          children: [{
            id: "1:4",
            type: "RECTANGLE",
            boundVariables: {fills: {type: "VARIABLE_ALIAS", id: "VariableID:brand"}},
          }],
        }],
      },
    },
    reviewSnapshots: {"1:2": {path: "design/sync/snapshots/badge.png", sha256: "a".repeat(64)}},
  });
  if (validateFigmaLibrarySnapshot(snapshot).length > 0) {
    throw new Error("valid hydrated Figma snapshot failed validation");
  }
  if (snapshot.components[0]?.propertyDefinitions[0]?.normalizedName !== "tone") {
    throw new Error("component property suffix/name normalization failed");
  }
  if (snapshot.components[0]?.boundVariableCount !== 1) {
    throw new Error("descendant bound-variable evidence was not captured");
  }
  const mcpSnapshot = normalizeFigmaMcpSnapshot({
    capture: {
      version: 1,
      capturedAt: "2026-08-13T00:00:00Z",
      source: {fileKey: "file-key", fileName: "Catch Foundations"},
      components: [{
        nodeId: "2:1",
        componentKey: "component-key",
        name: "Catch/Field",
        type: "COMPONENT_SET",
        publishStatus: "UNPUBLISHED",
        propertyDefinitions: [{name: "Title#42", type: "TEXT", defaultValue: "Title"}],
        boundVariableIds: ["VariableID:surface"],
        boundVariableCount: 12,
      }],
    },
    reviewSnapshots: {
      "2:1": {
        path: "design/sync/snapshots/field.png",
        sha256: "b".repeat(64),
        sourceNodeId: "2:9",
      },
    },
  });
  if (validateFigmaLibrarySnapshot(mcpSnapshot).length > 0) {
    throw new Error("valid Figma MCP snapshot failed validation");
  }
  if (mcpSnapshot.components[0]?.propertyDefinitions[0]?.normalizedName !== "title") {
    throw new Error("MCP property suffix/name normalization failed");
  }
  let knownBadFailed = false;
  try {
    normalizeFigmaLibrarySnapshot({webhook: {event_type: "PING"}, fileResponse: {document: {}}});
  } catch {
    knownBadFailed = true;
  }
  if (!knownBadFailed) throw new Error("known-bad non-publish webhook must fail");
  console.log("Figma library snapshot importer self-test passed.");
}

function valueAfter(args, flag) {
  const index = args.indexOf(flag);
  if (index === -1) return null;
  const value = args[index + 1];
  if (!value || value.startsWith("--")) throw new Error(`${flag} requires a value`);
  return value;
}

function resolveInputPath(value) {
  return path.isAbsolute(value) ? value : fromRepo(value);
}

function main() {
  const args = process.argv.slice(2);
  if (args.includes("--help") || args.includes("-h")) {
    console.log(`Usage:
  node tool/design/import_figma_library_snapshot.mjs --check
  node tool/design/import_figma_library_snapshot.mjs --self-test
  node tool/design/import_figma_library_snapshot.mjs --mcp-capture <json> [--review-snapshots <json>] [--out <json>]
  node tool/design/import_figma_library_snapshot.mjs --webhook <json> --file-response <json> [--review-snapshots <json>] [--out <json>]

Use --mcp-capture for a read-only Figma MCP discovery receipt. It records live
component properties, bindings, review evidence, and publication status without
claiming that an unpublished component is a published library item. The
LIBRARY_PUBLISH path still requires a hydrated GET-file or GET-file-nodes
response. Mapping to Catch contract ids remains generated from deterministic
component names.
`);
    return;
  }
  if (args.includes("--self-test")) return runSelfTest();
  const output = fromRepo(valueAfter(args, "--out") ?? relativeToRepo(defaultOutputPath));
  if (args.includes("--check")) {
    const snapshot = JSON.parse(fs.readFileSync(output, "utf8"));
    const problems = validateFigmaLibrarySnapshot(snapshot);
    if (problems.length > 0) throw new Error(problems.join("\n"));
    console.log(`Figma library snapshot check passed (${snapshot.components.length} component nodes).`);
    return;
  }
  const webhookPath = valueAfter(args, "--webhook");
  const fileResponsePath = valueAfter(args, "--file-response");
  const mcpCapturePath = valueAfter(args, "--mcp-capture");
  if (mcpCapturePath && (webhookPath || fileResponsePath)) {
    throw new Error("--mcp-capture cannot be combined with --webhook or --file-response");
  }
  if (!mcpCapturePath && (!webhookPath || !fileResponsePath)) {
    throw new Error("--mcp-capture or both --webhook and --file-response are required");
  }
  const reviewPath = valueAfter(args, "--review-snapshots");
  const reviewSnapshots = reviewPath
    ? JSON.parse(fs.readFileSync(resolveInputPath(reviewPath), "utf8"))
    : {};
  const snapshot = mcpCapturePath
    ? normalizeFigmaMcpSnapshot({
      capture: JSON.parse(fs.readFileSync(resolveInputPath(mcpCapturePath), "utf8")),
      reviewSnapshots,
    })
    : normalizeFigmaLibrarySnapshot({
      webhook: JSON.parse(fs.readFileSync(resolveInputPath(webhookPath), "utf8")),
      fileResponse: JSON.parse(fs.readFileSync(resolveInputPath(fileResponsePath), "utf8")),
      reviewSnapshots,
    });
  const problems = validateFigmaLibrarySnapshot(snapshot);
  if (problems.length > 0) throw new Error(problems.join("\n"));
  fs.mkdirSync(path.dirname(output), {recursive: true});
  fs.writeFileSync(output, `${JSON.stringify(snapshot, null, 2)}\n`);
  console.log(`Wrote ${relativeToRepo(output)} (${snapshot.components.length} component nodes).`);
}

if (process.argv[1] && path.resolve(process.argv[1]) === fileURLToPath(import.meta.url)) {
  try {
    main();
  } catch (error) {
    console.error(`Figma library snapshot import failed: ${error.message}`);
    process.exit(1);
  }
}
