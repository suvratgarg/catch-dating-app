import type {FaqItem, PlaybookModule, PlaybookStage, SectionCopy} from "./types";

export const hostPageCopy = {
  nav: {
    workflow: "How it works",
    liveTools: "Live tools",
    worksNow: "What works now",
    comingSoon: "Coming soon",
    organizers: "Organizers",
    apply: "Apply for beta",
  },
  hero: {
    title: "Keep your booking platform. Run a better event.",
    body:
      "Import your guest list, share one QR code, and give every checked-in guest the live Catch experience—no app download required.",
    primaryAction: "Apply for beta access",
    secondaryAction: "See how it works",
    compatibility:
      "Bring a CSV from Luma, Eventbrite, Partiful, POSH, Airbnb, BookMyShow—or anywhere else.",
  },
  workflow: {
    title: "From exported guest list to live room in minutes.",
    body:
      "Keep selling tickets or taking RSVPs where you already do. Catch begins with the guest list you export.",
    railLabel: "Setup steps",
    mockLabel: "Companion event",
    nextLabel: "Next",
    readyLabel: "Ready to share",
  },
  live: {
    label: "Live tools",
    title: "Useful before the Catch network exists.",
    body:
      "Every guest opens the event in a mobile browser after phone verification. The host controls attendance, approvals, and the live flow from the organizer app.",
  },
  comparison: {
    label: "What works now",
    title: "Use Catch for the part ticketing tools leave unfinished.",
    bookingColumn: "Your booking platform",
    catchColumn: "Catch alongside it",
    callout:
      "A QR scanner alone is not the product. One imported guest list unlocks arrival, live facilitation, and post-event learning together.",
    limits:
      "Today: CSV-based setup for up to 250 guests at a time. Very large guest lists and provider-direct sync come later.",
    tableLabel: "How a booking platform and Catch divide the work",
  },
  captures: {
    label: "What the host sees",
    title: "One event record from the door to the recap.",
    body:
      "The organizer app keeps the imported guest list, check-in state, live controls, approval requests, and event recap connected.",
    setup: "Guest list setup",
    live: "Live host controls",
    report: "Event recap",
  },
  comingSoon: {
    label: "Coming later with the Catch platform",
    title: "What’s next—and not required to start.",
    body:
      "Useful now does not depend on these. They deepen the system when you choose to adopt them.",
  },
  apply: {
    title: "Apply for beta access.",
    body:
      "We are approving a small group of hosts whose next event can teach us something. Apply with a real event; selected hosts get hands-on onboarding and free beta access.",
  },
  footer:
    "Standalone live-event tools for hosts who already have a way to sell tickets or collect RSVPs.",
} as const;

export const hostHeroCopy = {
  stageCaption: "Guest list, arrival, live tools, and host approvals in one view.",
  demo: {
    eventName: "Sunday Supper",
    hostLabel: "Host console",
    guestListLabel: "Guest list",
    checkedInLabel: "Checked in",
    guestLabel: "Guest",
    statusLabel: "Status",
    timeLabel: "Arrival",
    shareLabel: "Share event QR",
    runtimeLabel: "Guest web check-in",
    runtimeTitle: "You’re checked in.",
    runtimeBody: "No app download required.",
    runtimeItems: ["First Hello", "Prompts", "Ask for an introduction"],
    guests: [
      {name: "Avery", status: "Checked in", time: "7:02"},
      {name: "Jordan", status: "Checked in", time: "7:01"},
      {name: "Taylor", status: "Expected", time: "—"},
      {name: "Morgan", status: "Expected", time: "—"},
    ],
  },
} as const;

export const hostWorkflowSteps = [
  {
    step: "01",
    title: "Create the companion event",
    body: "Keep selling tickets or taking RSVPs where you already do.",
  },
  {
    step: "02",
    title: "Import the guest list",
    body: "Upload a CSV in the organizer app or use secure forwarding.",
  },
  {
    step: "03",
    title: "Share the event QR",
    body: "Phone verification links each arrival to the right guest-list entry.",
  },
] as const;

