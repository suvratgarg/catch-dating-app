export const adminQueryKeys = {
  all: ["admin"] as const,
  adminRoles: {
    assignments: (status: string) =>
      [...adminQueryKeys.all, "admin-roles", "assignments", status] as const,
    user: (targetUid: string) =>
      [...adminQueryKeys.all, "admin-roles", "user", targetUid] as const,
  },
  access: {
    applications: () =>
      [...adminQueryKeys.all, "access", "applications"] as const,
    detail: (applicationUid: string) =>
      [...adminQueryKeys.all, "access", "detail", applicationUid] as const,
  },
  dataQuality: {
    snapshot: () => [...adminQueryKeys.all, "data-quality", "snapshot"] as const,
  },
  events: {
    list: (payloadKey: string) =>
      [...adminQueryKeys.all, "events", "list", payloadKey] as const,
    externalList: (payloadKey: string) =>
      [...adminQueryKeys.all, "events", "external-list", payloadKey] as const,
    detail: (eventId: string) =>
      [...adminQueryKeys.all, "events", "detail", eventId] as const,
    supplyReadiness: () => [...adminQueryKeys.all, "events", "supply-readiness"] as const,
  },
  eventIntake: {
    dashboardBridge: () =>
      [...adminQueryKeys.all, "event-intake", "dashboard-bridge"] as const,
    decision: () => [...adminQueryKeys.all, "event-intake", "decision"] as const,
  },
  finance: {
    overview: () => [...adminQueryKeys.all, "finance", "overview"] as const,
  },
  growth: {
    kpis: (rangePreset: string, granularity: string) =>
      [...adminQueryKeys.all, "growth", "kpis", rangePreset, granularity] as const,
  },
  marketing: {
    opsBridge: () => [...adminQueryKeys.all, "marketing", "ops-bridge"] as const,
    createDraft: () => [...adminQueryKeys.all, "marketing", "create-draft"] as const,
    decision: () => [...adminQueryKeys.all, "marketing", "decision"] as const,
  },
  organizerIntake: {
    curation: () => [...adminQueryKeys.all, "organizer-intake", "curation"] as const,
    decision: () => [...adminQueryKeys.all, "organizer-intake", "decision"] as const,
    eventDecision: () =>
      [...adminQueryKeys.all, "organizer-intake", "event-decision"] as const,
    locationResolution: () =>
      [...adminQueryKeys.all, "organizer-intake", "location-resolution"] as const,
    policyDecision: () =>
      [...adminQueryKeys.all, "organizer-intake", "policy-decision"] as const,
  },
  organizers: {
    list: (query: string) => [...adminQueryKeys.all, "organizers", "list", query] as const,
    detail: (clubId: string) =>
      [...adminQueryKeys.all, "organizers", "detail", clubId] as const,
  },
  overview: {
    snapshot: (mode: string) =>
      [...adminQueryKeys.all, "overview", "snapshot", mode] as const,
    analytics: (payloadKey: string, mode: string, access: string) =>
      [...adminQueryKeys.all, "overview", "analytics", mode, access, payloadKey] as const,
  },
  safety: {
    queue: () => [...adminQueryKeys.all, "safety", "queue"] as const,
    detail: (targetPath: string) =>
      [...adminQueryKeys.all, "safety", "detail", targetPath] as const,
  },
  users: {
    analytics: (payloadKey: string) =>
      [...adminQueryKeys.all, "users", "analytics", payloadKey] as const,
  },
};
