/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

import type {SalesQuoteVersionsDocument} from "./salesQuoteVersionsDocument";
import type {SalesQuotesDocument} from "./salesQuotesDocument";

export interface AdminReviseSalesQuoteResponse {
  quote: SalesQuotesDocument;
  quoteVersion: SalesQuoteVersionsDocument;
  receipt: {
    requestId: string;
    revision: number | null;
  };
}
