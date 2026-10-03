/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const programLodgingProposalDocumentSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/firestore/program_lodging_proposals.schema.json",
  "title": "ProgramLodgingProposalDocument",
  "description": "Private immutable placement proposal tied to source, inventory, layout and published revisions. Server validates content identity and current canonical Programs scope; no hotel affinity or medical projection is public.",
  "x-firestore-collection": "programLodgingProposals",
  "x-firestore-path": "programLodgingProposals/{proposalId}",
  "x-document-id-field": "proposalId",
  "x-owner": "private program lodging server operations",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "programId",
    "organizerId",
    "proposal",
    "createdByUid",
    "createdAtMillis"
  ],
  "properties": {
    "programId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180,
      "x-catch-ownership": "server-only"
    },
    "organizerId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180,
      "x-catch-ownership": "server-only"
    },
    "proposal": {
      "type": "object",
      "additionalProperties": false,
      "required": [
        "scope",
        "id",
        "revisions",
        "placements",
        "unplacedPartyIds",
        "explanations",
        "score",
        "search"
      ],
      "properties": {
        "scope": {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "programId",
            "organizerId"
          ],
          "properties": {
            "programId": {
              "type": "string",
              "minLength": 1,
              "maxLength": 180,
              "x-catch-ownership": "server-only"
            },
            "organizerId": {
              "type": "string",
              "minLength": 1,
              "maxLength": 180,
              "x-catch-ownership": "server-only"
            }
          }
        },
        "id": {
          "type": "string",
          "pattern": "^[a-f0-9]{64}$"
        },
        "revisions": {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "source",
            "inventory",
            "layout",
            "published"
          ],
          "properties": {
            "source": {
              "type": "integer",
              "minimum": 0,
              "maximum": 9007199254740991
            },
            "inventory": {
              "type": "integer",
              "minimum": 0,
              "maximum": 9007199254740991
            },
            "layout": {
              "type": "integer",
              "minimum": 0,
              "maximum": 9007199254740991
            },
            "published": {
              "type": "integer",
              "minimum": 0,
              "maximum": 9007199254740991
            }
          }
        },
        "placements": {
          "type": "array",
          "maxItems": 500,
          "items": {
            "type": "object",
            "additionalProperties": false,
            "required": [
              "partyId",
              "inventoryId"
            ],
            "properties": {
              "partyId": {
                "type": "string",
                "minLength": 1,
                "maxLength": 180,
                "x-catch-ownership": "server-only"
              },
              "inventoryId": {
                "type": "string",
                "minLength": 1,
                "maxLength": 180,
                "x-catch-ownership": "server-only"
              }
            }
          }
        },
        "unplacedPartyIds": {
          "type": "array",
          "maxItems": 500,
          "items": {
            "type": "string",
            "minLength": 1,
            "maxLength": 180,
            "x-catch-ownership": "server-only"
          }
        },
        "explanations": {
          "type": "array",
          "maxItems": 502,
          "items": {
            "type": "string",
            "maxLength": 2000
          }
        },
        "score": {
          "type": "array",
          "minItems": 5,
          "maxItems": 5,
          "items": {
            "type": "number",
            "minimum": 0
          }
        },
        "search": {
          "type": "object",
          "additionalProperties": false,
          "required": [
            "complete",
            "explored"
          ],
          "properties": {
            "complete": {
              "type": "boolean"
            },
            "explored": {
              "type": "integer",
              "minimum": 0,
              "maximum": 9007199254740991
            }
          }
        }
      },
      "x-catch-ownership": "server-only"
    },
    "createdByUid": {
      "type": "string",
      "minLength": 1,
      "maxLength": 180,
      "x-catch-ownership": "server-only"
    },
    "createdAtMillis": {
      "type": "integer",
      "minimum": 1,
      "maximum": 9007199254740991,
      "x-catch-ownership": "server-only"
    }
  }
} as const;
