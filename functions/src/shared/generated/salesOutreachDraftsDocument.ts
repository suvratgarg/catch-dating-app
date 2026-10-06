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
  participantScope?: {
    partnerUid: string;
    assignmentRevision: number;
    renderedDraftId: string;
  };
  /**
   * Own-partner neutral style edit, bound to an immutable intelligence receipt; never replaces sourced factual prose.
   */
  composition?: {
    schemaVersion: 1;
    revision: number;
    previousRevision: number;
    baseContentHash: string;
    previousContentHash: string;
    contentHash: string;
    editRequestId: string;
    editedAt: string;
    editedBy: string;
    style: {
      greeting: "none" | "hello" | "hi";
      closing: "none" | "thanks" | "best";
      subjectStyle: "original" | "question" | "idea";
      paragraphStyle: "spaced" | "compact";
    };
  };
}
