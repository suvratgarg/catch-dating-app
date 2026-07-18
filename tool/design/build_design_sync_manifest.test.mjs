#!/usr/bin/env node
import assert from "node:assert/strict";
import test from "node:test";
import {
  buildDesignSyncManifest,
  compareFigmaProperties,
  expectedFigmaProperties,
  validateDesignSyncManifest,
} from "./build_design_sync_manifest.mjs";

const capabilities = {
  figma: {fileKey: null},
  codeConnect: {status: "blocked-plan-tier"},
};
const component = (id, figma = {}) => ({
  id,
  dart: {symbol: id === "catch.badge" ? "CatchBadge" : "CatchField", file: `lib/${id}.dart`},
  governance: {conceptRole: "concept", conceptId: id},
  design: {
    figma: {status: "unmapped", componentName: id, componentUrl: null, ...figma},
    codeConnect: {status: "planned", template: null},
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
        {nodeId: "1:2", name: "catch.badge", componentKey: "badge-key", propertyDefinitions: []},
        {nodeId: "1:3", name: "catch.field", componentKey: "field-key", propertyDefinitions: []},
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
