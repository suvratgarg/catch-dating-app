export type MarketingRouteId =
  | "home"
  | "host"
  | "organizer_search"
  | "organizer_listing"
  | "claim"
  | "claim_lookup"
  | "not_found";

export interface MarketingRouteDefinition {
  id: MarketingRouteId;
  path: string;
}

export const marketingRouteDefinitions = [
  {id: "home", path: "/"},
  {id: "host", path: "/host/*"},
  {id: "organizer_search", path: "/organizers"},
  {id: "organizer_listing", path: "/organizers/*"},
  {id: "claim", path: "/claim"},
  {id: "claim_lookup", path: "/claim/:listing"},
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
