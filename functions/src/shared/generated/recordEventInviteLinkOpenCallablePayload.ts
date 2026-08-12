/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Callable payload accepted by recordEventInviteLinkOpen. inviteLinkId accepts a legacy document id or a versioned opaque bearer token.
 */
export interface RecordEventInviteLinkOpenCallablePayload {
  eventId: string;
  inviteLinkId: string;
  surface?:
    | "consumerApp"
    | "hostApp"
    | "runtimeWeb"
    | "marketingWeb"
    | "unknown";
  sessionId?: string | null;
}
