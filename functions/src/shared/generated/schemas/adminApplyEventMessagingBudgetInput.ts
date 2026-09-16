/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const adminApplyEventMessagingBudgetCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/admin_apply_event_messaging_budget_payload.schema.json",
  "title": "AdminApplyEventMessagingBudgetCallablePayload",
  "description": "Stages one still-current approved event-messaging budget decision as paused event and sender-day ceilings. The operation grants no spending or dispatch authority and cannot activate a worker.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "requestId",
    "decisionId",
    "expectedDecisionRevision",
    "note"
  ],
  "properties": {
    "requestId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "decisionId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "expectedDecisionRevision": {
      "type": "integer",
      "minimum": 1,
      "maximum": 9007199254740991
    },
    "note": {
      "type": "string",
      "minLength": 1,
      "maxLength": 1000
    }
  }
} as const;
