/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const deleteSavedEventClientWriteSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/client_writes/delete_saved_event.schema.json",
  "title": "DeleteSavedEventClientWrite",
  "description": "Client-owned Firestore delete operation for savedEvents/{savedEventId}.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "path"
  ],
  "properties": {
    "path": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "savedEventId"
      ],
      "properties": {
        "savedEventId": {
          "type": "string",
          "minLength": 1,
          "maxLength": 180
        }
      }
    }
  },
  "x-firestore-operation": "delete",
  "x-firestore-path": "savedEvents/{savedEventId}",
  "x-owner": "authenticated owner direct delete"
} as const;
