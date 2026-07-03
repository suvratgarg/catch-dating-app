import type {HostListingPageController} from "../useHostListingPageController";
import type {HostListing} from "../types";
import type {ListingClaimController} from "../../claims/useListingClaimController";
import {ListingMissingEvidenceSection} from "./ListingClaimSections";
import {
  ListingCatchEventsSection,
  ListingEventEvidenceSection,
  ListingEventSuccessSection,
  ListingExternalEventsSection,
} from "./ListingEventsSections";
import {ListingFactsSection} from "./ListingFactsSection";
import {ListingFitSection} from "./ListingFitSection";
import {ListingHeroSection} from "./ListingHeroSection";
import {ListingReviewsSection} from "./ListingReviewsSection";
import {ListingSourcesSection} from "./ListingSourcesSection";
import {RecommendedOrganizersSection} from "./RecommendedOrganizersSection";

export function HostListingSections({
  claimController,
  controller,
  listing,
}: {
  claimController: ListingClaimController;
  controller: HostListingPageController;
  listing: HostListing;
}) {
  const {
    claimHref,
    handleSaveListing,
    handleShareListing,
    isAppCreated,
    isSaved,
    shareStatus,
  } = controller;

  return (
    <>
      <ListingHeroSection
        claimHref={claimHref}
        isAppCreated={isAppCreated}
        isSaved={isSaved}
        listing={listing}
        onSaveListing={handleSaveListing}
        onShareListing={() => void handleShareListing()}
        shareStatus={shareStatus}
      />

      <ListingFactsSection
        isAppCreated={isAppCreated}
        listing={listing}
      />

      {listing.catchEvents?.length ? (
        <ListingCatchEventsSection listing={listing} />
      ) : null}

      {listing.externalEvents?.length ? (
        <ListingExternalEventsSection
          anchorId={listing.catchEvents?.length ? "external-events" : "events"}
          listing={listing}
        />
      ) : null}

      <ListingEventEvidenceSection listing={listing} />
      <ListingReviewsSection listing={listing} />

      {listing.eventSuccessSummary ? (
        <ListingEventSuccessSection summary={listing.eventSuccessSummary} />
      ) : null}

      <ListingFitSection
        isAppCreated={isAppCreated}
        listing={listing}
      />

      {!isAppCreated ? (
        <>
          <ListingSourcesSection listing={listing} />
          <ListingMissingEvidenceSection
            claimController={claimController}
            listing={listing}
          />
          <RecommendedOrganizersSection current={listing} />
        </>
      ) : null}
    </>
  );
}
