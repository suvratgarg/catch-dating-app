import type {
  AppDownloadCtaItem,
  AppDownloadStorePlatform,
} from "../../shared/ui/primitives";

export type StorePlatform = AppDownloadStorePlatform;
export interface OrganizerEventHighlight {
  id: string;
  title: string;
  kind: string;
  detail: string;
  href: string;
  activityToken: string;
}
export interface StoreCta extends AppDownloadCtaItem {
  shortLabel: string;
}

export interface ActivityMeta {
  label: string;
  token: string;
  short: string;
}

export interface HostCreateStep {
  id: string;
  title: string;
  sub: string;
  captureId?: string;
  outcome: string;
  fields: Array<{
    label: string;
    value: string;
    note?: string;
    options?: string[];
    activeOption?: string;
    wide?: boolean;
  }>;
}

export const formatCards = [
  {
    mark: "SR",
    title: "Social runs",
    body: "Low-pressure movement, shared pace, and the right follow-up after.",
  },
  {
    mark: "RK",
    title: "Racket sports",
    body: "Pairing, rotations, and court-aware structure for social play.",
  },
  {
    mark: "DN",
    title: "Dinners",
    body: "Tables, prompts, and host rhythm that make conversation easier.",
  },
  {
    mark: "QZ",
    title: "Quiz nights",
    body: "Teams, missions, and shared wins before private interest opens.",
  },
  {
    mark: "MX",
    title: "Singles mixers",
    body: "Structured ways to meet more people without exposing rejection.",
  },
  {
    mark: "CU",
    title: "Custom hosts",
    body: "Bring the format. Catch gives you the event and dating layer.",
  },
];

export const memberLoop = [
  {
    step: "01",
    title: "Choose the event",
    body: "Browse events by format, city, host, timing, and social structure.",
  },
  {
    step: "02",
    title: "Be present",
    body: "Check in, meet people, and let the host guide the live moment.",
  },
  {
    step: "03",
    title: "Catch privately",
    body: "After the event, express interest without exposing rejection.",
  },
  {
    step: "04",
    title: "Match with context",
    body: "If the interest is mutual, chat opens around the event you shared.",
  },
];

export const hostLoop = [
  {
    step: "01",
    title: "Design the format",
    body: "Select the activity, interaction model, capacity, and live modules.",
  },
  {
    step: "02",
    title: "Shape demand",
    body: "Use invite links, requests, waitlists, offers, cohorts, and pricing controls.",
  },
  {
    step: "03",
    title: "Run the event",
    body: "Check people in, guide live moments, and adjust assignments when needed.",
  },
  {
    step: "04",
    title: "Learn what worked",
    body: "Unlock private catches, then review aggregate attendance and connection signal.",
  },
];

export const trustItems = [
  {
    title: "Attendance-gated",
    body: "Dating surfaces open around real event participation, not cold browsing.",
  },
  {
    title: "Private by default",
    body: "Catches are private unless mutual. Host reports stay aggregate-safe.",
  },
  {
    title: "Format-aware facilitation",
    body: "Runs, dinners, teams, courts, and mixers can use the modules that fit.",
  },
  {
    title: "Host-owned standards",
    body: "Admission, capacity, waitlist, check-in, and safety controls stay explicit.",
  },
];

export const hostModules = [
  {
    label: "Arrival",
    title: "First Hello",
    body: "A lightweight check-in ritual that helps guests start with a real person, not a blank prompt.",
  },
  {
    label: "Movement",
    title: "Assignments",
    body: "Balanced pairs, tables, pods, teams, and rotations with aggregate-safe reasons and host overrides.",
  },
  {
    label: "Control",
    title: "Host console",
    body: "Check-in, live steps, reveal moments, planned breaks, and safety actions stay in one place.",
  },
  {
    label: "After",
    title: "Catch window",
    body: "Private interest opens after attendance. Mutual catches become chats with shared context.",
  },
];

export const hostEvidenceMetrics = [
  {value: "64", label: "invite activity"},
  {value: "24", label: "demand signals"},
  {value: "17", label: "booked guests"},
  {value: "13", label: "checked in"},
  {value: "11", label: "caught someone"},
  {value: "18", label: "mutual matches"},
];

export const hostSurfaceCards = [
  {
    label: "Bookings",
    title: "Control who gets in before the event fills.",
    body: "Open sales, invite-only drops, request-to-join, balanced ratios, paid checkout, waitlists, and host-issued offers all feed the same roster.",
  },
  {
    label: "Live",
    title: "Give the event structure while it is happening.",
    body: "First Hello, prompts, check-in, assignments, rotations, planned breaks, reveal moments, overrides, and safety controls are built for the host screen.",
  },
  {
    label: "After",
    title: "Turn attendance into a private matching window.",
    body: "Guests can catch privately after they show up. Hosts see aggregate demand, matches, chats, and repeat attendance, never private target identities.",
  },
];

