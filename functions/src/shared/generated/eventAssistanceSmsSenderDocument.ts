/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export interface EventAssistanceSmsSenderDocument {
  schemaVersion: 1;
  senderId: string;
  revision: number;
  provider: "gupshup";
  senderIdentity: "catchPlatform";
  country: "IN";
  status: "inactive" | "ready" | "paused";
  mask: string;
  principalEntityId: string;
  credentialVersion: string;
  activation: {
    useCaseApprovalId: string;
    senderApprovalId: string;
    approvedAt: number;
    validUntil: number;
  };
  maxSegments: number;
  quote: {
    revision: number;
    currency: "INR";
    maxMicrosPerSegment: number;
    validUntil: number;
  };
  /**
   * @minItems 1
   * @maxItems 32
   */
  templates: {
    templateId: string;
    revision: number;
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
    dltTemplateId: string;
    status: "pending" | "approved" | "paused";
    /**
     * @minItems 1
     * @maxItems 16
     */
    parts: (
      | {
          kind: "literal";
          text: string;
        }
      | {
          kind: "variable";
          name: "eventTitle" | "instruction" | "responseUrl";
          maxCharacters: number;
        }
    )[];
  }[];
}
