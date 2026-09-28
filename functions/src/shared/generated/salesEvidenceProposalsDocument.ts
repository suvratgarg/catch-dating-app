/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Private suggestions, isolated from employee-reviewed evidence and qualification.
 */
export interface SalesEvidenceProposalsDocument {
  schemaVersion: 1;
  classification: "sales_private";
  proposalId: string;
  organizerId: string;
  revision: number;
  status: "pending" | "accepted" | "rejected";
  evidence: {
    organizerId: string;
    contactId?: string | null;
    claimKey: "identity" | "recurrence" | "operation" | "stack" | "other";
    signalId?: string;
    sourceType: "first_party" | "public_web" | "human_note" | "import_artifact";
    sourceRef: string;
    observedAt: string;
    validThrough?: string | null;
    confidence: "high" | "medium" | "low";
    normalizedValue?: string | null;
    excerpt?: string | null;
  };
  createdAt: string;
  createdBy: string;
  clientId: string | null;
  clientAuthUid: string | null;
  delegationId: string | null;
  reviewedAt: string | null;
  reviewerUid: string | null;
  reviewReason: string | null;
  promotedEvidenceId: string | null;
}
