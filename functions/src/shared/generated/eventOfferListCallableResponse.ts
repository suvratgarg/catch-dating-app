/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export interface EventOfferListCallableResponse {
  /**
   * @maxItems 50
   */
  items: {
    offerId: string;
    eventId: string;
    contactId: string;
    sourceKind: "application" | "formResponse";
    sourceId: string;
    status: "draft" | "offered" | "withdrawn" | "expired";
    effectiveStatus: "draft" | "offered" | "withdrawn" | "expired";
    paymentStatus:
      | "none"
      | "evidenceSubmitted"
      | "hostAttestedReceived"
      | "rejected";
    revision: number;
    generation: number;
    expiresAtMillis: number;
  }[];
  nextCursor: string | null;
}
