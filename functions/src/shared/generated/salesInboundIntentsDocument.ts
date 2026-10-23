/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Private self-reported host submission, immutable at capture and linked only after identity review.
 */
export type SalesInboundIntentsDocument = {
  [k: string]: unknown;
} & {
  schemaVersion: 1;
  revision: number;
  classification: "sales_private";
  intentId: string;
  source: "website" | "partner";
  submissionId: string;
  requestHash: string;
  waitlistId: string;
  status: "needs_identity_review" | "linked" | "dismissed";
  organizerId: string | null;
  evidenceStatus: "self_reported";
  fullName: string;
  email: string | null;
  city: string;
  entryRoute: string | null;
  alreadyJoined: boolean;
  hostApplication: {
    organizationName?: string | null;
    organizationType?: string | null;
    operatingCity?: string | null;
    communityLink?: string | null;
    /**
     * @maxItems 10
     */
    formats?: string[];
    eventCadence?: string | null;
    nextEventName?: string | null;
    nextEventDate?: string | null;
    eventLocation?: string | null;
    expectedCapacity?: string | null;
    bookingPlatform?: string | null;
    guestListFormat?: string | null;
    priceRange?: string | null;
    admissionModel?: string | null;
    waitlistPlan?: string | null;
    paymentReadiness?: string | null;
    /**
     * @maxItems 16
     */
    eventSuccessModules?: string[];
    hostGoals?: string | null;
    operatingNotes?: string | null;
    eventPricing?: ("paid" | "free" | "mixed" | "undecided") | null;
  } | null;
  /**
   * Serialized Firestore Timestamp fixture shape.
   */
  createdAt: {
    _seconds: number;
    _nanoseconds: number;
  };
  /**
   * Serialized Firestore Timestamp fixture shape.
   */
  updatedAt: {
    _seconds: number;
    _nanoseconds: number;
  };
  /**
   * Serialized Firestore Timestamp fixture shape.
   */
  linkedAt?: {
    _seconds: number;
    _nanoseconds: number;
  };
  linkedBy?: string;
  linkRequestId?: string;
  partnerUid?: string;
  hostLead?: {
    eventId: string;
    isNew: boolean;
  };
  /**
   * Optional first-party campaign snapshot captured with the new Host receipt under current analytics permission. Erased on withdrawal or original-choice expiry; never used without a current consent/privacy check.
   */
  acquisitionAttribution?: {
    version: 1;
    consentId: string;
    acceptedAt: number;
    expiresAt: number;
    firstTouch: {
      capturedAt: number;
      landingPath:
        | "/host/"
        | "/host/overview/"
        | "/host/platform/"
        | "/host/planners/"
        | "/host/clubs/"
        | "/host/directory/"
        | "/claim/"
        | "/host/claim/"
        | "/host/apply/"
        | "/host/stack/"
        | "/host/workflows/";
      values: {
        utm_source?: "google" | "meta" | "newsletter" | "catch" | "partner";
        utm_medium?: "cpc" | "paid_social" | "email" | "organic" | "referral";
        utm_campaign?:
          | "launch"
          | "launch_2026"
          | "planner_launch"
          | "host_acquisition_2026"
          | "synthetic_launch";
        utm_content?:
          | "host_hero"
          | "host_footer"
          | "claim_cta"
          | "application_cta";
      };
    } | null;
    lastTouch: {
      capturedAt: number;
      landingPath:
        | "/host/"
        | "/host/overview/"
        | "/host/platform/"
        | "/host/planners/"
        | "/host/clubs/"
        | "/host/directory/"
        | "/claim/"
        | "/host/claim/"
        | "/host/apply/"
        | "/host/stack/"
        | "/host/workflows/";
      values: {
        utm_source?: "google" | "meta" | "newsletter" | "catch" | "partner";
        utm_medium?: "cpc" | "paid_social" | "email" | "organic" | "referral";
        utm_campaign?:
          | "launch"
          | "launch_2026"
          | "planner_launch"
          | "host_acquisition_2026"
          | "synthetic_launch";
        utm_content?:
          | "host_hero"
          | "host_footer"
          | "claim_cta"
          | "application_cta";
      };
    } | null;
  };
};
