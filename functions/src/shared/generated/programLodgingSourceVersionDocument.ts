/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Private transactional revision counters backed by complete canonical source fingerprints. Contains no copied guest or property records. Changes invalidate proposals; publication advances its own domain atomically with canonical stays.
 */
export interface ProgramLodgingSourceVersionDocument {
  programId: string;
  organizerId: string;
  versions: {
    source: {
      revision: number;
      fingerprint: string;
    };
    inventory: {
      revision: number;
      fingerprint: string;
    };
    layout: {
      revision: number;
      fingerprint: string;
    };
    published: {
      revision: number;
      fingerprint: string;
    };
  };
}
