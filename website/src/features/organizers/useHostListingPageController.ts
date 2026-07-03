import {useCallback, useEffect, useMemo, useState} from "react";
import {trackMarketingEvent} from "../../analytics";
import type {SiteNavItem} from "../../shared/site";
import {trackOrganizerAnalytics} from "./analytics";
import {absoluteListingUrl} from "./publicDiscovery";
import {claimHrefForListing} from "./routing";
import {readSavedOrganizer, writeSavedOrganizer} from "./savedOrganizerStorage";
import type {HostListing} from "./types";

export function useHostListingPageController(listing: HostListing) {
  const isAppCreated = listing.listingVariant === "appCreatedClub";
  const claimHref = isAppCreated ? listing.claim.href : claimHrefForListing(listing);
  const hasEventSupply = Boolean(
    listing.catchEvents?.length || listing.externalEvents?.length
  );
  const [shareStatus, setShareStatus] = useState("");
  const [isSaved, setIsSaved] = useState(() => readSavedOrganizer(listing.id));

  useEffect(() => {
    setIsSaved(readSavedOrganizer(listing.id));
    setShareStatus("");
  }, [listing.id]);

  useEffect(() => {
    trackOrganizerAnalytics(listing, "listingView", "listing_page");
  }, [listing.id]);

  const nav = useMemo<SiteNavItem[]>(() => [
    {href: "#profile", label: "Profile"},
    ...(hasEventSupply ? [{href: "#events", label: "Events"}] : []),
    {href: "#reviews", label: "Reviews"},
    {href: "#fit", label: isAppCreated ? "Format" : "Fit"},
    ...(!isAppCreated ? [{href: "#sources", label: "Sources"}] : []),
    {href: "/organizers/", label: "Search"},
    {href: "/host/", label: "For hosts"},
  ], [hasEventSupply, isAppCreated]);

  const footerLinks = useMemo<SiteNavItem[]>(() => [
    {href: "/host/", label: "For hosts"},
    {href: "#profile", label: "Profile"},
    {href: "#sources", label: "Sources"},
    {href: claimHref, label: "Claim"},
  ], [claimHref]);

  const handleSaveListing = useCallback(() => {
    const nextSaved = !isSaved;
    setIsSaved(nextSaved);
    writeSavedOrganizer(listing.id, nextSaved);
    if (nextSaved) {
      trackOrganizerAnalytics(listing, "organizerSave", "listing_hero");
    }
  }, [isSaved, listing]);

  const handleShareListing = useCallback(async () => {
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
  }, [listing]);

  return {
    claimHref,
    footerLinks,
    handleSaveListing,
    handleShareListing,
    hasEventSupply,
    headerCtaLabel: isAppCreated ? listing.claim.label : "Claim listing",
    isAppCreated,
    isSaved,
    nav,
    shareStatus,
  };
}

export type HostListingPageController = ReturnType<typeof useHostListingPageController>;
