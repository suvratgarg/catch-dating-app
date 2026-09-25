/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export type EventOfferAction =
  | {
      requestId: string;
      expectedRevision: number;
      kind: "createDraft";
      terms: {
        expiresAtMillis: number;
        organizerPaymentLink: string | null;
      };
    }
  | {
      requestId: string;
      expectedRevision: number;
      kind: "reissueDraft";
      expectedGeneration: number;
      terms: {
        expiresAtMillis: number;
        organizerPaymentLink: string | null;
      };
    }
  | {
      requestId: string;
      expectedRevision: number;
      kind: "offer";
      expectedGeneration: number;
    }
  | {
      requestId: string;
      expectedRevision: number;
      kind: "withdraw";
      expectedGeneration: number;
    }
  | {
      requestId: string;
      expectedRevision: number;
      kind: "expire";
      expectedGeneration: number;
    }
  | {
      requestId: string;
      expectedRevision: number;
      kind: "recordEvidence";
      expectedGeneration: number;
      evidenceReference: string;
    }
  | {
      requestId: string;
      expectedRevision: number;
      kind: "reconcileEvidence";
      expectedGeneration: number;
      decision: "hostAttestedReceived" | "rejected";
      reviewNote: string;
      bankReceiptChecked: boolean;
    };
