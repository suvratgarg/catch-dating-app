export type MarketingRouteId =
  | "home"
  | "host"
  | "host_preview"
  | "organizer_search"
  | "organizer_listing"
  | "claim"
  | "claim_lookup"
  | "fallback";

export interface MarketingRouteDefinition {
  id: MarketingRouteId;
  path: string;
}

export const marketingRouteDefinitions = [
  {id: "home", path: "/"},
  {id: "host_preview", path: "/host/preview/*"},
  {id: "host", path: "/host/*"},
  {id: "organizer_search", path: "/organizers"},
  {id: "organizer_listing", path: "/organizers/*"},
  {id: "claim", path: "/claim"},
  {id: "claim_lookup", path: "/claim/:listing"},
  {id: "fallback", path: "*"},
] as const satisfies readonly MarketingRouteDefinition[];

export const marketingRoutePaths = marketingRouteDefinitions.reduce(
  (paths, route) => ({
    ...paths,
    [route.id]: route.path,
  }),
  {} as Record<MarketingRouteId, string>
);

export function isHostPreviewPath(pathname: string) {
  return pathname === "/host/preview" ||
    pathname.startsWith("/host/preview/");
}
