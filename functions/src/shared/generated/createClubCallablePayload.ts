/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

import {UploadedPhoto} from "./uploadedPhoto";

/**
 * Callable payload accepted by createClub.
 */
export interface CreateClubCallablePayload {
  clubId?: string;
  name: string;
  description: string;
  location: string;
  area: string;
  /**
   * Canonical organizer classification. Club is one organizer subtype; missing legacy values normalize to club during migration.
   */
  organizerType?:
    | "club"
    | "community"
    | "individual"
    | "eventProducer"
    | "venue"
    | "brand";
  imageUrl?: string | null;
  profileImageUrl?: string | null;
  /**
   * @maxItems 12
   */
  clubPhotos?: UploadedPhoto[];
  logoPhoto?: UploadedPhoto | null;
  instagramHandle?: string | null;
  phoneNumber?: string | null;
  email?: string | null;
  hostDefaults?: {
    primaryActivityKind?:
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
    /**
     * @maxItems 16
     */
    supportedActivityKinds?: (
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
      | "openActivity"
    )[];
    eventPolicy?: {
      admissionPreset?:
        | "openCapacity"
        | "inviteOnly"
        | "balancedSingles"
        | "fixedCohortCaps";
      minAge?: number;
      maxAge?: number;
      maxMen?: number | null;
      maxWomen?: number | null;
      dynamicPricingEnabled?: boolean;
      dynamicPricingStepInPaise?: number | null;
      dynamicPricingMaxInPaise?: number | null;
      cancellationPolicyId?: "flexible" | "standard" | "strict";
    };
    eventSuccess?: {
      enabled?: boolean;
      playbookId?: string;
      /**
       * @maxItems 24
       */
      selectedModuleIds?: string[];
      moduleSelectionConfigured?: boolean;
      structureConfig?: {
        unitKind: "wholeGroup" | "pods" | "pairs" | "teams" | "tables";
        unitSize: number;
        unitCount?: number | null;
        rotationIntervalMinutes?: number | null;
        revealCountdownSeconds: number;
        rotationRepeatStrategy?: "avoid" | "allowWhenExhausted";
        maxPairMeetings?: number;
        /**
         * @maxItems 8
         */
        balanceActivityAttributes?: ("paceBand" | "skillBand" | "roleBand")[];
        /**
         * @maxItems 8
         */
        clusterActivityAttributes?: ("paceBand" | "skillBand" | "roleBand")[];
      };
      hostGoal?: string;
      wingmanRequestsEnabled?: boolean;
      contextualOpenersEnabled?: boolean;
      compatibilityAffectsRanking?: boolean;
      questionnaireConfig?: {
        templateId: string;
        customTitle?: string | null;
        /**
         * @maxItems 8
         */
        customQuestions?: {
          id: string;
          prompt: string;
          /**
           * @minItems 2
           * @maxItems 5
           */
          options: {
            id: string;
            label: string;
          }[];
        }[];
      };
      attendeePrompt?: string | null;
    };
    eventSuccessByActivityKind?: {
      [k: string]: {
        enabled?: boolean;
        playbookId?: string;
        /**
         * @maxItems 24
         */
        selectedModuleIds?: string[];
        moduleSelectionConfigured?: boolean;
        structureConfig?: {
          unitKind: "wholeGroup" | "pods" | "pairs" | "teams" | "tables";
          unitSize: number;
          unitCount?: number | null;
          rotationIntervalMinutes?: number | null;
          revealCountdownSeconds: number;
          rotationRepeatStrategy?: "avoid" | "allowWhenExhausted";
          maxPairMeetings?: number;
          /**
           * @maxItems 8
           */
          balanceActivityAttributes?: ("paceBand" | "skillBand" | "roleBand")[];
          /**
           * @maxItems 8
           */
          clusterActivityAttributes?: ("paceBand" | "skillBand" | "roleBand")[];
        };
        hostGoal?: string;
        wingmanRequestsEnabled?: boolean;
        contextualOpenersEnabled?: boolean;
        compatibilityAffectsRanking?: boolean;
        questionnaireConfig?: {
          templateId: string;
          customTitle?: string | null;
          /**
           * @maxItems 8
           */
          customQuestions?: {
            id: string;
            prompt: string;
            /**
             * @minItems 2
             * @maxItems 5
             */
            options: {
              id: string;
              label: string;
            }[];
          }[];
        };
        attendeePrompt?: string | null;
      };
    };
  };
}
