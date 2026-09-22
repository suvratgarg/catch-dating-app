/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const setProgramTravelReadinessCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/set_program_travel_readiness_payload.schema.json",
  "title": "SetProgramTravelReadinessCallablePayload",
  "description": "Greeter/dispatcher leg observation: claim, unclaim, mark ready at curb, or flag disruption. clientOperationId makes offline replays safe.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "programId",
    "legId",
    "action",
    "clientOperationId",
    "expectedRevision",
    "observedAtMillis"
  ],
  "properties": {
    "programId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "legId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "action": {
      "type": "string",
      "enum": [
        "markReady",
        "claim",
        "unclaim",
        "markDisrupted"
      ]
    },
    "expectedRevision": {
      "type": "integer",
      "minimum": 1,
      "maximum": 9007199254740991
    },
    "manualCurbAtMillis": {
      "type": [
        "integer",
        "null"
      ],
      "minimum": 0,
      "maximum": 253402300799999,
      "description": "Reviewed curb estimate set alongside markDisrupted or planner correction."
    },
    "manualCurbNote": {
      "type": [
        "string",
        "null"
      ],
      "maxLength": 280
    },
    "clientOperationId": {
      "type": "string",
      "minLength": 8,
      "maxLength": 120
    },
    "afterObservation": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "clientOperationId",
        "action"
      ],
      "description": "A preceding observation by the same actor on the same journey. Its receipt result revision must still equal the current leg revision.",
      "properties": {
        "clientOperationId": {
          "type": "string",
          "minLength": 8,
          "maxLength": 120
        },
        "action": {
          "type": "string",
          "enum": [
            "claim",
            "unclaim",
            "markReady",
            "markDisrupted"
          ]
        }
      }
    },
    "observedAtMillis": {
      "type": "integer",
      "minimum": 0,
      "maximum": 253402300799999,
      "description": "Immutable device observation time; accepted up to seven days late with five minutes of clock skew."
    }
  }
} as const;
