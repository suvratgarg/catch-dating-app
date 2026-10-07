import Ajv from "ajv";
import addFormats from "ajv-formats";
import {httpsCallable} from "firebase/functions";
import {functions} from "../../../shared/api/firebaseFunctions";
import listSchema from "../../../../../contracts/callable_responses/get_sales_partner_demo_reviews_response.schema.json";
import proposalSchema from "../../../../../contracts/callable_responses/propose_sales_partner_demo_wording_response.schema.json";
import inputSchema from "../../../../../contracts/callables/propose_sales_partner_demo_wording_payload.schema.json";
import type {PartnerDemoReviewRow, DemoReviewWording} from "../../../shared/domain/salesDemoReview";
export interface PartnerDemoReviews {
  organizerId: string; assignmentRevision: number; rows: PartnerDemoReviewRow[]; evaluatedAt: string;
  sendAuthority: false; capabilityApprovalAuthority: false; organizerControlAuthority: false;
}
export interface DemoWordingInput {requestId: string; organizerId: string; expectedAssignmentRevision: number;
  blueprintId: string; expectedPreviewHash: string; expectedProposalRevision: number; wording: DemoReviewWording}
export interface DemoWordingResult {organizerId: string; blueprintId: string; proposalRevision: number;
  sourcePreviewHash: string; state: "pending_owner_review"; sendAuthority: false;
  capabilityApprovalAuthority: false; organizerControlAuthority: false}
export interface PartnerDemoReviewApi {
  list(input: {organizerId: string; expectedAssignmentRevision: number}): Promise<PartnerDemoReviews>;
  propose(input: DemoWordingInput): Promise<DemoWordingResult>;
}
const ajv = new Ajv({strict: false}); addFormats(ajv);
const listValidator = ajv.compile<PartnerDemoReviews>(listSchema);
const proposalValidator = ajv.compile<DemoWordingResult>(proposalSchema);
const inputValidator = ajv.compile<DemoWordingInput>(inputSchema);
export function parsePartnerDemoReviews(value: unknown, scope: {organizerId: string; expectedAssignmentRevision: number}) {
  if (!listValidator(value) || value.organizerId !== scope.organizerId ||
      value.assignmentRevision !== scope.expectedAssignmentRevision ||
      new Set(value.rows.map((row) => row.blueprintId)).size !== value.rows.length ||
      value.rows.some((row) => row.organizerId !== value.organizerId || row.assignmentRevision !== value.assignmentRevision ||
        row.evaluatedAt !== value.evaluatedAt || Date.parse(row.validUntil) <= Date.parse(row.evaluatedAt))) {
    throw new Error("Private preview response is invalid. Refresh current access.");
  }
  return value;
}
export const partnerDemoReviewApi: PartnerDemoReviewApi = {
  list: async (input) => parsePartnerDemoReviews((await httpsCallable<unknown, unknown>(functions,
    "getSalesPartnerDemoReviews")(input)).data, input),
  propose: async (input) => {
    if (!inputValidator(input)) throw new Error("Preview wording request is invalid.");
    const value = (await httpsCallable<unknown, unknown>(functions, "proposeSalesPartnerDemoWording")(input)).data;
    if (!proposalValidator(value) || value.organizerId !== input.organizerId || value.blueprintId !== input.blueprintId ||
        value.sourcePreviewHash !== input.expectedPreviewHash || value.proposalRevision !== input.expectedProposalRevision + 1) {
      throw new Error("Preview proposal response is invalid. Recover the unchanged request.");
    }
    return value;
  },
};
