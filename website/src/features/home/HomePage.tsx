import {ConsumerHome} from "../../shared/ui/primitives/consumerHome";
import {organiserHomeCopy} from "@content/marketingOrganization";
import {renderConsumerHero, renderConsumerEvents, renderConsumerStory} from "./sections/consumerHomeSections";
import {useConsumerHomeController} from "./useConsumerHomeController";
import type {HomeCategory} from "./homeDiscovery";
type HomeRouteState = {city: string; category: HomeCategory};
import {websiteCopy} from "@content/generated";
import {
  HomeCapturesSection,
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

export function VisitorDiscoveryPage({captures, routeState}: {captures: Record<string, CaptureRecord>; routeState?: HomeRouteState}) {
  const home = useConsumerHomeController(routeState?.city, routeState?.category);
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
        localActions={[{href: "#events", label: organiserHomeCopy.actions.attend.label}]}
      />
      <WebsitePageMain id="top">
        <HomeHeroSection captures={captures} />
        <ConsumerHome >{renderConsumerEvents(home, true)}</ConsumerHome>
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

export function HomePage({routeState}: {captures: Record<string, CaptureRecord>; routeState?: HomeRouteState}) {
  const home = useConsumerHomeController(routeState?.city, routeState?.category);
  return <ConsumerHome >
    <PublicSiteHeader audience="consumer" />
    <WebsitePageMain id="top">{renderConsumerHero(home)}{renderConsumerEvents(home)}{renderConsumerStory(home)}</WebsitePageMain>
    <PublicSiteFooter audience="consumer" />
  </ConsumerHome>;
}
