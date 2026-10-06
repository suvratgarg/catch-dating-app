/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

import type {ImportEventAttendeesCallablePayload} from "./importEventAttendeesCallablePayload";

/**
 * Private exact reviewed payload and outcome used for lost-response replay.
 */
export interface HostRosterIntakeReceiptDocument {
  importId: string;
  appliedAtMillis: number;
  preview: {
    sessionId: string;
    revision: number;
    reviewHash: string;
    /**
     * @minItems 1
     * @maxItems 250
     */
    rows: {
      rowId: string;
      sourceRowNumber: number;
      displayName: string;
      externalReference: string | null;
      attendeeId: string | null;
      kind:
        | "add"
        | "update"
        | "unchanged"
        | "excluded"
        | "needsReview"
        | "identityConflict";
      /**
       * @maxItems 11
       */
      changedFields: (
        | "displayName"
        | "phone"
        | "email"
        | "cityMarketId"
        | "externalReference"
        | "arrivalGroup"
        | "ticketType"
        | "revenueAmountMinor"
        | "revenueCurrency"
        | "revenueSource"
        | "status"
      )[];
      /**
       * @maxItems 11
       */
      fieldChanges: {
        field:
          | "displayName"
          | "phone"
          | "email"
          | "cityMarketId"
          | "externalReference"
          | "arrivalGroup"
          | "ticketType"
          | "revenueAmountMinor"
          | "revenueCurrency"
          | "revenueSource"
          | "status";
        currentValue: string | null;
        proposedValue: string | null;
        origin:
          | "upload"
          | "hostCorrection"
          | "modelProposal"
          | "default"
          | null;
      }[];
      issueCode: string | null;
    }[];
    counts: {
      add: number;
      update: number;
      unchanged: number;
      excluded: number;
      needsReview: number;
      identityConflict: number;
    };
    eligibleForApply: boolean;
  };
  payload: ImportEventAttendeesCallablePayload;
}
