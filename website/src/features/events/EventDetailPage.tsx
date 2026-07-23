import {eventDetailCopy} from "../../content/events";
import {siteFooterLegalLinks} from "../../content/site";
import {SiteFooter, SiteHeader, WebsitePageMain} from "../../shared/site";
import {useAppDownloadCtas} from "../marketing/useAppDownloadCtas";
import type {EventDetailRecord} from "./eventDetailModel";
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
  return (
    <>
      <SiteHeader
        actions={[{
          href: event.listing.path,
          label: eventDetailCopy.nav.organizerAction,
        }]}
        brandHref="/"
        nav={[
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

      <SiteFooter
        brandHref="/"
        body={eventDetailCopy.footerBody}
        links={[
          {href: event.listing.path, label: eventDetailCopy.nav.organizerAction},
          ...siteFooterLegalLinks,
        ]}
      />
    </>
  );
}
