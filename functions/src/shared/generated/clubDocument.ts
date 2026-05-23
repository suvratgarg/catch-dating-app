/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Canonical club document stored at clubs/{clubId}. The club id is the document id and is not stored in document data.
 */
export interface ClubDocument {
  name: string;
  description: string;
  location: string | null;
  area: string;
  hostUserId: string;
  hostName: string;
  hostAvatarUrl: string | null;
  ownerUserId: string;
  /**
   * @minItems 1
   * @maxItems 20
   */
  hostUserIds: string[];
  /**
   * @minItems 1
   * @maxItems 20
   */
  hostProfiles: {
    uid: string;
    displayName: string;
    avatarUrl: string | null;
    role: "owner" | "host";
  }[];
  /**
   * Serialized Firestore Timestamp fixture shape.
   */
  createdAt: {
    _seconds: number;
    _nanoseconds: number;
  };
  imageUrl: string | null;
  profileImageUrl: string | null;
  /**
   * @maxItems 20
   */
  tags: string[];
  memberCount: number;
  rating: number;
  reviewCount: number;
  nextEventAt: {
    _seconds: number;
    _nanoseconds: number;
  } | null;
  nextEventLabel: string | null;
  instagramHandle: string | null;
  phoneNumber: string | null;
  email: string | null;
  status: "active" | "archived";
  archived: boolean;
  archivedAt: {
    _seconds: number;
    _nanoseconds: number;
  } | null;
  archiveReason: string | null;
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
  /**
   * Internal demo seed marker used for cleanup and diagnostics.
   */
  synthetic?: boolean;
  /**
   * Internal demo seed prefix used for cleanup and diagnostics.
   */
  seedPrefix?: string;
  /**
   * Internal demo seed scenario name used for cleanup and diagnostics.
   */
  scenario?: string;
  /**
   * Internal demo-operations marker used for cleanup and diagnostics.
   */
  demoOps?: boolean;
  /**
   * Internal demo-operations id used for cleanup and diagnostics.
   */
  demoOpsId?: string;
  /**
   * Internal demo-operations command name used for cleanup and diagnostics.
   */
  demoOpsCommand?: string;
}
