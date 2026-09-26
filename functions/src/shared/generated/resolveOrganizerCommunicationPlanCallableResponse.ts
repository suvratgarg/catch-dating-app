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
          | "personalEmailHandoff"
          | "organizerWhatsappCampaign"
          | "catchWhatsapp"
          | "catchChat"
          | "catchEventAnnouncement"
          | "organizerFollowerUpdate"
        )
      | null;
    /**
     * @minItems 3
     * @maxItems 3
     */
    routes: {
      routeId:
        | "personalWhatsappHandoff"
        | "personalEmailHandoff"
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
            | "missingEmail"
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
