/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Manager-only bounded organizer audience export request.
 */
export interface ExportOrganizerContactsCallablePayload {
  organizerId: string;
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
}