export const hostLiveTools = [
  {
    label: "Arrival",
    title: "Guest list and attendance",
    body: "Import names and phone numbers, then see who is expected, checked in, or awaiting approval.",
  },
  {
    label: "Door",
    title: "QR and manual check-in",
    body: "Guests scan the event QR, or a host confirms attendance manually when the door is busy.",
  },
  {
    label: "First minutes",
    title: "First Hello",
    body: "Give each arrival a simple first interaction they can skip or replace.",
  },
  {
    label: "Context",
    title: "Compatibility prompts",
    body: "A short optional questionnaire supplies conversation context without pretending to score chemistry.",
  },
  {
    label: "Introductions",
    title: "Help me say hi",
    body: "A checked-in guest can quietly ask the host for an introduction; the other person is not notified.",
  },
  {
    label: "Control",
    title: "Host approvals and overrides",
    body: "Review unmatched arrivals, control what runs, and override assignments without exposing private answers.",
  },
] as const;

export const hostCurrentLayers = [
  {
    label: "Bring",
    title: "Your existing guest list",
    body: "Catch begins with names and phone numbers exported from the tool you already use.",
  },
  {
    label: "Run",
    title: "A no-download live room",
    body: "Phone verification opens event-only tools in the guest’s mobile browser.",
  },
  {
    label: "Learn",
    title: "One connected event record",
    body: "Attendance, host actions, and private feedback stay connected without creating a dating profile.",
  },
] as const;

export const hostSetupProof = [
  {
    id: "imports",
    label: "Guest-list import",
    title: "Map the file once.",
    body: "Reviewed exports map automatically, while unknown files keep a manual mapping path.",
    facts: [
      "CSV and XLSX upload in the organizer app.",
      "Secure email and WhatsApp forwarding when provider routing is configured.",
      "Duplicate contacts are detected inside the event.",
    ],
    activityToken: "var(--catch-activity-dinner-accent)",
  },
  {
    id: "arrival",
    label: "Arrival",
    title: "Keep the door moving.",
    body: "A QR opens phone verification; manual attendance and walk-in approvals remain available to the host.",
    facts: [
      "QR and direct-link entry.",
      "Manual check-in when a guest cannot scan.",
      "Approval queue for unmatched walk-ins when enabled.",
    ],
    activityToken: "var(--catch-activity-social-run-accent)",
  },
  {
    id: "browser",
    label: "Guest browser",
    title: "Open only what the event needs.",
    body: "The event can request a few optional fields before opening First Hello, prompts, or introduction requests.",
    facts: [
      "No app download or public profile required.",
      "Sensitive fields appear only when selected logic needs them.",
      "Answers can prefill a later opt-in profile without publishing one.",
    ],
    activityToken: "var(--catch-activity-padel-accent)",
  },
] as const;

export const hostComparisonRows = [
  ["Sell tickets or take RSVPs", "Import the guest list"],
  ["Guest list before doors", "Verified attendance at the door"],
  ["Broadcast updates", "First Hello, prompts, and quiet introduction requests"],
  ["RSVP totals", "A private event recap with concrete next steps"],
] as const;

export const hostComingSoonItems = [
  {
    label: "Booking",
    proof: "Catch-native ticketing and waitlists",
  },
  {
    label: "Profiles",
    proof: "Full member profiles and mutual catching",
  },
  {
    label: "Conversation",
    proof: "Event-context chats",
  },
  {
    label: "Network",
    proof: "Catch discovery and the social graph",
  },
] as const;

export const playbook = {
  eyebrow: "The live room",
  title: "Turn on only the help this event needs.",
  body: [
    "A run may need only attendance and a First Hello. A dinner or mixer can add prompts, introductions, and guided rotations.",
    "Every live tool is optional per event, works in the guest’s browser, and stays tied to the same attendance record.",
  ],
  railLabel: "Live stages",
  captureFallback: "Live host controls",
  guardrailTitle: "Guests opt in. Hosts stay in control.",
  guardrailBody:
    "Guests can skip any prompt or request. Hosts never see private questionnaire answers, and sensitive traits are requested only when a selected live tool genuinely needs them.",
  formatNote:
    "Use the lightest version that improves the room. A feature that distracts guests from the event should stay off.",
} as const;

