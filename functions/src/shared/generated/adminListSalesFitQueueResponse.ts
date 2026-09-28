/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

import type {SalesFitQueueEntryDocument} from "./salesFitQueueEntryDocument";

export interface AdminListSalesFitQueueResponse {
  /**
   * @maxItems 25
   */
  rows: SalesFitQueueEntryDocument[];
  nextCursor: string | null;
  generation: number;
  policyRevision: number;
  qualificationPolicyHash: string | null;
  omittedExpiredInPage: number;
}
