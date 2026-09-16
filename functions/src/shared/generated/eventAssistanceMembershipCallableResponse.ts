/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export interface EventAssistanceMembershipCallableResponse {
  outcome: "read" | "applied" | "replayed";
  operationRevision: number | null;
  view: {
    context: {
      mode: "live";
      eventId: string;
      organizerId: string;
    };
    attendeeId: string;
    sourceHash: string;
    serverTime: number;
    revision: number;
    episodeId: string | null;
    participationRevision: number;
    freshness: "uninitialized" | "current" | "sourceChanged";
    ready: boolean;
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
    transferState:
      | "none"
      | "pending"
      | "expired"
      | "sourceChanged"
      | "accepted"
      | "rejected"
      | "cancelled";
    /**
     * @maxItems 40
     */
    groups: {
      groupId: string;
      label: string;
    }[];
    /**
     * @maxItems 6
     */
    actions: ("place" | "propose" | "accept" | "reject" | "cancel" | "leave")[];
    /**
     * Bounded receiving-operator choices for the reviewed guest. Read evidence only; the command rechecks current target authority. Omitted when proposing is unavailable or an older server does not provide this projection.
     */
    handoverReview?: {
      expiresAt: number;
      /**
       * @maxItems 92
       */
      receivers: {
        operatorId: string;
        displayName: string | null;
        /**
         * @minItems 1
         * @maxItems 40
         */
        groups: {
          groupId: string;
          validUntil: number;
        }[];
      }[];
    };
  };
}
