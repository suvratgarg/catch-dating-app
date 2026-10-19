import {hostLandingCopy} from "@content/hostLanding";
import {PublicSiteFooter, PublicSiteHeader, WebsitePageMain} from "../../shared/site";
import {HostLanding} from "../../shared/ui/primitives/hostLanding";
import type {HostCaptureMap} from "./sections/CaptureFrames";
import {renderHostLandingHero, renderHostLandingBenefits, renderHostFormatExplorer, renderHostLandingInsights, renderHostLandingAdoption, renderHostLandingFaq, renderHostLandingClose} from "./sections/hostLandingSections";

export function HostPage(_props: {captures: HostCaptureMap}) {
  return <HostLanding>
    <PublicSiteHeader audience="guest" localNav={hostLandingCopy.nav} localActions={[{href: "/host/apply/", label: hostLandingCopy.apply}]} />
    <WebsitePageMain id="top">
      {renderHostLandingHero()}
      {renderHostLandingBenefits()}
      {renderHostFormatExplorer()}
      {renderHostLandingInsights()}
      {renderHostLandingAdoption()}
      {renderHostLandingFaq()}
      {renderHostLandingClose()}
    </WebsitePageMain>
    <PublicSiteFooter audience="consumer" />
  </HostLanding>;
}
