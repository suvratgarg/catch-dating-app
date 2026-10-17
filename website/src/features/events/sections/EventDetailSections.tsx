import type {ReactNode} from "react";
import {trackOrganizerProviderOutboundClick} from "../../organizers/observeOrganizerProviders";
import {trackOrganizerAnalytics} from "../../organizers/analytics";
import {ButtonLink, EventDetailFactGrid, EventDetailHeroLayout, EventDetailMedia,
  EventDetailOrganizerPanel, EventDetailSection, EventDetailSourceLink,
  ReviewSignalLane} from "../../../shared/ui/primitives";
import {EventDetailBodyLayout, EventDetailItinerary} from "../../../shared/ui/primitives/eventDetail";
import {eventDetailCopy as copy} from "../../../content/events";
import {interpolateContent} from "../../../content/interpolate";
import {ActivityMark, StatusBadge} from "../../organizers/OrganizerIdentity";
import {organizerPolicyForListing} from "../../organizers/organizerPolicy";
import {activityForKind} from "../../organizers/publicDiscovery";
import {buildListingReviewSummary} from "../../reviews/reviewModel";
import type {EventDetailRecord} from "../eventDetailModel";

export function EventDetailHeroSection({event, guestEntry}: {
  event: EventDetailRecord; guestEntry?: ReactNode;
}) {
  const activity = activityForKind(event.activityKind);
  const external = event.supply === "external";
  return <EventDetailHeroLayout activityToken={activity.token} eyebrow={activity.label}
    title={event.title}
    media={<EventDetailMedia src={event.photoUrl} alt={interpolateContent(copy.invitation.coverAlt, {title: event.title})}
      fallback={<><span>{activity.label}</span><strong>{event.title}</strong><span>{event.listing.name}</span></>} />}
    host={<><ActivityMark listing={event.listing} size="sm" /><div><span>{copy.hero.hostedByLabel}</span>
      <EventDetailSourceLink href={event.listing.path}>{event.listing.name}</EventDetailSourceLink></div></>}
    facts={[
      {label: copy.hero.facts.when, value: <>{event.date}{event.timezone ? <small>{event.timezone}</small> : null}</>},
      {label: copy.hero.facts.where, value: <>{event.location}{event.locationDetails.trim() ? <small>{event.locationDetails}</small> : null}</>},
      {label: copy.details.price, value: event.priceLabel},
    ]}>
    {external ? <>
      <p>{event.registrationState === "closed" ? copy.details.registrationClosed :
        interpolateContent(copy.hero.externalActionHeading, {source: event.sourceLabel})}</p>
      {event.registrationState !== "closed" && event.sourceHref ? <ButtonLink href={event.sourceHref}
        target="_blank" rel="noreferrer" onClick={() => trackSource(event, "external_event_booking")}>
        {copy.hero.officialSourceAction}</ButtonLink> : null}
    </> : guestEntry ?? <ButtonLink href={`/booking/${encodeURIComponent(event.eventId)}/`}>
      {copy.hero.guestAction}</ButtonLink>}
  </EventDetailHeroLayout>;
}

export function EventDetailFactsSection({event}: {event: EventDetailRecord}) {
  const details = [
    {label: copy.details.requirements, value: event.requirements.trim()},
    {label: copy.details.accessibility, value: event.accessibility.trim()},
  ].filter((item) => item.value);
  const itinerary = event.itinerary ?? [];
  return <EventDetailSection aria-label={copy.details.eyebrow}>
    <EventDetailBodyLayout host={<EventDetailOrganizerPanel
      activity={<ActivityMark listing={event.listing} size="lg" />}
      badge={<StatusBadge listing={event.listing} />} eyebrow={copy.hero.hostedByLabel}
      location={[event.listing.city, event.listing.country].filter(Boolean).join(", ")}
      metrics={[]} name={event.listing.name}
      primaryAction={<ButtonLink href={event.listing.path} variant="ghost">{copy.nav.organizerAction}</ButtonLink>} />}>
      {event.summary.trim() ? <><h2>{copy.invitation.about}</h2><p>{event.summary}</p></> : null}
      {itinerary.length ? <><h2>{copy.invitation.itinerary}</h2><EventDetailItinerary items={itinerary.map((item) => ({
        id: item.id, title: item.title, description: item.description,
        time: itineraryTime(event, item.offsetMinutes),
        location: item.location ? <EventDetailSourceLink target="_blank" rel="noreferrer"
          href={`https://www.google.com/maps/search/?api=1&query=${encodeURIComponent(`${item.location.latitude},${item.location.longitude}`)}`}>
          {item.location.name}{item.location.address ? ` · ${item.location.address}` : ""}
        </EventDetailSourceLink> : undefined,
      }))} /></> : null}
      {details.length ? <EventDetailFactGrid items={details} /> : null}
    </EventDetailBodyLayout>
  </EventDetailSection>;
}

export function EventDetailProvenanceSection({event}: {event: EventDetailRecord}) {
  if (event.supply !== "external" || !event.sourceHref) return null;
  return <EventDetailSection variant="provenance">
    <p>{copy.hero.externalActionBody} <EventDetailSourceLink href={event.sourceHref} target="_blank" rel="noreferrer"
      onClick={() => trackSource(event, "external_event_source")}>{event.sourceLabel}</EventDetailSourceLink></p>
  </EventDetailSection>;
}

export function EventDetailReviewsSection({event}: {event: EventDetailRecord}) {
  if (!organizerPolicyForListing(event.listing).canReadPublicReviews) return null;
  const reviews = buildListingReviewSummary(event.listing, event.eventReviews).verifiedReviews;
  if (!reviews.length) return null;
  return <EventDetailSection id="reviews" aria-label={copy.reviews.eyebrow} variant="reviews">
    <ReviewSignalLane body={copy.reviews.laneBody} emptyBody={copy.reviews.emptyBody}
      emptyTitle={copy.reviews.emptyTitle} reviews={reviews} title={copy.reviews.laneTitle} />
  </EventDetailSection>;
}

function trackSource(event: EventDetailRecord, placement: string) {
  trackOrganizerAnalytics(event.listing, "outboundClick", placement, event.eventId);
  trackOrganizerProviderOutboundClick(event.listing.id, event.eventId);
}

function itineraryTime(event: EventDetailRecord, offsetMinutes: number): string {
  // Never imply a browser-local time when the organizer has not supplied a zone.
  if (!event.timezone || !Number.isFinite(Date.parse(event.startTime))) return copy.invitation.offset(offsetMinutes);
  try {
    return new Intl.DateTimeFormat("en-IN", {timeZone: event.timezone, hour: "numeric", minute: "2-digit"})
      .format(new Date(Date.parse(event.startTime) + offsetMinutes * 60_000));
  } catch { return copy.invitation.offset(offsetMinutes); }
}
