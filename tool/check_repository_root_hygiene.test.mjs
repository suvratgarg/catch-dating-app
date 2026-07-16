import test from "node:test";
import assert from "node:assert/strict";
import {classify, matchesPattern, portableLinkViolations} from "./check_repository_root_hygiene.mjs";

test("glob matching covers dynamic root logs without widening paths", () => {
  assert.equal(matchesPattern("flutter_12.log", "flutter_*.log"), true);
  assert.equal(matchesPattern("nested/flutter_12.log", "flutter_*.log"), false);
});

test("classification reports an unknown and an ambiguous entry", () => {
  const manifest = {entries: [{names: ["known"]}], patterns: [{pattern: "k*"}]};
  assert.equal(classify("unknown", manifest).length, 0);
  assert.equal(classify("known", manifest).length, 2);
});

test("portable links reject machine paths but accept repository links", () => {
  assert.deepEqual(portableLinkViolations("[bad](/Users/person/repo/a.md) [ok](docs/a.md)"), ["/Users/person/repo/a.md"]);
});
