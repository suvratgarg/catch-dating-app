/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Authenticated private lodging commands. Current authority comes from the session and canonical program documents, never this payload. Hotel desk may request only its scoped operational board/confirmation.
 */
export type ManageProgramLodgingCallablePayload =
  | {
      action: "readMembership";
      programId: string;
      guestId: string;
    }
  | {
      action: "decideMembership";
      programId: string;
      guestId: string;
      expectedRevision: number;
      /**
       * @maxItems 20
       */
      groupIds: string[];
    }
  | {
      action: "readSetup";
      programId: string;
    }
  | {
      action: "setup";
      programId: string;
      setup: {
        /**
         * @maxItems 500
         */
        demand: {
          guestId: string;
          startsAtMillis: number;
          endsAtMillis: number;
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
        groupParents: {
          id: string;
          /**
           * @maxItems 20
           */
          parentIds: string[];
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
        labels: {
          inventoryId: string;
          roomLabel: string | null;
        }[];
      };
      expectedConfigurationRevision: number;
      /**
       * @maxItems 200
       */
      adoptions: {
        stayId: string;
        partyId: string;
        inventoryId: string;
        expectedRevision: number;
      }[];
    }
  | {
      action: "preview";
      programId: string;
    }
  | {
      action: "propose";
      programId: string;
      /**
       * @maxItems 500
       */
      placements: {
        partyId: string;
        inventoryId: string;
      }[];
      expectedRevisions: {
        source: number;
        inventory: number;
        layout: number;
        published: number;
      };
    }
  | {
      action: "destinations";
      programId: string;
      /**
       * @maxItems 500
       */
      placements: {
        partyId: string;
        inventoryId: string;
      }[];
      expectedRevisions: {
        source: number;
        inventory: number;
        layout: number;
        published: number;
      };
      partyId: string;
    }
  | {
      action: "save";
      programId: string;
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
      action: "transition";
      programId: string;
      command: {
        proposalId: string;
        operationId: string;
        expectedWorkflowRevision: number;
        action: "approve" | "confirmHotel" | "publishGuests";
        hotelId: string | null;
      };
    }
  | {
      action: "hotelBoard";
      programId: string;
      hotelId: string;
    }
  | {
      action: "resolveDates";
      programId: string;
      arrival: string;
      departure: string;
    };
