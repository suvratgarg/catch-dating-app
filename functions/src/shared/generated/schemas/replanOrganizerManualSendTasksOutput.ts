/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const replanOrganizerManualSendTasksCallableResponseSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callable_responses/replan_organizer_manual_send_tasks_response.schema.json",
  "title": "ReplanOrganizerManualSendTasksCallableResponse",
  "description": "Current route advice for manual tasks. Returning this response never mutates or completes a task.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "organizerId",
    "results",
    "resolvedAtMillis"
  ],
  "properties": {
    "organizerId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "results": {
      "type": "array",
      "minItems": 1,
      "maxItems": 50,
      "items": {
        "type": "object",
        "additionalProperties": false,
        "required": [
          "taskId",
          "contactId",
          "disposition",
          "recommendedRouteId",
          "blocker"
        ],
        "properties": {
          "taskId": {
            "type": "string",
            "minLength": 1,
            "maxLength": 180
          },
          "contactId": {
            "type": "string",
            "minLength": 1,
            "maxLength": 180
          },
          "disposition": {
            "type": "string",
            "enum": [
              "keepByHand",
              "managedRouteAvailable",
              "unavailable",
              "taskInactive"
            ]
          },
          "recommendedRouteId": {
            "type": [
              "string",
              "null"
            ],
            "enum": [
              "catchChat",
              "personalWhatsappHandoff",
              null
            ]
          },
          "blocker": {
            "type": [
              "string",
              "null"
            ],
            "enum": [
              "catchAccountRequired",
              "identityAmbiguous",
              "missingPhone",
              "organizerSuppressed",
              "contactOptedOut",
              "contactUnavailable",
              "endpointChanged",
              null
            ]
          }
        }
      }
    },
    "resolvedAtMillis": {
      "type": "integer",
      "minimum": 0
    }
  }
} as const;
