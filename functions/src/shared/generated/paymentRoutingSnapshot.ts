/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export interface PaymentRoutingSnapshot {
  version: 1;
  purpose: "formFee" | "eventAdmission";
  organizerId: string;
  selection: {
    route:
      | "razorpayRoute"
      | "razorpayOAuth"
      | "stripeConnectDirect"
      | "stripeConnectDestination";
    mode: "test" | "live";
    currency: string;
    merchantCountry: string;
  };
  policySource: "app" | "organizer" | "legacy";
  appRevision: number;
  organizerRevision: number;
  bindingId: string;
  merchantAccountId: string;
  destinationAccountId: string | null;
  configurationVersion: string;
  checkoutKey: string | null;
}
