/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Private program workflow. Host approval, individual hotel confirmation and guest publication are distinct states. Publication changes canonical stays and this workflow atomically.
 */
export interface ProgramLodgingWorkflowDocument {
  programId: string;
  organizerId: string;
  workflow: {
    revision: number;
    approvedProposalId: string | null;
    /**
     * @maxItems 500
     */
    confirmedHotelIds: string[];
    guestPublishedProposalId: string | null;
  };
}
