import {listingFromFirestoreOrganizer} from "../../scripts/next/organizerProjection.mjs";
import {validateWebsiteHostListingProjection} from "../../../tool/contracts/generated/schema_contract_validators.mjs";
import {publicDocumentId, publicOrganizerAuthorized, publicHttpsUrl, organizerPath} from "./publicReadPolicy.ts";
import {organizerListingCopy} from "../content/organizer.ts";
import type {HostListing} from "../features/organizers/types";

// Claim, indexing, ownership, verification and publication state render from
// the structured authority. Free-text facts restating them go stale.
const authorityFactLabel = /^(?:claim(?: state| status)?|index(?:ing| status)?|ownership(?: state)?|verification(?: status)?|publi(?:sh|cation)(?: state| status)?)$/iu;
const ownerEstablished = new Set(["userCreated", "claimed", "transferred"]);

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
  // A source without a public link is intake evidence, not public provenance.
  listing.sources = listing.sources.flatMap(source => {
    const safeHref = publicHttpsUrl(source.href);
    return safeHref ? [{...source, href: safeHref}] : [];
  });
  listing.facts = listing.facts.filter(fact => !authorityFactLabel.test(fact.label.trim()));
  listing.fitNotes = [];
  if (!ownerEstablished.has(listing.authority.ownershipState)) {
    // Imported listings stay out of search, and intake prose is written for
    // operators, so visitors get a structured summary until an owner claims it.
    listing.indexing = "noindex, follow";
    listing.description = organizerListingCopy.detail.sourcedSummary(listing.name, listing.category, listing.city);
    listing.sourceSummary = listing.description;
  }
  listing.eventEvidence = listing.eventEvidence.filter(event => publicHttpsUrl(event.sourceHref));
  const raw = data as Record<string, unknown>;
  const metrics: NonNullable<HostListing["metrics"]> = {};
  for (const key of ["followerCount", "reviewCount", "verifiedReviewCount"] as const) {
    if (key !== "followerCount" && listing.capabilities.publicReviews.readState !== "enabled") continue;
    if (Number.isSafeInteger(raw[key]) && Number(raw[key]) >= 0) metrics[key] = Number(raw[key]);
  }
  // The canonical score is verified-review-only; never pair it with the total public-review count.
  if (typeof raw.rating === "number" && raw.rating > 0 && raw.rating <= 5 && (metrics.verifiedReviewCount ?? 0) > 0) metrics.rating = raw.rating;
  listing.metrics = metrics;
  listing.catchEvents = [];
  return listing;
}
