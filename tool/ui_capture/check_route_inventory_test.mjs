import assert from "node:assert/strict";
import test from "node:test";
import {
  extractGoRouterConfigurationBlock,
  isUnnamedRedirectOnly,
} from "./check_route_inventory.mjs";

test("extracts returned and lifecycle-owned GoRouter configurations", () => {
  for (const source of [
    "return GoRouter(routes: const []);",
    "final router = GoRouter(routes: const []); ref.onDispose(router.dispose); return router;",
  ]) {
    const block = extractGoRouterConfigurationBlock(source);
    assert.match(block.body, /routes:\s*const \[\]/u);
  }
});

test("allows only an unnamed redirect-only legacy route", () => {
  assert.equal(isUnnamedRedirectOnly({
    redirectExpression: "(_, state) => legacyRedirect(state.uri)",
    builderExpression: "",
    pageBuilderExpression: "",
  }), true);
});

test("rejects unnamed routes that can render a page", () => {
  assert.equal(isUnnamedRedirectOnly({
    redirectExpression: "(_, state) => legacyRedirect(state.uri)",
    builderExpression: "(_, _) => const LegacyScreen()",
    pageBuilderExpression: "",
  }), false);
  assert.equal(isUnnamedRedirectOnly({
    redirectExpression: "",
    builderExpression: "",
    pageBuilderExpression: "",
  }), false);
});
