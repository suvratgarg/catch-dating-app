/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export interface EventAssistanceOperationalNoticePublicationDocument {
  schemaVersion: 1;
  publicationId: string;
  quotaId: string;
  context:
    | {
        mode: "live";
        eventId: string;
        organizerId: string;
      }
    | {
        mode: "rehearsal";
        rehearsalId: string;
        virtualEventId: string;
        clockId: string;
      };
  eventId: string;
  attendeeId: string;
  episodeId: string;
  sourceKind: "planChange" | "followUp";
  workflowKind: "planChangeCommunication" | "postEventFollowUp";
  sourceId: string;
  sourceRevision: number;
  messageId: string;
  threadId: string;
  ordinal: number;
  contentHash: string;
  intentHash: string;
  sourceOccurredAt: number;
  createdAt: number;
}
