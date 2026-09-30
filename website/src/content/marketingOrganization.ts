import {ownerGatedSiteDestinations} from "./site";

export const organiserHomeCopy = {
  menu: {
    dialogLabel: "Site menu", openLabel: "Menu", closeLabel: "Close",
    kicker: "Catch · For organisers", hint: "Presence, guests, and the live event", navLabel: "Mobile",
  },
  nav: [
    {href: "#product", label: "Product"},
    {href: "#solutions", label: "Solutions"},
    {href: "#explore", label: "Explore"},
    {href: "#resources", label: "Resources"},
  ],
  actions: {
    start: {href: "/claim/", label: "Get started free"},
    signIn: {href: "/claim/", label: "Sign in for a claim"},
    walkthrough: {href: ownerGatedSiteDestinations.contactHref, label: "Request a software walkthrough"},
    pilot: {href: "/host/", label: "Explore the live-event pilot"},
  },
  hero: {
    kicker: "Catch for organisers",
    title: "Get found. Bring guests together. Run the room.",
    body: "A home for your public presence and a clearer path through guest management, live operations, and event logistics. Start with the directory, or discuss the supported live-event pilot.",
    claimNote: "Start with a claim request. Presence-management tools are being developed.",
    signInNote: "Sign-in is for the existing claim flow. It does not open an organiser workspace.",
  },
  product: {
    title: "Four jobs, one event story.",
    body: "Explore what Catch can help with today and the workflows being developed. Preview pages describe concepts, not generally available software.",
    items: [
      {label: "Directory and claim requests", title: "Presence and discovery", body: "Help visitors find your organiser listing. Request a claim; tools for managing that presence are being developed.", action: {href: "/organizers/", label: "Search the organiser directory"}},
      {label: "Supported pilot and workflow previews", title: "Registration and guest management", body: "Keep your existing booking or RSVP tool. The live-event pilot begins with an imported guest list; broader registration workflows are previews.", action: {href: "/host/workflows/", label: "Preview guest workflows"}},
      {label: "Supported live-event pilot", title: "Live operations", body: "Selected hosts get hands-on setup for guest-list import, arrival, optional live tools, and a connected recap.", action: {href: "/host/", label: "See the current pilot"}},
      {label: "Concept preview", title: "Programme and logistics", body: "Explore ideas for schedules, guest coordination, and planning. Discuss your event before assuming these tools are available.", action: {href: "/host/planners/", label: "Preview planning workflows"}},
    ],
  },
  solutions: {
    title: "Start with the kind of event you run.",
    body: "These solution previews show where the same organiser jobs meet different event needs. Availability is agreed through a supported walkthrough.",
    items: [
      {label: "Solution preview", title: "Clubs and communities", body: "Recurring meetups and member events need a visible organiser, a clear guest list, and a smooth welcome.", action: {href: "/host/clubs/", label: "Preview clubs and communities"}},
      {label: "Solution preview", title: "Social events", body: "Dinners and mixers need arrival, introductions, and optional live structure that fits the room.", action: {href: "/host/mixers/", label: "Preview social events"}},
      {label: "Planning preview", title: "Weddings", body: "Explore planning concepts for guest coordination and the programme of a private celebration.", action: {href: "/host/planners/", label: "Preview wedding planning"}},
      {label: "Planning preview", title: "Corporate events", body: "Explore planning concepts for a team gathering, its guest coordination, and its programme.", action: {href: "/host/planners/", label: "Preview corporate planning"}},
    ],
  },
  explore: {
    eyebrow: "Explore the directory",
    title: "Discovery starts with organisers.",
    body: "Search current public organiser listings by name, activity, or city. Visitors can browse the directory without claiming a listing or applying for the pilot.",
    directory: {href: "/organizers/", label: "Browse all organisers"},
    visitors: {href: "/explore/", label: "Explore events and the Catch app"},
    claim: {href: "/claim/", label: "Request a listing claim"},
  },
  discovery: {
    eyebrow: "Public event discovery",
    title: "Search events and the organisers behind them.",
    body: "Browse public events and follow each listing to its organiser or official source. Availability and registration depend on the event.",
  },
  featured: {
    eyebrow: "Organiser directory",
    title: "Public organiser pages are the starting point.",
    body: "Browse current public listings and the sources behind them. A public listing does not mean its organiser has claimed it or joined the pilot.",
    ctaBody: "Run an event? Start with a listing claim request. Presence-management tools are being developed.",
  },
  resources: {
    title: "Choose a useful next step.",
    body: "Read the current pilot details, explore clearly labelled concepts, or contact Catch to discuss what your event needs.",
    items: [
      {title: "Current live-event pilot", body: "Read the supported guest-list handoff, live tools, limits, and host application process.", action: {href: "/host/", label: "Read pilot details"}},
      {title: "Workflow previews", body: "Explore registration, guest-management, and planning concepts before discussing availability.", action: {href: "/host/workflows/", label: "Explore workflow previews"}},
      {title: "Software walkthrough", body: "Discuss your event and which supported tools could help. A walkthrough request does not create a workspace.", action: {href: ownerGatedSiteDestinations.contactHref, label: "Request a software walkthrough"}},
    ],
  },
  footer: "Catch for organisers: public discovery, guest coordination, and a supported live-event pilot.",
} as const;
