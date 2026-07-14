/** Canonical collection names for a future persistence adapter. */
export const operationCollections = {
  runs: "operationRuns",
  workItems: "operationWorkItems",
  actionReceipts: "operationActionReceipts",
  decisions: "operationDecisions",
  leases: "operationLeases",
  publicationPlans: "operationPublicationPlans",
  ruleProposals: "operationRuleProposals",
  ruleEvaluations: "operationRuleEvaluations",
} as const;

export type OperationCollectionName =
  typeof operationCollections[keyof typeof operationCollections];
