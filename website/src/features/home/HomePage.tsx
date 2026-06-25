import {
  CaptureCard,
  PublicEventCard,
  PublicSearchBar,
  SectionHeader,
  SiteFooter,
  SiteHeader,
} from "../../components/site";
import type {CaptureRecord} from "../../app/usePageLifecycle";
import {ButtonLink} from "../../shared/ui/primitives";
import {WaitlistForm} from "../waitlist/WaitlistForm";
import {AppDownloadCtas} from "../marketing/AppDownloadCtas";
import {
  formatCards,
  memberLoop,
  trustItems,
} from "../marketing/content";
import {LoopList} from "../marketing/LoopList";
import {trackCtaClick} from "../marketing/tracking";
import {hostListings} from "../organizers/data";
import {OrganizerMiniCard} from "../organizers/OrganizerMiniCard";
import {
  publicEventSummaries,
  publicSearchSuggestions,
} from "../organizers/publicDiscoveryData";
import {listingProfileStrength} from "../organizers/selectors";

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

      <main id="top">
        <section className="hero hero--home">
          <div className="hero__media" aria-hidden="true">
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
          </div>

          <div className="hero__inner">
            <div className="hero__copy">
              <h1 data-reveal>Real events. Real hosts. The match comes after.</h1>
              <p className="hero__body" data-reveal>
                Find a hosted run, dinner, game night, or mixer near you. Show
                up in person, then catch privately with people you actually met.
              </p>
              <div className="hero__actions" data-reveal>
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
              </div>
              <AppDownloadCtas placement="home_hero" />
            </div>

            <aside className="hero-panel" aria-label="Catch event panel" data-reveal>
              <div className="event-ticket">
                <div>
                  <span className="ui-label">This week</span>
                  <h2>Events with a reason to talk</h2>
                </div>
                <span className="event-ticket__status">
                  Private catches open only after attendance
                </span>
              </div>
              <div className="event-ticket__meta">
                <span>Dinner</span>
                <span>Social run</span>
                <span>Host-led prompts</span>
                <span>Verified reviews</span>
              </div>
            </aside>
          </div>
        </section>

        <HomeDiscoverySection />

        <section className="format-band" id="formats" aria-labelledby="formats-title">
          <div className="section-heading" data-reveal>
            <h2 id="formats-title">Not another swipe feed. A better way to meet.</h2>
            <p>
              Catch is format-aware: every event can carry the right amount of
              structure, from light social flow to guided rotations and reveal
              moments.
            </p>
          </div>

          <div className="format-grid">
            {formatCards.map((card) => (
              <article className="format-card" data-reveal key={card.mark}>
                <span className="format-card__mark">{card.mark}</span>
                <h3>{card.title}</h3>
                <p>{card.body}</p>
              </article>
            ))}
          </div>
        </section>

        <FeaturedOrganizersSection />

        <section className="story-section" id="members" aria-labelledby="loop-title">
          <div className="section-heading section-heading--wide" data-reveal>
            <h2 id="loop-title">A dating loop built around showing up.</h2>
          </div>
          <LoopList items={memberLoop} />
        </section>

        <section className="proof-section" id="hosts">
          <div className="proof-section__copy" data-reveal>
            <h2>For hosts who care about the experience, not just the RSVP list.</h2>
            <p>
              Catch gives hosts the controls that make singles events safer, more
              balanced, and more memorable: admission rules, waitlists, cohort
              shaping, check-in, live facilitation, and aggregate reports.
            </p>
            <ButtonLink
              variant="ghost-light"
              href="/host/"
              onClick={() => trackCtaClick("host_tools_section", "/host/")}
            >
              See host tools
            </ButtonLink>
          </div>

          <HostProductBoard />
        </section>

        <section className="captures-section" aria-labelledby="app-proof-title">
          <div className="section-heading" data-reveal>
            <h2 id="app-proof-title">See the Catch loop in motion.</h2>
            <p>
              Browse the event, show up, catch privately, and let the shared
              experience carry the first conversation.
            </p>
          </div>

          <div className="capture-grid">
            <CaptureCard id="member-event-discovery" fallbackStep="Discover" captures={captures} />
            <CaptureCard id="post-run-catch-window" fallbackStep="Catch" captures={captures} />
            <CaptureCard id="host-live-console" fallbackStep="Host" captures={captures} />
          </div>
        </section>

        <section className="download-section" id="download-app" aria-labelledby="download-title">
          <div className="download-section__copy" data-reveal>
            <span className="ui-label">Member app</span>
            <h2 id="download-title">Download Catch when your city opens.</h2>
            <p>
              Store listings are not public yet. The buttons are in place now
              so launch traffic can move directly to the app once the listings
              are approved.
            </p>
          </div>
          <AppDownloadCtas placement="home_download_section" className="app-download-ctas--panel" />
        </section>

        <section className="trust-section" id="trust" aria-labelledby="trust-title">
          <div className="section-heading" data-reveal>
            <h2 id="trust-title">Designed for consent, context, and host control.</h2>
          </div>

          <div className="trust-grid">
            {trustItems.map((item) => (
              <article data-reveal key={item.title}>
                <h3>{item.title}</h3>
                <p>{item.body}</p>
              </article>
            ))}
          </div>
        </section>

        <section className="waitlist-section" id="waitlist" aria-labelledby="waitlist-title">
          <div className="waitlist__intro" data-reveal>
            <h2 id="waitlist-title">Be first in your city.</h2>
            <p>
              Join the member waitlist or apply as a founding host. We will reach
              out as city access opens.
            </p>
          </div>
          <WaitlistForm variant="member" />
        </section>
      </main>

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

