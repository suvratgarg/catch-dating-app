/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Private bounded Sales callable request. Server authorization and transaction policy are enforced separately.
 */
export interface AdminCreateSalesCustomFieldCallablePayload {
  requestId: string;
  field: {
    fieldId: string;
    label: string;
    type: "string" | "number" | "boolean" | "date" | "enum";
    recordType: "account";
    helpText?: string | null;
    /**
     * @maxItems 20
     */
    enumOptions?: string[];
  };
}
