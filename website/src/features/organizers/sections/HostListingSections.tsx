import {organiserProfileCopy} from "../../../content/organiserProfile";
import {renderAccountForm} from "../../account/accountForm";
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
import {
  ListingHeroRailSection,
  ListingHeroSection,
  ListingProfileInformation,
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
  ListingSection,
  ListingSectionIntro,
  ButtonLink,
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
    handleFollowListing,
    handleShareListing,
    isAppCreated,
    isFollowing,
    shareStatus,
  } = controller;
  const canRequestClaim = organizerPolicyForListing(listing).canRequestClaim;
  const activity = activityForListing(listing);

  return (
    <ListingProfileLayout activityToken={activity.token}>
      <ListingProfilePrimary>
        <ListingHeroSection listing={listing} />

        {listing.catchEvents?.length ? (
          <ListingCatchEventsSection listing={listing} />
        ) : null}

        {listing.externalEvents?.length ? (
          <ListingExternalEventsSection
            anchorId={listing.catchEvents?.length ? "external-events" : "events"}
            listing={listing}
          />
        ) : null}

        {!controller.hasEventSupply ? <ListingSection id="events" aria-labelledby="profile-empty-events">
          <ListingSectionIntro titleId="profile-empty-events" eyebrow={organiserProfileCopy.nav.events} title={organiserProfileCopy.emptyTitle}
            body={organiserProfileCopy.emptyBody(listing.name)} />
          <ButtonLink variant="ghost" href={`/explore/?city=${encodeURIComponent(listing.city)}`}>{organiserProfileCopy.exploreCity(listing.city)}</ButtonLink>
        </ListingSection> : null}
        <ListingEventEvidenceSection listing={listing} />

        {listing.eventSuccessSummary ? (
          <ListingEventSuccessSection summary={listing.eventSuccessSummary} />
        ) : null}

        <ListingFactsSection listing={listing} />
        <ListingReviewsSection listing={listing} />

        <ListingProfileInformation listing={listing} />

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
          isFollowing={isFollowing}
          followPending={controller.followPending || controller.account.loading}
          listing={listing}
          onFollowListing={handleFollowListing}
          onShareListing={() => void handleShareListing()}
          shareStatus={shareStatus}
        />
        {controller.followRequested ? renderAccountForm(controller.account) : null}
        {controller.followError ? <p role="alert">{controller.followError}</p> : null}
        {listing.sources.length ? (
          <ListingSourcesSection listing={listing} />
        ) : null}
        <ListingEventsRailSection listing={listing} />
      </ListingProfileRail>
    </ListingProfileLayout>
  );
}