function HomeDiscoverySection() {
  const events = publicEventSummaries.slice(0, 3);
  return (
    <section className="home-discovery" id="events" aria-labelledby="home-events-title">
      <SectionHeader
        eyebrow="Find events"
        id="home-events-title"
        title="Start with what is happening, then choose who to meet."
        body="The public website now treats events and organizer pages as one discovery loop: search the city, browse a real host page, then continue into the app when the event opens."
        wide
      />
      <PublicSearchBar
        cityName={events[0]?.city ?? "Your city"}
        suggestions={publicSearchSuggestions}
      />
      <div className="public-event-grid">
        {events.length ? (
          events.map((event) => <PublicEventCard event={event} key={event.id} />)
        ) : (
          <div className="public-event-empty" data-reveal>
            <strong>No public Catch events are projected yet.</strong>
            <p>
              Browse organizer pages while event projections are added to the
              public website feed.
            </p>
            <ButtonLink variant="ghost" href="/organizers/">
              Open organizer directory
            </ButtonLink>
          </div>
        )}
      </div>
    </section>
  );
}

function FeaturedOrganizersSection() {
  const featured = hostListings
    .slice()
    .sort((a, b) => listingProfileStrength(b) - listingProfileStrength(a))
    .slice(0, 3);

  return (
    <section className="featured-organizers" aria-labelledby="featured-organizers-title">
      <div className="section-heading" data-reveal>
        <span className="ui-label">Organizer directory</span>
        <h2 id="featured-organizers-title">The public loop starts with real host pages.</h2>
        <p>
          Searchable organizer profiles create a concrete path from discovery to
          claim, reviews, host tools, events, and app usage.
        </p>
      </div>
      <div className="featured-organizers__grid">
        {featured.map((listing) => (
          <OrganizerMiniCard listing={listing} key={listing.id} />
        ))}
      </div>
      <div className="featured-organizers__cta" data-reveal>
        <p>
          Run events? Your profile can show public sources today, then verified
          Catch activity after you claim and publish.
        </p>
        <ButtonLink
          variant="ghost-light"
          href="/organizers/"
          onClick={() => trackCtaClick("home_featured_organizers", "/organizers/")}
        >
          Open directory
        </ButtonLink>
      </div>
    </section>
  );
}

function HostProductBoard() {
  return (
    <div className="product-board" aria-label="Catch host product board" data-reveal>
      <div className="product-board__nav">
        <span>Format</span>
        <span>Admission</span>
        <span>Live</span>
        <span>Report</span>
      </div>
      <div className="product-board__main">
        <article>
          <span className="ui-label">Create event</span>
          <h3>Pickleball social</h3>
          <p>Paired rotations, balanced admission, check-in required.</p>
          <div className="control-row">
            <span>Format</span>
            <strong>Racket sports</strong>
          </div>
          <div className="control-row">
            <span>Access</span>
            <strong>Invite code + public waitlist</strong>
          </div>
          <div className="control-row">
            <span>Live module</span>
            <strong>Partner switch</strong>
          </div>
        </article>
        <article className="product-board__dark">
          <span className="ui-label">Live event</span>
          <h3>Host mode</h3>
          <p>Check-in, prompts, rotations, and safety controls stay in one surface.</p>
          <div className="live-meter">
            <span>Arrival</span>
            <span>Prompt</span>
            <span>Reveal</span>
          </div>
        </article>
      </div>
    </div>
  );
}
