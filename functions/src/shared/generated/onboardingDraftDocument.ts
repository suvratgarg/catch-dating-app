/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/generate_schema_contracts.mjs

import {ProfilePromptAnswer} from "./profilePromptAnswer";

/**
 * Owner-private, intentionally extensible onboarding draft stored at onboarding_drafts/{uid}.
 */
export interface OnboardingDraftDocument {
  step: number;
  draftVersion?: number;
  firstName?: string;
  lastName?: string;
  dateOfBirth?: {
    _seconds: number;
    _nanoseconds: number;
  } | null;
  phoneNumber?: string;
  countryCode?: string;
  gender?: ("man" | "woman" | "nonBinary" | "other") | null;
  interestedInGenders?: ("man" | "woman" | "nonBinary" | "other")[];
  instagramHandle?: string | null;
  /**
   * @maxItems 3
   */
  profilePrompts?: ProfilePromptAnswer[];
  [k: string]: unknown;
}
