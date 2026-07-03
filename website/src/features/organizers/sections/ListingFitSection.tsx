import {SectionHeader} from "../../../shared/site";
import {ListingNoteGrid, ListingSection} from "../../../shared/ui/primitives";
import type {HostListing} from "../types";

export function ListingFitSection({
  isAppCreated,
  listing,
}: {
  isAppCreated: boolean;
  listing: HostListing;
}) {
  const noteItems = listing.fitNotes.map((note) => ({
    body: note,
    key: note,
  }));

  return (
    <ListingSection id="fit" aria-labelledby="listing-fit-title">
      <SectionHeader
        eyebrow={isAppCreated ? "Page format" : "Catch fit"}
        id="listing-fit-title"
        title={isAppCreated ?
          "What the app-created profile needs to emphasize." :
          "Why this category belongs in the first test."} />
      <ListingNoteGrid items={noteItems} />
    </ListingSection>
  );
}
