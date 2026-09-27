import Ajv, {type ValidateFunction} from "ajv";
import addFormats from "ajv-formats";
import {HttpsError} from "firebase-functions/v2/https";
import type {CommercialAction, CommercialRead} from "./types";

type Schema = Record<string, unknown>;
const id: Schema = {
  type: "string",
  minLength: 1,
  maxLength: 96,
  pattern: "^[A-Za-z0-9][A-Za-z0-9._:-]*$",
};
const revision: Schema = {
  type: "integer",
  minimum: 0,
  maximum: 1_000_000_000,
};
const dateTime: Schema = {type: "string", format: "date-time"};
const evidence: Schema = object(["evidenceId"], {evidenceId: id});

function object(
  required: string[],
  properties: Record<string, unknown>,
): Schema {
  return {type: "object", additionalProperties: false, required, properties};
}

const common = {
  organizerId: id,
  opportunityId: id,
  requestId: {...id, minLength: 8},
  expectedRevision: revision,
};
export const COMMERCIAL_ACTION_SCHEMAS: Record<CommercialAction, Schema> = {
  "commercial.pilots.upsert": object(
    ["organizerId", "opportunityId", "requestId", "expectedRevision", "plan"],
    {
      ...common,
      plan: object(
        [
          "status",
          "workflowId",
          "objective",
          "successMeasures",
          "startsAt",
          "endsAt",
          "reviewEvidence",
          "outcomeEvidence",
        ],
        {
          status: {
            enum: ["draft", "reviewed", "active", "completed", "cancelled"],
          },
          workflowId: id,
          objective: {type: "string", minLength: 1, maxLength: 1000},
          successMeasures: {
            type: "array",
            minItems: 1,
            maxItems: 8,
            items: {type: "string", minLength: 1, maxLength: 240},
          },
          startsAt: {anyOf: [dateTime, {type: "null"}]},
          endsAt: {anyOf: [dateTime, {type: "null"}]},
          reviewEvidence: {anyOf: [evidence, {type: "null"}]},
          outcomeEvidence: {anyOf: [evidence, {type: "null"}]},
        },
      ),
    },
  ),
  "commercial.quotes.revise": object(
    ["organizerId", "opportunityId", "requestId", "expectedRevision", "terms"],
    {
      ...common,
      terms: object(
        [
          "currency",
          "amountMinor",
          "billingCadence",
          "scope",
          "validUntil",
          "sourceFactRefs",
        ],
        {
          currency: {type: "string", pattern: "^[A-Z]{3}$"},
          amountMinor: {
            type: "integer",
            minimum: 0,
            maximum: 1_000_000_000_000,
          },
          billingCadence: {
            enum: ["one_time", "monthly", "annual", "usage_based"],
          },
          scope: {type: "string", minLength: 1, maxLength: 2000},
          validUntil: dateTime,
          sourceFactRefs: {
            type: "array",
            minItems: 1,
            maxItems: 20,
            uniqueItems: true,
            items: id,
          },
        },
      ),
    },
  ),
  "commercial.quotes.approve": quoteDecisionSchema(),
  "commercial.quotes.accept": quoteDecisionSchema(),
};

function quoteDecisionSchema(): Schema {
  return object(
    [
      "organizerId",
      "opportunityId",
      "requestId",
      "expectedRevision",
      "termVersion",
      "evidence",
    ],
    {
      ...common,
      termVersion: {type: "integer", minimum: 1, maximum: 1_000_000_000},
      evidence,
    },
  );
}

export const COMMERCIAL_READ_SCHEMAS: Record<CommercialRead, Schema> = {
  "commercial.detail": object(["organizerId", "opportunityId"], {
    organizerId: id,
    opportunityId: id,
  }),
  "commercial.report": object(["organizerId"], {
    organizerId: id,
    limit: {type: "integer", minimum: 1, maximum: 25},
    cursor: {type: "string", minLength: 1, maxLength: 512},
  }),
};

const ajv = new Ajv({allErrors: true, strict: true});
addFormats(ajv);
const actions = Object.fromEntries(
  Object.entries(COMMERCIAL_ACTION_SCHEMAS).map(([name, schema]) => [
    name,
    ajv.compile(schema),
  ]),
) as Record<CommercialAction, ValidateFunction>;
const reads = Object.fromEntries(
  Object.entries(COMMERCIAL_READ_SCHEMAS).map(([name, schema]) => [
    name,
    ajv.compile(schema),
  ]),
) as Record<CommercialRead, ValidateFunction>;

export function validateCommercialAction(
  action: CommercialAction,
  payload: unknown,
): void {
  if (!actions[action](payload)) {
    throw new HttpsError(
      "invalid-argument",
      "Invalid Sales commercial action input.",
    );
  }
}

export function validateCommercialRead(
  action: CommercialRead,
  payload: unknown,
): void {
  if (!reads[action](payload)) {
    throw new HttpsError(
      "invalid-argument",
      "Invalid Sales commercial read input.",
    );
  }
}
