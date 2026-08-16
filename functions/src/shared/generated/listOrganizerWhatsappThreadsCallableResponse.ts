/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export interface ListOrganizerWhatsappThreadsCallableResponse {
  organizerId: string;
  /**
   * @maxItems 50
   */
  threads: {
    threadId: string;
    contactId: string;
    displayName: string;
    /**
     * @maxItems 50
     */
    eventIds: string[];
    lastMessageBody: string;
    lastMessageDirection: "inbound" | "outbound";
    lastMessageAtMillis: number;
    lastInboundAtMillis: number;
    serviceWindowExpiresAtMillis: number;
    serviceWindowOpen: boolean;
  }[];
  nextCursor: string | null;
}
