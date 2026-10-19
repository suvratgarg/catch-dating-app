import {
  buildPublicEventDetailRecords,
  type EventDetailRecord,
} from "../../features/events/eventDetailModel";
import type {HostListing} from "../../features/organizers/types";
import {hostListings} from "./hostListings";

const appCreatedListing = withReadableReviews(
  requireListing("club-sales-sunday-table")
);
const afterflyListing = withClaimCapability({
  ...requireListing("afterfly"),
  externalEvents: [{
    accessibility: "Step-free venue access is listed; contact the source for route conditions.",
    activityKind: "socialRun",
    availability: "read_only_external",
    date: "Sat, 8 Aug 2026, 6:30 PM-9:00 PM",
    dedupeKey: "afterfly-takeoff-run-rave-2026-08-08",
    endTime: "2026-08-08T15:30:00.000Z",
    externalLinkCount: 1,
    id: "external-afterfly-takeoff-run-rave",
    location: "Indore, Madhya Pradesh",
    locationDetails: "The final start point is confirmed on the official event page.",
    priceLabel: "Free RSVP",
    requirements: "Bring running shoes and water; confirm the pace group on the source page.",
    sourceHref: "https://luma.com/afterfly-takeoff-run-rave",
    sourceLabel: "Luma",
    startTime: "2026-08-08T13:00:00.000Z",
    summary:
      "A sunset social run followed by music. This is source-attributed external supply, so Catch does not handle registration.",
    timezone: "Asia/Kolkata",
    title: "Afterfly Takeoff Run + Rave",
  }],
});

const records = buildPublicEventDetailRecords(
  [appCreatedListing, afterflyListing],
  Date.parse("2026-07-24T00:00:00.000Z")
);

export const catchEventDetailFixture: EventDetailRecord = {
  ...requireEvent("event-host-post-report", records),
  title: "A table for strangers.", activityKind: "dinner",
  listing: {...appCreatedListing, city: "Mumbai", country: "India"},
  photoUrl: "/assets/events/dinner-invitation-preview.png",
  date: "Saturday, October 24, 2026 · 7:00–10:00 PM", timezone: "Asia/Kolkata",
  startTime: "2026-10-24T13:30:00.000Z", endTime: "2026-10-24T16:30:00.000Z",
  summary: "Good food. New faces. A few unexpected connections. Join us for a relaxed evening around one table, with a host to get the conversation started.",
  location: "Bandra, Mumbai", locationDetails: "Exact address shared after booking",
  priceLabel: "₹1,500", eventReviews: [],
  itinerary: [
    {id: "arrive", kind: "gather", offsetMinutes: 0, title: "Settle in", description: "Meet your host and find your place at the table."},
    {id: "dinner", kind: "activity", offsetMinutes: 30, title: "Dinner & conversation"},
    {id: "finish", kind: "finish", offsetMinutes: 180, title: "One last goodbye"},
  ],
};
export const externalEventDetailFixture = requireEvent(
  "external-afterfly-takeoff-run-rave",
  records
);

function withReadableReviews(listing: HostListing): HostListing {
  return {
    ...listing,
    capabilities: {
      ...listing.capabilities,
      publicReviews: {
        targetState: "enabled",
        readState: "enabled",
        writeState: "disabled",
        reason: "Story fixture exposes read-only event review records.",
      },
    },
  };
}

function withClaimCapability(listing: HostListing): HostListing {
  return {
    ...listing,
    capabilities: {
      ...listing.capabilities,
      claimRequest: {
        state: "enabled",
        reason: "Story fixture exposes the supported claim handoff.",
      },
    },
  };
}

function requireListing(id: string): HostListing {
  const listing = hostListings.find((candidate) => candidate.id === id);
  if (!listing) throw new Error(`Missing organizer story fixture: ${id}`);
  return listing;
}

function requireEvent(
  id: string,
  candidates: readonly EventDetailRecord[]
): EventDetailRecord {
  const event = candidates.find((candidate) => candidate.eventId === id);
  if (!event) throw new Error(`Missing event story fixture: ${id}`);
  return event;
}

