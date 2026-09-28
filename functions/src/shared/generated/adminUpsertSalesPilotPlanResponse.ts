/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

import type {SalesPilotPlansDocument} from "./salesPilotPlansDocument";

export interface AdminUpsertSalesPilotPlanResponse {
  pilotPlan: SalesPilotPlansDocument;
  receipt: {
    requestId: string;
    revision: number | null;
  };
}
