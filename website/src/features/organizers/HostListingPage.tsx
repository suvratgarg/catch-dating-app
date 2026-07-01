import {useEffect, useState} from "react";
import {trackMarketingEvent} from "../../analytics";
import {SiteFooter, SiteHeader} from "../../shared/site";
import {trackCtaClick} from "../marketing/tracking";
import {trackOrganizerAnalytics} from "./analytics";
import {absoluteListingUrl} from "./publicDiscovery";
import {claimHrefForListing} from "./routing";
import {readSavedOrganizer, writeSavedOrganizer} from "./savedOrganizerStorage";
import type {HostListing} from "./types";
import {
  ListingCatchEventsSection,
  ListingEventEvidenceSection,
  ListingEventSuccessSection,
  ListingExternalEventsSection,
} from "./sections/ListingEventsSections";
import {ListingFactsSection} from "./sections/ListingFactsSection";
import {ListingFitSection} from "./sections/ListingFitSection";
import {ListingHeroSection} from "./sections/ListingHeroSection";
import {ListingMissingEvidenceSection} from "./sections/ListingClaimSections";
import {ListingReviewsSection} from "./sections/ListingReviewsSection";
import {ListingSourcesSection} from "./sections/ListingSourcesSection";
import {RecommendedOrganizersSection} from "./sections/RecommendedOrganizersSection";

export function HostListingPage({listing}: {listing: HostListing}) {
  const isAppCreated = listing.listingVariant === "appCreatedClub";
  const claimHref = isAppCreated ? listing.claim.href : claimHrefForListing(listing);
  const hasEventSupply = Boolean(
    listing.catchEvents?.length || listing.externalEvents?.length
  );
  const [shareStatus, setShareStatus] = useState("");
  const [isSaved, setIsSaved] = useState(() => readSavedOrganizer(listing.id));
  const nav = [
    {href: "#profile", label: "Profile"},
    ...(hasEventSupply ? [{href: "#events", label: "Events"}] : []),
    {href: "#reviews", label: "Reviews"},
    {href: "#fit", label: isAppCreated ? "Format" : "Fit"},
    ...(!isAppCreated ? [{href: "#sources", label: "Sources"}] : []),
    {href: "/organizers/", label: "Search"},
    {href: "/host/", label: "For hosts"},
  ];

  useEffect(() => {
    trackOrganizerAnalytics(listing, "listingView", "listing_page");
  }, [listing]);

  function handleSaveListing() {
    const nextSaved = !isSaved;
    setIsSaved(nextSaved);
    writeSavedOrganizer(listing.id, nextSaved);
    if (nextSaved) {
      trackOrganizerAnalytics(listing, "organizerSave", "listing_hero");
    }
  }

  async function handleShareListing() {
    const shareUrl = absoluteListingUrl(listing);
    const shareData = {
      title: `${listing.name} on Catch`,
      text: listing.headline,
      url: shareUrl,
    };

    try {
      if ("share" in navigator && typeof navigator.share === "function") {
        await navigator.share(shareData);
        setShareStatus("Share sheet opened.");
        trackMarketingEvent("listing_share_completed", {
          club_id: listing.id,
          method: "native",
        });
        return;
      }
      if (navigator.clipboard?.writeText) {
        await navigator.clipboard.writeText(shareUrl);
        setShareStatus("Listing link copied.");
        trackMarketingEvent("listing_share_completed", {
          club_id: listing.id,
          method: "clipboard",
        });
        return;
      }
      setShareStatus(shareUrl);
      trackMarketingEvent("listing_share_completed", {
        club_id: listing.id,
        method: "manual",
      });
    } catch (error) {
      const aborted = error instanceof DOMException && error.name === "AbortError";
      setShareStatus(aborted ? "Share cancelled." : "Could not share. Copy the URL from the address bar.");
      trackMarketingEvent("listing_share_error", {
        club_id: listing.id,
        aborted,
      });
    }
  }

  return (
    <>
      <SiteHeader
        brandHref="/"
        nav={nav}
        ctaHref={claimHref}
        ctaLabel={isAppCreated ? listing.claim.label : "Claim listing"}
      />

      <main id="profile">
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
            <ListingMissingEvidenceSection listing={listing} />
            <RecommendedOrganizersSection current={listing} />
          </>
        ) : null}
      </main>

      <SiteFooter
        brandHref="/"
        body="Claimable profiles for hosts who run social events people actually show up for."
        links={[
          {href: "/host/", label: "For hosts"},
          {href: "#profile", label: "Profile"},
          {href: "#sources", label: "Sources"},
          {href: claimHref, label: "Claim"},
        ]}
      />
    </>
  );
}
