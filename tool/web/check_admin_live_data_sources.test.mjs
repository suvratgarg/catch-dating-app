import assert from "node:assert/strict";
import test from "node:test";

import {
  validateAdminLiveDataSources,
  verifyAdminCallableReachability,
} from
  "./check_admin_live_data_sources.mjs";

const base = {
  contract: {
    schemaVersion: 1,
    routes: [{
      routeId: "overview",
      navId: "overview",
      paths: ["/overview"],
      liveReads: ["adminGetOverview"],
    }, {
      routeId: "event-intake",
      navId: "organizer-intake",
      paths: ["/intake/events"],
      liveReads: ["adminGetOverview"],
    }, {
      routeId: "organizer-intake",
      navId: "organizer-intake",
      paths: ["/intake/organizers"],
      liveReads: ["adminGetOverview"],
    }, {
      routeId: "intake-operations",
      navId: "organizer-intake",
      paths: ["/intake/operations"],
      liveReads: ["adminGetOverview"],
    }],
    sampleOnlyImportRoots: ["admin/src/features/sample.ts"],
  },
  appSource: `
    const navigation: AdminNavGroup[] = [
      {id: "group", label: "Group", items: [
        {id: "overview", label: "Overview", icon: Activity},
      ]},
    ];
    const navRoles = {};
  `,
  apiSource: `httpsCallable(functions, "adminGetOverview")`,
  functionsIndexSource: `export {adminGetOverview} from "./admin/overview";`,
  featureFiles: [],
};

test("accepts callable-backed routes with sample-only generated fixtures", () => {
  assert.deepEqual(validateAdminLiveDataSources({
    ...base,
    featureFiles: [{
      path: "admin/src/features/sample.ts",
      source: `import fixture from "./generated/sample.json";`,
    }],
  }), []);
});

test("rejects a production feature that imports generated operational JSON", () => {
  const violations = validateAdminLiveDataSources({
    ...base,
    featureFiles: [{
      path: "admin/src/features/intake/controller.ts",
      source: `import bridge from "../generated/intake.json";`,
    }],
  });
  assert.ok(violations.some((violation) =>
    violation.includes("production feature imports generated operational JSON")));
});

test("rejects navigation without a live callable contract", () => {
  const violations = validateAdminLiveDataSources({
    ...base,
    appSource: `
      const navigation: AdminNavGroup[] = [
        {id: "group", label: "Group", items: [
          {id: "overview", label: "Overview", icon: Activity},
          {id: "finance", label: "Finance", icon: Dollar},
        ]},
      ];
      const navRoles = {};
    `,
  });
  assert.ok(violations.includes(
    "admin navigation: finance has no live data contract"
  ));
});

test("live verification reports every missing deployed callable", async () => {
  const result = await verifyAdminCallableReachability({
    contract: {
      routes: [{
        liveReads: ["adminGetOverview", "adminListIntakeOperations"],
        liveMutations: ["adminListActionExecutions"],
      }],
    },
    projectId: "catch-prod",
    probe: async ({callable}) => {
      if (callable === "adminGetOverview") {
        return {httpStatus: 401, callableStatus: "UNAUTHENTICATED"};
      }
      throw new Error(`${callable} is not deployed`);
    },
  });
  assert.deepEqual(result.reachable.map((entry) => entry.callable), [
    "adminGetOverview",
  ]);
  assert.deepEqual(result.failures.map((entry) => entry.callable), [
    "adminListActionExecutions",
    "adminListIntakeOperations",
  ]);
});
