import {websiteCopy} from "@content/generated";
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
  HostCapturesSection,
  HostEvidenceSection,
  HostFillRoomSection,
  HostHeroSection,
  HostLiveModulesSection,
  HostProofLedgerSection,
  HostSurfaceSection,
  HostWorkflowSection,
} from "./sections/HostPageSections";

export function HostPage({captures}: {captures: HostCaptureMap}) {
  return (
    <>
      <SiteHeader
        brandHref="/"
        nav={[
          {href: "#workflow", label: websiteCopy["hostpage_0275"]},
          {href: "#fill-room", label: websiteCopy["hostpage_0269"]},
          {href: "#live", label: websiteCopy["hostpage_0271"]},
          {href: "#screens", label: websiteCopy["hostpage_0274"]},
          {href: "/organizers/", label: websiteCopy["hostpage_0273"]},
          {href: "/", label: websiteCopy["hostpage_0272"]},
        ]}
        ctaHref="#founding-hosts"
        ctaLabel={websiteCopy["hostpage_0268"]}
      />
      <WebsitePageMain id="top">
        <HostHeroSection />
        <HostFoundingOfferSection />
        <HostEvidenceSection />
        <HostWorkflowSection />
        <CreateEventWalkthrough captures={captures} />
        <HostSurfaceSection />
        <HostFillRoomSection />
        <HostLiveModulesSection />
        <PlaybookShowcase captures={captures} />
        <HostProofLedgerSection />
        <HostComparisonSection />
        <HostTrustSection />
        <HostFaqSection />
        <HostCapturesSection captures={captures} />
        <HostApplySection />
      </WebsitePageMain>
      <SiteFooter
        brandHref="/"
        body={websiteCopy["hostpage_0270"]}
        links={[
          {href: "/", label: websiteCopy["hostpage_0272"]},
          {href: "#workflow", label: websiteCopy["hostpage_0275"]},
          {href: "#live", label: websiteCopy["hostpage_0271"]},
          {href: "#founding-hosts", label: websiteCopy["hostpage_0267"]},
        ]}
      />
    </>
  );
}
