import {
  type CSSProperties,
  type FormEvent,
  type ReactNode,
  useEffect,
  useMemo,
  useRef,
  useState,
} from "react";
import {trackMarketingEvent} from "../analytics";

export interface SiteNavItem {
  href: string;
  label: string;
}

export interface SiteHeaderAction extends SiteNavItem {
  variant?: "primary" | "secondary";
}

export interface CaptureRecord {
  id: string;
  webPath: string;
  alt: string;
  caption: string;
  walkthroughStep: string;
}

export interface ActivityMeta {
  label: string;
  token: string;
  short: string;
}

export interface ActivityListing {
  logo: {
    text: string;
  };
  status: string;
}

export interface PublicSearchSuggestion {
  id: string;
  href: string;
  label: string;
  meta: string;
  type: "organizer" | "event" | "format";
  activityToken?: string;
}

export interface PublicEventCardModel {
  id: string;
  title: string;
  href: string;
  hostName: string;
  activityLabel: string;
  activityToken: string;
  city: string;
  date: string;
  location: string;
  priceLabel: string;
  bookedCount: number;
  capacityLimit: number;
  waitlistedCount: number;
  summary: string;
}

export interface EventAction {
  href: string;
  label: string;
  variant?: "primary" | "secondary";
  target?: string;
  rel?: string;
  trackingLabel?: string;
}

export interface EventActionCardModel {
  id: string;
  eyebrow: string;
  title: string;
  body: string;
  activityToken: string;
  meta: Array<{label: string; value: string}>;
  counts: Array<{label: string; value: string | number}>;
  actions: EventAction[];
}

export interface PublicReviewCardModel {
  id: string;
  reviewerName: string;
  createdAtLabel: string;
  rating: number;
  comment: string;
  verified: boolean;
  verificationLabel: string;
  sourceLabel: string;
  ownerResponse?: {
    hostName: string;
    message: string;
    updatedAtLabel: string;
  } | null;
}

export interface ProcessStatusAction {
  href: string;
  label: string;
  variant?: "primary" | "secondary";
  trackingLabel?: string;
}

export interface ProcessStatusItem {
  title: string;
  body: string;
}

export interface ProductModuleCardModel {
  id: string;
  label: string;
  title: string;
  body: string;
  facts: string[];
  activityToken?: string;
}

export function SiteHeader({
  brandHref,
  nav,
  actions,
  ctaHref,
  ctaLabel,
}: {
  brandHref: string;
  nav: SiteNavItem[];
  actions?: SiteHeaderAction[];
  ctaHref?: string;
  ctaLabel?: string;
}) {
  const [isScrolled, setIsScrolled] = useState(false);
  const headerActions = actions ?? (
    ctaHref && ctaLabel ? [{href: ctaHref, label: ctaLabel}] : []
  );

  useEffect(() => {
    const syncHeader = () => setIsScrolled(window.scrollY > 18);
    syncHeader();
    window.addEventListener("scroll", syncHeader, {passive: true});
    return () => window.removeEventListener("scroll", syncHeader);
  }, []);

  return (
    <header className={`site-header ${isScrolled ? "is-scrolled" : ""}`}>
      <a className="brand" href={brandHref} aria-label="Catch home">
        <span className="brand__mark" aria-hidden="true">C</span>
        <span className="brand__word">Catch</span>
      </a>

      <nav className="site-nav" aria-label="Primary">
        {nav.map((item) => (
          <a
            href={item.href}
            key={`${item.href}-${item.label}`}
            onClick={() => trackCtaClick(`nav_${slugForTracking(item.label)}`, item.href)}
          >
            {item.label}
          </a>
        ))}
      </nav>

      <div className="site-header__actions">
        {headerActions.map((action) => (
          <a
            className={`button button--small ${action.variant === "secondary" ? "button--ghost" : ""}`.trim()}
            href={action.href}
            key={`${action.href}-${action.label}`}
            onClick={() => trackCtaClick(`header_${slugForTracking(action.label)}`, action.href)}
          >
            {action.label}
          </a>
        ))}
      </div>
    </header>
  );
}

