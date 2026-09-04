/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const organizerAudienceSummaryDocumentSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/firestore/organizer_audience_summaries.schema.json",
  "title": "OrganizerAudienceSummaryDocument",
  "description": "Server-maintained scalable organizer audience summary projected from contact traits.",
  "type": "object",
  "additionalProperties": false,
  "x-firestore-collection": "organizerAudienceSummaries",
  "x-firestore-path": "organizerAudienceSummaries/{organizerId}",
  "x-document-id-field": "organizerId",
  "x-owner": "organizer audience projection and getOrganizerCrmSummary",
  "required": [
    "organizerId",
    "contactCount",
    "pastAttendeeCount",
    "repeatAttendeeCount",
    "linkedAccountCount",
    "importedContactCount",
    "advocateCount",
    "highImpactAdvocateCount",
    "whatsappOptInCount",
    "smsOptInCount",
    "sourceCoverage",
    "projectionVersion",
    "computedAt"
  ],
  "properties": {
    "organizerId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180
    },
    "contactCount": {
      "type": "integer",
      "minimum": 0,
      "maximum": 2147483647
    },
    "pastAttendeeCount": {
      "type": "integer",
      "minimum": 0,
      "maximum": 2147483647
    },
    "repeatAttendeeCount": {
      "type": "integer",
      "minimum": 0,
      "maximum": 2147483647
    },
    "linkedAccountCount": {
      "type": "integer",
      "minimum": 0,
      "maximum": 2147483647
    },
    "importedContactCount": {
      "type": "integer",
      "minimum": 0,
      "maximum": 2147483647
    },
    "advocateCount": {
      "type": "integer",
      "minimum": 0,
      "maximum": 2147483647
    },
    "highImpactAdvocateCount": {
      "type": "integer",
      "minimum": 0,
      "maximum": 2147483647
    },
    "whatsappOptInCount": {
      "type": "integer",
      "minimum": 0,
      "maximum": 2147483647
    },
    "smsOptInCount": {
      "type": "integer",
      "minimum": 0,
      "maximum": 2147483647
    },
    "sourceCoverage": {
      "type": "string",
      "enum": [
        "exact",
        "partial"
      ]
    },
    "projectionVersion": {
      "type": "integer",
      "minimum": 1,
      "maximum": 1000
    },
    "computedAt": {
      "type": "object",
      "description": "Serialized Firestore Timestamp fixture shape.",
      "x-firestore-type": "timestamp",
      "additionalProperties": false,
      "required": [
        "_seconds",
        "_nanoseconds"
      ],
      "properties": {
        "_seconds": {
          "type": "integer"
        },
        "_nanoseconds": {
          "type": "integer",
          "minimum": 0,
          "maximum": 999999999
        }
      }
    }
  },
  "definitions": {
    "count": {
      "type": "integer",
      "minimum": 0,
      "maximum": 2147483647
    }
  }
} as const;
