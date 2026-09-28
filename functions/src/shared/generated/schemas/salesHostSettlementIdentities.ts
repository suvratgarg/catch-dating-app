/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const salesHostSettlementIdentitiesDocumentSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/firestore/sales_host_settlement_identities.schema.json",
  "title": "SalesHostSettlementIdentitiesDocument",
  "description": "Immutable uniqueness receipt for one external host settlement reference within one recipient ledger scope, independent of evidence and quote IDs.",
  "type": "object",
  "additionalProperties": false,
  "x-firestore-collection": "salesHostSettlementIdentities",
  "x-firestore-path": "salesHostSettlementIdentities/{settlementIdentityHash}",
  "x-document-id-field": "settlementIdentityHash",
  "x-owner": "private Sales commercial service",
  "required": [
    "schemaVersion",
    "classification",
    "settlementIdentityHash",
    "attestationId",
    "organizerId",
    "opportunityId",
    "createdAt"
  ],
  "properties": {
    "schemaVersion": {
      "const": 1
    },
    "classification": {
      "const": "sales_private"
    },
    "settlementIdentityHash": {
      "type": "string",
      "pattern": "^[a-f0-9]{64}$"
    },
    "attestationId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 96
    },
    "organizerId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 96
    },
    "opportunityId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 96
    },
    "createdAt": {
      "type": "string",
      "format": "date-time",
      "maxLength": 48
    }
  }
} as const;
