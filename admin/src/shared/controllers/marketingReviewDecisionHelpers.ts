import type {
  AdminRecordMarketingReviewDecisionPayload,
  AdminRecordMarketingReviewDecisionResponse,
  MarketingEventCandidate,
  MarketingOpsBridge,
  MarketingOpsDecision,
  MarketingOpsReviewState,
  MarketingOpsTargetType,
} from "../types/adminTypes";

export type DecisionHandler = (input: {
  targetType: MarketingOpsTargetType;
  targetId: string;
  decision: MarketingOpsDecision;
  edits?: Record<string, unknown>;
  defaultNote: string;
}) => Promise<void>;

export function checklistForDecision(
  targetType: MarketingOpsTargetType,
  decision: MarketingOpsDecision
): AdminRecordMarketingReviewDecisionPayload["checklist"] {
  if (decision !== "approve" && decision !== "export_ready") {
    return {
      sourceReviewed: false,
      dateReviewed: false,
      venueReviewed: false,
      copyReviewed: false,
      rightsReviewed: false,
      noCatchHostingImplied: false,
    };
  }
  return {
    sourceReviewed: targetType !== "content_draft",
    dateReviewed: [
      "event_candidate",
      "recommendation_item",
      "content_draft",
    ].includes(targetType),
    venueReviewed: [
      "event_candidate",
      "recommendation_item",
      "content_draft",
    ].includes(targetType),
    copyReviewed:
      targetType !== "source_profile" && targetType !== "query_template",
    rightsReviewed: targetType === "content_draft",
    noCatchHostingImplied: true,
  };
}

export function applyLocalDecision(
  bridge: MarketingOpsBridge,
  response: AdminRecordMarketingReviewDecisionResponse,
  note: string
): MarketingOpsBridge {
  const reviewState = reviewStateFor(response.decision);
  const latestDecision = {
    decision: response.decision,
    note,
    reviewer: "local-admin",
    reviewedAt: new Date().toISOString(),
  };
  if (response.targetType === "source_result") {
    return {
      ...bridge,
      sourceResults: bridge.sourceResults.map((result) =>
        result.id === response.targetId ? {
          ...result,
          status: reviewState,
          latestDecision,
        } : result
      ),
    };
  }
  if (response.targetType === "event_candidate") {
    return {
      ...bridge,
      eventCandidates: bridge.eventCandidates.map((candidate) =>
        candidate.id === response.targetId ? {
          ...candidate,
          reviewState,
          latestDecision,
        } : candidate
      ),
    };
  }
  if (response.targetType === "recommendation_item") {
    return {
      ...bridge,
      recommendationSets: bridge.recommendationSets.map((set) => ({
        ...set,
        items: set.items.map((item) =>
          item.id === response.targetId ? {...item, reviewState} : item
        ),
      })),
    };
  }
  if (response.targetType === "content_draft") {
    return {
      ...bridge,
      contentDrafts: bridge.contentDrafts.map((draft) =>
        draft.id === response.targetId ? {
          ...draft,
          reviewState,
          latestDecision,
        } : draft
      ),
    };
  }
  return bridge;
}

export function reviewStateFor(
  decision: MarketingOpsDecision
): MarketingOpsReviewState {
  if (decision === "approve" || decision === "export_ready") return "approved";
  if (decision === "hold") return "held";
  if (decision === "reject") return "rejected";
  return "needs_changes";
}

export function publishabilityLabel(
  value: MarketingEventCandidate["publishability"]
): string {
  if (value === "lead_needs_source") return "needs source";
  if (value === "reviewable_needs_verification") return "reviewable";
  if (value === "publishable_after_approval") {
    return "marketing ready after approval";
  }
  return "unknown readiness";
}

export function sourceStatusLabel(
  value: MarketingEventCandidate["sourceStatus"]
): string {
  if (value === "missing_source_url") return "missing source URL";
  if (value === "manual_reference_needs_official_verification") {
    return "manual reference";
  }
  if (value === "source_backed") return "source-backed";
  return "source status unknown";
}
