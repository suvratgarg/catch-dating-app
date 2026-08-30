/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Current route advice for manual tasks. Returning this response never mutates or completes a task.
 */
export interface ReplanOrganizerManualSendTasksCallableResponse {
  organizerId: string;
  /**
   * @minItems 1
   * @maxItems 50
   */
  results: {
    taskId: string;
    contactId: string;
    disposition:
      | "keepByHand"
      | "managedRouteAvailable"
      | "unavailable"
      | "taskInactive";
    recommendedRouteId: "catchChat" | "personalWhatsappHandoff" | null;
    blocker:
      | "catchAccountRequired"
      | "identityAmbiguous"
      | "missingPhone"
      | "organizerSuppressed"
      | "contactOptedOut"
      | "contactUnavailable"
      | "endpointChanged"
      | null;
  }[];
  resolvedAtMillis: number;
}