export function SiteFooter({
  brandHref,
  body,
  links,
}: {
  brandHref: string;
  body: string;
  links: SiteNavItem[];
}) {
  return (
    <footer className="site-footer">
      <a className="brand" href={brandHref} aria-label="Catch home">
        <span className="brand__mark" aria-hidden="true">C</span>
        <span className="brand__word">Catch</span>
      </a>
      <p>{body}</p>
      <nav aria-label="Footer">
        {links.map((link) => (
          <a
            href={link.href}
            key={`${link.href}-${link.label}`}
            onClick={() => trackCtaClick(`footer_${slugForTracking(link.label)}`, link.href)}
          >
            {link.label}
          </a>
        ))}
      </nav>
    </footer>
  );
}

export function SectionHeader({
  eyebrow,
  title,
  body,
  id,
  wide = false,
}: {
  eyebrow?: string;
  title: ReactNode;
  body?: ReactNode;
  id?: string;
  wide?: boolean;
}) {
  return (
    <div className={`section-heading ${wide ? "section-heading--wide" : ""}`} data-reveal>
      {eyebrow ? <span className="ui-label">{eyebrow}</span> : null}
      <h2 id={id}>{title}</h2>
      {body ? <p>{body}</p> : null}
    </div>
  );
}

export function ActivityMark({
  listing,
  activity,
  size = "md",
}: {
  listing: ActivityListing;
  activity: ActivityMeta;
  size?: "sm" | "md" | "lg";
}) {
  const isUnclaimed = listing.status.toLowerCase() === "unclaimed";
  return (
    <span
      className={`activity-mark activity-mark--${size} ${isUnclaimed ? "is-unclaimed" : ""}`}
      style={{"--activity": activity.token} as CSSProperties}
      aria-hidden="true"
    >
      {listing.logo.text || activity.short}
    </span>
  );
}

export function StatusBadge({
  status,
  isVerified,
  compact = false,
}: {
  status: string;
  isVerified: boolean;
  compact?: boolean;
}) {
  const isUnclaimed = status.toLowerCase() === "unclaimed";
  const label = isVerified
    ? compact ? "Verified" : "Verified on Catch"
    : isUnclaimed
      ? "Unclaimed"
      : "Claimed";
  return (
    <span className={`status-badge ${isVerified ? "is-verified" : isUnclaimed ? "is-unclaimed" : "is-claimed"}`}>
      {label}
    </span>
  );
}

export function ProfileStrength({value}: {value: number}) {
  return (
    <div className="profile-strength" aria-label={`Profile strength ${value}%`}>
      <span>{value}%</span>
      <i><b style={{width: `${value}%`}} /></i>
    </div>
  );
}

