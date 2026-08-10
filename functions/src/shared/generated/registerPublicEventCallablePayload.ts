/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Phone-authenticated website registration for a published Catch event without a Consumer profile.
 */
export interface RegisterPublicEventCallablePayload {
  eventId: string;
  displayName: string;
  /**
   * Optional, explicit opt-in to organizer marketing updates. Absence never grants consent.
   */
  organizerUpdates?: {
    whatsapp: boolean;
    sms: boolean;
    termsVersion: string;
  };
}
