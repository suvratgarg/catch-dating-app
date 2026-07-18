#!/usr/bin/env node
import assert from "node:assert/strict";
import fs from "node:fs";
import test from "node:test";
import {
  buildDesignSyncManifest,
  compareFigmaProperties,
  expectedFigmaProperties,
  validateDesignSyncManifest,
} from "./build_design_sync_manifest.mjs";
import {
  buildCapturedClaudeDesignReceipt,
  buildClaudeDesignHandoffRequest,
} from "./claude_design_handoff.mjs";

const capabilities = {
  figma: {fileKey: null},
  codeConnect: {status: "blocked-plan-tier"},
};
const component = (id, figma = {}, codeConnect = {}) => ({
  id,
  dart: {symbol: id === "catch.badge" ? "CatchBadge" : "CatchField", file: `lib/${id}.dart`},
  governance: {conceptRole: "concept", conceptId: id},
  design: {
    figma: {status: "unmapped", componentName: id, componentUrl: null, ...figma},
    codeConnect: {status: "planned", template: null, ...codeConnect},
    claude: {handoffName: id, allowed: true},
  },
  contract: {props: [], states: [], members: [], tokens: []},
});

test("known-bad mapped entries without node URLs fail", () => {
  const manifest = buildDesignSyncManifest({
    componentsDocument: {components: [
      component("catch.badge", {status: "mapped", componentUrl: "https://figma.com/design/key/file"}),
      component("catch.field"),
    ]},
    capabilities,
  });
  assert.match(validateDesignSyncManifest(manifest).join("\n"), /node-specific URL/u);
});

test("live spike gate stays red when Figma and Code Connect are unavailable", () => {
  const manifest = buildDesignSyncManifest({
    componentsDocument: {components: [component("catch.badge"), component("catch.field")]},
    capabilities,
  });
  const failures = validateDesignSyncManifest(manifest, {requireLive: true}).join("\n");
  assert.match(failures, /catch\.badge: current live Figma mapping is required/u);
  assert.match(failures, /blocked by live account capability/u);
});

test("snapshot names generate current mappings without hand-edited URLs", () => {
  const liveCapabilities = {
    figma: {fileKey: "file-key"},
    codeConnect: {status: "available"},
  };
  const componentsDocument = {
    components: [component("catch.badge"), component("catch.field")],
  };
  const manifest = buildDesignSyncManifest({
    componentsDocument,
    capabilities: liveCapabilities,
    figmaSnapshot: {
      status: "captured",
      source: {fileKey: "file-key"},
      components: [
        {nodeId: "1:2", name: "catch.badge", componentKey: "badge-key", propertyDefinitions: [], boundVariableCount: 0, boundVariableRefs: []},
        {nodeId: "1:3", name: "catch.field", componentKey: "field-key", propertyDefinitions: [], boundVariableCount: 0, boundVariableRefs: []},
      ],
      reviewSnapshots: [],
    },
  });
  assert.equal(manifest.metrics.figmaMappingStates.current, 2);
  assert.equal(manifest.mappings[0].figmaNodeId, "1:2");
  assert.match(manifest.mappings[0].figmaUrl, /node-id=1-2/u);
});

test("known-bad Figma property drift is deterministic", () => {
  const withProps = component("catch.badge");
  withProps.contract.props = [{
    name: "tone",
    type: "enum",
    default: "neutral",
    values: ["neutral", "danger"],
  }];
  withProps.contract.states = ["resting", "active"];
  const expected = expectedFigmaProperties(withProps);
  const drift = compareFigmaProperties(expected, [{
    name: "Tone#42",
    normalizedName: "tone",
    type: "BOOLEAN",
    variantOptions: [],
  }]).join("\n");
  assert.match(drift, /tone: expected VARIANT, found BOOLEAN/u);
  assert.match(drift, /tone: variant options differ/u);
  assert.match(drift, /missing Figma property reviewState/u);
});

test("known-bad stale Claude context fails", () => {
  const componentsDocument = {
    components: [component("catch.badge"), component("catch.field")],
  };
  const manifest = buildDesignSyncManifest({
    componentsDocument,
    capabilities,
    claudeContextDocument: {components: [component("catch.badge")]},
  });
  assert.match(validateDesignSyncManifest(manifest).join("\n"), /Claude context is stale/u);
});

test("known-bad Claude Design state receipt fails", () => {
  const componentsDocument = {
    components: [component("catch.badge"), component("catch.field")],
  };
  componentsDocument.components[0].contract.states = ["resting", "active"];
  const request = buildClaudeDesignHandoffRequest(componentsDocument);
  const receipt = buildCapturedClaudeDesignReceipt(request, {
    capturedAt: "2026-07-18T00:00:00Z",
    proposalRef: "claude-design://known-bad-state",
  });
  receipt.components[0].supportedStatesDigest = "stale";
  const manifest = buildDesignSyncManifest({
    componentsDocument,
    capabilities,
    claudeHandoffRequest: request,
    claudeDesignReceipt: receipt,
  });
  assert.equal(manifest.claudeDesign.receiptStatus, "stale");
  assert.match(
    validateDesignSyncManifest(manifest).join("\n"),
    /catch\.badge: Claude Design supported states are stale/u,
  );
});

