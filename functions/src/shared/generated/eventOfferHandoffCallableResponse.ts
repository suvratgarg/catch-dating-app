/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export type EventOfferHandoffCallableResponse =
  | {
      kind: "blocked";
      offerId: string;
      /**
       * @minItems 1
       * @maxItems 28
       */
      blockers: (
        | "offerUnavailable"
        | "offerWithdrawn"
        | "offerExpired"
        | "eventMismatch"
        | "eventCanceled"
        | "eventArchived"
        | "eventUnavailable"
        | "contactMismatch"
        | "sourceRevoked"
        | "contactUnavailable"
        | "contactOptedOut"
        | "permissionUnavailable"
        | "termsChanged"
        | "nameMissing"
        | "eventMissing"
        | "eventStarted"
        | "timeMissing"
        | "timeZoneInvalid"
        | "paymentPolicyMissing"
        | "paymentModeUnsupported"
        | "currencyMissing"
        | "paymentLinkMissing"
        | "paymentLinkInvalid"
        | "paymentLinkMismatch"
        | "paymentInstructionsMissing"
        | "phoneMissing"
        | "phoneInvalid"
        | "templateInvalid"
      )[];
    }
  | {
      kind: "prepared";
      offerId: string;
      contactId: string;
      editableText: string;
      copyText: string;
      whatsappUrl: string;
    };
