import {listingFromFirestoreOrganizer} from "../../scripts/next/organizerProjection.mjs";
import {validateWebsiteHostListingProjection} from "../../../tool/contracts/generated/schema_contract_validators.mjs";
import {publicDocumentId, publicOrganizerAuthorized, publicHttpsUrl, organizerPath} from "./publicReadPolicy.ts";
import type {HostListing} from "../features/organizers/types";

/** The serializer only accepts the closed public DTO contract, never an Admin document. */
export function projectPublicOrganizer(id: string, data: unknown, liveMarkets: ReadonlySet<string>): HostListing | null {
  if (!publicDocumentId(id) || !publicOrganizerAuthorized(data, liveMarkets)) return null;
  const projected = listingFromFirestoreOrganizer({id, data});
  if (!projected) return null;
  // This field describes the projection input. Ownership remains in authority.
  projected.dataOrigin = "organizerIntake";
  if (!validateWebsiteHostListingProjection(projected)) return null;
  const listing = JSON.parse(JSON.stringify(projected)) as HostListing;
  listing.legacyPaths = listing.legacyPaths?.filter(organizerPath);
  listing.sources = listing.sources.map(source => {
    const {href, ...rest} = source;
    const safeHref = publicHttpsUrl(href);
    return safeHref ? {...rest, href: safeHref} : rest;
  });
  listing.catchEvents = [];
  return listing;
}
