import {accountCopy} from "../../content/account";
import {observeOrganizerProviders} from "./observeOrganizerProviders";
import {websiteCopy} from "@content/generated";
import {organizerPresenceCopy} from "@content/organizerPresence";
import {websiteTemplates} from "@content/templates";
import {useCallback, useEffect, useMemo, useRef, useState} from "react";
import {trackMarketingEvent} from "../../analytics";
import type {SiteNavItem} from "../../shared/site";
import {observeOrganizerPageView, trackOrganizerAnalytics} from "./analytics";
import {absoluteListingUrl} from "./publicDiscovery";
import {claimHrefForListing} from "./routing";
import {useMutation} from "@tanstack/react-query";
import {setWebsiteOrganizerFollow} from "../../firebase";
import {useWebsiteAccountController} from "../account/useWebsiteAccountController";
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
  const eventsHref = hasEventSupply ? "#events" : listing.eventEvidence?.length ? "#event-evidence" : null;
  const [shareStatus, setShareStatus] = useState("");
  const account = useWebsiteAccountController({organizerId: listing.id});
  const [followRequested, setFollowRequested] = useState(false);
  const [followError, setFollowError] = useState("");
  const followBusy = useRef(false);
  const current = useRef({uid: account.uid, id: listing.id});
  current.current = {uid: account.uid, id: listing.id};
  const followMutation = useMutation({retry: false, gcTime: 0,
    mutationFn: (following: boolean) => setWebsiteOrganizerFollow(listing.id, following, account.uid!)});
  const isFollowing = account.account?.following === true;
  const previousUid = useRef(account.uid);
  useEffect(() => {
    if (previousUid.current && previousUid.current !== account.uid) setFollowRequested(false);
    previousUid.current = account.uid;
    setFollowError("");
  }, [account.uid]);

  useEffect(() => {
    setFollowRequested(false); setFollowError("");
    setShareStatus("");
  }, [listing.id]);

  useEffect(() => observeOrganizerPageView(listing, "listingView", "listing_page"), [listing]);
  useEffect(() => observeOrganizerProviders(listing), [listing]);

  const nav = useMemo<SiteNavItem[]>(() => [
    ...(eventsHref ? [{href: eventsHref, label: organizerPresenceCopy.navigation.events}] : []),
    {href: "#about", label: organizerPresenceCopy.navigation.about},
    {href: "#reviews", label: organizerPresenceCopy.navigation.reviews},
  ], [eventsHref]);

  const footerLinks = useMemo<SiteNavItem[]>(() => [
    {href: "/host/", label: websiteCopy["usehostlistingpagecontroller_0494"]},
    {href: "#profile", label: websiteCopy["usehostlistingpagecontroller_0495"]},
    {href: "#fit", label: isAppCreated ? "Format" : "Fit"},
    ...(listing.sources.length ? [{href: "#sources", label: websiteCopy["usehostlistingpagecontroller_0498"]}] : []),
    {href: "/organizers/", label: websiteCopy["usehostlistingpagecontroller_0497"]},
    ...(policy.canRequestClaim ? [{href: claimHref, label: websiteCopy["usehostlistingpagecontroller_0492"]}] : []),
  ], [claimHref, isAppCreated, listing.sources.length, policy.canRequestClaim]);

  async function changeFollow(following: boolean) {
    if (followBusy.current) return;
    const identity = current.current;
    followBusy.current = true;
    setFollowRequested(false); setFollowError("");
    try {
      await followMutation.mutateAsync(following);
      if (current.current.uid !== identity.uid || current.current.id !== identity.id) return;
      await account.refresh();
    } catch {
      if (current.current.uid === identity.uid && current.current.id === identity.id) {
        setFollowError(accountCopy.followFailed);
      }
    } finally {followBusy.current = false;}
  }
  useEffect(() => {
    if (followRequested && account.ready) void changeFollow(true);
  }, [followRequested, account.ready]);
  function handleFollowListing() {
    if (account.ready) void changeFollow(!isFollowing);
    else setFollowRequested(true);
  }

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
    handleFollowListing,
    account, followRequested, followError, followPending: followMutation.isPending,
    handleShareListing,
    hasEventSupply,
    headerCtaLabel: policy.canRequestClaim ?
      "Claim listing" :
      isAppCreated ? listing.claim.label : "Search organizers",
    isAppCreated,
    isFollowing,
    nav,
    shareStatus,
  };
}

export type HostListingPageController = ReturnType<typeof useHostListingPageController>;
