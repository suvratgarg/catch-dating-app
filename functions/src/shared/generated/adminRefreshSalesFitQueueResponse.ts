/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

import type {SalesFitQueueEntryDocument} from "./salesFitQueueEntryDocument";

export interface AdminRefreshSalesFitQueueResponse {
  entry: SalesFitQueueEntryDocument;
  receipt: {
    requestId: string;
    sourceHash: string;
  };
}
