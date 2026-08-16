/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Manager-authorized paginated organizer audience query.
 */
export interface ListOrganizerContactsCallablePayload {
  organizerId: string;
  limit?: number;
  cursor?: string | null;
  query?: string | null;
  sort?: "lastSeen" | "mostAttended" | "name";
  segmentId?:
    | (
        | "new_to_organizer"
        | "first_time_attendee"
        | "repeat_attendee"
        | "regular"
        | "lapsed_regular"
        | "reliable_attendee"
        | "needs_confirmation"
        | "advocate"
        | "high_impact_advocate"
        | "whatsapp_reachable"
        | "sms_reachable"
      )
    | null;
  manualTagId?: string | null;
}
