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
  ControlRow,
  EmptyState,
  EventTicketMeta,
  EventTicketStatus,
  FeaturedOrganizerCardGrid,
  FeaturedOrganizersCta,
  HomeHeroBody,
  HomeHeroCopy,
  HomeHeroInner,
  HomeHeroMedia,
  HomeHeroShell,
  LiveMeter,
  MarketingInfoCardGrid,
  MarketingLoopList,
  MarketingFormatCard,
  MarketingSection,
  MarketingSectionCopy,
  PanelShell,
  PublicEventCard,
  PublicSearchBar,
  type PublicEventCardModel,
  type PublicSearchSuggestion,
  ProductBoardCard,
  ProductBoardMain,
  ProductBoardNav,
  ProductShell,
  UiLabel,
  WaitlistSection,
} from "../../../shared/ui/primitives";
import {
  formatCards,
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

export function HomeHeroSection() {
  const appDownloadCtas = useAppDownloadCtas({placement: "home_hero"});

  return (
    <HomeHeroShell>
      <HomeHeroMedia aria-hidden="true">
        <img
          src="/assets/marketing/catch-hero-event-1280.jpg"
          srcSet="/assets/marketing/catch-hero-event-960.jpg 960w, /assets/marketing/catch-hero-event-1280.jpg 1280w, /assets/marketing/catch-hero-event-1680.jpg 1680w"
          sizes="100vw"
          width="1681"
          height="936"
          fetchPriority="high"
          decoding="async"
          alt=""
        />
      </HomeHeroMedia>

      <HomeHeroInner>
        <HomeHeroCopy>
          <h1 data-reveal>{websiteCopy["homepagesections_0157"]}</h1>
          <HomeHeroBody reveal>{websiteCopy["homepagesections_0138"]}</HomeHeroBody>
          <ActionGroup variant="hero" reveal>
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

        <PanelShell variant="hero" as="aside" aria-label={websiteCopy["homepagesections_0127"]} reveal>
          <PanelShell variant="event-ticket">
            <div>
              <UiLabel>{websiteCopy["homepagesections_0167"]}</UiLabel>
              <h2>{websiteCopy["homepagesections_0137"]}</h2>
            </div>
            <EventTicketStatus>{websiteCopy["homepagesections_0156"]}</EventTicketStatus>
          </PanelShell>
          <EventTicketMeta>
            <span>{websiteCopy["homepagesections_0134"]}</span>
            <span>{websiteCopy["homepagesections_0162"]}</span>
            <span>{websiteCopy["homepagesections_0144"]}</span>
            <span>{websiteCopy["homepagesections_0168"]}</span>
          </EventTicketMeta>
        </PanelShell>
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
          visibleEvents.map((event) => (
            <PublicEventCard
              event={event}
              key={event.id}
              onCardClick={trackPublicEventCardClick}
            />
          ))
        ) : (
          <EmptyState variant="public-event" reveal>
            <strong>{websiteCopy["homepagesections_0149"]}</strong>
            <p>{websiteCopy["homepagesections_0123"]}</p>
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

export function HomeHostProofSection() {
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

      <HostProductBoard />
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
        <CaptureCard id="member-event-discovery" fallbackStep={websiteCopy["homepagesections_0135"]} captures={captures} />
        <CaptureCard id="post-run-catch-window" fallbackStep={websiteCopy["homepagesections_0126"]} captures={captures} />
        <CaptureCard id="host-live-console" fallbackStep={websiteCopy["homepagesections_0142"]} captures={captures} />
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
    >
      <WaitlistForm variant="member" />
    </WaitlistSection>
  );
}

function HostProductBoard() {
  return (
    <ProductShell variant="product-board" aria-label={websiteCopy["homepagesections_0129"]} reveal>
      <ProductBoardNav
        items={["Format", "Admission", "Live", "Report"].map((item) => ({
          key: item,
          label: item,
        }))}
      />
      <ProductBoardMain>
        <ProductBoardCard>
          <UiLabel>{websiteCopy["homepagesections_0132"]}</UiLabel>
          <h3>{websiteCopy["homepagesections_0155"]}</h3>
          <p>{websiteCopy["homepagesections_0154"]}</p>
          <ControlRow label={websiteCopy["homepagesections_0141"]} value="Racket sports" />
          <ControlRow label={websiteCopy["homepagesections_0120"]} value="Invite code + public waitlist" />
          <ControlRow label={websiteCopy["homepagesections_0147"]} value="Partner switch" />
        </ProductBoardCard>
        <ProductBoardCard tone="dark">
          <UiLabel>{websiteCopy["homepagesections_0146"]}</UiLabel>
          <h3>{websiteCopy["homepagesections_0143"]}</h3>
          <p>{websiteCopy["homepagesections_0131"]}</p>
          <LiveMeter items={["Arrival", "Prompt", "Reveal"]} />
        </ProductBoardCard>
      </ProductBoardMain>
    </ProductShell>
  );
}
