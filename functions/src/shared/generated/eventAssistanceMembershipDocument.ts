/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export interface EventAssistanceMembershipDocument {
  schemaVersion: 1;
  membershipId: string;
  context: {
    mode: "live";
    eventId: string;
    organizerId: string;
  };
  attendeeId: string;
  sourceGeneration: string;
  attendeeGeneration: string;
  episodeId: string;
  revision: number;
  accepted: {
    groupId: string;
    groupSourceHash: string;
    responsibleOperatorId: string;
    acceptedAt: number;
  } | null;
  transfer:
    | (
        | {
            transferId: string;
            from: string | null;
            to: string;
            targetSourceHash: string;
            receivingOperatorId: string;
            requestedBy: string;
            requestedAt: number;
            expiresAt: number;
            status: "pending";
            resolvedAt: null;
            resolvedBy: null;
          }
        | {
            transferId: string;
            from: string | null;
            to: string;
            targetSourceHash: string;
            receivingOperatorId: string;
            requestedBy: string;
            requestedAt: number;
            expiresAt: number;
            status: "accepted" | "rejected" | "cancelled";
            resolvedAt: number;
            resolvedBy: string;
          }
      )
    | null;
  createdAt: number;
  updatedAt: number;
}