test("require-live rejects missing visual proof and unpublished templates", () => {
  const liveCapabilities = {
    figma: {fileKey: "file-key"},
    codeConnect: {status: "available"},
  };
  const componentsDocument = {
    components: [component("catch.badge"), component("catch.field")],
  };
  const manifest = buildDesignSyncManifest({
    componentsDocument,
    capabilities: liveCapabilities,
    figmaSnapshot: {
      status: "captured",
      source: {fileKey: "file-key"},
      components: [
        {nodeId: "1:2", name: "catch.badge", propertyDefinitions: [], boundVariableCount: 0, boundVariableRefs: []},
        {nodeId: "1:3", name: "catch.field", propertyDefinitions: [], boundVariableCount: 0, boundVariableRefs: []},
      ],
      reviewSnapshots: [],
    },
  });
  const failures = validateDesignSyncManifest(manifest, {requireLive: true}).join("\n");
  assert.match(failures, /catch\.badge: variable-bound Figma evidence is required/u);
  assert.match(failures, /catch\.field: review snapshot evidence is required/u);
  assert.match(failures, /catch\.badge: published Code Connect mapping is required/u);
});

test("fully evidenced Badge and Field spike passes the live gate", () => {
  const liveCapabilities = {
    figma: {fileKey: "file-key"},
    codeConnect: {status: "available"},
  };
  const componentsDocument = {
    components: [
      component("catch.badge", {}, {status: "mapped", template: "design/code_connect/CatchBadge.figma.ts"}),
      component("catch.field", {}, {status: "mapped", template: "design/code_connect/CatchField.figma.ts"}),
    ],
  };
  const claudeHandoffRequest = buildClaudeDesignHandoffRequest(componentsDocument);
  const manifest = buildDesignSyncManifest({
    componentsDocument,
    capabilities: liveCapabilities,
    claudeHandoffRequest,
    claudeDesignReceipt: buildCapturedClaudeDesignReceipt(claudeHandoffRequest, {
      capturedAt: "2026-07-18T00:00:00Z",
      proposalRef: "claude-design://badge-field-spike",
    }),
    figmaSnapshot: {
      status: "captured",
      source: {fileKey: "file-key"},
      components: [
        {nodeId: "1:2", name: "catch.badge", propertyDefinitions: [], boundVariableCount: 1, boundVariableRefs: [{nodeId: "1:4", field: "fills", variableIds: ["VariableID:brand"]}]},
        {nodeId: "1:3", name: "catch.field", propertyDefinitions: [], boundVariableCount: 1, boundVariableRefs: [{nodeId: "1:5", field: "fills", variableIds: ["VariableID:surface"]}]},
      ],
      reviewSnapshots: [
        {nodeId: "1:2", path: "badge.png", sha256: "a".repeat(64)},
        {nodeId: "1:3", path: "field.png", sha256: "b".repeat(64)},
      ],
    },
  });
  assert.deepEqual(validateDesignSyncManifest(manifest, {requireLive: true}), []);
  assert.equal(manifest.spike.status, "figma-claude-round-trip-ready");
});

test("real Badge and Field contract projection round-trips and fails on one removed property", () => {
  const realDocument = JSON.parse(fs.readFileSync(
    new URL("../../design/components/catch.components.json", import.meta.url),
    "utf8",
  ));
  for (const item of realDocument.components) {
    if (!["catch.badge", "catch.field"].includes(item.id)) continue;
    item.design.codeConnect = {
      ...item.design.codeConnect,
      status: "mapped",
      template: `design/code_connect/${item.dart.symbol}.figma.ts`,
    };
  }
  const spikeComponents = realDocument.components
    .filter((item) => ["catch.badge", "catch.field"].includes(item.id));
  const snapshot = {
    status: "captured",
    source: {fileKey: "file-key"},
    components: spikeComponents.map((item, index) => ({
      nodeId: `1:${index + 2}`,
      name: item.design.figma.componentName,
      propertyDefinitions: expectedFigmaProperties(item),
      boundVariableCount: 1,
      boundVariableRefs: [{
        nodeId: `2:${index + 2}`,
        field: "fills",
        variableIds: [`VariableID:${item.id}`],
      }],
    })),
    reviewSnapshots: spikeComponents.map((item, index) => ({
      nodeId: `1:${index + 2}`,
      path: `${item.id}.png`,
      sha256: String(index + 1).repeat(64),
    })),
  };
  const liveCapabilities = {
    figma: {fileKey: "file-key"},
    codeConnect: {status: "available"},
  };
  const claudeHandoffRequest = buildClaudeDesignHandoffRequest(realDocument);
  const claudeDesignReceipt = buildCapturedClaudeDesignReceipt(claudeHandoffRequest, {
    capturedAt: "2026-07-18T00:00:00Z",
    proposalRef: "claude-design://real-contract-round-trip",
  });
  const manifest = buildDesignSyncManifest({
    componentsDocument: realDocument,
    claudeContextDocument: realDocument,
    capabilities: liveCapabilities,
    figmaSnapshot: snapshot,
    claudeHandoffRequest,
    claudeDesignReceipt,
  });
  assert.deepEqual(validateDesignSyncManifest(manifest, {requireLive: true}), []);
  assert.equal(manifest.metrics.figmaMappingStates.current, 2);

  const knownBadSnapshot = structuredClone(snapshot);
  knownBadSnapshot.components[0].propertyDefinitions =
    knownBadSnapshot.components[0].propertyDefinitions
      .filter((property) => property.normalizedName !== "review_state");
  const knownBad = buildDesignSyncManifest({
    componentsDocument: realDocument,
    claudeContextDocument: realDocument,
    capabilities: liveCapabilities,
    figmaSnapshot: knownBadSnapshot,
    claudeHandoffRequest,
    claudeDesignReceipt,
  });
  const badge = knownBad.mappings.find((entry) => entry.contractId === "catch.badge");
  assert.equal(badge.figmaStatus, "stale");
  assert.match(badge.figmaDrift.join("\n"), /missing Figma property reviewState/u);
  assert.match(
    validateDesignSyncManifest(knownBad, {requireLive: true}).join("\n"),
    /catch\.badge: current live Figma mapping is required/u,
  );
});
