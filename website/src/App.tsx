import {FormEvent, useEffect, useMemo, useState} from "react";
import {
  createMarketingEventId,
  getMarketingConsent,
  initializeMarketingAnalytics,
  setMarketingConsent,
  trackMarketingEvent,
  trackPageView,
  waitlistAnalyticsPayload,
} from "./analytics";
import {
  claimFirebaseConfigured,
  ClubClaimRole,
  createPublicClubReview,
  listPublicClubReviews,
  publicReviewsFirebaseConfigured,
  requestClubClaim,
  signInForClaim,
  signOutClaimUser,
  User,
  watchClaimAuthState,
} from "./firebase";
import hostListingsJson from "./generated/hostListings.json";

type PageKey = "home" | "host" | "organizers" | "listing";
type FormVariant = "member" | "host";
type StatusTone = "" | "is-error" | "is-success";
type ClaimStatus = {
  message: string;
  tone: StatusTone;
};

interface PageMeta {
  title: string;
  description: string;
  canonicalPath: string;
  twitterDescription: string;
  robots?: string;
}

interface CaptureRecord {
  id: string;
  webPath: string;
  alt: string;
  caption: string;
  walkthroughStep: string;
}

interface CaptureManifest {
  captures?: CaptureRecord[];
}

interface HostListingSource {
  type: string;
  label: string;
  detail: string;
  href?: string;
  confidence: "high" | "medium" | "low";
}

interface HostListingEventEvidence {
  title: string;
  date: string;
  location: string;
  summary: string;
  facts: string[];
  sourceLabel: string;
  sourceHref: string;
}

interface HostListingReview {
  id: string | null;
  reviewerName: string;
  rating: number;
  comment: string;
  createdAt: string;
  verificationStatus?: "verified" | "unverified";
  source?: "catchEvent" | "publicListing";
  isAnonymous?: boolean;
  ownerResponse: {
    hostName: string;
    hostAvatarUrl: string | null;
    message: string;
    updatedAt: string;
  } | null;
}

interface HostListingMetrics {
  memberCount?: number;
  rating?: number;
  reviewCount?: number;
  nextEventAt?: string | null;
  nextEventLabel?: string | null;
}

interface HostListingHost {
  name: string;
  role: string;
  avatarUrl: string | null;
}

interface HostListingCatchEvent {
  id: string;
  role: string;
  title: string;
  activityKind: string;
  timeline: "upcoming" | "past";
  startTime: string;
  endTime: string;
  date: string;
  location: string;
  summary: string;
  capacityLimit: number;
  bookedCount: number;
  checkedInCount: number;
  waitlistedCount: number;
  priceLabel: string;
  scorecard?: Record<string, unknown> | null;
}

interface HostListingEventSuccessSummary {
  bookedCount: number;
  checkedInCount: number;
  mutualMatchCount: number;
  chatStartedCount: number;
  catchSentCount: number;
  safetyIncidentCount: number;
}

interface HostListing {
  id: string;
  listingVariant?: "unclaimedScraped" | "appCreatedClub";
  dataOrigin?: "scrapedSeed" | "catchDemo";
  name: string;
  slug: string;
  city: string;
  citySlug: string;
  region: string;
  country: string;
  path: string;
  category: string;
  status: string;
  indexing: string;
  sourceConfidence: string;
  headline: string;
  description: string;
  sourceSummary: string;
  logo: {
    mode: "monogram";
    text: string;
    status: string;
  };
  formats: string[];
  facts: Array<{label: string; value: string}>;
  metrics?: HostListingMetrics;
  host?: HostListingHost;
  catchEvents?: HostListingCatchEvent[];
  eventSuccessSummary?: HostListingEventSuccessSummary | null;
  eventEvidence?: HostListingEventEvidence[];
  reviews?: HostListingReview[];
  fitNotes: string[];
  missingEvidence: string[];
  sources: HostListingSource[];
  claim: {
    href: string;
    label: string;
  };
  lastVerifiedAt: string;
  searchText?: string;
}

const hostListings = hostListingsJson as HostListing[];

const claimRoleOptions: Array<{value: ClubClaimRole; label: string}> = [
  {value: "owner", label: "Owner"},
  {value: "founder", label: "Founder"},
  {value: "manager", label: "Manager"},
  {value: "marketer", label: "Marketing"},
  {value: "venueManager", label: "Venue manager"},
  {value: "other", label: "Other"},
];

const pageMeta: Record<Exclude<PageKey, "listing">, PageMeta> = {
  home: {
    title: "Catch | The event before the match",
    description:
      "Catch turns curated singles events into real dating context. Choose a hosted event, show up, catch privately, and match with people you actually met.",
    canonicalPath: "/",
    twitterDescription: "Curated singles events become real dating context.",
  },
  host: {
    title: "Catch for Hosts | Host better singles events",
    description:
      "Catch helps hosts publish curated singles events, manage admission and waitlists, run live facilitation, and turn real attendance into post-event connections.",
    canonicalPath: "/host/",
    twitterDescription:
      "Event setup, admission, waitlists, live facilitation, check-in, and aggregate post-event reporting for hosts.",
  },
  organizers: {
    title: "Organizer Search | Catch",
    description:
      "Search Catch organizer profiles by name, city, format, and review signal.",
    canonicalPath: "/organizers/",
    twitterDescription: "Search Catch organizer and club profiles.",
    robots: "noindex, follow",
  },
};

const formatCards = [
  {
    mark: "SR",
    title: "Social runs",
    body: "Low-pressure movement, shared pace, and the right follow-up after.",
  },
  {
    mark: "RK",
    title: "Racket sports",
    body: "Pairing, rotations, and court-aware structure for social play.",
  },
  {
    mark: "DN",
    title: "Dinners",
    body: "Tables, prompts, and host rhythm that make conversation easier.",
  },
  {
    mark: "QZ",
    title: "Quiz nights",
    body: "Teams, missions, and shared wins before private interest opens.",
  },
  {
    mark: "MX",
    title: "Singles mixers",
    body: "Structured ways to meet more people without exposing rejection.",
  },
  {
    mark: "CU",
    title: "Custom hosts",
    body: "Bring the format. Catch gives you the event and dating layer.",
  },
];

const memberLoop = [
  {
    step: "01",
    title: "Choose the event",
    body: "Browse events by format, city, host, timing, and social structure.",
  },
  {
    step: "02",
    title: "Be present",
    body: "Check in, meet people, and let the host guide the live moment.",
  },
  {
    step: "03",
    title: "Catch privately",
    body: "After the event, express interest without exposing rejection.",
  },
  {
    step: "04",
    title: "Match with context",
    body: "If the interest is mutual, chat opens around the event you shared.",
  },
];

const hostLoop = [
  {
    step: "01",
    title: "Design the format",
    body: "Select the activity, interaction model, capacity, and live modules.",
  },
  {
    step: "02",
    title: "Shape demand",
    body: "Use invite links, requests, waitlists, offers, cohorts, and pricing controls.",
  },
  {
    step: "03",
    title: "Run the event",
    body: "Check people in, guide live moments, and adjust assignments when needed.",
  },
  {
    step: "04",
    title: "Learn what worked",
    body: "Unlock private catches, then review aggregate attendance and connection signal.",
  },
];

const trustItems = [
  {
    title: "Attendance-gated",
    body: "Dating surfaces open around real event participation, not cold browsing.",
  },
  {
    title: "Private by default",
    body: "Catches are private unless mutual. Host reports stay aggregate-safe.",
  },
  {
    title: "Format-aware facilitation",
    body: "Runs, dinners, teams, courts, and mixers can use the modules that fit.",
  },
  {
    title: "Host-owned standards",
    body: "Admission, capacity, waitlist, check-in, and safety controls stay explicit.",
  },
];

const hostModules = [
  {
    label: "Arrival",
    title: "First Hello",
    body: "A lightweight check-in ritual that helps guests start with a real person, not a blank prompt.",
  },
  {
    label: "Movement",
    title: "Assignments",
    body: "Balanced pairs, tables, pods, teams, and rotations with host-visible reasons and overrides.",
  },
  {
    label: "Control",
    title: "Host console",
    body: "Check-in, live steps, reveal moments, planned breaks, and safety actions stay in one place.",
  },
  {
    label: "After",
    title: "Catch window",
    body: "Private interest opens after attendance. Mutual catches become chats with shared context.",
  },
];

