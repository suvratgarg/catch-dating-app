/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Server-owned payout-provider account state. New documents use hostPaymentAccounts/{uid}_{provider}; legacy Stripe documents at {uid} remain readable during migration.
 */
export interface HostPaymentAccountDocument {
  userId: string;
  provider: "razorpay" | "stripe";
  country: string;
  defaultCurrency: string;
  providerAccountId: string;
  stripeAccountId: string;
  razorpayAccountId: string;
  razorpayProductId?: string | null;
  chargesEnabled: boolean;
  payoutsEnabled: boolean;
  detailsSubmitted: boolean;
  onboardingStatus: "notStarted" | "pending" | "complete" | "restricted";
  disabledReason?: string | null;
  /**
   * @maxItems 80
   */
  requirementsCurrentlyDue: string[];
  /**
   * @maxItems 80
   */
  requirementsPastDue: string[];
  /**
   * @maxItems 80
   */
  requirementsPendingVerification: string[];
  lastStripeEventId?: string | null;
  /**
   * Serialized Firestore Timestamp fixture shape.
   */
  createdAt: {
    _seconds: number;
    _nanoseconds: number;
  };
  /**
   * Serialized Firestore Timestamp fixture shape.
   */
  updatedAt: {
    _seconds: number;
    _nanoseconds: number;
  };
}
