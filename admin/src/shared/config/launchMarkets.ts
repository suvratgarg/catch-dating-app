export const launchMarketIds = ["in-mh-mumbai", "in-mp-indore"] as const;
export const launchMarketSlugs = ["mumbai", "indore"] as const;

export const launchMarketIdSet = new Set<string>(launchMarketIds);
export const launchMarketSlugSet = new Set<string>(launchMarketSlugs);

export function isLaunchMarketId(value: string | null | undefined): boolean {
  return value != null && launchMarketIdSet.has(value);
}

export function isLaunchMarketSlug(value: string | null | undefined): boolean {
  return value != null && launchMarketSlugSet.has(value);
}
