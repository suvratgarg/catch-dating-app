/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export interface EventApprovalNotificationIntent {
  schemaVersion: 1;
  intentId: string;
  revision: 1;
  context: {
    mode: "live";
    applicationId: string;
    organizerId: string;
    eventId: string;
    uid: string;
    sourceResponseId: string;
    approvedAtMillis: number;
    approvalRevision: number;
  };
  createdAt: number;
  expiresAt: number;
  lane: "phone" | "email";
  /**
   * @minItems 1
   * @maxItems 2
   */
  permittedRoutes: ("approvalWhatsapp" | "approvalSms" | "approvalEmail")[];
  deliveryPolicy: {
    maxAttempts: 3;
    maxAttemptsPerRoute: 1;
    minimumRetrySeconds: 60;
  };
}
