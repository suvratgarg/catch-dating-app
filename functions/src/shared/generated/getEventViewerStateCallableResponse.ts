/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Current eligibility is separate from retained payment, admission and attendance evidence. Observation only; final mutations revalidate authority.
 */
export interface GetEventViewerStateCallableResponse {
  viewer: {
    eventId: string;
    organizerId: string;
    observedAtMillis: number;
    membership: {
      state: "notRequired" | "none" | "active" | "revoked" | "unavailable";
      revision: number | null;
      decisionId: string | null;
    };
    review: "none" | "pending" | "approved";
    admission: "none" | "nativeParticipation" | "publicPaidRoster";
    attendance: "notRecorded" | "attended";
    waitlisted: boolean;
    payment:
      | "notRead"
      | "creatingOrder"
      | "orderUnknown"
      | "checkoutReady"
      | "verifying"
      | "captured"
      | "admitted"
      | "expired"
      | "refundPending"
      | "refunded"
      | "reviewRequired"
      | "failed"
      | "cancelled";
    futureBooking:
      | {
          allowed: true;
          reason: null;
        }
      | {
          allowed: false;
          reason:
            | "membershipRequired"
            | "inviteRequired"
            | "reviewRequired"
            | "full"
            | "pairCapacityUnavailable"
            | "generalCapacityUnavailable"
            | "cohortCapacityUnavailable"
            | "outOfRatioReviewRequired"
            | "balanceUnavailable"
            | "bookingDetailsRequired"
            | "runPreferencesRequired"
            | "ageRestricted"
            | "scheduleConflict"
            | "eventUnavailable"
            | "past"
            | "cancelled"
            | "unsupportedRoute";
        };
    route: ("catchFreeBooking" | "catchCheckout" | "catchWaitlistOffer") | null;
    quotedPriceInPaise: number | null;
    basis: {
      policyHash: string | null;
      inventoryRevision: number | null;
      capacityRevision: number | null;
      migrationRevision: number | null;
    };
  };
}
