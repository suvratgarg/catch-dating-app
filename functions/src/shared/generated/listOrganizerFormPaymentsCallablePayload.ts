/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Manager-only bounded fee ledger for one owned form, independent of the response inbox.
 */
export interface ListOrganizerFormPaymentsCallablePayload {
  organizerId: string;
  formId: string;
  /**
   * @maxItems 11
   */
  statuses: (
    | "creatingOrder"
    | "orderUnknown"
    | "checkoutReady"
    | "verifying"
    | "captured"
    | "submitted"
    | "failed"
    | "expired"
    | "refundPending"
    | "refunded"
    | "reviewRequired"
  )[];
  cursor: string | null;
  limit: number;
}
