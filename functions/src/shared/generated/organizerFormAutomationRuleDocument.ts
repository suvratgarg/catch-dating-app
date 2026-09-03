/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Manager-authored, revisioned, explicit form automation.
 */
export interface OrganizerFormAutomationRuleDocument {
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
    webhookSecret: string | null;
    channel: null | "whatsapp" | "email";
    campaignId?: string | null;
    campaignRevision?: number | null;
  }[];
  createdByUid: string;
  updatedByUid: string;
  /**
   * Serialized Firestore Timestamp fixture shape.
   */
  createdAt: {
    _seconds: number;
    _nanoseconds: number;
  };
  /**
   * Serialized Firestore Timestamp fixture shape.
   */
  updatedAt: {
    _seconds: number;
    _nanoseconds: number;
  };
  triggerEventId?: string | null;
  delayMinutes?: number;
  conditionVersionId?: string | null;
}
