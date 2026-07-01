export const adminQueryKeys = {
  all: ["admin"] as const,
  adminRoles: {
    assignments: (status: string) =>
      [...adminQueryKeys.all, "admin-roles", "assignments", status] as const,
  },
  dataQuality: {
    snapshot: () => [...adminQueryKeys.all, "data-quality", "snapshot"] as const,
  },
  events: {
    list: (query: string) => [...adminQueryKeys.all, "events", "list", query] as const,
    supplyReadiness: () => [...adminQueryKeys.all, "events", "supply-readiness"] as const,
  },
  finance: {
    overview: () => [...adminQueryKeys.all, "finance", "overview"] as const,
  },
  organizers: {
    list: (query: string) => [...adminQueryKeys.all, "organizers", "list", query] as const,
  },
  overview: {
    analytics: (range: string, mode: string) =>
      [...adminQueryKeys.all, "overview", "analytics", range, mode] as const,
  },
  users: {
    analytics: (userId: string) =>
      [...adminQueryKeys.all, "users", "analytics", userId] as const,
  },
};
