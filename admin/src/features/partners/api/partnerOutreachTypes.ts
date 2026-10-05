import type {DraftArtifact, DraftSourceRequest, DraftJob} from "../../../shared/domain/salesOutreach";

export interface PartnerPreparation {
  organizerId: string; assignmentRevision: number;
  researchStatus: "new" | "needs_research" | "ready_for_review" | "qualified" |
    "benchmark_only" | "no_fit" | "archived";
  contacts: Array<{contactId: string; displayName: string; role: string}>;
  opportunities: Array<{opportunityId: string; stage: string; motion: string}>;
  clauses: Array<{clauseId: string; kind: "observation" | "capability" | "reference" | "cta";
    text: string; revision: number; validUntil: string;
    evidence: Array<{evidenceId: string; sourceRef: string; observedAt: string;
      validThrough: string | null; excerpt: string | null; confidence: "high" | "medium" | "low"}>}>;
  evaluatedAt: string; sendAuthority: false; capabilityApprovalAuthority: false;
}
export interface PartnerOutreachScope {
  organizerId: string; expectedAssignmentRevision: number;
}
export interface PartnerDraft {
  draftId: string;
  draft: DraftArtifact & {organizerId: string; contactId: string;
    opportunityId: string; channel: "email" | "message"};
  status: "pending_review" | "approved"; reviewedAt: string | null;
  sendAuthority: false;
}
export type PartnerGeneration = {status: "completed";
  result: {draftId: string; contentHash: string}; idempotentReplay: boolean} |
  {status: "running"; retryAfterSeconds: number} | {status: "failed"; failure: string | null};
export interface PartnerReview {
  draftId: string; exactContentHash: string; compositionReviewed: true;
  capabilityApprovalAuthority: false; sendAuthority: false; providerConfirmed: false;
}
export interface PartnerCopy {
  draftId: string; subject: string | null; text: string; exactContentHash: string;
  copiedAt: string; sendAuthority: false; providerConfirmed: false;
}
export interface PartnerManualSend {
  organizerId: string; draftId: string; activityId: string; exactContentHash: string;
  occurredAt: string; outcome: "actor_attested_sent"; providerConfirmed: false; sendAuthority: false;
}
export interface PartnerOutreachApi {
  preparation(scope: PartnerOutreachScope): Promise<PartnerPreparation>;
  generate(input: {requestId: string; expectedAssignmentRevision: number;
    sourceRequest: DraftSourceRequest}): Promise<PartnerGeneration>;
  job(input: PartnerOutreachScope & {requestId: string}): Promise<DraftJob>;
  draft(input: PartnerOutreachScope & {draftId: string}): Promise<PartnerDraft>;
  review(input: PartnerOutreachScope & {requestId: string; draftId: string;
    expectedContentHash: string; factualValidity: "verified"; tone: "approved";
    channelReadiness: "manual_copy_only"}): Promise<PartnerReview>;
  copy(input: PartnerOutreachScope & {requestId: string; draftId: string;
    expectedContentHash: string}): Promise<PartnerCopy>;
  record(input: PartnerOutreachScope & {requestId: string; draftId: string;
    expectedContentHash: string; channel: "email" | "whatsapp" | "other";
    occurredAt: string; attestation: "i_manually_sent_this_reviewed_draft"}): Promise<PartnerManualSend>;
}
