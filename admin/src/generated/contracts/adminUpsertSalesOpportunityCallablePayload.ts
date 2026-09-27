/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Private bounded Sales callable request. Server authorization and transaction policy are enforced separately.
 */
export interface AdminUpsertSalesOpportunityCallablePayload {
  organizerId: string;
  requestId: string;
  expectedRevision: number;
  opportunityId?: string;
  fields: {
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
  };
  transitionReason?: string;
}