const hostEvidenceMetrics = [
  {value: "64", label: "invite activity"},
  {value: "24", label: "demand signals"},
  {value: "17", label: "booked guests"},
  {value: "13", label: "checked in"},
  {value: "11", label: "caught someone"},
  {value: "18", label: "mutual matches"},
];

const hostSurfaceCards = [
  {
    label: "Bookings",
    title: "Control who gets in before the event fills.",
    body: "Open sales, invite-only drops, request-to-join, balanced ratios, paid checkout, waitlists, and host-issued offers all feed the same roster.",
  },
  {
    label: "Live",
    title: "Give the event structure while it is happening.",
    body: "First Hello, prompts, check-in, assignments, rotations, planned breaks, reveal moments, overrides, and safety controls are built for the host screen.",
  },
  {
    label: "After",
    title: "Turn attendance into a private matching window.",
    body: "Guests can catch privately after they show up. Hosts see aggregate demand, matches, chats, and repeat attendance, never private target identities.",
  },
];

const hostProofRows = [
  {
    label: "Invite links",
    proof: "See which invites create interest, bookings, paid guests, check-ins, catches, matches, and chats.",
  },
  {
    label: "Waitlist movement",
    proof: "Offer expiring spots without overselling, and keep the list clear as guests accept, decline, or miss the window.",
  },
  {
    label: "Event Success",
    proof: "Create pairs, tables, pods, teams, and rotations around the guest mix, event size, host constraints, and last-minute changes.",
  },
  {
    label: "Host reports",
    proof: "Reports stay current as bookings, attendance, waitlist offers, catches, matches, and chats move.",
  },
];

const cities = ["Mumbai", "Delhi", "Bangalore", "Pune", "Hyderabad", "Other"];

function App() {
  const listing = getHostListingForPath(window.location.pathname);
  const fallbackPage = getPageKey();
  const page: PageKey = listing ? "listing" : fallbackPage;
  const captures = useMarketingCaptures();
  const meta = listing ? pageMetaForListing(listing) : pageMeta[fallbackPage];

  useMarketingAnalytics(page);
  useDocumentMeta(meta);
  useRevealAnimations(page);

  return (
    <div className={`page-shell ${pageClassFor(page)}`}>
      {listing ? (
        <HostListingPage listing={listing} />
      ) : page === "host" ? (
        <HostPage captures={captures} />
      ) : page === "organizers" ? (
        <OrganizerSearchPage />
      ) : (
        <HomePage captures={captures} />
      )}
      <MarketingConsentBanner />
    </div>
  );
}

function HomePage({captures}: {captures: Record<string, CaptureRecord>}) {
  return (
    <>
      <SiteHeader
        brandHref="#top"
        nav={[
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
              src="/assets/marketing/catch-hero-event.png"
              alt=""
            />
          </div>

          <div className="hero__inner">
            <div className="hero__copy">
              <h1 data-reveal>Catch</h1>
              <p className="hero__headline" data-reveal>
                The event before the match.
              </p>
              <p className="hero__body" data-reveal>
                Curated singles events become real dating context. Pick a hosted
                event, show up, catch privately, and start the conversation with
                something you already shared.
              </p>
              <div className="hero__actions" data-reveal>
                <a
                  className="button"
                  href="#waitlist"
                  onClick={() => trackCtaClick("home_hero_join_waitlist", "#waitlist")}
                >
                  Join the waitlist
                </a>
                <a
                  className="button button--ghost"
                  href="/host/"
                  onClick={() => trackCtaClick("home_hero_apply_host", "/host/")}
                >
                  Apply as host
                </a>
              </div>
            </div>

            <aside className="hero-panel" aria-label="Catch event panel" data-reveal>
              <div className="event-ticket">
                <div>
                  <span className="ui-label">Tonight</span>
                  <h2>Table for twelve</h2>
                </div>
                <span className="event-ticket__status">
                  Private catches open after check-in
                </span>
              </div>
              <div className="event-ticket__meta">
                <span>Dinner</span>
                <span>Host-led prompts</span>
                <span>Post-event match window</span>
              </div>
            </aside>
          </div>
        </section>

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
            <a
              className="button button--ghost-light"
              href="/host/"
              onClick={() => trackCtaClick("host_tools_section", "/host/")}
            >
              See host tools
            </a>
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
          {href: "#trust", label: "Trust"},
          {href: "#waitlist", label: "Waitlist"},
        ]}
      />
    </>
  );
}

function HostPage({captures}: {captures: Record<string, CaptureRecord>}) {
  return (
    <>
      <SiteHeader
        brandHref="/"
        nav={[
          {href: "#workflow", label: "Workflow"},
          {href: "#live", label: "Live mode"},
          {href: "#screens", label: "Screens"},
          {href: "/organizers/", label: "Organizers"},
          {href: "/", label: "Member site"},
        ]}
        ctaHref="#founding-hosts"
        ctaLabel="Apply as host"
      />

      <main id="top">
        <section className="host-hero">
          <div className="host-hero__inner">
            <div className="host-hero__copy">
              <h1 data-reveal>Run singles events people actually follow through on.</h1>
              <p data-reveal>
                Catch handles the loop around your event: booking logic,
                admission, waitlists, live facilitation, check-in, private
                catches, and the post-event report that shows what actually
                happened.
              </p>
              <div className="hero__actions" data-reveal>
                <a
                  className="button"
                  href="#founding-hosts"
                  onClick={() => trackCtaClick("host_hero_apply", "#founding-hosts")}
                >
                  Apply as host
                </a>
                <a
                  className="button button--ghost"
                  href="#workflow"
                  onClick={() => trackCtaClick("host_hero_workflow", "#workflow")}
                >
                  See workflow
                </a>
              </div>
            </div>

            <div className="host-console" aria-label="Host console" data-reveal>
              <div className="host-console__top">
                <span>Host console</span>
                <strong>West Village mixer</strong>
              </div>
              <div className="host-console__grid">
                <div>
                  <span className="ui-label">Admission</span>
                  <strong>Requests + invite links</strong>
                </div>
                <div>
                  <span className="ui-label">Live moment</span>
                  <strong>Balanced rotations</strong>
                </div>
                <div>
                  <span className="ui-label">After event</span>
                  <strong>18 mutual matches</strong>
                </div>
              </div>
              <div className="host-console__timeline">
                {hostEvidenceMetrics.map((metric) => (
                  <span key={metric.label}>
                    <strong>{metric.value}</strong>
                    {metric.label}
                  </span>
                ))}
              </div>
            </div>
          </div>
        </section>

        <section
          className="host-evidence"
          aria-labelledby="host-evidence-title"
        >
          <div className="section-heading" data-reveal>
            <span className="ui-label">What a host can see</span>
            <h2 id="host-evidence-title">
              Catch shows the path from interest to attendance to follow-up.
            </h2>
            <p>
              Catch answers more than "who RSVP'd?" It shows where demand came
              from, where people dropped off, and whether the event created real
              connection afterward.
            </p>
          </div>
          <div className="evidence-strip" data-reveal>
            {hostEvidenceMetrics.map((metric) => (
              <div key={metric.label}>
                <strong>{metric.value}</strong>
                <span>{metric.label}</span>
              </div>
            ))}
          </div>
        </section>

        <section className="story-section" id="workflow" aria-labelledby="workflow-title">
          <div className="section-heading" data-reveal>
            <h2 id="workflow-title">One loop, from booking to connection.</h2>
            <p>
              Replace forms, payment links, spreadsheets, group chats, manual
              intros, and safety notes with one flow built around the event.
            </p>
          </div>
          <LoopList items={hostLoop} modifier="loop-list--host" />
        </section>

        <section
          className="surface-section"
          aria-labelledby="surface-title"
        >
          <div className="section-heading section-heading--wide" data-reveal>
            <span className="ui-label">What Catch handles</span>
            <h2 id="surface-title">
              The platform is not just ticketing, and it is not just matching.
            </h2>
          </div>
          <div className="surface-grid">
            {hostSurfaceCards.map((item) => (
              <article data-reveal key={item.label}>
                <span>{item.label}</span>
                <h3>{item.title}</h3>
                <p>{item.body}</p>
              </article>
            ))}
          </div>
        </section>

        <section className="proof-section proof-section--host" id="live">
          <div className="proof-section__copy" data-reveal>
            <span className="ui-label">Event Success</span>
            <h2>Live facilitation is built into the event flow.</h2>
            <p>
              Every supported format can use the modules that fit its shape:
              arrival moments, prompts, balanced assignments, rotations,
              host overrides, reveals, private catches, feedback, and reports.
            </p>
          </div>

          <div className="module-stack" data-reveal>
            {hostModules.map((item) => (
              <article key={item.label}>
                <span>{item.label}</span>
                <strong>{item.title}</strong>
                <p>{item.body}</p>
              </article>
            ))}
          </div>
        </section>

        <section
          className="proof-ledger"
          aria-labelledby="proof-ledger-title"
        >
          <div className="section-heading" data-reveal>
            <span className="ui-label">Host confidence</span>
            <h2 id="proof-ledger-title">Run the whole event loop from one place.</h2>
            <p>
              Catch gives hosts the controls to shape demand, guide the live
              experience, and understand what happened after people met.
            </p>
          </div>
          <div className="proof-ledger__rows">
            {hostProofRows.map((item) => (
              <article data-reveal key={item.label}>
                <strong>{item.label}</strong>
                <p>{item.proof}</p>
              </article>
            ))}
          </div>
        </section>

        <section className="captures-section" id="screens" aria-labelledby="screens-title">
          <div className="section-heading" data-reveal>
            <span className="ui-label">Host tools</span>
            <h2 id="screens-title">See the host workflow end to end.</h2>
            <p>
              Set up the event, manage the live moment, and review the signals
              that help the next event get better.
            </p>
          </div>

          <div className="capture-grid capture-grid--host">
            <CaptureCard id="host-event-setup" fallbackStep="Setup" captures={captures} />
            <CaptureCard id="host-live-console" fallbackStep="Live" captures={captures} />
            <CaptureCard id="host-post-event-report" fallbackStep="Report" captures={captures} />
          </div>
        </section>

        <section
          className="waitlist-section"
          id="founding-hosts"
          aria-labelledby="host-apply-title"
        >
          <div className="waitlist__intro" data-reveal>
            <h2 id="host-apply-title">
              Bring the format. Catch handles the loop around it.
            </h2>
            <p>
              Apply as a founding host if you run events, communities, venues, or
              formats where the right singles can meet with more context.
            </p>
          </div>
          <WaitlistForm variant="host" />
        </section>
      </main>

      <SiteFooter
        brandHref="/"
        body="Host-led singles events with booking, facilitation, matching, and insight."
        links={[
          {href: "/", label: "Member site"},
          {href: "#workflow", label: "Workflow"},
          {href: "#live", label: "Live mode"},
          {href: "#founding-hosts", label: "Apply"},
        ]}
      />
    </>
  );
}

