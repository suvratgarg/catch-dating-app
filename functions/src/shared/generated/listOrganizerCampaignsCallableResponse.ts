/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Reverse-chronological organizer Sends rows mixing WhatsApp campaigns and event announcements.
 */
export interface ListOrganizerCampaignsCallableResponse {
  organizerId: string;
  /**
   * @maxItems 50
   */
  sends: (
    | {
        kind: "campaign";
        campaignId: string;
        name: string;
        status:
          | "draft"
          | "previewed"
          | "approved"
          | "scheduled"
          | "resolving"
          | "sending"
          | "completed"
          | "partiallyFailed"
          | "cancelled"
          | "blocked";
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
        templateId: string;
        templateName: string | null;
        audienceCounts: {
          total: number;
          reachable: number;
          optedOut: number;
          invalid: number;
          duplicate: number;
          unsupported: number;
          frequencyCapped: number;
          providerBlocked: number;
          unknown: number;
        };
        deliveryCounts: {
          pending: number;
          suppressed: number;
          accepted: number;
          sent: number;
          delivered: number;
          read: number;
          failed: number;
          replied: number;
          optedOut: number;
        };
        scheduledAtMillis: number | null;
        dispatchedAtMillis: number | null;
        activityAtMillis: number;
      }
    | {
        kind: "announcement";
        broadcastId: string;
        eventId: string;
        eventName: string;
        audience: "booked" | "prospective" | "everyone";
        recipientCount: number;
        sentAtMillis: number;
        partialFailure: boolean;
        activityAtMillis: number;
      }
  )[];
  nextCursor: string | null;
}
