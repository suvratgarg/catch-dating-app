import {organiserProfileCopy} from "../../../content/organiserProfile";
import {organizerListingCopy} from "@content/organizer";
import {
  ListingFactGrid,
  ListingFormatRow,
  ListingSection,
  ListingSectionIntro,
  UiLabel,
} from "../../../shared/ui/primitives";
import {publicFactsForListing} from "../selectors";
import type {HostListing} from "../types";

export function ListingFactsSection({listing}: {listing: HostListing}) {

  return (
    <ListingSection id="about" aria-labelledby="listing-facts-title">
      <ListingSectionIntro
        eyebrow={organiserProfileCopy.community}
        titleId="listing-facts-title"
        title={organizerListingCopy.detail.aboutTitle(listing.name)}
        body={listing.description}
      />
      <ListingFactGrid items={publicFactsForListing(listing)} />
      <UiLabel>{organizerListingCopy.detail.formatsLabel}</UiLabel>
      <ListingFormatRow items={listing.formats} />
    </ListingSection>
  );
}
