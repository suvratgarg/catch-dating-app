import {
  MAX_WORK_ITEMS_PER_RUN,
  PLATFORM_CAPABILITY_CEILING,
  SUPPORTED_EXECUTION_MODES,
} from "../platform/contracts.mjs";
import {CLI_COMMANDS} from "../platform/cli-contract.mjs";
import {SupplyIntakeLearner} from "./supply-intake/learning.mjs";
import {
  SUPPLY_INTAKE_ENTITY_KINDS,
  SUPPLY_INTAKE_LIFECYCLE_SEMANTICS,
  SUPPLY_INTAKE_LIFECYCLE_STATUSES,
  SUPPLY_INTAKE_PRIMARY_STAGES,
  SUPPLY_INTAKE_TRANSITIONS,
} from "./supply-intake/definition.mjs";
import {
  SOURCE_PROFILE_IDS,
  loadSourceProfiles,
} from "./supply-intake/sources/index.mjs";
import {
  SupplyIntakeWorkflow,
  SUPPLY_INTAKE_WORKFLOW_ID,
  SUPPLY_INTAKE_WORKFLOW_VERSION,
} from "./supply-intake/workflow.mjs";
import {LEGACY_ARTIFACT_PATTERNS} from
  "./supply-intake/adapters/legacy-artifacts.mjs";

export const WORKFLOW_REGISTRY = Object.freeze([
  Object.freeze({
    directory: "supply-intake",
    workflowId: SUPPLY_INTAKE_WORKFLOW_ID,
    version: SUPPLY_INTAKE_WORKFLOW_VERSION,
    commands: CLI_COMMANDS,
    executionModes: SUPPORTED_EXECUTION_MODES,
    capabilities: PLATFORM_CAPABILITY_CEILING,
    primaryStages: SUPPLY_INTAKE_PRIMARY_STAGES,
    lifecycleStatuses: SUPPLY_INTAKE_LIFECYCLE_STATUSES,
    lifecycleSemantics: SUPPLY_INTAKE_LIFECYCLE_SEMANTICS,
    entityKinds: SUPPLY_INTAKE_ENTITY_KINDS,
    allowedTransitions: SUPPLY_INTAKE_TRANSITIONS,
    maxWorkItemsPerRun: MAX_WORK_ITEMS_PER_RUN,
    sourceProfileIds: SOURCE_PROFILE_IDS,
    compatibilityArtifactPatterns: LEGACY_ARTIFACT_PATTERNS,
    loadSourceProfiles,
    createWorkflow: (options) => new SupplyIntakeWorkflow(options),
    createLearner: (options) => new SupplyIntakeLearner(options),
  }),
]);

export function workflowDescriptor(workflowId, registry = WORKFLOW_REGISTRY) {
  return registry.find((entry) => entry.workflowId === workflowId) ?? null;
}
