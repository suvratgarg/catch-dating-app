/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Sanitized campaign state and aggregate eligibility/delivery counts.
 */
export interface OrganizerCampaignCallableResponse {
  organizerId: string;
  campaignId: string;
  savedAudienceId: string | null;
  status:
    | "draft"
    | "previewed"
    | "approved"
    | "scheduled"
    | "resolving"
    | "sending"
    | "completed"
    | "partiallyFailed"
    | "cancelled"
    | "blocked";
  revision: number;
  audienceCounts: {
    total: number;
    reachable: number;
    optedOut: number;
    invalid: number;
    duplicate: number;
    unsupported: number;
    frequencyCapped: number;
    providerBlocked: number;
    unknown: number;
  };
  deliveryCounts: {
    pending: number;
    suppressed: number;
    accepted: number;
    sent: number;
    delivered: number;
    read: number;
    failed: number;
    replied: number;
    optedOut: number;
  };
  senderStatus:
    | "pending"
    | "testing"
    | "active"
    | "degraded"
    | "blocked"
    | "tokenRevoked"
    | "disconnected"
    | "notConnected";
  templateStatus:
    | "APPROVED"
    | "PENDING"
    | "REJECTED"
    | "PAUSED"
    | "DISABLED"
    | "DELETED"
    | "UNKNOWN"
    | "missing";
  canApprove: boolean;
  canDispatch: boolean;
  /**
   * @maxItems 20
   */
  blockers: (
    | "providerSetupRequired"
    | "senderInactive"
    | "templateMissing"
    | "templateUnapproved"
    | "savedAudienceMissing"
    | "savedAudienceChanged"
    | "noReachableRecipients"
    | "audienceCoveragePartial"
    | "audienceTooLarge"
    | "eventMissing"
    | "eventUnavailable"
    | "scheduleInPast"
    | "campaignImmutable"
    | "campaignCancelled"
    | "campaignComplete"
    | "campaignLeaseActive"
  )[];
}
