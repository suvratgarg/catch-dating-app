/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Typed value validated against its private field definition in the transaction.
 */
export interface SalesCustomFieldValueDocument {
  schemaVersion: 1;
  classification: "sales_private";
  organizerId: string;
  fieldId: string;
  value: string | number | boolean | null;
  revision: number;
  updatedAt: string;
  updatedBy: string;
}
