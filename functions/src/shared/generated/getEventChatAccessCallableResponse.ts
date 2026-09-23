/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export interface GetEventChatAccessCallableResponse {
  eventId: string;
  organizerId: string;
  title: string;
  role: "host" | "attendee";
  room: {
    status: "notCreated" | "open" | "closed";
    revision: number;
  };
  membership: {
    status: "notJoined" | "joined" | "left";
    revision: number;
  };
  canManage: boolean;
  canJoin: boolean;
  canReadMessages: boolean;
  profileClaimRequired: boolean;
  termsVersion: "event-chat-v1";
}
