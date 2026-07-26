/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Callable payload accepted by adminTakedownExternalEvent. Dry-run validates and receipts a reviewed takedown; apply removes the external event from discovery without deleting audit history.
 */
export interface AdminTakedownExternalEventCallablePayload {
  eventId: string;
  executionMode: "dry_run" | "apply";
  idempotencyKey: string;
  reviewNote: string;
  checklist: {
    sourceStatusReviewed: boolean;
    takedownAuthorityReviewed: boolean;
    downstreamVisibilityReviewed: boolean;
  };
}
