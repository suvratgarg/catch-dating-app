export const websiteTemplates = {
  listingOwnerPending: (name: string) => `${name} is waiting for owner approval.`,
  listingHasOwner: (name: string) => `${name} already has owner context.`,
  listingClaimUnavailable: (name: string) => `${name} is not accepting owner requests yet.`,
  hostPacketReceived: (organizationName: string) =>
    `Catch has the operating packet for ${organizationName || "your host profile"}.`,
  playbookStageBody: (sub: string, hostLine: string) => `${sub} — ${hostLine}`,
  organizerCardDetail: (category: string, city: string) => `${category} · ${city}`,
  listingProfileLabel: (name: string) => `${name} profile`,
  updatedLabel: (value: string) => `Updated ${value}`,
  ratingLabel: (value: number) => `${value.toFixed(1)} rating`,
  reviewCountLabel: (value: number) => `${value} reviews`,
  listingShareTitle: (name: string) => `${name} on Catch`,
} as const;
