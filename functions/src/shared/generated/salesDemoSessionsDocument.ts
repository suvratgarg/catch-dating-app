/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Isolated synthetic Forms practice state; no production guest, message, payment or membership references.
 */
export interface SalesDemoSessionsDocument {
  schemaVersion: 1;
  classification: "sales_private";
  sessionId: string;
  invitationId: string;
  blueprintId: string;
  blueprintRevision: number;
  actorUid: string;
  createdAt: string;
  expiresAt: string;
  status: "active" | "completed";
  /**
   * @minItems 1
   * @maxItems 4
   */
  allowedActions: (
    | "reviewApplication"
    | "prepareReply"
    | "admitGuest"
    | "requestAssistance"
  )[];
  revision: number;
  actionCount: number;
  step: "application" | "reply" | "admission" | "complete";
  application: {
    applicantName: "Sample Applicant";
    request: "Sample event application";
    review: "pending" | "approved" | "needs_info";
  };
  reply: {
    status: "none" | "prepared";
    template: "none" | "welcome" | "clarify";
  };
  guest: {
    status: "not_admitted" | "admitted";
    displayName: "Sample Applicant";
  };
  assistanceRequested: boolean;
}