function OrganizerSearchPage() {
  const initialQuery = new URLSearchParams(window.location.search).get("q") ?? "";
  const [query, setQuery] = useState(initialQuery);
  const normalizedQuery = query.trim().toLowerCase();
  const results = useMemo(() => {
    if (!normalizedQuery) return hostListings;
    const terms = normalizedQuery.split(/\s+/).filter(Boolean);
    return hostListings.filter((listing) => {
      const haystack = [
        listing.searchText,
        listing.name,
        listing.city,
        listing.region,
        listing.category,
        listing.status,
        ...(listing.formats ?? []),
      ].filter(Boolean).join(" ").toLowerCase();
      return terms.every((term) => haystack.includes(term));
    });
  }, [normalizedQuery]);

  function handleSearch(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();
    const params = new URLSearchParams(window.location.search);
    if (normalizedQuery) {
      params.set("q", normalizedQuery);
    } else {
      params.delete("q");
    }
    const next = params.toString() ? `/organizers/?${params}` : "/organizers/";
    window.history.replaceState(null, "", next);
    trackMarketingEvent("organizer_search_submitted", {
      query: normalizedQuery,
      result_count: results.length,
    });
  }

  return (
    <>
      <SiteHeader
        brandHref="/"
        nav={[
          {href: "/host/", label: "For hosts"},
          {href: "/", label: "Member site"},
        ]}
        ctaHref="/host/#founding-hosts"
        ctaLabel="Apply as host"
      />

      <main id="top">
        <section className="organizer-search-hero" aria-labelledby="organizer-search-title">
          <div className="section-heading section-heading--wide" data-reveal>
            <span className="ui-label">Organizer search</span>
            <h1 id="organizer-search-title">Find clubs, hosts, and event organizers.</h1>
            <p>
              Search seed listings and first-party Catch-created clubs by name,
              city, format, host signal, and reviews.
            </p>
          </div>
          <form className="organizer-search-form" onSubmit={handleSearch} data-reveal>
            <label>
              Search organizers
              <input
                value={query}
                onChange={(event) => setQuery(event.target.value)}
                placeholder="Try Sunday Table, Delhi, run club, dinner"
              />
            </label>
            <button className="button" type="submit">Search</button>
          </form>
          <p className="organizer-search-count" data-reveal>
            {results.length} {results.length === 1 ? "profile" : "profiles"}
          </p>
        </section>

        <section className="organizer-results" aria-label="Organizer results">
          {results.map((listing) => (
            <OrganizerResultCard listing={listing} key={listing.id} />
          ))}
        </section>
      </main>

      <SiteFooter
        brandHref="/"
        body="Searchable profiles for hosts, clubs, venues, and social organizers."
        links={[
          {href: "/host/", label: "For hosts"},
          {href: "/", label: "Member site"},
          {href: "/organizers/?q=run", label: "Run clubs"},
          {href: "/organizers/?q=dinner", label: "Dinners"},
        ]}
      />
    </>
  );
}

function OrganizerResultCard({listing}: {listing: HostListing}) {
  const isAppCreated = listing.listingVariant === "appCreatedClub";
  const rating = listing.metrics?.rating;
  const reviewCount = listing.metrics?.reviewCount;
  return (
    <article className="organizer-result-card">
      <a href={listing.path}>
        <div className="listing-mark organizer-result-card__mark" aria-hidden="true">
          {listing.logo.text}
        </div>
        <div className="organizer-result-card__body">
          <span className="ui-label">{isAppCreated ? "Catch-created" : listing.status}</span>
          <h2>{listing.name}</h2>
          <p>{listing.description}</p>
          <div className="listing-badge-row">
            <span>{listing.city}</span>
            <span>{listing.category}</span>
            {rating ? <span>{rating.toFixed(1)} rating</span> : null}
            {reviewCount ? <span>{reviewCount} reviews</span> : null}
          </div>
          <div className="listing-format-row">
            {listing.formats.slice(0, 4).map((format) => (
              <span key={format}>{format}</span>
            ))}
          </div>
        </div>
      </a>
    </article>
  );
}

