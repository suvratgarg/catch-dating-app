/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Private immutable choice mapping committed with one live outbox dispatch claim. Native IDs provide correlation, never bearer authentication. A signed queued reply must match the original sender, recipient and confirmed provider message before the shared guest-action transaction can apply its stored choice.
 */
export interface EventWhatsappReplyBindingDocument {
  schemaVersion: 1;
  attemptId: string;
  messageId: string;
  context: {
    mode: "live";
    eventId: string;
    organizerId: string;
  };
  guestId: string;
  attendeeId: string;
  episodeId: string;
  attendeeGeneration: string;
  guestRevision: number;
  attemptScopeHash: string;
  senderId: string;
  bindingRevision: number;
  providerAccountId: string;
  providerPhoneNumberId: string;
  recipientEndpointId: string;
  endpointHash: string;
  replyKind: "templateQuickReply" | "replyButton" | "listReply";
  /**
   * @minItems 1
   * @maxItems 20
   */
  choices: {
    nativeId: string;
    choiceId: string;
  }[];
  createdAt: number;
  expiresAt: number;
  intentHash: string;
}
