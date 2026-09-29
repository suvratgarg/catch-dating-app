/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Admin-authorized grant of one entitlement SKU to an organizer. operationId makes the mutation idempotent across retries; server stamps grantedAt and grantedBy.
 */
export interface AdminGrantOrganizerEntitlementCallablePayload {
  organizerId: string;
  operationId: string;
  sku:
    | "wedding_essentials"
    | "wedding_pro"
    | "wedding_signature"
    | "wedding_transport_addon"
    | "planner_annual";
  unit: "program" | "organizerYear";
  quantityTotal: number;
  validFromMillis?: number;
  validUntilMillis?: number | null;
  source: "manualInvoice" | "checkout" | "promo";
  receiptRef?: string;
  note?: string;
}