function HostListingPage({listing}: {listing: HostListing}) {
  const isAppCreated = listing.listingVariant === "appCreatedClub";
  const nav = [
    {href: "#profile", label: "Profile"},
    ...(listing.catchEvents?.length ? [{href: "#events", label: "Events"}] : []),
    {href: "#reviews", label: "Reviews"},
    {href: "#fit", label: isAppCreated ? "Format" : "Fit"},
    ...(!isAppCreated ? [{href: "#sources", label: "Sources"}] : []),
    {href: "/organizers/", label: "Search"},
    {href: "/host/", label: "For hosts"},
  ];
  return (
    <>
      <SiteHeader
        brandHref="/"
        nav={nav}
        ctaHref={listing.claim.href}
        ctaLabel={isAppCreated ? listing.claim.label : "Claim listing"}
      />

      <main id="profile">
        <section className="listing-hero">
          <div className="listing-hero__inner">
            <div className="listing-hero__copy" data-reveal>
              <span className="ui-label">{listing.category}</span>
              <h1>{listing.headline}</h1>
              <p>{listing.description}</p>
              <div className="listing-badge-row" aria-label="Listing status">
                <span>{listing.status}</span>
                <span>{listing.sourceConfidence.replaceAll("_", " ")}</span>
                <span>Updated {listing.lastVerifiedAt}</span>
              </div>
              <div className="hero__actions">
                <a
                  className="button"
                  href={listing.claim.href}
                  onClick={() => trackCtaClick("listing_claim", listing.claim.href)}
                >
                  {listing.claim.label}
                </a>
                <a
                  className="button button--ghost"
                  href={isAppCreated ? "/organizers/" : "/host/"}
                  onClick={() => trackCtaClick(
                    isAppCreated ? "listing_search_organizers" : "listing_host_tools",
                    isAppCreated ? "/organizers/" : "/host/"
                  )}
                >
                  {isAppCreated ? "Search organizers" : "See Catch for hosts"}
                </a>
              </div>
            </div>

            <aside className="listing-panel" aria-label={`${listing.name} profile`} data-reveal>
              <div className="listing-mark" aria-hidden="true">
                {listing.logo.text}
              </div>
              <div>
                <span className="ui-label">
                  {isAppCreated ? "Catch organizer" : "Unclaimed profile"}
                </span>
                <h2>{listing.name}</h2>
                <p>
                  {listing.host ? `Hosted by ${listing.host.name}` : `${listing.city}, ${listing.region}`}
                </p>
              </div>
              {listing.metrics ? (
                <div className="listing-panel__metrics" aria-label="Organizer metrics">
                  <span><strong>{listing.metrics.memberCount ?? 0}</strong> members</span>
                  <span><strong>{listing.metrics.rating?.toFixed(1) ?? "0.0"}</strong> rating</span>
                  <span><strong>{listing.metrics.reviewCount ?? 0}</strong> reviews</span>
                </div>
              ) : null}
              <div className="listing-format-row">
                {listing.formats.map((format) => (
                  <span key={format}>{format}</span>
                ))}
              </div>
            </aside>
          </div>
        </section>

        <section className="listing-section" aria-labelledby="listing-facts-title">
          <div className="section-heading" data-reveal>
            <span className="ui-label">
              {isAppCreated ? "Club profile" : "Known profile"}
            </span>
            <h2 id="listing-facts-title">
              {isAppCreated ?
                "A Catch-created club with real product context." :
                "A source-conservative seed listing."}
            </h2>
            <p>{listing.sourceSummary}</p>
          </div>
          <div className="listing-grid">
            {listing.facts.map((fact) => (
              <article className="listing-card" data-reveal key={fact.label}>
                <span>{fact.label}</span>
                <strong>{fact.value}</strong>
              </article>
            ))}
          </div>
        </section>

        {listing.catchEvents?.length ? (
          <ListingCatchEventsSection listing={listing} />
        ) : null}

        {listing.eventEvidence?.length ? (
          <section className="listing-section listing-section--events" aria-labelledby="listing-events-title">
            <div className="section-heading" data-reveal>
              <span className="ui-label">Event evidence</span>
              <h2 id="listing-events-title">Public events tied to this host.</h2>
            </div>
            <div className="listing-event-stack">
              {listing.eventEvidence.map((event) => (
                <article className="listing-event-card" data-reveal key={event.title}>
                  <div>
                    <span className="ui-label">{event.date}</span>
                    <h3>{event.title}</h3>
                    <p>{event.summary}</p>
                  </div>
                  <dl className="listing-event-meta">
                    <div>
                      <dt>Location</dt>
                      <dd>{event.location}</dd>
                    </div>
                    <div>
                      <dt>Source</dt>
                      <dd>
                        <a href={event.sourceHref} target="_blank" rel="noreferrer">
                          {event.sourceLabel}
                        </a>
                      </dd>
                    </div>
                  </dl>
                  <ul className="listing-event-facts">
                    {event.facts.map((fact) => (
                      <li key={fact}>{fact}</li>
                    ))}
                  </ul>
                </article>
              ))}
            </div>
          </section>
        ) : null}

        <ListingReviewsSection listing={listing} />

        {listing.eventSuccessSummary ? (
          <ListingEventSuccessSection summary={listing.eventSuccessSummary} />
        ) : null}

        <section className="listing-section" id="fit" aria-labelledby="listing-fit-title">
          <div className="section-heading" data-reveal>
            <span className="ui-label">{isAppCreated ? "Page format" : "Catch fit"}</span>
            <h2 id="listing-fit-title">
              {isAppCreated ?
                "What the app-created profile needs to emphasize." :
                "Why this category belongs in the first test."}
            </h2>
          </div>
          <div className="listing-grid listing-grid--fit">
            {listing.fitNotes.map((note) => (
              <article className="listing-card" data-reveal key={note}>
                <p>{note}</p>
              </article>
            ))}
          </div>
        </section>

        {!isAppCreated ? (
          <>
            <ListingSourcesSection listing={listing} />
            <section className="claim-band" aria-labelledby="listing-missing-title">
              <div data-reveal>
                <span className="ui-label">Before public indexing</span>
                <h2 id="listing-missing-title">Missing evidence</h2>
              </div>
              <div className="claim-band__grid">
                <ul className="missing-list" data-reveal>
                  {listing.missingEvidence.map((item) => (
                    <li key={item}>{item}</li>
                  ))}
                </ul>
                <ClaimListingPanel listing={listing} />
              </div>
            </section>
          </>
        ) : null}
      </main>

      <SiteFooter
        brandHref="/"
        body="Claimable profiles for hosts who run social events people actually show up for."
        links={[
          {href: "/host/", label: "For hosts"},
          {href: "#profile", label: "Profile"},
          {href: "#sources", label: "Sources"},
          {href: listing.claim.href, label: "Claim"},
        ]}
      />
    </>
  );
}

function ListingCatchEventsSection({listing}: {listing: HostListing}) {
  const events = listing.catchEvents ?? [];
  return (
    <section
      className="listing-section listing-section--events"
      id="events"
      aria-labelledby="listing-catch-events-title"
    >
      <div className="section-heading" data-reveal>
        <span className="ui-label">Catch events</span>
        <h2 id="listing-catch-events-title">Events created inside Catch.</h2>
        <p>
          App-created clubs should show the actual event pipeline: what is
          coming up, what filled, and what happened after people showed up.
        </p>
      </div>
      <div className="listing-catch-event-grid">
        {events.map((event) => (
          <article className="listing-catch-event-card" data-reveal key={event.id}>
            <div>
              <span className="ui-label">{event.timeline}</span>
              <h3>{event.title}</h3>
              <p>{event.summary}</p>
            </div>
            <dl className="listing-event-meta">
              <div>
                <dt>Date</dt>
                <dd>{event.date}</dd>
              </div>
              <div>
                <dt>Location</dt>
                <dd>{event.location}</dd>
              </div>
              <div>
                <dt>Price</dt>
                <dd>{event.priceLabel}</dd>
              </div>
              <div>
                <dt>Capacity</dt>
                <dd>{event.capacityLimit}</dd>
              </div>
            </dl>
            <div className="listing-event-counts" aria-label={`${event.title} event counts`}>
              <span><strong>{event.bookedCount}</strong> booked</span>
              <span><strong>{event.checkedInCount}</strong> checked in</span>
              <span><strong>{event.waitlistedCount}</strong> waitlisted</span>
            </div>
          </article>
        ))}
      </div>
    </section>
  );
}

function ListingEventSuccessSection({
  summary,
}: {
  summary: HostListingEventSuccessSummary;
}) {
  const metrics = [
    {label: "Booked", value: summary.bookedCount},
    {label: "Checked in", value: summary.checkedInCount},
    {label: "Catches sent", value: summary.catchSentCount},
    {label: "Mutual matches", value: summary.mutualMatchCount},
    {label: "Chats started", value: summary.chatStartedCount},
    {label: "Safety reports", value: summary.safetyIncidentCount},
  ];
  return (
    <section className="listing-section listing-section--success" aria-labelledby="event-success-title">
      <div className="section-heading" data-reveal>
        <span className="ui-label">Event Success</span>
        <h2 id="event-success-title">The claimed profile can show what Catch actually operated.</h2>
        <p>
          These are aggregate, host-safe outcomes from a completed Catch event.
          This is the kind of proof an app-created club can show that a scraped
          unclaimed listing cannot.
        </p>
      </div>
      <div className="listing-success-grid" data-reveal>
        {metrics.map((metric) => (
          <div key={metric.label}>
            <strong>{metric.value}</strong>
            <span>{metric.label}</span>
          </div>
        ))}
      </div>
    </section>
  );
}

