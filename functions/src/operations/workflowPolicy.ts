import {WorkItemLifecycleStatus} from "./models";

export interface WorkItemStageDefinition {
  lifecycleStatus: WorkItemLifecycleStatus;
  requiresDecision?: boolean;
  requiresNoBlockers?: boolean;
  requiresPublicationPlan?: boolean;
  gateErrorCode?: string;
  gateErrorMessage?: string;
}

export interface WorkItemPublicationPolicy {
  outcome: string;
  readyStages: readonly string[];
  followupOutcomes: readonly string[];
  publishedOnlyOutcomes: readonly string[];
  requiresDecision: boolean;
  requiresPublicationPlan: boolean;
}

export interface WorkItemStagePolicy {
  workflowId: string;
  stages: Readonly<Record<string, WorkItemStageDefinition>>;
  transitions: Readonly<Record<string, readonly string[]>>;
  publication: WorkItemPublicationPolicy | null;
}
