/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Private immutable placement proposal tied to source, inventory, layout and published revisions. Server validates content identity and current canonical Programs scope; no hotel affinity or medical projection is public.
 */
export interface ProgramLodgingProposalDocument {
  programId: string;
  organizerId: string;
  proposal: {
    scope: {
      programId: string;
      organizerId: string;
    };
    id: string;
    revisions: {
      source: number;
      inventory: number;
      layout: number;
      published: number;
    };
    /**
     * @maxItems 500
     */
    placements: {
      partyId: string;
      inventoryId: string;
    }[];
    /**
     * @maxItems 500
     */
    unplacedPartyIds: string[];
    /**
     * @maxItems 502
     */
    explanations: string[];
    /**
     * @minItems 5
     * @maxItems 5
     */
    score: number[];
    search: {
      complete: boolean;
      explored: number;
    };
  };
  createdByUid: string;
  createdAtMillis: number;
}
