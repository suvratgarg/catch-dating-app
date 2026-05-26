/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Callable payload accepted by createStripeHostOnboardingLink. Hosts can optionally provide the Stripe account country and default currency for first-time setup.
 */
export interface CreateStripeHostOnboardingLinkCallablePayload {
  country?: string | null;
  defaultCurrency?: string | null;
}
