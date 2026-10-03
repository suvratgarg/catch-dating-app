/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

import type {ProgramLodgingConfigDocument} from "./programLodgingConfigDocument";

/**
 * Strict role-specific lodging result. Coordinator context is private; hotelBoard contains only allowlisted operational fields.
 */
export type ManageProgramLodgingCallableResponse =
  | {
      kind: "readSetup";
      configuration: ProgramLodgingConfigDocument | null;
      accessExpiresAtMillis: number | null;
      catalog: {
        programId: string;
        organizerId: string;
        timezone: string;
        /**
         * @maxItems 500
         */
        guests: {
          id: string;
          label: string;
          householdId: string | null;
          /**
           * @maxItems 20
           */
          groupIds: string[];
        }[];
        /**
         * @maxItems 500
         */
        groups: {
          id: string;
          label: string;
        }[];
        /**
         * @maxItems 500
         */
        hotels: {
          id: string;
          label: string;
          active: boolean;
        }[];
        /**
         * @maxItems 500
         */
        contracts: {
          id: string;
          hotelId: string;
          label: string;
          roomType: string | null;
          totalRooms: number;
          maxOccupantsPerRoom: number;
          startsAtMillis: number;
          endsAtMillis: number;
        }[];
        /**
         * @maxItems 2000
         */
        activeStays: {
          id: string;
          guestId: string;
          hotelId: string;
          roomBlockId: string | null;
          roomLabel: string | null;
          roomOccupancyId: string | null;
          lodgingPartyId: string | null;
          lodgingInventoryId: string | null;
          startsAtMillis: number | null;
          endsAtMillis: number | null;
          status: "held" | "confirmed" | "checkedIn";
          revision: number;
        }[];
        calendarDates: {
          [k: string]: string;
        };
      };
    }
  | {
      kind: "setup";
      revision: number;
    }
  | {
      kind: "proposal";
      proposal: {
        scope: {
          programId: string;
          organizerId: string;
        };
        id: string;
        revisions: {
          source: number;
          inventory: number;
          layout: number;
          published: number;
        };
        /**
         * @maxItems 500
         */
        placements: {
          partyId: string;
          inventoryId: string;
        }[];
        /**
         * @maxItems 500
         */
        unplacedPartyIds: string[];
        /**
         * @maxItems 502
         */
        explanations: string[];
        /**
         * @minItems 5
         * @maxItems 5
         */
        score: number[];
        search: {
          complete: boolean;
          explored: number;
        };
      };
      context: {
        snapshot: {
          scope: {
            programId: string;
            organizerId: string;
          };
          revisions: {
            source: number;
            inventory: number;
            layout: number;
            published: number;
          };
          /**
           * @maxItems 500
           */
          guests: {
            id: string;
            arrival: string;
            departure: string;
            beds: number;
            /**
             * @maxItems 30
             */
            requiredFeatures: string[];
          }[];
          /**
           * @maxItems 500
           */
          parties: {
            id: string;
            /**
             * @minItems 1
             * @maxItems 100
             */
            guestIds: string[];
            confirmed: boolean;
            priority: number;
            requiredRoomType: string | null;
            pin: {
              inventoryId?: string;
              hotelId?: string;
              zoneId?: string;
            } | null;
          }[];
          /**
           * @maxItems 500
           */
          groups: {
            id: string;
            /**
             * @maxItems 20
             */
            parentIds: string[];
          }[];
          /**
           * @maxItems 10000
           */
          memberships: {
            guestId: string;
            groupId: string;
            included: boolean;
            authority: "canonical" | "manual" | "acceptedSuggestion";
            sourceId: string | null;
          }[];
          /**
           * @maxItems 500
           */
          rooms: {
            id: string;
            hotelId: string;
            zoneId: string;
            building: string | null;
            floor: string | null;
            wing: string | null;
            roomType: string;
            beds: number;
            maxOccupants: number;
            /**
             * @maxItems 30
             */
            verifiedFeatures: string[];
            /**
             * @minItems 1
             * @maxItems 100
             */
            resourceIds: string[];
            position: {
              x: number;
              y: number;
            } | null;
          }[];
          /**
           * @maxItems 500
           */
          contracts: {
            id: string;
            hotelId: string;
            arrival: string;
            departure: string;
            nightlyRoomQuota: number;
          }[];
          /**
           * @maxItems 500
           */
          inventory: {
            id: string;
            contractId: string;
            physicalRoomId: string | null;
            provisional: {
              hotelId: string;
              zoneId: string;
              building: string | null;
              floor: string | null;
              wing: string | null;
              roomType: string;
              beds: number;
              maxOccupants: number;
              /**
               * @maxItems 30
               */
              verifiedFeatures: string[];
            } | null;
            /**
             * @minItems 1
             * @maxItems 30
             */
            availability: {
              arrival: string;
              departure: string;
            }[];
          }[];
          /**
           * @maxItems 500
           */
          published: {
            partyId: string;
            inventoryId: string;
            locked: boolean;
            checkedIn: boolean;
          }[];
        };
        configuration: ProgramLodgingConfigDocument;
        labels: {
          guests: {
            [k: string]: string;
          };
          groups: {
            [k: string]: string;
          };
          hotels: {
            [k: string]: string;
          };
        };
        workflow: {
          revision: number;
          approvedProposalId: string | null;
          /**
           * @maxItems 500
           */
          confirmedHotelIds: string[];
          guestPublishedProposalId: string | null;
        };
        accessExpiresAtMillis: number | null;
      };
    }
  | {
      kind: "destinations";
      revisions: {
        source: number;
        inventory: number;
        layout: number;
        published: number;
      };
      /**
       * @maxItems 500
       */
      destinations: {
        inventoryId: string;
        allowed: boolean;
        explanation: string;
      }[];
    }
  | {
      kind: "saved";
      proposal: {
        scope: {
          programId: string;
          organizerId: string;
        };
        id: string;
        revisions: {
          source: number;
          inventory: number;
          layout: number;
          published: number;
        };
        /**
         * @maxItems 500
         */
        placements: {
          partyId: string;
          inventoryId: string;
        }[];
        /**
         * @maxItems 500
         */
        unplacedPartyIds: string[];
        /**
         * @maxItems 502
         */
        explanations: string[];
        /**
         * @minItems 5
         * @maxItems 5
         */
        score: number[];
        search: {
          complete: boolean;
          explored: number;
        };
      };
    }
  | {
      kind: "transition";
      workflow: {
        revision: number;
        approvedProposalId: string | null;
        /**
         * @maxItems 500
         */
        confirmedHotelIds: string[];
        guestPublishedProposalId: string | null;
      };
      receipt: {
        operationId: string;
        requestHash: string;
        actorUid: string;
        resultingRevision: number;
      };
      replayed: boolean;
    }
  | {
      kind: "hotelBoard";
      /**
       * @maxItems 500
       */
      rows: {
        partyId: string;
        inventoryId: string;
        physicalRoomId: string | null;
        zoneId: string;
        roomType: string;
        /**
         * @maxItems 100
         */
        guests: {
          guestId: string;
          arrival: string;
          departure: string;
        }[];
      }[];
    }
  | {
      kind: "resolvedDates";
      timezone: string;
      arrival: string;
      departure: string;
      startsAtMillis: number;
      endsAtMillis: number;
      accessExpiresAtMillis: number | null;
    };
