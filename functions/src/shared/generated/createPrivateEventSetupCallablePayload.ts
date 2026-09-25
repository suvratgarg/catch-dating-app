/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export interface CreatePrivateEventSetupCallablePayload {
  organizerId: string;
  requestId: string;
  basics: {
    name: string;
    city:
      | {
          mode: "inherit";
        }
      | {
          mode: "set";
          value: {
            cityId: string;
            marketId: string;
          };
        };
    localDate: string;
    localStartTime: string;
    timezone:
      | {
          mode: "inherit";
        }
      | {
          mode: "set";
          value: string;
        };
    reviewedDefaultsHash?: string;
  };
}