export const hostFillRoomModules = [
  {
    id: "paid-checkout",
    label: "Paid checkout",
    title: "Turn demand into a confirmed roster.",
    body: "Checkout, payment state, refunds, and check-in all feed the same attendance record, so hosts are not reconciling tickets in another tool.",
    facts: [
      "Track checkout started, payment pending, paid, failed, and refunded states.",
      "Keep paid guests, approved requests, and invite-link demand in one roster.",
      "Use attendance proof before reviews, catches, matches, or reports count.",
    ],
    activityToken: "var(--catch-activity-dinner-accent)",
  },
  {
    id: "waitlist-offers",
    label: "Waitlist offers",
    title: "Move the waitlist without overselling the room.",
    body: "Timed offers let hosts release open spots, expire stale demand, and keep the public waitlist honest as people accept or decline.",
    facts: [
      "Offer active, accepted, declined, and expired states stay visible.",
      "Hosts can fill cancellations without manual DMs or duplicate payment links.",
      "Waitlist movement appears in the post-event report beside bookings.",
    ],
    activityToken: "var(--catch-activity-social-run-accent)",
  },
  {
    id: "balanced-cohorts",
    label: "Balanced cohorts",
    title: "See who the room is missing before publish.",
    body: "Cohort previews expose aggregate balance, format fit, and guest-mix gaps without revealing private catch targets or sensitive identities.",
    facts: [
      "Preview gender balance, group size, pace, skill, and repeat-attendee gaps.",
      "Use cohorts for tables, teams, pods, courts, or rotations.",
      "Keep host reporting aggregate-safe before, during, and after the event.",
    ],
    activityToken: "var(--catch-activity-racket-accent)",
  },
];

export const hostProofRows = [
  {
    label: "Invite links",
    proof: "See which invites create interest, bookings, paid guests, check-ins, catches, matches, and chats.",
  },
  {
    label: "Waitlist movement",
    proof: "Offer expiring spots without overselling, and keep the list clear as guests accept, decline, or miss the window.",
  },
  {
    label: "Event Success",
    proof: "Create pairs, tables, pods, teams, and rotations around the guest mix, event size, host constraints, and last-minute changes.",
  },
  {
    label: "Host reports",
    proof: "Reports stay current as bookings, attendance, waitlist offers, catches, matches, and chats move.",
  },
];

export const storeCtas: StoreCta[] = [
  {
    platform: "ios",
    kicker: "Download on the",
    label: "App Store",
    shortLabel: "iOS",
    href: import.meta.env.VITE_APP_STORE_URL?.trim() ?? "",
  },
  {
    platform: "android",
    kicker: "Get it on",
    label: "Google Play",
    shortLabel: "Play",
    href: import.meta.env.VITE_PLAY_STORE_URL?.trim() ?? "",
  },
];

export const activityMeta: Record<string, ActivityMeta> = {
  socialRun: {
    label: "Social run",
    token: "var(--catch-activity-social-run-accent)",
    short: "SR",
  },
  running: {
    label: "Running",
    token: "var(--catch-activity-running-accent)",
    short: "RN",
  },
  dinner: {
    label: "Dinner",
    token: "var(--catch-activity-dinner-accent)",
    short: "DN",
  },
  singlesMixer: {
    label: "Singles mixer",
    token: "var(--catch-activity-singles-mixer-accent)",
    short: "MX",
  },
  pubQuiz: {
    label: "Pub quiz",
    token: "var(--catch-activity-pub-quiz-accent)",
    short: "QZ",
  },
  racket: {
    label: "Racket sport",
    token: "var(--catch-activity-padel-accent)",
    short: "RK",
  },
  open: {
    label: "Open format",
    token: "var(--catch-activity-open-activity-accent)",
    short: "OP",
  },
};

export const claimUnlocks = [
  "Respond to public reviews",
  "Correct facts, formats, and contact details",
  "Add official photos and logo permission",
  "Publish Catch events with bookings and check-in",
  "Show verified attendee reviews",
  "See listing views, saves, and search appearance",
];

