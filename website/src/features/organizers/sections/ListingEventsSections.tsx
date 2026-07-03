import {trackMarketingEvent} from "../../../analytics";
import {SectionHeader} from "../../../shared/site";
import {
  AppDownloadCtaGroup,
  ContentGrid,
  EventActionCard,
  type EventActionCardAction,
  type EventActionCardModel,
  ListingEventDownloadPanel,
  ListingEventEvidenceList,
  ListingSuccessMetricGrid,
  ListingSection,
} from "../../../shared/ui/primitives";
import {useAppDownloadCtas} from "../../marketing/useAppDownloadCtas";
import {trackOrganizerAnalytics} from "../analytics";
import {
  eventActionCardForListing,
  externalEventActionCardForListing,
} from "../publicDiscovery";
import type {HostListing, HostListingEventSuccessSummary} from "../types";

export function ListingCatchEventsSection({listing}: {listing: HostListing}) {
  const events = listing.catchEvents ?? [];
  const eventCards = events.map((event) =>
    withCatchEventActionTracking(
      listing,
      event.id,
      eventActionCardForListing(listing, event)
    )
  );
  const appDownloadCtas = useAppDownloadCtas({
    placement: `listing-events-${listing.slug}`,
  });

  return (
    <ListingSection
      variant="events"
      id="events"
      aria-labelledby="listing-catch-events-title"
    >
      <SectionHeader
        eyebrow="Catch events"
        id="listing-catch-events-title"
        title="Events created inside Catch."
        body="App-created clubs should show the actual event pipeline: what is coming up, what filled, and what happened after people showed up." />
      <ContentGrid variant="listing-event">
        {eventCards.map((event) => (
          <EventActionCard
            event={event}
            key={event.id}
            onActionClick={trackListingEventActionClick}
          />
        ))}
      </ContentGrid>
      <ListingEventDownloadPanel
        kicker="Member app"
        heading="Book, check in, and review from Catch."
        body="Public pages expose the event record. The app handles booking, waitlist movement, attendance, catches, and verified reviews."
      >
        <AppDownloadCtaGroup {...appDownloadCtas} variant="compact" />
      </ListingEventDownloadPanel>
    </ListingSection>
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
    withExternalEventActionTracking(
      listing,
      event.id,
      externalEventActionCardForListing(listing, event)
    )
  );
  return (
    <ListingSection
      variant="events"
      id={anchorId}
      aria-labelledby="listing-external-events-title"
    >
      <SectionHeader
        eyebrow="External events"
        id="listing-external-events-title"
        title="Source-attributed events from public listings."
        body="These events come from approved intake sources and remain read-only: Catch does not run booking, payment, reservations, waitlists, or attendance for them." />
      <ContentGrid variant="listing-event">
        {eventCards.map((event) => (
          <EventActionCard
            event={event}
            key={event.id}
            onActionClick={trackListingEventActionClick}
          />
        ))}
      </ContentGrid>
    </ListingSection>
  );
}

function trackListingEventActionClick(action: EventActionCardAction) {
  trackMarketingEvent("cta_click", {
    cta_href: action.href,
    cta_label: action.trackingLabel ?? "event_action",
    page_path: `${window.location.pathname}${window.location.search}`,
  });
}

function withCatchEventActionTracking(
  listing: HostListing,
  eventId: string,
  card: EventActionCardModel
): EventActionCardModel {
  return {
    ...card,
    actions: card.actions.map((action) => {
      if (action.trackingLabel === "listing_event_success") {
        return {
          ...action,
          onClick: () => trackOrganizerAnalytics(
            listing,
            "eventView",
            "event_success_panel",
            eventId
          ),
        };
      }
      if (action.trackingLabel?.startsWith("listing_event_open_")) {
        return {
          ...action,
          onClick: () => trackOrganizerAnalytics(
            listing,
            "eventView",
            "catch_event_card",
            eventId
          ),
        };
      }
      return action;
    }),
  };
}

function withExternalEventActionTracking(
  listing: HostListing,
  eventId: string,
  card: EventActionCardModel
): EventActionCardModel {
  return {
    ...card,
    actions: card.actions.map((action) => {
      if (action.trackingLabel !== "external_event_source") return action;
      return {
        ...action,
        onClick: () => trackOrganizerAnalytics(
          listing,
          "outboundClick",
          "external_event_card",
          eventId
        ),
      };
    }),
  };
}

export function ListingEventEvidenceSection({listing}: {listing: HostListing}) {
  const events = listing.eventEvidence ?? [];
  if (!events.length) return null;
  const eventItems = events.map((event) => ({
    date: event.date,
    facts: event.facts,
    key: event.title,
    location: event.location,
    onSourceClick: () => trackOrganizerAnalytics(
      listing,
      "outboundClick",
      "event_evidence"
    ),
    sourceHref: event.sourceHref,
    sourceLabel: event.sourceLabel,
    summary: event.summary,
    title: event.title,
  }));

  return (
    <ListingSection variant="events" aria-labelledby="listing-events-title">
      <SectionHeader
        eyebrow="Event evidence"
        id="listing-events-title"
        title="Public events tied to this host." />
      <ListingEventEvidenceList items={eventItems} />
    </ListingSection>
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
    <ListingSection
      variant="success"
      id="event-success"
      aria-labelledby="event-success-title"
    >
      <SectionHeader
        eyebrow="Event Success"
        id="event-success-title"
        title="The claimed profile can show what Catch actually operated."
        body="These are aggregate, host-safe outcomes from a completed Catch event. This is the kind of proof an app-created club can show that a scraped unclaimed listing cannot." />
      <ListingSuccessMetricGrid items={metrics} />
    </ListingSection>
  );
}
