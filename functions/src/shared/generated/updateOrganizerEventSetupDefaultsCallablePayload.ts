/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export interface UpdateOrganizerEventSetupDefaultsCallablePayload {
  organizerId: string;
  requestId: string;
  expectedRevision: number;
  reviewedDefaultsHash: string;
  changes: {
    usualDurationMinutes?:
      | {
          mode: "set";
          value: number;
        }
      | {
          mode: "clear";
        };
    preferredVenueId?:
      | {
          mode: "set";
          value: string;
        }
      | {
          mode: "clear";
        };
    offerValidityMinutes?:
      | {
          mode: "set";
          value: number;
        }
      | {
          mode: "clear";
        };
    collectionPreference?:
      | {
          mode: "set";
          value:
            | "manualInstructions"
            | "reusablePage"
            | "personalRequest"
            | "catchCheckout";
        }
      | {
          mode: "clear";
        };
    currency?:
      | {
          mode: "set";
          value: string;
        }
      | {
          mode: "clear";
        };
    offerMessageTemplate?:
      | {
          mode: "set";
          value: string;
        }
      | {
          mode: "clear";
        };
    paymentInstructions?:
      | {
          mode: "set";
          value: string;
        }
      | {
          mode: "clear";
        };
    reusablePaymentPage?:
      | {
          mode: "set";
          value: {
            url: string;
            reusableForEvents: true;
          };
        }
      | {
          mode: "clear";
        };
    timezone?:
      | {
          mode: "set";
          value: string;
        }
      | {
          mode: "clear";
        };
  };
}
