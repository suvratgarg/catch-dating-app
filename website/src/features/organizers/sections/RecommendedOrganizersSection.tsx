import {websiteCopy} from "@content/generated";
import {SectionHeader} from "../../../shared/site";
import {
  FeaturedOrganizerCardGrid,
  RecommendedOrganizersSectionShell,
} from "../../../shared/ui/primitives";
import {hostListings} from "../data";
import {featuredOrganizerCardItemForListing} from "../featuredOrganizerCardItem";
import {isVerifiedListing} from "../selectors";
import type {HostListing} from "../types";

export function RecommendedOrganizersSection({current}: {current: HostListing}) {
  const recommended = hostListings
    .filter((listing) => listing.id !== current.id && isVerifiedListing(listing))
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
