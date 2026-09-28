/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Private OTP recipient invitation and single-UID claim. Document ID hashes a random token; raw tokens and phone numbers are never persisted. Immutable offer/source/phone bindings are rechecked in every payment transaction.
 */
export interface OrganizerEventOfferRecipientDocument {
  organizerId: string;
  eventId: string;
  offerId: string;
  responseId: string;
  originId: string;
  contactId: string;
  issuedByUid: string;
  offerGeneration: number;
  offerRevision: number;
  issuedAtMillis: number;
  expiresAtMillis: number;
  phoneHash: string;
  recipientUid: string | null;
  claimedAtMillis: number | null;
  revokedAtMillis: number | null;
}
