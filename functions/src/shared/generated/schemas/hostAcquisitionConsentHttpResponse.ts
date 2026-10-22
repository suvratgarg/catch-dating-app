/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const hostAcquisitionConsentHTTPResponseSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/http/host_acquisition_consent_response.schema.json",
  "title": "HostAcquisitionConsentHTTPResponse",
  "description": "Permission handshake result. Disabled or revoked status never authorizes delivery.",
  "oneOf": [
    {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "ok",
        "status",
        "expiresAt"
      ],
      "properties": {
        "ok": {
          "const": true
        },
        "status": {
          "enum": [
            "active",
            "revoked",
            "disabled"
          ]
        },
        "expiresAt": {
          "type": [
            "integer",
            "null"
          ],
          "minimum": 1
        }
      }
    },
    {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "error"
      ],
      "properties": {
        "error": {
          "type": "string",
          "minLength": 1,
          "maxLength": 200
        }
      }
    }
  ]
} as const;
