/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Acknowledgement for a household RSVP submit: the household id, its committed revision, and how many function responses landed.
 */
export interface SubmitProgramHouseholdRsvpCallableResponse {
  /**
   * The household document id.
   */
  entityId: string;
  revision: number;
  appliedCount: number;
  /**
   * The consent state now recorded on the household.
   */
  messagingConsentGranted: boolean;
  alreadyApplied: boolean;
}
