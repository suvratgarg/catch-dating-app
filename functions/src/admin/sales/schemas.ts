import Ajv, {type ValidateFunction} from "ajv";
import addFormats from "ajv-formats";
import {HttpsError} from "firebase-functions/v2/https";
import type {SalesMutationAction, SalesReadAction} from "./types";

type Schema = Record<string, unknown>;
const id: Schema = {type: "string", minLength: 1, maxLength: 96,
  pattern: "^[A-Za-z0-9][A-Za-z0-9._:-]*$"};
const requestId: Schema = {type: "string", minLength: 8, maxLength: 96,
  pattern: "^[A-Za-z0-9][A-Za-z0-9._:-]*$"};
const note: Schema = {type: "string", minLength: 1, maxLength: 2000};
const shortText: Schema = {type: "string", minLength: 1, maxLength: 160};
const nullableText = (maxLength: number): Schema =>
  {return {type: ["string", "null"], maxLength};};
const nullableId: Schema = {anyOf: [id, {type: "null"}]};
const dateTime: Schema = {type: "string", format: "date-time"};
const nullableDateTime: Schema = {anyOf: [dateTime, {type: "null"}]};
const revision: Schema = {type: "integer", minimum: 0, maximum: 1_000_000_000};
const listLimit: Schema = {type: "integer", minimum: 1, maximum: 50};
const cursor: Schema = {type: "string", minLength: 1, maxLength: 512};
const researchStatus: Schema = {enum: ["new", "needs_research", "ready_for_review",
  "qualified", "benchmark_only", "no_fit", "archived"]};
const taskKind: Schema = {enum: ["research", "reply", "follow_up", "demo", "pilot",
  "duplicate_review", "opt_out", "service_commitment"]};
const taskStatus: Schema = {enum: ["open", "completed", "cancelled"]};
const opportunityStage: Schema = {enum: ["new_enquiry", "ready_to_contact", "contacted",
  "in_conversation", "demo_arranged", "demo_completed", "pilot_agreed",
  "pilot_running", "commercial_discussion", "closed_won", "closed_lost"]};
const strict = (required: string[], properties: Record<string, unknown>): Schema =>
  ({type: "object", additionalProperties: false, required, properties});
const page = (extra: Record<string, unknown> = {}): Schema =>
  strict([], {limit: listLimit, cursor, ...extra});

export const SALES_READ_SCHEMAS: Record<SalesReadAction, Schema> = {
  "hosts.search": page({query: {type: "string", minLength: 2, maxLength: 80},
    ownerUid: id, researchStatus}),
  "hosts.get": strict(["organizerId"], {organizerId: id}),
  "tasks.list": page({ownerUid: id, status: taskStatus}),
  "opportunities.list": page({ownerUid: id, stage: opportunityStage}),
  "fields.list": strict([], {}),
  "receipts.get": strict(["requestId"], {requestId}),
};

export const SALES_ACTION_SCHEMAS: Record<SalesMutationAction, Schema> = {
  "hosts.create": strict(["organizerId", "requestId"], {organizerId: id, requestId}),
  "hosts.update": strict(["organizerId", "requestId", "expectedRevision", "patch"], {
    organizerId: id, requestId, expectedRevision: revision,
    patch: {type: "object", additionalProperties: false, minProperties: 1, properties: {
      researchStatus, assignedOwnerUid: nullableId, summary: nullableText(1200),
      nextAction: nullableText(320),
    }},
  }),
  "tasks.upsert": strict(["organizerId", "requestId", "expectedRevision", "task"], {
    organizerId: id, requestId, expectedRevision: revision, taskId: id,
    task: strict(["kind", "title", "dueAt", "ownerUid", "status"], {
      kind: taskKind, title: shortText, dueAt: nullableDateTime,
      ownerUid: id, status: taskStatus,
    }),
  }),
  "opportunities.upsert": strict(["organizerId", "requestId", "expectedRevision", "fields"], {
    organizerId: id, requestId, expectedRevision: revision, opportunityId: id,
    fields: strict(["motion", "stage", "ownerUid", "nextStep", "nextStepAt"], {
      motion: shortText, stage: opportunityStage, ownerUid: id,
      nextStep: nullableText(320), nextStepAt: nullableDateTime,
    }),
  }),
  "activities.log": strict(["organizerId", "requestId", "type", "occurredAt", "note"], {
    organizerId: id, requestId, opportunityId: id,
    type: {enum: ["note", "reply", "call", "demo", "pilot", "correction"]},
    occurredAt: dateTime, note,
  }),
  "fields.create": strict(["requestId", "field"], {requestId,
    field: strict(["fieldId", "label", "type", "recordType"], {
      fieldId: id, label: shortText,
      type: {enum: ["string", "number", "boolean", "date", "enum"]},
      recordType: {const: "account"}, helpText: nullableText(320),
      enumOptions: {type: "array", maxItems: 20, uniqueItems: true,
        items: shortText},
    })}),
  "fields.setValue": strict(["organizerId", "requestId", "expectedRevision",
    "fieldId", "value"], {organizerId: id, requestId,
    expectedRevision: revision, fieldId: id,
    value: {anyOf: [{type: "string", maxLength: 500},
      {type: "number"}, {type: "boolean"}, {type: "null"}]},
  }),
};

const ajv = new Ajv({allErrors: true, strict: true});
addFormats(ajv);
const readValidators = Object.fromEntries(Object.entries(SALES_READ_SCHEMAS)
  .map(([action, schema]) => [action, ajv.compile(schema)])) as
  Record<SalesReadAction, ValidateFunction>;
const actionValidators = Object.fromEntries(Object.entries(SALES_ACTION_SCHEMAS)
  .map(([action, schema]) => [action, ajv.compile(schema)])) as
  Record<SalesMutationAction, ValidateFunction>;

export function validateSalesRead(action: SalesReadAction, payload: unknown): void {
  assertValid(readValidators[action], payload);
}

export function validateSalesAction(action: SalesMutationAction, payload: unknown): void {
  assertValid(actionValidators[action], payload);
}

function assertValid(validator: ValidateFunction, payload: unknown): void {
  if (validator(payload)) return;
  const detail = (validator.errors ?? []).map((error) => {
    const property = error.keyword === "additionalProperties" ?
      String(error.params.additionalProperty) : "";
    return `${error.instancePath || "/"}${property ? `/${property}` : ""}: ${error.message}`;
  }).join("; ");
  throw new HttpsError("invalid-argument", detail);
}
