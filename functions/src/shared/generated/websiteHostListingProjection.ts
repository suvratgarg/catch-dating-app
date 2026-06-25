/* eslint-disable */
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: node tool/contracts/generate_schema_contracts.mjs

/**
 * Public organizer listing projection consumed by the marketing website and future shared web/app listing surfaces. It is generated from approved organizer, seed, or demo data and is not the canonical club document.
 */
export interface WebsiteHostListingProjection {
  id: string;
  listingVariant: "unclaimedScraped" | "appCreatedClub";
  dataOrigin: "scrapedSeed" | "catchDemo" | "organizerIntake";
  name: string;
  slug: string;
  city: string;
  citySlug: string;
  region: string;
  country: string;
  path: string;
  legacyPaths?: string[];
  category: string;
  status: string;
  indexing: "index, follow" | "noindex, follow";
  sourceConfidence: "first_party" | "high" | "medium" | "low";
  headline: string;
  description: string;
  sourceSummary: string;
  logo: {
    mode: "monogram";
    text: string;
    status: string;
  };
  formats: string[];
  facts: {
    label: string;
    value: string;
  }[];
  metrics?: {
    memberCount?: number;
    rating?: number;
    reviewCount?: number;
    nextEventAt?: string | null;
    nextEventLabel?: string | null;
  };
  host?: {
    name: string;
    role: string;
    avatarUrl: string | null;
  };
  catchEvents?: {
    id: string;
    role: string;
    title: string;
    activityKind: string;
    timeline: "upcoming" | "past";
    startTime: string;
    endTime: string;
    date: string;
    location: string;
    summary: string;
    capacityLimit: number;
    bookedCount: number;
    checkedInCount: number;
    waitlistedCount: number;
    priceLabel: string;
    scorecard?: {
      [k: string]: unknown;
    } | null;
  }[];
  externalEvents?: {
    id: string;
    title: string;
    activityKind: string;
    availability: "read_only_external";
    startTime: string;
    endTime: string | null;
    date: string;
    location: string;
    summary: string;
    priceLabel: string;
    sourceLabel: string;
    sourceHref: string;
    externalLinkCount: number;
    dedupeKey: string;
  }[];
  eventSuccessSummary?: {
    bookedCount: number;
    checkedInCount: number;
    mutualMatchCount: number;
    chatStartedCount: number;
    catchSentCount: number;
    safetyIncidentCount: number;
  } | null;
  eventEvidence: {
    title: string;
    date: string;
    location: string;
    summary: string;
    facts: string[];
    sourceLabel: string;
    sourceHref: string;
  }[];
  reviews: {
    id: string | null;
    reviewerName: string;
    rating: number;
    comment: string;
    createdAt: string;
    verificationStatus: "verified" | "unverified";
    source: "catchEvent" | "publicListing";
    isAnonymous: boolean;
    ownerResponse: {
      hostName: string;
      hostAvatarUrl: string | null;
      message: string;
      updatedAt: string;
    } | null;
  }[];
  fitNotes: string[];
  missingEvidence: string[];
  sources: {
    type: string;
    label: string;
    detail: string;
    href?: string;
    confidence: "high" | "medium" | "low";
  }[];
  claim: {
    href: string;
    label: string;
  };
  publicApi: {
    state: "enabled" | "disabled";
    reason: string;
    claimTargetSyncStatus:
      | "in_sync"
      | "write_needed"
      | "static_fixture"
      | "unknown";
  };
  lastVerifiedAt: string;
  searchText: string;
}
