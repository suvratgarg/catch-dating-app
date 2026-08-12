/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Claims one operational attendee after Firebase phone verification.
 */
export interface ClaimEventRuntimeAccessCallablePayload {
  publicRuntimeId: string;
  displayName: string;
  runtimeTermsVersion: string;
  attendeeToken?: string | null;
  /**
   * Legacy invite-link id or versioned opaque invitation bearer token.
   */
  inviteToken?: string | null;
}
