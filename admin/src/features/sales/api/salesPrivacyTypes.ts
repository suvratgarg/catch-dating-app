export interface PrivacyPolicySummary {
  revision: number;
  policyHash: string;
  sourceReference: string;
  reviewedAt: string;
  financeDisposition: "retain_pending_finance_review";
  auditDisposition: "retain_pending_audit_review";
  financeReason: string;
  auditReason: string;
}
export interface PrivacyBlocker {code: string; fingerprint: string}
export interface PrivacyPlanSummary {
  planId: string;
  organizerId: string;
  policyHash: string;
  inventoryHash: string;
  cursor: number;
  itemCount: number;
  retainedCount: number;
  unresolvedCount: number;
  blockers: PrivacyBlocker[];
  status: "reviewed" | "processing" | "internal_processed_with_unresolved";
}
export interface PrivacyCase {
  organizerId: string;
  restricted: boolean;
  restriction?: {status: "restricted" | "processing" |
    "internal_processed_with_unresolved"; revision: number;
    restrictedAt: string; reason: string};
  plan: PrivacyPlanSummary | null;
  policy: PrivacyPolicySummary | null;
  completeDeletion: false;
}
export interface PrivacyPreview {
  organizerId: string;
  restrictionRevision: number;
  activePlanId: string | null;
  policyHash: string;
  inventoryHash: string;
  counts: {deletable: number; retained: number; unresolved: number};
  blockers: PrivacyBlocker[];
  overflow: boolean;
  effectsApplied: false;
}
export interface PrivacyBatch {
  organizerId: string;
  planId: string;
  previousCursor: number;
  nextCursor: number;
  itemCount: number;
  deletedCount: number;
  retainedCount: number;
  unresolvedCount: number;
  status: "processing" | "internal_processed_with_unresolved";
  completeDeletion: false;
  receiptId: string;
}
export interface PrivacyApi {
  getCase(organizerId: string): Promise<PrivacyCase>;
  reviewPolicy(input: {requestId: string; expectedRevision: number;
    sourceReference: string; sourceHash: string; financeReason: string;
    auditReason: string}): Promise<{policy: PrivacyPolicySummary}>;
  restrict(input: {organizerId: string; requestId: string; reason: string}):
    Promise<{restriction: NonNullable<PrivacyCase["restriction"]>}>;
  preview(organizerId: string): Promise<PrivacyPreview>;
  reviewPlan(input: {organizerId: string; requestId: string;
    restrictionRevision: number; expectedActivePlanId: string | null;
    policyHash: string; inventoryHash: string}):
    Promise<{plan: PrivacyPlanSummary}>;
  applyBatch(input: {organizerId: string; planId: string; requestId: string;
    expectedCursor: number}): Promise<{batch: PrivacyBatch}>;
}
