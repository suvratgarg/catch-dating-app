import assert from "node:assert/strict";
import test from "node:test";

import {
  findStaleHostFeatureOutputs,
  HostFeatureResponsibilityError,
  parseDartRoutes,
  renderHostFeatureReadme,
  validateAndResolveHostFeatureResponsibilities,
} from "./build_host_feature_responsibilities.mjs";

const ids = ["today", "events", "audience", "inbox", "organizer"];
const destinations = [
  "hostToday",
  "hostEvents",
  "hostAudience",
  "hostInbox",
  "hostOrganizer",
];
const routeIds = [
  "hostTodayScreen",
  "hostEventsScreen",
  "hostAudienceScreen",
  "hostInboxScreen",
  "hostOrganizerScreen",
];

function fixture() {
  const existing = new Set(["lib/shared.dart"]);
  const sourceByPath = new Map();
  const featureContracts = new Map();
  const routes = new Map([
    [
      "hostSharedScreen",
      {id: "hostSharedScreen", path: "/host/shared", audience: "host"},
    ],
  ]);
  const features = ids.map((id, index) => {
    const symbol = `${id[0].toUpperCase()}${id.slice(1)}Screen`;
    const ownerFile = `lib/${id}.dart`;
    const dataContract = `contracts/${id}.json`;
    const testFile = `test/${id}.dart`;
    const currentRoot = index < 2 ? `lib/hosts/${id}` : `lib/legacy/${id}`;
    for (const repoPath of [ownerFile, dataContract, testFile, currentRoot]) {
      existing.add(repoPath);
    }
    sourceByPath.set(ownerFile, `class ${symbol} {}`);
    routes.set(routeIds[index], {
      id: routeIds[index],
      path: `/host/${id}`,
      audience: "host",
    });
    featureContracts.set(`feature.${id}`, {
      id: `feature.${id}`,
      surfaces: [
        {
          id: "host_flutter",
          bindings: {
            actionOwners: [
              {id: "screen", file: ownerFile, symbol, language: "dart"},
            ],
            dataContracts: [dataContract],
          },
          actions: [{id: "open", owner: "screen"}],
        },
      ],
    });
    return {
      id,
      destination: destinations[index],
      primaryRouteId: routeIds[index],
      ownedRouteIds: [routeIds[index]],
      handoffRouteIds: ["hostSharedScreen"],
      targetRoot: `lib/hosts/${id}`,
      migrationStatus: index < 2
        ? "verticalSlice"
        : "targetDefinedLegacyImplementation",
      purpose: `${id} purpose.`,
      responsibilities: [`Own ${id}.`],
      doesNotOwn: [`Exclude non-${id}.`],
      currentRoots: [currentRoot],
      featureContractBindings: [
        {
          contractId: `feature.${id}`,
          surfaceId: "host_flutter",
          actionOwnerIds: ["screen"],
          includeDataContracts: true,
        },
      ],
      additionalCodeOwners: [],
      additionalDataContracts: [],
      sharedDependencies: [
        {path: "lib/shared.dart", reason: "Shared fixture dependency."},
      ],
      testFiles: [testFile],
    };
  });
  return {
    contract: {
      updated: "2026-09-01",
      features,
    },
    shellManifest: {
      primaryRoutes: ids.map((id, index) => ({
        destination: destinations[index],
        routeId: routeIds[index],
        path: `/host/${id}`,
        label: `${id[0].toUpperCase()}${id.slice(1)}`,
      })),
    },
    routes,
    featureContracts,
    pathExists: (repoPath) => existing.has(repoPath),
    readText: (repoPath) => sourceByPath.get(repoPath) ?? "",
  };
}

test("accepts exactly five ordered Host feature owners and renders local docs", () => {
  const input = fixture();
  const resolved = validateAndResolveHostFeatureResponsibilities(input);
  assert.deepEqual(resolved.map((feature) => feature.id), ids);
  assert.match(
    renderHostFeatureReadme({contract: input.contract, feature: resolved[0]}),
    /# Host Today[\s\S]+This feature owns[\s\S]+TodayScreen/u,
  );
});

test("rejects route ownership, action-owner, and symbol drift", () => {
  const input = fixture();
  input.contract.features[1].ownedRouteIds = [routeIds[0], routeIds[1]];
  input.contract.features[2].featureContractBindings[0].actionOwnerIds = [
    "missing_owner",
  ];
  input.readText = () => "class WrongSymbol {}";
  assert.throws(
    () => validateAndResolveHostFeatureResponsibilities(input),
    (error) =>
      error instanceof HostFeatureResponsibilityError &&
      error.errors.some((message) => message.includes("already owned")) &&
      error.errors.some((message) => message.includes("missing_owner")) &&
      error.errors.some((message) => message.includes("symbol")),
  );
});

test("detects stale generated responsibility docs", () => {
  const outputs = [
    {path: "/tmp/today.md", content: "today\n"},
    {path: "/tmp/events.md", content: "events\n"},
  ];
  assert.deepEqual(
    findStaleHostFeatureOutputs({
      outputs,
      readCurrent: (outputPath) =>
        outputPath.endsWith("today.md") ? "today\n" : "old\n",
    }),
    ["/tmp/events.md"],
  );
});

test("parses single-line and wrapped Host route declarations", () => {
  const routes = parseDartRoutes(`enum Routes {
    hostTodayScreen('/host/today', AppRouteAudience.host),
    hostEventsScreen(
      '/host/events',
      AppRouteAudience.host,
    ),
    dashboardScreen('/', AppRouteAudience.consumer),
  }`);
  assert.deepEqual(routes.get("hostTodayScreen"), {
    id: "hostTodayScreen",
    path: "/host/today",
    audience: "host",
  });
  assert.equal(routes.get("hostEventsScreen")?.path, "/host/events");
  assert.equal(routes.get("dashboardScreen")?.audience, "consumer");
});
