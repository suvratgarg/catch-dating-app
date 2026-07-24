import {hostListings} from "../organizers/data";
import {organizerPolicyForListing} from "../organizers/organizerPolicy";
import type {
  HostListing,
  HostListingCatchEvent,
  HostListingExternalEvent,
  HostListingReview,
} from "../organizers/types";

export type EventSupplyKind = "catchNative" | "external";
export type EventRegistrationState =
  | "catchApp"
  | "closed"
  | "external"
  | "full";

export interface EventDetailRecord {
  accessibility: string;
  activityKind: string;
  capacityLimit: number | null;
  date: string;
  endTime: string | null;
  eventId: string;
  eventReviews: HostListingReview[];
  isUpcoming: boolean;
  listing: HostListing;
  location: string;
  locationDetails: string;
  path: string;
  priceLabel: string;
  registrationState: EventRegistrationState;
  remainingCapacity: number | null;
  requirements: string;
  sourceHref: string | null;
  sourceLabel: string;
  startTime: string;
  summary: string;
  supply: EventSupplyKind;
  timezone: string;
  title: string;
}

interface EventRecordCandidate extends EventDetailRecord {
  eventId: string;
}

export const publicEventDetailRecords = buildPublicEventDetailRecords(hostListings);

export function buildPublicEventDetailRecords(
  listings: readonly HostListing[],
  now: number = Date.now()
): EventDetailRecord[] {
  const candidates = listings
    .filter((listing) => organizerPolicyForListing(listing).isPubliclyReadable)
    .flatMap((listing) => [
      ...(listing.catchEvents ?? []).map((event) =>
        catchEventRecord(listing, event, now)
      ),
      ...(listing.externalEvents ?? []).map((event) =>
        externalEventRecord(listing, event, now)
      ),
    ]);
  const eventIdCounts = new Map<string, number>();
  for (const candidate of candidates) {
    eventIdCounts.set(candidate.eventId, (eventIdCounts.get(candidate.eventId) ?? 0) + 1);
  }
  return candidates.filter((candidate) => eventIdCounts.get(candidate.eventId) === 1);
}

export function eventDetailPath(eventId: string) {
  return `/events/${encodeURIComponent(eventId)}/`;
}

export function getEventDetailForPath(
  pathname: string,
  records: readonly EventDetailRecord[] = publicEventDetailRecords
): EventDetailRecord | null {
  const match = /^\/events\/([^/]+)\/?$/u.exec(pathname);
  if (!match) return null;
  let eventId: string;
  try {
    eventId = decodeURIComponent(match[1]);
  } catch {
    return null;
  }
  return records.find((record) => record.eventId === eventId) ?? null;
}

export function isEventDetailPath(pathname: string) {
  return pathname === "/events" || pathname.startsWith("/events/");
}

function catchEventRecord(
  listing: HostListing,
  event: HostListingCatchEvent,
  now: number
): EventRecordCandidate {
  const end = Date.parse(event.endTime);
  const isUpcoming = event.timeline === "upcoming" && (
    !Number.isFinite(end) || end >= now
  );
  const remainingCapacity = Math.max(0, event.capacityLimit - event.bookedCount);
  const registrationState: EventRegistrationState = !isUpcoming
    ? "closed"
    : remainingCapacity === 0
      ? "full"
      : "catchApp";
  return {
    accessibility: event.accessibility ?? "",
    activityKind: event.activityKind,
    capacityLimit: event.capacityLimit,
    date: event.date,
    endTime: event.endTime,
    eventId: event.id,
    eventReviews: eventReviewsForListing(listing, event.id),
    isUpcoming,
    listing,
    location: event.location,
    locationDetails: event.locationDetails ?? "",
    path: eventDetailPath(event.id),
    priceLabel: event.priceLabel,
    registrationState,
    remainingCapacity,
    requirements: event.requirements ?? "",
    sourceHref: null,
    sourceLabel: "Catch",
    startTime: event.startTime,
    summary: event.summary || listing.description,
    supply: "catchNative",
    timezone: event.timezone ?? "",
    title: event.title,
  };
}

function externalEventRecord(
  listing: HostListing,
  event: HostListingExternalEvent,
  now: number
): EventRecordCandidate {
  const endOrStart = Date.parse(event.endTime ?? event.startTime);
  const isUpcoming = !Number.isFinite(endOrStart) || endOrStart >= now;
  return {
    accessibility: event.accessibility ?? "",
    activityKind: event.activityKind,
    capacityLimit: null,
    date: event.date,
    endTime: event.endTime,
    eventId: event.id,
    eventReviews: eventReviewsForListing(listing, event.id),
    isUpcoming,
    listing,
    location: event.location,
    locationDetails: event.locationDetails ?? "",
    path: eventDetailPath(event.id),
    priceLabel: event.priceLabel,
    registrationState: isUpcoming ? "external" : "closed",
    remainingCapacity: null,
    requirements: event.requirements ?? "",
    sourceHref: event.sourceHref,
    sourceLabel: event.sourceLabel,
    startTime: event.startTime,
    summary: event.summary || listing.description,
    supply: "external",
    timezone: event.timezone ?? "",
    title: event.title,
  };
}

function eventReviewsForListing(
  listing: HostListing,
  eventId: string
): HostListingReview[] {
  if (!organizerPolicyForListing(listing).canReadPublicReviews) return [];
  return listing.reviews.filter((review) => review.eventId === eventId);
}
