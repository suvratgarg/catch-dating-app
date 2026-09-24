/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

import type {OrganizerEventOfferDocument} from "./organizerEventOfferDocument";
import type {OrganizerEventOfferActionReceiptDocument} from "./organizerEventOfferActionReceiptDocument";

export interface EventOfferMutationCallableResponse {
  offer: OrganizerEventOfferDocument;
  receipt: OrganizerEventOfferActionReceiptDocument;
  replayed: boolean;
}
