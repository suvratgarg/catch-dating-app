import type {HostListing} from "../features/organizers/types";

export type PageKey = "home" | "host" | "organizers" | "listing" | "claim";

export interface PageMeta {
  title: string;
  description: string;
  canonicalPath: string;
  twitterDescription: string;
  robots?: string;
}

export const pageMeta: Record<Exclude<PageKey, "listing">, PageMeta> = {
  home: {
    title: "Catch | The event before the match",
    description:
      "Catch turns curated singles events into real dating context. Choose a hosted event, show up, catch privately, and match with people you actually met.",
    canonicalPath: "/",
    twitterDescription: "Curated singles events become real dating context.",
  },
  host: {
    title: "Catch for Hosts | Host better singles events",
    description:
      "Catch helps hosts publish curated singles events, manage admission and waitlists, run live facilitation, and turn real attendance into post-event connections.",
    canonicalPath: "/host/",
    twitterDescription:
      "Event setup, admission, waitlists, live facilitation, check-in, and aggregate post-event reporting for hosts.",
  },
  organizers: {
    title: "Organizer Search | Catch",
    description:
      "Search Catch organizer profiles by name, city, format, and review signal.",
    canonicalPath: "/organizers/",
    twitterDescription: "Search Catch organizer and club profiles.",
    robots: "noindex, follow",
  },
  claim: {
    title: "Claim your organizer listing | Catch",
    description:
      "Find an unclaimed organizer profile, verify ownership, and request access to Catch host tools.",
    canonicalPath: "/claim/",
    twitterDescription: "Claim an organizer profile and unlock Catch host tools.",
    robots: "noindex, follow",
  },
};

export function pageMetaForListing(
  listing: HostListing,
  options: {noindexOverride?: boolean} = {}
): PageMeta {
  return {
    title: `${listing.name} | ${listing.city} organizer profile | Catch`,
    description: listing.description,
    canonicalPath: listing.path,
    twitterDescription: listing.sourceSummary,
    robots: options.noindexOverride ? "noindex, follow" : listing.indexing,
  };
}

export function getPageKey(pathname: string = window.location.pathname): Exclude<PageKey, "listing"> {
  if (pathname.startsWith("/claim")) return "claim";
  if (pathname.startsWith("/host")) return "host";
  if (pathname.startsWith("/organizers")) return "organizers";
  return "home";
}

export function pageClassFor(page: PageKey) {
  if (page === "host") return "host-page";
  if (page === "listing") return "listing-page";
  if (page === "organizers") return "organizers-page";
  if (page === "claim") return "claim-page";
  return "home-page";
}
