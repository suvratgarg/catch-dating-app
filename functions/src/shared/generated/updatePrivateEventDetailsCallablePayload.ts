/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

import type {UploadedPhoto} from "./uploadedPhoto";

export interface UpdatePrivateEventDetailsCallablePayload {
  organizerId: string;
  eventId: string;
  requestId: string;
  expectedSetupRevision: number;
  reviewedDefaultsHash: string;
  details: {
    durationMinutes?:
      | {
          mode: "set";
          value: number;
        }
      | {
          mode: "clear";
        }
      | {
          mode: "inherit";
        };
    venue?:
      | {
          mode: "set";
          value:
            | {
                name: string;
              }
            | {
                name: string;
                address?: string | null;
                placeId?: string | null;
                latitude: number;
                longitude: number;
                notes?: string | null;
              };
        }
      | {
          mode: "clear";
        }
      | {
          mode: "inherit";
        };
    eventFormat?:
      | {
          mode: "set";
          value: {
            version: 1;
            activityKind:
              | "socialRun"
              | "running"
              | "walking"
              | "pickleball"
              | "padel"
              | "tennis"
              | "badminton"
              | "cycling"
              | "spinClass"
              | "yoga"
              | "strengthTraining"
              | "pubQuiz"
              | "barCrawl"
              | "dinner"
              | "singlesMixer"
              | "openActivity";
            interactionModel:
              | "pacePods"
              | "pairedRotations"
              | "teamRotations"
              | "seatedTable"
              | "freeFormMixer"
              | "hostLedProgram"
              | "openFormat";
            customActivityLabel?: string;
            defaultPlaybookId?: string;
            /**
             * @maxItems 30
             */
            defaultModuleIds?: string[];
            /**
             * Optional event-success behavior primitives for custom or unsupported activity formats. These fields translate a saved event format into the small set of primitives event success can reason about.
             */
            eventSuccessPrimitives?: {
              phoneAvailability?:
                | "continuous"
                | "plannedPauses"
                | "arrivalAndPostEventOnly"
                | "hostOnlyLive"
                | "noneDuringActivity";
              rotationSuitability?:
                | "none"
                | "plannedBreaks"
                | "continuousRounds";
              assignmentAlgorithm?:
                | "none"
                | "pacePods"
                | "socialPods"
                | "pairRotations"
                | "teamBalancer"
                | "tableSeating";
              compatibilityPolicy?:
                | "none"
                | "socialCohortBalance"
                | "mutualInterestOnly"
                | "questionnaireClueOnly";
              matchingObjective?:
                | "coverage"
                | "romantic"
                | "affinity"
                | "novelty"
                | "balance"
                | "spread";
              unitOutcome?: "none" | "completion" | "score" | "rank";
              accountability?: "none" | "rollCall" | "sweep";
              durationShape?: "continuous" | "rounds" | "courses" | "segments";
            };
            activityDetails?: {
              /**
               * Composable operations for an event that moves through a route. Activity kind remains the broader format authority.
               */
              routePlan?: {
                version: 1 | 2;
                movementMode: "run" | "walk" | "ride" | "mixed";
                routeShape: "loop" | "outAndBack" | "pointToPoint";
                groupStrategy: "together" | "paceGroups" | "selfDirected";
                stopCadence: "continuous" | "flexibleStops" | "hostedStops";
                /**
                 * @minItems 1
                 * @maxItems 7
                 */
                stopKinds: (
                  | "water"
                  | "regroup"
                  | "venue"
                  | "photoSpot"
                  | "viewpoint"
                  | "hazard"
                  | "turnaround"
                )[];
                /**
                 * @minItems 1
                 * @maxItems 6
                 */
                roleKinds: (
                  | "routeLead"
                  | "sweep"
                  | "pacer"
                  | "stopHost"
                  | "marshal"
                  | "photographer"
                )[];
                /**
                 * @minItems 2
                 * @maxItems 500
                 */
                path?: {
                  latitude: number;
                  longitude: number;
                }[];
                /**
                 * @maxItems 12
                 */
                paceGroups?: {
                  id: string;
                  label: string;
                  targetPaceSecondsPerKm?: number | null;
                  sortOrder: number;
                }[];
                liveTrackingPolicy?: {
                  mode: "disabled" | "hostOnly" | "authorizedOperators";
                  staleAfterSeconds: number;
                  retentionMinutes: number;
                };
              };
              /**
               * Optional host-authored notes for public event pages. Blank notes are omitted.
               */
              publicDetails?: {
                requirements?: string;
                accessibility?: string;
                included?: string;
                [k: string]: unknown;
              };
              [k: string]: unknown;
            };
          };
        }
      | {
          mode: "clear";
        };
    description?: string;
    admissionTerms?: {
      capacityLimit: number;
      priceInPaise: number;
      currency: string;
      cancellationPolicyId:
        | "notApplicable"
        | "flexible"
        | "standard"
        | "strict";
    };
    distanceKm?: number;
    pace?: "easy" | "moderate" | "fast" | "competitive";
    /**
     * @maxItems 40
     */
    itinerary?: {
      id: string;
      kind: "gather" | "activity" | "stop" | "break" | "transition" | "finish";
      offsetMinutes: number;
      durationMinutes?: number | null;
      title: string;
      description?: string | null;
      location?: {
        name: string;
        address?: string | null;
        placeId?: string | null;
        latitude: number;
        longitude: number;
        notes?: string | null;
      } | null;
      routeDistanceMeters?: number | null;
    }[];
    eventPhotos?: UploadedPhoto[];
  };
}
