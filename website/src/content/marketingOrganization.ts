import {publicSiteCopy} from "./site";

export const organiserHomeCopy = {
  nav: publicSiteCopy.nav,
  actions: {
    start: {href: "/host/", label: "Explore Catch Host"},
    attend: {href: "/explore/", label: "Find events"},
    claim: {href: "/claim/", label: "Claim your organiser page"},
  },
  hero: {
    kicker: "Catch for organisers",
    title: "Get found. Bring guests together. Run the room.",
    body: "The room before the match: runs, dinners, quiz nights and mixers where people meet in person first. Catch gives organisers a public presence and a supported path from guest list to live event.",
    claimNote: "Claim requests are reviewed. Submitting one does not open an organiser workspace.",
  },
  product: {
    title: "Start with the part of your event that needs Catch.",
    body: "Keep the booking tools that work. Explore the supported live-event pilot and discuss the wider guest-management and planning workflows with us.",
    items: [
      {title: "Presence and discovery", body: "Find your public organiser page, its events and sources, and request an ownership review.", action: {href: "/organizers/", label: "Browse organisers"}},
      {title: "Guest management and live operations", body: "Review a guest-list import, coordinate arrival, choose useful live tools and connect the recap.", action: {href: "/host/#how-it-works", label: "See how Catch Host works"}},
      {title: "Your event, your workflow", body: "Explore clubs, social events, weddings, corporate gatherings and multi-day programmes. Confirm support before changing your setup.", action: {href: "/host/#use-cases", label: "Explore use cases"}},
    ],
  },
  explore: {
    eyebrow: "Here to attend?", title: "Find the event and the people behind it.",
    body: "Browse real public events and organiser profiles. Registration follows each event’s available booking or official-source path. App availability and the member waitlist live with event discovery.",
    directory: {href: "/organizers/", label: "Browse all organisers"},
    visitors: {href: "/explore/", label: "Find events"},
  },
  footer: publicSiteCopy.footerBody,
} as const;
