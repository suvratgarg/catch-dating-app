/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export type EventAssistanceGuestViewCallableResponse =
  | {
      status: "unavailable";
      serverTime: number;
      reason:
        | "expired"
        | "eventClosed"
        | "guestUnavailable"
        | "noInstructions"
        | "alreadyJoined";
    }
  | {
      status: "ready";
      serverTime: number;
      eventTitle: string;
      guestRevision: number;
      intentId: string;
      intentRevision: number;
      instructionRevision: number;
      title: string;
      text: string;
      expiresAt: number;
      response: {
        label: string;
        receivedAt: number;
      } | null;
      /**
       * @maxItems 20
       */
      choices: {
        choiceId: string;
        label: string;
      }[];
    };
