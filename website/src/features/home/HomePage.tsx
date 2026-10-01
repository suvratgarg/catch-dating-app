import {organiserHomeCopy} from "@content/marketingOrganization";
import {renderOrganiserHomeSections} from "./sections/OrganiserHomeSections";
import {websiteCopy} from "@content/generated";
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
  PublicSiteFooter,
  PublicSiteHeader,
  WebsitePageMain,
} from "../../shared/site";

export function VisitorDiscoveryPage({captures}: {captures: Record<string, CaptureRecord>}) {
  return (
    <>
      <PublicSiteHeader
        tone="dark"
        localNav={[
          {href: "#events", label: websiteCopy["homepage_0110"]},
          {href: "#formats", label: websiteCopy["homepage_0112"]},
          {href: "#members", label: websiteCopy["homepage_0115"]},
          {href: "#hosts", label: websiteCopy["homepage_0113"]},
          {href: "#trust", label: websiteCopy["homepage_0117"]},
          {href: "/organizers/", label: websiteCopy["homepage_0116"]},
          {href: "/host/", label: websiteCopy["homepage_0111"]},
        ]}
        localActions={[{href: "#waitlist", label: websiteCopy["homepage_0114"]}]}
      />
      <WebsitePageMain id="top">
        <HomeHeroSection captures={captures} />
        <HomeDiscoverySection />
        <HomeFormatsSection />
        <HomeFeaturedOrganizersSection />
        <HomeMemberLoopSection />
        <HomeHostProofSection captures={captures} />
        <HomeCapturesSection captures={captures} />
        <HomeDownloadSection />
        <HomeTrustSection />
        <HomeWaitlistSection />
      </WebsitePageMain>
      <PublicSiteFooter
        body={websiteCopy["homepage_0108"]}
        links={[
          {href: "/host/", label: websiteCopy["homepage_0111"]},
          {href: "#formats", label: websiteCopy["homepage_0112"]},
          {href: "#download-app", label: websiteCopy["homepage_0109"]},
          {href: "#trust", label: websiteCopy["homepage_0117"]},
          {href: "#waitlist", label: websiteCopy["homepage_0118"]},
        ]}
      />
    </>
  );
}

export function HomePage(_props: {captures: Record<string, CaptureRecord>}) {
  return (
    <>
      <PublicSiteHeader tone="dark" />
      <WebsitePageMain id="top">{renderOrganiserHomeSections()}</WebsitePageMain>
      <PublicSiteFooter
        body={organiserHomeCopy.footer}
        links={[
          ...organiserHomeCopy.nav,
          organiserHomeCopy.explore.directory,
          organiserHomeCopy.explore.visitors,
        ]}
      />
    </>
  );
}
