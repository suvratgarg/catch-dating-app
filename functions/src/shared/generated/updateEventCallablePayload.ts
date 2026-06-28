/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

import {UploadedPhoto} from "./uploadedPhoto";

/**
 * Callable payload accepted by updateEvent.
 */
export interface UpdateEventCallablePayload {
  eventId: string;
  fields: {
    startTimeMillis?: number;
    endTimeMillis?: number;
    meetingPoint?: string;
    /**
     * Canonical meeting location selected from Google Places or a manually pinned map coordinate.
     */
    meetingLocation?: {
      name: string;
      address?: string | null;
      placeId?: string | null;
      latitude: number;
      longitude: number;
      notes?: string | null;
    };
    startingPointLat?: (number | null) | null;
    startingPointLng?: (number | null) | null;
    locationDetails?: string | null;
    photoUrl?: string | null;
    /**
     * @maxItems 12
     */
    eventPhotos?: UploadedPhoto[];
    distanceKm?: number;
    pace?: "easy" | "moderate" | "fast" | "competitive";
    description?: string;
    capacityLimit?: number;
    priceInPaise?: number;
    constraints?: {
      minAge?: number;
      maxAge?: number;
      maxMen?: number | null;
      maxWomen?: number | null;
    };
    eventPolicy?: {
      version: 1;
      admission: {
        format:
          | "open"
          | "inviteOnly"
          | "manualApproval"
          | "fixedCohortCaps"
          | "balancedRatio"
          | "membersOnly";
        capacityLimit: number;
        waitlistPolicy: {
          mode:
            | "disabled"
            | "rankedOffer"
            | "broadcastFirstComeFirstServed"
            | "manualReview";
          offerWindowMinutes: number;
        };
        inviteRequired: boolean;
        membershipRequired: boolean;
        manualApprovalRequired: boolean;
        privateAccessPolicy: {
          mode: "none" | "inviteCode";
          inviteCodeHint: string | null;
          privateLinkEnabled: boolean;
        };
        cohortCapacityLimits: {
          [k: string]: number;
        };
        balancedRatioPolicy: {
          leftCohortId: string;
          rightCohortId: string;
          maxSkew: number;
          openingBufferPerCohort: number;
          outOfRatioCohortPolicy:
            | "admitWithinGeneralCapacity"
            | "waitlist"
            | "manualReview"
            | "reject";
        } | null;
      };
      pricing: {
        basePriceInPaise: number;
        cohortAdjustmentsInPaise: {
          [k: string]: number;
        };
        /**
         * @maxItems 20
         */
        demandPricingRules: {
          pricedCohortId: string;
          balancingCohortId: string;
          stepAdjustmentInPaise: number;
          maxAdjustmentInPaise: number;
          freeSkew: number;
          demandStep: number;
        }[];
      };
      cancellation: {
        policyId: "flexible" | "standard" | "strict";
      };
      settlement: {
        hostPayoutTiming: "afterEventCompletion";
      };
    };
    privateAccess?: {
      inviteCode?: string | null;
    };
  };
}
