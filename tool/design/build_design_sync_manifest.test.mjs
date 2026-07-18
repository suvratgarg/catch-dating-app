#!/usr/bin/env node
import assert from "node:assert/strict";
import test from "node:test";
import {
  buildDesignSyncManifest,
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
  assert.match(failures, /catch\.badge: live Figma mapping is required/u);
  assert.match(failures, /blocked by live account capability/u);
});
