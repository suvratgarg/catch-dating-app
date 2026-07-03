import {SiteFooter, SiteHeader} from "../../shared/site";
import {HostPreviewMain} from "../../shared/ui/primitives";
import type {HostCaptureMap} from "./sections/CaptureFrames";
import {HostComparisonSection} from "./sections/HostComparisonSection";
import {
  HostPreviewAdmissionSection,
  HostPreviewAfterSection,
  HostPreviewApplySection,
  HostPreviewCreateFlowSection,
  HostPreviewFaqSection,
  HostPreviewFormatsSection,
  HostPreviewHeroSection,
  HostPreviewLiveSection,
  HostPreviewOfferSection,
  HostPreviewOperatingLoopSection,
  HostPreviewPaymentsSection,
  HostPreviewTrustSection,
} from "./sections/HostPreviewSections";

export function HostPreviewPage({captures}: {captures: HostCaptureMap}) {
  return (
    <>
      <SiteHeader
        brandHref="/"
        nav={[
          {href: "#offer", label: "Offer"},
          {href: "#formats", label: "Formats"},
          {href: "#operating-loop", label: "Workflow"},
          {href: "#create-flow", label: "Create flow"},
          {href: "#founding-hosts", label: "Apply"},
        ]}
        ctaHref="#founding-hosts"
        ctaLabel="Apply for founding host access"
      />

      <HostPreviewMain id="top">
        <HostPreviewHeroSection captures={captures} />
        <HostPreviewOfferSection />
        <HostPreviewFormatsSection />
        <HostComparisonSection />
        <HostPreviewOperatingLoopSection />
        <HostPreviewCreateFlowSection captures={captures} />
        <HostPreviewAdmissionSection />
        <HostPreviewPaymentsSection />
        <HostPreviewLiveSection captures={captures} />
        <HostPreviewAfterSection captures={captures} />
        <HostPreviewTrustSection />
        <HostPreviewFaqSection />
        <HostPreviewApplySection />
      </HostPreviewMain>

      <SiteFooter
        brandHref="/"
        body="Host-led social events with admission, payments, live facilitation, matching, and insight."
        links={[
          {href: "/host/", label: "Current host page"},
          {href: "#offer", label: "Founding offer"},
          {href: "#create-flow", label: "Create flow"},
          {href: "#founding-hosts", label: "Apply"},
        ]}
      />
    </>
  );
}
