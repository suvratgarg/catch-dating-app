/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export type AdminGetSalesPrivacyCaseResponse =
  | {
      organizerId: string;
      restricted: false;
      plan: null;
      completeDeletion: false;
      policy: null | {
        revision: number;
        policyHash: string;
        sourceReference: string;
        reviewedAt: string;
        financeDisposition: "retain_pending_finance_review";
        auditDisposition: "retain_pending_audit_review";
        financeReason: string;
        auditReason: string;
      };
    }
  | {
      organizerId: string;
      restricted: true;
      restriction: {
        status:
          | "restricted"
          | "processing"
          | "internal_processed_with_unresolved";
        revision: number;
        restrictedAt: string;
        reason: string;
      };
      plan: {
        planId: string;
        organizerId: string;
        policyHash: string;
        inventoryHash: string;
        cursor: number;
        itemCount: number;
        retainedCount: number;
        unresolvedCount: number;
        /**
         * @maxItems 240
         */
        blockers: {
          code: string;
          fingerprint: string;
        }[];
        status:
          | "reviewed"
          | "processing"
          | "internal_processed_with_unresolved";
      } | null;
      completeDeletion: false;
      policy: null | {
        revision: number;
        policyHash: string;
        sourceReference: string;
        reviewedAt: string;
        financeDisposition: "retain_pending_finance_review";
        auditDisposition: "retain_pending_audit_review";
        financeReason: string;
        auditReason: string;
      };
    };
