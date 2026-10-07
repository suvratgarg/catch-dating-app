import Ajv from "ajv";
import addFormats from "ajv-formats";
import schema from "../../../../../contracts/callable_responses/get_sales_partner_workspace_response.schema.json";
import type {PartnerWorkspace} from "./partnerRepository";

const ajv = new Ajv({allErrors: false, strict: false});
addFormats(ajv);
const validate = ajv.compile<PartnerWorkspace>(schema);

/** Validate before React Query can retain any private workspace material. */
export function parsePartnerWorkspace(value: unknown): PartnerWorkspace {
  if (!validate(value) || value.leads.some((lead) =>
    lead.assignment.organizerId !== lead.organizer.organizerId) ||
    new Set(value.leads.map((lead) => lead.organizer.organizerId)).size !== value.leads.length) {
    throw new Error("Partner workspace response is invalid. Refresh before continuing.");
  }
  return value;
}
