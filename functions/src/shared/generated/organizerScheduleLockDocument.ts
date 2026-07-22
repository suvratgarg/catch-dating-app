/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Server-owned time-slot claim stored at organizerScheduleLocks/{organizerId_slot}.
 */
export interface OrganizerScheduleLockDocument {
  ownerType: "organizer";
  ownerId: string;
  slot: number;
  eventId: string;
  organizerId: string;
  startTimeMillis: number;
  endTimeMillis: number;
}
