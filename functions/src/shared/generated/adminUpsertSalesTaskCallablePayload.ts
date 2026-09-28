/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Private bounded Sales callable request. Server authorization and transaction policy are enforced separately.
 */
export interface AdminUpsertSalesTaskCallablePayload {
  organizerId: string;
  requestId: string;
  expectedRevision: number;
  taskId?: string;
  task: {
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
    contactId?: string | null;
    ownerUid: string;
    status: "open" | "completed" | "cancelled";
  };
}
