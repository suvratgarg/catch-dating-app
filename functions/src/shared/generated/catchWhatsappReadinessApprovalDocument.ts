/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Server-only independently authorized review. Provisioning consumes it atomically with readiness and immutable audit; this source provides no approval writer. No TTL, token, endpoint or message body.
 */
export interface CatchWhatsappReadinessApprovalDocument {
  schemaVersion: 1;
  approvalId: string;
  state: "approved" | "consumed";
  approval: {
    approvalId: string;
    action: "create" | "revoke";
    scope: {
      projectId: string;
      wabaId: string;
      phoneNumberId: string;
      recipientUid: string;
      endpointHash: string;
      evidenceSha256: string;
    };
    reviewerUid: string;
    reviewedAtMillis: number;
    expiresAtMillis: number;
    atomicIngressStartedAtMillis: number;
    expectedRecordSha256: string | null;
  };
  ingressEvidenceSha256: string;
  consumedAtMillis: number | null;
  recordSha256: string | null;
}
