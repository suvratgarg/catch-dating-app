/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

import type {SalesHostSettlementAttestationsDocument} from "./salesHostSettlementAttestations";
import type {SalesCommercialDecisionsDocument} from "./salesCommercialDecisionsDocument";
import type {SalesOpportunityStageHistoryDocument} from "./salesOpportunityStageHistoryDocument";
import type {SalesPilotPlansDocument} from "./salesPilotPlansDocument";
import type {SalesQuoteVersionsDocument} from "./salesQuoteVersionsDocument";
import type {SalesQuotesDocument} from "./salesQuotesDocument";
import type {SalesOpportunityDocument} from "./salesOpportunityDocument";

export interface AdminGetSalesCommercialDetailResponse {
  opportunity: SalesOpportunityDocument;
  pilotPlan: SalesPilotPlansDocument | null;
  quote: SalesQuotesDocument | null;
  quoteVersion: SalesQuoteVersionsDocument | null;
  approvedDecision: SalesCommercialDecisionsDocument | null;
  acceptedDecision: SalesCommercialDecisionsDocument | null;
  settlementAttestation: SalesHostSettlementAttestationsDocument | null;
  /**
   * @maxItems 25
   */
  history: SalesOpportunityStageHistoryDocument[];
  historyTruncated: boolean;
  paymentStatus: "unknown" | "manual_attested";
  bookedHostRevenueMinor: null;
}
