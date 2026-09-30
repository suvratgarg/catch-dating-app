import {hostPageCopy, hostSiteActions, hostSiteNavigation} from "@content/host";
import {siteFooterLegalLinks, siteMenuCopy} from "@content/site";
import {SiteFooter, SiteHeader, WebsitePageMain} from "../../shared/site";
import type {HostCaptureMap} from "./sections/CaptureFrames";
import {CreateEventWalkthrough} from "./sections/CreateEventWalkthrough";
import {PlaybookShowcase} from "./sections/PlaybookShowcase";
import {HostComparisonSection} from "./sections/HostComparisonSection";
import {
  HostFaqSection,
  HostFoundingOfferSection,
  HostTrustSection,
} from "./sections/HostSupportingSections";
import {
  HostApplySection,
  HostHeroSection,
  HostLiveModulesSection,
  HostProofLedgerSection,
  HostWorkflowSection,
} from "./sections/HostPageSections";

export function HostPage({captures}: {captures: HostCaptureMap}) {
  return (
    <>
      <SiteHeader
        brandHref="/"
        menuCopy={siteMenuCopy}
        tone="dark"
        nav={[...hostSiteNavigation]}
        ctaHref={hostSiteActions.apply}
        ctaLabel={hostPageCopy.nav.apply}
      />
      <WebsitePageMain id="top">
        <HostHeroSection captures={captures} />
        <HostWorkflowSection />
        <CreateEventWalkthrough captures={captures} />
        <HostLiveModulesSection />
        <PlaybookShowcase captures={captures} />
        <HostComparisonSection />
        <HostTrustSection />
        <HostProofLedgerSection />
        <HostFaqSection />
        <HostFoundingOfferSection />
        <HostApplySection />
      </WebsitePageMain>
      <SiteFooter
        brandHref="/"
        body={hostPageCopy.footer}
        links={[
          ...hostSiteNavigation.filter((item) => item.footer),
          {href: hostSiteActions.apply, label: hostPageCopy.nav.apply},
          ...siteFooterLegalLinks,
        ]}
      />
    </>
  );
}
