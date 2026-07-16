import {WorkItemStagePolicy} from "../workflowPolicy";

export const supplyIntakeStagePolicy: WorkItemStagePolicy = {
  workflowId: "supply-intake",
  stages: {
    incoming: {lifecycleStatus: "queued"},
    verify: {lifecycleStatus: "in_progress"},
    resolve: {lifecycleStatus: "waiting"},
    ready: {
      lifecycleStatus: "ready",
      requiresDecision: true,
      requiresNoBlockers: true,
      gateErrorCode: "ready_gates_not_met",
      gateErrorMessage:
        "Ready work requires no blockers and an accepted decision",
    },
  },
  transitions: {
    incoming: ["verify"],
    verify: ["incoming", "resolve", "ready"],
    resolve: ["verify", "ready"],
    ready: ["verify", "resolve"],
  },
  publication: {
    outcome: "published",
    readyStages: ["ready"],
    followupOutcomes: ["expired", "cancelled", "taken_down"],
    publishedOnlyOutcomes: ["taken_down"],
    requiresDecision: true,
    requiresPublicationPlan: true,
  },
};
