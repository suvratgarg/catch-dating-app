/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Set one program function's invitation mode and, for selectedGuests functions, the explicit invited guest list. The callable diffs the desired list against current programFunctionGuests rows; unknown guest ids are ignored.
 */
export interface ApplyProgramFunctionInvitationsCallablePayload {
  programId: string;
  functionId: string;
  /**
   * Whether the function invites every program guest or only the programFunctionGuests rows marked invited.
   */
  invitationMode: "allGuests" | "selectedGuests";
  /**
   * Desired invited guests for selectedGuests mode; ignored when invitationMode is allGuests.
   *
   * @maxItems 2000
   */
  selectedGuestIds?: string[];
  /**
   * Fences the function document read-modify-write.
   */
  expectedRevision: number;
}
