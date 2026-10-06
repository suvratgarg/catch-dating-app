/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export interface EditSalesPartnerOutreachDraftCallablePayload {
  requestId: string;
  organizerId: string;
  expectedAssignmentRevision: number;
  draftId: string;
  expectedContentHash: string;
  expectedCompositionRevision: number;
  style: {
    greeting: "none" | "hello" | "hi";
    closing: "none" | "thanks" | "best";
    subjectStyle: "original" | "question" | "idea";
    paragraphStyle: "spaced" | "compact";
  };
}
