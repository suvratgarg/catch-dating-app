/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Private timeline. Manual outbound is actor-attested only; claim transitions originate only from canonical server workflows.
 */
export type SalesActivityDocument = {
  [k: string]: unknown;
} & {
  schemaVersion: 1;
  classification: "sales_private";
  activityId: string;
  organizerId: string;
  opportunityId: string | null;
  type:
    | "note"
    | "reply"
    | "call"
    | "demo"
    | "pilot"
    | "correction"
    | "outreach_sent_manual"
    | "claim_requested"
    | "claim_approved"
    | "claim_rejected";
  channel: ("email" | "whatsapp" | "other") | null;
  outcome: "actor_attested_sent" | null;
  providerConfirmed: false;
  occurredAt: string;
  recordedAt: string;
  note: string;
  actorUid: string;
  source?: {
    kind: "organizer_claim";
    claimRequestId: string;
    transitionId: string;
  };
};
