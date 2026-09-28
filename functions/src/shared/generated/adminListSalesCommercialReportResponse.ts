/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export interface AdminListSalesCommercialReportResponse {
  /**
   * @maxItems 25
   */
  rows: {
    opportunityId: string;
    stage: string;
    ownerUid: string;
    pilotStatus:
      | ("draft" | "reviewed" | "active" | "completed" | "cancelled")
      | null;
    pilotRevision: number | null;
    quoteStatus: ("draft" | "approved" | "accepted_reviewed") | null;
    quoteRevision: number | null;
    termVersion: number | null;
    paymentStatus: "unknown" | "manual_attested";
    manuallyAttestedHostRevenue: {
      amountMinor: number;
      currency: string;
      providerConfirmed: false;
      purpose: "host_subscription";
    } | null;
    bookedHostRevenueMinor: null;
  }[];
  nextCursor: string | null;
  pageScope: true;
}
