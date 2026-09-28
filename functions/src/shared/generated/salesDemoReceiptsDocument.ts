/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Immutable issuer-bound command result and material hash; trial receipts expire with their session.
 */
export interface SalesDemoReceiptsDocument {
  schemaVersion: 1;
  classification: "sales_private";
  receiptId: string;
  actorUid: string;
  requestId: string;
  action:
    | "salesDemo.blueprint.save"
    | "salesDemo.blueprint.review"
    | "salesDemo.blueprint.withdraw"
    | "salesDemo.invitation.issue"
    | "salesDemo.invitation.revoke"
    | "salesDemo.session.start"
    | "salesDemo.session.reviewApplication"
    | "salesDemo.session.prepareReply"
    | "salesDemo.session.admitGuest"
    | "salesDemo.session.requestAssistance";
  targetId: string;
  materialHash: string;
  result: {
    schemaVersion?: 1;
    synthetic?: true;
    blueprintId?: string;
    blueprintRevision?: number;
    invitationId?: string;
    sessionId?: string;
    revision?: number;
    state?: "draft" | "reviewed" | "withdrawn";
    reviewedAt?: string;
    previewOnly?: boolean;
    expiresAt?: string;
    revoked?: boolean;
    revokedAt?: string;
    revokedByUid?: string;
    createdAt?: string;
    status?: "active" | "completed";
    /**
     * @maxItems 4
     */
    allowedActions?: (
      | "reviewApplication"
      | "prepareReply"
      | "admitGuest"
      | "requestAssistance"
    )[];
    actionCount?: number;
    step?: "application" | "reply" | "admission" | "complete";
    application?: {
      applicantName: "Sample Applicant";
      request: "Sample event application";
      review: "pending" | "approved" | "needs_info";
    };
    reply?: {
      status: "none" | "prepared";
      template: "none" | "welcome" | "clarify";
    };
    guest?: {
      status: "not_admitted" | "admitted";
      displayName: "Sample Applicant";
    };
    assistanceRequested?: boolean;
  };
  createdAt: string;
  expiresAt?: string;
}
