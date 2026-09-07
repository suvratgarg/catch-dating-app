/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export type EventAssistanceCaseDocument =
  | {
      schemaVersion: 1;
      caseId: string;
      guestId: string;
      context: {
        mode: "live";
        eventId: string;
        organizerId: string;
      };
      attendeeId: string;
      episodeId: string;
      responseId: string;
      messageId: string;
      status: "open" | "resolved";
      receivedAt: number;
      category: "eventLogistics" | "accessibility" | "other";
      owner: "eventLead";
    }
  | {
      schemaVersion: 1;
      caseId: string;
      guestId: string;
      context: {
        mode: "live";
        eventId: string;
        organizerId: string;
      };
      attendeeId: string;
      episodeId: string;
      responseId: string;
      messageId: string;
      status: "open" | "resolved";
      receivedAt: number;
      category: "comfortSafety";
      owner: "authorizedSafetyOperator";
    };
