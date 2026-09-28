/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export interface AdminReviewSalesPrivacyPolicyResponse {
  policy: {
    schemaVersion: 1;
    classification: "sales_private";
    policyId: "current";
    revision: number;
    status: "reviewed";
    sourceReference: string;
    sourceHash: string;
    financeDisposition: "retain_pending_finance_review";
    financeReason: string;
    auditDisposition: "retain_pending_audit_review";
    auditReason: string;
    externalCopies: "unverified";
    policyHash: string;
    requestId: string;
    reviewedByUid: string;
    reviewedAt: string;
  };
}
