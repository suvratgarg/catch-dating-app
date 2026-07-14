import {
  supplyIntakePrimaryStages,
  type OperationWorkItem,
  type SupplyIntakePrimaryStage,
} from "./operationsTypes";

export function operationStageCounts(
  items: OperationWorkItem[]
): Record<SupplyIntakePrimaryStage, number> {
  const counts: Record<SupplyIntakePrimaryStage, number> = {
    incoming: 0,
    verify: 0,
    resolve: 0,
    ready: 0,
  };
  for (const item of items.filter(operationIsActive)) {
    counts[item.primaryStage] += 1;
  }
  return counts;
}

export function operationItemsForStage(
  items: OperationWorkItem[],
  stage: SupplyIntakePrimaryStage
) {
  return items.filter((item) =>
    operationIsActive(item) && item.primaryStage === stage);
}

export function operationIsActive(item: OperationWorkItem) {
  return item.lifecycleStatus !== "published" &&
    item.lifecycleStatus !== "terminal";
}

export function operationNeedsHumanReview(item: OperationWorkItem) {
  return item.taskFlags.includes("human_review_required") ||
    item.blockerCodes.includes("human_review_required") ||
    item.normalizedPayload.owner === "human";
}

export function operationWorkItemTitle(item: OperationWorkItem) {
  for (const key of ["title", "displayName", "name"]) {
    const value = item.normalizedPayload[key];
    if (typeof value === "string" && value.trim()) return value.trim();
  }
  const sourceEntity = objectValue(item.normalizedPayload.sourceEntity);
  const sourceTitle = sourceEntity?.title;
  if (typeof sourceTitle === "string" && sourceTitle.trim()) {
    return sourceTitle.trim();
  }
  return item.externalKey ?? item.workItemId;
}

export function operationWorkItemSubtitle(item: OperationWorkItem) {
  const city = item.normalizedPayload.city;
  const market = item.normalizedPayload.market;
  const location = typeof city === "string" ? city :
    typeof market === "string" ? market : null;
  return [
    item.entityKind.replaceAll("_", " "),
    location,
    `priority ${item.priority}`,
  ].filter(Boolean).join(" · ");
}

function objectValue(value: unknown): Record<string, unknown> | null {
  return value !== null && typeof value === "object" &&
    !Array.isArray(value) ? value as Record<string, unknown> : null;
}

export function isSupplyIntakePrimaryStage(
  value: string
): value is SupplyIntakePrimaryStage {
  return supplyIntakePrimaryStages.includes(
    value as SupplyIntakePrimaryStage
  );
}
