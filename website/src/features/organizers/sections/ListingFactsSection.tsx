import {
  organizerAboutForSlug,
  organizerListingCopy,
} from "@content/organizer";
import {
  ListingFormatRow,
  ListingSection,
  ListingSectionIntro,
  UiLabel,
} from "../../../shared/ui/primitives";
import {organizerPolicyForListing} from "../organizerPolicy";
import type {HostListing} from "../types";

export function ListingFactsSection({listing}: {listing: HostListing}) {
  const policy = organizerPolicyForListing(listing);

  return (
    <ListingSection aria-labelledby="listing-facts-title">
      <ListingSectionIntro
        eyebrow={policy.badge.label}
        titleId="listing-facts-title"
        title={organizerListingCopy.detail.aboutTitle(listing.name)}
        body={organizerAboutForSlug(listing.slug, listing.description)}
      />
      <UiLabel>{organizerListingCopy.detail.formatsLabel}</UiLabel>
      <ListingFormatRow items={listing.formats} />
    </ListingSection>
  );
}
