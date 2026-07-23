import type {AppDownloadCtaGroupProps} from "../../../shared/ui/primitives";
import {
  ActionGroup,
  AppDownloadCtaGroup,
  ButtonLink,
  EventDetailActionPanel,
  EventDetailFactGrid,
  EventDetailHeroLayout,
  EventDetailProvenanceFacts,
  EventDetailProvenanceLayout,
  EventDetailSection,
  EventDetailSourceLink,
  ReviewSignalLane,
} from "../../../shared/ui/primitives";
import {SectionHeader} from "../../../shared/site";
import {eventDetailCopy} from "../../../content/events";
import {interpolateContent} from "../../../content/interpolate";
import {StatusBadge} from "../../organizers/OrganizerIdentity";
import {organizerPolicyForListing} from "../../organizers/organizerPolicy";
import {claimHrefForListing} from "../../organizers/routing";
import {buildListingReviewSummary} from "../../reviews/reviewModel";
import type {EventDetailRecord} from "../eventDetailModel";

export function EventDetailHeroSection({
  appDownloadCtas,
  event,
}: {
  appDownloadCtas: AppDownloadCtaGroupProps;
  event: EventDetailRecord;
}) {
  const isExternal = event.supply === "external";
  const organizerPolicy = organizerPolicyForListing(event.listing);
  return (
    <EventDetailHeroLayout
      badge={<StatusBadge listing={event.listing} />}
      eyebrow={isExternal
        ? eventDetailCopy.hero.externalEyebrow
        : eventDetailCopy.hero.catchEyebrow}
      organizerLine={interpolateContent(eventDetailCopy.hero.byOrganizer, {
        organizer: event.listing.name,
      })}
      summary={event.summary}
      supplyLabel={isExternal
        ? interpolateContent(eventDetailCopy.hero.externalSupply, {
          source: event.sourceLabel,
        })
        : eventDetailCopy.hero.catchSupply}
      title={event.title}
    >
      <EventDetailActionPanel
        date={event.date}
        description={isExternal
          ? eventDetailCopy.hero.externalActionBody
          : eventDetailCopy.hero.catchActionBody}
        title={isExternal
          ? eventDetailCopy.hero.externalActionHeading
          : eventDetailCopy.hero.catchActionHeading}
      >
        {isExternal && event.sourceHref ? (
          <ActionGroup variant="flow">
            <ButtonLink
              href={event.sourceHref}
              rel="noreferrer"
              target="_blank"
              variant="primary"
            >
              {eventDetailCopy.hero.officialSourceAction}
            </ButtonLink>
            <ButtonLink href={event.listing.path} variant="ghost">
              {eventDetailCopy.hero.organizerAction}
            </ButtonLink>
          </ActionGroup>
        ) : (
          <>
            <AppDownloadCtaGroup
              {...appDownloadCtas}
              reveal={false}
              variant="compact"
            />
            <ActionGroup variant="flow">
              <ButtonLink href={event.listing.path} variant="ghost">
                {eventDetailCopy.hero.organizerAction}
              </ButtonLink>
            </ActionGroup>
          </>
        )}
        {organizerPolicy.canRequestClaim ? (
          <ButtonLink
            href={claimHrefForListing(event.listing)}
            variant="ghost"
          >
            {eventDetailCopy.hero.claimAction}
          </ButtonLink>
        ) : null}
      </EventDetailActionPanel>
    </EventDetailHeroLayout>
  );
}

