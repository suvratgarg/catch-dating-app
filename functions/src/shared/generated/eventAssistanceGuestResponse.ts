/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

export type EventAssistanceGuestResponse =
  | {
      schemaVersion: 1;
      responseId: string;
      intentId: string;
      intentRevision: number;
      eventId: string;
      attendeeId: string;
      episodeId: string;
      choiceId: string;
      receivedAt: number;
      value:
        | {
            kind: "joinIntent";
            intention:
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
          }
        | {
            kind: "acknowledge";
            instructionRevision: number;
          }
        | {
            kind: "requestHelp";
            category:
              | "eventLogistics"
              | "accessibility"
              | "comfortSafety"
              | "other";
          };
      context: {
        mode: "live";
        eventId: string;
        organizerId: string;
      };
      source: {
        kind: "guestWeb";
        linkId: string;
      };
    }
  | {
      schemaVersion: 1;
      responseId: string;
      intentId: string;
      intentRevision: number;
      eventId: string;
      attendeeId: string;
      episodeId: string;
      choiceId: string;
      receivedAt: number;
      value:
        | {
            kind: "joinIntent";
            intention:
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
          }
        | {
            kind: "acknowledge";
            instructionRevision: number;
          }
        | {
            kind: "requestHelp";
            category:
              | "eventLogistics"
              | "accessibility"
              | "comfortSafety"
              | "other";
          };
      context: {
        mode: "live";
        eventId: string;
        organizerId: string;
      };
      source: {
        kind: "provider";
        attemptId: string;
        providerEventId: string;
      };
    }
  | {
      schemaVersion: 1;
      responseId: string;
      intentId: string;
      intentRevision: number;
      eventId: string;
      attendeeId: string;
      episodeId: string;
      choiceId: string;
      receivedAt: number;
      value:
        | {
            kind: "joinIntent";
            intention:
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
          }
        | {
            kind: "acknowledge";
            instructionRevision: number;
          }
        | {
            kind: "requestHelp";
            category:
              | "eventLogistics"
              | "accessibility"
              | "comfortSafety"
              | "other";
          };
      context: {
        mode: "rehearsal";
        rehearsalId: string;
        virtualEventId: string;
        clockId: string;
      };
      source: {
        kind: "simulation";
        actionId: string;
      };
    };
