import {
  HomeCapturesSection,
  HomeDiscoverySection,
  HomeDownloadSection,
  HomeFeaturedOrganizersSection,
  HomeFormatsSection,
  HomeHeroSection,
  HomeHostProofSection,
  HomeMemberLoopSection,
  HomeTrustSection,
  HomeWaitlistSection,
} from "./sections/HomePageSections";
import type {CaptureRecord} from "../../shared/ui/primitives";
import {
  SiteFooter,
  SiteHeader,
  WebsitePageMain,
} from "../../shared/site";

export function HomePage({captures}: {captures: Record<string, CaptureRecord>}) {
  return (
    <>
      <SiteHeader
        brandHref="#top"
        nav={[
          {href: "#events", label: "Events"},
          {href: "#formats", label: "Formats"},
          {href: "#members", label: "Members"},
          {href: "#hosts", label: "Hosts"},
          {href: "#trust", label: "Trust"},
          {href: "/organizers/", label: "Organizers"},
          {href: "/host/", label: "For hosts"},
        ]}
        ctaHref="#waitlist"
        ctaLabel="Join waitlist"
      />
      <WebsitePageMain id="top">
        <HomeHeroSection />
        <HomeDiscoverySection />
        <HomeFormatsSection />
        <HomeFeaturedOrganizersSection />
        <HomeMemberLoopSection />
        <HomeHostProofSection />
        <HomeCapturesSection captures={captures} />
        <HomeDownloadSection />
        <HomeTrustSection />
        <HomeWaitlistSection />
      </WebsitePageMain>
      <SiteFooter
        brandHref="#top"
        body="Curated singles events. Real context. Better conversations."
        links={[
          {href: "/host/", label: "For hosts"},
          {href: "#formats", label: "Formats"},
          {href: "#download-app", label: "Download"},
          {href: "#trust", label: "Trust"},
          {href: "#waitlist", label: "Waitlist"},
        ]}
      />
    </>
  );
}
