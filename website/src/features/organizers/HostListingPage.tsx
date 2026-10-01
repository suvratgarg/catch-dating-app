import {websiteCopy} from "@content/generated";
import {PublicSiteFooter, PublicSiteHeader, WebsitePageMain} from "../../shared/site";
import type {HostListing} from "./types";
import {useListingClaimController} from "../claims/useListingClaimController";
import {HostListingSections} from "./sections/HostListingSections";
import {useHostListingPageController} from "./useHostListingPageController";

export function HostListingPage({listing}: {listing: HostListing}) {
  const controller = useHostListingPageController(listing);
  const claimController = useListingClaimController(listing);

  return (
    <>
      <PublicSiteHeader
        localNav={controller.nav}
        localActions={[{href: controller.claimHref, label: controller.headerCtaLabel}]}
      />

      <WebsitePageMain id="profile">
        <HostListingSections
          claimController={claimController}
          controller={controller}
          listing={listing}
        />
      </WebsitePageMain>

      <PublicSiteFooter
        body={websiteCopy["hostlistingpage_0346"]}
        links={[...controller.footerLinks]}
      />
    </>
  );
}
