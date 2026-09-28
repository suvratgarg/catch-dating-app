/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

import type {AdminRefreshSalesFitQueueResponse} from "./adminRefreshSalesFitQueueResponse";

/**
 * Private exact-retry receipt for one host fit projection refresh, not a durable claim of current rank.
 */
export interface SalesFitQueueReceiptDocument {
  schemaVersion: 1;
  classification: "sales_private";
  receiptId: string;
  actorUid: string;
  requestId: string;
  materialHash: string;
  result: AdminRefreshSalesFitQueueResponse;
  createdAt: string;
  qualificationPolicyHash: string | null;
}
