export type CommercialEvidence = {evidenceId: string; sourceRef: string;
  contentHash: string; observedAt: string};
export type CommercialStatus = "draft" | "reviewed" | "active" | "completed" |
  "cancelled";
export interface CommercialPilot {
  organizerId: string; opportunityId: string; revision: number;
  status: CommercialStatus; workflowId: string; objective: string;
  successMeasures: string[]; startsAt: string | null; endsAt: string | null;
  reviewEvidence: CommercialEvidence | null;
  outcomeEvidence: CommercialEvidence | null;
}
export interface CommercialTerms {
  currency: string; amountMinor: number;
  billingCadence: "one_time" | "monthly" | "annual" | "usage_based";
  scope: string; validUntil: string; sourceFactRefs: string[];
}
export interface CommercialQuote {
  organizerId: string; opportunityId: string; quoteId: string;
  revision: number; termVersion: number;
  status: "draft" | "approved" | "accepted_reviewed";
  approvedDecisionId: string | null; acceptedDecisionId: string | null;
}
export interface CommercialSettlementAttestation {
  attestationId: string; organizerId: string; opportunityId: string;
  quoteId: string; termVersion: number; termsHash: string;
  amountMinor: number; currency: string; purpose: "host_subscription";
  receivedAt: string;
  settlementMethod: "bank_transfer" | "cash" | "other_external";
  servicePeriod: {startsAt: string; endsAt: string} | null;
  evidence: CommercialEvidence;
  status: "manual_attested_collected"; providerConfirmed: false;
  actorUid: string; attestedAt: string;
}
export interface CommercialDetail {
  opportunity: {opportunityId: string; organizerId: string; stage: string;
    revision: number; motion: string; ownerUid: string;
    nextStep: string | null; nextStepAt: string | null};
  pilotPlan: CommercialPilot | null;
  quote: CommercialQuote | null;
  quoteVersion: {termVersion: number; terms: CommercialTerms;
    termsHash: string} | null;
  approvedDecision: {decisionId: string; evidence: CommercialEvidence} | null;
  acceptedDecision: {decisionId: string; evidence: CommercialEvidence} | null;
  settlementAttestation: CommercialSettlementAttestation | null;
  history: Array<{fromStage: string | null; toStage: string;
    reason: string | null; changedAt: string}>;
  historyTruncated: boolean;
  paymentStatus: "unknown" | "manual_attested";
  bookedHostRevenueMinor: null;
}
export interface CommercialReportRow {
  opportunityId: string; stage: string; ownerUid: string;
  pilotStatus: CommercialStatus | null; pilotRevision: number | null;
  quoteStatus: CommercialQuote["status"] | null;
  quoteRevision: number | null; termVersion: number | null;
  paymentStatus: "unknown" | "manual_attested";
  manuallyAttestedHostRevenue: {amountMinor: number; currency: string;
    providerConfirmed: false; purpose: "host_subscription"} | null;
  bookedHostRevenueMinor: null;
}
export interface CommercialReport {rows: CommercialReportRow[];
  nextCursor: string | null; pageScope: true}
export type CommercialPilotInput = {
  organizerId: string; opportunityId: string; requestId: string;
  expectedRevision: number;
  plan: {status: CommercialStatus; workflowId: string; objective: string;
    successMeasures: string[]; startsAt: string | null; endsAt: string | null;
    reviewEvidence: {evidenceId: string} | null;
    outcomeEvidence: {evidenceId: string} | null};
};
export type CommercialQuoteInput = {
  organizerId: string; opportunityId: string; requestId: string;
  expectedRevision: number; terms: CommercialTerms;
};
export type CommercialDecisionInput = {
  organizerId: string; opportunityId: string; requestId: string;
  expectedRevision: number; termVersion: number;
  evidence: {evidenceId: string};
};
export type CommercialSettlementInput = {
  organizerId: string; opportunityId: string; requestId: string;
  expectedQuoteRevision: number; termVersion: number;
  amountMinor: number; currency: string; purpose: "host_subscription";
  receivedAt: string;
  settlementMethod: CommercialSettlementAttestation["settlementMethod"];
  servicePeriod: CommercialSettlementAttestation["servicePeriod"];
  evidence: {evidenceId: string};
};
export type CommercialCloseInput = {
  organizerId: string; opportunityId: string; requestId: string;
  expectedRevision: number; financeAttestationId: string;
  fields: {motion: string; stage: "closed_won"; ownerUid: string;
    nextStep: null; nextStepAt: null};
};
