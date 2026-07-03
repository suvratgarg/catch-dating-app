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
        eyebrow="While you are here"
        id="recommended-organizers-title"
        title="Verified organizers nearby in the product loop."
        body="Unclaimed pages keep the source ledger visible, but verified profiles can show owner-managed activity, reviews, and event outcomes." />
      <FeaturedOrganizerCardGrid items={recommendedItems} />
    </RecommendedOrganizersSectionShell>
  );
}
