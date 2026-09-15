import assert from "node:assert/strict";
import test from "node:test";
import {
  commandBinding,
  commandBindingDefinitions,
  commandHasExecutor,
  workflowDefinitions,
  workflowDefinitionsForSurface,
  workflowHasCommandContract,
  type HostSurface,
} from "./catalog";
import {COMMAND_AUTHORITY, type CommandKind} from "./commands";

const hostAuthorities = new Set([
  "checkIn",
  "groupLead",
  "eventLead",
  "authorizedSafetyOperator",
]);

test("catalog commands name an authorized actor", () => {
  for (const definition of workflowDefinitions) {
    for (const kind of definition.commands.automatic) {
      assert.ok((COMMAND_AUTHORITY[kind] as readonly string[])
        .includes("systemWithinPolicy"));
    }
    for (const kind of definition.commands.host) {
      assert.ok(COMMAND_AUTHORITY[kind].some((authority) =>
        hostAuthorities.has(authority)));
    }
    for (const kind of definition.commands.guest) {
      assert.ok((COMMAND_AUTHORITY[kind] as readonly string[])
        .includes("guestSelf"));
    }
    assert.equal(
      definition.overridePolicy === "scopedReasonedExpiring",
      (definition.commands.host as readonly string[]).includes("applyOverride")
    );
  }
});

test("catalog accounts for every command kind", () => {
  const referenced = new Set<CommandKind>();
  for (const definition of workflowDefinitions) {
    for (const commands of Object.values(definition.commands)) {
      for (const kind of commands) referenced.add(kind);
    }
  }
  assert.deepEqual(
    [...referenced].sort(),
    (Object.keys(COMMAND_AUTHORITY) as CommandKind[]).sort()
  );
});

test("command bindings account for every command and mode", () => {
  assert.deepEqual(
    commandBindingDefinitions
      .map((definition) => definition.commandKind).sort(),
    Object.keys(COMMAND_AUTHORITY).sort()
  );
  for (const definition of commandBindingDefinitions) {
    for (const mode of ["live", "rehearsal"] as const) {
      const binding = commandBinding(definition.commandKind, mode);
      assert.equal(
        commandHasExecutor(definition.commandKind, mode),
        binding.bindingType !== "contractOnly"
      );
      assert.equal(
        binding.operations.length === 0,
        binding.bindingType === "contractOnly"
      );
    }
  }
});

test("direct live bindings only name command-consuming callables", () => {
  const direct = Object.fromEntries(commandBindingDefinitions
    .filter((definition) => definition.live.bindingType === "directCommand")
    .map((definition) => [
      definition.commandKind,
      [...definition.live.operations],
    ]));
  assert.deepEqual(direct, {
    confirmDeparture: ["confirmEventAssistanceDeparture"],
    setJoinIntent: ["submitEventAssistanceGuestChoice"],
    setParticipation: ["setEventAssistanceParticipation"],
    transferGroup: ["transferEventAssistanceGroup"],
    recordCheckpoint: ["recordEventAssistanceCheckpoint"],
    resolveAccountability: ["resolveEventAssistanceAccountability"],
    resolveAssistance: ["resolveEventAssistanceCase"],
    repairDelivery: ["repairEventAssistanceDelivery"],
    recordNoShow: ["recordEventNoShow"],
    reassignCheckpointReporter: [
      "reassignEventAssistanceCheckpointReporter",
    ],
    setCheckpointCloseout: ["setEventAssistanceCheckpointCloseout"],
  });
});

test("every workflow names its command or external resolution boundary", () => {
  const externallyResolved = Object.fromEntries(
    workflowDefinitions
      .filter((definition) => !workflowHasCommandContract(definition))
      .map((definition) => [definition.kind, definition.resolutionBoundary])
  );
  assert.deepEqual(
    externallyResolved,
    {
      venueReadiness: "eventConfiguration",
      routeReadiness: "eventConfiguration",
      formatReadiness: "eventConfiguration",
      messagingReadiness: "messagingConfiguration",
      financialReadiness: "paymentConfiguration",
      contextBoundary: "navigation",
      eventLearning: "reportReview",
    }
  );
  for (const definition of workflowDefinitions) {
    const commandCount = Object.values(definition.commands)
      .reduce((total, commands) => total + commands.length, 0);
    assert.equal(workflowHasCommandContract(definition), commandCount > 0);
  }
});

test("every Host surface has an exhaustive filtered projection", () => {
  const surfaces = [
    "today",
    "eventSetup",
    "liveNow",
    "liveGuests",
    "liveRoom",
    "eventReport",
  ] as const satisfies readonly HostSurface[];
  const catalogSurfaces = new Set(workflowDefinitions.flatMap((definition) =>
    definition.hostProjection.surfaces));
  assert.deepEqual([...catalogSurfaces].sort(), [...surfaces].sort());
  for (const surface of surfaces) {
    const projected = workflowDefinitionsForSurface(surface);
    assert.ok(projected.length > 0);
    assert.ok(projected.every((definition) =>
      (definition.hostProjection.surfaces as readonly HostSurface[])
        .includes(surface)));
  }
});
