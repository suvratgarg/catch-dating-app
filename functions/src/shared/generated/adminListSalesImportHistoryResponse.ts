/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export interface AdminListSalesImportHistoryResponse {
  /**
   * @minItems 0
   * @maxItems 25
   */
  records: {
    schemaVersion: 1;
    classification: "sales_private";
    sourceId: string;
    sourceRowId: string;
    sourceContentHash: string;
    importId: string;
    organizerId: string;
    promotionVersion: string;
    recordId: string;
    kind: "activity" | "observation" | "benchmark";
    sourceColumn: string;
    sourceValue: string;
    occurredAt: string | null;
    dateSourceColumn: string | null;
    dateSourceValue: string | null;
    contentHash: string;
    recordedAt: string;
    recordedBy: string;
    providerConfirmed: false;
    currentFitAuthority: false;
    contactAuthority: false;
    sendAuthority: false;
    relativeChronology: "first_touch" | "last_touch" | "unspecified";
    dateCertainty: "source_exact" | "unknown";
  }[];
  nextCursor: string | null;
}
