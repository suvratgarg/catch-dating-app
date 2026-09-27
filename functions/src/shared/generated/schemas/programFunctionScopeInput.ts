/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const programFunctionScopeCallablePayloadSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callables/program_function_scope_payload.schema.json",
  "title": "ProgramFunctionScopeCallablePayload",
  "description": "Function-scoped program read shared by the door roster view and other per-function staff surfaces.",
  "type": "object",
  "additionalProperties": false,
  "x-callable-aliases": [
    "getProgramFunctionDoorView"
  ],
  "required": [
    "programId",
    "functionId"
  ],
  "properties": {
    "programId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "functionId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180,
      "description": "Requested function. Staff are still intersected with their granted function scope; managers may read any function."
    }
  }
} as const;
