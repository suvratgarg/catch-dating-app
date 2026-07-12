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
} from "../../marketing/content";
import {trackCtaClick} from "../../marketing/tracking";
import {useAppDownloadCtas} from "../../marketing/useAppDownloadCtas";
import {hostListings} from "../../organizers/data";
import {featuredOrganizerCardItemForListing} from "../../organizers/featuredOrganizerCardItem";
import {
  publicEventSummaries,
  publicSearchSuggestions,
} from "../../organizers/publicDiscoveryData";
import {listingProfileStrength} from "../../organizers/selectors";
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
          <h1 data-reveal>Real events. Real hosts. The match comes after.</h1>
          <HomeHeroBody reveal>
            Find a hosted run, dinner, game night, or mixer near you. Show
            up in person, then catch privately with people you actually met.
          </HomeHeroBody>
          <ActionGroup variant="hero" reveal>
            <ButtonLink
              href="/organizers/"
              onClick={() => trackCtaClick("home_hero_browse_events", "/organizers/")}
            >
              Browse organizers
            </ButtonLink>
            <ButtonLink
              variant="ghost"
              href="/host/"
              onClick={() => trackCtaClick("home_hero_apply_host", "/host/")}
            >
              Apply as host
            </ButtonLink>
          </ActionGroup>
          <AppDownloadCtaGroup {...appDownloadCtas} />
        </HomeHeroCopy>

        <PanelShell variant="hero" as="aside" aria-label="Catch event panel" reveal>
          <PanelShell variant="event-ticket">
            <div>
              <UiLabel>This week</UiLabel>
              <h2>Events with a reason to talk</h2>
            </div>
            <EventTicketStatus>
              Private catches open only after attendance
            </EventTicketStatus>
          </PanelShell>
          <EventTicketMeta>
            <span>Dinner</span>
            <span>Social run</span>
            <span>Host-led prompts</span>
            <span>Verified reviews</span>
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
        eyebrow="Find events"
        id="home-events-title"
        title="Start with what is happening, then choose who to meet."
        body="The public website now treats events and organizer pages as one discovery loop: search the city, browse a real host page, then continue into the app when the event opens."
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
            <strong>No public Catch events are projected yet.</strong>
            <p>
              Browse organizer pages while event projections are added to the
              public website feed.
            </p>
            <ButtonLink variant="ghost" href="/organizers/">
              Open organizer directory
            </ButtonLink>
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
        title="Not another swipe feed. A better way to meet."
        body="Catch is format-aware: every event can carry the right amount of structure, from light social flow to guided rotations and reveal moments."
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
    .slice()
    .sort((a, b) => listingProfileStrength(b) - listingProfileStrength(a))
    .slice(0, 3);
  const featuredItems = featured.map(featuredOrganizerCardItemForListing);

  return (
    <MarketingSection variant="featured-organizers" aria-labelledby="featured-organizers-title">
      <SectionHeader
        eyebrow="Organizer directory"
        id="featured-organizers-title"
        title="The public loop starts with real host pages."
        body="Searchable organizer profiles create a concrete path from discovery to claim, reviews, host tools, events, and app usage."
      />
      <FeaturedOrganizerCardGrid items={featuredItems} />
      <FeaturedOrganizersCta
        body="Run events? Your profile can show public sources today, then verified Catch activity after you claim and publish."
        reveal
      >
        <ButtonLink
          variant="ghost-light"
          href="/organizers/"
          onClick={() => trackCtaClick("home_featured_organizers", "/organizers/")}
        >
          Open directory
        </ButtonLink>
      </FeaturedOrganizersCta>
    </MarketingSection>
  );
}

export function HomeMemberLoopSection() {
  return (
    <MarketingSection variant="story" id="members" aria-labelledby="loop-title">
      <SectionHeader id="loop-title" title="A dating loop built around showing up." wide />
      <MarketingLoopList items={memberLoop} />
    </MarketingSection>
  );
}

export function HomeHostProofSection() {
  return (
    <MarketingSection variant="proof" id="hosts">
      <MarketingSectionCopy
        body="Catch gives hosts the controls that make singles events safer, more balanced, and more memorable: admission rules, waitlists, cohort shaping, check-in, live facilitation, and aggregate reports."
        title="For hosts who care about the experience, not just the RSVP list."
        variant="proof"
      >
        <ButtonLink
          variant="ghost-light"
          href="/host/"
          onClick={() => trackCtaClick("host_tools_section", "/host/")}
        >
          See host tools
        </ButtonLink>
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
        title="See the Catch loop in motion."
        body="Browse the event, show up, catch privately, and let the shared experience carry the first conversation."
      />

      <CaptureGrid>
        <CaptureCard id="member-event-discovery" fallbackStep="Discover" captures={captures} />
        <CaptureCard id="post-run-catch-window" fallbackStep="Catch" captures={captures} />
        <CaptureCard id="host-live-console" fallbackStep="Host" captures={captures} />
      </CaptureGrid>
    </MarketingSection>
  );
}

export function HomeDownloadSection() {
  const appDownloadCtas = useAppDownloadCtas({placement: "home_download_section"});

  return (
    <MarketingSection variant="download" id="download-app" aria-labelledby="download-title">
      <MarketingSectionCopy
        body="Store listings are not public yet. The buttons are in place now so launch traffic can move directly to the app once the listings are approved."
        eyebrow="Member app"
        title="Download Catch when your city opens."
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
        title="Designed for consent, context, and host control."
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
      title="Be first in your city."
      body="Join the member waitlist or apply as a founding host. We will reach out as city access opens."
    >
      <WaitlistForm variant="member" />
    </WaitlistSection>
  );
}

function HostProductBoard() {
  return (
    <ProductShell variant="product-board" aria-label="Catch host product board" reveal>
      <ProductBoardNav
        items={["Format", "Admission", "Live", "Report"].map((item) => ({
          key: item,
          label: item,
        }))}
      />
      <ProductBoardMain>
        <ProductBoardCard>
          <UiLabel>Create event</UiLabel>
          <h3>Pickleball social</h3>
          <p>Paired rotations, balanced admission, check-in required.</p>
          <ControlRow label="Format" value="Racket sports" />
          <ControlRow label="Access" value="Invite code + public waitlist" />
          <ControlRow label="Live module" value="Partner switch" />
        </ProductBoardCard>
        <ProductBoardCard tone="dark">
          <UiLabel>Live event</UiLabel>
          <h3>Host mode</h3>
          <p>Check-in, prompts, rotations, and safety controls stay in one surface.</p>
          <LiveMeter items={["Arrival", "Prompt", "Reveal"]} />
        </ProductBoardCard>
      </ProductBoardMain>
    </ProductShell>
  );
}
