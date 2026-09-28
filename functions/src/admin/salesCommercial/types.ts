export type CommercialAction =
  | "commercial.pilots.upsert"
  | "commercial.quotes.revise"
  | "commercial.quotes.approve"
  | "commercial.quotes.accept"
  | "commercial.finance.attest";
export type CommercialRead = "commercial.report" | "commercial.detail";

export interface EvidenceReference {
  evidenceId: string;
  sourceRef: string;
  contentHash: string;
  observedAt: string;
}

export interface EvidenceSelection {
  evidenceId: string;
}

export interface PilotPlanInput {
  organizerId: string;
  opportunityId: string;
  requestId: string;
  expectedRevision: number;
  plan: {
    status: "draft" | "reviewed" | "active" | "completed" | "cancelled";
    workflowId: string;
    objective: string;
    successMeasures: string[];
    startsAt: string | null;
    endsAt: string | null;
    reviewEvidence: EvidenceSelection | null;
    outcomeEvidence: EvidenceSelection | null;
  };
}

export interface QuoteTerms {
  currency: string;
  amountMinor: number;
  billingCadence: "one_time" | "monthly" | "annual" | "usage_based";
  scope: string;
  validUntil: string;
  sourceFactRefs: string[];
}

export interface QuoteReviseInput {
  organizerId: string;
  opportunityId: string;
  requestId: string;
  expectedRevision: number;
  terms: QuoteTerms;
}

export interface QuoteDecisionInput {
  organizerId: string;
  opportunityId: string;
  requestId: string;
  expectedRevision: number;
  termVersion: number;
  evidence: EvidenceSelection;
}

export interface HostSettlementAttestationInput {
  organizerId: string;
  opportunityId: string;
  requestId: string;
  expectedQuoteRevision: number;
  termVersion: number;
  amountMinor: number;
  currency: string;
  purpose: "host_subscription";
  receivedAt: string;
  settlementMethod: "bank_transfer" | "cash" | "other_external";
  settlementReference: string;
  recipientAccountScope: string;
  servicePeriod: {startsAt: string; endsAt: string} | null;
  evidence: EvidenceSelection;
}

export type CommercialPayload =
  | PilotPlanInput
  | QuoteReviseInput
  | QuoteDecisionInput
  | HostSettlementAttestationInput;

export interface HostSettlementAttestation {
  schemaVersion: 1;
  classification: "sales_private";
  revision: 1;
  attestationId: string;
  organizerId: string;
  opportunityId: string;
  quoteId: string;
  termVersion: number;
  termsHash: string;
  amountMinor: number;
  currency: string;
  purpose: "host_subscription";
  receivedAt: string;
  settlementMethod: HostSettlementAttestationInput["settlementMethod"];
  settlementReference: string;
  recipientAccountScope: string;
  settlementIdentityHash: string;
  servicePeriod: HostSettlementAttestationInput["servicePeriod"];
  evidence: EvidenceReference;
  status: "manual_attested_collected";
  providerConfirmed: false;
  actorUid: string;
  attestedAt: string;
}

export interface PilotPlan {
  schemaVersion: 1;
  classification: "sales_private";
  organizerId: string;
  opportunityId: string;
  revision: number;
  status: PilotPlanInput["plan"]["status"];
  workflowId: string;
  objective: string;
  successMeasures: string[];
  startsAt: string | null;
  endsAt: string | null;
  reviewEvidence: EvidenceReference | null;
  outcomeEvidence: EvidenceReference | null;
  updatedAt: string;
  updatedBy: string;
}

export interface QuoteHead {
  schemaVersion: 1;
  classification: "sales_private";
  organizerId: string;
  opportunityId: string;
  quoteId: string;
  revision: number;
  termVersion: number;
  status: "draft" | "approved" | "accepted_reviewed";
  approvedDecisionId: string | null;
  acceptedDecisionId: string | null;
  updatedAt: string;
  updatedBy: string;
}

export interface QuoteVersion {
  schemaVersion: 1;
  classification: "sales_private";
  organizerId: string;
  opportunityId: string;
  quoteId: string;
  termVersion: number;
  terms: QuoteTerms;
  termsHash: string;
  createdAt: string;
  createdBy: string;
}

export interface CommercialDecision {
  schemaVersion: 1;
  classification: "sales_private";
  decisionId: string;
  organizerId: string;
  opportunityId: string;
  quoteId: string | null;
  termVersion: number | null;
  termsHash: string;
  kind: "quote_approved" | "terms_acceptance_reviewed";
  evidence: EvidenceReference;
  approvedDecisionId: string | null;
  actorUid: string;
  decidedAt: string;
  paymentStatus: "unknown";
}

export interface OpportunityStageHistory {
  schemaVersion: 1;
  classification: "sales_private";
  historyId: string;
  organizerId: string;
  opportunityId: string;
  fromStage: string | null;
  toStage: string;
  reason: string | null;
  actorUid: string;
  changedAt: string;
}
