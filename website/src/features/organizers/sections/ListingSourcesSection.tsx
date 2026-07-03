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
        eyebrow="Source ledger"
        title="Evidence before indexing."
        body="Thin pages should stay out of search until identity, cadence, and owner-safe details are verified."
      />

      <ListingSourceLedger items={sourceItems} />
    </ListingSection>
  );
}
