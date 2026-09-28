/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Private sales pipeline stage, independent of public organizer status.
 */
export interface SalesOpportunityDocument {
  schemaVersion: 1;
  classification: "sales_private";
  opportunityId: string;
  organizerId: string;
  revision: number;
  motion: string;
  stage:
    | "new_enquiry"
    | "ready_to_contact"
    | "contacted"
    | "in_conversation"
    | "demo_arranged"
    | "demo_completed"
    | "pilot_agreed"
    | "pilot_running"
    | "commercial_discussion"
    | "closed_won"
    | "closed_lost";
  ownerUid: string;
  nextStep: string | null;
  nextStepAt: string | null;
  stageEnteredAt: string;
  createdAt: string;
  updatedAt: string;
  updatedBy: string;
}
