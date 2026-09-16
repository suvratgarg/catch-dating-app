/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export interface EventAssistanceOperationalNoticeQuotaDocument {
  schemaVersion: 1;
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
  attendeeGeneration: string;
  sourceGeneration: string;
  workflowKind: "planChangeCommunication" | "postEventFollowUp";
  count: number;
  revision: number;
  createdAt: number;
  updatedAt: number;
}
