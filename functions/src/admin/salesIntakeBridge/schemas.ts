import Ajv from "ajv";
import {HttpsError} from "firebase-functions/v2/https";
import type {LinkIntakeToSalesInput} from "./service";

export const LINK_INTAKE_TO_SALES_SCHEMA = {
  type: "object", additionalProperties: false,
  required: ["workItemId", "candidateId", "expectedWorkItemRevision",
    "expectedCandidateHash", "organizerId", "curationPath", "requestId"],
  properties: {
    workItemId: {type: "string", minLength: 1, maxLength: 180,
      pattern: "^[A-Za-z0-9][A-Za-z0-9._:-]*$"},
    candidateId: {type: "string", minLength: 1, maxLength: 240},
    expectedWorkItemRevision: {type: "integer", minimum: 0},
    expectedCandidateHash: {type: "string", pattern: "^[a-f0-9]{64}$"},
    organizerId: {type: "string", minLength: 1, maxLength: 96,
      pattern: "^[A-Za-z0-9][A-Za-z0-9._:-]*$"},
    curationPath: {type: "string", minLength: 34, maxLength: 270,
      pattern: "^organizerIntakeCurationDecisions/" +
        "[A-Za-z0-9][A-Za-z0-9._:-]*$"},
    requestId: {type: "string", minLength: 8, maxLength: 96,
      pattern: "^[A-Za-z0-9][A-Za-z0-9._:-]*$"},
  },
} as const;

const validate = new Ajv({strict: true, allErrors: true})
  .compile(LINK_INTAKE_TO_SALES_SCHEMA);

export function parseLinkIntakeToSalesInput(value: unknown):
  LinkIntakeToSalesInput {
  if (!validate(value)) {
    throw new HttpsError("invalid-argument",
      "Invalid Intake-to-Sales identity link request.");
  }
  return value as LinkIntakeToSalesInput;
}
