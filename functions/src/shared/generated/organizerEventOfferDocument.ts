/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

import type {EventOfferPaymentSnapshot} from "./eventOfferPaymentSnapshot";
import type {EventOfferManualPayment} from "./eventOfferManualPayment";

export interface OrganizerEventOfferDocument {
  organizerId: string;
  eventId: string;
  contactId: string;
  applicationId: string;
  sourceKind: "application" | "formResponse";
  offerId: string;
  status: "draft" | "offered" | "withdrawn" | "expired";
  generation: number;
  revision: number;
  expiresAtMillis: number;
  organizerPaymentLink: string | null;
  paymentSnapshot: EventOfferPaymentSnapshot;
  offeredAtMillis: number | null;
  manualPayment: EventOfferManualPayment;
  createdAtMillis: number;
  updatedAtMillis: number;
}
