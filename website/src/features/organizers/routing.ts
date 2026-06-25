import {hostListings} from "./data";
import type {HostListing, HostListingRoute} from "./types";

type BrowserLocation = Pick<Location, "pathname" | "search">;

export type ClaimUrlState = "alreadyClaimed" | "pendingClaim" | "notFound" | null;

export function getHostListingRouteForPath(
  pathname: string
): HostListingRoute | null {
  const normalizedPath = pathname.endsWith("/") ? pathname : `${pathname}/`;
  const canonicalListing = hostListings.find((listing) =>
    listing.path === normalizedPath
  );
  if (canonicalListing) {
    return {
      isLegacyPath: false,
      listing: canonicalListing,
    };
  }

  const legacyListing = hostListings.find((listing) =>
    listing.legacyPaths?.includes(normalizedPath)
  );
  return legacyListing ? {
    isLegacyPath: true,
    listing: legacyListing,
  } : null;
}

export function getHostListingForPath(pathname: string) {
  return getHostListingRouteForPath(pathname)?.listing ?? null;
}

export function getClaimListingFromLocation(
  location: BrowserLocation = window.location
) {
  const lookup = getClaimListingLookupFromLocation(location);
  if (!lookup) return null;
  return hostListings.find((listing) =>
    listing.id === lookup ||
    listing.slug === lookup ||
    listing.path === lookup ||
    listing.legacyPaths?.includes(lookup)
  ) ?? null;
}

export function getClaimListingLookupFromLocation(
  location: BrowserLocation = window.location
) {
  const params = new URLSearchParams(location.search);
  const idOrSlug = params.get("listing") ?? params.get("clubId");
  const pathParts = location.pathname.split("/").filter(Boolean);
  const pathSlug = pathParts[0] === "claim" ? pathParts[1] : null;
  return idOrSlug ?? pathSlug;
}

export function getClaimRequestIdFromLocation(
  location: BrowserLocation = window.location
) {
  const params = new URLSearchParams(location.search);
  return params.get("requestId") ?? params.get("claimRequestId");
}

export function claimStateForLocation(
  lookup: string | null,
  listing: HostListing | null,
  location: BrowserLocation = window.location
): ClaimUrlState {
  const params = new URLSearchParams(location.search);
  const status = (params.get("claimStatus") ?? params.get("status") ?? "").toLowerCase();
  if (listing && (status === "pending" || Boolean(getClaimRequestIdFromLocation(location)))) {
    return "pendingClaim";
  }
  if (lookup && !listing) return "notFound";
  if (listing && !isUnclaimedListing(listing)) return "alreadyClaimed";
  return null;
}

export function claimHrefForListing(listing: HostListing) {
  return `/claim/?listing=${encodeURIComponent(listing.id)}`;
}

function isUnclaimedListing(listing: HostListing) {
  return listing.status.toLowerCase() === "unclaimed";
}
