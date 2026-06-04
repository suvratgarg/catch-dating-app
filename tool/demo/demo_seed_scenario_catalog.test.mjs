import assert from "node:assert/strict";
import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import test from "node:test";
import {loadScenarioConfig} from "./demo_seed_scenario_catalog.mjs";

test("host demo scenario declares host sales proof coverage", () => {
  const scenario = loadScenarioConfig("host-demo");
  const coverage = scenario.salesDemo.proofCoverage;

  assert.ok(Array.isArray(coverage));
  assert.ok(coverage.length >= 4);
  assert.ok(
    coverage.some((item) => item.claim.includes("Invite links")),
    "invite-link proof should stay represented"
  );
  assert.ok(
    coverage.some((item) => item.claim.includes("waitlist")),
    "waitlist-offer proof should stay represented"
  );
  assert.ok(
    coverage.some((item) => item.claim.includes("private-interest")),
    "catch metrics proof should stay represented"
  );
  assert.ok(
    coverage.some((item) => item.claim.includes("table seating")),
    "assignment primitive proof should stay represented"
  );
});

test("scenario catalog rejects malformed proof coverage", () => {
  const tempDir = fs.mkdtempSync(path.join(os.tmpdir(), "catch-scenario-"));
  const scenarioPath = path.join(tempDir, "bad-proof.json");
  fs.writeFileSync(
    scenarioPath,
    JSON.stringify({
      id: "bad-proof",
      label: "Bad Proof",
      description: "Invalid proof coverage fixture.",
      salesDemo: {
        host: {},
        club: {},
        events: [{role: "demo"}],
        rosterPersonaIds: ["persona-1"],
        proofCoverage: [{claim: "Missing evidence"}],
      },
    })
  );

  assert.throws(
    () => loadScenarioConfig(scenarioPath),
    /proofCoverage\[0\]\.productSurface must be a non-empty string/
  );
});
