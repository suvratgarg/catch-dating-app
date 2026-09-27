/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Private bounded Sales callable request. Server authorization and transaction policy are enforced separately.
 */
export interface AdminAddSalesEvidenceCallablePayload {
  organizerId: string;
  contactId?: string | null;
  requestId: string;
  claimKey: "identity" | "recurrence" | "operation" | "stack" | "other";
  signalId?: string;
  sourceType: "first_party" | "public_web" | "human_note" | "import_artifact";
  sourceRef: string;
  observedAt: string;
  validThrough?: string | null;
  confidence: "high" | "medium" | "low";
  normalizedValue?: string | null;
  excerpt?: string | null;
}
