import {websiteCopy} from "@content/generated";
import {siteFooterLegalLinks} from "@content/site";
import {SiteFooter, SiteHeader, WebsitePageMain} from "../../shared/site";
import type {HostListing} from "./types";
import {useListingClaimController} from "../claims/useListingClaimController";
import {HostListingSections} from "./sections/HostListingSections";
import {useHostListingPageController} from "./useHostListingPageController";

export function HostListingPage({listing}: {listing: HostListing}) {
  const controller = useHostListingPageController(listing);
  const claimController = useListingClaimController(listing);

  return (
    <>
      <SiteHeader
        brandHref="/"
        nav={controller.nav}
        ctaHref={controller.claimHref}
        ctaLabel={controller.headerCtaLabel}
      />

      <WebsitePageMain id="profile">
        <HostListingSections
          claimController={claimController}
          controller={controller}
          listing={listing}
        />
      </WebsitePageMain>

      <SiteFooter
        brandHref="/"
        body={websiteCopy["hostlistingpage_0346"]}
        links={[...controller.footerLinks, ...siteFooterLegalLinks]}
      />
    </>
  );
}
