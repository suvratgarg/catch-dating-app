import {websiteCopy} from "@content/generated";
import {websiteTemplates} from "@content/templates";
import {useCallback, useEffect, useMemo, useState} from "react";
import {trackMarketingEvent} from "../../analytics";
import type {SiteNavItem} from "../../shared/site";
import {trackOrganizerAnalytics} from "./analytics";
import {absoluteListingUrl} from "./publicDiscovery";
import {claimHrefForListing} from "./routing";
import {readSavedOrganizer, writeSavedOrganizer} from "./savedOrganizerStorage";
import {organizerPolicyForListing} from "./organizerPolicy";
import type {HostListing} from "./types";

export function useHostListingPageController(listing: HostListing) {
  const policy = organizerPolicyForListing(listing);
  const isAppCreated = policy.isCatchCreated;
  const claimHref = policy.canRequestClaim ?
    claimHrefForListing(listing) :
    isAppCreated ? listing.claim.href : "/organizers/";
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
    {href: "#profile", label: websiteCopy["usehostlistingpagecontroller_0495"]},
    ...(hasEventSupply ? [{href: "#events", label: websiteCopy["usehostlistingpagecontroller_0493"]}] : []),
    {href: "#reviews", label: websiteCopy["usehostlistingpagecontroller_0496"]},
    {href: "#fit", label: isAppCreated ? "Format" : "Fit"},
    ...(!isAppCreated ? [{href: "#sources", label: websiteCopy["usehostlistingpagecontroller_0498"]}] : []),
    {href: "/organizers/", label: websiteCopy["usehostlistingpagecontroller_0497"]},
    {href: "/host/", label: websiteCopy["usehostlistingpagecontroller_0494"]},
  ], [hasEventSupply, isAppCreated]);

  const footerLinks = useMemo<SiteNavItem[]>(() => [
    {href: "/host/", label: websiteCopy["usehostlistingpagecontroller_0494"]},
    {href: "#profile", label: websiteCopy["usehostlistingpagecontroller_0495"]},
    ...(!isAppCreated ? [{href: "#sources", label: websiteCopy["usehostlistingpagecontroller_0498"]}] : []),
    ...(policy.canRequestClaim ? [{href: claimHref, label: websiteCopy["usehostlistingpagecontroller_0492"]}] : []),
  ], [claimHref, isAppCreated, policy.canRequestClaim]);

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
      title: websiteTemplates.listingShareTitle(listing.name),
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
    headerCtaLabel: policy.canRequestClaim ?
      "Claim listing" :
      isAppCreated ? listing.claim.label : "Search organizers",
    isAppCreated,
    isSaved,
    nav,
    shareStatus,
  };
}

export type HostListingPageController = ReturnType<typeof useHostListingPageController>;
