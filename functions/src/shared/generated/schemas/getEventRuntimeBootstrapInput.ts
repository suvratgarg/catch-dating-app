/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const getEventRuntimeBootstrapCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/get_event_runtime_bootstrap_payload.schema.json",
  "title": "GetEventRuntimeBootstrapCallablePayload",
  "description": "Opaque public Event Success runtime lookup.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "publicRuntimeId"
  ],
  "properties": {
    "publicRuntimeId": {
      "type": "string",
      "pattern": "^[A-Za-z0-9_-]{20,80}$"
    }
  }
} as const;
