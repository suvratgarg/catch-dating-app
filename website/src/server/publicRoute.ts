import {productionIndexing} from "./publicEnvironment";
import {cache} from "react";
import {readPublicCatalog, readPublicListingReviews} from "./publicCatalog";
import {pageMeta, pageMetaForHostPath, pageMetaForListing, pageMetaForEvent, type PageKey} from "../app/pageMeta";
import {getHostListingRouteForPath} from "../features/organizers/routing";
import {buildPublicEventDetailRecords, getEventDetailForPath} from "../features/events/eventDetailModel";
import type {Metadata} from "next";
export const resolvePublicRoute = cache(async (pathname: string) => {
  const key = pathname.replace(/\/+$/, "") || "/";
  const live = key === "/" || key === "/explore" || /^\/(organizers|events|claim)(\/|$)/.test(key);
  let catalog = live ? await readPublicCatalog() : {listings: [], readAt: 0};
  let listingRoute = getHostListingRouteForPath(pathname, catalog.listings);
  let event = getEventDetailForPath(pathname, buildPublicEventDetailRecords(catalog.listings, catalog.readAt));
  const target = event?.listing ?? listingRoute?.listing;
  if (target) {
    const enriched = await readPublicListingReviews(target, event?.eventId);
    catalog = {...catalog, listings: catalog.listings.map(listing => listing.id === target.id ? enriched : listing)};
    listingRoute = getHostListingRouteForPath(pathname, catalog.listings);
    event = getEventDetailForPath(pathname, buildPublicEventDetailRecords(catalog.listings, catalog.readAt));
  }
  const routes: Record<string, PageKey> = {"/": "home", "/explore": "visitor_discovery", "/host": "host",
    "/host/apply": "host", "/organizers": "organizers", "/privacy": "privacy", "/terms": "terms", "/help": "help", "/claim": "claim"};
  const page: PageKey = listingRoute ? "listing" : event ? "event_detail" : routes[key] ??
    (/^\/claim\/[^/]+$/.test(key) ? "claim" : "not_found");
  const meta = listingRoute ? pageMetaForListing(listingRoute.listing) : event ? pageMetaForEvent(event) :
    pageMetaForHostPath(pathname) ?? pageMeta[page as keyof typeof pageMeta];
  const metadata: Metadata = {title: meta.title, description: meta.description,
    alternates: {canonical: `https://catchdates.com${meta.canonicalPath}`},
    robots: productionIndexing() ? meta.robots ?? "index, follow" : "noindex, follow", openGraph: {title: meta.title, description: meta.description,
      url: `https://catchdates.com${meta.canonicalPath}`, type: "website"},
    twitter: {card: "summary_large_image", title: meta.title, description: meta.twitterDescription}};
  return {page, catalog, metadata, listingRoute, event, live};
});
