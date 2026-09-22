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
    "clientOperationId"
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
      "maximum": 9007199254740991,
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
    }
  }
} as const;
