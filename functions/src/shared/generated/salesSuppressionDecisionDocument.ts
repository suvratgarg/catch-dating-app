/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Append-only human decision. Contact draft review never means send permission.
 */
export type SalesSuppressionDecisionDocument = {
  [k: string]: unknown;
} & {
  schemaVersion: 1;
  classification: "sales_private";
  decisionId: string;
  targetType: "account" | "contact_relationship";
  organizerId: string;
  contactId: string | null;
  previousStatus:
    | "clear"
    | "unknown"
    | "draft_reviewed"
    | "held"
    | "suppressed";
  status: "clear" | "unknown" | "draft_reviewed" | "held" | "suppressed";
  reason: string;
  actorUid: string;
  recordedAt: string;
  accountRevision?: number;
  relationshipRevision?: number;
  evidenceId?: string | null;
  sendAuthority?: false;
};
