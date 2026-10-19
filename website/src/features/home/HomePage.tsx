import {ConsumerHome} from "../../shared/ui/primitives/consumerHome";
import {renderConsumerHero, renderConsumerEvents, renderConsumerStory} from "./sections/consumerHomeSections";
import {useConsumerHomeController} from "./useConsumerHomeController";
import type {HomeCategory} from "./homeDiscovery";
type HomeRouteState = {city: string; category: HomeCategory};
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
      <PublicSiteHeader audience="consumer" />
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
      <PublicSiteFooter audience="consumer" />
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