function ListingSourcesSection({listing}: {listing: HostListing}) {
  return (
    <section className="listing-section listing-section--split" id="sources">
      <div data-reveal>
        <span className="ui-label">Source ledger</span>
        <h2>Evidence before indexing.</h2>
        <p>
          Thin pages should stay out of search until identity, cadence, and
          owner-safe details are verified.
        </p>
      </div>

      <div className="listing-ledger" data-reveal>
        {listing.sources.map((source) => (
          <article key={`${source.type}-${source.label}`}>
            <div>
              <strong>{source.label}</strong>
              <span>{source.confidence} confidence</span>
            </div>
            <p>{source.detail}</p>
            {source.href ? (
              <a className="source-link" href={source.href} target="_blank" rel="noreferrer">
                Open source
              </a>
            ) : null}
          </article>
        ))}
      </div>
    </section>
  );
}

function ListingReviewsSection({listing}: {listing: HostListing}) {
  const seedReviews = listing.reviews ?? [];
  const [reviews, setReviews] = useState<HostListingReview[]>(
    () => seedReviews
  );
  const [rating, setRating] = useState(5);
  const [reviewerName, setReviewerName] = useState("");
  const [comment, setComment] = useState("");
  const [isAnonymous, setIsAnonymous] = useState(false);
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [status, setStatus] = useState<ClaimStatus>({
    message: "",
    tone: "",
  });

  useEffect(() => {
    let cancelled = false;
    setReviews(seedReviews);

    if (!publicReviewsFirebaseConfigured) return () => {
      cancelled = true;
    };

    listPublicClubReviews({clubId: listing.id})
      .then((result) => {
        if (cancelled || !result.reviews.length) return;
        setReviews(mergeReviews(result.reviews, seedReviews));
      })
      .catch((error) => {
        if (cancelled) return;
        setStatus({
          message: readableError(error),
          tone: "is-error",
        });
      });

    return () => {
      cancelled = true;
    };
  }, [listing]);

  const seedReviewKeys = new Set(seedReviews.map(reviewKey));
  const supplementalReviews = reviews.filter(
    (review) => !seedReviewKeys.has(reviewKey(review))
  );
  const aggregateReviewCount = listing.metrics?.reviewCount;
  const aggregateRating = listing.metrics?.rating;
  const displayReviewCount = aggregateReviewCount !== undefined ?
    aggregateReviewCount + supplementalReviews.length :
    reviews.length;
  const supplementalRatingTotal = supplementalReviews.reduce(
    (sum, review) => sum + review.rating,
    0
  );
  const visibleRatingAverage = reviews.length
    ? reviews.reduce((sum, review) => sum + review.rating, 0) / reviews.length
    : 0;
  const displayRating = aggregateRating !== undefined && aggregateReviewCount ?
    (
      (aggregateRating * aggregateReviewCount + supplementalRatingTotal) /
      displayReviewCount
    ) :
    visibleRatingAverage;
  const visibleVerifiedCount = reviews.filter(
    (review) => review.verificationStatus === "verified" ||
      (!review.verificationStatus && review.source !== "publicListing")
  ).length;
  const verifiedCount = Math.max(
    listing.listingVariant === "appCreatedClub" ? aggregateReviewCount ?? 0 : 0,
    visibleVerifiedCount
  );
  const reviewFormId = `review-${listing.id}`;

  async function submitReview(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();
    setStatus({message: "", tone: ""});

    const trimmedComment = comment.trim();
    const trimmedName = reviewerName.trim();
    if (!trimmedComment) {
      setStatus({message: "Review text is required.", tone: "is-error"});
      return;
    }
    if (!isAnonymous && !trimmedName) {
      setStatus({
        message: "Add your name, or choose anonymous.",
        tone: "is-error",
      });
      return;
    }

    setIsSubmitting(true);
    const localReview: HostListingReview = {
      id: `local-${Date.now()}`,
      reviewerName: isAnonymous ? "Anonymous reviewer" : trimmedName,
      rating,
      comment: trimmedComment,
      createdAt: new Date().toISOString(),
      verificationStatus: "unverified",
      source: "publicListing",
      isAnonymous,
      ownerResponse: null,
    };

    try {
      if (publicReviewsFirebaseConfigured) {
        const result = await createPublicClubReview({
          clubId: listing.id,
          rating,
          comment: trimmedComment,
          reviewerName: trimmedName,
          isAnonymous,
          submittedFromPath: window.location.pathname,
        });
        setReviews((current) => mergeReviews([result.review], current));
        setStatus({
          message: "Review published as an unverified public review.",
          tone: "is-success",
        });
      } else {
        setReviews((current) => mergeReviews([localReview], current));
        setStatus({
          message:
            "Preview review added locally. Configure website App Check to write it to Firestore.",
          tone: "is-success",
        });
      }
      setComment("");
      if (isAnonymous) setReviewerName("");
      trackMarketingEvent("listing_public_review_submitted", {
        club_id: listing.id,
        anonymous: isAnonymous,
        configured: publicReviewsFirebaseConfigured,
      });
    } catch (error) {
      setStatus({
        message: readableError(error),
        tone: "is-error",
      });
    } finally {
      setIsSubmitting(false);
    }
  }

  return (
    <section
      className="listing-section listing-section--reviews"
      id="reviews"
      aria-labelledby="listing-reviews-title"
    >
      <div className="section-heading" data-reveal>
        <span className="ui-label">Reviews</span>
        <h2 id="listing-reviews-title">Public reviews for {listing.name}.</h2>
        <p>
          Verified reviews come from logged-in Catch guests after attended
          events. Reviews submitted on this public page are unverified and can
          be anonymous.
        </p>
      </div>

      <div className="listing-review-summary" data-reveal>
        <div>
          <span className="ui-label">Rating</span>
          <strong>
            {displayReviewCount ? displayRating.toFixed(1) : "No reviews yet"}
          </strong>
        </div>
        <div>
          <span className="ui-label">Count</span>
          <strong>{displayReviewCount}</strong>
        </div>
        <div>
          <span className="ui-label">Verified</span>
          <strong>{verifiedCount}</strong>
        </div>
        <a
          className="button button--ghost"
          href={`#${reviewFormId}`}
          onClick={() => trackCtaClick("listing_review_intent", `#${reviewFormId}`)}
        >
          Add review
        </a>
      </div>

      <div className="listing-review-workspace">
        <div>
          {reviews.length ? (
            <div className="listing-review-stack">
              {reviews.map((review) => (
                <article
                  className="listing-review-card"
                  key={review.id ?? `${review.reviewerName}-${review.createdAt}`}
                >
                  <div className="listing-review-card__header">
                    <div>
                      <strong>{review.reviewerName}</strong>
                      <span>{reviewDateLabel(review.createdAt)}</span>
                    </div>
                    <span aria-label={`${review.rating} out of 5 stars`}>
                      {"★".repeat(
                        Math.max(0, Math.min(5, Math.round(review.rating)))
                      )}
                    </span>
                  </div>
                  <span className={`listing-review-badge ${
                    review.verificationStatus === "verified" ?
                      "is-verified" :
                      "is-unverified"
                  }`}>
                    {review.verificationStatus === "verified" ?
                      "Verified Catch attendee" :
                      "Unverified public review"}
                  </span>
                  {review.comment ? <p>{review.comment}</p> : null}
                  {review.ownerResponse ? (
                    <div className="listing-owner-response">
                      <span>Host response · {review.ownerResponse.hostName}</span>
                      <p>{review.ownerResponse.message}</p>
                    </div>
                  ) : null}
                </article>
              ))}
            </div>
          ) : (
            <div className="listing-review-empty" data-reveal>
              <div>
                <span className="ui-label">First review</span>
                <h3>No public reviews for {listing.name} yet.</h3>
                <p>
                  Add the first public review here. If the organizer claims this
                  page, they can respond from the verified host account.
                </p>
              </div>
            </div>
          )}
        </div>

        <form
          className="listing-review-form"
          data-reveal
          id={reviewFormId}
          onSubmit={submitReview}
        >
          <div>
            <span className="ui-label">Add review</span>
            <h3>Share feedback for {listing.name}.</h3>
          </div>
          <label>
            Rating
            <select
              value={rating}
              onChange={(event) => setRating(Number(event.target.value))}
            >
              <option value={5}>5 stars</option>
              <option value={4}>4 stars</option>
              <option value={3}>3 stars</option>
              <option value={2}>2 stars</option>
              <option value={1}>1 star</option>
            </select>
          </label>
          <label>
            Display name
            <input
              value={reviewerName}
              disabled={isAnonymous}
              maxLength={120}
              onChange={(event) => setReviewerName(event.target.value)}
              placeholder={isAnonymous ? "Anonymous reviewer" : "Your name"}
            />
          </label>
          <label className="listing-review-checkbox">
            <input
              type="checkbox"
              checked={isAnonymous}
              onChange={(event) => setIsAnonymous(event.target.checked)}
            />
            Post anonymously
          </label>
          <label>
            Review
            <textarea
              value={comment}
              maxLength={1000}
              rows={6}
              onChange={(event) => setComment(event.target.value)}
              placeholder="What should people know about this organizer?"
            />
          </label>
          <button className="button" type="submit" disabled={isSubmitting}>
            {isSubmitting ? "Publishing..." : "Publish review"}
          </button>
          {status.message ? (
            <p className={`form-status ${status.tone}`} role="status">
              {status.message}
            </p>
          ) : null}
        </form>
      </div>
    </section>
  );
}

