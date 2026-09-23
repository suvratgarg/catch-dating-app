/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Manager/coordinator guest inventory with household labels. Contact fields are present because this surface requires the programCoordinator duty or organizer management.
 */
export interface ProgramGuestListCallableResponse {
  programId: string;
  /**
   * @maxItems 200
   */
  guests: {
    guestId: string;
    displayName: string;
    householdId: string | null;
    phoneE164: string | null;
    email: string | null;
    externalReference: string | null;
    invitationStatus: "notInvited" | "invited" | "delivered" | "responded";
    rsvpStatus: "pending" | "attending" | "declined" | "maybe";
    revision: number;
  }[];
  /**
   * @maxItems 500
   */
  households: {
    householdId: string;
    label: string;
    /**
     * @maxItems 50
     */
    memberGuestIds: string[];
    revision: number;
  }[];
  nextCursor: string | null;
}
