/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export interface AdminGetSalesFunnelReportResponse {
  activeHosts: number;
  opportunities: number;
  hostsWithOpportunities: number;
  overdueOpportunities: number;
  hostsWithOverdueOpportunities: number;
  opportunitiesMissingNextStep: number;
  openObligations: number;
  overdueObligations: number;
  heldHosts: number;
  duplicateReviewHosts: number;
  excludedArchivedOrRestrictedHosts: number;
  movementEvents: number;
  schemaVersion: 1;
  asOf: string;
  since: string;
  coverage: "complete_bounded_snapshot";
  revenueStatus: "not_calculated";
  /**
   * @minItems 11
   * @maxItems 11
   */
  stages: {
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
    opportunities: number;
    distinctHosts: number;
    enteredInWindow: number;
    distinctHostsEntered: number;
  }[];
}
