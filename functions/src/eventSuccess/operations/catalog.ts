import type {
  EventAssistancePolicy,
} from "../../shared/generated/eventAssistancePolicy";
import {
  eventAssistanceCommandBindingCatalog,
} from "../../shared/generated/catalogs/eventAssistanceCommandBindingCatalog";
import {
  eventAssistanceWorkflowCatalog,
} from "../../shared/generated/catalogs/eventAssistanceWorkflowCatalog";
import {
  COMMAND_AUTHORITY,
  type Authority,
  type CommandKind,
} from "./commands";
import {assertNever} from "./lateJoin";

export type WorkflowKind = EventAssistancePolicy["kind"];
export const workflowDefinitions = eventAssistanceWorkflowCatalog.definitions;
export const commandBindingDefinitions =
  eventAssistanceCommandBindingCatalog.definitions;
type CatalogKind = (typeof workflowDefinitions)[number]["kind"];
const completeCatalog: [
  Exclude<WorkflowKind, CatalogKind>,
  Exclude<CatalogKind, WorkflowKind>,
] extends [never, never]
  ? true
  : false = true;
void completeCatalog;
type CatalogCommands =
  (typeof workflowDefinitions)[number]["commands"];
type CatalogCommandKind = CatalogCommands[keyof CatalogCommands][number];
const completeCommandCatalog: [
  Exclude<CommandKind, CatalogCommandKind>,
  Exclude<CatalogCommandKind, CommandKind>,
] extends [never, never]
  ? true
  : false = true;
void completeCommandCatalog;
type BoundCommandKind =
  (typeof commandBindingDefinitions)[number]["commandKind"];
const completeCommandBindings: [
  Exclude<CommandKind, BoundCommandKind>,
  Exclude<BoundCommandKind, CommandKind>,
] extends [never, never]
  ? true
  : false = true;
void completeCommandBindings;

export type CommandExecutionMode = "live" | "rehearsal";
export type CommandBinding =
  (typeof commandBindingDefinitions)[number][CommandExecutionMode];

export function commandBinding(
  kind: CommandKind,
  mode: CommandExecutionMode
): CommandBinding {
  const definition = commandBindingDefinitions.find(
    (candidate) => candidate.commandKind === kind
  );
  if (!definition) throw new Error(`Missing command binding: ${kind}`);
  return definition[mode];
}

export function commandHasExecutor(
  kind: CommandKind,
  mode: CommandExecutionMode
): boolean {
  return commandBinding(kind, mode).bindingType !== "contractOnly";
}

type CommandsAvailableTo<A extends Authority> = {
  [K in CommandKind]: Extract<
    A,
    (typeof COMMAND_AUTHORITY)[K][number]
  > extends never ? never : K
}[CommandKind];
type CommandsFor<R extends keyof CatalogCommands> =
  CatalogCommands[R][number];
type HostAuthority =
  | "checkIn"
  | "groupLead"
  | "eventLead"
  | "authorizedSafetyOperator";
const commandsMatchActors: [
  Exclude<CommandsFor<"automatic">,
    CommandsAvailableTo<"systemWithinPolicy">>,
  Exclude<CommandsFor<"host">, CommandsAvailableTo<HostAuthority>>,
  Exclude<CommandsFor<"guest">, CommandsAvailableTo<"guestSelf">>,
] extends [never, never, never]
  ? true
  : false = true;
void commandsMatchActors;

export type ApplicabilityRule =
  (typeof workflowDefinitions)[number]["applicability"];
export type HostSurface =
  (typeof workflowDefinitions)[number]["hostProjection"]["surfaces"][number];
export type ResolutionBoundary =
  (typeof workflowDefinitions)[number]["resolutionBoundary"];

export function workflowDefinitionsForSurface(
  surface: HostSurface
) {
  return workflowDefinitions.filter((definition) =>
    (definition.hostProjection.surfaces as readonly HostSurface[])
      .includes(surface));
}

export function workflowHasCommandContract(
  definition: (typeof workflowDefinitions)[number]
): boolean {
  return definition.resolutionBoundary === "eventAssistanceCommand";
}

/** Derived per phase/unit from the saved format and explicit requirements. */
export interface OperatingCapabilities {
  moving: boolean;
  movingSubgroups: boolean;
  groups: boolean;
  resources: boolean;
  rounds: boolean;
  independentUnits: boolean;
  outcomes: boolean;
  accountability: boolean;
  paid: boolean;
  requiredData: boolean;
  roles: boolean;
  admission: boolean;
  tracking: boolean;
}

export function isApplicable(
  rule: ApplicabilityRule,
  capabilities: OperatingCapabilities
): boolean {
  switch (rule) {
  case "all":
    return true;
  case "moving":
    return capabilities.moving;
  case "movingSubgroups":
    return capabilities.moving && capabilities.movingSubgroups;
  case "resources":
    return capabilities.resources;
  case "rounds":
    return capabilities.rounds;
  case "independentUnits":
    return capabilities.independentUnits;
  case "outcomes":
    return capabilities.outcomes;
  case "accountability":
    return capabilities.accountability;
  case "paid":
    return capabilities.paid;
  case "requiredData":
    return capabilities.requiredData;
  case "roles":
    return capabilities.roles;
  case "admission":
    return capabilities.admission;
  case "tracking":
    return capabilities.moving && capabilities.tracking;
  case "groupsOrResources":
    return capabilities.groups || capabilities.resources;
  default:
    return assertNever(rule);
  }
}
