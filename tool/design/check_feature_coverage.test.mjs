import assert from "node:assert/strict";
import test from "node:test";

import {validateFeatureCoverage} from "./check_feature_coverage.mjs";

function fixture() {
  return {
    coverage: {
      authorities: [
        {
          id: "flutter_screens",
          runtime: "flutter",
          registry: "design/screens.json",
          collection: "screens",
          idField: "id",
        },
        {
          id: "admin_routes",
          runtime: "react_admin",
          registry: "design/admin.json",
          collection: "components",
          idField: "id",
          filter: {field: "kind", value: "route"},
        },
      ],
      decisions: [
        {
          authority: "flutter_screens",
          authorityId: "screen.example",
          status: "contracted",
          priority: "P1",
          reason: "Reference contract.",
          featureContract: "feature.example",
        },
        {
          authority: "admin_routes",
          authorityId: "route_example",
          status: "planned",
          priority: "P2",
          reason: "Queued contract.",
          targetFeature: "feature.admin_example",
          debtId: "FEATURE-CONTRACT-MIGRATION-001",
        },
        {
          authority: "admin_routes",
          authorityId: "route_example_live",
          status: "grouped",
          priority: "P2",
          reason: "Live wrapper for the same route.",
          primaryAuthorityId: "route_example",
        },
      ],
    },
    featureContracts: [
      {id: "feature.example", screenContract: "screen.example"},
    ],
    registries: {
      "design/screens.json": {screens: [{id: "screen.example"}]},
      "design/admin.json": {
        components: [
          {id: "route_example", kind: "route"},
          {id: "route_example_live", kind: "route"},
          {id: "shared_button", kind: "component"},
        ],
      },
    },
  };
}

function validate(data) {
  return validateFeatureCoverage({
    coverage: data.coverage,
    featureContracts: data.featureContracts,
    readRegistry: (registryPath) => data.registries[registryPath],
  });
}

test("accepts exhaustive cross-surface coverage and filtered authorities", () => {
  const result = validate(fixture());
  assert.deepEqual(result.errors, []);
  assert.equal(result.summary.totalInventory, 3);
  assert.equal(result.summary.authorityCounts.get("admin_routes"), 2);
});

test("rejects missing, duplicate, and unknown authority decisions", () => {
  const data = fixture();
  data.coverage.decisions.pop();
  data.coverage.decisions.push({...data.coverage.decisions[0]});
  data.coverage.decisions.push({
    authority: "admin_routes",
    authorityId: "route_missing",
    status: "excluded",
    priority: "P4",
    reason: "Unknown fixture route.",
  });

  const result = validate(data);
  assert.match(result.errors.join("\n"), /duplicate coverage decision/u);
  assert.match(result.errors.join("\n"), /unknown authority item/u);
  assert.match(result.errors.join("\n"), /route_example_live: missing feature coverage decision/u);
});

test("rejects contracted decisions that do not bind their authority item", () => {
  const data = fixture();
  data.coverage.decisions[0].authorityId = "screen.other";
  data.registries["design/screens.json"].screens[0].id = "screen.other";

  const result = validate(data);
  assert.match(
    result.errors.join("\n"),
    /feature\.example does not bind this authority item/u,
  );
});

test("rejects missing or chained grouped primaries", () => {
  const data = fixture();
  data.coverage.decisions[1] = {
    authority: "admin_routes",
    authorityId: "route_example",
    status: "grouped",
    priority: "P2",
    reason: "Invalid chained wrapper.",
    primaryAuthorityId: "route_missing",
  };

  let result = validate(data);
  assert.match(result.errors.join("\n"), /unknown grouped primary/u);

  data.coverage.decisions[1].primaryAuthorityId = "route_example_live";
  result = validate(data);
  assert.match(result.errors.join("\n"), /cannot itself be grouped/u);
});

test("fails when a registry adds an unclassified feature surface", () => {
  const data = fixture();
  data.registries["design/screens.json"].screens.push({id: "screen.new"});

  const result = validate(data);
  assert.match(
    result.errors.join("\n"),
    /flutter_screens:screen\.new: missing feature coverage decision/u,
  );
});

test("rejects orphaned source contracts", () => {
  const data = fixture();
  data.featureContracts.push({
    id: "feature.orphaned",
    screenContract: "screen.orphaned",
  });

  const result = validate(data);
  assert.match(
    result.errors.join("\n"),
    /feature\.orphaned: feature contract has no contracted coverage decision/u,
  );
});