export const playbookStages = [
  {id: "before", label: "Before", sub: "Guest list ready", guestLine: "Your phone number links you only to this event.", hostLine: "Import the guest list and choose the live tools that fit."},
  {id: "arrival", label: "Arrival", sub: "The door", guestLine: "Scan, verify, and enter the live room without downloading an app.", hostLine: "Watch attendance and review unmatched arrivals."},
  {id: "mixing", label: "Live", sub: "Room in motion", guestLine: "Get a simple first step, prompt, or optional introduction request.", hostLine: "Run First Hello, prompts, and assignments with overrides close by."},
  {id: "debrief", label: "After", sub: "The recap", guestLine: "Private feedback helps the next event improve.", hostLine: "Review attendance and event-level patterns without seeing private answers."},
] satisfies readonly PlaybookStage[];

export const playbookModules = [
  {id: "guest_list", anchor: "playbook-guest-list", publicName: "Guest list import", stageId: "before", chip: "OFF YOUR PLATE", oneLiner: "Start with the list your booking tool already gives you.", more: "Upload CSV or XLSX in the organizer app. Reviewed formats map automatically; every other file keeps a manual column-mapping path.", fits: "Every format."},
  {id: "qr_check_in", anchor: "playbook-door-check-in", publicName: "Door check-in", stageId: "arrival", chip: "OFF YOUR PLATE", oneLiner: "Know who is actually in the room.", more: "Guests verify the phone number on the imported list, while hosts keep manual attendance and an approval queue for unmatched arrivals.", fits: "Every format."},
  {id: "first_hello_check_in", anchor: "playbook-first-hello", publicName: "First Hello", stageId: "arrival", chip: "NEW POWER", oneLiner: "Give every arrival a clear first interaction.", more: "A small arrival mission suggests a person to find and a question to ask. Guests can skip or request another mission.", fits: "Dinners, mixers, quiz nights, and racket socials. Off by default."},
  {id: "compatibility_questionnaire", anchor: "playbook-compatibility-prompts", publicName: "Compatibility prompts", stageId: "before", chip: "NEW POWER", oneLiner: "Add context without requiring a full dating profile.", more: "A short event-only questionnaire can supply the fields a selected prompt or assignment needs. Answers remain private and can prefill an optional later profile.", fits: "Mixers, dinners, and quiz nights. Off by default."},
  {id: "wingman_requests", anchor: "playbook-help-me-say-hi", publicName: "Help me say hi", stageId: "mixing", chip: "NEW POWER", oneLiner: "Let guests request a quiet introduction.", more: "Checked-in guests can make an explicit, private request. The other person is not notified; the host decides whether and how to introduce them.", fits: "Every stationary format."},
  {id: "guided_rotations", anchor: "playbook-rotations", publicName: "Guided assignments", stageId: "mixing", chip: "OFF YOUR PLATE", oneLiner: "Move pairs, tables, or small groups without manual logistics.", more: "Show each guest only where to go next and keep host overrides available when attendance changes.", fits: "Dinners, mixers, quiz nights, and racket socials."},
  {id: "decomposed_feedback", anchor: "playbook-guest-feedback", publicName: "Guest feedback", stageId: "debrief", chip: "NEW POWER", oneLiner: "Learn what guests experienced and what can improve.", more: "Short private questions cover welcome, structure, safety, and conversation. Hosts see combined patterns, not individual answers.", fits: "Every format."},
  {id: "host_recap", anchor: "playbook-recap", publicName: "The event recap", stageId: "debrief", chip: "NEW POWER", oneLiner: "Turn live activity into one or two next steps.", more: "Attendance, participation, and private feedback become a concise operating brief without promising conclusions the event did not produce.", fits: "Every format."},
] satisfies readonly PlaybookModule[];

