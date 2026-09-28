export interface SalesImportedHistoryRecord {
  schemaVersion: 1;
  classification: "sales_private";
  recordId: string;
  sourceId: string;
  sourceRowId: string;
  sourceContentHash: string;
  importId: string;
  organizerId: string;
  promotionVersion: string;
  kind: "activity" | "observation" | "benchmark";
  sourceColumn: string;
  sourceValue: string;
  relativeChronology: "first_touch" | "last_touch" | "unspecified";
  dateCertainty: "source_exact" | "unknown";
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
}
export interface SalesImportedHistoryRow {
  schemaVersion: 1;
  classification: "sales_private";
  rowId: string;
  sourceId: string;
  sourceRowId: string;
  sourceContentHash: string;
  importId: string;
  organizerId: string;
  promotionVersion: string;
  disposition: "promoted" | "skipped" | "review_needed";
  reason: string;
  recordIds: string[];
  reviewHash: string;
  reviewedAt: string;
  reviewedBy: string;
}
export interface SalesImportedHistoryPage<T> {
  records?: T[];
  rows?: T[];
  nextCursor: string | null;
}
export interface SalesHistoryApi {
  listRecords: (input: {organizerId: string; cursor?: string;
    limit: number}) => Promise<{records: SalesImportedHistoryRecord[];
    nextCursor: string | null}>;
  listRows: (input: {organizerId: string; cursor?: string;
    limit: number}) => Promise<{rows: SalesImportedHistoryRow[];
    nextCursor: string | null}>;
}
