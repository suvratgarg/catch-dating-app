import {websiteCopy} from "@content/generated";
import {
  ListingSection,
  ListingSectionIntro,
  ListingSourceLedger,
} from "../../../shared/ui/primitives";
import {trackOrganizerAnalytics} from "../analytics";
import type {HostListing} from "../types";

export function ListingSourcesSection({listing}: {listing: HostListing}) {
  const sourceItems = listing.sources.map((source) => ({
    confidence: source.confidence,
    detail: source.detail,
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
    <ListingSection variant="split" id="sources">
      <ListingSectionIntro
        eyebrow={websiteCopy["listingsourcessection_0449"]}
        title={websiteCopy["listingsourcessection_0448"]}
        body={websiteCopy["listingsourcessection_0450"]}
      />

      <ListingSourceLedger items={sourceItems} />
    </ListingSection>
  );
}