export const hostFoundingOffer = {
  title: "Free to use. Deliberately limited access.",
  body:
    "Beta access is free, but onboarding is hands-on. We select hosts with a real upcoming event, a guest list they can import, and a format where the live tools can be evaluated honestly.",
  badgeAriaLabel: "Catch beta access",
  badgeLabel: "Private",
  badgeValue: "Beta",
  steps: ["Apply with an event", "Get selected", "Import the guest list", "Run the room"],
} as const;

export const hostTrust = {
  title: "The useful part is the connected system, not any one feature.",
  body:
    "QR check-in is common. What matters is that the same verified attendance record powers the guest’s live tools, the host’s controls, and an honest recap.",
} satisfies SectionCopy;

export const hostTrustItems = [
  {
    title: "No app requirement",
    body: "Guests verify their phone number and use the live event in a mobile browser.",
  },
  {
    title: "Event-only identity",
    body: "A guest can participate without creating a public dating profile or joining the Catch network.",
  },
  {
    title: "Private by design",
    body: "Hosts manage the room without seeing private questionnaire answers or exposing an introduction request.",
  },
] as const;

export const hostFaq = {
  title: "Questions hosts ask before adding another tool.",
} satisfies SectionCopy;

export const hostFaqs = [
  {
    question: "Do I have to stop using my current booking platform?",
    answer:
      "No. Keep selling tickets or collecting RSVPs where you already do. Export the guest list and create a companion event in Catch.",
  },
  {
    question: "Do guests have to download the Catch app?",
    answer:
      "No. The event QR opens a mobile web experience. Guests verify the phone number used on the guest list and enter the event directly.",
  },
  {
    question: "Which guest-list exports work?",
    answer:
      "CSV and XLSX upload are supported. Luma, Eventbrite, Partiful, and POSH have reviewed mappings; other exports can use manual column mapping while their samples are verified.",
  },
  {
    question: "What if someone arrives without a matching guest-list entry?",
    answer:
      "The host can allow walk-ins for the event. The guest verifies a phone number and enters an approval queue before the live tools unlock.",
  },
  {
    question: "Is the beta really free?",
    answer:
      "Yes. Access is limited because onboarding and event review are hands-on, not because there is a software fee during the beta.",
  },
  {
    question: "What still requires the future Catch platform?",
    answer:
      "Catch-native ticketing and waitlists, full member profiles, mutual catching, event-context chats, and the broader discovery network come later.",
  },
] satisfies readonly FaqItem[];

export const hostApplicationCopy = {
  steps: {
    profile: {label: "Host identity", body: "Who you are and what you run."},
    event: {label: "Next event", body: "The real event we can learn from."},
    setup: {label: "Current setup", body: "Booking tool and guest-list size."},
    success: {label: "Live tools", body: "Where Catch could help most."},
    review: {label: "Review", body: "Confirm the beta application."},
  },
  setup: {
    bookingPlatformLabel: "Current booking or RSVP platform",
    guestListFormatLabel: "How can you export the guest list?",
    guestCountLabel: "Expected guest count",
    bookingPlatforms: [
      "Luma",
      "Eventbrite",
      "Partiful",
      "POSH",
      "Airbnb Experiences",
      "BookMyShow / District",
      "SortMyScene",
      "Google Form / spreadsheet",
      "Another platform",
    ],
    guestListFormats: ["CSV", "XLSX", "Not sure yet"],
  },
  liveToolOptions: [
    "Guest list and attendance",
    "QR and manual check-in",
    "First Hello",
    "Compatibility prompts",
    "Help me say hi",
    "Guided assignments",
    "Guest feedback",
    "Event recap",
  ],
  checklist: {
    profile: "Host identity",
    event: "Real upcoming event",
    setup: "Current booking setup",
    live: "Live-tool goal",
  },
  errors: {
    setup: "Add the booking platform, export format, and expected guest count.",
  },
  review: {
    setupTitle: "Current setup",
    platformLabel: "Platform",
    formatLabel: "Export",
    guestsLabel: "Guests",
    noteTitle: "What happens after you apply",
    noteBody:
      "Catch reviews the event, guest-list setup, and selected live tools before confirming beta access. Selected hosts get a guided import check and a run-through before doors open.",
  },
} as const;
