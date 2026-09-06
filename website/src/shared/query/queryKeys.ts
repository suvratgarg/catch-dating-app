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
  eventRuntime: {
    conversationGraph: (eventId: string | null) =>
      [...websiteQueryKeys.all, "event-runtime", "conversation-graph",
        eventId ?? "none"] as const,
  },
  eventAssistance: {
    guest: (instanceId: string) =>
      [...websiteQueryKeys.all, "event-assistance", "guest", instanceId] as const,
    reply: (instanceId: string) =>
      [...websiteQueryKeys.all, "event-assistance", "reply", instanceId] as const,
  },
  eventRehearsal: {
    guest: (publicRehearsalId: string) =>
      [...websiteQueryKeys.all, "event-rehearsal", "guest",
        publicRehearsalId] as const,
    action: (publicRehearsalId: string) =>
      [...websiteQueryKeys.all, "event-rehearsal", "action",
        publicRehearsalId] as const,
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
