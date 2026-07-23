import type {HostListing} from "../features/organizers/types";
import type {EventDetailRecord} from "../features/events/eventDetailModel";
import metaContent from "../content/meta.json";
import {interpolateContent} from "../content/interpolate";
import {validatedWebsiteMeta} from "../content/metaContract";

export type PageKey =
  | "home"
  | "host"
  | "organizers"
  | "listing"
  | "event_detail"
  | "claim"
  | "privacy"
  | "terms"
  | "help"
  | "not_found";

export interface PageMeta {
  title: string;
  description: string;
  canonicalPath: string;
  twitterDescription: string;
  robots?: string;
}

const websiteMeta = validatedWebsiteMeta(metaContent);

export const pageMeta: Record<Exclude<PageKey, "listing" | "event_detail">, PageMeta> =
  websiteMeta.routes;

export function pageMetaForListing(
  listing: HostListing,
  options: {noindexOverride?: boolean} = {}
): PageMeta {
  return {
    title: interpolateContent(websiteMeta.listing.titleTemplate, {
      name: listing.name,
      city: listing.city,
    }),
    description: listing.description,
    canonicalPath: listing.path,
    twitterDescription: listing.sourceSummary,
    robots: options.noindexOverride ? "noindex, follow" : listing.indexing,
  };
}

export function pageMetaForEvent(event: EventDetailRecord): PageMeta {
  const description = event.summary || event.listing.description;
  return {
    title: interpolateContent(websiteMeta.event.titleTemplate, {
      title: event.title,
      city: event.listing.city,
    }),
    description,
    canonicalPath: event.path,
    twitterDescription: event.supply === "external"
      ? interpolateContent(websiteMeta.event.externalTwitterTemplate, {
        title: event.title,
        source: event.sourceLabel,
      })
      : interpolateContent(websiteMeta.event.catchTwitterTemplate, {
        title: event.title,
        organizer: event.listing.name,
      }),
    robots: event.listing.indexing,
  };
}

export function getPageKey(
  pathname: string = window.location.pathname
): Exclude<PageKey, "listing" | "event_detail"> {
  if (pathname.startsWith("/claim")) return "claim";
  if (pathname.startsWith("/privacy")) return "privacy";
  if (pathname.startsWith("/terms")) return "terms";
  if (pathname.startsWith("/help")) return "help";
  if (pathname.startsWith("/host")) return "host";
  if (pathname.startsWith("/organizers")) return "organizers";
  if (pathname === "/" || pathname === "") return "home";
  return "not_found";
}

export function pageClassFor(page: PageKey) {
  if (page === "host") return "host-page";
  if (page === "listing") return "listing-page";
  if (page === "event_detail") return "event-detail-page";
  if (page === "organizers") return "organizers-page";
  if (page === "claim") return "claim-page";
  if (page === "privacy" || page === "terms" || page === "help") return "legal-page";
  if (page === "not_found") return "not-found-page";
  return "home-page";
}
