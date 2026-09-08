/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export interface EventAssistanceRcsConfig {
  schemaVersion: 1;
  senderId: string;
  revision: number;
  provider: "googleRbm";
  senderIdentity: "catchPlatform";
  agentId: string;
  region: "asia" | "europe" | "us";
  status: "inactive" | "ready" | "paused";
  credentialVersion: string;
  /**
   * @minItems 1
   * @maxItems 20
   */
  recipientPrefixes: string[];
  activation: {
    approvalId: string;
    approvedAt: number;
    validUntil: number;
  };
  quote: {
    revision: number;
    currency: string;
    maxMicrosPerMessage: number;
    validUntil: number;
  };
  maxQueueSeconds: number;
  /**
   * @minItems 1
   * @maxItems 9
   */
  allowedPurposes: (
    | "joiningUpdate"
    | "joiningInstructions"
    | "planChanged"
    | "guestRequirement"
    | "assignmentChanged"
    | "participationCheck"
    | "eventCancelled"
    | "eventFinished"
    | "followUp"
  )[];
}
