/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

import type {SalesIntakeLinkDocument} from "./salesIntakeLinkDocument";
import type {OrganizerSalesAccountDocument} from "./organizerSalesAccountDocument";

export interface AdminLinkOrganizerIntakeToSalesResponse {
  link: SalesIntakeLinkDocument;
  account: OrganizerSalesAccountDocument;
  accountCreated: boolean;
}
