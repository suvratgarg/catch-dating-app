/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export interface ReconcilePrivateEventSeatsCallablePayload {
  organizerId: string;
  eventId: string;
  requestId: string;
  expectedSetupRevision: number;
  reviewedDefaultsHash: string;
  details: {
    admissionTerms: {
      capacityLimit: number;
      priceInPaise: number;
      currency: string;
      cancellationPolicyId:
        | "notApplicable"
        | "flexible"
        | "standard"
        | "strict";
    };
  };
  discard?: boolean;
}
