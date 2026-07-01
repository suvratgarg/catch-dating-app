export const websiteQueryKeys = {
  all: ["website"] as const,
  claims: {
    lookup: (listingId: string | null) =>
      [...websiteQueryKeys.all, "claims", "lookup", listingId ?? "none"] as const,
  },
  hostApplications: {
    submit: () => [...websiteQueryKeys.all, "host-applications", "submit"] as const,
  },
  reviews: {
    listing: (clubId: string) =>
      [...websiteQueryKeys.all, "reviews", "listing", clubId] as const,
  },
};
