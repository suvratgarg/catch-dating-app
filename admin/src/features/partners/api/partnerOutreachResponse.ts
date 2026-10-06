import Ajv from "ajv";
import addFormats from "ajv-formats";
import preparationSchema from "../../../../../contracts/callable_responses/get_sales_partner_preparation_response.schema.json";
import draftSchema from "../../../../../contracts/callable_responses/get_sales_partner_outreach_draft_response.schema.json";
import reviewSchema from "../../../../../contracts/callable_responses/review_sales_partner_outreach_draft_response.schema.json";
import manualSchema from "../../../../../contracts/callable_responses/record_sales_partner_manual_send_response.schema.json";
import generateSchema from "../../../../../contracts/callable_responses/admin_sales_outreach_generate_response.schema.json";
import jobSchema from "../../../../../contracts/callable_responses/admin_sales_outreach_job_response.schema.json";
import copySchema from "../../../../../contracts/callable_responses/admin_sales_outreach_copy_response.schema.json";
import artifactSchema from "../../../../../contracts/operations/outreach_drafting_draft.schema.json";
import selectionSchema from "../../../../../contracts/operations/outreach_drafting_selection.schema.json";
import type {PartnerPreparation, PartnerDraft, PartnerGeneration,
  PartnerReview, PartnerCopy, PartnerManualSend} from "./partnerOutreachTypes";
import type {DraftJob} from "../../../shared/domain/salesOutreach";

const ajv = new Ajv({allErrors: false, strict: false});
addFormats(ajv);
ajv.addSchema(selectionSchema); ajv.addSchema(artifactSchema); ajv.addSchema(jobSchema);
const validators = {
  preparation: ajv.compile<PartnerPreparation>(preparationSchema),
  draft: ajv.compile<PartnerDraft>(draftSchema),
  review: ajv.compile<PartnerReview>(reviewSchema),
  record: ajv.compile<PartnerManualSend>(manualSchema),
  generate: ajv.compile<PartnerGeneration>(generateSchema),
  job: ajv.getSchema<DraftJob>(jobSchema.$id)!,
  copy: ajv.compile<PartnerCopy>(copySchema),
};

/** Strict private responses are checked before any query or mutation can retain them. */
export function parsePartnerOutreachResponse(kind: keyof typeof validators,
  value: unknown): unknown {
  if (!validators[kind](value)) throw new Error("Partner outreach response is invalid. Refresh current access.");
  if (kind === "preparation") {
    const preparation = value as PartnerPreparation;
    for (const source of preparation.clauses.flatMap((clause) => clause.evidence)) {
      const url = new URL(source.sourceRef);
      if (url.protocol !== "https:" || url.username || url.password || url.search || url.hash ||
          !url.hostname.includes(".") || /\.(?:local|localhost)$/u.test(url.hostname)) {
        throw new Error("Partner source response is invalid. Refresh current access.");
      }
    }
  }
  return value;
}
