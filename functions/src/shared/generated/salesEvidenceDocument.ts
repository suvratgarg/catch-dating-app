/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Reviewed source lineage for Sales claims; not provider consent or ownership verification.
 */
export type SalesEvidenceDocument = {
  [k: string]: unknown;
} & {
  schemaVersion: 1;
  classification: "sales_private";
  evidenceId: string;
  organizerId: string;
  contactId: string | null;
  claimKey: "identity" | "recurrence" | "operation" | "stack" | "other";
  signalId: string | null;
  sourceType: "first_party" | "public_web" | "human_note" | "import_artifact";
  sourceRef: string;
  observedAt: string;
  validThrough: string | null;
  confidence: "high" | "medium" | "low";
  normalizedValue: string | null;
  excerpt: string | null;
  reviewedAt: string;
  reviewerUid: string;
  createdAt: string;
  createdBy: string;
};
