/** Source-bound Sales outreach DTOs shared by employee and referral workspaces. */
export interface DraftSourceRequest {
  organizerId: string; contactId: string; opportunityId: string;
  observationIds: string[]; capabilityIds: string[];
  referenceIds: string[]; ctaIds: string[];
  channel: "email" | "message"; purpose: "first_message" | "follow_up";
  priorActivityId?: string;
}
export interface DraftArtifact {
  draftId: string; subject: string | null; text: string;
  contentHash: string; sendAuthority: false;
  model: {modelId: "deterministic"; usage: {inputTokens: 0; outputTokens: 0; costMicros: 0}};
  sentences: Array<{text: string; kind: string; sourceIds: string[]}>;
}
export interface DraftJob {
  status: "running" | "completed" | "failed";
  result: {draftId: string; contentHash: string} | null;
  failure: string | null; retryAfterSeconds: number | null;
}
