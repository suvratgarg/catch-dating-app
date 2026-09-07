/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export type EventAssistanceRuntimeConfigDocument =
  | {
      schemaVersion: 1;
      runtimeId: string;
      context: {
        mode: "live";
        eventId: string;
        organizerId: string;
      };
      workflowKind: "lateJoin";
      revision: number;
      status: "enabled";
      configuration: {
        options: {
          /**
           * @minItems 1
           * @maxItems 3
           */
          routes: (
            | {
                routeId: "catchEventSms";
                senderId: string;
              }
            | {
                routeId: "organizerEventWhatsapp";
                senderId: string;
              }
            | {
                routeId: "catchEventRcs";
              }
          )[];
          responseDeadline: number | null;
          deliveryPolicy: {
            maxAttempts: number;
            maxAttemptsPerRoute: number;
            minimumRetrySeconds: number;
          };
          /**
           * @maxItems 17
           */
          laterChoices?: {
            label: string;
            target:
              | {
                  kind: "fixedPlace";
                  placeId: string;
                  lateEntry: "allowed" | "hostDecision" | "closed";
                }
              | {
                  kind: "itineraryStop";
                  itineraryId: string;
                  stopId: string;
                }
              | {
                  kind: "groupCheckpoint";
                  routeId: string;
                  groupId: string;
                  checkpointId: string;
                };
          }[];
        };
        expiresAt: number;
        maxEvaluations: number;
      };
      sourceHash: string;
      sourceGeneration: string;
      updatedBy: string;
      createdAt: number;
      updatedAt: number;
    }
  | {
      schemaVersion: 1;
      runtimeId: string;
      context: {
        mode: "live";
        eventId: string;
        organizerId: string;
      };
      workflowKind: "lateJoin";
      revision: number;
      status: "paused";
      configuration: {
        options: {
          /**
           * @minItems 1
           * @maxItems 3
           */
          routes: (
            | {
                routeId: "catchEventSms";
                senderId: string;
              }
            | {
                routeId: "organizerEventWhatsapp";
                senderId: string;
              }
            | {
                routeId: "catchEventRcs";
              }
          )[];
          responseDeadline: number | null;
          deliveryPolicy: {
            maxAttempts: number;
            maxAttemptsPerRoute: number;
            minimumRetrySeconds: number;
          };
          /**
           * @maxItems 17
           */
          laterChoices?: {
            label: string;
            target:
              | {
                  kind: "fixedPlace";
                  placeId: string;
                  lateEntry: "allowed" | "hostDecision" | "closed";
                }
              | {
                  kind: "itineraryStop";
                  itineraryId: string;
                  stopId: string;
                }
              | {
                  kind: "groupCheckpoint";
                  routeId: string;
                  groupId: string;
                  checkpointId: string;
                };
          }[];
        };
        expiresAt: number;
        maxEvaluations: number;
      } | null;
      sourceHash: string;
      sourceGeneration: string;
      updatedBy: string;
      createdAt: number;
      updatedAt: number;
    };
