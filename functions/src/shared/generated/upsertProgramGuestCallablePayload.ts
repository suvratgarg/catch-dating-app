/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Create or update one program guest. guestId absent creates; expectedRevision fences updates. A shared phone never merges guests.
 */
export interface UpsertProgramGuestCallablePayload {
  programId: string;
  guestId?: string;
  expectedRevision?: number;
  displayName: string;
  householdId?: string | null;
  /**
   * When present, replaces the guest's programGuestGroups membership. Every id must belong to the same program and organizer. Omitted preserves existing membership.
   *
   * @maxItems 20
   */
  groupIds?: string[];
  phoneE164?: string | null;
  email?: string | null;
  externalReference?: string | null;
  rsvpStatus?: "pending" | "attending" | "declined" | "maybe";
}
