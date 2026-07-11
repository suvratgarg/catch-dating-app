import {hostListings} from "../organizers/data";
import {
  isClaimSubmissionEnabledListing,
  isUnclaimedListing,
} from "../organizers/selectors";
import type {HostListing} from "../organizers/types";

export type ClaimRouteLocation = Pick<Location, "pathname" | "search">;
export type ClaimUrlState =
  | "alreadyClaimed"
  | "claimUnavailable"
  | "pendingClaim"
  | "notFound"
  | null;

export interface ClaimRouteState {
  lookup: string | null;
  listing: HostListing | null;
  requestId: string | null;
  urlState: ClaimUrlState;
}

export const emptyClaimRouteState: ClaimRouteState = {
  lookup: null,
  listing: null,
  requestId: null,
  urlState: null,
};

export function claimRouteStateForLocation(
  location: ClaimRouteLocation,
  routeListing: string | null | undefined = null
): ClaimRouteState {
  const lookup = getClaimListingLookupFromLocation(location, routeListing);
  const listing = getClaimListingForLookup(lookup);
  const requestId = getClaimRequestIdFromLocation(location);
  return {
    lookup,
    listing,
    requestId,
    urlState: claimStateForLocation({
      listing,
      location,
      lookup,
      requestId,
    }),
  };
}

export function getClaimListingForLookup(lookup: string | null) {
  if (!lookup) return null;
  return hostListings.find((listing) =>
    listing.id === lookup ||
    listing.slug === lookup ||
    listing.path === lookup ||
    listing.legacyPaths?.includes(lookup)
  ) ?? null;
}

export function getClaimListingLookupFromLocation(
  location: ClaimRouteLocation,
  routeListing: string | null | undefined = null
) {
  const params = new URLSearchParams(location.search);
  const idOrSlug = params.get("listing") ?? params.get("clubId");
  const pathParts = location.pathname.split("/").filter(Boolean);
  const pathSlug = normalizedLookup(routeListing) ??
    (pathParts[0] === "claim" ? normalizedLookup(pathParts[1]) : null);
  return normalizedLookup(idOrSlug) ?? pathSlug;
}

export function getClaimRequestIdFromLocation(location: ClaimRouteLocation) {
  const params = new URLSearchParams(location.search);
  return normalizedLookup(params.get("requestId") ?? params.get("claimRequestId"));
}

function claimStateForLocation({
  listing,
  location,
  lookup,
  requestId,
}: {
  listing: HostListing | null;
  location: ClaimRouteLocation;
  lookup: string | null;
  requestId: string | null;
}): ClaimUrlState {
  const params = new URLSearchParams(location.search);
  const status = (params.get("claimStatus") ?? params.get("status") ?? "").toLowerCase();
  if (listing && (status === "pending" || Boolean(requestId))) {
    return "pendingClaim";
  }
  if (lookup && !listing) return "notFound";
  if (listing && !isUnclaimedListing(listing)) return "alreadyClaimed";
  if (listing && !isClaimSubmissionEnabledListing(listing)) {
    return "claimUnavailable";
  }
  return null;
}

function normalizedLookup(value: string | null | undefined) {
  const normalized = value?.trim();
  return normalized ? normalized : null;
}
