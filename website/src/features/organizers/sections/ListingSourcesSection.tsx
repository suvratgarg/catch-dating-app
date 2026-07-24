import {
  ListingRailLinkList,
  ListingRailSection,
} from "../../../shared/ui/primitives";
import {organizerListingCopy} from "@content/organizer";
import {trackOrganizerAnalytics} from "../analytics";
import type {HostListing} from "../types";

export function ListingSourcesSection({listing}: {listing: HostListing}) {
  const sourceItems = listing.sources.map((source) => ({
    href: source.href,
    key: `${source.type}-${source.label}`,
    label: source.label,
    onClick: source.href ? () => trackOrganizerAnalytics(
      listing,
      source.type === "socialProfile" ? "contactClick" : "outboundClick",
      `source_${source.type}`
    ) : undefined,
  }));

  return (
    <ListingRailSection
      eyebrow={organizerListingCopy.detail.sourcesEyebrow}
      id="sources"
    >
      <ListingRailLinkList items={sourceItems} />
    </ListingRailSection>
  );
}
