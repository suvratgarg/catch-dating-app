/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Saved form automation projection.
 */
export type CreateOrganizerFormAutomationCallableResponse = {
  ruleId: string;
  organizerId: string;
  formId: string;
  name: string;
  enabled: boolean;
  revision: number;
  trigger: "responseSubmitted" | "responseWithdrawn" | "answerMatches";
  condition: {
    questionId: string;
    operator:
      | "equals"
      | "notEquals"
      | "contains"
      | "notContains"
      | "greaterThan"
      | "lessThan"
      | "answered"
      | "notAnswered";
    /**
     * @maxItems 20
     */
    expectedValues: (string | number | boolean)[];
  } | null;
  /**
   * @minItems 1
   * @maxItems 10
   */
  actions: {
    actionId: string;
    kind:
      | "notifyTeam"
      | "addOrganizerTag"
      | "createCrmContact"
      | "addApplicationQueue"
      | "proposeEventAttendee"
      | "signedWebhook"
      | "campaignHandoff";
    tagId: string | null;
    eventId: string | null;
    webhookUrl: string | null;
    webhookSecretConfigured: boolean;
    channel: null | "whatsapp" | "email";
  }[];
  updatedAtMillis: number;
};
