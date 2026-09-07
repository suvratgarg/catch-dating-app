/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export interface EventAssistanceGuestDocument {
  schemaVersion: 1;
  guestId: string;
  context: {
    mode: "live";
    eventId: string;
    organizerId: string;
  };
  attendeeId: string;
  attendeeGeneration: string;
  episodeId: string;
  revision: number;
  lifecycle: "active" | "closed";
  intention:
    | {
        kind: "unknown";
      }
    | {
        kind: "onMyWay";
        claimedEta: number | null;
      }
    | {
        kind: "joinLater";
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
      }
    | {
        kind: "notComing";
      };
  createdAt: number;
  updatedAt: number;
}
