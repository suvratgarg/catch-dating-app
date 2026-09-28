/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

import type {SalesCommercialDecisionsDocument} from "./salesCommercialDecisionsDocument";
import type {SalesQuotesDocument} from "./salesQuotesDocument";

export interface AdminApproveSalesQuoteResponse {
  quote: SalesQuotesDocument;
  decision: SalesCommercialDecisionsDocument;
  receipt: {
    requestId: string;
    revision: number | null;
  };
}
