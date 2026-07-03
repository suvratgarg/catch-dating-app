import {hostListings} from "./data";
import type {HostListing, HostListingRoute} from "./types";

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

export function claimHrefForListing(listing: HostListing) {
  return `/claim/?listing=${encodeURIComponent(listing.id)}`;
}
