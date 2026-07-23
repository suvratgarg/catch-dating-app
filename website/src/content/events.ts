export const eventDetailCopy = {
  nav: {
    organizers: "Organizers",
    host: "Host an event",
    organizerAction: "View organizer",
  },
  hero: {
    catchEyebrow: "Catch event · app booking",
    externalEyebrow: "Source-backed event · {source}",
    catchSupply: "Created and managed in Catch",
    externalSupply: "Published by {source}",
    byOrganizer: "Hosted by {organizer}",
    catchActionHeading: "Booking stays in the Catch app",
    catchActionBody:
      "This website is read-only. Open Catch on iOS or Android to check live availability, join a waitlist, or book.",
    externalActionHeading: "Registration stays with {source}",
    externalActionBody:
      "Catch does not sell, reserve, or waitlist places for this event. Confirm the latest details before you go.",
    officialSourceAction: "Open official source",
    viewDetailsAction: "View event details",
    organizerAction: "View organizer profile",
    claimAction: "Claim this organizer listing",
    hostedByLabel: "Hosted by",
    planLabel: "The plan",
    facts: {
      when: "When",
      where: "Where",
      format: "Format",
    },
    organizerMetrics: {
      rating: "Rating",
      reviews: "Organizer reviews",
      members: "Members",
    },
    media: {
      alt:
        "Catch members gathering at an evening social event; illustrative activity photography, not organizer-supplied event media.",
      src: "/assets/events/social-run-music-hero.jpg",
      mobileSrcSet: "/assets/events/social-run-music-hero-960.jpg",
    },
  },
  details: {
    eyebrow: "Event details",
    title: "Plan with the published information",
    body:
      "Event pages show the latest approved listing data. Missing details are labelled instead of inferred.",
    schedule: "Schedule",
    timezone: "Time zone",
    location: "Location",
    locationDisclosure: "Location notes",
    price: "Price",
    registration: "Registration",
    requirements: "Requirements",
    accessibility: "Accessibility",
    freshness: "Source freshness",
    timezoneMissing: "Not provided by the organizer",
    locationCatchFallback:
      "Additional meeting instructions may be shown in the Catch app after booking.",
    locationExternalFallback:
      "Confirm the final meeting point on the official source before attending.",
    requirementsMissing: "No requirements were provided in this listing.",
    accessibilityMissing: "Accessibility information was not provided in this listing.",
    freshnessTemplate: "Listing sources last reviewed {date}",
    catchRegistrationOpen: "{count} spots shown; booking is available in the Catch app.",
    catchRegistrationFull: "Shown as full; check the Catch app for waitlist updates.",
    registrationClosed: "Registration is closed because this event has ended.",
    externalRegistration: "Check current availability on the official source.",
  },
  provenance: {
    eyebrow: "Listing provenance",
    title: "Know who supplied the event",
    catchBody:
      "This event was created in Catch. Organizer verification is shown separately so an app-created event is not mistaken for an owner-verified organizer.",
    externalBody:
      "This event was collected from an approved public source. Catch keeps it read-only and sends registration back to that source.",
    sourceLabel: "Event source",
    organizerLabel: "Organizer status",
    reviewedLabel: "Last reviewed",
  },
  reviews: {
    eyebrow: "Event reviews",
    title: "Reviews tied to this event",
    body:
      "Only published reviews carrying this event ID appear here. Organizer-level reviews stay on the organizer profile.",
    laneBody: "These reviews are linked to attendance at this specific event.",
    laneTitle: "Verified attendee reviews",
    emptyTitle: "No event-specific reviews yet",
    emptyBody:
      "The organizer may still have reviews on its profile, but Catch does not attribute them to this event without an event ID.",
    unavailableTitle: "Event reviews are not available yet",
    unavailableBody:
      "Catch will show event-specific reviews here after the organizer review target is verified. No organizer-level review is attributed to this event.",
  },
  footerBody:
    "Read event details on the web, then use Catch or the official source for registration.",
} as const;
