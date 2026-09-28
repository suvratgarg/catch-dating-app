/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

import type {OutreachDraft} from "./outreachDraft";

/**
 * Private Operations-rendered manual-copy-only draft with frozen source request and exact source hash.
 */
export interface SalesOutreachDraftsDocument {
  schemaVersion: 1;
  classification: "sales_private";
  draftId: string;
  organizerId: string;
  contactId: string;
  opportunityId: string;
  sourceRequest: {
    organizerId: string;
    contactId: string;
    opportunityId: string;
    /**
     * @maxItems 12
     */
    observationIds: string[];
    /**
     * @maxItems 12
     */
    capabilityIds: string[];
    /**
     * @maxItems 12
     */
    referenceIds: string[];
    /**
     * @maxItems 12
     */
    ctaIds: string[];
    channel: "email" | "message";
    purpose: "first_message" | "follow_up";
    priorActivityId?: string;
  };
  sourceMaterialHash: string;
  sourceHash: string;
  inputHash: string;
  draft: OutreachDraft;
  status: "pending_review" | "approved";
  createdAt: string;
  createdBy: string;
  reviewedAt: string | null;
  reviewedBy: string | null;
}
