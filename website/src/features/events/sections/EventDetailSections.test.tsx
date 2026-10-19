import {cleanup, fireEvent, render, screen, within} from "@testing-library/react";
import {afterEach, describe, expect, it, vi} from "vitest";
import {EventDetailPage} from "../EventDetailPage";
import {hostListings} from "../../organizers/data";
import type {HostListing} from "../../organizers/types";
import type {EventDetailRecord} from "../eventDetailModel";
import {
  EventDetailFactsSection,
  EventDetailHeroSection,
  EventDetailProvenanceSection,
  EventDetailReviewsSection,
} from "./EventDetailSections";

const observeOrganizerPageView = vi.hoisted(() => vi.fn(() => vi.fn()));
const trackOrganizerAnalytics = vi.hoisted(() => vi.fn());
const observeOrganizerProviders = vi.hoisted(() => vi.fn(() => vi.fn()));
const trackOrganizerProviderOutboundClick = vi.hoisted(() => vi.fn());
vi.mock("../../organizers/observeOrganizerProviders", () => ({observeOrganizerProviders, trackOrganizerProviderOutboundClick}));
vi.mock("../../organizers/analytics", () => ({trackOrganizerAnalytics, observeOrganizerPageView}));
afterEach(() => {cleanup(); vi.clearAllMocks();});

