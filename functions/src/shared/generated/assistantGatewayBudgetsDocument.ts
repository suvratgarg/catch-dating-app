/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Transactional request counter for one delegated client or owner window.
 */
export interface AssistantGatewayBudgetsDocument {
  schemaVersion: 1;
  classification: "sales_private";
  budgetId: string;
  windowKind: "minute" | "day";
  count: number;
  /**
   * Serialized Firestore Timestamp fixture shape.
   */
  expiresAt: {
    _seconds: number;
    _nanoseconds: number;
  };
}
