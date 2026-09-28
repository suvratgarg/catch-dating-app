/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

import type {OutreachDraftingSelection} from "./outreachDraftingSelection";

export interface OutreachDraft {
  schemaVersion: 1;
  draftId: string;
  organizerId: string;
  contactId: string;
  opportunityId: string;
  language: "en";
  channel: "email" | "message";
  subject: string | null;
  text: string;
  /**
   * @minItems 2
   * @maxItems 5
   */
  sentences: {
    text: string;
    kind:
      | "observation"
      | "capability"
      | "reference"
      | "cta"
      | "prior_interaction";
    /**
     * @minItems 1
     * @maxItems 1
     */
    sourceIds: string[];
  }[];
  selection: OutreachDraftingSelection;
  inputHash: string;
  contentHash: string;
  sourceRevisions: {
    [k: string]: number;
  };
  model: {
    modelId: string;
    promptVersion: string;
    playbookVersion: string;
    cacheHit: boolean;
    usage: {
      inputTokens: number;
      outputTokens: number;
      costMicros: number;
    };
  };
  reviewStatus: "pending_review";
  sendAuthority: false;
}
