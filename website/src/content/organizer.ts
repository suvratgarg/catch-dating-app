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
  reviews: {
    unavailableLabel: "Reviews unavailable",
    unavailableTitle: "Public reviews are not available for this listing.",
    pendingAcknowledgement: "Review submitted for moderation.",
    runtimeUnavailable: "Review submission is unavailable in this website build.",
  },
} as const;