function ClaimListingPanel({listing}: {listing: HostListing}) {
  const [user, setUser] = useState<User | null>(null);
  const [authReady, setAuthReady] = useState(false);
  const [isSigningIn, setIsSigningIn] = useState(false);
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [status, setStatus] = useState<ClaimStatus>({
    message: "",
    tone: "",
  });

  useEffect(() => {
    return watchClaimAuthState((nextUser) => {
      setUser(nextUser);
      setAuthReady(true);
    });
  }, []);

  async function handleSignIn() {
    setIsSigningIn(true);
    setStatus({message: "", tone: ""});
    trackMarketingEvent("listing_claim_sign_in_started", {
      listing_id: listing.id,
    });
    try {
      await signInForClaim();
      trackMarketingEvent("listing_claim_signed_in", {
        listing_id: listing.id,
      });
    } catch (error) {
      setStatus({
        message:
          error instanceof Error ?
            error.message :
            "Sign-in did not complete. Please try again.",
        tone: "is-error",
      });
      trackMarketingEvent("listing_claim_sign_in_error", {
        listing_id: listing.id,
      });
    } finally {
      setIsSigningIn(false);
    }
  }

  async function handleSubmit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();
    if (!user) {
      setStatus({
        message: "Sign in before requesting this claim.",
        tone: "is-error",
      });
      return;
    }

    const form = event.currentTarget;
    const formData = new FormData(form);
    const requesterName = String(formData.get("requesterName") || "").trim();
    const requesterRole = String(formData.get("requesterRole") || "") as
      ClubClaimRole;
    const businessEmail = nullableString(formData.get("businessEmail"));
    const businessPhone = nullableString(formData.get("businessPhone"));
    const proofUrls = parseProofUrls(formData.get("proofUrls"));
    const message = nullableString(formData.get("message"));

    if (!requesterName || !requesterRole) {
      setStatus({
        message: "Add your name and role before requesting the claim.",
        tone: "is-error",
      });
      return;
    }

    if (!businessEmail && !businessPhone && proofUrls.length === 0) {
      setStatus({
        message: "Add a business contact or at least one public proof link.",
        tone: "is-error",
      });
      return;
    }

    setIsSubmitting(true);
    setStatus({message: "", tone: ""});
    trackMarketingEvent("listing_claim_submit_attempt", {
      listing_id: listing.id,
      proof_count: proofUrls.length,
      requester_role: requesterRole,
    });

    try {
      await requestClubClaim({
        clubId: listing.id,
        requesterName,
        requesterRole,
        businessEmail,
        businessPhone,
        proofUrls,
        message,
      });
      form.reset();
      setStatus({
        message: "Claim request received. Catch will review it before ownership changes.",
        tone: "is-success",
      });
      trackMarketingEvent("listing_claim_submitted", {
        listing_id: listing.id,
        proof_count: proofUrls.length,
        requester_role: requesterRole,
      });
    } catch (error) {
      setStatus({
        message:
          error instanceof Error ?
            error.message :
            "We could not submit this claim request. Please try again.",
        tone: "is-error",
      });
      trackMarketingEvent("listing_claim_submit_error", {
        listing_id: listing.id,
      });
    } finally {
      setIsSubmitting(false);
    }
  }

  if (!claimFirebaseConfigured) {
    return (
      <div className="claim-request-panel" id="claim" data-reveal>
        <div>
          <span className="ui-label">Claim this listing</span>
          <h3>Owner review is not enabled on this build.</h3>
          <p>
            Use the host application while this public claim flow is being
            connected to Firebase.
          </p>
        </div>
        <a
          className="button"
          href="/host/#founding-hosts"
          onClick={() => trackCtaClick("listing_claim_fallback", "/host/#founding-hosts")}
        >
          Apply as host
        </a>
      </div>
    );
  }

  return (
    <div className="claim-request-panel" id="claim" data-reveal>
      <div className="claim-request-panel__heading">
        <span className="ui-label">Claim this listing</span>
        <h3>Request ownership for {listing.name}</h3>
        <p>
          Approved claims attach this profile to a Catch host account before
          owner tools or responses are unlocked.
        </p>
      </div>

      <div className="claim-auth-row">
        <span>
          {user ?
            `Signed in as ${user.displayName || user.email || "Catch user"}` :
            authReady ?
              "Sign in to request ownership." :
              "Checking sign-in status."}
        </span>
        {user ? (
          <button
            className="button button--ghost"
            onClick={() => void signOutClaimUser()}
            type="button"
          >
            Sign out
          </button>
        ) : (
          <button
            className="button"
            disabled={!authReady || isSigningIn}
            onClick={() => void handleSignIn()}
            type="button"
          >
            {isSigningIn ? "Signing in..." : "Sign in"}
          </button>
        )}
      </div>

      <form className="claim-request-form" onSubmit={handleSubmit}>
        <label>
          Your name
          <input
            name="requesterName"
            autoComplete="name"
            defaultValue={user?.displayName ?? ""}
            required
          />
        </label>
        <label>
          Role
          <select name="requesterRole" defaultValue="owner" required>
            {claimRoleOptions.map((option) => (
              <option value={option.value} key={option.value}>
                {option.label}
              </option>
            ))}
          </select>
        </label>
        <label>
          Business email
          <input
            name="businessEmail"
            type="email"
            autoComplete="email"
            defaultValue={user?.email ?? ""}
          />
        </label>
        <label>
          Business phone
          <input name="businessPhone" type="tel" autoComplete="tel" />
        </label>
        <label className="span-2">
          Proof links
          <textarea
            name="proofUrls"
            rows={3}
            placeholder="Official website, Instagram, Luma, Linktree, or event page"
          />
        </label>
        <label className="span-2">
          Note for review
          <textarea
            name="message"
            rows={3}
            maxLength={1000}
            placeholder="Anything Catch should know before approving ownership"
          />
        </label>
        <button className="button" disabled={!user || isSubmitting} type="submit">
          {isSubmitting ? "Submitting..." : "Request claim"}
        </button>
        <p className={`form-status ${status.tone}`.trim()} role="status" aria-live="polite">
          {status.message}
        </p>
      </form>
    </div>
  );
}

function SiteHeader({
  brandHref,
  nav,
  ctaHref,
  ctaLabel,
}: {
  brandHref: string;
  nav: Array<{href: string; label: string}>;
  ctaHref: string;
  ctaLabel: string;
}) {
  const [isScrolled, setIsScrolled] = useState(false);

  useEffect(() => {
    const syncHeader = () => setIsScrolled(window.scrollY > 18);
    syncHeader();
    window.addEventListener("scroll", syncHeader, {passive: true});
    return () => window.removeEventListener("scroll", syncHeader);
  }, []);

  return (
    <header className={`site-header ${isScrolled ? "is-scrolled" : ""}`}>
      <a className="brand" href={brandHref} aria-label="Catch home">
        <span className="brand__mark" aria-hidden="true">
          C
        </span>
        <span className="brand__word">Catch</span>
      </a>

      <nav className="site-nav" aria-label="Primary">
        {nav.map((item) => (
          <a
            href={item.href}
            key={`${item.href}-${item.label}`}
            onClick={() => trackCtaClick(`nav_${slugForEvent(item.label)}`, item.href)}
          >
            {item.label}
          </a>
        ))}
      </nav>

      <a
        className="button button--small"
        href={ctaHref}
        onClick={() => trackCtaClick(`header_${slugForEvent(ctaLabel)}`, ctaHref)}
      >
        {ctaLabel}
      </a>
    </header>
  );
}

