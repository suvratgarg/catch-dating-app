/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/generate_schema_contracts.mjs

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
    /**
     * @maxItems 12
     */
    tags?: string[];
    instagramHandle?: string | null;
    phoneNumber?: string | null;
    email?: string | null;
    hostDefaults?: {
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
        hostGoal?: string;
        privateCrushEnabled?: boolean;
        contextualOpenersEnabled?: boolean;
        attendeePrompt?: string | null;
      };
    };
  };
}
