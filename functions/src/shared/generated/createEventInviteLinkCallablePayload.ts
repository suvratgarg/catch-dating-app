/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Callable payload accepted by createEventInviteLink for Host channels, direct recipients, partners, promoters, or eligible attendee referrers.
 */
export interface CreateEventInviteLinkCallablePayload {
  eventId: string;
  label: string;
  source?: string | null;
  linkKind?:
    | "hostChannel"
    | "directRecipient"
    | "attendeeReferrer"
    | "promoter"
    | "partner";
  intendedRecipientContactId?: string | null;
  campaignId?: string | null;
  destinationKind?:
    | "catchEvent"
    | "eventRuntime"
    | "externalBooking"
    | "marketingLanding";
  attributionWindowDays?: number | null;
}
