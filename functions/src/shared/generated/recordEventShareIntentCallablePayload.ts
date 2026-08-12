/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Records that a signed-in actor opened a Catch share surface. It never claims a message was sent or forwarded.
 */
export interface RecordEventShareIntentCallablePayload {
  eventId: string;
  inviteLinkId: string;
  surface: "hostApp" | "consumerApp" | "runtimeWeb";
  creativeId?: string | null;
  channelHint?:
    | "systemShare"
    | "copyLink"
    | "whatsapp"
    | "sms"
    | "email"
    | null;
}
