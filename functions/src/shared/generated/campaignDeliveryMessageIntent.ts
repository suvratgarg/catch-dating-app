/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export interface CampaignDeliveryMessageIntent {
  schemaVersion: 1;
  intentId: string;
  revision: number;
  context: {
    mode: "live";
    organizerId: string;
    campaignId: string;
    recipientId: string;
  };
  campaignId: string;
  recipient: {
    kind: "campaignRecipient";
    /**
     * organizerCampaignRecipients document id — the frozen per-recipient campaign row. Endpoint and consent facts resolve at claim time, never in the intent.
     */
    recipientKey: string;
  };
  workflow: {
    kind: "campaignDispatch";
    campaignId: string;
    recipientId: string;
  };
  createdAt: number;
  expiresAt: number;
  /**
   * @minItems 1
   * @maxItems 1
   */
  permittedRoutes: "organizerWhatsappCampaign"[];
  deliveryPolicy: {
    maxAttempts: number;
    maxAttemptsPerRoute: number;
    minimumRetrySeconds: number;
  };
  kind: "campaignMessage";
  /**
   * The campaign dispatch epoch (dispatchedAt millis) this intent was issued under. Reservation authority expires when the campaign's dispatch epoch changes.
   */
  instructionRevision: number;
  /**
   * Approved WhatsApp template content frozen from the campaign/recipient snapshot; sender credentials never appear here.
   */
  whatsapp: {
    connectionId: string;
    templateId: string;
    variables: {
      [k: string]: string;
    };
  };
}
