import assert from "node:assert/strict";
import test from "node:test";
import {
  matchesGlobPath,
  matchesScopePath,
  normalizeGlobPath,
} from "./path_glob.mjs";

test("glob matching is normalized, dot-safe, and supports zero-depth globstars", () => {
  assert.equal(normalizeGlobPath("./tool//"), "tool");
  assert.equal(normalizeGlobPath(""), null);
  assert.equal(matchesGlobPath(".github/workflows/ci.yml", "**/*"), true);
  assert.equal(matchesGlobPath("a/b", "a/**/b"), true);
  assert.equal(matchesGlobPath("a/one/b", "a/**/b"), true);
  assert.equal(matchesGlobPath("a/one/c", "a/**/b"), false);
});

test("scope matching retains literal directory ownership", () => {
  assert.equal(matchesScopePath("tool/example.mjs", "tool"), true);
  assert.equal(matchesScopePath("tool", "tool/**"), true);
  assert.equal(matchesScopePath("tool/example.mjs", "tool/**"), true);
  assert.equal(matchesScopePath("docs/example.md", "tool"), false);
});
