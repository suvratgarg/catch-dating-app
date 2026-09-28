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
   * How many programTravelLegs rows this submit wrote from its travel blocks.
   */
  travelLegAppliedCount: number;
  /**
   * The consent state now recorded on the household.
   */
  messagingConsentGranted: boolean;
  alreadyApplied: boolean;
}
