/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Shared aggregate analytics response returned by host and admin analytics callables. Values are aggregate-only and host-safe.
 */
export interface HostAnalyticsCallableResponse {
  generatedAt: string;
  timezone: string;
  range: {
    startDate: string;
    endDate: string;
    granularity: "day" | "week" | "month";
    preset?: string | null;
  };
  scope: {
    clubIds: string[];
    eventIds: string[];
    clubName?: string | null;
    eventTitle?: string | null;
  };
  summaryCards: {
    id: string;
    label: string;
    value: number;
    unit: "count" | "percent" | "money_minor" | "rating";
    status: "ready" | "partial" | "missing";
    caption?: string | null;
  }[];
  trend: {
    periodStart: string;
    periodEnd: string;
    metrics: {
      [k: string]: number;
    };
  }[];
  /**
   * @maxItems 25
   */
  topEvents: {
    eventId: string;
    clubId: string;
    title: string;
    startTime: string;
    status: string;
    capacityLimit: number;
    bookedCount: number;
    checkedInCount: number;
    waitlistedCount: number;
    fillRate: number;
    checkInRate: number;
    grossRevenueMinor: number;
    currency: string;
    checkoutStartedCount: number;
    checkoutDropoffCount: number;
    paymentCompletedCount: number;
    paymentFailedCount: number;
    paymentRefundedCount: number;
    reviewCount: number;
    averageRating: number;
    demandCount: number;
    inviteOpenCount: number;
    mutualMatchCount: number;
    chatStartedCount: number;
    repeatAttendeeCount: number;
  }[];
  reviewSummary: {
    newReviews: number;
    publishedReviews: number;
    verifiedReviews: number;
    publicReviews: number;
    ownerResponseCount: number;
    averageRating: number;
  };
  discoverySummary: {
    listingViews: number;
    searchAppearances: number;
    eventViews: number;
    organizerSaves: number;
    eventSaves: number;
    contactClicks: number;
    claimClicks: number;
    outboundClicks: number;
  };
  dataQuality: {
    id: string;
    state: "ok" | "partial" | "missing";
    detail: string;
    owner: string;
    runbook: string;
    nextAction: string;
  }[];
}
