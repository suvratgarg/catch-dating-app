export type MarketingRouteId =
  | "sales_demo"
  | "home"
  | "host"
  | "host_overview"
  | "host_platform"
  | "host_planners"
  | "host_mixers"
  | "host_clubs"
  | "host_directory"
  | "host_claim"
  | "host_apply"
  | "host_stack"
  | "host_workflows"
  | "organizer_search"
  | "organizer_listing"
  | "event_detail"
  | "event_runtime"
  | "event_assistance"
  | "event_offer"
  | "event_booking"
  | "event_rehearsal"
  | "event_invite"
  | "household_rsvp"
  | "public_form"
  | "claim"
  | "claim_lookup"
  | "privacy"
  | "terms"
  | "help"
  | "not_found";

export interface MarketingRouteDefinition {
  id: MarketingRouteId;
  path: string;
}

export const marketingRouteDefinitions = [
  {id: "sales_demo", path: "/demo/:invitationId"},
  {id: "home", path: "/"},
  {id: "host", path: "/host/*"},
  {id: "host_overview", path: "/host/overview/"},
  {id: "host_platform", path: "/host/platform/"},
  {id: "host_planners", path: "/host/planners/"},
  {id: "host_mixers", path: "/host/mixers/"},
  {id: "host_clubs", path: "/host/clubs/"},
  {id: "host_directory", path: "/host/directory/"},
  {id: "host_claim", path: "/host/claim/"},
  {id: "host_apply", path: "/host/apply/"},
  {id: "host_stack", path: "/host/stack/"},
  {id: "host_workflows", path: "/host/workflows/"},

  {id: "organizer_search", path: "/organizers"},
  {id: "organizer_listing", path: "/organizers/*"},
  {id: "event_detail", path: "/events/:eventId"},
  {id: "event_runtime", path: "/join/:publicRuntimeId"},
  {id: "event_offer", path: "/offer"},
  {id: "event_booking", path: "/booking/:eventId"},
  {id: "event_assistance", path: "/event-update/:linkId"},
  {id: "event_rehearsal", path: "/rehearse/:publicRehearsalId"},
  {id: "event_invite", path: "/invite/:inviteToken"},
  {id: "household_rsvp", path: "/rsvp/:householdToken"},
  {id: "public_form", path: "/f/:publicFormId"},
  {id: "claim", path: "/claim"},
  {id: "claim_lookup", path: "/claim/:listing"},
  {id: "privacy", path: "/privacy/*"},
  {id: "terms", path: "/terms/*"},
  {id: "help", path: "/help/*"},
  {id: "not_found", path: "*"},
] as const satisfies readonly MarketingRouteDefinition[];

export const marketingRoutePaths = marketingRouteDefinitions.reduce(
  (paths, route) => ({
    ...paths,
    [route.id]: route.path,
  }),
  {} as Record<MarketingRouteId, string>
);

export function isOrganizerSearchPath(pathname: string) {
  return pathname === "/organizers" || pathname === "/organizers/";
}
