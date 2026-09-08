/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const eventRcsCapabilityObservationSchema: Record<string, unknown> = {
  "type": "object",
  "additionalProperties": false,
  "required": [
    "requestId",
    "senderId",
    "agentId",
    "recipientEndpointId",
    "configHash",
    "permissionHash",
    "checkedAt",
    "validUntil",
    "supportsOpenUrl"
  ],
  "properties": {
    "requestId": {
      "type": "string",
      "pattern": "^[a-f0-9]{8}-[a-f0-9]{4}-[1-5][a-f0-9]{3}-[89ab][a-f0-9]{3}-[a-f0-9]{12}$"
    },
    "senderId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 160,
      "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
    },
    "agentId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 512,
      "pattern": "^[A-Za-z0-9][A-Za-z0-9._@-]*$"
    },
    "recipientEndpointId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 160,
      "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
    },
    "configHash": {
      "type": "string",
      "pattern": "^[a-f0-9]{64}$"
    },
    "permissionHash": {
      "type": "string",
      "pattern": "^[a-f0-9]{64}$"
    },
    "checkedAt": {
      "type": "integer",
      "minimum": 0,
      "maximum": 9007199254740991
    },
    "validUntil": {
      "type": "integer",
      "minimum": 0,
      "maximum": 9007199254740991
    },
    "supportsOpenUrl": {
      "type": "boolean"
    }
  },
  "title": "EventRcsCapabilityObservation"
} as const;