export const hostCreateSteps: HostCreateStep[] = [
  {
    id: "basics",
    title: "Event basics",
    sub: "Name, activity format, and interaction model",
    captureId: "host-create-basics",
    outcome: "Turns a rough idea into a reusable event shell.",
    fields: [
      {label: "Event name", value: "Sunday Table Club", wide: true},
      {label: "Activity format", value: "Dinner"},
      {label: "Guest promise", value: "Conversation-first"},
      {label: "Interaction model", value: "Seated table rotation", wide: true},
    ],
  },
  {
    id: "location",
    title: "Meeting location",
    sub: "Venue, meeting point, and arrival notes",
    captureId: "host-create-location",
    outcome: "Keeps the public listing simple while preserving exact arrival context.",
    fields: [
      {label: "Location name", value: "Pali Village Cafe"},
      {label: "Address release", value: "After booking"},
      {label: "Meeting point", value: "Host greets guests at the door", wide: true},
      {label: "Arrival note", value: "Seat together at 8:30 sharp", wide: true},
    ],
  },
  {
    id: "schedule",
    title: "When is the event?",
    sub: "Date, time, and check-in window",
    captureId: "host-create-schedule",
    outcome: "Makes timing visible before bookings, reminders, and check-in begin.",
    fields: [
      {label: "Event date", value: "Sat 21 Jun"},
      {label: "Start time", value: "8:30 PM"},
      {label: "Duration", value: "2 hours"},
      {label: "Check-in opens", value: "30 min before"},
    ],
  },
  {
    id: "policy",
    title: "Event policy",
    sub: "Capacity, price, admission, waitlist, and cancellation",
    captureId: "host-create-policy",
    outcome: "Protects the room composition before demand starts building.",
    fields: [
      {label: "Max attendees", value: "20"},
      {label: "Base price", value: "₹1,200"},
      {
        label: "Admission format",
        value: "Balanced",
        options: ["Open", "Invite", "Request", "Balanced"],
        activeOption: "Balanced",
        note: "Straight men and women are kept within one spot of each other.",
        wide: true,
      },
      {label: "Demand pricing", value: "Step ₹200 · Max ₹1,800", wide: true},
      {label: "Age range", value: "24 – 34"},
      {label: "Cancellation", value: "Flexible · 24h"},
    ],
  },
  {
    id: "guide",
    title: "Live event guide",
    sub: "Event Success defaults for the night",
    captureId: "host-create-guide",
    outcome: "Prepares the live run-of-show before guests arrive.",
    fields: [
      {label: "Playbook", value: "Dinner facilitation"},
      {label: "Welcome script", value: "On"},
      {label: "Timed partner rotations", value: "Every 25 min", wide: true},
      {label: "Wrap prompt", value: "Host help before guests leave", wide: true},
    ],
  },
];

export const eventSuccessStages = [
  {id: "before", label: "Before", sub: "Bookings build"},
  {id: "arrival", label: "Arrival", sub: "The door"},
  {id: "opening", label: "Opening", sub: "First 15 min"},
  {id: "mixing", label: "Mixing", sub: "Room in motion"},
  {id: "activity", label: "Activity", sub: "Rounds and reveals"},
  {id: "after", label: "After", sub: "Catch window"},
  {id: "debrief", label: "Debrief", sub: "Host report"},
];

export const eventSuccessModules = [
  {
    stage: "before",
    title: "Booking balance preview",
    attendee: "The room feels intentional instead of random.",
    host: "Shows waitlist, cohort, skill, and pace gaps before the event.",
  },
  {
    stage: "arrival",
    title: "Attendance and live roster",
    attendee: "Arrival is quick and the right people enter the loop.",
    host: "Confirms who actually attended before matching and reviews.",
  },
  {
    stage: "opening",
    title: "Welcome script",
    attendee: "The room gets clear social permission to talk.",
    host: "A simple live guide for non-professional hosts.",
  },
  {
    stage: "mixing",
    title: "Help me say hi",
    attendee: "Ask for help with a specific introduction, live.",
    host: "Only explicit, consented requests become introductions.",
  },
  {
    stage: "activity",
    title: "Timed partner rotations",
    attendee: "Everyone meets more people without doing the logistics.",
    host: "Predictable mixing for games, tables, and teams. No repeats.",
  },
  {
    stage: "activity",
    title: "Synchronized partner reveal",
    attendee: "The next assignment lands as a shared reveal.",
    host: "Countdowns, clues, and round-by-round reveal control.",
  },
  {
    stage: "after",
    title: "Suggested first-message openers",
    attendee: "A match starts with shared context instead of a cold hi.",
    host: "Better chat starts, zero host involvement.",
  },
  {
    stage: "debrief",
    title: "Host recap",
    attendee: "The next event feels better because this one taught us something.",
    host: "Check-in, mixing, catches, reviews, and repeats become advice.",
  },
];