function LoopList({
  items,
  modifier,
}: {
  items: Array<{step: string; title: string; body: string}>;
  modifier?: string;
}) {
  return (
    <ol className={`loop-list ${modifier ?? ""}`.trim()}>
      {items.map((item) => (
        <li data-reveal key={item.step}>
          <span>{item.step}</span>
          <h3>{item.title}</h3>
          <p>{item.body}</p>
        </li>
      ))}
    </ol>
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

function CaptureCard({
  id,
  fallbackStep,
  captures,
}: {
  id: string;
  fallbackStep: string;
  captures: Record<string, CaptureRecord>;
}) {
  const capture = captures[id];
  const imagePath = capture?.webPath ?? `/assets/app-screenshots/placeholders/${id}.svg`;

  return (
    <figure className="capture-card" data-reveal data-capture-slot={id}>
      <img
        src={imagePath}
        alt={capture?.alt ?? fallbackAltForCapture(id)}
        loading="lazy"
      />
      <figcaption>
        <span>{capture?.walkthroughStep ?? fallbackStep}</span>
        <strong>{capture?.caption ?? fallbackCaptionForCapture(id)}</strong>
      </figcaption>
    </figure>
  );
}

function WaitlistForm({variant}: {variant: FormVariant}) {
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [status, setStatus] = useState<{message: string; tone: StatusTone}>({
    message: "",
    tone: "",
  });
  const [showCustomCity, setShowCustomCity] = useState(false);
  const [hasStarted, setHasStarted] = useState(false);

  const roleOptions = useMemo(
    () =>
      variant === "host"
        ? [
            {value: "host", label: "Host"},
            {value: "both", label: "Host and member"},
          ]
        : [
            {value: "", label: "Choose role"},
            {value: "member", label: "Member"},
            {value: "host", label: "Host"},
            {value: "both", label: "Both"},
          ],
    [variant]
  );

  async function handleSubmit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();
    const form = event.currentTarget;
    const payload = new FormData(form);
    const cityValue =
      payload.get("city") === "Other"
        ? String(payload.get("customCity") || "").trim()
        : String(payload.get("city") || "").trim();

    const eventId = createMarketingEventId(
      variant === "host" ? "host_lead" : "waitlist"
    );
    const conversionPayload = waitlistAnalyticsPayload(eventId, variant);
    const body = {
      fullName: String(payload.get("fullName") || "").trim(),
      email: String(payload.get("email") || "").trim(),
      city: cityValue,
      role: String(payload.get("role") || "").trim(),
      instagram: String(payload.get("instagram") || "").trim(),
      website: String(payload.get("website") || "").trim(),
      ...conversionPayload,
    };

    if (!body.fullName || !body.email || !body.city || !body.role) {
      setStatus({
        message: "Please fill out your name, email, city, and role.",
        tone: "is-error",
      });
      return;
    }

    setIsSubmitting(true);
    setStatus({message: "", tone: ""});
    trackMarketingEvent(
      variant === "host" ? "host_lead_submit_attempt" : "waitlist_submit_attempt",
      {city: body.city, event_id: eventId, form_variant: variant, role: body.role}
    );

    try {
      const response = await fetch("/api/join-waitlist", {
        method: "POST",
        headers: {"Content-Type": "application/json"},
        body: JSON.stringify(body),
      });
      const data = (await response.json().catch(() => ({}))) as {
        alreadyJoined?: boolean;
        error?: string;
      };

      if (!response.ok) {
        throw new Error(
          typeof data.error === "string"
            ? data.error
            : "We couldn't save your spot. Please try again."
        );
      }

      form.reset();
      setShowCustomCity(false);
      setHasStarted(false);
      setStatus({
        message: data.alreadyJoined
          ? "You're already on the list. We refreshed your details."
          : "You're in. We'll reach out when Catch opens in your city.",
        tone: "is-success",
      });
      trackMarketingEvent(
        variant === "host" ? "host_lead_submitted" : "waitlist_submitted",
        {
          already_joined: Boolean(data.alreadyJoined),
          city: body.city,
          event_id: eventId,
          form_variant: variant,
          role: body.role,
        }
      );
      trackMarketingEvent("generate_lead", {
        city: body.city,
        event_id: eventId,
        form_variant: variant,
        lead_type: variant === "host" ? "host" : "member",
      });
    } catch (error) {
      setStatus({
        message:
          error instanceof Error
            ? error.message
            : "We couldn't save your spot. Please try again.",
        tone: "is-error",
      });
      trackMarketingEvent("lead_submit_error", {
        event_id: eventId,
        form_variant: variant,
      });
    } finally {
      setIsSubmitting(false);
    }
  }

  function handleFormStart() {
    if (hasStarted) return;
    setHasStarted(true);
    trackMarketingEvent(
      variant === "host" ? "host_lead_started" : "waitlist_started",
      {form_variant: variant}
    );
  }

  return (
    <form className="waitlist-form" onFocus={handleFormStart} onSubmit={handleSubmit}>
      <label>
        Full name
        <input name="fullName" autoComplete="name" required />
      </label>
      <label>
        Email
        <input name="email" type="email" autoComplete="email" required />
      </label>
      <label>
        City
        <select
          name="city"
          required
          onChange={(event) => {
            const city = event.currentTarget.value;
            setShowCustomCity(city === "Other");
            if (city) {
              trackMarketingEvent("city_selected", {
                city,
                form_variant: variant,
              });
            }
          }}
        >
          <option value="">Choose city</option>
          {cities.map((city) => (
            <option key={city}>{city}</option>
          ))}
        </select>
      </label>
      <label hidden={!showCustomCity}>
        Your city
        <input name="customCity" autoComplete="address-level2" required={showCustomCity} />
      </label>
      <label>
        Joining as
        <select
          name="role"
          required
          defaultValue={variant === "host" ? "host" : ""}
          onChange={(event) => {
            if (event.currentTarget.value) {
              trackMarketingEvent("role_selected", {
                form_variant: variant,
                role: event.currentTarget.value,
              });
            }
          }}
        >
          {roleOptions.map((option) => (
            <option value={option.value} key={option.value || option.label}>
              {option.label}
            </option>
          ))}
        </select>
      </label>
      <label>
        {variant === "host" ? "Community or venue link" : "Instagram or community link"}
        <input name="instagram" autoComplete="url" />
      </label>
      <input
        className="honeypot"
        name="website"
        tabIndex={-1}
        autoComplete="off"
        aria-hidden="true"
      />
      <button className="button" type="submit" disabled={isSubmitting}>
        {isSubmitting ? (variant === "host" ? "Applying..." : "Joining...") : variant === "host" ? "Apply as host" : "Join the list"}
      </button>
      <p className={`form-status ${status.tone}`.trim()} role="status" aria-live="polite">
        {status.message}
      </p>
    </form>
  );
}

function MarketingConsentBanner() {
  const [consent, setConsent] = useState(() => getMarketingConsent());

  if (consent) return null;

  return (
    <aside className="consent-banner" aria-label="Analytics consent">
      <p>
        Catch uses analytics and ad measurement to understand which campaigns
        bring real waitlist and host demand.
      </p>
      <div>
        <button
          className="button button--small"
          type="button"
          onClick={() => setConsent(setMarketingConsent("accepted"))}
        >
          Accept all
        </button>
        <button
          className="button button--small button--ghost"
          type="button"
          onClick={() => setConsent(setMarketingConsent("essential"))}
        >
          Essential only
        </button>
      </div>
    </aside>
  );
}

function SiteFooter({
  brandHref,
  body,
  links,
}: {
  brandHref: string;
  body: string;
  links: Array<{href: string; label: string}>;
}) {
  return (
    <footer className="site-footer">
      <a className="brand" href={brandHref} aria-label="Catch home">
        <span className="brand__mark" aria-hidden="true">
          C
        </span>
        <span className="brand__word">Catch</span>
      </a>
      <p>{body}</p>
      <nav aria-label="Footer">
        {links.map((link) => (
          <a href={link.href} key={`${link.href}-${link.label}`}>
            {link.label}
          </a>
        ))}
      </nav>
    </footer>
  );
}

function useDocumentMeta(meta: PageMeta) {
  useEffect(() => {
    document.title = meta.title;
    setMetaContent("description", meta.description);
    setMetaProperty("og:title", meta.title);
    setMetaProperty("og:description", meta.description);
    setMetaProperty("og:type", "website");
    setMetaProperty("og:url", `https://catchdates.com${meta.canonicalPath}`);
    setMetaContent("twitter:card", "summary_large_image");
    setMetaContent("twitter:title", meta.title);
    setMetaContent("twitter:description", meta.twitterDescription);
    setCanonical(`https://catchdates.com${meta.canonicalPath}`);
    setOptionalMetaContent("robots", meta.robots);
  }, [meta]);
}

function useMarketingAnalytics(page: PageKey) {
  useEffect(() => {
    initializeMarketingAnalytics();
    trackPageView(page);
  }, [page]);
}

function useRevealAnimations(page: PageKey) {
  useEffect(() => {
    const revealItems = Array.from(document.querySelectorAll<HTMLElement>("[data-reveal]"));
    revealItems.forEach((item, index) => {
      item.style.transitionDelay = `${(index % 4) * 80}ms`;
    });

    const prefersReducedMotion = window.matchMedia("(prefers-reduced-motion: reduce)").matches;
    if (prefersReducedMotion || !("IntersectionObserver" in window)) {
      revealItems.forEach((item) => item.classList.add("is-visible"));
      return undefined;
    }

    const observer = new IntersectionObserver(
      (entries, currentObserver) => {
        entries.forEach((entry) => {
          if (!entry.isIntersecting) return;
          entry.target.classList.add("is-visible");
          currentObserver.unobserve(entry.target);
        });
      },
      {threshold: 0.15, rootMargin: "0px 0px -40px 0px"}
    );

    revealItems.forEach((item) => observer.observe(item));
    return () => observer.disconnect();
  }, [page]);
}

function useMarketingCaptures() {
  const [captures, setCaptures] = useState<Record<string, CaptureRecord>>({});

  useEffect(() => {
    let isActive = true;
    fetch("/assets/app-screenshots/manifest.json", {cache: "no-cache"})
      .then((response) => (response.ok ? response.json() : null))
      .then((manifest: CaptureManifest | null) => {
        if (!isActive || !Array.isArray(manifest?.captures)) return;
        const byId: Record<string, CaptureRecord> = {};
        for (const capture of manifest.captures) {
          byId[capture.id] = capture;
        }
        setCaptures(byId);
      })
      .catch(() => {
        // Local static pages can run without a fetchable manifest.
      });

    return () => {
      isActive = false;
    };
  }, []);

  return captures;
}

function getPageKey(): Exclude<PageKey, "listing"> {
  if (window.location.pathname.startsWith("/host")) return "host";
  if (window.location.pathname.startsWith("/organizers")) return "organizers";
  return "home";
}

function getHostListingForPath(pathname: string) {
  const normalizedPath = pathname.endsWith("/") ? pathname : `${pathname}/`;
  return hostListings.find((listing) => listing.path === normalizedPath) ?? null;
}

function nullableString(value: FormDataEntryValue | null): string | null {
  if (typeof value !== "string") return null;
  const trimmed = value.trim();
  return trimmed.length > 0 ? trimmed : null;
}

function parseProofUrls(value: FormDataEntryValue | null): string[] {
  if (typeof value !== "string") return [];
  const urls = value
    .split(/[\n,]+/)
    .map((item) => item.trim())
    .filter(Boolean)
    .map((item) =>
      item.startsWith("http://") || item.startsWith("https://") ?
        item :
        `https://${item}`
    )
    .filter((item) => {
      try {
        const url = new URL(item);
        return url.protocol === "http:" || url.protocol === "https:";
      } catch {
        return false;
      }
    });
  return [...new Set(urls)].slice(0, 8);
}

function mergeReviews(
  incoming: HostListingReview[],
  existing: HostListingReview[]
): HostListingReview[] {
  const seen = new Set<string>();
  const merged: HostListingReview[] = [];
  for (const review of [...incoming, ...existing]) {
    const key = reviewKey(review);
    if (seen.has(key)) continue;
    seen.add(key);
    merged.push(review);
  }
  return merged.sort(
    (a, b) => reviewTime(b.createdAt) - reviewTime(a.createdAt)
  );
}

function reviewKey(review: HostListingReview): string {
  return review.id ?? `${review.reviewerName}-${review.createdAt}`;
}

function reviewTime(value: string): number {
  const parsed = Date.parse(value);
  return Number.isNaN(parsed) ? 0 : parsed;
}

function reviewDateLabel(value: string): string {
  const parsed = Date.parse(value);
  if (Number.isNaN(parsed)) return value;
  const elapsedMs = Date.now() - parsed;
  if (elapsedMs >= 0 && elapsedMs < 60 * 1000) return "Just now";
  return new Intl.DateTimeFormat("en", {
    month: "short",
    day: "numeric",
    year: "numeric",
  }).format(new Date(parsed));
}

function readableError(error: unknown): string {
  return error instanceof Error ?
    error.message :
    "Something went wrong. Please try again.";
}

function pageMetaForListing(listing: HostListing): PageMeta {
  return {
    title: `${listing.name} | ${listing.city} organizer profile | Catch`,
    description: listing.description,
    canonicalPath: listing.path,
    twitterDescription: listing.sourceSummary,
    robots: listing.indexing,
  };
}

function pageClassFor(page: PageKey) {
  if (page === "host") return "host-page";
  if (page === "listing") return "listing-page";
  if (page === "organizers") return "organizers-page";
  return "home-page";
}

function setMetaContent(name: string, content: string) {
  const element = ensureMeta("name", name);
  element.content = content;
}

function setOptionalMetaContent(name: string, content?: string) {
  const selector = `meta[name="${name}"]`;
  const existing = document.head.querySelector<HTMLMetaElement>(selector);
  if (!content) {
    existing?.remove();
    return;
  }
  const element = existing ?? document.createElement("meta");
  element.name = name;
  element.content = content;
  if (!existing) document.head.appendChild(element);
}

function setMetaProperty(property: string, content: string) {
  const element = ensureMeta("property", property);
  element.content = content;
}

function ensureMeta(attribute: "name" | "property", value: string) {
  let element = document.head.querySelector<HTMLMetaElement>(`meta[${attribute}="${value}"]`);
  if (!element) {
    element = document.createElement("meta");
    element.setAttribute(attribute, value);
    document.head.appendChild(element);
  }
  return element;
}

function setCanonical(href: string) {
  let link = document.head.querySelector<HTMLLinkElement>('link[rel="canonical"]');
  if (!link) {
    link = document.createElement("link");
    link.rel = "canonical";
    document.head.appendChild(link);
  }
  link.href = href;
}

function trackCtaClick(label: string, href: string) {
  trackMarketingEvent("cta_click", {
    cta_href: href,
    cta_label: label,
    page_path: `${window.location.pathname}${window.location.search}`,
  });
}

function slugForEvent(value: string) {
  return value.toLowerCase().replace(/[^a-z0-9]+/g, "_").replace(/^_|_$/g, "");
}

function fallbackAltForCapture(id: string) {
  switch (id) {
    case "member-event-discovery":
      return "Catch event discovery screen showing hosted singles events";
    case "post-run-catch-window":
      return "Catch post-event roster screen for the 24 hour catch window";
    case "match-chat-context":
      return "Catch match chat screen with shared event context";
    case "host-event-setup":
      return "Catch host event setup screen";
    case "host-live-console":
      return "Catch host live console with roster and check-in controls";
    case "host-post-event-report":
      return "Catch host post-event report screen";
    default:
      return "Catch app screen";
  }
}

function fallbackCaptionForCapture(id: string) {
  switch (id) {
    case "member-event-discovery":
      return "Members browse real hosted events before any dating surface opens.";
    case "post-run-catch-window":
      return "The roster opens after attendance creates shared context.";
    case "match-chat-context":
      return "Matches start with the event they already shared.";
    case "host-event-setup":
      return "Set admission rules, invite links, waitlist, payments, and Event Success before publishing.";
    case "host-live-console":
      return "Check in guests, manage waitlist movement, and run Event Success modules from one screen.";
    case "host-post-event-report":
      return "Review invite conversion, waitlist movement, attendance, catches, matches, and chats after the event closes.";
    default:
      return "Catch app screen for members and hosts.";
  }
}

export default App;
