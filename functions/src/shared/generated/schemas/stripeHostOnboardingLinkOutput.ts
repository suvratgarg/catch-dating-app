/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export const stripeHostOnboardingLinkCallableResponseSchema: Record<string, unknown> = {
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://catch.app/contracts/callable_responses/stripe_host_onboarding_link_response.schema.json",
  "title": "StripeHostOnboardingLinkCallableResponse",
  "description": "Callable response returned by createStripeHostOnboardingLink.",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "accountId",
    "onboardingUrl"
  ],
  "properties": {
    "accountId": {
      "type": "string",
      "minLength": 1,
      "maxLength": 120
    },
    "onboardingUrl": {
      "type": "string",
      "format": "uri",
      "maxLength": 2048
    }
  }
} as const;
