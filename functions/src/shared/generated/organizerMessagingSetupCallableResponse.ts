/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Safe organizer messaging connection and approved-template inventory.
 */
export interface OrganizerMessagingSetupCallableResponse {
  organizerId: string;
  providerConfigured: boolean;
  embeddedSignup: {
    appId: string | null;
    configId: string | null;
    graphVersion: string | null;
  };
  connection: {
    connectionId: string;
    status:
      | "pending"
      | "testing"
      | "active"
      | "degraded"
      | "blocked"
      | "tokenRevoked"
      | "disconnected";
    displayPhoneNumber: string | null;
    verifiedName: string | null;
    qualityRating: null | "GREEN" | "YELLOW" | "RED" | "UNKNOWN";
    messagingLimitTier: string | null;
    templateSyncStatus: "notStarted" | "current" | "stale" | "failed";
    webhookStatus: "notSubscribed" | "subscribed" | "degraded";
    testStatus: "notSent" | "pending" | "delivered" | "failed";
    revision: number;
  } | null;
  /**
   * @maxItems 200
   */
  templates: {
    templateId: string;
    name: string;
    language: string;
    category: "MARKETING" | "UTILITY" | "AUTHENTICATION" | "UNKNOWN";
    status:
      | "APPROVED"
      | "PENDING"
      | "REJECTED"
      | "PAUSED"
      | "DISABLED"
      | "DELETED"
      | "UNKNOWN";
    variableNames: string[];
    hasMediaHeader: boolean;
    buttonKinds: string[];
  }[];
}
