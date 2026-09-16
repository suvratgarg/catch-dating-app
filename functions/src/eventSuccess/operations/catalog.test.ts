import assert from "node:assert/strict";
import test from "node:test";
import {
  commandBinding,
  commandBindingDefinitions,
  commandCoverage,
  commandHasExecutor,
  commandIsFullyImplemented,
  plannedWorkflowCommand,
  workflowDefinitions,
  workflowDefinitionsForSurface,
  workflowActionPlanForSurface,
  workflowHasCommandContract,
  type HostSurface,
  type OperatingCapabilities,
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
        commandIsFullyImplemented(definition.commandKind, mode),
        commandCoverage(definition.commandKind, mode) === "complete"
      );
      assert.equal(
        binding.operations.length === 0,
        binding.bindingType === "contractOnly"
      );
      assert.equal(
        binding.missingCapability !== null,
        commandCoverage(definition.commandKind, mode) !== "complete"
      );
    }
  }
});

test("operational message variants have one complete live binding", () => {
  const binding = commandBinding("sendOperationalMessage", "live");
  assert.equal("coverage" in binding, false);
  assert.equal(binding.missingCapability, null);
  assert.equal(commandHasExecutor("sendOperationalMessage", "live"), true);
  assert.equal(
    commandIsFullyImplemented("sendOperationalMessage", "live"),
    true
  );
});

