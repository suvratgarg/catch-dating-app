/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Private account identity and optional own organizer-follow state.
 */
export interface ManageWebsiteAccountCallableResponse {
  uid: string;
  accountReady: boolean;
  displayName: string;
  phoneNumber: string | null;
  dateOfBirth: string | null;
  profileRevision: number;
  /**
   * Null unless an organizer was requested. Reflects only the authenticated UID relationship.
   */
  following: boolean | null;
  eventAge: null | {
    minimum: number;
    maximum: number;
    eligible: boolean;
    needsDateOfBirth: boolean;
  };
}
