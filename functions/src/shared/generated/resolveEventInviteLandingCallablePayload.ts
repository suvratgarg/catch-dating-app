/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Resolves an opaque invitation bearer token into one bounded event landing projection and records a deduplicated open.
 */
export interface ResolveEventInviteLandingCallablePayload {
  inviteToken: string;
  sessionId?: string | null;
}
