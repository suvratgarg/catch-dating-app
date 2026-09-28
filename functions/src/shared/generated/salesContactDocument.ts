/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Shared person identity only; organizer-specific endpoints and contactability live on relationships.
 */
export interface SalesContactDocument {
  schemaVersion: 1;
  classification: "sales_private";
  contactId: string;
  displayName: string;
  revision: number;
  createdAt: string;
  updatedAt: string;
  createdBy: string;
}
