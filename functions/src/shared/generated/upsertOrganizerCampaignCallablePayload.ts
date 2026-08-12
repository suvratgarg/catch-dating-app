/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Creates or revision-updates one draft WhatsApp organizer campaign.
 */
export interface UpsertOrganizerCampaignCallablePayload {
  organizerId: string;
  campaignId?: string | null;
  requestId: string;
  expectedRevision?: number | null;
  name: string;
  messageClass: "eventFollowUp" | "organizerUpdate" | "organizerPromotion";
  /**
   * @minItems 1
   * @maxItems 5
   */
  segmentIds: (
    | "first_time_attendee"
    | "repeat_attendee"
    | "regular"
    | "lapsed_regular"
    | "reliable_attendee"
    | "advocate"
    | "high_impact_advocate"
    | "whatsapp_reachable"
  )[];
  connectionId: string;
  templateId: string;
  templateVariables: {
    [k: string]: string;
  };
  eventId?: string | null;
  inviteDestinationKind?:
    | null
    | "catchEvent"
    | "eventRuntime"
    | "externalBooking"
    | "marketingLanding";
  scheduledAtMillis?: number | null;
}
