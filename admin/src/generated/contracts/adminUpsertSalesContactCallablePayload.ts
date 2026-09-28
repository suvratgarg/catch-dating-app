/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Private bounded Sales callable request. Server authorization and transaction policy are enforced separately.
 */
export interface AdminUpsertSalesContactCallablePayload {
  organizerId: string;
  requestId: string;
  expectedRevision: number;
  contactId?: string;
  linkExisting?: boolean;
  contact: {
    displayName: string;
  };
  relationship: {
    role: string;
    decisionInfluence: "unknown" | "decision_maker" | "influencer" | "operator";
    primary: boolean;
    /**
     * @maxItems 3
     */
    endpoints?: {
      kind: "email" | "phone";
      value: string;
      verificationStatus: "unverified" | "verified";
      evidenceId?: string | null;
    }[];
  };
}
