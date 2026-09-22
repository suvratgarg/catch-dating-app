/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const transportVendorListCallableResponseSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callable_responses/transport_vendor_list_response.schema.json",
  "title": "TransportVendorListCallableResponse",
  "description": "Operational vendor picker data: id, name and program binding only. Contact and commercial fields stay on manager surfaces.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "vendors"
  ],
  "properties": {
    "vendors": {
      "type": "array",
      "maxItems": 100,
      "items": {
        "type": "object",
        "additionalProperties": false,
        "required": [
          "vendorId",
          "name",
          "active",
          "boundToProgram"
        ],
        "properties": {
          "vendorId": {
            "type": "string",
            "minLength": 1,
            "maxLength": 180
          },
          "name": {
            "type": "string",
            "minLength": 1,
            "maxLength": 140
          },
          "active": {
            "type": "boolean"
          },
          "boundToProgram": {
            "type": "boolean"
          }
        }
      }
    }
  }
} as const;
