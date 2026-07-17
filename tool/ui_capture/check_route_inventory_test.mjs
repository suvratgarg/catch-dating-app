import assert from "node:assert/strict";
import test from "node:test";
import {isUnnamedRedirectOnly} from "./check_route_inventory.mjs";

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
