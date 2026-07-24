import {SectionHeader} from "../../../shared/site";
import {ListingFactGrid, ListingSection} from "../../../shared/ui/primitives";
import {organizerPolicyForListing} from "../organizerPolicy";
import {publicFactsForListing} from "../selectors";
import type {HostListing} from "../types";

export function ListingFactsSection({
  isAppCreated,
  listing,
}: {
  isAppCreated: boolean;
  listing: HostListing;
}) {
  const policy = organizerPolicyForListing(listing);
  const factItems = publicFactsForListing(listing).map((fact) => ({
    key: fact.label,
    label: fact.label,
    value: fact.value,
  }));

  return (
    <ListingSection aria-labelledby="listing-facts-title">
      <SectionHeader
        eyebrow={policy.badge.label}
        id="listing-facts-title"
        title={isAppCreated ?
          "A Catch-created club with real product context." :
          policy.trustState === "ownerVerified" ?
            "An owner-verified organizer profile." :
            "A source-conservative organizer listing."}
        body={listing.sourceSummary} />
      <ListingFactGrid items={factItems} />
    </ListingSection>
  );
}
