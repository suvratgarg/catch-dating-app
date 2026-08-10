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
    webActionHeading: "Register here with your phone",
    webActionBody:
      "No app or Consumer profile is required. Verify your number, add your name, and the organizer will see you on the event roster.",
    webWaitlistHeading: "Join the waitlist with your phone",
    webWaitlistBody:
      "The confirmed roster is full. Verify your number to join the event-scoped waitlist without an app or Consumer profile.",
    externalActionHeading: "Registration stays with {source}",
    externalActionBody:
      "Catch does not sell, reserve, or waitlist places for this event. Confirm the latest details before you go.",
    officialSourceAction: "Open official source",
    webRegistration: {
      nameLabel: "Your name",
      namePlaceholder: "Name for the event roster",
      phoneLabel: "Mobile number",
      phonePlaceholder: "+91 98765 43210",
      codeLabel: "6-digit OTP",
      codePlaceholder: "123456",
      sendCodeAction: "Send OTP",
      confirmAction: "Verify and register",
      sendingCodeAction: "Sending OTP...",
      registeringAction: "Registering...",
      codeSent: "OTP sent. Enter the code from your phone.",
      success: "You are registered. The organizer now has you on the event roster.",
      alreadyRegistered: "You were already registered. Your roster place is confirmed.",
      waitlisted: "The event is full, so you are now on the organizer's waitlist.",
      privacy:
        "Your number is used for event identity and roster operations. A full Catch profile is not created.",
      missingName: "Enter the name the organizer should use.",
      invalidPhone: "Use a mobile number with country code, such as +91.",
      invalidCode: "Enter the 6-digit OTP.",
      verificationExpired: "That verification expired. Send a new OTP to continue.",
      tooManyRequests: "Too many attempts were made. Wait a little, then request a new OTP.",
      eventUnavailable: "Registration changed while you were signing up. Refresh the event page for the latest availability.",
      genericError: "Something went wrong. Please try again.",
    },
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
    webRegistrationOpen: "{count} spots shown; phone OTP registration is available here.",
    webRegistrationWaitlist: "The confirmed roster is full; phone OTP waitlist registration is available here.",
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
