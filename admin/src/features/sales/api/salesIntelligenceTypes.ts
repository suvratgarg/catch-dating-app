import type {SalesAccountDetail, SalesContact, SalesEvidence,
  SalesPage} from "./salesTypes";

export type EvidenceClaim = "identity" | "recurrence" | "operation" |
  "stack" | "other";
export interface IntelligenceFactor {
  id: string; weight: number; claimKeys: EvidenceClaim[]; maxAgeDays: number;
}
export interface IntelligencePolicy {
  policyId: string; version: string; revision: number;
  status: "active" | "paused"; factors: IntelligenceFactor[];
  priorityBands: {high: number; medium: number};
  promptVersion: string; playbookVersion: string;
}
export interface FactorAssessment {
  assessmentId: string; organizerId: string; factorId: string;
  revision: number; state: "known" | "unknown" | "disputed";
  value: number | null; evidenceIds: string[]; reason: string | null;
  reviewedAt: string; reviewerUid: string;
}
export interface ApprovedClause {
  clauseId: string; organizerId: string; revision: number;
  kind: "observation" | "capability" | "reference" | "cta";
  text: string; state: "draft" | "approved" | "withdrawn";
  evidenceIds: string[]; validUntil: string;
  permission: "not_required" | "private_mention" | "withdrawn";
  reviewedAt: string | null;
}
export interface IntelligenceCatalog {
  policy: IntelligencePolicy | null;
  assessments: FactorAssessment[];
  clauses: ApprovedClause[];
  evaluatedAt: string;
}
export interface ScoreSnapshot {
  status: "complete" | "needs_research" | "review_required";
  score: number | null; priority: "high" | "medium" | "low" | "unranked";
  policyVersion: string; evaluatedAt: string;
  factors: Array<{factorId: string; state: FactorAssessment["state"];
    value: number | null; evidenceIds: string[]; reason: string | null}>;
}
export interface DraftSourceRequest {
  organizerId: string; contactId: string; opportunityId: string;
  observationIds: string[]; capabilityIds: string[];
  referenceIds: string[]; ctaIds: string[];
  channel: "email" | "message";
  purpose: "first_message" | "follow_up";
  priorActivityId?: string;
}
export interface DraftSummary {
  draftId: string; contactId: string; opportunityId: string;
  subject: string | null; status: "pending_review" | "approved";
  contentHash: string; createdAt: string; reviewedAt: string | null;
}
export interface DraftArtifact {
  draftId: string; subject: string | null; text: string;
  contentHash: string; sendAuthority: false;
  model: {modelId: "deterministic"; usage: {inputTokens: 0;
    outputTokens: 0; costMicros: 0}};
  sentences: Array<{text: string; kind: string; sourceIds: string[]}>;
}
export interface DraftDetail {
  draftId: string; draft: DraftArtifact;
  status: DraftSummary["status"];
  reviewedAt: string | null; reviewedBy: string | null;
  sendAuthority: false;
}
export interface DraftJob {
  status: "running" | "completed" | "failed";
  result: {draftId: string; contentHash: string} | null;
  failure: string | null; retryAfterSeconds: number | null;
}
export interface MutationResult {
  draftId: string; exactContentHash: string; sendAuthority: false;
  providerConfirmed: false;
}
export interface IntelligenceApi {
  catalog(organizerId: string): Promise<IntelligenceCatalog>;
  score(organizerId: string): Promise<{snapshot: ScoreSnapshot}>;
  account(organizerId: string): Promise<SalesAccountDetail>;
  contacts(organizerId: string, cursor?: string): Promise<SalesPage<SalesContact>>;
  evidence(organizerId: string, cursor?: string): Promise<SalesPage<SalesEvidence>>;
  drafts(organizerId: string): Promise<{rows: DraftSummary[]}>;
  draft(draftId: string): Promise<DraftDetail>;
  job(requestId: string): Promise<DraftJob>;
  assess(input: {requestId: string; organizerId: string; factorId: string;
    expectedRevision: number; state: FactorAssessment["state"];
    value: number | null; evidenceIds: string[]; reason: string | null}):
    Promise<{assessment: FactorAssessment}>;
  savePolicy(input: {requestId: string; expectedRevision: number;
    policy: Omit<IntelligencePolicy, "revision">}):
    Promise<{policy: IntelligencePolicy}>;
  saveClause(input: {requestId: string; clauseId: string; organizerId: string;
    expectedRevision: number; kind: ApprovedClause["kind"]; text: string;
    evidenceIds: string[]; validUntil: string;
    permission: ApprovedClause["permission"]}):
    Promise<{clause: ApprovedClause}>;
  reviewClause(input: {requestId: string; clauseId: string;
    expectedRevision: number; decision: "approve" | "withdraw"}):
    Promise<{clause: ApprovedClause}>;
  generate(input: {requestId: string; sourceRequest: DraftSourceRequest}):
    Promise<{status: "running" | "completed" | "failed";
      result?: {draftId: string; contentHash: string} | null;
      retryAfterSeconds?: number; idempotentReplay?: boolean; failure?: string}>;
  review(input: {requestId: string; draftId: string;
    expectedContentHash: string; factualValidity: "verified";
    tone: "approved"; channelReadiness: "manual_copy_only"}):
    Promise<MutationResult>;
  copy(input: {requestId: string; draftId: string;
    expectedContentHash: string}):
    Promise<MutationResult & {subject: string | null; text: string;
      copiedAt: string}>;
}
