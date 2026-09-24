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
  /**
   * Active CRM saved audience. Required for recipientSource.kind=savedAudience (the default); must be null for programSelection.
   */
  savedAudienceId: string | null;
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
  /**
   * Recipient resolution. Absent reads as savedAudience backed by savedAudienceId. programSelection resolves program guests/households instead of CRM contacts.
   */
  recipientSource?: {
    kind: "savedAudience" | "programSelection";
    /**
     * Required when kind=programSelection; ignored otherwise.
     */
    programId?: string | null;
    /**
     * Restricts to guests invited to these functions; null or empty means every function in the program.
     *
     * @maxItems 32
     */
    functionIds?: string[] | null;
    /**
     * Restricts to matching per-function RSVP statuses; null or empty means every effective status.
     *
     * @maxItems 4
     */
    rsvpStatuses?: ("pending" | "attending" | "declined" | "maybe")[] | null;
    /**
     * When true, guests sharing a household collapse into one recipient. Default true.
     */
    householdDedupe?: boolean | null;
  } | null;
}
