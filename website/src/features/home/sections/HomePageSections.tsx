import type {CSSProperties} from "react";
import {websiteCopy} from "@content/generated";
import {SectionHeader} from "../../../shared/site";
import {
  ActionGroup,
  AppDownloadCtaGroup,
  ButtonLink,
  CaptureCard,
  CaptureGrid,
  type CaptureRecord,
  ContentGrid,
  EmptyState,
  FeaturedOrganizerCardGrid,
  FeaturedOrganizersCta,
  HeroAccent,
  HomeHeroBody,
  HomeHeroCopy,
  HomeHeroInner,
  HomeHeroShell,
  HomeHeroStage,
  MarketingFormatCard,
  MarketingInfoCardGrid,
  MarketingLoopList,
  MarketingSection,
  MarketingSectionCopy,
  PhoneCaptureShell,
  PublicEventCard,
  PublicSearchBar,
  type PublicEventCardModel,
  type PublicSearchSuggestion,
  UiLabel,
  WaitlistSection,
} from "../../../shared/ui/primitives";
import {
  capturesFallbackSteps,
  formatCards,
  homeDiscoveryEmptyCopy,
  homeHeroCopy,
  memberLoop,
  trustItems,
} from "@content/marketing";
import {trackCtaClick} from "../../marketing/tracking";
import {useAppDownloadCtas} from "../../marketing/useAppDownloadCtas";
import {hostListings} from "../../organizers/data";
import {featuredOrganizerCardItemForListing} from "../../organizers/featuredOrganizerCardItem";
import {
  publicEventSummaries,
  publicSearchSuggestions,
} from "../../organizers/publicDiscoveryData";
import {
  isPubliclyReadableListing,
  listingProfileStrength,
} from "../../organizers/selectors";
import {WaitlistForm} from "../../waitlist/WaitlistForm";

export function HomeHeroSection({captures}: {captures: Record<string, CaptureRecord>}) {
  const appDownloadCtas = useAppDownloadCtas({placement: "home_hero"});
  const stageCapture = captures["member-event-discovery"];

  return (
    <HomeHeroShell>
      <HomeHeroInner>
        <HomeHeroCopy>
          <UiLabel>{homeHeroCopy.kicker}</UiLabel>
          <h1 data-reveal style={{"--reveal-delay": "70ms"} as CSSProperties}>
            {homeHeroCopy.titleBefore}
            <HeroAccent>{homeHeroCopy.titleAccent}</HeroAccent>
            {homeHeroCopy.titleAfter}
          </h1>
          <HomeHeroBody reveal style={{"--reveal-delay": "150ms"} as CSSProperties}>
            {websiteCopy["homepagesections_0138"]}
          </HomeHeroBody>
          <ActionGroup
            reveal
            style={{"--reveal-delay": "230ms"} as CSSProperties}
            variant="hero"
          >
            <ButtonLink
              href="/organizers/"
              onClick={() => trackCtaClick("home_hero_browse_events", "/organizers/")}
            >{websiteCopy["homepagesections_0124"]}</ButtonLink>
            <ButtonLink
              variant="ghost"
              href="/host/"
              onClick={() => trackCtaClick("home_hero_apply_host", "/host/")}
            >{websiteCopy["homepagesections_0121"]}</ButtonLink>
          </ActionGroup>
          <AppDownloadCtaGroup {...appDownloadCtas} />
        </HomeHeroCopy>

        <HomeHeroStage data-reveal="scale" style={{"--reveal-delay": "300ms"} as CSSProperties}>
          <PhoneCaptureShell
            caption={stageCapture?.caption ?? homeHeroCopy.stageCaption}
            captureSlotId="member-event-discovery"
          >
            <img
              src={stageCapture?.webPath ?? "/assets/app-screenshots/placeholders/member-event-discovery.svg"}
              alt={stageCapture?.alt ?? homeHeroCopy.stageCaption}
              decoding="async"
            />
          </PhoneCaptureShell>
        </HomeHeroStage>
      </HomeHeroInner>
    </HomeHeroShell>
  );
}

export function HomeDiscoverySection({
  events = publicEventSummaries,
}: {
  events?: PublicEventCardModel[];
} = {}) {
  const visibleEvents = events.slice(0, 3);
  return (
    <MarketingSection variant="home-discovery" id="events" aria-labelledby="home-events-title">
      <SectionHeader
        eyebrow={websiteCopy["homepagesections_0139"]}
        id="home-events-title"
        title={websiteCopy["homepagesections_0163"]}
        body={websiteCopy["homepagesections_0166"]}
        wide
      />
      <PublicSearchBar
        cityHref="/organizers/"
        cityName={visibleEvents[0]?.city ?? "Your city"}
        onCityClick={trackPublicSearchCityClick}
        onSearchSubmit={trackPublicSearchSubmit}
        onSuggestionClick={trackPublicSearchSuggestionClick}
        searchHrefForQuery={publicSearchHrefForQuery}
        suggestions={publicSearchSuggestions}
      />
      <ContentGrid variant="public-event">
        {visibleEvents.length ? (
          visibleEvents.map((event, index) => (
            <PublicEventCard
              event={event}
              key={event.id}
              onCardClick={trackPublicEventCardClick}
              style={{"--reveal-delay": `${index * 90}ms`} as CSSProperties}
            />
          ))
        ) : (
          <EmptyState variant="public-event" reveal>
            <strong>{homeDiscoveryEmptyCopy.title}</strong>
            <p>{homeDiscoveryEmptyCopy.body}</p>
            <ButtonLink variant="ghost" href="/organizers/">{websiteCopy["homepagesections_0152"]}</ButtonLink>
          </EmptyState>
        )}
      </ContentGrid>
    </MarketingSection>
  );
}

