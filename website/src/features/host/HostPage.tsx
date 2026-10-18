import {hostPageCopy, hostSiteActions, hostSiteNavigation} from "@content/host";
import {renderHostFeatures, renderHostWorkflows, renderHostUseCases, renderHostExistingTools, renderHostPricing} from "./sections/hostProductSections";
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
        localNav={hostSiteNavigation}
        localActions={[{href: hostSiteActions.apply, label: hostPageCopy.nav.apply}]}
      />
      <WebsitePageMain id="top">
        <HostHeroSection captures={captures} />
        {renderHostFeatures()}
        <HostWorkflowSection />
        {renderHostWorkflows()}
        {renderHostUseCases()}
        <CreateEventWalkthrough captures={captures} />
        <HostLiveModulesSection />
        <PlaybookShowcase captures={captures} />
        <HostComparisonSection />
        {renderHostExistingTools()}
        <HostTrustSection />
        <HostProofLedgerSection />
        <HostFaqSection />
        <HostFoundingOfferSection />
        {renderHostPricing()}
      </WebsitePageMain>
      <PublicSiteFooter
        body={hostPageCopy.footer}
        links={[
          ...hostSiteNavigation.filter((item) => item.footer),
          {href: hostSiteActions.apply, label: hostPageCopy.nav.apply},
        ]}
      />
    </>
  );
}
