import {websiteCopy} from "@content/generated";
import {siteFooterLegalLinks} from "@content/site";
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
          {href: "#events", label: websiteCopy["homepage_0110"]},
          {href: "#formats", label: websiteCopy["homepage_0112"]},
          {href: "#members", label: websiteCopy["homepage_0115"]},
          {href: "#hosts", label: websiteCopy["homepage_0113"]},
          {href: "#trust", label: websiteCopy["homepage_0117"]},
          {href: "/organizers/", label: websiteCopy["homepage_0116"]},
          {href: "/host/", label: websiteCopy["homepage_0111"]},
        ]}
        ctaHref="#waitlist"
        ctaLabel={websiteCopy["homepage_0114"]}
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
        body={websiteCopy["homepage_0108"]}
        links={[
          {href: "/host/", label: websiteCopy["homepage_0111"]},
          {href: "#formats", label: websiteCopy["homepage_0112"]},
          {href: "#download-app", label: websiteCopy["homepage_0109"]},
          {href: "#trust", label: websiteCopy["homepage_0117"]},
          {href: "#waitlist", label: websiteCopy["homepage_0118"]},
          ...siteFooterLegalLinks,
        ]}
      />
    </>
  );
}
