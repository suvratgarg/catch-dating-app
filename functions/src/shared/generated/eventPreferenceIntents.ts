/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export interface EventPreferenceIntents {
  usualDurationMinutes:
    | {
        mode: "set";
        value: number;
      }
    | {
        mode: "clear";
      }
    | {
        mode: "inherit";
      };
  preferredVenueId:
    | {
        mode: "set";
        value: string;
      }
    | {
        mode: "clear";
      }
    | {
        mode: "inherit";
      };
  offerValidityMinutes:
    | {
        mode: "set";
        value: number;
      }
    | {
        mode: "clear";
      }
    | {
        mode: "inherit";
      };
  collectionPreference:
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
      }
    | {
        mode: "inherit";
      };
  currency:
    | {
        mode: "set";
        value: string;
      }
    | {
        mode: "clear";
      }
    | {
        mode: "inherit";
      };
  offerMessageTemplate:
    | {
        mode: "set";
        value: string;
      }
    | {
        mode: "clear";
      }
    | {
        mode: "inherit";
      };
  paymentInstructions:
    | {
        mode: "set";
        value: string;
      }
    | {
        mode: "clear";
      }
    | {
        mode: "inherit";
      };
  reusablePaymentPage:
    | {
        mode: "set";
        value: {
          url: string;
          reusableForEvents: true;
        };
      }
    | {
        mode: "clear";
      }
    | {
        mode: "inherit";
      };
  admissionPreset:
    | {
        mode: "set";
        value:
          | "openCapacity"
          | "inviteOnly"
          | "balancedSingles"
          | "fixedCohortCaps";
      }
    | {
        mode: "clear";
      }
    | {
        mode: "inherit";
      };
  expectedAmountMinor:
    | {
        mode: "set";
        value: number;
      }
    | {
        mode: "clear";
      };
}
