import {cleanup, render, screen} from "@testing-library/react";
import {afterEach, describe, expect, it} from "vitest";
import {hostListings} from "../../organizers/data";
import type {HostListing} from "../../organizers/types";
import type {EventDetailRecord} from "../eventDetailModel";
import {
  EventDetailFactsSection,
  EventDetailHeroSection,
  EventDetailProvenanceSection,
  EventDetailReviewsSection,
} from "./EventDetailSections";

afterEach(cleanup);

describe("Event Detail sections", () => {
  it("keeps external events read-only and sends registration to the source", () => {
    const event = externalEvent();
    render(
      <>
        <EventDetailHeroSection appDownloadCtas={appDownloadCtas} event={event} />
        <EventDetailFactsSection event={event} />
        <EventDetailProvenanceSection event={event} />
      </>
    );

    expect(screen.getByRole("link", {name: "Open official source"}).getAttribute("href"))
      .toBe("https://luma.com/example");
    expect(screen.getByText("Source-backed event · Luma")).toBeTruthy();
    expect(screen.getByText("Registration stays with Luma")).toBeTruthy();
    expect(screen.getByText("Asia/Kolkata")).toBeTruthy();
    expect(screen.queryByRole("link", {name: /book|checkout|sign in/iu})).toBeNull();
    expect(screen.queryByRole("button", {name: /book|checkout|sign in/iu})).toBeNull();
  });

  it("hands Catch booking to the app and renders only event-scoped reviews", () => {
    const event = catchEvent();
    render(
      <>
        <EventDetailHeroSection appDownloadCtas={appDownloadCtas} event={event} />
        <EventDetailReviewsSection event={event} />
      </>
    );

    expect(screen.getByText("Booking stays in the Catch app")).toBeTruthy();
    expect(screen.getAllByText("Scoped attendee")).toHaveLength(2);
    expect(screen.queryByText("Organizer-only reviewer")).toBeNull();
    expect(screen.queryByRole("link", {name: /book|checkout|sign in/iu})).toBeNull();
  });

  it("shows claim and unavailable-review states only when their capabilities allow it", () => {
    const event = claimableExternalEvent();
    render(
      <EventDetailHeroSection appDownloadCtas={appDownloadCtas} event={event} />
    );

    expect(screen.getByRole("link", {name: "Claim this organizer listing"})
      .getAttribute("href")).toBe(`/claim/?listing=${event.listing.id}`);
    expect(screen.getByText("Event reviews are not available yet")).toBeTruthy();
    expect(screen.queryByText("No event-specific reviews yet")).toBeNull();
  });
});

const appDownloadCtas = {
  items: [{
    href: "https://apps.apple.com/app/catch",
    kicker: "Download on the",
    label: "App Store",
    platform: "ios" as const,
  }],
  placement: "event-detail-test",
};

function readableListing(): HostListing {
  const listing = hostListings[0];
  return {
    ...listing,
    authority: {
      ...listing.authority,
      publishStatus: "published",
    },
    capabilities: {
      ...listing.capabilities,
      publicReviews: {
        targetState: "enabled",
        readState: "enabled",
        writeState: "disabled",
        reason: "Read-only test fixture.",
      },
    },
    reviews: [
      {
        id: "scoped-review",
        eventId: "catch-event",
        reviewerName: "Scoped attendee",
        rating: 5,
        comment: "A well-run event.",
        createdAt: "2026-07-20T10:00:00.000Z",
        verificationStatus: "verified",
        source: "catchEvent",
        isAnonymous: false,
        ownerResponse: null,
      },
      {
        id: "organizer-review",
        eventId: null,
        reviewerName: "Organizer-only reviewer",
        rating: 4,
        comment: "This belongs to the organizer.",
        createdAt: "2026-07-19T10:00:00.000Z",
        verificationStatus: "unverified",
        source: "publicListing",
        isAnonymous: false,
        ownerResponse: null,
      },
    ],
  };
}

function catchEvent(): EventDetailRecord {
  const listing = readableListing();
  return {
    accessibility: "",
    activityKind: "dinner",
    capacityLimit: 20,
    date: "Aug 1, 2026, 7:00 PM-9:00 PM",
    endTime: "2026-08-01T15:30:00.000Z",
    eventId: "catch-event",
    eventReviews: listing.reviews.filter((review) => review.eventId === "catch-event"),
    isUpcoming: true,
    listing,
    location: "Mumbai",
    locationDetails: "",
    path: "/events/catch-event/",
    priceLabel: "₹1,500",
    registrationState: "catchApp",
    remainingCapacity: 8,
    requirements: "",
    sourceHref: null,
    sourceLabel: "Catch",
    startTime: "2026-08-01T13:30:00.000Z",
    summary: "A small hosted dinner.",
    supply: "catchNative",
    timezone: "Asia/Kolkata",
    title: "Future Catch dinner",
  };
}

function externalEvent(): EventDetailRecord {
  return {
    ...catchEvent(),
    accessibility: "Step-free venue access is listed.",
    capacityLimit: null,
    eventId: "external-event",
    eventReviews: [],
    location: "Indore",
    path: "/events/external-event/",
    priceLabel: "Free RSVP",
    registrationState: "external",
    remainingCapacity: null,
    requirements: "Bring running shoes and water.",
    sourceHref: "https://luma.com/example",
    sourceLabel: "Luma",
    supply: "external",
    title: "External social run",
  };
}

function claimableExternalEvent(): EventDetailRecord {
  const event = externalEvent();
  return {
    ...event,
    listing: {
      ...event.listing,
      capabilities: {
        ...event.listing.capabilities,
        claimRequest: {
          state: "enabled",
          reason: "Claim handoff is enabled for this fixture.",
        },
        publicReviews: {
          targetState: "disabled",
          readState: "disabled",
          writeState: "disabled",
          reason: "Review target is not ready for this fixture.",
        },
      },
    },
  };
}
