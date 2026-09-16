import {
  decideEventMessagingBudget,
  loadHostAnalytics,
  loadOverview,
  reviewEventMessagingBudget,
  stageEventMessagingBudget,
} from "../../../shared/api/adminApi";
import type {AdminApplyEventMessagingBudgetCallablePayload} from
  "../../../generated/contracts/adminApplyEventMessagingBudgetCallablePayload";
import type {AdminApplyEventMessagingBudgetCallableResponse} from
  "../../../generated/contracts/adminApplyEventMessagingBudgetCallableResponse";
import type {AdminDecideEventMessagingBudgetCallablePayload} from
  "../../../generated/contracts/adminDecideEventMessagingBudgetCallablePayload";
import type {AdminDecideEventMessagingBudgetCallableResponse} from
  "../../../generated/contracts/adminDecideEventMessagingBudgetCallableResponse";
import type {AdminReviewEventMessagingBudgetCallablePayload} from
  "../../../generated/contracts/adminReviewEventMessagingBudgetCallablePayload";
import type {AdminReviewEventMessagingBudgetCallableResponse} from
  "../../../generated/contracts/adminReviewEventMessagingBudgetCallableResponse";
import type {
  AdminOverviewResponse,
  HostAnalyticsResponse,
} from "../../../shared/types/adminTypes";

export function loadFinanceOverview(): Promise<AdminOverviewResponse> {
  return loadOverview();
}

export function loadFinanceHostAnalytics(): Promise<HostAnalyticsResponse> {
  return loadHostAnalytics({rangePreset: "30d", granularity: "week"});
}

export function loadMessagingBudgetReview(
  payload: AdminReviewEventMessagingBudgetCallablePayload
): Promise<AdminReviewEventMessagingBudgetCallableResponse> {
  return reviewEventMessagingBudget(payload);
}

export function recordMessagingBudgetDecision(
  payload: AdminDecideEventMessagingBudgetCallablePayload
): Promise<AdminDecideEventMessagingBudgetCallableResponse> {
  return decideEventMessagingBudget(payload);
}

export function stageApprovedMessagingBudget(
  payload: AdminApplyEventMessagingBudgetCallablePayload
): Promise<AdminApplyEventMessagingBudgetCallableResponse> {
  return stageEventMessagingBudget(payload);
}