export const hostComparisonRows = [
  ["Publish and ticket an event", "yes", "yes", "yes", "yes", "yes", "partial", "partial"],
  ["App or marketplace discovery", "yes", "partial", "yes", "yes", "yes", "partial", "no"],
  ["Admission rules and request-to-join", "yes", "partial", "partial", "partial", "partial", "partial", "partial"],
  ["Waitlists with timed offers", "yes", "partial", "partial", "partial", "partial", "no", "partial"],
  ["Balanced ratios and cohorts", "yes", "no", "no", "no", "no", "no", "partial"],
  ["Door check-in and live host console", "yes", "partial", "yes", "partial", "partial", "no", "partial"],
  ["Proof of real attendance", "yes", "partial", "partial", "partial", "partial", "no", "partial"],
  ["Private post-event matching", "yes", "no", "no", "no", "no", "no", "no"],
  ["Verified attendee reviews tied to organizer", "yes", "no", "no", "no", "no", "no", "no"],
  ["Public organizer reputation listing", "yes", "partial", "partial", "partial", "partial", "partial", "no"],
  ["Post-event host report", "yes", "partial", "yes", "partial", "partial", "no", "partial"],
];

export const hostComparisonColumns = [
  "Catch",
  "Luma",
  "Eventbrite",
  "District",
  "BookMyShow",
  "Instagram + WhatsApp",
  "Forms + sheets",
];

export const hostPreviewFormats = [
  "Social runs",
  "Dinners",
  "Singles mixers",
  "Game nights",
  "Pub quizzes",
  "Racket sports",
  "Walks",
  "Venue events",
  "Custom formats",
];

export const hostPreviewLoop = [
  {
    step: "Interest",
    title: "People discover the event",
    body: "Directory placement, organizer listings, invite links, and public event pages start demand in one place.",
  },
  {
    step: "Admission",
    title: "The host controls who gets in",
    body: "Open booking, invite-only, request-to-join, balanced cohorts, waitlists, and timed offers feed one roster.",
  },
  {
    step: "Attendance",
    title: "Check-in proves who showed up",
    body: "Ticketing, payment state, refund status, cancellation, and check-in stay attached to the attendee record.",
  },
  {
    step: "Live",
    title: "The room gets a run-of-show",
    body: "Prompts, rotations, assignments, overrides, and safety controls help the host guide the actual event.",
  },
  {
    step: "After",
    title: "Follow-up opens with context",
    body: "Guests privately catch people they met. Mutual catches become chats; hosts see aggregate reporting.",
  },
];

export const hostPreviewRosterStates = [
  "Requested",
  "Approved",
  "Paid",
  "Waitlisted",
  "Offer sent",
  "Checked in",
  "Refunded",
];

export const hostPreviewPaymentStates = [
  "Checkout started",
  "Payment pending",
  "Paid",
  "Cancelled",
  "Refunded",
  "Checked in",
];

export const hostPreviewTrustItems = [
  {
    title: "Attendance-gated reputation",
    body: "Reviews and post-event signals can be tied to real attendance instead of anonymous public noise.",
  },
  {
    title: "Private catch targets stay private",
    body: "Hosts see aggregate outcomes. They do not see who privately caught whom.",
  },
  {
    title: "Moderation and disputes are part of the workflow",
    body: "Reports, review disputes, cancellation handling, and refund paths sit beside the event record.",
  },
];

export const hostPreviewFaqs = [
  {
    question: "What does founding host access include?",
    answer:
      "Manual approval, 0% Catch platform fee for 24 months from your first published event, a public Founding Host badge, and increased visibility in Catch discovery.",
  },
  {
    question: "Are there any fees?",
    answer:
      "Catch charges founding hosts 0% platform fee during the 24-month founding period. Standard payment processor fees still apply, e.g. Stripe, Razorpay, etc.",
  },
  {
    question: "When does the 24-month lock start?",
    answer: "It starts when your first Catch event is published.",
  },
  {
    question: "What kinds of events can I host?",
    answer:
      "Runs, dinners, mixers, game nights, quizzes, racket sports, walks, venue events, and custom hosted social formats.",
  },
  {
    question: "Can I control who gets in?",
    answer:
      "Yes. Catch supports open booking, invite-only events, request-to-join, waitlists, timed offers, capacity rules, and balanced cohorts.",
  },
  {
    question: "Does Catch handle payments and refunds?",
    answer:
      "Yes. Payments, refunds, cancellations, and attendance are connected to the event roster.",
  },
];
