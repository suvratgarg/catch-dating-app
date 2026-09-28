/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export interface OutreachDraftingInput {
  schemaVersion: 1;
  organizer: {
    organizerId: string;
    name: string;
    revision: number;
    identityStatus: "verified";
  };
  contact: {
    contactId: string;
    revision: number;
    role: string;
    eligibility: "eligible";
    suppressionStatus: "clear";
    claimStatus: "verified" | "not_required";
  };
  opportunity: {
    opportunityId: string;
    revision: number;
    stage: string;
    motion: string;
  };
  language: "en";
  channel: "email" | "message";
  purpose: "first_message" | "follow_up";
  evaluatedAt: string;
  policy: {
    promptVersion: string;
    playbookVersion: string;
    modelId: string;
  };
  /**
   * @maxItems 12
   */
  observations: {
    id: string;
    text: string;
    revision: number;
    organizerId: string;
    approved: true;
    validUntil: string;
  }[];
  /**
   * @maxItems 12
   */
  capabilities: {
    id: string;
    text: string;
    revision: number;
    organizerId: string;
    approved: true;
    validUntil: string;
  }[];
  /**
   * @maxItems 8
   */
  references: {
    id: string;
    text: string;
    revision: number;
    organizerId: string;
    approved: true;
    validUntil: string;
  }[];
  /**
   * @minItems 1
   * @maxItems 8
   */
  ctas: {
    id: string;
    text: string;
    revision: number;
  }[];
  priorInteraction: null | {
    activityId: string;
    summary: string;
    revision: number;
  };
  evidenceConflictStatus: "clear" | "needs_review";
}