describe("Event Detail sections", () => {
  it("uses the shared consumer navigation without moving the booking destination", () => {
    render(<EventDetailPage event={externalEvent()} />);
    const nav = screen.getByRole("navigation", {name: "Primary"});
    expect(within(nav).getAllByRole("link").map(link => link.getAttribute("href")))
      .toEqual(["/explore/", "/organizers/", "/host/"]);
    expect(screen.getByRole("link", {name: "Open official source"}).getAttribute("href")).toBe("https://luma.com/example");
  });

  it("links the experience badge to only the declared interaction tools", () => {
    const event = {...catchEvent(), catchExperienceActivities: ["rotations" as const]};
    render(<><EventDetailHeroSection event={event} /><EventDetailFactsSection event={event} /></>);
    expect(screen.getByRole("link", {name: "Catch Experience"}).getAttribute("href")).toBe("#catch-experience");
    const panel = screen.getByRole("region", {name: "A little help joining in."});
    expect(within(panel).getByRole("heading", {name: "Partner or group rotations"})).toBeTruthy();
    expect(within(panel).getByText("Activities are optional. Join in at your own pace.")).toBeTruthy();
    expect(screen.queryByText("Guided introductions")).toBeNull();
    expect(screen.getByRole("link", {name: "Check event access"}).getAttribute("href")).toBe(`/booking/${event.eventId}/`);
  });

  it.each([undefined, [], ["checkIn"], ["rotations", "rotations"]])("does not badge booking-only or invalid declarations: %j", (activities) => {
    const event = {...catchEvent(), catchExperienceActivities: activities} as EventDetailRecord;
    render(<><EventDetailHeroSection event={event} /><EventDetailFactsSection event={event} /></>);
    expect(screen.queryByText("Catch Experience")).toBeNull();
    expect(screen.queryByRole("region", {name: "A little help joining in."})).toBeNull();
  });

  it("observes a directly rendered external detail page and cleans up its consent subscription", () => {
    const event = externalEvent();
    const {unmount} = render(<EventDetailPage event={event} />);
    expect(observeOrganizerPageView).toHaveBeenCalledWith(event.listing, "eventView", "event_detail", event.eventId);
    expect(observeOrganizerProviders).toHaveBeenCalledWith(event.listing, event.eventId);
    const stopProvider = observeOrganizerProviders.mock.results[0].value;
    const stop = observeOrganizerPageView.mock.results[0].value;
    unmount();
    expect(stop).toHaveBeenCalledOnce();
    expect(stopProvider).toHaveBeenCalledOnce();
  });
  it("keeps external events read-only and sends registration to the source", () => {
    const event = externalEvent();
    render(
      <>
        <EventDetailHeroSection event={event} />
        <EventDetailFactsSection event={event} />
        <EventDetailProvenanceSection event={event} />
      </>
    );

    expect(screen.getByRole("link", {name: "Open official source"}).getAttribute("href"))
      .toBe("https://luma.com/example");
    fireEvent.click(screen.getByRole("link", {name: "Open official source"}));
    expect(trackOrganizerProviderOutboundClick).toHaveBeenCalledWith(event.listing.id, event.eventId);
    expect(trackOrganizerAnalytics).toHaveBeenLastCalledWith(event.listing, "outboundClick", "external_event_booking", event.eventId);
    fireEvent.click(screen.getByRole("link", {name: "Luma"}));
    expect(trackOrganizerAnalytics).toHaveBeenLastCalledWith(event.listing, "outboundClick", "external_event_source", event.eventId);
    expect(trackOrganizerAnalytics.mock.calls.some((call) => call[1] === "eventView")).toBe(false);
    expect(screen.getByText("Registration stays with Luma")).toBeTruthy();
    expect(screen.getByText("Asia/Kolkata")).toBeTruthy();
    expect(screen.queryByRole("link", {name: /book|checkout|sign in/iu})).toBeNull();
    expect(screen.queryByRole("button", {name: /book|checkout|sign in/iu})).toBeNull();
  });

  it("hands Catch booking to the web guest journey and renders only event-scoped reviews", () => {
    const event = catchEvent();
    render(
      <>
        <EventDetailHeroSection event={event} />
        <EventDetailReviewsSection event={event} />
      </>
    );

    expect(screen.getByRole("link", {name: "Check event access"}).getAttribute("href")).toBe(`/booking/${event.eventId}/`);
    expect(screen.getAllByText("Scoped attendee")).toHaveLength(1);
    expect(screen.queryByText("Organizer-only reviewer")).toBeNull();
    expect(screen.queryByRole("link", {name: /book|checkout|sign in/iu})).toBeNull();
  });

  it("preserves the guest journey after registration closes", () => {
    render(<EventDetailHeroSection event={{...catchEvent(), registrationState: "closed"}}
      guestEntry={<p>Account-owned booking recovery</p>} />);
    expect(screen.getByText("Account-owned booking recovery")).toBeTruthy();
    expect(screen.queryByText("Registration is closed for this event.")).toBeNull();
  });

  it("omits absent optional content and unrelated reviews", () => {
    const event = {...claimableExternalEvent(), summary: "", accessibility: "", requirements: ""};
    render(<><EventDetailHeroSection event={event} /><EventDetailFactsSection event={event} />
      <EventDetailReviewsSection event={event} /></>);
    for (const text of ["About this event", "The plan", "Requirements", "Accessibility", "No event-specific reviews yet", "Event reviews are not available yet"]) {
      expect(screen.queryByText(text)).toBeNull();
    }
    expect(screen.queryByRole("img")).toBeNull();
    expect(screen.queryByRole("link", {name: "Claim this organizer listing"})).toBeNull();
  });

  it("renders the real cover and structured itinerary, including zero coordinates", () => {
    const event = {...catchEvent(), photoUrl: "https://example.com/event.jpg", itinerary: [{
      id: "arrival", title: "Meet at the café", kind: "gather" as const, offsetMinutes: 30,
      description: null, location: {name: "Café", latitude: 0, longitude: 0},
    }]};
    render(<><EventDetailHeroSection event={event} /><EventDetailFactsSection event={event} /></>);
    expect(screen.getByRole("img").getAttribute("src")).toBe(event.photoUrl);
    expect(screen.getByText("7:30 pm")).toBeTruthy();
    expect(screen.getByRole("link", {name: "Café"}).getAttribute("href")).toContain("query=0%2C0");
    fireEvent.error(screen.getByRole("img"));
    expect(screen.queryByRole("img")).toBeNull();
    expect(screen.getByRole("heading", {level: 1}).textContent).toBe(event.title);
  });

});

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
    registrationMode: "free",
    paidBookingAvailable: false,
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
    registrationMode: "free",
    paidBookingAvailable: false,
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
