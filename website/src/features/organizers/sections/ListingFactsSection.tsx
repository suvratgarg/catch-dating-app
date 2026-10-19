import {organiserProfileCopy} from "../../../content/organiserProfile";
import {
  organizerAboutForSlug,
  organizerListingCopy,
} from "@content/organizer";
import {
  ListingFactGrid,
  ListingFormatRow,
  ListingSection,
  ListingSectionIntro,
  ListingSourceLedger,
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
        body={organizerAboutForSlug(listing.slug, listing.description)}
      />
      <ListingFactGrid items={publicFactsForListing(listing)} />
      <UiLabel>{organizerListingCopy.detail.formatsLabel}</UiLabel>
      <ListingFormatRow items={listing.formats} />
      {listing.sourceSummary && listing.sourceSummary !== listing.description ? <p>{listing.sourceSummary}</p> : null}
      {listing.sources.length ? (
        <>
          <UiLabel>{organizerListingCopy.detail.sourcesEyebrow}</UiLabel>
          <ListingSourceLedger items={listing.sources.map((source) => ({
            key: `${source.type}-${source.label}`,
            label: source.label,
            detail: source.detail,
            confidence: source.confidence,
          }))} />
        </>
      ) : null}
    </ListingSection>
  );
}
