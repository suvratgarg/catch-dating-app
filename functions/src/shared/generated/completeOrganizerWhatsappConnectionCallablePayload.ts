/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Server-side completion of Meta Embedded Signup using the short-lived authorization code returned to the Host surface.
 */
export interface CompleteOrganizerWhatsappConnectionCallablePayload {
  organizerId: string;
  authorizationCode: string;
  wabaId: string;
  phoneNumberId: string;
  businessId?: string | null;
}
