/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Typed, namespaced private account field definition; never extends public organizer records.
 */
export type SalesCustomFieldDocument = {
  [k: string]: unknown;
} & {
  schemaVersion: 1;
  classification: "sales_private";
  fieldId: string;
  label: string;
  normalizedLabel: string;
  type: "string" | "number" | "boolean" | "date" | "enum";
  recordType: "account";
  helpText: string | null;
  /**
   * @minItems 0
   * @maxItems 20
   */
  enumOptions: string[];
  revision: 1;
  createdAt: string;
  createdBy: string;
};
