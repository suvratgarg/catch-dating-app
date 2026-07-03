export const websiteQueryKeys = {
  all: ["website"] as const,
  claims: {
    all: () => [...websiteQueryKeys.all, "claims"] as const,
    lookup: (listingId: string | null) =>
      [...websiteQueryKeys.claims.all(), "lookup", listingId ?? "none"] as const,
    request: (listingId: string | null) =>
      [...websiteQueryKeys.claims.requests(), listingId ?? "none"] as const,
    requests: () => [...websiteQueryKeys.claims.all(), "requests"] as const,
  },
  hostApplications: {
    submit: () => [...websiteQueryKeys.all, "host-applications", "submit"] as const,
  },
  reviews: {
    listing: (clubId: string) =>
      [...websiteQueryKeys.all, "reviews", "listing", clubId] as const,
  },
  waitlist: {
    submit: (variant: string) =>
      [...websiteQueryKeys.all, "waitlist", "submit", variant] as const,
  },
};