export function CaptureCard({
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

export function PublicSearchBar({
  cityName,
  suggestions,
  placeholder = "Clubs, organizers, venues, formats, events...",
}: {
  cityName: string;
  suggestions: PublicSearchSuggestion[];
  placeholder?: string;
}) {
  const [query, setQuery] = useState("");
  const [open, setOpen] = useState(false);
  const rootRef = useRef<HTMLFormElement | null>(null);
  const normalizedQuery = query.trim().toLowerCase();
  const results = useMemo(() => {
    if (normalizedQuery.length < 2) return suggestions.slice(0, 5);
    return suggestions
      .filter((item) =>
        [item.label, item.meta, item.type].join(" ").toLowerCase().includes(normalizedQuery)
      )
      .slice(0, 7);
  }, [normalizedQuery, suggestions]);

  useEffect(() => {
    const handlePointerDown = (event: MouseEvent) => {
      if (!rootRef.current?.contains(event.target as Node)) {
        setOpen(false);
      }
    };
    document.addEventListener("mousedown", handlePointerDown);
    return () => document.removeEventListener("mousedown", handlePointerDown);
  }, []);

  function submitSearch(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();
    const href = normalizedQuery ?
      `/organizers/?q=${encodeURIComponent(query.trim())}` :
      "/organizers/";
    trackCtaClick("public_search_submit", href);
    window.location.assign(href);
  }

  return (
    <form className="public-search" data-reveal onSubmit={submitSearch} ref={rootRef}>
      <button
        className="public-search__city"
        type="button"
        onClick={() => {
          trackCtaClick("public_search_city", "/organizers/");
          window.location.assign("/organizers/");
        }}
      >
        {cityName}
      </button>
      <label className="public-search__input">
        <span>Search Catch</span>
        <input
          value={query}
          placeholder={placeholder}
          onChange={(event) => {
            setQuery(event.currentTarget.value);
            setOpen(true);
          }}
          onFocus={() => setOpen(true)}
        />
      </label>
      <button className="public-search__go" type="submit">Search</button>
      {open && results.length ? (
        <div className="public-search__results">
          {results.map((item) => (
            <a
              href={item.href}
              key={item.id}
              onClick={() => trackCtaClick(`public_search_${item.type}`, item.href)}
              style={{"--activity": item.activityToken ?? "var(--website-accent)"} as CSSProperties}
            >
              <span className="public-search__glyph" aria-hidden="true">
                {item.type === "event" ? "EV" : item.type === "format" ? "FT" : "OR"}
              </span>
              <span>
                <strong>{item.label}</strong>
                <small>{item.meta}</small>
              </span>
              <em>{item.type}</em>
            </a>
          ))}
        </div>
      ) : null}
    </form>
  );
}

export function PublicEventCard({event}: {event: PublicEventCardModel}) {
  const capacityLabel = event.capacityLimit > 0
    ? `${event.bookedCount}/${event.capacityLimit} booked`
    : `${event.bookedCount} booked`;
  return (
    <a
      className="public-event-card"
      href={event.href}
      data-reveal
      onClick={() => trackCtaClick("public_event_card", event.href)}
      style={{"--activity": event.activityToken} as CSSProperties}
    >
      <div className="public-event-card__art" aria-hidden="true">
        <span>{event.activityLabel.slice(0, 2).toUpperCase()}</span>
      </div>
      <div className="public-event-card__body">
        <div className="public-event-card__meta">
          <span>{event.date}</span>
          <span>{event.city}</span>
        </div>
        <h3>{event.title}</h3>
        <p>{event.summary}</p>
        <div className="public-event-card__facts">
          <span>{event.hostName}</span>
          <span>{event.location}</span>
          <span>{event.priceLabel}</span>
          <span>{capacityLabel}</span>
          {event.waitlistedCount ? <span>{event.waitlistedCount} waitlisted</span> : null}
        </div>
      </div>
    </a>
  );
}

export function EventActionCard({event}: {event: EventActionCardModel}) {
  return (
    <article
      className="event-action-card"
      data-reveal
      id={event.id}
      style={{"--activity": event.activityToken} as CSSProperties}
    >
      <div className="event-action-card__lead">
        <span className="ui-label">{event.eyebrow}</span>
        <h3>{event.title}</h3>
        <p>{event.body}</p>
      </div>
      <dl className="event-action-card__meta">
        {event.meta.map((item) => (
          <div key={`${item.label}-${item.value}`}>
            <dt>{item.label}</dt>
            <dd>{item.value}</dd>
          </div>
        ))}
      </dl>
      <div className="event-action-card__counts" aria-label={`${event.title} event counts`}>
        {event.counts.map((item) => (
          <span key={`${item.label}-${item.value}`}>
            <strong>{item.value}</strong>
            {item.label}
          </span>
        ))}
      </div>
      <div className="event-action-card__actions">
        {event.actions.map((action) => (
          <a
            className={action.variant === "secondary" ? "button button--ghost" : "button"}
            href={action.href}
            key={`${action.href}-${action.label}`}
            target={action.target}
            rel={action.rel}
            onClick={() => trackCtaClick(action.trackingLabel ?? "event_action", action.href)}
          >
            {action.label}
          </a>
        ))}
      </div>
    </article>
  );
}

export function ReviewSignalLane({
  title,
  body,
  reviews,
  emptyTitle,
  emptyBody,
}: {
  title: string;
  body: string;
  reviews: PublicReviewCardModel[];
  emptyTitle: string;
  emptyBody: string;
}) {
  return (
    <section className="review-signal-lane" aria-label={title}>
      <div className="review-signal-lane__head">
        <div>
          <span className="ui-label">{reviews.length} visible</span>
          <h3>{title}</h3>
        </div>
        <p>{body}</p>
      </div>
      {reviews.length ? (
        <div className="review-signal-lane__stack">
          {reviews.map((review) => (
            <ReviewSignalCard key={review.id} review={review} />
          ))}
        </div>
      ) : (
        <div className="review-signal-lane__empty">
          <strong>{emptyTitle}</strong>
          <p>{emptyBody}</p>
        </div>
      )}
    </section>
  );
}

export function ReviewSignalCard({review}: {review: PublicReviewCardModel}) {
  return (
    <article className="review-signal-card">
      <div className="review-signal-card__header">
        <div>
          <strong>{review.reviewerName}</strong>
          <span>{review.createdAtLabel}</span>
        </div>
        <span aria-label={`${review.rating} out of 5 stars`}>
          {"★".repeat(Math.max(0, Math.min(5, Math.round(review.rating))))}
        </span>
      </div>
      <div className="review-signal-card__badges">
        <span className={`review-signal-badge ${review.verified ? "is-verified" : "is-unverified"}`}>
          {review.verificationLabel}
        </span>
        <span className="review-signal-badge">{review.sourceLabel}</span>
      </div>
      {review.comment ? <p>{review.comment}</p> : null}
      {review.ownerResponse ? (
        <div className="listing-owner-response">
          <span>Host response · {review.ownerResponse.hostName}</span>
          <p>{review.ownerResponse.message}</p>
          <small>{review.ownerResponse.updatedAtLabel}</small>
        </div>
      ) : null}
    </article>
  );
}

export function OwnerResponsePrompt({
  title,
  body,
  stats,
  ctaHref,
  ctaLabel,
}: {
  title: string;
  body: string;
  stats: Array<{label: string; value: string | number}>;
  ctaHref?: string;
  ctaLabel?: string;
}) {
  return (
    <aside className="owner-response-prompt" data-reveal>
      <div>
        <span className="ui-label">Owner response</span>
        <h3>{title}</h3>
        <p>{body}</p>
      </div>
      <div className="owner-response-prompt__stats">
        {stats.map((item) => (
          <span key={item.label}>
            <strong>{item.value}</strong>
            {item.label}
          </span>
        ))}
      </div>
      {ctaHref && ctaLabel ? (
        <a
          className="button button--ghost"
          href={ctaHref}
          onClick={() => trackCtaClick("owner_response_prompt", ctaHref)}
        >
          {ctaLabel}
        </a>
      ) : null}
    </aside>
  );
}

export function ProcessStatusPanel({
  mark,
  eyebrow,
  title,
  body,
  items,
  actions,
}: {
  mark: string;
  eyebrow: string;
  title: ReactNode;
  body: ReactNode;
  items: ProcessStatusItem[];
  actions: ProcessStatusAction[];
}) {
  return (
    <section className="process-status-panel" data-reveal>
      <div className="process-status-panel__card">
        <span className="process-status-panel__mark" aria-hidden="true">
          {mark}
        </span>
        <div>
          <span className="ui-label">{eyebrow}</span>
          <h2>{title}</h2>
          <p>{body}</p>
        </div>
      </div>
      <div className="process-status-panel__grid">
        {items.map((item) => (
          <article key={item.title}>
            <strong>{item.title}</strong>
            <p>{item.body}</p>
          </article>
        ))}
      </div>
      <div className="process-status-panel__actions">
        {actions.map((action) => (
          <a
            className={action.variant === "secondary" ? "button button--ghost" : "button"}
            href={action.href}
            key={`${action.href}-${action.label}`}
            onClick={() => trackCtaClick(action.trackingLabel ?? "process_status_action", action.href)}
          >
            {action.label}
          </a>
        ))}
      </div>
    </section>
  );
}

export function ProductModuleGrid({modules}: {modules: ProductModuleCardModel[]}) {
  return (
    <div className="product-module-grid">
      {modules.map((module) => (
        <article
          className="product-module-card"
          data-reveal
          key={module.id}
          style={{"--activity": module.activityToken ?? "var(--website-accent)"} as CSSProperties}
        >
          <span className="ui-label">{module.label}</span>
          <h3>{module.title}</h3>
          <p>{module.body}</p>
          <ul>
            {module.facts.map((fact) => (
              <li key={fact}>{fact}</li>
            ))}
          </ul>
        </article>
      ))}
    </div>
  );
}

function trackCtaClick(label: string, href: string) {
  trackMarketingEvent("cta_click", {
    cta_href: href,
    cta_label: label,
    page_path: `${window.location.pathname}${window.location.search}`,
  });
}

function slugForTracking(value: string) {
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
