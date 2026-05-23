/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Callable payload accepted by updateClub.
 */
export interface UpdateClubCallablePayload {
  clubId: string;
  fields: {
    name?: string;
    description?: string;
    location?: string | null;
    area?: string;
    hostName?: string;
    hostAvatarUrl?: string | null;
    imageUrl?: string | null;
    profileImageUrl?: string | null;
    /**
     * @maxItems 12
     */
    tags?: string[];
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
        structureConfig?: {
          unitKind: "wholeGroup" | "pods" | "pairs" | "teams" | "tables";
          unitSize: number;
          unitCount?: number | null;
          rotationIntervalMinutes?: number | null;
          revealCountdownSeconds: number;
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
          structureConfig?: {
            unitKind: "wholeGroup" | "pods" | "pairs" | "teams" | "tables";
            unitSize: number;
            unitCount?: number | null;
            rotationIntervalMinutes?: number | null;
            revealCountdownSeconds: number;
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
  };
}
