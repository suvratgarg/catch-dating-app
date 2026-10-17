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