// Explicit component-review fixtures, never imported by the public catalogue.
// The upcoming state has no event reviews; a separate completed event exercises reviews.
export const completeEventDetailFixture: EventDetailRecord = {
  ...catchEventDetailFixture,
  requirements: "18+ · Come on your own or with a friend. Let the host know about dietary requirements before booking. A three-course vegetarian dinner and a welcome drink are included; additional drinks are separate.",
  accessibility: "Illustrative venue information: step-free entrance, lift access and an accessible toilet. Seating is provided throughout. Contact the organiser before booking if you need a quieter seat or other support.",
  summary: "An evening for people who enjoy good food and meeting someone new. Arrive on your own or bring a friend: your host will welcome you, help everyone settle in and start the conversation. There is no dating requirement, networking pitch or pressure to take part. Dinner, a welcome drink and a hosted evening are included.",
  catchExperienceActivities: ["introductions", "sharedActivities", "rotations"],
  locationDetails: "Bandra West · Exact venue address is shared with confirmed guests. Please arrive 10 minutes before the start.",
  capacityLimit: 24, remainingCapacity: 6,
  registrationMode: "paid", registrationState: "webOtp", paidBookingAvailable: true,
  listing: {...catchEventDetailFixture.listing,
    metrics: {...catchEventDetailFixture.listing.metrics, rating: 4.8, reviewCount: 29, memberCount: 76}},
  itinerary: [
    {id: "arrive", kind: "gather", offsetMinutes: 0, durationMinutes: 20, title: "Arrive & say hello", description: "Your host welcomes you. An optional introduction prompt gives you a reason to meet someone new."},
    {id: "first-course", kind: "activity", offsetMinutes: 20, durationMinutes: 60, title: "First course, first conversations", description: "Settle into a small group over dinner. Light conversation prompts are there if you want them."},
    {id: "new-seat", kind: "transition", offsetMinutes: 80, durationMinutes: 15, title: "A new seat, a few new faces", description: "An optional seat change introduces you to another part of the table. Your host can adapt the plan."},
    {id: "dessert", kind: "activity", offsetMinutes: 95, durationMinutes: 65, title: "Dessert & unhurried conversation", description: "Keep talking with the people you have met, or join a new conversation."},
    {id: "close", kind: "finish", offsetMinutes: 180, title: "Goodnight, for now", description: "An optional feedback prompt helps the host improve the next evening."},
  ],
  eventReviews: [],
};
export const completePastEventDetailFixture: EventDetailRecord = {
  ...completeEventDetailFixture,
  title: "A table for strangers. · Past edition",
  date: "Saturday, October 10, 2026 · 7:00–10:00 PM",
  startTime: "2026-10-10T13:30:00.000Z", endTime: "2026-10-10T16:30:00.000Z",
  isUpcoming: false, registrationState: "closed", registrationMode: "closed",
  eventReviews: [
    {id: "preview-review-1", eventId: completeEventDetailFixture.eventId, reviewerName: "Demo guest A", rating: 5,
      comment: "Illustrative review: coming alone felt easy. The host introduced us and the seat change helped me speak to more people.",
      createdAt: "2026-10-11T10:00:00.000Z", verificationStatus: "verified", source: "catchEvent", isAnonymous: false,
      ownerResponse: {hostName: "Demo host", hostAvatarUrl: null, message: "Illustrative host reply: thank you for joining us. We are glad the introductions helped.", updatedAt: "2026-10-12T10:00:00.000Z"}},
    {id: "preview-review-2", eventId: completeEventDetailFixture.eventId, reviewerName: "Demo guest B", rating: 4,
      comment: "Illustrative review: good food and a friendly group. I would have liked a little more time before the seat change.",
      createdAt: "2026-10-12T10:00:00.000Z", verificationStatus: "verified", source: "catchEvent", isAnonymous: false, ownerResponse: null},
  ],
};
