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
export interface CommercialDetail {
  opportunity: {opportunityId: string; organizerId: string; stage: string};
  pilotPlan: CommercialPilot | null;
  quote: CommercialQuote | null;
  quoteVersion: {termVersion: number; terms: CommercialTerms;
    termsHash: string} | null;
  approvedDecision: {decisionId: string; evidence: CommercialEvidence} | null;
  acceptedDecision: {decisionId: string; evidence: CommercialEvidence} | null;
  history: Array<{fromStage: string | null; toStage: string;
    reason: string | null; changedAt: string}>;
  historyTruncated: boolean;
  paymentStatus: "unknown";
  bookedHostRevenueMinor: null;
}
export interface CommercialReportRow {
  opportunityId: string; stage: string; ownerUid: string;
  pilotStatus: CommercialStatus | null; pilotRevision: number | null;
  quoteStatus: CommercialQuote["status"] | null;
  quoteRevision: number | null; termVersion: number | null;
  paymentStatus: "unknown"; bookedHostRevenueMinor: null;
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
