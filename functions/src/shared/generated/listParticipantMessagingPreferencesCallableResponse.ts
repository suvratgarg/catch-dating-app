/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Bounded participant-only WhatsApp permission directory; no contact endpoints or CRM fields.
 */
export interface ListParticipantMessagingPreferencesCallableResponse {
  catchPreference: {
    status: "unknown" | "optedIn" | "optedOut";
    purposes?: {
      eventOperations?: {
        status: "unknown" | "optedIn" | "optedOut";
        receiptId: string | null;
      };
      marketing?: {
        status: "unknown" | "optedIn" | "optedOut";
        receiptId: string | null;
      };
    };
    receiptId: string | null;
  };
  /**
   * @maxItems 30
   */
  organizers: {
    organizerId: string;
    organizerName: string | null;
    preference: {
      status: "unknown" | "optedIn" | "optedOut";
      purposes?: {
        eventOperations?: {
          status: "unknown" | "optedIn" | "optedOut";
          receiptId: string | null;
        };
        marketing?: {
          status: "unknown" | "optedIn" | "optedOut";
          receiptId: string | null;
        };
      };
      receiptId: string | null;
    };
  }[];
  nextCursor: string | null;
}
