import type {
  AdminRecordEventIntakeReviewDecisionPayload,
  AdminRecordEventIntakeReviewDecisionResponse,
  EventIntakeCandidate,
  EventIntakeDecision,
  EventIntakeBridge,
  EventIntakeTargetType,
  MarketingOpsReviewState,
} from "../../../../shared/types/adminTypes";

type EventIntakeUiDecision = EventIntakeDecision | "export_ready";

export type EventIntakeDecisionHandler = (input: {
  targetType: EventIntakeTargetType;
  targetId: string;
  decision: EventIntakeUiDecision;
  edits?: Record<string, unknown>;
  defaultNote: string;
}) => Promise<void>;

export function checklistForEventIntakeDecision(
  targetType: EventIntakeTargetType,
  decision: EventIntakeUiDecision
): AdminRecordEventIntakeReviewDecisionPayload["checklist"] {
  if (decision !== "approve") {
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
    sourceReviewed: targetType !== "query_template" && targetType !== "run_plan",
    dateReviewed: targetType === "event_candidate",
    venueReviewed: targetType === "event_candidate",
    copyReviewed:
      targetType !== "source_profile" && targetType !== "query_template",
    rightsReviewed: false,
    noCatchHostingImplied: true,
  };
}

export function applyLocalEventIntakeDecision(
  bridge: EventIntakeBridge,
  response: AdminRecordEventIntakeReviewDecisionResponse,
  note: string
): EventIntakeBridge {
  const reviewState = reviewStateForEventIntakeDecision(response.decision);
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
  return bridge;
}

function reviewStateForEventIntakeDecision(
  decision: EventIntakeDecision
): MarketingOpsReviewState {
  if (decision === "approve") return "approved";
  if (decision === "hold") return "held";
  if (decision === "reject") return "rejected";
  return "needs_changes";
}

export function eventIntakePublishabilityLabel(
  value: EventIntakeCandidate["publishability"]
): string {
  if (value === "lead_needs_source") return "needs source";
  if (value === "reviewable_needs_verification") return "reviewable";
  if (value === "publishable_after_approval") {
    return "publishable after approval";
  }
  return "unknown readiness";
}

export function eventIntakeSourceStatusLabel(
  value: EventIntakeCandidate["sourceStatus"]
): string {
  if (value === "missing_source_url") return "missing source URL";
  if (value === "manual_reference_needs_official_verification") {
    return "manual reference";
  }
  if (value === "source_backed") return "source-backed";
  return "source status unknown";
}
