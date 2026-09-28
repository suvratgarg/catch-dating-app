/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

import type {SalesHostSettlementAttestationsDocument} from "./salesHostSettlementAttestations";

export interface AdminAttestSalesHostSettlementResponse {
  attestation: SalesHostSettlementAttestationsDocument;
  receipt: {
    requestId: string;
    revision: number | null;
  };
}
