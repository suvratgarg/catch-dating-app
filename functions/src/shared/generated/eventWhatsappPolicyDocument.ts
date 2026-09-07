/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Reviewed event-service template and spend policy for one existing organizer-owned WhatsApp sender. This policy alone grants no guest consent or send authority.
 */
export interface EventWhatsappPolicyDocument {
  schemaVersion: 1;
  senderId: string;
  organizerId: string;
  revision: number;
  maxTemplateAgeSeconds: number;
  status: "inactive" | "ready" | "paused";
  providerAccountId: string;
  providerPhoneNumberId: string;
  activation: {
    approvalId: string;
    approvedAt: number;
    validUntil: number;
  };
  quote: {
    revision: number;
    currency: string;
    /**
     * @minItems 1
     * @maxItems 250
     */
    recipientPrefixes: string[];
    maxMicrosPerMessage: number;
    validUntil: number;
  };
  /**
   * @minItems 1
   * @maxItems 32
   */
  templates: {
    templateDocumentId: string;
    purpose:
      | "joiningUpdate"
      | "joiningInstructions"
      | "planChanged"
      | "guestRequirement"
      | "assignmentChanged"
      | "participationCheck"
      | "eventCancelled"
      | "eventFinished"
      | "followUp";
    templateHash: string;
    /**
     * @minItems 1
     * @maxItems 20
     */
    variables: {
      providerName: string;
      source:
        | "eventTitle"
        | "instruction"
        | "responseUrl"
        | "responseUrlSuffix";
      maxCharacters: number;
    }[];
    /**
     * @maxItems 10
     */
    quickReplies: {
      buttonIndex: number;
      choiceId: string;
      label: string;
      action:
        | "onMyWay"
        | "notComing"
        | "joinLater"
        | "helpLogistics"
        | "helpAccessibility"
        | "helpSafety"
        | "helpOther"
        | "acknowledge";
    }[];
  }[];
}
