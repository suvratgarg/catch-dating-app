/** Deterministic browser/test fixture; never selects a live program or token. */
export const householdRsvpViewFixture = {
  programId: "fixture-program",
  programTitle: "Asha & Rohan's Wedding",
  timezone: "Asia/Kolkata",
  householdId: "fixture-household",
  householdLabel: "Sharma family",
  messagingConsentGranted: false,
  members: [
    {
      guestId: "fixture-guest-1",
      displayName: "Ashok Sharma",
      functions: [
        {
          functionId: "fixture-sangeet",
          name: "Sangeet",
          startsAtMillis: 1_800_600_000_000,
          endsAtMillis: 1_800_603_000_000,
          venueName: "The Courtyard",
          dressCode: "Festive",
          instructions: null,
          rsvpStatus: "pending" as const,
          partySize: null,
          responseNote: null,
        },
        {
          functionId: "fixture-reception",
          name: "Reception",
          startsAtMillis: 1_800_700_000_000,
          endsAtMillis: 1_800_703_000_000,
          venueName: "Grand Hall",
          dressCode: "Formal",
          instructions: "Doors open at 6:30 pm.",
          rsvpStatus: "attending" as const,
          partySize: 2,
          responseNote: null,
        },
      ],
    },
    {
      guestId: "fixture-guest-2",
      displayName: "Meena Sharma",
      functions: [
        {
          functionId: "fixture-sangeet",
          name: "Sangeet",
          startsAtMillis: 1_800_600_000_000,
          endsAtMillis: 1_800_603_000_000,
          venueName: "The Courtyard",
          dressCode: "Festive",
          instructions: null,
          rsvpStatus: "pending" as const,
          partySize: null,
          responseNote: null,
        },
      ],
    },
  ],
};

export const householdRsvpCopy = {
  brand: "Catch home", brandWord: "catch", kicker: "You're invited",
  loadingTitle: "Getting your invitation",
  loading: "Loading your household's invitation…",
  unavailableTitle: "This invitation link is unavailable",
  unavailableBody: "Open the latest link from your message. It may have expired or been replaced.",
  networkTitle: "We couldn't load your invitation",
  networkBody: "Check your connection and try again.",
  refresh: "Refresh", refreshing: "Refreshing…",
  attending: "Attending", maybe: "Maybe", declined: "Can't make it",
  partySize: "Seats needed", partySizePlaceholder: "1",
  note: "Anything we should know? (optional)",
  notePlaceholder: "Allergies, accessibility, travel timing…",
  consentLabel:
    "It's OK to message this household about schedule changes and event updates.",
  submit: "Send RSVP", sending: "Sending your RSVP…",
  saved: "Your RSVP is saved. You can update it any time before the event.",
  uncertain:
    "We couldn't confirm your RSVP. Check your connection and try again.",
  itinerary: "Add to calendar (.ics)",
  dressCodeLabel: "Dress code:",
  functionsHeading: "Functions",
  membersHeading: "Your household",
};
