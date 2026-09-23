/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export interface GetEventChatAccessCallableResponse {
  eventId: string;
  organizerId: string;
  title: string;
  role: "host" | "attendee";
  room: {
    status:
      | "notCreated"
      | "scheduled"
      | "open"
      | "announcementsOnly"
      | "paused"
      | "closed"
      | "archived";
    revision: number;
    opensAtMillis?: number | null;
    closesAtMillis?: number | null;
  };
  membership: {
    status: "notJoined" | "joined" | "left" | "removed" | "banned";
    revision: number;
    notificationsMuted?: boolean;
  };
  canManage: boolean;
  canJoin: boolean;
  canReadMessages: boolean;
  canPostMessages: boolean;
  profileClaimRequired: boolean;
  termsVersion: "event-chat-v1";
}
