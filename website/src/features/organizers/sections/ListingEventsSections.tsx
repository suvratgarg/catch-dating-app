import {EventActionCard} from "../../../components/site";
import {AppDownloadCtas} from "../../marketing/AppDownloadCtas";
import {trackOrganizerAnalytics} from "../analytics";
import {
  eventActionCardForListing,
  externalEventActionCardForListing,
} from "../publicDiscovery";
import type {HostListing, HostListingEventSuccessSummary} from "../types";

export function ListingCatchEventsSection({listing}: {listing: HostListing}) {
  const events = listing.catchEvents ?? [];
  const eventCards = events.map((event) => eventActionCardForListing(listing, event));
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
        {eventCards.map((event) => (
          <EventActionCard event={event} key={event.id} />
        ))}
      </div>
      <div className="listing-event-download" data-reveal>
        <div>
          <span className="ui-label">Member app</span>
          <h3>Book, check in, and review from Catch.</h3>
          <p>
            Public pages expose the event record. The app handles booking,
            waitlist movement, attendance, catches, and verified reviews.
          </p>
        </div>
        <AppDownloadCtas
          placement={`listing-events-${listing.slug}`}
          className="app-download-ctas--compact"
        />
      </div>
    </section>
  );
}

export function ListingExternalEventsSection({
  anchorId,
  listing,
}: {
  anchorId: string;
  listing: HostListing;
}) {
  const events = listing.externalEvents ?? [];
  const eventCards = events.map((event) =>
    externalEventActionCardForListing(listing, event)
  );
  return (
    <section
      className="listing-section listing-section--events"
      id={anchorId}
      aria-labelledby="listing-external-events-title"
    >
      <div className="section-heading" data-reveal>
        <span className="ui-label">External events</span>
        <h2 id="listing-external-events-title">Source-attributed events from public listings.</h2>
        <p>
          These events come from approved intake sources and remain read-only:
          Catch does not run booking, payment, reservations, waitlists, or
          attendance for them.
        </p>
      </div>
      <div className="listing-catch-event-grid">
        {eventCards.map((event) => (
          <EventActionCard event={event} key={event.id} />
        ))}
      </div>
    </section>
  );
}

export function ListingEventEvidenceSection({listing}: {listing: HostListing}) {
  const events = listing.eventEvidence ?? [];
  if (!events.length) return null;

  return (
    <section className="listing-section listing-section--events" aria-labelledby="listing-events-title">
      <div className="section-heading" data-reveal>
        <span className="ui-label">Event evidence</span>
        <h2 id="listing-events-title">Public events tied to this host.</h2>
      </div>
      <div className="listing-event-stack">
        {events.map((event) => (
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
                  <a
                    href={event.sourceHref}
                    target="_blank"
                    rel="noreferrer"
                    onClick={() => trackOrganizerAnalytics(
                      listing,
                      "outboundClick",
                      "event_evidence"
                    )}
                  >
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
  );
}

export function ListingEventSuccessSection({
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
    <section
      className="listing-section listing-section--success"
      id="event-success"
      aria-labelledby="event-success-title"
    >
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
