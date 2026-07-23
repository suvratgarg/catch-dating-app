import {
  organizerHeroMediaForSlug,
  organizerListingCopy,
} from "@content/organizer";
import {
  ActivityMark,
  StatusBadge,
} from "../OrganizerIdentity";
import {activityForListing} from "../publicDiscovery";
import {organizerPolicyForListing} from "../organizerPolicy";
import type {HostListing} from "../types";
import {
  Button,
  ButtonLink,
  ListingPolaroid,
  ListingRailActions,
  ListingRailIdentity,
  ListingStatusLedger,
} from "../../../shared/ui/primitives";
import {trackOrganizerAnalytics} from "../analytics";
import {trackCtaClick} from "../../marketing/tracking";

export function ListingHeroSection({listing}: {listing: HostListing}) {
  const policy = organizerPolicyForListing(listing);
  const location = listingLocation(listing);

  return (
    <section aria-labelledby="listing-profile-title">
      <ListingPolaroid
        caption={location}
        fallback={<ActivityMark listing={listing} size="lg" />}
        media={organizerHeroMediaForSlug(listing.slug)}
        provenance={policy.badge.label}
        title={listing.name}
        titleId="listing-profile-title"
      />
      <ListingStatusLedger
        items={[
          {
            label: organizerListingCopy.detail.sourceCountLabel,
            value: `${listing.sources.length} ${listing.sources.length === 1 ? "source" : "sources"}`,
          },
          {
            label: organizerListingCopy.detail.claimStateLabel,
            value: claimStateLabel(policy.claimState),
          },
          {
            label: organizerListingCopy.detail.surfaceLabel,
            value: listing.authority?.appVisibility === "hidden" ? "Web only" : "In Catch",
          },
          {
            label: organizerListingCopy.detail.freshnessLabel,
            value: reviewedLabel(listing.lastVerifiedAt),
          },
          {
            label: organizerListingCopy.detail.ownershipLabel,
            value: ownershipLabel(policy),
          },
        ]}
      />
    </section>
  );
}

export function ListingHeroRailSection({
  canRequestClaim,
  claimHref,
  isAppCreated,
  isSaved,
  listing,
  onSaveListing,
  onShareListing,
  shareStatus,
}: {
  canRequestClaim?: boolean;
  claimHref: string;
  isAppCreated: boolean;
  isSaved: boolean;
  listing: HostListing;
  onSaveListing: () => void;
  onShareListing: () => void;
  shareStatus: string;
}) {
  const policy = organizerPolicyForListing(listing);
  const resolvedCanRequestClaim = canRequestClaim ?? policy.canRequestClaim;
  const primaryDescription = resolvedCanRequestClaim
    ? "Claim to manage copy, publish events and respond to reviews."
    : isAppCreated
      ? "Open the organizer's published Catch events."
      : policy.claimRequestReason;

  return (
    <>
      <ListingRailIdentity
        activity={<ActivityMark listing={listing} size="lg" />}
        eyebrow={organizerListingCopy.detail.organizerEyebrow}
        location={listingLocation(listing)}
        name={listing.name}
        status={<StatusBadge listing={listing} />}
      />
      <ListingRailActions description={primaryDescription} shareStatus={shareStatus}>
        {resolvedCanRequestClaim ? (
          <ButtonLink
            href={claimHref}
            onClick={() => {
              trackCtaClick("listing_claim", claimHref);
              trackOrganizerAnalytics(listing, "claimClick", "organizer_rail");
            }}
          >
            {listing.claim.label}
          </ButtonLink>
        ) : isAppCreated ? (
          <ButtonLink
            href={claimHref}
            onClick={() => trackCtaClick("listing_events", claimHref)}
          >
            {listing.claim.label}
          </ButtonLink>
        ) : (
          <Button disabled type="button">
            {listing.claim.label}
          </Button>
        )}
        {listing.sources.length ? (
          <ButtonLink variant="ghost" href="#sources">
            {organizerListingCopy.detail.viewSourcesAction}
          </ButtonLink>
        ) : null}
        <Button variant="ghost" type="button" onClick={onShareListing}>
          {organizerListingCopy.detail.shareAction}
        </Button>
        <Button
          variant="ghost"
          type="button"
          aria-pressed={isSaved}
          onClick={onSaveListing}
        >
          {isSaved ? "Saved" : "Save"}
        </Button>
      </ListingRailActions>
    </>
  );
}

function listingLocation(listing: HostListing) {
  return [listing.city, listing.region, listing.country]
    .map((part) => part.trim())
    .filter(Boolean)
    .join(" · ");
}

function claimStateLabel(state: ReturnType<typeof organizerPolicyForListing>["claimState"]) {
  switch (state) {
  case "unclaimed": return "Unclaimed";
  case "claimPending": return "Claim in review";
  case "claimed": return "Claimed";
  case "verified": return "Verified";
  case "suppressed": return "Unavailable";
  case "unknown": return "Status unknown";
  }
}

function reviewedLabel(value: string) {
  const date = new Date(`${value}T00:00:00.000Z`);
  if (Number.isNaN(date.getTime())) return "Review date unavailable";
  const month = date.toLocaleString("en", {month: "short", timeZone: "UTC"}).toUpperCase();
  const year = String(date.getUTCFullYear()).slice(-2);
  return `${month} '${year} reviewed`;
}

function ownershipLabel(policy: ReturnType<typeof organizerPolicyForListing>) {
  if (policy.isCatchCreated) return "Catch created";
  if (policy.verificationStatus === "ownerVerified") return "Ownership verified";
  if (policy.claimState === "claimPending") return "Ownership in review";
  return "Ownership not verified";
}
