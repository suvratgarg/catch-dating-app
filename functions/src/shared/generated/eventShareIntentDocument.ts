/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Evidence that a signed-in actor opened a Catch-owned share surface; it is not proof that a message was sent.
 */
export interface EventShareIntentDocument {
  eventId: string;
  organizerId: string;
  inviteLinkId: string;
  actorUid: string;
  actorKind: "host" | "attendee" | "member";
  surface: "hostApp" | "consumerApp" | "runtimeWeb";
  creativeId: string | null;
  channelHint: "systemShare" | "copyLink" | "whatsapp" | "sms" | "email" | null;
  /**
   * Serialized Firestore Timestamp fixture shape.
   */
  createdAt: {
    _seconds: number;
    _nanoseconds: number;
  };
  /**
   * Serialized Firestore Timestamp fixture shape.
   */
  expiresAt: {
    _seconds: number;
    _nanoseconds: number;
  };
}
