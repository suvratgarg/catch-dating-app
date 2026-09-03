/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Updated form automation projection.
 */
export type SetOrganizerFormAutomationStateCallableResponse = {
  ruleId: string;
  organizerId: string;
  formId: string | null;
  name: string;
  enabled: boolean;
  revision: number;
  trigger:
    | "responseSubmitted"
    | "responseWithdrawn"
    | "answerMatches"
    | "applicationAccepted"
    | "eventAttended";
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
    campaignId?: string | null;
    campaignRevision?: number | null;
  }[];
  updatedAtMillis: number;
  triggerEventId?: string | null;
  delayMinutes?: number;
};
