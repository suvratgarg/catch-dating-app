import {SectionHeader} from "../../../shared/site";
import {ListingFactGrid, ListingSection} from "../../../shared/ui/primitives";
import type {HostListing} from "../types";

export function ListingFactsSection({
  isAppCreated,
  listing,
}: {
  isAppCreated: boolean;
  listing: HostListing;
}) {
  const factItems = listing.facts.map((fact) => ({
    key: fact.label,
    label: fact.label,
    value: fact.value,
  }));

  return (
    <ListingSection aria-labelledby="listing-facts-title">
      <SectionHeader
        eyebrow={isAppCreated ? "Club profile" : "Known profile"}
        id="listing-facts-title"
        title={isAppCreated ?
          "A Catch-created club with real product context." :
          "A source-conservative seed listing."}
        body={listing.sourceSummary} />
      <ListingFactGrid items={factItems} />
    </ListingSection>
  );
}
