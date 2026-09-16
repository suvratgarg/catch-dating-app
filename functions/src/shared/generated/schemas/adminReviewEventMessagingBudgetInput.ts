/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const adminReviewEventMessagingBudgetCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/admin_review_event_messaging_budget_payload.schema.json",
  "title": "AdminReviewEventMessagingBudgetCallablePayload",
  "description": "Exact Finance scope for a read-only event-messaging setup and current budget-decision review.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "organizerId",
    "eventId",
    "routeId",
    "senderId",
    "purpose"
  ],
  "properties": {
    "organizerId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "eventId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "routeId": {
      "type": "string",
      "enum": [
        "catchEventSms",
        "catchEventRcs",
        "organizerEventWhatsapp"
      ]
    },
    "senderId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 160,
      "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
    },
    "purpose": {
      "type": "string",
      "enum": [
        "joiningUpdate",
        "joiningInstructions",
        "planChanged",
        "eventCancelled",
        "eventFinished",
        "guestRequirement",
        "assignmentChanged",
        "participationCheck",
        "followUp"
      ]
    }
  }
} as const;
