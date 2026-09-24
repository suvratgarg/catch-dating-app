/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

import type {OrganizerEventOfferDocument} from "./organizerEventOfferDocument";

export interface EventOfferDetailCallableResponse {
  offer: OrganizerEventOfferDocument;
  effectiveStatus: "draft" | "offered" | "withdrawn" | "expired";
}
