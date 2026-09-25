/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export interface OrganizerEventOfferAuditDocument {
  offerId: string;
  requestId: string;
  actorUid: string;
  kind:
    | "createDraft"
    | "reissueDraft"
    | "offer"
    | "withdraw"
    | "expire"
    | "recordEvidence"
    | "reconcileEvidence";
  beforeRevision: number;
  afterRevision: number;
  generation: number;
  atMillis: number;
  paymentStatus:
    | "none"
    | "evidenceSubmitted"
    | "hostAttestedReceived"
    | "rejected";
  bankReceiptChecked: boolean;
  reviewNote: string | null;
}
