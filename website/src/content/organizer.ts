export const organizerListingCopy = {
  badges: {
    crawledUnclaimed: {compact: "Unclaimed", label: "Unclaimed listing"},
    sourceBacked: {compact: "Source-backed", label: "Source-backed listing"},
    claimPending: {compact: "In review", label: "Claim under review"},
    claimedUnverified: {compact: "Claimed", label: "Claimed"},
    firstParty: {compact: "Catch", label: "Catch organizer"},
    ownerVerified: {compact: "Verified", label: "Owner verified"},
    suppressed: {compact: "Unavailable", label: "Listing unavailable"},
    unknown: {compact: "Unknown", label: "Status unavailable"},
  },
  eventActions: {
    readOrganizerReviews: "Read organizer reviews",
  },
  claims: {
    runtimeUnavailable: "Claim submission needs the website Firebase/App Check config.",
  },
  detail: {
    aboutTitle: (name: string) => `About ${name}`,
    claimStateLabel: "Claim state",
    eventsEyebrow: "Events",
    formatsLabel: "What they do",
    freshnessLabel: "Freshness",
    organizerEyebrow: "Organizer",
    ownershipLabel: "Ownership",
    railAriaLabel: (name: string) => `${name} listing actions`,
    shareAction: "Share",
    sourceCountLabel: "Source count",
    sourcesEyebrow: "Sources",
    surfaceLabel: "Surface",
    viewEventsAction: "View events",
    viewSourcesAction: "View sources",
  },
  reviews: {
    unavailableLabel: "Reviews unavailable",
    unavailableTitle: "Public reviews are not available for this listing.",
    pendingAcknowledgement: "Review submitted for moderation.",
    runtimeUnavailable: "Review submission is unavailable in this website build.",
  },
} as const;

export interface OrganizerHeroMedia {
  alt: string;
  mobileSrcSet: string;
  src: string;
}

const organizerHeroMediaBySlug: Readonly<Record<string, OrganizerHeroMedia>> = {
  afterfly: {
    alt:
      "A social run moving past an outdoor music setup at golden hour; illustrative activity photography, not organizer-supplied media.",
    mobileSrcSet: "/assets/events/social-run-music-hero-960.jpg",
    src: "/assets/events/social-run-music-hero.jpg",
  },
};

const organizerAboutBySlug: Readonly<Record<string, string>> = {
  afterfly:
    "Indore social runs that blend movement, music and community. Public facts are sourced; owner copy is not yet verified.",
};

export function organizerAboutForSlug(slug: string, fallback: string) {
  return organizerAboutBySlug[slug] ?? fallback;
}

export function organizerHeroMediaForSlug(
  slug: string
): OrganizerHeroMedia | null {
  return organizerHeroMediaBySlug[slug] ?? null;
}
