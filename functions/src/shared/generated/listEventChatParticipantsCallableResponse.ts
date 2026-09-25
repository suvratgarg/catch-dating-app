/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export interface ListEventChatParticipantsCallableResponse {
  /**
   * @maxItems 10
   */
  items: {
    uid: string;
    displayName: string;
    role: "host" | "attendee";
    membershipStatus: "joined" | "removed" | "banned";
    membershipRevision: number;
  }[];
  nextCursor: {
    eventId: string;
    accountUid: string;
    after: string;
  } | null;
}
