import type {AppDownloadCtaGroupProps} from "../../../shared/ui/primitives";
import {
  ActionGroup,
  AppDownloadCtaGroup,
  ButtonLink,
  EventDetailActionPanel,
  EventDetailFactGrid,
  EventDetailHeroLayout,
  EventDetailMedia,
  EventDetailOrganizerPanel,
  EventDetailProvenanceFacts,
  EventDetailProvenanceLayout,
  EventDetailReviewPreview,
  EventDetailSection,
  EventDetailSourceLink,
  ReviewSignalLane,
} from "../../../shared/ui/primitives";
import {SectionHeader} from "../../../shared/site";
import {eventDetailCopy} from "../../../content/events";
import {interpolateContent} from "../../../content/interpolate";
import {
  ActivityMark,
  StatusBadge,
} from "../../organizers/OrganizerIdentity";
import {organizerPolicyForListing} from "../../organizers/organizerPolicy";
import {activityForKind} from "../../organizers/publicDiscovery";
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
  const listingPath = event.listing.path;
  const organizerPolicy = organizerPolicyForListing(event.listing);
  const activity = activityForKind(event.activityKind);
  const reviewSummary = buildListingReviewSummary(
    event.listing,
    event.eventReviews
  );
  const previewReview = reviewSummary.verifiedReviews[0];
  const organizerMetrics = [
    event.listing.metrics?.rating
      ? {
        label: eventDetailCopy.hero.organizerMetrics.rating,
        value: event.listing.metrics.rating.toFixed(1),
      }
      : null,
    event.listing.metrics?.reviewCount
      ? {
        label: eventDetailCopy.hero.organizerMetrics.reviews,
        value: String(event.listing.metrics.reviewCount),
      }
      : null,
    event.listing.metrics?.memberCount
      ? {
        label: eventDetailCopy.hero.organizerMetrics.members,
        value: String(event.listing.metrics.memberCount),
      }
      : null,
  ].filter((item): item is Exclude<typeof item, null> => item !== null);
  return (
    <EventDetailHeroLayout
      activityToken={activity.token}
      eyebrow={isExternal
        ? interpolateContent(eventDetailCopy.hero.externalEyebrow, {
          source: event.sourceLabel,
        })
        : eventDetailCopy.hero.catchEyebrow}
      facts={[
        {label: eventDetailCopy.hero.facts.when, value: event.date},
        {label: eventDetailCopy.hero.facts.where, value: event.location},
        {label: eventDetailCopy.hero.facts.format, value: activity.label},
      ]}
      media={<EventDetailMedia
        alt={eventDetailCopy.hero.media.alt}
        src={eventDetailCopy.hero.media.src}
        srcSet={eventDetailCopy.hero.media.mobileSrcSet}
      />}
      metaLine={`${activity.label} · ${event.location}`}
      reviewPreview={<EventDetailReviewPreview
        body={previewReview
          ? previewReview.comment
          : organizerPolicy.canReadPublicReviews
            ? eventDetailCopy.reviews.emptyBody
            : eventDetailCopy.reviews.unavailableBody}
        eyebrow={eventDetailCopy.reviews.eyebrow}
        meta={previewReview
          ? `${previewReview.rating.toFixed(1)} / 5 · ${previewReview.reviewerName}`
          : undefined}
        title={previewReview
          ? previewReview.reviewerName
          : organizerPolicy.canReadPublicReviews
            ? eventDetailCopy.reviews.emptyTitle
            : eventDetailCopy.reviews.unavailableTitle}
      />}
      planLabel={eventDetailCopy.hero.planLabel}
      summary={event.summary}
      supplyLabel={isExternal
        ? interpolateContent(eventDetailCopy.hero.externalSupply, {
          source: event.sourceLabel,
        })
        : eventDetailCopy.hero.catchSupply}
      title={event.title}
    >
      <EventDetailOrganizerPanel
        activity={<ActivityMark listing={event.listing} size="lg" />}
        badge={<StatusBadge listing={event.listing} />}
        claimAction={organizerPolicy.canRequestClaim ? (
          <ButtonLink
            href={claimHrefForListing(event.listing)}
            variant="ghost"
          >
            {eventDetailCopy.hero.claimAction}
          </ButtonLink>
        ) : undefined}
        eyebrow={eventDetailCopy.hero.hostedByLabel}
        location={[event.listing.city, event.listing.country]
          .filter(Boolean)
          .join(", ")}
        metrics={organizerMetrics}
        name={event.listing.name}
        primaryAction={(
          <ButtonLink href={listingPath} variant="ghost">
            {eventDetailCopy.nav.organizerAction}
          </ButtonLink>
        )}
      />
      <EventDetailActionPanel
        date={event.date}
        description={isExternal
          ? eventDetailCopy.hero.externalActionBody
          : eventDetailCopy.hero.catchActionBody}
        title={isExternal
          ? interpolateContent(eventDetailCopy.hero.externalActionHeading, {
            source: event.sourceLabel,
          })
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
          </ActionGroup>
        ) : (
          <AppDownloadCtaGroup
            {...appDownloadCtas}
            reveal={false}
            variant="compact"
          />
        )}
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
  const reviewsUnavailable = !organizerPolicyForListing(event.listing)
    .canReadPublicReviews;
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
        emptyBody={reviewsUnavailable
          ? eventDetailCopy.reviews.unavailableBody
          : eventDetailCopy.reviews.emptyBody}
        emptyTitle={reviewsUnavailable
          ? eventDetailCopy.reviews.unavailableTitle
          : eventDetailCopy.reviews.emptyTitle}
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
