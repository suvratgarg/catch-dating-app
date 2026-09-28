/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Human-owned follow-up; a task does not authorize contacting or sending.
 */
export interface SalesTaskDocument {
  schemaVersion: 1;
  classification: "sales_private";
  taskId: string;
  organizerId: string;
  contactId: string | null;
  revision: number;
  kind:
    | "research"
    | "reply"
    | "follow_up"
    | "demo"
    | "pilot"
    | "duplicate_review"
    | "opt_out"
    | "service_commitment";
  title: string;
  dueAt: string | null;
  ownerUid: string;
  status: "open" | "completed" | "cancelled";
  createdAt: string;
  updatedAt: string;
  updatedBy: string;
}
