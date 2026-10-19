import {websiteCopy} from "@content/generated";
import {SectionHeader} from "../../../shared/site";
import {
  FeaturedOrganizerCardGrid,
  RecommendedOrganizersSectionShell,
} from "../../../shared/ui/primitives";
import {usePublicHostListings} from "../usePublicEventListingsController";
import {featuredOrganizerCardItemForListing} from "../featuredOrganizerCardItem";
import {isPubliclyReadableListing, isVerifiedListing} from "../selectors";
import type {HostListing} from "../types";

export function RecommendedOrganizersSection({
  current,
  listings,
}: {
  current: HostListing;
  listings?: readonly HostListing[];
}) {
  const live = usePublicHostListings();
  const recommended = (listings ?? live.listings)
    .filter((listing) =>
      listing.id !== current.id &&
      isPubliclyReadableListing(listing) &&
      isVerifiedListing(listing)
    )
    .slice(0, 3);
  if (!recommended.length) return null;
  const recommendedItems = recommended.map(featuredOrganizerCardItemForListing);

  return (
    <RecommendedOrganizersSectionShell aria-labelledby="recommended-organizers-title">
      <SectionHeader
        eyebrow={websiteCopy["recommendedorganizerssection_0491"]}
        id="recommended-organizers-title"
        title={websiteCopy["recommendedorganizerssection_0490"]}
        body={websiteCopy["recommendedorganizerssection_0489"]} />
      <FeaturedOrganizerCardGrid items={recommendedItems} />
    </RecommendedOrganizersSectionShell>
  );
}
