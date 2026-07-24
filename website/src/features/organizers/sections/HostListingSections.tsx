import type {HostListingPageController} from "../useHostListingPageController";
import type {HostListing} from "../types";
import type {ListingClaimController} from "../../claims/useListingClaimController";
import {ListingMissingEvidenceSection} from "./ListingClaimSections";
import {
  ListingCatchEventsSection,
  ListingEventEvidenceSection,
  ListingEventsRailSection,
  ListingEventSuccessSection,
  ListingExternalEventsSection,
} from "./ListingEventsSections";
import {ListingFactsSection} from "./ListingFactsSection";
import {ListingFitSection} from "./ListingFitSection";
import {
  ListingHeroRailSection,
  ListingHeroSection,
} from "./ListingHeroSection";
import {ListingReviewsSection} from "./ListingReviewsSection";
import {ListingSourcesSection} from "./ListingSourcesSection";
import {RecommendedOrganizersSection} from "./RecommendedOrganizersSection";
import {organizerPolicyForListing} from "../organizerPolicy";
import {activityForListing} from "../publicDiscovery";
import {
  ListingProfileLayout,
  ListingProfilePrimary,
  ListingProfileRail,
} from "../../../shared/ui/primitives";
import {organizerListingCopy} from "@content/organizer";

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
  const canRequestClaim = organizerPolicyForListing(listing).canRequestClaim;
  const activity = activityForListing(listing);

  return (
    <ListingProfileLayout activityToken={activity.token}>
      <ListingProfilePrimary>
        <ListingHeroSection listing={listing} />
        <ListingFactsSection listing={listing} />

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
          {claimController.presentation.panel !== "hidden" ? (
            <ListingMissingEvidenceSection
              claimController={claimController}
              listing={listing}
            />
          ) : null}
          <RecommendedOrganizersSection current={listing} />
          </>
        ) : null}
      </ListingProfilePrimary>

      <ListingProfileRail
        aria-label={organizerListingCopy.detail.railAriaLabel(listing.name)}
      >
        <ListingHeroRailSection
          claimHref={claimHref}
          canRequestClaim={canRequestClaim}
          isAppCreated={isAppCreated}
          isSaved={isSaved}
          listing={listing}
          onSaveListing={handleSaveListing}
          onShareListing={() => void handleShareListing()}
          shareStatus={shareStatus}
        />
        {!isAppCreated && listing.sources.length ? (
          <ListingSourcesSection listing={listing} />
        ) : null}
        <ListingEventsRailSection listing={listing} />
      </ListingProfileRail>
    </ListingProfileLayout>
  );
}
