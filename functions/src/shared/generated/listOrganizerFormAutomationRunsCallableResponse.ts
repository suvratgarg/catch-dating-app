/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Form automation definitions and bounded observable run history.
 */
export interface ListOrganizerFormAutomationRunsCallableResponse {
  /**
   * @maxItems 100
   */
  rules: {
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
  }[];
  /**
   * @maxItems 100
   */
  runs: {
    runId: string;
    ruleId: string;
    ruleRevision: number;
    responseId: string | null;
    eventKind:
      | "submitted"
      | "withdrawn"
      | "applicationAccepted"
      | "eventAttended";
    status:
      | "pending"
      | "running"
      | "succeeded"
      | "partiallyFailed"
      | "failed"
      | "skipped";
    attemptCount: number;
    /**
     * @maxItems 10
     */
    actionResults: {
      [k: string]: unknown;
    }[];
    errorMessage: string | null;
    createdAtMillis: number;
    completedAtMillis: number | null;
    sourceId?: string | null;
    dueAtMillis?: number | null;
  }[];
  nextCursor: string | null;
}
