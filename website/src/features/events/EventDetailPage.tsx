import {observeOrganizerProviders} from "../organizers/observeOrganizerProviders";
import {observeOrganizerPageView} from "../organizers/analytics";
import {useEffect} from "react";
import {eventDetailCopy} from "../../content/events";
import {PublicSiteFooter, PublicSiteHeader, WebsitePageMain} from "../../shared/site";
import {useAppDownloadCtas} from "../marketing/useAppDownloadCtas";
import type {EventDetailRecord} from "./eventDetailModel";
import {recordEventInviteLinkOpen} from "../../firebase";
import {
  eventInviteSessionId,
  eventInviteTokenFromLocation,
} from "../../shared/eventInviteAttribution";
import {
  EventDetailFactsSection,
  EventDetailHeroSection,
  EventDetailProvenanceSection,
  EventDetailReviewsSection,
} from "./sections/EventDetailSections";

export function EventDetailPage({event}: {event: EventDetailRecord}) {
  const appDownloadCtas = useAppDownloadCtas({
    placement: `event-detail-${event.eventId}`,
  });
  useEffect(() => observeOrganizerPageView(event.listing, "eventView", "event_detail", event.eventId), [event.listing, event.eventId]);
  useEffect(() => observeOrganizerProviders(event.listing, event.eventId), [event.listing, event.eventId]);
  const inviteToken = eventInviteTokenFromLocation();
  useEffect(() => {
    if (!inviteToken) return;
    void recordEventInviteLinkOpen({
      eventId: event.eventId,
      inviteLinkId: inviteToken,
      surface: "marketingWeb",
      sessionId: eventInviteSessionId(),
    }).catch(() => undefined);
  }, [event.eventId, inviteToken]);
  return (
    <>
      <PublicSiteHeader
        localActions={[{
          href: event.listing.path,
          label: eventDetailCopy.nav.organizerAction,
        }]}
        localNav={[
          {href: "/organizers/", label: eventDetailCopy.nav.organizers},
          {href: "/host/", label: eventDetailCopy.nav.host},
        ]}
      />

      <WebsitePageMain id="event-detail">
        <EventDetailHeroSection
          appDownloadCtas={appDownloadCtas}
          event={event}
        />
        <EventDetailFactsSection event={event} />
        <EventDetailProvenanceSection event={event} />
        <EventDetailReviewsSection event={event} />
      </WebsitePageMain>

      <PublicSiteFooter
        body={eventDetailCopy.footerBody}
        links={[
          {href: event.listing.path, label: eventDetailCopy.nav.organizerAction},
        ]}
      />
    </>
  );
}
