import {hostPageCopy, hostSiteActions, hostSiteNavigation} from "@content/host";
import {hostConceptCopy} from "@content/hostConceptNavigation";
import {PublicSiteFooter, PublicSiteHeader, WebsitePageMain} from "../../shared/site";
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
      <PublicSiteHeader
        tone="dark"
        localNav={[...hostSiteNavigation, hostConceptCopy.nav[0]]}
        localActions={[{href: hostSiteActions.apply, label: hostPageCopy.nav.apply}]}
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
      <PublicSiteFooter
        body={hostPageCopy.footer}
        links={[
          ...hostSiteNavigation.filter((item) => item.footer),
          {href: hostSiteActions.apply, label: hostPageCopy.nav.apply},
          ...hostConceptCopy.nav,
          ...hostConceptCopy.personaLinks,
          ...hostConceptCopy.additionalLinks,
        ]}
      />
    </>
  );
}
