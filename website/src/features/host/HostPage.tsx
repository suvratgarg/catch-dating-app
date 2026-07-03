import {SiteFooter, SiteHeader, WebsitePageMain} from "../../shared/site";
import type {HostCaptureMap} from "./sections/CaptureFrames";
import {CreateEventWalkthrough} from "./sections/CreateEventWalkthrough";
import {EventSuccessShowcase} from "./sections/EventSuccessShowcase";
import {HostComparisonSection} from "./sections/HostComparisonSection";
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
          {href: "#workflow", label: "Workflow"},
          {href: "#fill-room", label: "Fill room"},
          {href: "#live", label: "Live mode"},
          {href: "#screens", label: "Screens"},
          {href: "/organizers/", label: "Organizers"},
          {href: "/", label: "Member site"},
        ]}
        ctaHref="#founding-hosts"
        ctaLabel="Apply as host"
      />
      <WebsitePageMain id="top">
        <HostHeroSection />
        <HostEvidenceSection />
        <HostWorkflowSection />
        <CreateEventWalkthrough captures={captures} />
        <HostSurfaceSection />
        <HostFillRoomSection />
        <HostLiveModulesSection />
        <EventSuccessShowcase captures={captures} />
        <HostProofLedgerSection />
        <HostComparisonSection />
        <HostCapturesSection captures={captures} />
        <HostApplySection />
      </WebsitePageMain>
      <SiteFooter
        brandHref="/"
        body="Host-led singles events with booking, facilitation, matching, and insight."
        links={[
          {href: "/", label: "Member site"},
          {href: "#workflow", label: "Workflow"},
          {href: "#live", label: "Live mode"},
          {href: "#founding-hosts", label: "Apply"},
        ]}
      />
    </>
  );
}
