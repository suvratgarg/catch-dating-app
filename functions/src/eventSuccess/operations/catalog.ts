import type {
  EventAssistancePolicy,
} from "../../shared/generated/eventAssistancePolicy";
import {
  eventAssistanceWorkflowCatalog,
} from "../../shared/generated/catalogs/eventAssistanceWorkflowCatalog";
import {assertNever} from "./lateJoin";

export type WorkflowKind = EventAssistancePolicy["kind"];
export const workflowDefinitions = eventAssistanceWorkflowCatalog.definitions;
type CatalogKind = (typeof workflowDefinitions)[number]["kind"];
const completeCatalog: [
  Exclude<WorkflowKind, CatalogKind>,
  Exclude<CatalogKind, WorkflowKind>,
] extends [never, never]
  ? true
  : false = true;
void completeCatalog;
export type ApplicabilityRule =
  (typeof workflowDefinitions)[number]["applicability"];

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