test("unimplemented live commands name their missing capability", () => {
  const gaps = Object.fromEntries(commandBindingDefinitions
    .filter((definition) => definition.live.bindingType === "contractOnly")
    .map((definition) => [
      definition.commandKind,
      definition.live.missingCapability,
    ]));
  assert.deepEqual(gaps, {
    reconcileFinance: "eventPaymentCaseResolution",
  });
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
    changeRoute: ["changeEventAssistanceRoute"],
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

test("rehearsal route recovery names its movement command boundary", () => {
  const binding = commandBinding("changeRoute", "rehearsal");
  assert.equal(binding.bindingType, "directCommand");
  assert.deepEqual(binding.operations,
    ["controlEventRehearsal", "getEventRehearsalMovement"]);
  assert.equal(binding.missingCapability, null);
});

test("rehearsal required data binds both Host and guest boundaries", () => {
  const binding = commandBinding("requestRequiredData", "rehearsal");
  assert.equal(binding.bindingType, "domainAdapter");
  assert.deepEqual(binding.operations, [
    "controlEventRehearsal",
    "getEventRehearsalBootstrap",
    "getEventRehearsalGuestBootstrap",
    "submitEventRehearsalGuestAction",
  ]);
  assert.equal(binding.missingCapability, null);
});

test("rehearsal roster reconciliation binds control and review", () => {
  const binding = commandBinding("reconcileRoster", "rehearsal");
  assert.equal(binding.bindingType, "domainAdapter");
  assert.deepEqual(binding.operations,
    ["controlEventRehearsal", "getEventRehearsalBootstrap"]);
  assert.equal(binding.missingCapability, null);
});

test("rehearsal outcomes bind the Host control and review boundaries", () => {
  const binding = commandBinding("recordOutcome", "rehearsal");
  assert.equal(binding.bindingType, "domainAdapter");
  assert.deepEqual(binding.operations,
    ["controlEventRehearsal", "getEventRehearsalBootstrap"]);
  assert.equal(binding.missingCapability, null);
});

test("rehearsal reveal binds the Host control and review boundaries", () => {
  const binding = commandBinding("controlReveal", "rehearsal");
  assert.equal(binding.bindingType, "domainAdapter");
  assert.deepEqual(binding.operations,
    ["controlEventRehearsal", "getEventRehearsalBootstrap"]);
  assert.equal(binding.missingCapability, null);
});

test("rehearsal allocations bind proposal and publication boundaries", () => {
  const proposal = commandBinding("proposeAllocation", "rehearsal");
  assert.equal(proposal.bindingType, "domainAdapter");
  assert.deepEqual(proposal.operations,
    ["controlEventRehearsal", "getEventRehearsalBootstrap"]);
  assert.equal(proposal.missingCapability, null);

  const publication = commandBinding("publishAllocation", "rehearsal");
  assert.equal(publication.bindingType, "domainAdapter");
  assert.deepEqual(publication.operations, [
    "controlEventRehearsal",
    "getEventRehearsalBootstrap",
    "getEventRehearsalGuestBootstrap",
  ]);
  assert.equal(publication.missingCapability, null);
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

const capabilities = (
  values: Partial<OperatingCapabilities> = {}
): OperatingCapabilities => ({
  moving: false,
  movingSubgroups: false,
  groups: false,
  resources: false,
  rounds: false,
  independentUnits: false,
  outcomes: false,
  accountability: false,
  paid: false,
  requiredData: false,
  roles: false,
  admission: false,
  tracking: false,
  ...values,
});

test("action plans compose capabilities without activity-name forks", () => {
  const runClub = workflowActionPlanForSurface({
    surface: "liveNow",
    mode: "live",
    capabilities: capabilities({
      moving: true,
      movingSubgroups: true,
      groups: true,
      independentUnits: true,
      outcomes: true,
      accountability: true,
      roles: true,
      tracking: true,
    }),
  });
  const runKinds = new Set(runClub.map((workflow) => workflow.kind));
  assert.equal(runKinds.has("departure"), true);
  assert.equal(runKinds.has("checkpoint"), true);
  assert.equal(runKinds.has("routeRecovery"), true);
  assert.equal(runKinds.has("locationFreshness"), true);
  assert.equal(runKinds.has("resourceRecovery"), false);

  const courtSocial = workflowActionPlanForSurface({
    surface: "liveRoom",
    mode: "live",
    capabilities: capabilities({
      groups: true,
      resources: true,
      rounds: true,
      independentUnits: true,
      outcomes: true,
      requiredData: true,
    }),
  });
  const courtKinds = new Set(courtSocial.map((workflow) => workflow.kind));
  assert.equal(courtKinds.has("allocationRepair"), true);
  assert.equal(courtKinds.has("placementConfirmation"), true);
  assert.equal(courtKinds.has("resourceRecovery"), true);
  assert.equal(courtKinds.has("unitProgress"), true);
  assert.equal(courtKinds.has("routeRecovery"), false);
});

test("action plans preserve every implementation status", () => {
  const today = workflowActionPlanForSurface({
    surface: "today",
    mode: "live",
    capabilities: capabilities({
      moving: true,
      paid: true,
      requiredData: true,
      admission: true,
    }),
  });
  const byKind = Object.fromEntries(today.map((workflow) =>
    [workflow.kind, workflow]
  ));

  assert.equal(byKind.venueReadiness.implementationStatus, "external");
  assert.equal(byKind.rosterReadiness.implementationStatus, "complete");
  assert.equal(byKind.requiredGuestData.implementationStatus, "complete");
  assert.equal(
    byKind.financialReconciliation.implementationStatus,
    "unavailable"
  );
  assert.equal(byKind.postEventFollowUp.implementationStatus, "complete");

  const requiredData = byKind.requiredGuestData.commands.find((command) =>
    command.kind === "requestRequiredData"
  );
  assert.deepEqual(requiredData, {
    kind: "requestRequiredData",
    actor: "automatic",
    coverage: "complete",
    bindingType: "internalCoordinator",
    operations: ["onEventRuntimeParticipantWritten",
      "EventRuntimeRequiredDataStore.request", "getEventRuntimeBootstrap",
      "submitEventRuntimeProfile"],
    missingCapability: null,
    variantField: null,
    implementedVariants: [],
    missingVariants: [],
  });
});

test("planned commands expose complete operational message coverage", () => {
  assert.deepEqual(
    plannedWorkflowCommand("sendOperationalMessage", "automatic", "live"),
    {
      kind: "sendOperationalMessage",
      actor: "automatic",
      coverage: "complete",
      bindingType: "internalCoordinator",
      operations: ["prepareLiveLateJoinPublication",
        "OperationalNoticeFanoutStore.process",
        "ensureCurrentGuestEnrollment",
        "EventPlanChangeSourceReader.read",
        "PostEventFollowUpSourceReader.read",
        "prepareOperationalNoticePublication",
        "LiveMessageDispatcher.dispatch"],
      missingCapability: null,
      variantField: null,
      implementedVariants: [],
      missingVariants: [],
    }
  );
});
