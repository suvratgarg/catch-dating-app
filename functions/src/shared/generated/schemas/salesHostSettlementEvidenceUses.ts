/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const salesHostSettlementEvidenceUsesDocumentSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/firestore/sales_host_settlement_evidence_uses.schema.json",
  "title": "SalesHostSettlementEvidenceUsesDocument",
  "description": "Immutable uniqueness receipt preventing one settlement source from double counting.",
  "type": "object",
  "additionalProperties": false,
  "x-firestore-collection": "salesHostSettlementEvidenceUses",
  "x-firestore-path": "salesHostSettlementEvidenceUses/{evidenceId}",
  "x-owner": "private Sales commercial service",
  "required": [
    "schemaVersion",
    "classification",
    "evidenceId",
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
    "evidenceId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 96,
      "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
    },
    "attestationId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 96,
      "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
    },
    "organizerId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 96,
      "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
    },
    "opportunityId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 96,
      "pattern": "^[A-Za-z0-9][A-Za-z0-9._:-]*$"
    },
    "createdAt": {
      "type": "string",
      "format": "date-time",
      "maxLength": 48
    }
  },
  "x-document-id-field": "evidenceId"
} as const;
