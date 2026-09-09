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
      status: "open";
      receivedAt: number;
      category: "eventLogistics" | "accessibility" | "other";
      owner: "eventLead";
      sourceGeneration: string;
      handling: {
        revision: number;
        assigneeUid: string | null;
        updatedAt: number;
        resolution: null;
      };
      attendeeGeneration: string;
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
      status: "resolved";
      receivedAt: number;
      category: "eventLogistics" | "accessibility" | "other";
      owner: "eventLead";
      sourceGeneration: string;
      handling: {
        revision: number;
        assigneeUid: string | null;
        updatedAt: number;
        resolution: {
          outcome: "resolved" | "declined";
          actorUid: string;
          at: number;
        };
      };
      attendeeGeneration: string;
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
      status: "open";
      receivedAt: number;
      category: "comfortSafety";
      owner: "authorizedSafetyOperator";
      sourceGeneration: string;
      handling: {
        revision: number;
        assigneeUid: string | null;
        updatedAt: number;
        resolution: null;
      };
      attendeeGeneration: string;
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
      status: "resolved";
      receivedAt: number;
      category: "comfortSafety";
      owner: "authorizedSafetyOperator";
      sourceGeneration: string;
      handling: {
        revision: number;
        assigneeUid: string | null;
        updatedAt: number;
        resolution: {
          outcome: "resolved" | "declined";
          actorUid: string;
          at: number;
        };
      };
      attendeeGeneration: string;
    };
