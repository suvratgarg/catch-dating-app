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
  source: "website";
  submissionId: string;
  requestHash: string;
  waitlistId: string;
  status: "needs_identity_review" | "linked" | "dismissed";
  organizerId: string | null;
  evidenceStatus: "self_reported";
  fullName: string;
  email: string;
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
};
