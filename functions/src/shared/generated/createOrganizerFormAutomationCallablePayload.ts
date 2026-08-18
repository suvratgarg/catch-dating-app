/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Creates or replaces an explicit form automation under an optimistic revision guard.
 */
export interface CreateOrganizerFormAutomationCallablePayload {
  organizerId: string;
  formId: string;
  ruleId: string | null;
  requestId: string;
  expectedRevision: number | null;
  name: string;
  enabled: boolean;
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
    webhookSecret: string | null;
    channel: null | "whatsapp" | "email";
  }[];
}
