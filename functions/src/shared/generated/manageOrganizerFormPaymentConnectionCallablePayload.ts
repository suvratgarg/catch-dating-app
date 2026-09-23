/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Manager-only merchant connection setup, safe listing, credential refresh, and local disconnection.
 */
export interface ManageOrganizerFormPaymentConnectionCallablePayload {
  organizerId: string;
  action: "begin" | "list" | "disconnect" | "refresh";
  connectionId: string | null;
}
