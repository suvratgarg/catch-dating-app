/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Creates or revision-updates one draft WhatsApp organizer campaign that consumes a Customers-owned saved audience id.
 */
export interface UpsertOrganizerCampaignCallablePayload {
  organizerId: string;
  campaignId?: string | null;
  requestId: string;
  expectedRevision?: number | null;
  name: string;
  messageClass: "eventFollowUp" | "organizerUpdate" | "organizerPromotion";
  savedAudienceId: string;
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
