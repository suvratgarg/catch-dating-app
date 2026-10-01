import {organiserHomeCopy} from "@content/marketingOrganization";
import {renderOrganiserHomeSections} from "./sections/OrganiserHomeSections";
import {websiteCopy} from "@content/generated";
import {siteFooterLegalLinks, siteMenuCopy} from "@content/site";
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

export function VisitorDiscoveryPage({captures}: {captures: Record<string, CaptureRecord>}) {
  return (
    <>
      <SiteHeader
        brandHref="#top"
        menuCopy={siteMenuCopy}
        tone="dark"
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

export function HomePage(_props: {captures: Record<string, CaptureRecord>}) {
  return (
    <>
      <SiteHeader
        brandHref="#top"
        menuCopy={organiserHomeCopy.menu}
        tone="dark"
        nav={[...organiserHomeCopy.nav]}
        actions={[
          {...organiserHomeCopy.actions.signIn, variant: "secondary"},
          organiserHomeCopy.actions.start,
        ]}
      />
      <WebsitePageMain id="top">{renderOrganiserHomeSections()}</WebsitePageMain>
      <SiteFooter
        brandHref="#top"
        body={organiserHomeCopy.footer}
        links={[
          ...organiserHomeCopy.nav,
          organiserHomeCopy.explore.directory,
          organiserHomeCopy.explore.visitors,
          ...siteFooterLegalLinks,
        ]}
      />
    </>
  );
}
