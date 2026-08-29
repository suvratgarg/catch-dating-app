/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Server-derived communication routes and blockers for a named organizer intent at one capability snapshot.
 */
export interface ResolveOrganizerCommunicationPlanCallableResponse {
  organizerId: string;
  intent: "individualConversation";
  capabilityVersion: number;
  resolvedAtMillis: number;
  /**
   * @minItems 1
   * @maxItems 1
   */
  recipients: {
    contactId: string;
    displayName: string;
    outcome: "inCatch" | "automatic" | "byHand" | "unavailable";
    recommendedRouteId:
      | (
          | "personalWhatsappHandoff"
          | "organizerWhatsappCampaign"
          | "catchWhatsapp"
          | "catchChat"
          | "catchEventAnnouncement"
          | "organizerFollowerUpdate"
        )
      | null;
    /**
     * @minItems 2
     * @maxItems 2
     */
    routes: {
      routeId:
        | "personalWhatsappHandoff"
        | "organizerWhatsappCampaign"
        | "catchWhatsapp"
        | "catchChat"
        | "catchEventAnnouncement"
        | "organizerFollowerUpdate";
      executionMode: "managedDelivery" | "externalHandoff";
      availability: "available" | "unavailable";
      blocker:
        | (
            | "catchAccountRequired"
            | "identityAmbiguous"
            | "missingPhone"
            | "organizerSuppressed"
            | "contactOptedOut"
            | "permissionRequired"
            | "senderUnavailable"
            | "intentUnsupported"
          )
        | null;
    }[];
  }[];
}