function trackPublicEventCardClick(event: PublicEventCardModel) {
  trackCtaClick("public_event_card", event.href);
}

function publicSearchHrefForQuery(query: string) {
  return query ? `/organizers/?q=${encodeURIComponent(query)}` : "/organizers/";
}

function trackPublicSearchCityClick(href: string) {
  trackCtaClick("public_search_city", href);
  window.location.assign(href);
}

function trackPublicSearchSubmit(href: string) {
  trackCtaClick("public_search_submit", href);
  window.location.assign(href);
}

function trackPublicSearchSuggestionClick(suggestion: PublicSearchSuggestion) {
  trackCtaClick(`public_search_${suggestion.type}`, suggestion.href);
}

export function HomeFormatsSection() {
  return (
    <MarketingSection variant="format" id="formats" aria-labelledby="formats-title">
      <SectionHeader
        id="formats-title"
        title={websiteCopy["homepagesections_0150"]}
        body={websiteCopy["homepagesections_0130"]}
      />

      <ContentGrid variant="format">
        {formatCards.map((card) => (
          <MarketingFormatCard
            body={card.body}
            key={card.mark}
            mark={card.mark}
            title={card.title}
          />
        ))}
      </ContentGrid>
    </MarketingSection>
  );
}

export function HomeFeaturedOrganizersSection() {
  const featured = hostListings
    .filter(isPubliclyReadableListing)
    .slice()
    .sort((a, b) => listingProfileStrength(b) - listingProfileStrength(a))
    .slice(0, 3);
  const featuredItems = featured.map(featuredOrganizerCardItemForListing);

  return (
    <MarketingSection variant="featured-organizers" aria-labelledby="featured-organizers-title">
      <SectionHeader
        eyebrow={websiteCopy["homepagesections_0153"]}
        id="featured-organizers-title"
        title={websiteCopy["homepagesections_0165"]}
        body={websiteCopy["homepagesections_0159"]}
      />
      <FeaturedOrganizerCardGrid items={featuredItems} />
      <FeaturedOrganizersCta
        body={websiteCopy["homepagesections_0158"]}
        reveal
      >
        <ButtonLink
          variant="ghost-light"
          href="/organizers/"
          onClick={() => trackCtaClick("home_featured_organizers", "/organizers/")}
        >{websiteCopy["homepagesections_0151"]}</ButtonLink>
      </FeaturedOrganizersCta>
    </MarketingSection>
  );
}

export function HomeMemberLoopSection() {
  return (
    <MarketingSection variant="story" id="members" aria-labelledby="loop-title">
      <SectionHeader id="loop-title" title={websiteCopy["homepagesections_0119"]} wide />
      <MarketingLoopList items={memberLoop} />
    </MarketingSection>
  );
}

export function HomeHostProofSection({captures}: {captures: Record<string, CaptureRecord>}) {
  return (
    <MarketingSection variant="proof" id="hosts">
      <MarketingSectionCopy
        body={websiteCopy["homepagesections_0128"]}
        title={websiteCopy["homepagesections_0140"]}
        variant="proof"
      >
        <ButtonLink
          variant="ghost-light"
          href="/host/"
          onClick={() => trackCtaClick("host_tools_section", "/host/")}
        >{websiteCopy["homepagesections_0160"]}</ButtonLink>
      </MarketingSectionCopy>

      <CaptureGrid>
        <CaptureCard id="host-event-setup" fallbackStep={capturesFallbackSteps.setup} captures={captures} />
        <CaptureCard id="host-live-console" fallbackStep={capturesFallbackSteps.live} captures={captures} />
        <CaptureCard id="host-post-event-report" fallbackStep={capturesFallbackSteps.report} captures={captures} />
      </CaptureGrid>
    </MarketingSection>
  );
}

export function HomeCapturesSection({captures}: {captures: Record<string, CaptureRecord>}) {
  return (
    <MarketingSection variant="captures" aria-labelledby="app-proof-title">
      <SectionHeader
        id="app-proof-title"
        title={websiteCopy["homepagesections_0161"]}
        body={websiteCopy["homepagesections_0125"]}
      />

      <CaptureGrid>
        <CaptureCard id="member-event-discovery" fallbackStep={capturesFallbackSteps.discover} captures={captures} />
        <CaptureCard id="post-run-catch-window" fallbackStep={capturesFallbackSteps.unlock} captures={captures} />
        <CaptureCard id="match-chat-context" fallbackStep={capturesFallbackSteps.match} captures={captures} />
      </CaptureGrid>
    </MarketingSection>
  );
}

export function HomeDownloadSection() {
  const appDownloadCtas = useAppDownloadCtas({placement: "home_download_section"});

  return (
    <MarketingSection variant="download" id="download-app" aria-labelledby="download-title">
      <MarketingSectionCopy
        body={websiteCopy["homepagesections_0164"]}
        eyebrow={websiteCopy["homepagesections_0148"]}
        title={websiteCopy["homepagesections_0136"]}
        titleId="download-title"
        variant="download"
      />
      <AppDownloadCtaGroup {...appDownloadCtas} variant="panel" />
    </MarketingSection>
  );
}

export function HomeTrustSection() {
  return (
    <MarketingSection variant="trust" id="trust" aria-labelledby="trust-title">
      <SectionHeader
        id="trust-title"
        title={websiteCopy["homepagesections_0133"]}
      />

      <MarketingInfoCardGrid items={trustItems} variant="trust" />
    </MarketingSection>
  );
}

export function HomeWaitlistSection() {
  return (
    <WaitlistSection
      id="waitlist"
      titleId="waitlist-title"
      title={websiteCopy["homepagesections_0122"]}
      body={websiteCopy["homepagesections_0145"]}
      tone="dark"
    >
      <WaitlistForm variant="member" />
    </WaitlistSection>
  );
}
