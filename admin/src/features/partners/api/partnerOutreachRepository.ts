import {httpsCallable} from "firebase/functions";
import {functions} from "../../../shared/api/firebaseFunctions";
import {parsePartnerOutreachResponse} from "./partnerOutreachResponse";
import type {PartnerOutreachApi, PartnerPreparation, PartnerDraft, PartnerReview,
  PartnerCopy, PartnerManualSend} from "./partnerOutreachTypes";
import type {DraftJob} from "../../../shared/domain/salesOutreach";
async function call<T>(kind: Parameters<typeof parsePartnerOutreachResponse>[0], name: string, payload: unknown,
  matches: (value: T) => boolean = () => true): Promise<T> {
  const response = await httpsCallable<unknown, unknown>(functions, name)(payload);
  const value = parsePartnerOutreachResponse(kind, response.data) as T;
  if (!matches(value)) throw new Error("Partner outreach scope changed. Refresh before continuing.");
  return value;
}
export const partnerOutreachApi: PartnerOutreachApi = {
  preparation: (input) => call<PartnerPreparation>("preparation", "getSalesPartnerPreparation", input,
    (v) => v.organizerId === input.organizerId && v.assignmentRevision === input.expectedAssignmentRevision &&
      new Set(v.contacts.map((c) => c.contactId)).size === v.contacts.length &&
      new Set(v.opportunities.map((o) => o.opportunityId)).size === v.opportunities.length &&
      new Set(v.clauses.map((c) => c.clauseId)).size === v.clauses.length),
  generate: (input) => call("generate", "generateSalesPartnerOutreach", input),
  job: (input) => call<DraftJob>("job", "getSalesPartnerOutreachJob", input,
    (v) => v.status === "completed" ? v.result !== null && v.retryAfterSeconds === null && v.failure === null :
      v.result === null && (v.status !== "running" || v.retryAfterSeconds !== null)),
  draft: (input) => call<PartnerDraft>("draft", "getSalesPartnerOutreachDraft", input,
    (v) => v.draftId === input.draftId && v.draft.draftId === input.draftId &&
      v.draft.organizerId === input.organizerId && v.draft.text.length <= 2500 &&
      v.draft.model.modelId === "deterministic" && v.draft.model.usage.inputTokens === 0 &&
      v.draft.model.usage.outputTokens === 0 && v.draft.model.usage.costMicros === 0 &&
      (v.status === "approved" ? v.reviewedAt !== null : v.reviewedAt === null)),
  review: (input) => call<PartnerReview>("review", "reviewSalesPartnerOutreachDraft", input,
    (v) => v.draftId === input.draftId && v.exactContentHash === input.expectedContentHash),
  copy: (input) => call<PartnerCopy>("copy", "copySalesPartnerOutreachDraft", input,
    (v) => v.draftId === input.draftId && v.exactContentHash === input.expectedContentHash),
  record: (input) => call<PartnerManualSend>("record", "recordSalesPartnerManualSend", input,
    (v) => v.organizerId === input.organizerId && v.draftId === input.draftId &&
      v.exactContentHash === input.expectedContentHash && v.occurredAt === input.occurredAt),
};