export function EventDetailFactsSection({event}: {event: EventDetailRecord}) {
  const isExternal = event.supply === "external";
  const details = [
    {label: eventDetailCopy.details.schedule, value: event.date},
    {
      label: eventDetailCopy.details.timezone,
      value: event.timezone || eventDetailCopy.details.timezoneMissing,
    },
    {label: eventDetailCopy.details.location, value: event.location},
    {
      label: eventDetailCopy.details.locationDisclosure,
      value: event.locationDetails || (
        isExternal
          ? eventDetailCopy.details.locationExternalFallback
          : eventDetailCopy.details.locationCatchFallback
      ),
    },
    {label: eventDetailCopy.details.price, value: event.priceLabel},
    {
      label: eventDetailCopy.details.registration,
      value: registrationLabel(event),
    },
    {
      label: eventDetailCopy.details.requirements,
      value: event.requirements || eventDetailCopy.details.requirementsMissing,
    },
    {
      label: eventDetailCopy.details.accessibility,
      value: event.accessibility || eventDetailCopy.details.accessibilityMissing,
    },
    {
      label: eventDetailCopy.details.freshness,
      value: interpolateContent(eventDetailCopy.details.freshnessTemplate, {
        date: event.listing.lastVerifiedAt,
      }),
    },
  ];
  return (
    <EventDetailSection aria-labelledby="event-detail-facts-title">
      <SectionHeader
        body={eventDetailCopy.details.body}
        eyebrow={eventDetailCopy.details.eyebrow}
        id="event-detail-facts-title"
        title={eventDetailCopy.details.title}
        wide
      />
      <EventDetailFactGrid items={details} />
    </EventDetailSection>
  );
}

export function EventDetailProvenanceSection({
  event,
}: {
  event: EventDetailRecord;
}) {
  const isExternal = event.supply === "external";
  const sourceValue = isExternal && event.sourceHref ? (
    <EventDetailSourceLink
      href={event.sourceHref}
      rel="noreferrer"
      target="_blank"
    >
      {event.sourceLabel}
    </EventDetailSourceLink>
  ) : event.sourceLabel;
  return (
    <EventDetailSection
      aria-labelledby="event-detail-provenance-title"
      variant="provenance"
    >
      <EventDetailProvenanceLayout
        intro={<SectionHeader
          body={isExternal
            ? eventDetailCopy.provenance.externalBody
            : eventDetailCopy.provenance.catchBody}
          eyebrow={eventDetailCopy.provenance.eyebrow}
          id="event-detail-provenance-title"
          title={eventDetailCopy.provenance.title}
          wide
        />}
      >
        <EventDetailProvenanceFacts items={[
          {
            label: eventDetailCopy.provenance.sourceLabel,
            value: sourceValue,
          },
          {
            label: eventDetailCopy.provenance.organizerLabel,
            value: <StatusBadge listing={event.listing} compact />,
          },
          {
            label: eventDetailCopy.provenance.reviewedLabel,
            value: event.listing.lastVerifiedAt,
          },
        ]} />
      </EventDetailProvenanceLayout>
    </EventDetailSection>
  );
}

export function EventDetailReviewsSection({
  event,
}: {
  event: EventDetailRecord;
}) {
  const reviewSummary = buildListingReviewSummary(
    event.listing,
    event.eventReviews
  );
  return (
    <EventDetailSection
      id="reviews"
      aria-labelledby="event-detail-reviews-title"
      variant="reviews"
    >
      <SectionHeader
        body={eventDetailCopy.reviews.body}
        eyebrow={eventDetailCopy.reviews.eyebrow}
        id="event-detail-reviews-title"
        title={eventDetailCopy.reviews.title}
        wide
      />
      <ReviewSignalLane
        body={eventDetailCopy.reviews.laneBody}
        emptyBody={eventDetailCopy.reviews.emptyBody}
        emptyTitle={eventDetailCopy.reviews.emptyTitle}
        reviews={reviewSummary.verifiedReviews}
        title={eventDetailCopy.reviews.laneTitle}
      />
    </EventDetailSection>
  );
}

function registrationLabel(event: EventDetailRecord) {
  switch (event.registrationState) {
    case "catchApp":
      return interpolateContent(eventDetailCopy.details.catchRegistrationOpen, {
        count: String(event.remainingCapacity ?? 0),
      });
    case "full":
      return eventDetailCopy.details.catchRegistrationFull;
    case "external":
      return eventDetailCopy.details.externalRegistration;
    case "closed":
      return eventDetailCopy.details.registrationClosed;
  }
}
