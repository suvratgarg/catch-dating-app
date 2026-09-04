/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const injectEventRehearsalBehaviorCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/inject_event_rehearsal_behavior_payload.schema.json",
  "title": "InjectEventRehearsalBehaviorCallablePayload",
  "description": "Applies a deterministic synthetic-actor behavior or an internal-only fault.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "sessionId",
    "expectedRevision",
    "clientActionId",
    "actorId",
    "behavior",
    "faultId"
  ],
  "properties": {
    "sessionId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "expectedRevision": {
      "type": "integer",
      "minimum": 0,
      "maximum": 2147483647
    },
    "clientActionId": {
      "type": "string",
      "pattern": "^[A-Za-z0-9_-]{8,120}$"
    },
    "actorId": {
      "anyOf": [
        {
          "type": "string",
          "minLength": 1,
          "maxLength": 180
        },
        {
          "type": "null"
        }
      ]
    },
    "behavior": {
      "type": [
        "string",
        "null"
      ],
      "enum": [
        "arrive",
        "arriveLate",
        "markNoShow",
        "leaveEarly",
        "return",
        "walkIn",
        "ambiguousClaim",
        "resolveClaim",
        "optOut",
        "optIn",
        "keepApart",
        "disconnect",
        "reconnect",
        null
      ]
    },
    "faultId": {
      "type": "string",
      "enum": [
        "none",
        "latency",
        "oneShotFailure",
        "listenerDisconnect",
        "staleRevision",
        "duplicateDelivery",
        "legacyFixture",
        "reducedMotion",
        "lowBandwidth"
      ]
    }
  }
} as const;
