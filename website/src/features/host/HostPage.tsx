import {hostPageCopy} from "@content/host";
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
        nav={[
          {href: "#workflow", label: hostPageCopy.nav.workflow},
          {href: "#live", label: hostPageCopy.nav.liveTools},
          {href: "#works-now", label: hostPageCopy.nav.worksNow},
          {href: "#coming-soon", label: hostPageCopy.nav.comingSoon},
          {href: "/organizers/", label: hostPageCopy.nav.organizers},
        ]}
        ctaHref="#founding-hosts"
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
          {href: "#workflow", label: hostPageCopy.nav.workflow},
          {href: "#live", label: hostPageCopy.nav.liveTools},
          {href: "#coming-soon", label: hostPageCopy.nav.comingSoon},
          {href: "#founding-hosts", label: hostPageCopy.nav.apply},
          ...siteFooterLegalLinks,
        ]}
      />
    </>
  );
}
