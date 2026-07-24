import assert from "node:assert/strict";
import test from "node:test";
import {
  checkSchemaFixtures,
  fixtureSchemaCases,
} from "./check_schema_fixtures.mjs";

test("fixture manifest maps every fixture exactly once", () => {
  const fixturePaths = fixtureSchemaCases.map(([fixturePath]) => fixturePath);
  assert.equal(new Set(fixturePaths).size, fixturePaths.length);
  assert.ok(fixturePaths.includes("valid/host_profile_doc.json"));
  assert.ok(fixturePaths.includes("invalid/places_autocomplete_short_input.json"));
});

test("schema fixture check validates all current fixtures", () => {
  const result = checkSchemaFixtures();
  assert.deepEqual(result.errors, []);
  assert.equal(result.fixtureCount, fixtureSchemaCases.length);
  assert.equal(result.invalidFixtureCount, 22);
});
