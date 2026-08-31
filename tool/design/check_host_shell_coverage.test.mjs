import assert from "node:assert/strict";
import test from "node:test";
import {
  extractHostNavigationDestinations,
  validateHostShellCoverage,
} from "./check_host_shell_coverage.mjs";

const destinations = [
  "hostEvents",
  "hostCustomers",
  "hostForms",
  "hostInbox",
  "hostOrganizer",
];
const labels = ["Events", "Customers", "Forms", "Messaging", "Organizer"];
const primaryRoutes = destinations.map((destination, index) => ({
  destination,
  routeId: `${destination}Screen`,
  path: `/host/${destination.slice(4).toLowerCase()}`,
  label: labels[index],
  source: `lib/${destination}.dart`,
  captureId: `capture-${index}`,
}));
const shellSource = `List<AppShellNavigationItem> _hostNavigationItems() => [
${destinations
  .map(
    (destination) =>
      `AppShellNavigationItem(destination: AppShellNavigationDestination.${destination}),`,
  )
  .join("\n")}
];`;

function fixture() {
  return {
    manifest: {
      $schema: "catch.host-shell-coverage/v2",
      updated: "2026-08-29",
      informationArchitectureDecision: {
        selectedOption: "forms-global-today-within-events",
        primaryLabels: primaryRoutes.map((route) => route.label),
        todayOwnerRouteId: "hostEventsScreen",
        formsOwnerRouteId: "hostFormsScreen",
        audiencesOwnerRouteId: "hostCustomersScreen",
        inboxWorkspaceOwnerRouteId: "hostInboxScreen",
      },
      primaryRoutes,
      legacyRoutes: [
        {
          routeId: "hostHomeScreen",
          status: "redirect",
          canonicalRouteId: "hostEventsScreen",
        },
      ],
    },
    shellSource,
    routeInventory: {
      routes: primaryRoutes.map((route) => ({
        id: route.routeId,
        runtimePath: route.path,
      })),
    },
    captureCoverage: {
      routes: primaryRoutes.map((route) => ({
        routeId: route.routeId,
        status: "captured",
        captureIds: [route.captureId],
      })),
    },
    sourceExists: () => true,
  };
}

test("extracts the ordered Host shell destination contract", () => {
  assert.deepEqual(extractHostNavigationDestinations(shellSource), destinations);
});

test("accepts five routes backed by runtime routes, sources, and captures", () => {
  assert.deepEqual(validateHostShellCoverage(fixture()), []);
});

test("rejects a retired primary route and missing canonical capture", () => {
  const input = fixture();
  input.manifest.primaryRoutes = [
    {
      destination: "hostHome",
      routeId: "hostHomeScreen",
      path: "/host",
      source: "lib/home.dart",
      captureId: "host-home",
    },
    ...input.manifest.primaryRoutes.slice(1),
  ];
  input.captureCoverage.routes[1].captureIds = [];
  const errors = validateHostShellCoverage(input);
  assert.ok(errors.some((error) => error.includes("destination order")));
  assert.ok(errors.some((error) => error.includes("retired hostHomeScreen")));
  assert.ok(errors.some((error) => error.includes("does not own capture-1")));
});

test("rejects a competing Today route and a contextual Forms owner", () => {
  const input = fixture();
  input.manifest.informationArchitectureDecision = {
    ...input.manifest.informationArchitectureDecision,
    selectedOption: "today-global-forms-contextual",
    todayOwnerRouteId: "hostHomeScreen",
    formsOwnerRouteId: "hostCustomersScreen",
  };
  const errors = validateHostShellCoverage(input);
  assert.ok(
    errors.some((error) =>
      error.includes("keep Forms global and Today within Events"),
    ),
  );
  assert.ok(
    errors.some((error) =>
      error.includes("todayOwnerRouteId must remain hostEventsScreen"),
    ),
  );
  assert.ok(
    errors.some((error) =>
      error.includes("formsOwnerRouteId must remain hostFormsScreen"),
    ),
  );
});
