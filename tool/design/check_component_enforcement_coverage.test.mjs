import assert from "node:assert/strict";
import test from "node:test";

import {
  checkComponentEnforcementCoverage,
  extractCheckerCodes,
  extractPluginCodes,
} from "./check_component_enforcement_coverage.mjs";

test("extracts plugin and checker diagnostic declarations only", () => {
  assert.deepEqual(
    [...extractPluginCodes("LintCode('catch_a', 'x'); // catch_noise")],
    ["catch_a"],
  );
  assert.deepEqual(
    [...extractCheckerCodes("const code = 'catch_b'; // catch_noise")],
    ["catch_b"],
  );
});

test("requires decisions, live waivers, ownership, and probes", () => {
  const registry = {
    components: [
      {
        id: "catch.one",
        enforcement: {
          code: "catch_a",
          vehicle: "plugin",
          replaces: ["RawOne"],
          replacement: "CatchOne",
          steeringCode: "catch_a",
          probeSeed: "RawOne()",
        },
      },
      {
        id: "catch.two",
        waiver: {expires: "2026-01-01"},
      },
      {id: "catch.three"},
    ],
  };
  const result = checkComponentEnforcementCoverage({
    registry,
    pluginCodes: new Set(["catch_a", "catch_orphan"]),
    checkerCodes: new Set(),
    harnessSource: "",
    generatedProbeMinimums: {catch_a: 1},
    today: "2026-07-19",
  });

  assert.ok(result.failures.some((failure) => failure.includes("waiver expired")));
  assert.ok(result.failures.some((failure) => failure.includes("exactly one")));
  assert.ok(result.failures.some((failure) => failure.includes("catch_orphan")));
  assert.equal(result.metrics.expiredWaivers, 1);
});
