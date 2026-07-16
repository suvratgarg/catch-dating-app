import {websiteCopy} from "@content/generated";
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
        eyebrow={websiteCopy["listingeventssections_0388"]}
        id="listing-catch-events-title"
        title={websiteCopy["listingeventssections_0394"]}
        body={websiteCopy["listingeventssections_0385"]} />
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
        kicker={websiteCopy["listingeventssections_0396"]}
        heading={websiteCopy["listingeventssections_0386"]}
        body={websiteCopy["listingeventssections_0399"]}
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
        eyebrow={websiteCopy["listingeventssections_0395"]}
        id="listing-external-events-title"
        title={websiteCopy["listingeventssections_0401"]}
        body={websiteCopy["listingeventssections_0404"]} />
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
        eyebrow={websiteCopy["listingeventssections_0392"]}
        id="listing-events-title"
        title={websiteCopy["listingeventssections_0398"]} />
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
    {label: websiteCopy["listingeventssections_0387"], value: summary.bookedCount},
    {label: websiteCopy["listingeventssections_0391"], value: summary.checkedInCount},
    {label: websiteCopy["listingeventssections_0389"], value: summary.catchSentCount},
    {label: websiteCopy["listingeventssections_0397"], value: summary.mutualMatchCount},
    {label: websiteCopy["listingeventssections_0390"], value: summary.chatStartedCount},
    {label: websiteCopy["listingeventssections_0400"], value: summary.safetyIncidentCount},
  ];
  return (
    <ListingSection
      variant="success"
      id="event-success"
      aria-labelledby="event-success-title"
    >
      <SectionHeader
        eyebrow={websiteCopy["listingeventssections_0393"]}
        id="event-success-title"
        title={websiteCopy["listingeventssections_0402"]}
        body={websiteCopy["listingeventssections_0403"]} />
      <ListingSuccessMetricGrid items={metrics} />
    </ListingSection>
  );
}
