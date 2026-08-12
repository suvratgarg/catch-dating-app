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
   * Legacy invite-link id or versioned opaque invitation bearer token.
   */
  inviteToken?: string | null;
  /**
   * Optional, explicit opt-in to organizer marketing updates. Absence never grants consent.
   */
  organizerUpdates?: {
    whatsapp: boolean;
    sms: boolean;
    termsVersion: string;
  };
}
