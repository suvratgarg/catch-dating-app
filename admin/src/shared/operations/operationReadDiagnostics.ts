import type {
  AdminListIntakeOperationsResponse,
  OperationUnavailableRecord,
} from "./operationsTypes";

// Client inventory can combine ordinary and human-review pages. Keep that
// accumulation separate from the callable's raw, single-page scan metadata.
export type OperationInventoryResponse = AdminListIntakeOperationsResponse & {
  readInventory?: {
    unavailableRecords: OperationUnavailableRecord[];
    humanReviewUnavailableDocumentIds: string[];
  };
};

export function unavailableOperationRecords(
  response: OperationInventoryResponse
): OperationUnavailableRecord[] {
  return response.readInventory?.unavailableRecords ??
    response.workItemPage?.unavailableRecords ?? [];
}

export function assertOperationReadPage(
  page: AdminListIntakeOperationsResponse
): void {
  const diagnostics = page.workItemPage;
  if (!diagnostics) return;
  const ids = new Set(page.workItems.map((item) => item.workItemId));
  for (const record of diagnostics.unavailableRecords) {
    if (ids.has(record.documentId)) {
      throw new Error("Supply Intake page repeated a document identifier.");
    }
    ids.add(record.documentId);
  }
  if (!Number.isSafeInteger(diagnostics.scannedCount) ||
      diagnostics.scannedCount < 0 || diagnostics.scannedCount > 200 ||
      diagnostics.scannedCount !== ids.size ||
      ids.size !== page.workItems.length +
        diagnostics.unavailableRecords.length ||
      (page.nextWorkItemCursor && diagnostics.scannedCount === 0)) {
    throw new Error("Supply Intake page has inconsistent scanned inventory.");
  }
}

export function mergeUnavailableOperationRecords(
  previous: OperationUnavailableRecord[],
  page: AdminListIntakeOperationsResponse
): OperationUnavailableRecord[] {
  assertOperationReadPage(page);
  const records = new Map(previous.map((record) => [
    record.documentId, record,
  ]));
  for (const item of page.workItems) {
    if (records.has(item.workItemId)) {
      throw new Error("Supply Intake document availability changed between pages.");
    }
  }
  for (const record of page.workItemPage?.unavailableRecords ?? []) {
    records.set(record.documentId, record);
  }
  return [...records.values()];
}

export function unavailableOperationRecordLabel(
  record: OperationUnavailableRecord
): string {
  const id = record.documentId.length > 160 ?
    `${record.documentId.slice(0, 160)}…` : record.documentId;
  const issues = record.issues.slice(0, 3).map((issue) =>
    `${issue.path || "/"}: ${issue.code}`).join("; ");
  return `${id} — ${record.reason.replaceAll("_", " ")}` +
    (issues ? ` (${issues})` : "") +
    (record.issuesTruncated || record.issues.length > 3 ?
      " [additional issues omitted]" : "");
}
