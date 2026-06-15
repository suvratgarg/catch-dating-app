import {type CSSProperties, FormEvent, MouseEvent, useEffect, useMemo, useRef, useState} from "react";
import {
  createMarketingEventId,
  getMarketingConsent,
  initializeMarketingAnalytics,
  setMarketingConsent,
  trackMarketingEvent,
  trackPageView,
  waitlistAnalyticsPayload,
} from "./analytics";
import {
  claimFirebaseConfigured,
  ClubClaimRole,
  createPublicClubReview,
  listPublicClubReviews,
  publicReviewsFirebaseConfigured,
  requestClubClaim,
  signInForClaim,
  signOutClaimUser,
  User,
  watchClaimAuthState,
} from "./firebase";
import {
  ActivityMark as CanonicalActivityMark,
  CaptureCard as CanonicalCaptureCard,
  EventActionCard,
  type EventActionCardModel,
  OwnerResponsePrompt,
  ProfileStrength as CanonicalProfileStrength,
  ProcessStatusPanel,
  ProductModuleGrid,
  PublicEventCard,
  type PublicEventCardModel,
  type PublicReviewCardModel,
  PublicSearchBar,
  type PublicSearchSuggestion,
  ReviewSignalLane,
  SectionHeader,
  SiteFooter as CanonicalSiteFooter,
  SiteHeader as CanonicalSiteHeader,
  StatusBadge as CanonicalStatusBadge,
} from "./components/site";
import hostListingsJson from "./generated/hostListings.json";

type PageKey = "home" | "host" | "organizers" | "listing" | "claim";
type FormVariant = "member" | "host";
type StatusTone = "" | "is-error" | "is-success";
type StorePlatform = "ios" | "android";
type OrganizerStatusFilter = "all" | "verified" | "claimed" | "unclaimed";
type OrganizerSort = "relevance" | "reviews" | "rating" | "upcoming" | "confidence";
type ClaimFlowStep = "listing" | "role" | "verify" | "submitted";
type ClaimUrlState = "alreadyClaimed" | "pendingClaim" | "notFound" | null;
type HostApplicationStep = "profile" | "event" | "policy" | "success" | "review";
interface OrganizerDirectoryFilters {
  query: string;
  statusFilter: OrganizerStatusFilter;
  formatFilter: string;
  cityFilter: string;
  upcomingOnly: boolean;
  minRating: number;
  sort: OrganizerSort;
}
interface OrganizerEventHighlight {
  id: string;
  title: string;
  kind: string;
  detail: string;
  href: string;
  activityToken: string;
}
type ClaimStatus = {
  message: string;
  tone: StatusTone;
};

const organizerStatusFilters: OrganizerStatusFilter[] = [
  "all",
  "verified",
  "claimed",
  "unclaimed",
];
const organizerSortOptions: OrganizerSort[] = [
  "relevance",
  "reviews",
  "rating",
  "upcoming",
  "confidence",
];

interface StoreCta {
  platform: StorePlatform;
  kicker: string;
  label: string;
  shortLabel: string;
  href: string;
}

interface ActivityMeta {
  label: string;
  token: string;
  short: string;
}

interface HostCreateStep {
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

interface ClaimVerificationMethod {
  id: "publicProof" | "email" | "phone";
  title: string;
  body: string;
}

interface HostApplicationDraft {
  fullName: string;
  email: string;
  city: string;
  customCity: string;
  organizationName: string;
  organizationType: string;
  communityLink: string;
  formats: string[];
  eventCadence: string;
  nextEventName: string;
  nextEventDate: string;
  eventLocation: string;
  expectedCapacity: string;
  priceRange: string;
  admissionModel: string;
  waitlistPlan: string;
  paymentReadiness: string;
  eventSuccessModules: string[];
  hostGoals: string;
  operatingNotes: string;
}

interface PageMeta {
  title: string;
  description: string;
  canonicalPath: string;
  twitterDescription: string;
  robots?: string;
}

interface CaptureRecord {
  id: string;
  webPath: string;
  alt: string;
  caption: string;
  walkthroughStep: string;
}

interface CaptureManifest {
  captures?: CaptureRecord[];
}

interface HostListingSource {
  type: string;
  label: string;
  detail: string;
  href?: string;
  confidence: "high" | "medium" | "low";
}

interface HostListingEventEvidence {
  title: string;
  date: string;
  location: string;
  summary: string;
  facts: string[];
  sourceLabel: string;
  sourceHref: string;
}

interface HostListingReview {
  id: string | null;
  reviewerName: string;
  rating: number;
  comment: string;
  createdAt: string;
  verificationStatus?: "verified" | "unverified";
  source?: "catchEvent" | "publicListing";
  isAnonymous?: boolean;
  ownerResponse: {
    hostName: string;
    hostAvatarUrl: string | null;
    message: string;
    updatedAt: string;
  } | null;
}

interface HostListingMetrics {
  memberCount?: number;
  rating?: number;
  reviewCount?: number;
  nextEventAt?: string | null;
  nextEventLabel?: string | null;
}

interface HostListingHost {
  name: string;
  role: string;
  avatarUrl: string | null;
}

interface HostListingCatchEvent {
  id: string;
  role: string;
  title: string;
  activityKind: string;
  timeline: "upcoming" | "past";
  startTime: string;
  endTime: string;
  date: string;
  location: string;
  summary: string;
  capacityLimit: number;
  bookedCount: number;
  checkedInCount: number;
  waitlistedCount: number;
  priceLabel: string;
  scorecard?: Record<string, unknown> | null;
}

interface HostListingEventSuccessSummary {
  bookedCount: number;
  checkedInCount: number;
  mutualMatchCount: number;
  chatStartedCount: number;
  catchSentCount: number;
  safetyIncidentCount: number;
}

interface HostListing {
  id: string;
  listingVariant?: "unclaimedScraped" | "appCreatedClub";
  dataOrigin?: "scrapedSeed" | "catchDemo";
  name: string;
  slug: string;
  city: string;
  citySlug: string;
  region: string;
  country: string;
  path: string;
  category: string;
  status: string;
  indexing: string;
  sourceConfidence: string;
  headline: string;
  description: string;
  sourceSummary: string;
  logo: {
    mode: "monogram";
    text: string;
    status: string;
  };
  formats: string[];
  facts: Array<{label: string; value: string}>;
  metrics?: HostListingMetrics;
  host?: HostListingHost;
  catchEvents?: HostListingCatchEvent[];
  eventSuccessSummary?: HostListingEventSuccessSummary | null;
  eventEvidence?: HostListingEventEvidence[];
  reviews?: HostListingReview[];
  fitNotes: string[];
  missingEvidence: string[];
  sources: HostListingSource[];
  claim: {
    href: string;
    label: string;
  };
  lastVerifiedAt: string;
  searchText?: string;
}

const hostListings = hostListingsJson as HostListing[];

const claimRoleOptions: Array<{value: ClubClaimRole; label: string}> = [
  {value: "owner", label: "Owner"},
  {value: "founder", label: "Founder"},
  {value: "manager", label: "Manager"},
  {value: "marketer", label: "Marketing"},
  {value: "venueManager", label: "Venue manager"},
  {value: "other", label: "Other"},
];

const claimFlowSteps: Array<{id: ClaimFlowStep; label: string}> = [
  {id: "listing", label: "Find listing"},
  {id: "role", label: "Your role"},
  {id: "verify", label: "Verify"},
  {id: "submitted", label: "Review"},
];

const claimVerificationMethods: ClaimVerificationMethod[] = [
  {
    id: "publicProof",
    title: "Public proof links",
    body: "Submit official sites, event pages, Instagram bios, Linktree, Luma, or venue pages that connect you to this organizer.",
  },
  {
    id: "email",
    title: "Official email",
    body: "Use a domain or booking address that appears publicly for the organizer or venue.",
  },
  {
    id: "phone",
    title: "Venue or business phone",
    body: "Use the publicly listed business phone so Catch can confirm the claim before owner tools unlock.",
  },
];

const hostApplicationSteps: Array<{id: HostApplicationStep; label: string; body: string}> = [
  {
    id: "profile",
    label: "Host profile",
    body: "Who you are, what you run, and where Catch should place the operating profile.",
  },
  {
    id: "event",
    label: "Event draft",
    body: "The first event you want to publish, with enough detail for a real setup review.",
  },
  {
    id: "policy",
    label: "Admission",
    body: "Capacity, pricing, approval, waitlists, and payment readiness.",
  },
  {
    id: "success",
    label: "Run of show",
    body: "Event Success modules you want live at the door, during the room, and after.",
  },
  {
    id: "review",
    label: "Submit",
    body: "Catch receives the operating packet, not just an email address.",
  },
];

const hostFormatOptions = [
  "Dinner",
  "Singles mixer",
  "Social run",
  "Padel or pickleball",
  "Pub quiz",
  "Bar crawl",
  "Community meetup",
  "Custom format",
];

const hostSuccessModuleOptions = [
  "Booking balance preview",
  "Attendance and live roster",
  "Welcome script",
  "Starter groups",
  "Timed partner rotations",
  "Host introduction help",
  "Private catch window",
  "Verified attendee reviews",
  "Post-event report",
];

const canonicalHeaderNav = [
  {href: "/#events", label: "Find events"},
  {href: "/organizers/", label: "Organizers"},
  {href: "/host/", label: "For hosts"},
];

const canonicalHeaderActions = [
  {href: "/claim/", label: "Claim a listing", variant: "secondary" as const},
  {href: "/host/#founding-hosts", label: "Host on Catch", variant: "primary" as const},
];

const initialHostApplicationDraft: HostApplicationDraft = {
  fullName: "",
  email: "",
  city: "Mumbai",
  customCity: "",
  organizationName: "",
  organizationType: "Independent host",
  communityLink: "",
  formats: ["Dinner"],
  eventCadence: "Monthly",
  nextEventName: "",
  nextEventDate: "",
  eventLocation: "",
  expectedCapacity: "20",
  priceRange: "₹1,000–₹2,000",
  admissionModel: "Request to join",
  waitlistPlan: "Ranked timed offers",
  paymentReadiness: "Need Catch payment onboarding",
  eventSuccessModules: [
    "Attendance and live roster",
    "Welcome script",
    "Private catch window",
  ],
  hostGoals: "",
  operatingNotes: "",
};

const pageMeta: Record<Exclude<PageKey, "listing">, PageMeta> = {
  home: {
    title: "Catch | The event before the match",
    description:
      "Catch turns curated singles events into real dating context. Choose a hosted event, show up, catch privately, and match with people you actually met.",
    canonicalPath: "/",
    twitterDescription: "Curated singles events become real dating context.",
  },
  host: {
    title: "Catch for Hosts | Host better singles events",
    description:
      "Catch helps hosts publish curated singles events, manage admission and waitlists, run live facilitation, and turn real attendance into post-event connections.",
    canonicalPath: "/host/",
    twitterDescription:
      "Event setup, admission, waitlists, live facilitation, check-in, and aggregate post-event reporting for hosts.",
  },
  organizers: {
    title: "Organizer Search | Catch",
    description:
      "Search Catch organizer profiles by name, city, format, and review signal.",
    canonicalPath: "/organizers/",
    twitterDescription: "Search Catch organizer and club profiles.",
    robots: "noindex, follow",
  },
  claim: {
    title: "Claim your organizer listing | Catch",
    description:
      "Find an unclaimed organizer profile, verify ownership, and request access to Catch host tools.",
    canonicalPath: "/claim/",
    twitterDescription: "Claim an organizer profile and unlock Catch host tools.",
    robots: "noindex, follow",
  },
};

const formatCards = [
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

const memberLoop = [
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

const hostLoop = [
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

const trustItems = [
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

const hostModules = [
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

const hostEvidenceMetrics = [
  {value: "64", label: "invite activity"},
  {value: "24", label: "demand signals"},
  {value: "17", label: "booked guests"},
  {value: "13", label: "checked in"},
  {value: "11", label: "caught someone"},
  {value: "18", label: "mutual matches"},
];

const hostSurfaceCards = [
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

const hostFillRoomModules = [
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

const hostProofRows = [
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

const cities = ["Mumbai", "Delhi", "Bangalore", "Pune", "Hyderabad", "Other"];
const storeCtas: StoreCta[] = [
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

const activityMeta: Record<string, ActivityMeta> = {
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
const publicEventSummaries = buildPublicEventSummaries(hostListings);
const publicSearchSuggestions = buildPublicSearchSuggestions(
  hostListings,
  publicEventSummaries
);

const claimUnlocks = [
  "Respond to public reviews",
  "Correct facts, formats, and contact details",
  "Add official photos and logo permission",
  "Publish Catch events with bookings and check-in",
  "Show verified attendee reviews",
  "See listing views, saves, and search appearance",
];

const hostCreateSteps: HostCreateStep[] = [
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

const eventSuccessStages = [
  {id: "before", label: "Before", sub: "Bookings build"},
  {id: "arrival", label: "Arrival", sub: "The door"},
  {id: "opening", label: "Opening", sub: "First 15 min"},
  {id: "mixing", label: "Mixing", sub: "Room in motion"},
  {id: "activity", label: "Activity", sub: "Rounds and reveals"},
  {id: "after", label: "After", sub: "Catch window"},
  {id: "debrief", label: "Debrief", sub: "Host report"},
];

const eventSuccessModules = [
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

const hostComparisonRows = [
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

const hostComparisonColumns = [
  "Catch",
  "Luma",
  "Eventbrite",
  "District",
  "BookMyShow",
  "Instagram + WhatsApp",
  "Forms + sheets",
];

const hostPreviewFormats = [
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

const hostPreviewLoop = [
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

const hostPreviewRosterStates = [
  "Requested",
  "Approved",
  "Paid",
  "Waitlisted",
  "Offer sent",
  "Checked in",
  "Refunded",
];

const hostPreviewPaymentStates = [
  "Checkout started",
  "Payment pending",
  "Paid",
  "Cancelled",
  "Refunded",
  "Checked in",
];

const hostPreviewTrustItems = [
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

const hostPreviewFaqs = [
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

function App() {
  const listing = getHostListingForPath(window.location.pathname);
  const fallbackPage = getPageKey();
  const page: PageKey = listing ? "listing" : fallbackPage;
  const isHostPreview = window.location.pathname.startsWith("/host/preview");
  const captures = useMarketingCaptures();
  const meta = listing ? pageMetaForListing(listing) : pageMeta[fallbackPage];
  const shellClassName = isHostPreview
    ? `${pageClassFor(page)} host-preview-page`
    : pageClassFor(page);

  useMarketingAnalytics(page);
  useDocumentMeta(meta);
  useRevealAnimations(page);
  useHashScroll(page);

  return (
    <div className={`page-shell ${shellClassName}`}>
      {listing ? (
        <HostListingPage listing={listing} />
      ) : isHostPreview ? (
        <HostPreviewPage captures={captures} />
      ) : page === "host" ? (
        <HostPage captures={captures} />
      ) : page === "organizers" ? (
        <OrganizerSearchPage />
      ) : page === "claim" ? (
        <ClaimPage />
      ) : (
        <HomePage captures={captures} />
      )}
      <MarketingConsentBanner />
    </div>
  );
}

function HomePage({captures}: {captures: Record<string, CaptureRecord>}) {
  return (
    <>
      <SiteHeader
        brandHref="#top"
        nav={[
          {href: "#events", label: "Events"},
          {href: "#formats", label: "Formats"},
          {href: "#members", label: "Members"},
          {href: "#hosts", label: "Hosts"},
          {href: "#trust", label: "Trust"},
          {href: "/organizers/", label: "Organizers"},
          {href: "/host/", label: "For hosts"},
        ]}
        ctaHref="#waitlist"
        ctaLabel="Join waitlist"
      />

      <main id="top">
        <section className="hero hero--home">
          <div className="hero__media" aria-hidden="true">
            <img
              src="/assets/marketing/catch-hero-event.png"
              alt=""
            />
          </div>

          <div className="hero__inner">
            <div className="hero__copy">
              <h1 data-reveal>Real events. Real hosts. The match comes after.</h1>
              <p className="hero__body" data-reveal>
                Find a hosted run, dinner, game night, or mixer near you. Show
                up in person, then catch privately with people you actually met.
              </p>
              <div className="hero__actions" data-reveal>
                <a
                  className="button"
                  href="/organizers/"
                  onClick={() => trackCtaClick("home_hero_browse_events", "/organizers/")}
                >
                  Browse organizers
                </a>
                <a
                  className="button button--ghost"
                  href="/host/"
                  onClick={() => trackCtaClick("home_hero_apply_host", "/host/")}
                >
                  Apply as host
                </a>
              </div>
              <AppDownloadCtas placement="home_hero" />
            </div>

            <aside className="hero-panel" aria-label="Catch event panel" data-reveal>
              <div className="event-ticket">
                <div>
                  <span className="ui-label">This week</span>
                  <h2>Events with a reason to talk</h2>
                </div>
                <span className="event-ticket__status">
                  Private catches open only after attendance
                </span>
              </div>
              <div className="event-ticket__meta">
                <span>Dinner</span>
                <span>Social run</span>
                <span>Host-led prompts</span>
                <span>Verified reviews</span>
              </div>
            </aside>
          </div>
        </section>

        <HomeDiscoverySection />

        <section className="format-band" id="formats" aria-labelledby="formats-title">
          <div className="section-heading" data-reveal>
            <h2 id="formats-title">Not another swipe feed. A better way to meet.</h2>
            <p>
              Catch is format-aware: every event can carry the right amount of
              structure, from light social flow to guided rotations and reveal
              moments.
            </p>
          </div>

          <div className="format-grid">
            {formatCards.map((card) => (
              <article className="format-card" data-reveal key={card.mark}>
                <span className="format-card__mark">{card.mark}</span>
                <h3>{card.title}</h3>
                <p>{card.body}</p>
              </article>
            ))}
          </div>
        </section>

        <FeaturedOrganizersSection />

        <section className="story-section" id="members" aria-labelledby="loop-title">
          <div className="section-heading section-heading--wide" data-reveal>
            <h2 id="loop-title">A dating loop built around showing up.</h2>
          </div>
          <LoopList items={memberLoop} />
        </section>

        <section className="proof-section" id="hosts">
          <div className="proof-section__copy" data-reveal>
            <h2>For hosts who care about the experience, not just the RSVP list.</h2>
            <p>
              Catch gives hosts the controls that make singles events safer, more
              balanced, and more memorable: admission rules, waitlists, cohort
              shaping, check-in, live facilitation, and aggregate reports.
            </p>
            <a
              className="button button--ghost-light"
              href="/host/"
              onClick={() => trackCtaClick("host_tools_section", "/host/")}
            >
              See host tools
            </a>
          </div>

          <HostProductBoard />
        </section>

        <section className="captures-section" aria-labelledby="app-proof-title">
          <div className="section-heading" data-reveal>
            <h2 id="app-proof-title">See the Catch loop in motion.</h2>
            <p>
              Browse the event, show up, catch privately, and let the shared
              experience carry the first conversation.
            </p>
          </div>

          <div className="capture-grid">
            <CaptureCard id="member-event-discovery" fallbackStep="Discover" captures={captures} />
            <CaptureCard id="post-run-catch-window" fallbackStep="Catch" captures={captures} />
            <CaptureCard id="host-live-console" fallbackStep="Host" captures={captures} />
          </div>
        </section>

        <section className="download-section" id="download-app" aria-labelledby="download-title">
          <div className="download-section__copy" data-reveal>
            <span className="ui-label">Member app</span>
            <h2 id="download-title">Download Catch when your city opens.</h2>
            <p>
              Store listings are not public yet. The buttons are in place now
              so launch traffic can move directly to the app once the listings
              are approved.
            </p>
          </div>
          <AppDownloadCtas placement="home_download_section" className="app-download-ctas--panel" />
        </section>

        <section className="trust-section" id="trust" aria-labelledby="trust-title">
          <div className="section-heading" data-reveal>
            <h2 id="trust-title">Designed for consent, context, and host control.</h2>
          </div>

          <div className="trust-grid">
            {trustItems.map((item) => (
              <article data-reveal key={item.title}>
                <h3>{item.title}</h3>
                <p>{item.body}</p>
              </article>
            ))}
          </div>
        </section>

        <section className="waitlist-section" id="waitlist" aria-labelledby="waitlist-title">
          <div className="waitlist__intro" data-reveal>
            <h2 id="waitlist-title">Be first in your city.</h2>
            <p>
              Join the member waitlist or apply as a founding host. We will reach
              out as city access opens.
            </p>
          </div>
          <WaitlistForm variant="member" />
        </section>
      </main>

      <SiteFooter
        brandHref="#top"
        body="Curated singles events. Real context. Better conversations."
        links={[
          {href: "/host/", label: "For hosts"},
          {href: "#formats", label: "Formats"},
          {href: "#download-app", label: "Download"},
          {href: "#trust", label: "Trust"},
          {href: "#waitlist", label: "Waitlist"},
        ]}
      />
    </>
  );
}

function HomeDiscoverySection() {
  const events = publicEventSummaries.slice(0, 3);
  return (
    <section className="home-discovery" id="events" aria-labelledby="home-events-title">
      <SectionHeader
        eyebrow="Find events"
        id="home-events-title"
        title="Start with what is happening, then choose who to meet."
        body="The public website now treats events and organizer pages as one discovery loop: search the city, browse a real host page, then continue into the app when the event opens."
        wide
      />
      <PublicSearchBar
        cityName={events[0]?.city ?? "Your city"}
        suggestions={publicSearchSuggestions}
      />
      <div className="public-event-grid">
        {events.length ? (
          events.map((event) => <PublicEventCard event={event} key={event.id} />)
        ) : (
          <div className="public-event-empty" data-reveal>
            <strong>No public Catch events are projected yet.</strong>
            <p>
              Browse organizer pages while event projections are added to the
              public website feed.
            </p>
            <a className="button button--ghost" href="/organizers/">
              Open organizer directory
            </a>
          </div>
        )}
      </div>
    </section>
  );
}

function FeaturedOrganizersSection() {
  const featured = hostListings
    .slice()
    .sort((a, b) => listingProfileStrength(b) - listingProfileStrength(a))
    .slice(0, 3);

  return (
    <section className="featured-organizers" aria-labelledby="featured-organizers-title">
      <div className="section-heading" data-reveal>
        <span className="ui-label">Organizer directory</span>
        <h2 id="featured-organizers-title">The public loop starts with real host pages.</h2>
        <p>
          Searchable organizer profiles create a concrete path from discovery to
          claim, reviews, host tools, events, and app usage.
        </p>
      </div>
      <div className="featured-organizers__grid">
        {featured.map((listing) => (
          <OrganizerMiniCard listing={listing} key={listing.id} />
        ))}
      </div>
      <div className="featured-organizers__cta" data-reveal>
        <p>
          Run events? Your profile can show public sources today, then verified
          Catch activity after you claim and publish.
        </p>
        <a
          className="button button--ghost-light"
          href="/organizers/"
          onClick={() => trackCtaClick("home_featured_organizers", "/organizers/")}
        >
          Open directory
        </a>
      </div>
    </section>
  );
}

function OrganizerMiniCard({listing}: {listing: HostListing}) {
  const activity = activityForListing(listing);
  return (
    <a
      className="organizer-mini-card"
      href={listing.path}
      data-reveal
      style={{"--activity": activity.token} as CSSProperties}
      onClick={() => trackCtaClick("featured_organizer", listing.path)}
    >
      <ActivityMark listing={listing} />
      <div>
        <StatusBadge listing={listing} compact />
        <h3>{listing.name}</h3>
        <p>{listing.category} · {listing.city}</p>
      </div>
      <ProfileStrength value={listingProfileStrength(listing)} />
    </a>
  );
}

function ActivityMark({
  listing,
  size = "md",
}: {
  listing: HostListing;
  size?: "sm" | "md" | "lg";
}) {
  return <CanonicalActivityMark listing={listing} activity={activityForListing(listing)} size={size} />;
}

function StatusBadge({
  listing,
  compact = false,
}: {
  listing: HostListing;
  compact?: boolean;
}) {
  return (
    <CanonicalStatusBadge
      status={listing.status}
      isVerified={isVerifiedListing(listing)}
      compact={compact}
    />
  );
}

function ProfileStrength({value}: {value: number}) {
  return <CanonicalProfileStrength value={value} />;
}

function AppDownloadCtas({
  placement,
  className,
  initialStatus = "App Store and Play Store links are coming soon.",
}: {
  placement: string;
  className?: string;
  initialStatus?: string;
}) {
  const [status, setStatus] = useState(initialStatus);
  const statusId = `${placement}-store-status`;
  const rootClassName = ["app-download-ctas", className].filter(Boolean).join(" ");

  function handlePendingStoreClick(store: StoreCta) {
    setStatus(
      `${store.label} is not live yet. Join the waitlist and we will send the link when it opens.`
    );
    trackMarketingEvent("store_cta_pending", {
      platform: store.platform,
      placement,
      page_path: `${window.location.pathname}${window.location.search}`,
    });
  }

  function handleStoreLinkClick(store: StoreCta) {
    trackCtaClick(`store_${placement}_${store.platform}`, store.href);
    trackMarketingEvent("store_cta_click", {
      platform: store.platform,
      placement,
      store_href: store.href,
      page_path: `${window.location.pathname}${window.location.search}`,
    });
  }

  return (
    <div className={rootClassName} data-reveal>
      <div className="app-download-ctas__buttons">
        {storeCtas.map((store) => (
          <StoreButton
            key={store.platform}
            store={store}
            statusId={statusId}
            onPendingClick={handlePendingStoreClick}
            onStoreLinkClick={handleStoreLinkClick}
          />
        ))}
      </div>
      <p className="app-download-ctas__status" id={statusId} role="status" aria-live="polite">
        {status}
      </p>
    </div>
  );
}

function StoreButton({
  store,
  statusId,
  onPendingClick,
  onStoreLinkClick,
}: {
  store: StoreCta;
  statusId: string;
  onPendingClick: (store: StoreCta) => void;
  onStoreLinkClick: (store: StoreCta) => void;
}) {
  const content = (
    <>
      <span className="store-button__mark" aria-hidden="true">
        {store.platform === "ios" ? <AppleStoreMark /> : <GooglePlayStoreMark />}
      </span>
      <span>
        <span className="store-button__kicker">{store.kicker}</span>
        <strong>{store.label}</strong>
      </span>
    </>
  );

  if (!store.href) {
    return (
      <button
        className="store-button is-pending"
        type="button"
        aria-describedby={statusId}
        onClick={() => onPendingClick(store)}
      >
        {content}
      </button>
    );
  }

  return (
    <a
      className="store-button"
      href={store.href}
      target="_blank"
      rel="noreferrer"
      onClick={(event: MouseEvent<HTMLAnchorElement>) => {
        if (!store.href) {
          event.preventDefault();
          onPendingClick(store);
          return;
        }
        onStoreLinkClick(store);
      }}
    >
      {content}
    </a>
  );
}

function AppleStoreMark() {
  return (
    <svg viewBox="0 0 24 24" role="img" focusable="false" aria-hidden="true">
      <path
        d="M16.48 12.74c.02-2.14 1.72-3.16 1.8-3.2-1.02-1.5-2.58-1.7-3.12-1.72-1.32-.14-2.6.78-3.27.78-.69 0-1.72-.76-2.83-.74-1.44.02-2.78.85-3.52 2.15-1.52 2.63-.39 6.5 1.07 8.63.73 1.04 1.58 2.2 2.7 2.16 1.09-.04 1.5-.69 2.82-.69 1.31 0 1.69.69 2.84.67 1.18-.02 1.92-1.05 2.62-2.1.84-1.2 1.17-2.39 1.18-2.45-.03-.01-2.26-.87-2.29-3.49Zm-2.18-6.32c.59-.74.99-1.74.88-2.76-.85.04-1.9.59-2.51 1.3-.55.64-1.04 1.68-.91 2.66.96.08 1.93-.48 2.54-1.2Z"
        fill="currentColor"
      />
    </svg>
  );
}

function GooglePlayStoreMark() {
  return (
    <svg viewBox="0 0 24 24" role="img" focusable="false" aria-hidden="true">
      <path
        d="M4.5 3.7c-.26.28-.42.72-.42 1.28v14.04c0 .56.16 1 .42 1.28l7.7-8.3-7.7-8.3Z"
        fill="currentColor"
        opacity="0.86"
      />
      <path
        d="m14.84 9.15-2.64 2.84 2.64 2.85 3.26-1.85c1.09-.62 1.09-1.36 0-1.98l-3.26-1.86Z"
        fill="currentColor"
      />
      <path
        d="m14.84 9.15-3.07-1.74-5.1-2.9 5.53 7.48 2.64-2.84Z"
        fill="currentColor"
        opacity="0.68"
      />
      <path
        d="m6.67 19.49 5.1-2.9 3.07-1.75-2.64-2.85-5.53 7.5Z"
        fill="currentColor"
        opacity="0.68"
      />
    </svg>
  );
}

function HostPreviewPage({captures}: {captures: Record<string, CaptureRecord>}) {
  return (
    <>
      <SiteHeader
        brandHref="/"
        nav={[
          {href: "#offer", label: "Offer"},
          {href: "#formats", label: "Formats"},
          {href: "#operating-loop", label: "Workflow"},
          {href: "#create-flow", label: "Create flow"},
          {href: "#founding-hosts", label: "Apply"},
        ]}
        ctaHref="#founding-hosts"
        ctaLabel="Apply for founding host access"
      />

      <main id="top" className="host-preview">
        <section className="host-preview-hero" aria-labelledby="host-preview-title">
          <div className="host-preview-hero__media" aria-hidden="true">
            <img
              src="/assets/marketing/catch-hero-event.png"
              alt=""
            />
          </div>
          <div className="host-preview-hero__inner">
            <div className="host-preview-hero__copy">
              <h1 id="host-preview-title" data-reveal>
                Host social events people actually want to join.
              </h1>
              <p data-reveal>
                Catch gives hosts one place to publish events, manage admission,
                take payment, run the room, and turn attendance into private
                follow-up.
              </p>
              <div className="hero__actions" data-reveal>
                <a
                  className="button"
                  href="#founding-hosts"
                  onClick={() => trackCtaClick("host_preview_apply", "#founding-hosts")}
                >
                  Apply for founding host access
                </a>
                <a
                  className="button button--ghost"
                  href="#operating-loop"
                  onClick={() => trackCtaClick("host_preview_workflow", "#operating-loop")}
                >
                  See how Catch works
                </a>
              </div>
              <AppDownloadCtas
                placement="host_preview_hero"
                className="app-download-ctas--compact host-preview-hero__stores"
                initialStatus="Download Catch on iOS or Android at launch."
              />
            </div>

            <div className="host-preview-hero__product" data-reveal>
              <div className="host-preview-console">
                <div>
                  <span>Host console</span>
                  <strong>Sunday Table Club</strong>
                </div>
                <dl>
                  <div>
                    <dt>Admission</dt>
                    <dd>Balanced request-to-join</dd>
                  </div>
                  <div>
                    <dt>Roster</dt>
                    <dd>Paid · waitlist · checked in</dd>
                  </div>
                  <div>
                    <dt>After</dt>
                    <dd>Reviews · catches · report</dd>
                  </div>
                </dl>
              </div>
              <PhoneCaptureFrame
                id="host-live-console"
                fallbackStep="Live console"
                captures={captures}
              />
            </div>
          </div>
        </section>

        <section className="host-preview-offer" id="offer" aria-labelledby="host-preview-offer-title">
          <div className="host-preview-offer__card" data-reveal>
            <div>
              <h2 id="host-preview-offer-title">
                Founding hosts pay 0% Catch platform fee for 24 months.
              </h2>
              <p>
                Apply for manual approval. Your 24-month lock starts when your
                first Catch event goes live. Standard payment processor fees
                still apply, e.g. Stripe, Razorpay, etc.
              </p>
            </div>
            <div className="host-preview-badge" aria-label="Founding Host badge preview">
              <span>Founding</span>
              <strong>Host</strong>
            </div>
          </div>
          <div className="host-preview-offer__steps" data-reveal>
            {["Apply", "Get approved", "Publish first event", "Lock begins"].map((item, index) => (
              <div key={item}>
                <span>0{index + 1}</span>
                <strong>{item}</strong>
              </div>
            ))}
          </div>
        </section>

        <section className="host-preview-section" id="formats" aria-labelledby="host-preview-formats-title">
          <div className="host-preview-section__head" data-reveal>
            <h2 id="host-preview-formats-title">Built for hosted rooms, not one event type.</h2>
            <p>
              Catch is for the organizer who cares about the guest mix, the door,
              the flow of the night, and what happens after people meet.
            </p>
          </div>
          <div className="host-preview-format-rail" data-reveal>
            {hostPreviewFormats.map((format) => (
              <span key={format}>{format}</span>
            ))}
          </div>
        </section>

        <HostComparisonSection />

        <section
          className="host-preview-section host-preview-loop"
          id="operating-loop"
          aria-labelledby="host-preview-loop-title"
        >
          <div className="host-preview-section__head" data-reveal>
            <h2 id="host-preview-loop-title">One event record, from interest to follow-up.</h2>
            <p>
              Ticketing, waitlist movement, check-in, live facilitation, reviews,
              catches, matches, and reports stay connected to the same event.
            </p>
          </div>
          <div className="host-preview-loop__grid">
            {hostPreviewLoop.map((item, index) => (
              <article data-reveal key={item.step}>
                <span>0{index + 1}</span>
                <div>
                  <strong>{item.step}</strong>
                  <h3>{item.title}</h3>
                  <p>{item.body}</p>
                </div>
              </article>
            ))}
          </div>
        </section>

        <div id="create-flow">
          <CreateEventWalkthrough captures={captures} />
        </div>

        <section className="host-preview-section host-preview-product-split" id="admission" aria-labelledby="host-preview-admission-title">
          <div className="host-preview-product-split__copy" data-reveal>
            <h2 id="host-preview-admission-title">Shape demand before the room fills.</h2>
            <p>
              Use open booking, invite-only access, request-to-join, balanced
              cohorts, capacity rules, and timed waitlist offers without moving
              between forms, DMs, and spreadsheets.
            </p>
            <div className="host-preview-chip-row" aria-label="Roster states">
              {hostPreviewRosterStates.map((state) => (
                <span key={state}>{state}</span>
              ))}
            </div>
          </div>
          <div className="host-preview-roster" data-reveal>
            {[
              ["Maya", "Approved", "Paid"],
              ["Rohan", "Requested", "Balanced wait"],
              ["Ira", "Checked in", "Review eligible"],
              ["Kabir", "Offer sent", "Expires 18:00"],
              ["Naina", "Refunded", "Cancelled"],
            ].map(([name, status, note]) => (
              <div key={name}>
                <strong>{name}</strong>
                <span>{status}</span>
                <small>{note}</small>
              </div>
            ))}
          </div>
        </section>

        <section className="host-preview-section host-preview-payments" aria-labelledby="host-preview-payments-title">
          <div className="host-preview-section__head" data-reveal>
            <h2 id="host-preview-payments-title">Ticketing, refunds, and check-in stay connected.</h2>
            <p>
              Catch keeps checkout, payment state, cancellation, refund status,
              and attendance on the same roster, so hosts are not reconciling
              guests across separate tools.
            </p>
          </div>
          <div className="host-preview-payment-flow" data-reveal>
            {hostPreviewPaymentStates.map((state) => (
              <span key={state}>{state}</span>
            ))}
          </div>
        </section>

        <section className="host-preview-section host-preview-live" id="live" aria-labelledby="host-preview-live-title">
          <div className="host-preview-section__head" data-reveal>
            <h2 id="host-preview-live-title">Run the event from the host screen.</h2>
            <p>
              Check guests in, follow prompts, manage rotations, make overrides,
              and keep safety controls close while the event is happening.
            </p>
          </div>
          <div className="host-preview-live__grid">
            <CaptureCard id="host-live-console" fallbackStep="Live" captures={captures} />
            <div className="host-preview-live__modules" data-reveal>
              {["Check-in", "Welcome script", "Prompt", "Rotation", "Override", "Safety"].map((module) => (
                <span key={module}>{module}</span>
              ))}
            </div>
          </div>
        </section>

        <section className="host-preview-section host-preview-after" aria-labelledby="host-preview-after-title">
          <div className="host-preview-section__head" data-reveal>
            <h2 id="host-preview-after-title">Follow-up starts after attendance.</h2>
            <p>
              Guests can privately catch people they actually met. Mutual catches
              become chats with shared event context. Hosts see aggregate signals,
              not private interest.
            </p>
          </div>
          <div className="capture-grid capture-grid--host">
            <CaptureCard id="post-run-catch-window" fallbackStep="Catch window" captures={captures} />
            <CaptureCard id="match-chat-context" fallbackStep="Match chat" captures={captures} />
            <CaptureCard id="host-post-event-report" fallbackStep="Report" captures={captures} />
          </div>
        </section>

        <section className="host-preview-section host-preview-trust" aria-labelledby="host-preview-trust-title">
          <div className="host-preview-section__head" data-reveal>
            <h2 id="host-preview-trust-title">Guardrails are part of the product.</h2>
            <p>
              The page should answer operational concerns before a host reaches
              the application form.
            </p>
          </div>
          <div className="host-preview-trust__grid">
            {hostPreviewTrustItems.map((item) => (
              <article data-reveal key={item.title}>
                <h3>{item.title}</h3>
                <p>{item.body}</p>
              </article>
            ))}
          </div>
        </section>

        <section className="host-preview-section host-preview-faq" aria-labelledby="host-preview-faq-title">
          <div className="host-preview-section__head" data-reveal>
            <h2 id="host-preview-faq-title">Questions hosts ask before switching tools.</h2>
          </div>
          <div className="host-preview-faq__list">
            {hostPreviewFaqs.map((item) => (
              <details key={item.question} data-reveal>
                <summary>{item.question}</summary>
                <p>{item.answer}</p>
              </details>
            ))}
          </div>
        </section>

        <section
          className="waitlist-section host-preview-apply"
          id="founding-hosts"
          aria-labelledby="host-preview-apply-title"
        >
          <div className="waitlist__intro" data-reveal>
            <h2 id="host-preview-apply-title">Apply once. Publish when approved.</h2>
            <p>
              Approved founding hosts get the public badge, increased discovery
              visibility, and the 24-month platform-fee lock when their first
              Catch event goes live.
            </p>
          </div>
          <HostApplicationFlow />
        </section>
      </main>

      <SiteFooter
        brandHref="/"
        body="Host-led social events with admission, payments, live facilitation, matching, and insight."
        links={[
          {href: "/host/", label: "Current host page"},
          {href: "#offer", label: "Founding offer"},
          {href: "#create-flow", label: "Create flow"},
          {href: "#founding-hosts", label: "Apply"},
        ]}
      />
    </>
  );
}

function HostPage({captures}: {captures: Record<string, CaptureRecord>}) {
  return (
    <>
      <SiteHeader
        brandHref="/"
        nav={[
          {href: "#workflow", label: "Workflow"},
          {href: "#fill-room", label: "Fill room"},
          {href: "#live", label: "Live mode"},
          {href: "#screens", label: "Screens"},
          {href: "/organizers/", label: "Organizers"},
          {href: "/", label: "Member site"},
        ]}
        ctaHref="#founding-hosts"
        ctaLabel="Apply as host"
      />

      <main id="top">
        <section className="host-hero">
          <div className="host-hero__inner">
            <div className="host-hero__copy">
              <h1 data-reveal>Run singles events people actually follow through on.</h1>
              <p data-reveal>
                Catch handles the loop around your event: booking logic,
                admission, waitlists, live facilitation, check-in, private
                catches, and the post-event report that shows what actually
                happened.
              </p>
              <div className="hero__actions" data-reveal>
                <a
                  className="button"
                  href="#founding-hosts"
                  onClick={() => trackCtaClick("host_hero_apply", "#founding-hosts")}
                >
                  Apply as host
                </a>
                <a
                  className="button button--ghost"
                  href="#workflow"
                  onClick={() => trackCtaClick("host_hero_workflow", "#workflow")}
                >
                  See workflow
                </a>
              </div>
            </div>

            <div className="host-console" aria-label="Host console" data-reveal>
              <div className="host-console__top">
                <span>Host console</span>
                <strong>West Village mixer</strong>
              </div>
              <div className="host-console__grid">
                <div>
                  <span className="ui-label">Admission</span>
                  <strong>Requests + invite links</strong>
                </div>
                <div>
                  <span className="ui-label">Live moment</span>
                  <strong>Balanced rotations</strong>
                </div>
                <div>
                  <span className="ui-label">After event</span>
                  <strong>18 mutual matches</strong>
                </div>
              </div>
              <div className="host-console__timeline">
                {hostEvidenceMetrics.map((metric) => (
                  <span key={metric.label}>
                    <strong>{metric.value}</strong>
                    {metric.label}
                  </span>
                ))}
              </div>
            </div>
          </div>
        </section>

        <section
          className="host-evidence"
          aria-labelledby="host-evidence-title"
        >
          <div className="section-heading" data-reveal>
            <span className="ui-label">What a host can see</span>
            <h2 id="host-evidence-title">
              Catch shows the path from interest to attendance to follow-up.
            </h2>
            <p>
              Catch answers more than "who RSVP'd?" It shows where demand came
              from, where people dropped off, and whether the event created real
              connection afterward.
            </p>
          </div>
          <div className="evidence-strip" data-reveal>
            {hostEvidenceMetrics.map((metric) => (
              <div key={metric.label}>
                <strong>{metric.value}</strong>
                <span>{metric.label}</span>
              </div>
            ))}
          </div>
        </section>

        <section className="story-section" id="workflow" aria-labelledby="workflow-title">
          <div className="section-heading" data-reveal>
            <h2 id="workflow-title">One loop, from booking to connection.</h2>
            <p>
              Replace forms, payment links, spreadsheets, group chats, manual
              intros, and safety notes with one flow built around the event.
            </p>
          </div>
          <LoopList items={hostLoop} modifier="loop-list--host" />
        </section>

        <CreateEventWalkthrough captures={captures} />

        <section
          className="surface-section"
          aria-labelledby="surface-title"
        >
          <div className="section-heading section-heading--wide" data-reveal>
            <span className="ui-label">What Catch handles</span>
            <h2 id="surface-title">
              The platform is not just ticketing, and it is not just matching.
            </h2>
          </div>
          <div className="surface-grid">
            {hostSurfaceCards.map((item) => (
              <article data-reveal key={item.label}>
                <span>{item.label}</span>
                <h3>{item.title}</h3>
                <p>{item.body}</p>
              </article>
            ))}
          </div>
        </section>

        <section className="host-fill-room" id="fill-room" aria-labelledby="fill-room-title">
          <SectionHeader
            eyebrow="Fill the room"
            id="fill-room-title"
            title="Checkout, waitlist, and cohort controls belong in the same roster."
            body="The mockup split these into concrete host promises. In production they should stay connected to the event record instead of becoming separate ticketing, spreadsheet, or DM workflows."
            wide
          />
          <ProductModuleGrid modules={hostFillRoomModules} />
        </section>

        <section className="proof-section proof-section--host" id="live">
          <div className="proof-section__copy" data-reveal>
            <span className="ui-label">Event Success</span>
            <h2>Live facilitation is built into the event flow.</h2>
            <p>
              The live catalog is explicit: booking balance preview, attendance
              and roster, welcome scripts, prompts, assignments, rotations,
              private catches, feedback, and aggregate host reports.
            </p>
          </div>

          <div className="module-stack" data-reveal>
            {hostModules.map((item) => (
              <article key={item.label}>
                <span>{item.label}</span>
                <strong>{item.title}</strong>
                <p>{item.body}</p>
              </article>
            ))}
          </div>
        </section>

        <EventSuccessShowcase captures={captures} />

        <section
          className="proof-ledger"
          aria-labelledby="proof-ledger-title"
        >
          <div className="section-heading" data-reveal>
            <span className="ui-label">Host confidence</span>
            <h2 id="proof-ledger-title">Run the whole event loop from one place.</h2>
            <p>
              Catch gives hosts the controls to shape demand, guide the live
              experience, and understand what happened after people met.
            </p>
          </div>
          <div className="proof-ledger__rows">
            {hostProofRows.map((item) => (
              <article data-reveal key={item.label}>
                <strong>{item.label}</strong>
                <p>{item.proof}</p>
              </article>
            ))}
          </div>
        </section>

        <HostComparisonSection />

        <section className="captures-section" id="screens" aria-labelledby="screens-title">
          <div className="section-heading" data-reveal>
            <span className="ui-label">Host tools</span>
            <h2 id="screens-title">See the host workflow end to end.</h2>
            <p>
              Set up the event, manage the live moment, and review the signals
              that help the next event get better.
            </p>
          </div>

          <div className="capture-grid capture-grid--host">
            <CaptureCard id="host-event-setup" fallbackStep="Setup" captures={captures} />
            <CaptureCard id="host-live-console" fallbackStep="Live" captures={captures} />
            <CaptureCard id="host-post-event-report" fallbackStep="Report" captures={captures} />
          </div>
        </section>

        <section
          className="waitlist-section"
          id="founding-hosts"
          aria-labelledby="host-apply-title"
        >
          <div className="waitlist__intro" data-reveal>
            <h2 id="host-apply-title">
              Bring the format. Catch handles the loop around it.
            </h2>
            <p>
              Apply as a founding host if you run events, communities, venues, or
              formats where the right singles can meet with more context.
            </p>
          </div>
          <HostApplicationFlow />
        </section>
      </main>

      <SiteFooter
        brandHref="/"
        body="Host-led singles events with booking, facilitation, matching, and insight."
        links={[
          {href: "/", label: "Member site"},
          {href: "#workflow", label: "Workflow"},
          {href: "#live", label: "Live mode"},
          {href: "#founding-hosts", label: "Apply"},
        ]}
      />
    </>
  );
}

function OrganizerSearchPage() {
  const cityOptions = useMemo(
    () => [...new Set(hostListings.map((listing) => listing.city))].sort(),
    []
  );
  const formatOptions = useMemo(
    () => [...new Set(hostListings.flatMap((listing) => listing.formats))].sort(),
    []
  );
  const initialFilters = useMemo(
    () => readOrganizerFiltersFromUrl(cityOptions, formatOptions),
    [cityOptions, formatOptions]
  );
  const [query, setQuery] = useState(initialFilters.query);
  const [statusFilter, setStatusFilter] =
    useState<OrganizerStatusFilter>(initialFilters.statusFilter);
  const [formatFilter, setFormatFilter] = useState(initialFilters.formatFilter);
  const [cityFilter, setCityFilter] = useState(initialFilters.cityFilter);
  const [upcomingOnly, setUpcomingOnly] = useState(initialFilters.upcomingOnly);
  const [minRating, setMinRating] = useState(initialFilters.minRating);
  const [sort, setSort] = useState<OrganizerSort>(initialFilters.sort);
  const normalizedQuery = query.trim().toLowerCase();
  const queryTerms = useMemo(
    () => normalizedQuery.split(/\s+/).filter(Boolean),
    [normalizedQuery]
  );
  const currentFilters: OrganizerDirectoryFilters = {
    query,
    statusFilter,
    formatFilter,
    cityFilter,
    upcomingOnly,
    minRating,
    sort,
  };

  useEffect(() => {
    const syncFromUrl = () => {
      const next = readOrganizerFiltersFromUrl(cityOptions, formatOptions);
      setQuery(next.query);
      setStatusFilter(next.statusFilter);
      setFormatFilter(next.formatFilter);
      setCityFilter(next.cityFilter);
      setUpcomingOnly(next.upcomingOnly);
      setMinRating(next.minRating);
      setSort(next.sort);
    };
    window.addEventListener("popstate", syncFromUrl);
    return () => window.removeEventListener("popstate", syncFromUrl);
  }, [cityOptions, formatOptions]);

  useEffect(() => {
    replaceOrganizerDirectoryUrl(currentFilters);
  }, [cityFilter, formatFilter, minRating, query, sort, statusFilter, upcomingOnly]);

  const results = useMemo(() => {
    const filtered = hostListings.filter((listing) => {
      const haystack = organizerDirectorySearchText(listing);
      if (queryTerms.length && !queryTerms.every((term) => haystack.includes(term))) return false;
      if (statusFilter === "verified" && !isVerifiedListing(listing)) return false;
      if (statusFilter === "claimed" && listing.status !== "claimed") return false;
      if (statusFilter === "unclaimed" && !isUnclaimedListing(listing)) return false;
      if (formatFilter !== "all" && !listing.formats.includes(formatFilter)) return false;
      if (cityFilter !== "all" && listing.city !== cityFilter) return false;
      if (upcomingOnly && !hasUpcomingCatchEvent(listing)) return false;
      if (minRating > 0 && (listing.metrics?.rating ?? 0) < minRating) return false;
      return true;
    });
    return filtered.slice().sort((a, b) => compareListings(a, b, sort));
  }, [cityFilter, formatFilter, minRating, queryTerms, sort, statusFilter, upcomingOnly]);
  const verifiedCount = hostListings.filter(isVerifiedListing).length;
  const unclaimedCount = hostListings.filter(isUnclaimedListing).length;
  const eventBackedCount = hostListings.filter(hasAnyEventSignal).length;
  const claimableListings = hostListings.filter(isUnclaimedListing).slice(0, 3);

  function handleSearch(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();
    replaceOrganizerDirectoryUrl(currentFilters);
    trackMarketingEvent("organizer_search_submitted", {
      query: normalizedQuery,
      result_count: results.length,
      city_filter: cityFilter,
      format_filter: formatFilter,
      status_filter: statusFilter,
      upcoming_only: upcomingOnly,
      min_rating: minRating,
      sort,
    });
  }

  function clearFilters() {
    setQuery("");
    setStatusFilter("all");
    setFormatFilter("all");
    setCityFilter("all");
    setUpcomingOnly(false);
    setMinRating(0);
    setSort("relevance");
    replaceOrganizerDirectoryUrl(defaultOrganizerDirectoryFilters());
    trackMarketingEvent("organizer_search_filters_cleared", {});
  }

  return (
    <>
      <SiteHeader
        brandHref="/"
        nav={[
          {href: "/host/", label: "For hosts"},
          {href: "/", label: "Member site"},
        ]}
        ctaHref="/host/#founding-hosts"
        ctaLabel="Apply as host"
      />

      <main id="top">
        <section className="organizer-search-hero" aria-labelledby="organizer-search-title">
          <div className="section-heading section-heading--wide" data-reveal>
            <span className="ui-label">Organizer search</span>
            <h1 id="organizer-search-title">Every club, host, and venue running real events.</h1>
            <p>
              Search source-backed seed listings and Catch-created clubs by
              name, city, format, reviews, upcoming events, and claim state.
            </p>
          </div>
          <div className="organizer-search-stats" data-reveal>
            <span><strong>{hostListings.length}</strong> profiles tracked</span>
            <span><strong>{verifiedCount}</strong> verified on Catch</span>
            <span><strong>{unclaimedCount}</strong> claimable seed pages</span>
            <span><strong>{eventBackedCount}</strong> event-backed pages</span>
          </div>
          <form className="organizer-search-form" onSubmit={handleSearch} data-reveal>
            <label>
              Search organizers
              <input
                name="q"
                value={query}
                onChange={(event) => setQuery(event.target.value)}
                placeholder="Try Sunday Table, Indore, run club, dinner"
              />
            </label>
            <button className="button" type="submit">Search</button>
          </form>
          <div className="organizer-filter-rail" data-reveal>
            <label>
              Status
              <select
                name="status"
                value={statusFilter}
                onChange={(event) => setStatusFilter(event.target.value as OrganizerStatusFilter)}
              >
                <option value="all">Any status</option>
                <option value="verified">Verified on Catch</option>
                <option value="claimed">Claimed</option>
                <option value="unclaimed">Unclaimed</option>
              </select>
            </label>
            <label>
              City
              <select name="city" value={cityFilter} onChange={(event) => setCityFilter(event.target.value)}>
                <option value="all">Any city</option>
                {cityOptions.map((city) => <option key={city}>{city}</option>)}
              </select>
            </label>
            <label>
              Format
              <select name="format" value={formatFilter} onChange={(event) => setFormatFilter(event.target.value)}>
                <option value="all">Any format</option>
                {formatOptions.map((format) => <option key={format}>{format}</option>)}
              </select>
            </label>
            <label>
              Rating
              <select name="rating" value={minRating} onChange={(event) => setMinRating(Number(event.target.value))}>
                <option value={0}>Any rating</option>
                <option value={4}>4.0+</option>
                <option value={4.5}>4.5+</option>
              </select>
            </label>
            <button
              className={`filter-chip-button ${upcomingOnly ? "is-on" : ""}`}
              type="button"
              aria-pressed={upcomingOnly}
              onClick={() => setUpcomingOnly((current) => !current)}
            >
              Has upcoming events
            </button>
            <label>
              Sort
              <select name="sort" value={sort} onChange={(event) => setSort(event.target.value as OrganizerSort)}>
                <option value="relevance">Relevance</option>
                <option value="reviews">Most reviewed</option>
                <option value="rating">Rating</option>
                <option value="upcoming">Upcoming first</option>
                <option value="confidence">Source confidence</option>
              </select>
            </label>
          </div>
          <div className="organizer-result-summary" data-reveal>
            <p>
              {results.length} {results.length === 1 ? "profile" : "profiles"}
              {normalizedQuery ? ` for "${query.trim()}"` : ""}
            </p>
            <button className="see-all-button" type="button" onClick={clearFilters}>
              Clear filters
            </button>
          </div>
        </section>

        <DirectoryClaimPressureStrip
          claimableListings={claimableListings}
          eventBackedCount={eventBackedCount}
          unclaimedCount={unclaimedCount}
        />

        <section className="organizer-results" aria-label="Organizer results">
          {results.length ? (
            results.map((listing) => (
              <OrganizerResultCard
                listing={listing}
                key={listing.id}
                queryTerms={queryTerms}
              />
            ))
          ) : (
            <div className="empty-results" data-reveal>
              <h2>No organizer profiles match those filters.</h2>
              <p>Try a wider city, format, or status filter.</p>
              <button className="button button--ghost" type="button" onClick={clearFilters}>
                Reset directory
              </button>
            </div>
          )}
        </section>
      </main>

      <SiteFooter
        brandHref="/"
        body="Searchable profiles for hosts, clubs, venues, and social organizers."
        links={[
          {href: "/host/", label: "For hosts"},
          {href: "/", label: "Member site"},
          {href: "/organizers/?q=run", label: "Run clubs"},
          {href: "/organizers/?q=dinner", label: "Dinners"},
        ]}
      />
    </>
  );
}

function DirectoryClaimPressureStrip({
  claimableListings,
  eventBackedCount,
  unclaimedCount,
}: {
  claimableListings: HostListing[];
  eventBackedCount: number;
  unclaimedCount: number;
}) {
  return (
    <section className="directory-claim-pressure" aria-labelledby="directory-claim-title">
      <div className="directory-claim-pressure__copy" data-reveal>
        <span className="ui-label">Claim pressure</span>
        <h2 id="directory-claim-title">Public pages work harder when the owner steps in.</h2>
        <p>
          Seed pages expose source evidence and proof gaps. Claimed pages can add
          official details, publish Catch events, separate verified attendee
          reviews, and respond as the host.
        </p>
        <div className="directory-claim-pressure__stats">
          <span><strong>{unclaimedCount}</strong> claimable pages</span>
          <span><strong>{eventBackedCount}</strong> event-backed pages</span>
        </div>
      </div>
      <div className="directory-claim-pressure__list" data-reveal>
        {claimableListings.map((listing) => (
          <a href={claimHrefForListing(listing)} key={listing.id}>
            <ActivityMark listing={listing} size="sm" />
            <span>
              <strong>{listing.name}</strong>
              <small>{listing.city} · {listing.missingEvidence.length} proof gaps</small>
            </span>
            <StatusBadge listing={listing} compact />
          </a>
        ))}
        <a className="directory-claim-pressure__cta" href="/claim/">
          Open claim flow
        </a>
      </div>
    </section>
  );
}

function ClaimPage() {
  const claimLookup = getClaimListingLookupFromUrl();
  const preselectedListing = getClaimListingFromUrl();
  const claimUrlState = claimStateForUrl(claimLookup, preselectedListing);
  const urlRequestId = getClaimRequestIdFromUrl();
  const [step, setStep] = useState<ClaimFlowStep>(
    claimUrlState ? "listing" : preselectedListing ? "role" : "listing"
  );
  const [listing, setListing] = useState<HostListing | null>(preselectedListing);
  const [query, setQuery] = useState(preselectedListing?.name ?? "");
  const [requesterName, setRequesterName] = useState("");
  const [requesterRole, setRequesterRole] = useState<ClubClaimRole>("owner");
  const [businessEmail, setBusinessEmail] = useState("");
  const [businessPhone, setBusinessPhone] = useState("");
  const [proofUrls, setProofUrls] = useState("");
  const [message, setMessage] = useState("");
  const [verificationMethod, setVerificationMethod] =
    useState<ClaimVerificationMethod["id"]>("publicProof");
  const [requestId, setRequestId] = useState<string | null>(null);
  const [user, setUser] = useState<User | null>(null);
  const [authReady, setAuthReady] = useState(false);
  const [isSigningIn, setIsSigningIn] = useState(false);
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [status, setStatus] = useState<ClaimStatus>({message: "", tone: ""});

  useEffect(() => {
    return watchClaimAuthState((nextUser) => {
      setUser(nextUser);
      setAuthReady(true);
      setRequesterName((current) => current || nextUser?.displayName || "");
      setBusinessEmail((current) => current || nextUser?.email || "");
    });
  }, []);

  const searchResults = useMemo(() => {
    const normalized = query.trim().toLowerCase();
    const claimableListings = hostListings.filter(isUnclaimedListing);
    if (normalized.length <= 1) return claimableListings.slice(0, 5);
    return claimableListings
      .filter((item) =>
        [
          item.name,
          item.category,
          item.city,
          item.region,
          ...item.formats,
        ].join(" ").toLowerCase().includes(normalized)
      )
      .slice(0, 8);
  }, [query]);

  const currentStepIndex = claimFlowSteps.findIndex((item) => item.id === step);
  const selectedMethod =
    claimVerificationMethods.find((method) => method.id === verificationMethod) ??
    claimVerificationMethods[0];
  const activeRequestId = requestId ?? urlRequestId;
  const canContinueRole =
    Boolean(listing) &&
    requesterName.trim().length >= 2 &&
    (businessEmail.trim().length > 0 ||
      businessPhone.trim().length > 0 ||
      proofUrls.trim().length > 0);

  async function handleSignIn() {
    setIsSigningIn(true);
    setStatus({message: "", tone: ""});
    trackMarketingEvent("claim_flow_sign_in_started", {
      listing_id: listing?.id ?? null,
    });
    try {
      await signInForClaim();
      trackMarketingEvent("claim_flow_signed_in", {
        listing_id: listing?.id ?? null,
      });
    } catch (error) {
      setStatus({message: readableError(error), tone: "is-error"});
      trackMarketingEvent("claim_flow_sign_in_error", {
        listing_id: listing?.id ?? null,
      });
    } finally {
      setIsSigningIn(false);
    }
  }

  async function handleClaimSubmit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();
    if (!listing) {
      setStatus({message: "Choose a listing before submitting.", tone: "is-error"});
      setStep("listing");
      return;
    }

    const parsedProofUrls = parseProofUrls(proofUrls);
    if (!requesterName.trim() || !requesterRole) {
      setStatus({message: "Add your name and role before submitting.", tone: "is-error"});
      setStep("role");
      return;
    }
    if (!businessEmail.trim() && !businessPhone.trim() && parsedProofUrls.length === 0) {
      setStatus({
        message: "Add a business email, phone, or proof link.",
        tone: "is-error",
      });
      setStep("role");
      return;
    }
    if (!claimFirebaseConfigured) {
      setStatus({
        message:
          "Claim submission needs the website Firebase/App Check config. The operating packet is ready, but this local build cannot submit it.",
        tone: "is-error",
      });
      return;
    }
    if (!user) {
      setStatus({message: "Sign in before submitting this claim.", tone: "is-error"});
      return;
    }

    const reviewMessage = [
      `Verification method: ${selectedMethod.title}`,
      message.trim(),
    ].filter(Boolean).join("\n\n");

    setIsSubmitting(true);
    setStatus({message: "", tone: ""});
    trackMarketingEvent("claim_flow_submit_attempt", {
      listing_id: listing.id,
      proof_count: parsedProofUrls.length,
      requester_role: requesterRole,
      verification_method: verificationMethod,
    });

    try {
      const response = await requestClubClaim({
        clubId: listing.id,
        requesterName: requesterName.trim(),
        requesterRole,
        businessEmail: businessEmail.trim() || null,
        businessPhone: businessPhone.trim() || null,
        proofUrls: parsedProofUrls,
        message: reviewMessage || null,
      });
      setRequestId(response.requestId);
      setStatus({
        message: "Claim request received. Catch will review ownership before tools unlock.",
        tone: "is-success",
      });
      setStep("submitted");
      trackMarketingEvent("claim_flow_submitted", {
        listing_id: listing.id,
        proof_count: parsedProofUrls.length,
        requester_role: requesterRole,
        request_id: response.requestId,
      });
    } catch (error) {
      setStatus({message: readableError(error), tone: "is-error"});
      trackMarketingEvent("claim_flow_submit_error", {
        listing_id: listing.id,
      });
    } finally {
      setIsSubmitting(false);
    }
  }

  return (
    <>
      <SiteHeader
        brandHref="/"
        nav={[
          {href: "/organizers/", label: "Find listing"},
          {href: "/host/", label: "Host tools"},
          {href: "/#trust", label: "Trust"},
        ]}
        ctaHref="/host/#founding-hosts"
        ctaLabel="Start fresh"
      />

      <main className="claim-flow">
        <section className="claim-flow__hero">
          <div className="claim-flow__intro" data-reveal>
            <span className="ui-label">Claim your listing</span>
            <h1>Take control of how your events show up.</h1>
            <p>
              Find an unclaimed organizer page, prove your role, and send the
              operating packet Catch needs before owner tools unlock.
            </p>
          </div>
          <div className="claim-flow__summary" data-reveal>
            <strong>{listing?.name ?? "No listing selected"}</strong>
            <span>
              {listing ?
                `${listing.category} · ${listing.city} · ${listing.sourceConfidence.replaceAll("_", " ")}` :
                "Search the source-backed organizer directory first."}
            </span>
          </div>
        </section>

        {claimUrlState ? (
          <ClaimUrlStatePanel
            state={claimUrlState}
            listing={listing}
            lookup={claimLookup}
            requestId={activeRequestId}
          />
        ) : (
          <form className="claim-flow__workspace" onSubmit={handleClaimSubmit}>
          <nav className="operational-step-rail" aria-label="Claim progress">
            {claimFlowSteps.map((item, index) => (
              <button
                className={index === currentStepIndex ? "is-active" : index < currentStepIndex ? "is-done" : ""}
                disabled={index > currentStepIndex}
                key={item.id}
                onClick={() => setStep(item.id)}
                type="button"
              >
                <span>{String(index + 1).padStart(2, "0")}</span>
                <strong>{item.label}</strong>
              </button>
            ))}
          </nav>

          <section className="claim-flow__panel" aria-live="polite">
            {step === "listing" ? (
              <div className="claim-flow__stage">
                <div className="field-block">
                  <label htmlFor="claim-search">Search unclaimed listings</label>
                  <input
                    id="claim-search"
                    value={query}
                    placeholder="Organizer, venue, category, or city"
                    onChange={(event) => setQuery(event.currentTarget.value)}
                  />
                </div>
                <div className="claim-listing-results">
                  {searchResults.map((item) => (
                    <button
                      className={listing?.id === item.id ? "claim-result is-selected" : "claim-result"}
                      key={item.id}
                      onClick={() => {
                        setListing(item);
                        setQuery(item.name);
                      }}
                      type="button"
                      style={{"--activity": activityForListing(item).token} as CSSProperties}
                    >
                      <ActivityMark listing={item} size="sm" />
                      <span>
                        <strong>{item.name}</strong>
                        <small>{item.category} · {item.city} · {item.sources.length} sources</small>
                      </span>
                      <StatusBadge listing={item} compact />
                    </button>
                  ))}
                  {!searchResults.length ? (
                    <div className="claim-empty-state">
                      <strong>No unclaimed listing found.</strong>
                      <p>
                        Start as a fresh host so Catch can create the organizer
                        profile from first-party details.
                      </p>
                      <a className="button button--ghost" href="/host/#founding-hosts">
                        Start fresh
                      </a>
                    </div>
                  ) : null}
                </div>
                <div className="flow-actions">
                  <a className="button button--ghost" href="/host/#founding-hosts">
                    My organizer is not listed
                  </a>
                  <button
                    className="button"
                    disabled={!listing}
                    type="button"
                    onClick={() => setStep("role")}
                  >
                    Continue
                  </button>
                </div>
              </div>
            ) : null}

            {step === "role" && listing ? (
              <div className="claim-flow__stage">
                <div className="selected-listing-card">
                  <ActivityMark listing={listing} size="sm" />
                  <span>
                    <strong>{listing.name}</strong>
                    <small>{listing.category} · {listing.city}</small>
                  </span>
                  <button className="see-all-button" type="button" onClick={() => setStep("listing")}>
                    Change
                  </button>
                </div>

                <div className="flow-field-grid">
                  <div className="field-block">
                    <label htmlFor="claim-name">Your name</label>
                    <input
                      id="claim-name"
                      value={requesterName}
                      autoComplete="name"
                      onChange={(event) => setRequesterName(event.currentTarget.value)}
                      required
                    />
                  </div>
                  <div className="field-block">
                    <label htmlFor="claim-role">Role</label>
                    <select
                      id="claim-role"
                      value={requesterRole}
                      onChange={(event) => setRequesterRole(event.currentTarget.value as ClubClaimRole)}
                      required
                    >
                      {claimRoleOptions.map((option) => (
                        <option value={option.value} key={option.value}>
                          {option.label}
                        </option>
                      ))}
                    </select>
                  </div>
                  <div className="field-block">
                    <label htmlFor="claim-email">Business email</label>
                    <input
                      id="claim-email"
                      type="email"
                      value={businessEmail}
                      autoComplete="email"
                      onChange={(event) => setBusinessEmail(event.currentTarget.value)}
                    />
                  </div>
                  <div className="field-block">
                    <label htmlFor="claim-phone">Business phone</label>
                    <input
                      id="claim-phone"
                      type="tel"
                      value={businessPhone}
                      autoComplete="tel"
                      onChange={(event) => setBusinessPhone(event.currentTarget.value)}
                    />
                  </div>
                  <div className="field-block span-2">
                    <label htmlFor="claim-proof">Proof links</label>
                    <textarea
                      id="claim-proof"
                      rows={3}
                      value={proofUrls}
                      placeholder="Official website, Instagram, Luma, Linktree, or event page"
                      onChange={(event) => setProofUrls(event.currentTarget.value)}
                    />
                  </div>
                </div>

                <div className="flow-actions">
                  <button className="button button--ghost" type="button" onClick={() => setStep("listing")}>
                    Back
                  </button>
                  <button
                    className="button"
                    disabled={!canContinueRole}
                    type="button"
                    onClick={() => setStep("verify")}
                  >
                    Continue
                  </button>
                </div>
              </div>
            ) : null}

            {step === "verify" && listing ? (
              <div className="claim-flow__stage">
                <div>
                  <span className="ui-label">Verification method</span>
                  <h2>How Catch should verify ownership.</h2>
                  <p>
                    Approved claims attach this page to a host account before
                    editing, review responses, events, or analytics are unlocked.
                  </p>
                </div>

                <div className="verification-methods">
                  {claimVerificationMethods.map((method) => (
                    <button
                      className={verificationMethod === method.id ? "choice-card is-selected" : "choice-card"}
                      key={method.id}
                      type="button"
                      onClick={() => setVerificationMethod(method.id)}
                    >
                      <strong>{method.title}</strong>
                      <span>{method.body}</span>
                    </button>
                  ))}
                </div>

                <div className="claim-review-grid">
                  <div>
                    <span className="ui-label">Claim packet</span>
                    <dl>
                      <div><dt>Listing</dt><dd>{listing.name}</dd></div>
                      <div><dt>Requester</dt><dd>{requesterName}</dd></div>
                      <div><dt>Role</dt><dd>{claimRoleOptions.find((option) => option.value === requesterRole)?.label}</dd></div>
                      <div><dt>Contact</dt><dd>{businessEmail || businessPhone || "Proof links only"}</dd></div>
                    </dl>
                  </div>
                  <div>
                    <span className="ui-label">Unlocks after approval</span>
                    <ul>
                      {claimUnlocks.map((item) => (
                        <li key={item}>{item}</li>
                      ))}
                    </ul>
                  </div>
                </div>

                <div className="field-block">
                  <label htmlFor="claim-message">Note for review</label>
                  <textarea
                    id="claim-message"
                    rows={3}
                    value={message}
                    maxLength={1000}
                    placeholder="Anything Catch should know before approving ownership"
                    onChange={(event) => setMessage(event.currentTarget.value)}
                  />
                </div>

                <div className="claim-auth-row claim-auth-row--flow">
                  <span>
                    {user ?
                      `Signed in as ${user.displayName || user.email || "Catch user"}` :
                      authReady ?
                        "Sign in with Google to submit the claim." :
                        "Checking sign-in status."}
                  </span>
                  {user ? (
                    <button className="button button--ghost" onClick={() => void signOutClaimUser()} type="button">
                      Sign out
                    </button>
                  ) : (
                    <button
                      className="button button--ghost"
                      disabled={!authReady || isSigningIn}
                      onClick={() => void handleSignIn()}
                      type="button"
                    >
                      {isSigningIn ? "Signing in..." : "Sign in"}
                    </button>
                  )}
                </div>

                <div className="flow-actions">
                  <button className="button button--ghost" type="button" onClick={() => setStep("role")}>
                    Back
                  </button>
                  <button className="button" disabled={isSubmitting || !user} type="submit">
                    {isSubmitting ? "Submitting..." : "Submit claim"}
                  </button>
                </div>
              </div>
            ) : null}

            {step === "submitted" && listing ? (
              <div className="claim-flow__stage">
                <ProcessStatusPanel
                  mark="✓"
                  eyebrow="Claim in review"
                  title={`${listing.name} is waiting for owner approval.`}
                  body={requestId ?
                    `Request ${requestId} is pending. Catch will verify ownership before attaching host tools.` :
                    "Catch will verify ownership before attaching host tools, review responses, event publishing, or analytics."}
                  items={claimWhileYouWaitItems(listing)}
                  actions={[
                    {href: listing.path, label: "View public listing", variant: "secondary"},
                    {href: "/host/", label: "Explore host tools", variant: "primary"},
                  ]}
                />
                <div className="owner-unlock-board">
                  {[
                    ["Profile", "Fix source details, description, photos, and event categories."],
                    ["Events", "Publish the first Catch event with admission, price, waitlist, and Event Success."],
                    ["Reviews", "Respond as owner and separate public reviews from verified attendee reviews."],
                    ["Reports", "Track attendance, catches, matches, repeat interest, and safety totals."],
                  ].map(([title, body]) => (
                    <article key={title}>
                      <span>{title}</span>
                      <p>{body}</p>
                    </article>
                  ))}
                </div>
              </div>
            ) : null}

            <p className={`form-status ${status.tone}`.trim()} role="status" aria-live="polite">
              {status.message}
            </p>
          </section>
          </form>
        )}
      </main>

      <SiteFooter
        brandHref="/"
        body="Claimable organizer profiles with verified owner review before host tools unlock."
        links={[
          {href: "/organizers/", label: "Organizer search"},
          {href: "/host/", label: "For hosts"},
          {href: "/", label: "Member site"},
        ]}
      />
    </>
  );
}

function ClaimUrlStatePanel({
  state,
  listing,
  lookup,
  requestId,
}: {
  state: ClaimUrlState;
  listing: HostListing | null;
  lookup: string | null;
  requestId: string | null;
}) {
  if (state === "alreadyClaimed" && listing) {
    return (
      <ProcessStatusPanel
        mark="C"
        eyebrow="Already claimed"
        title={`${listing.name} already has owner context.`}
        body="Catch does not open a second owner request from this public claim flow. Use the public profile, events, or organizer search instead."
        items={[
          {
            title: "Owner tools stay gated",
            body: "Edits, event publishing, review responses, and reports stay attached to the verified owner account.",
          },
          {
            title: "Public profile remains visible",
            body: "Members can still inspect source details, Catch events, reviews, and event outcomes from the profile.",
          },
          {
            title: "Need a different organizer?",
            body: "Search unclaimed seed pages or start fresh so Catch can review a new host packet.",
          },
        ]}
        actions={[
          {href: listing.path, label: "View public listing", variant: "primary"},
          {href: "/claim/", label: "Search claimable pages", variant: "secondary"},
          {href: "/host/#founding-hosts", label: "Start fresh", variant: "secondary"},
        ]}
      />
    );
  }

  if (state === "pendingClaim") {
    return (
      <ProcessStatusPanel
        mark="..."
        eyebrow="Claim in review"
        title={listing ? `${listing.name} is already in owner review.` : "This claim is in owner review."}
        body={requestId ?
          `Request ${requestId} is pending. Catch will verify ownership before attaching host tools.` :
          "Catch will verify ownership before attaching host tools, review responses, event publishing, or analytics."}
        items={claimWhileYouWaitItems(listing)}
        actions={[
          ...(listing ? [{href: listing.path, label: "View public listing", variant: "secondary" as const}] : []),
          {href: "/host/", label: "Explore host tools", variant: "primary"},
          {href: "/claim/", label: "Search another page", variant: "secondary"},
        ]}
      />
    );
  }

  return (
    <ProcessStatusPanel
      mark="?"
      eyebrow="Listing not found"
      title={lookup ? `No claimable page matched "${lookup}".` : "No claimable page matched this link."}
      body="The claim URL does not match a generated organizer page. The owner can still apply as a fresh host or search the source-backed directory."
      items={[
        {
          title: "Check the directory",
          body: "Search by organizer name, city, format, or source event before starting a new packet.",
        },
        {
          title: "Start from first-party details",
          body: "If the page does not exist yet, the host application can create a cleaner first-party profile.",
        },
        {
          title: "Avoid duplicate claims",
          body: "Catch should only review ownership against a stable generated page or a fresh host packet.",
        },
      ]}
      actions={[
        {href: "/claim/", label: "Search claimable pages", variant: "primary"},
        {href: "/organizers/", label: "Open directory", variant: "secondary"},
        {href: "/host/#founding-hosts", label: "Start fresh", variant: "secondary"},
      ]}
    />
  );
}

function claimWhileYouWaitItems(listing: HostListing | null) {
  return [
    {
      title: "Keep proof links stable",
      body: "Leave the website, Instagram, event page, or Linktree proof available while Catch reviews ownership.",
    },
    {
      title: "Draft the first Catch event",
      body: listing ?
        `Prepare the next ${listing.category.toLowerCase()} with capacity, price, admission rules, and waitlist plan.` :
        "Prepare the next event with capacity, price, admission rules, and waitlist plan.",
    },
    {
      title: "Watch for follow-up",
      body: "Catch may ask for a public-page edit, email confirmation, or additional owner-safe source before approval.",
    },
    {
      title: "Do not promise automation yet",
      body: "Instagram DM verification still needs backend support, so manual review remains the source of truth.",
    },
  ];
}

function OrganizerResultCard({
  listing,
  queryTerms,
}: {
  listing: HostListing;
  queryTerms: string[];
}) {
  const isAppCreated = listing.listingVariant === "appCreatedClub";
  const rating = listing.metrics?.rating;
  const reviewCount = listing.metrics?.reviewCount;
  const activity = activityForListing(listing);
  const eventHighlights = eventHighlightsForListing(listing, queryTerms);
  const nextEvent = nextFutureCatchEvent(listing);
  return (
    <article
      className="organizer-result-card"
      style={{"--activity": activity.token} as CSSProperties}
    >
      <a href={listing.path}>
        <ActivityMark listing={listing} size="lg" />
        <div className="organizer-result-card__body">
          <div className="organizer-card-topline">
            <StatusBadge listing={listing} compact />
            <span>{listing.city}</span>
            <span>{activity.label}</span>
          </div>
          <h2>{listing.name}</h2>
          <p>{listing.description}</p>
          <div className="listing-badge-row">
            <span>{listing.category}</span>
            {rating ? <span>{rating.toFixed(1)} rating</span> : null}
            {reviewCount ? <span>{reviewCount} reviews</span> : null}
            {nextEvent ? <span>{nextEvent.title}</span> : <span>{isAppCreated ? "No future event" : "Cadence unverified"}</span>}
          </div>
          {eventHighlights.length ? (
            <div className="organizer-event-highlights" aria-label={`${listing.name} event evidence`}>
              {eventHighlights.map((event) => (
                <span key={event.id} style={{"--activity": event.activityToken} as CSSProperties}>
                  <strong>{event.title}</strong>
                  <small>{event.kind} · {event.detail}</small>
                </span>
              ))}
            </div>
          ) : null}
          <div className="listing-format-row">
            {listing.formats.slice(0, 4).map((format) => (
              <span key={format}>{format}</span>
            ))}
          </div>
          <div className="organizer-result-card__footer">
            <ProfileStrength value={listingProfileStrength(listing)} />
            <span>{isAppCreated ? "Owner-managed profile" : `${listing.missingEvidence.length} proof gaps`}</span>
          </div>
        </div>
      </a>
    </article>
  );
}

function HostListingPage({listing}: {listing: HostListing}) {
  const isAppCreated = listing.listingVariant === "appCreatedClub";
  const activity = activityForListing(listing);
  const claimHref = isAppCreated ? listing.claim.href : claimHrefForListing(listing);
  const [shareStatus, setShareStatus] = useState("");
  const nav = [
    {href: "#profile", label: "Profile"},
    ...(listing.catchEvents?.length ? [{href: "#events", label: "Events"}] : []),
    {href: "#reviews", label: "Reviews"},
    {href: "#fit", label: isAppCreated ? "Format" : "Fit"},
    ...(!isAppCreated ? [{href: "#sources", label: "Sources"}] : []),
    {href: "/organizers/", label: "Search"},
    {href: "/host/", label: "For hosts"},
  ];

  async function handleShareListing() {
    const shareUrl = absoluteListingUrl(listing);
    const shareData = {
      title: `${listing.name} on Catch`,
      text: listing.headline,
      url: shareUrl,
    };

    try {
      if ("share" in navigator && typeof navigator.share === "function") {
        await navigator.share(shareData);
        setShareStatus("Share sheet opened.");
        trackMarketingEvent("listing_share_completed", {
          club_id: listing.id,
          method: "native",
        });
        return;
      }
      if (navigator.clipboard?.writeText) {
        await navigator.clipboard.writeText(shareUrl);
        setShareStatus("Listing link copied.");
        trackMarketingEvent("listing_share_completed", {
          club_id: listing.id,
          method: "clipboard",
        });
        return;
      }
      setShareStatus(shareUrl);
      trackMarketingEvent("listing_share_completed", {
        club_id: listing.id,
        method: "manual",
      });
    } catch (error) {
      const aborted = error instanceof DOMException && error.name === "AbortError";
      setShareStatus(aborted ? "Share cancelled." : "Could not share. Copy the URL from the address bar.");
      trackMarketingEvent("listing_share_error", {
        club_id: listing.id,
        aborted,
      });
    }
  }

  return (
    <>
      <SiteHeader
        brandHref="/"
        nav={nav}
        ctaHref={claimHref}
        ctaLabel={isAppCreated ? listing.claim.label : "Claim listing"}
      />

      <main id="profile">
        <section className="listing-hero">
          <div className="listing-hero__inner">
            <div
              className="listing-hero__copy"
              data-reveal
              style={{"--activity": activity.token} as CSSProperties}
            >
              <div className="listing-hero__eyebrow">
                <StatusBadge listing={listing} />
                <span className="ui-label">{listing.category}</span>
              </div>
              <h1>{listing.headline}</h1>
              <p>{listing.description}</p>
              <div className="listing-badge-row" aria-label="Listing status">
                <span>{listing.status}</span>
                <span>{listing.sourceConfidence.replaceAll("_", " ")}</span>
                <span>Updated {listing.lastVerifiedAt}</span>
              </div>
              <div className="hero__actions">
                <a
                  className="button"
                  href={claimHref}
                  onClick={() => trackCtaClick("listing_claim", claimHref)}
                >
                  {listing.claim.label}
                </a>
                <a
                  className="button button--ghost"
                  href={isAppCreated ? "/organizers/" : "/host/"}
                  onClick={() => trackCtaClick(
                    isAppCreated ? "listing_search_organizers" : "listing_host_tools",
                    isAppCreated ? "/organizers/" : "/host/"
                  )}
                >
                  {isAppCreated ? "Search organizers" : "See Catch for hosts"}
                </a>
                <button
                  className="button button--ghost"
                  type="button"
                  onClick={() => void handleShareListing()}
                >
                  Share listing
                </button>
              </div>
              <p className="listing-share-status" role="status" aria-live="polite">
                {shareStatus}
              </p>
            </div>

            <aside
              className="listing-panel"
              aria-label={`${listing.name} profile`}
              data-reveal
              style={{"--activity": activity.token} as CSSProperties}
            >
              <ActivityMark listing={listing} size="lg" />
              <div>
                <span className="ui-label">
                  {isAppCreated ? "Catch organizer" : "Unclaimed profile"}
                </span>
                <h2>{listing.name}</h2>
                <p>
                  {listing.host ? `Hosted by ${listing.host.name}` : `${listing.city}, ${listing.region}`}
                </p>
              </div>
              {listing.metrics ? (
                <div className="listing-panel__metrics" aria-label="Organizer metrics">
                  <span><strong>{listing.metrics.memberCount ?? 0}</strong> members</span>
                  <span><strong>{listing.metrics.rating?.toFixed(1) ?? "0.0"}</strong> rating</span>
                  <span><strong>{listing.metrics.reviewCount ?? 0}</strong> reviews</span>
                </div>
              ) : null}
              <div className="listing-format-row">
                {listing.formats.map((format) => (
                  <span key={format}>{format}</span>
                ))}
              </div>
              <ListingDiagnosticsPanel listing={listing} />
            </aside>
          </div>
        </section>

        <section className="listing-section" aria-labelledby="listing-facts-title">
          <div className="section-heading" data-reveal>
            <span className="ui-label">
              {isAppCreated ? "Club profile" : "Known profile"}
            </span>
            <h2 id="listing-facts-title">
              {isAppCreated ?
                "A Catch-created club with real product context." :
                "A source-conservative seed listing."}
            </h2>
            <p>{listing.sourceSummary}</p>
          </div>
          <div className="listing-grid">
            {listing.facts.map((fact) => (
              <article className="listing-card" data-reveal key={fact.label}>
                <span>{fact.label}</span>
                <strong>{fact.value}</strong>
              </article>
            ))}
          </div>
        </section>

        {listing.catchEvents?.length ? (
          <ListingCatchEventsSection listing={listing} />
        ) : null}

        {listing.eventEvidence?.length ? (
          <section className="listing-section listing-section--events" aria-labelledby="listing-events-title">
            <div className="section-heading" data-reveal>
              <span className="ui-label">Event evidence</span>
              <h2 id="listing-events-title">Public events tied to this host.</h2>
            </div>
            <div className="listing-event-stack">
              {listing.eventEvidence.map((event) => (
                <article className="listing-event-card" data-reveal key={event.title}>
                  <div>
                    <span className="ui-label">{event.date}</span>
                    <h3>{event.title}</h3>
                    <p>{event.summary}</p>
                  </div>
                  <dl className="listing-event-meta">
                    <div>
                      <dt>Location</dt>
                      <dd>{event.location}</dd>
                    </div>
                    <div>
                      <dt>Source</dt>
                      <dd>
                        <a href={event.sourceHref} target="_blank" rel="noreferrer">
                          {event.sourceLabel}
                        </a>
                      </dd>
                    </div>
                  </dl>
                  <ul className="listing-event-facts">
                    {event.facts.map((fact) => (
                      <li key={fact}>{fact}</li>
                    ))}
                  </ul>
                </article>
              ))}
            </div>
          </section>
        ) : null}

        <ListingReviewsSection listing={listing} />

        {listing.eventSuccessSummary ? (
          <ListingEventSuccessSection summary={listing.eventSuccessSummary} />
        ) : null}

        <section className="listing-section" id="fit" aria-labelledby="listing-fit-title">
          <div className="section-heading" data-reveal>
            <span className="ui-label">{isAppCreated ? "Page format" : "Catch fit"}</span>
            <h2 id="listing-fit-title">
              {isAppCreated ?
                "What the app-created profile needs to emphasize." :
                "Why this category belongs in the first test."}
            </h2>
          </div>
          <div className="listing-grid listing-grid--fit">
            {listing.fitNotes.map((note) => (
              <article className="listing-card" data-reveal key={note}>
                <p>{note}</p>
              </article>
            ))}
          </div>
        </section>

        {!isAppCreated ? (
          <>
            <ListingSourcesSection listing={listing} />
            <section className="claim-band" aria-labelledby="listing-missing-title">
              <div data-reveal>
                <span className="ui-label">Before public indexing</span>
                <h2 id="listing-missing-title">Missing evidence</h2>
                <p>
                  This is the pressure mechanic from the prototype: visitors can
                  see what is known, what is missing, and why a verified Catch
                  profile earns stronger placement.
                </p>
              </div>
              <div className="claim-band__grid">
                <ul className="missing-list" data-reveal>
                  {listing.missingEvidence.map((item) => (
                    <li key={item}>{item}</li>
                  ))}
                </ul>
                <div className="claim-band__rail">
                  <ClaimUnlocksCard listing={listing} />
                  <ClaimListingPanel listing={listing} />
                </div>
              </div>
            </section>
            <RecommendedOrganizersSection current={listing} />
          </>
        ) : null}
      </main>

      <SiteFooter
        brandHref="/"
        body="Claimable profiles for hosts who run social events people actually show up for."
        links={[
          {href: "/host/", label: "For hosts"},
          {href: "#profile", label: "Profile"},
          {href: "#sources", label: "Sources"},
          {href: claimHref, label: "Claim"},
        ]}
      />
    </>
  );
}

function ListingDiagnosticsPanel({listing}: {listing: HostListing}) {
  const verified = isVerifiedListing(listing);
  const strength = listingProfileStrength(listing);
  const diagnostics = verified
    ? [
        {ok: true, label: "Ownership and source model verified"},
        {ok: true, label: "Catch events attached to profile"},
        {ok: (listing.metrics?.reviewCount ?? 0) > 0, label: "Review signal visible"},
        {ok: Boolean(listing.eventSuccessSummary), label: "Aggregate host report available"},
      ]
    : [
        {ok: true, label: "Public facts collected from sources"},
        {ok: false, label: "Ownership not verified"},
        {ok: false, label: "No Catch events published"},
        {ok: false, label: "No verified attendee reviews"},
      ];

  return (
    <div className="listing-diagnostics">
      <div className="listing-diagnostics__head">
        <span className="ui-label">Profile strength</span>
        <strong>{strength}%</strong>
      </div>
      <ProfileStrength value={strength} />
      <ul>
        {diagnostics.map((item) => (
          <li className={item.ok ? "is-ok" : "is-missing"} key={item.label}>
            <span aria-hidden="true">{item.ok ? "✓" : "!"}</span>
            {item.label}
          </li>
        ))}
      </ul>
    </div>
  );
}

function ClaimUnlocksCard({listing}: {listing: HostListing}) {
  const claimHref = claimHrefForListing(listing);
  return (
    <aside className="claim-unlocks" data-reveal>
      <span className="ui-label">Claiming unlocks</span>
      <h3>What {listing.name} cannot show yet.</h3>
      <ul>
        {claimUnlocks.map((item) => (
          <li key={item}>{item}</li>
        ))}
      </ul>
      <a
        className="button"
        href={claimHref}
        onClick={() => trackCtaClick("claim_unlocks_panel", claimHref)}
      >
        Claim this listing
      </a>
    </aside>
  );
}

function RecommendedOrganizersSection({current}: {current: HostListing}) {
  const recommended = hostListings
    .filter((listing) => listing.id !== current.id && isVerifiedListing(listing))
    .slice(0, 3);
  if (!recommended.length) return null;

  return (
    <section className="listing-section recommended-organizers" aria-labelledby="recommended-organizers-title">
      <div className="section-heading" data-reveal>
        <span className="ui-label">While you are here</span>
        <h2 id="recommended-organizers-title">Verified organizers nearby in the product loop.</h2>
        <p>
          Unclaimed pages keep the source ledger visible, but verified profiles
          can show owner-managed activity, reviews, and event outcomes.
        </p>
      </div>
      <div className="featured-organizers__grid">
        {recommended.map((listing) => (
          <OrganizerMiniCard listing={listing} key={listing.id} />
        ))}
      </div>
    </section>
  );
}

function ListingCatchEventsSection({listing}: {listing: HostListing}) {
  const events = listing.catchEvents ?? [];
  const eventCards = events.map((event) => eventActionCardForListing(listing, event));
  return (
    <section
      className="listing-section listing-section--events"
      id="events"
      aria-labelledby="listing-catch-events-title"
    >
      <div className="section-heading" data-reveal>
        <span className="ui-label">Catch events</span>
        <h2 id="listing-catch-events-title">Events created inside Catch.</h2>
        <p>
          App-created clubs should show the actual event pipeline: what is
          coming up, what filled, and what happened after people showed up.
        </p>
      </div>
      <div className="listing-catch-event-grid">
        {eventCards.map((event) => (
          <EventActionCard event={event} key={event.id} />
        ))}
      </div>
      <div className="listing-event-download" data-reveal>
        <div>
          <span className="ui-label">Member app</span>
          <h3>Book, check in, and review from Catch.</h3>
          <p>
            Public pages expose the event record. The app handles booking,
            waitlist movement, attendance, catches, and verified reviews.
          </p>
        </div>
        <AppDownloadCtas
          placement={`listing-events-${listing.slug}`}
          className="app-download-ctas--compact"
        />
      </div>
    </section>
  );
}

function ListingEventSuccessSection({
  summary,
}: {
  summary: HostListingEventSuccessSummary;
}) {
  const metrics = [
    {label: "Booked", value: summary.bookedCount},
    {label: "Checked in", value: summary.checkedInCount},
    {label: "Catches sent", value: summary.catchSentCount},
    {label: "Mutual matches", value: summary.mutualMatchCount},
    {label: "Chats started", value: summary.chatStartedCount},
    {label: "Safety reports", value: summary.safetyIncidentCount},
  ];
  return (
    <section
      className="listing-section listing-section--success"
      id="event-success"
      aria-labelledby="event-success-title"
    >
      <div className="section-heading" data-reveal>
        <span className="ui-label">Event Success</span>
        <h2 id="event-success-title">The claimed profile can show what Catch actually operated.</h2>
        <p>
          These are aggregate, host-safe outcomes from a completed Catch event.
          This is the kind of proof an app-created club can show that a scraped
          unclaimed listing cannot.
        </p>
      </div>
      <div className="listing-success-grid" data-reveal>
        {metrics.map((metric) => (
          <div key={metric.label}>
            <strong>{metric.value}</strong>
            <span>{metric.label}</span>
          </div>
        ))}
      </div>
    </section>
  );
}

function ListingSourcesSection({listing}: {listing: HostListing}) {
  return (
    <section className="listing-section listing-section--split" id="sources">
      <div data-reveal>
        <span className="ui-label">Source ledger</span>
        <h2>Evidence before indexing.</h2>
        <p>
          Thin pages should stay out of search until identity, cadence, and
          owner-safe details are verified.
        </p>
      </div>

      <div className="listing-ledger" data-reveal>
        {listing.sources.map((source) => (
          <article key={`${source.type}-${source.label}`}>
            <div>
              <strong>{source.label}</strong>
              <span>{source.confidence} confidence</span>
            </div>
            <p>{source.detail}</p>
            {source.href ? (
              <a className="source-link" href={source.href} target="_blank" rel="noreferrer">
                Open source
              </a>
            ) : null}
          </article>
        ))}
      </div>
    </section>
  );
}

function ListingReviewsSection({listing}: {listing: HostListing}) {
  const seedReviews = listing.reviews ?? [];
  const [reviews, setReviews] = useState<HostListingReview[]>(
    () => seedReviews
  );
  const [rating, setRating] = useState(5);
  const [reviewerName, setReviewerName] = useState("");
  const [comment, setComment] = useState("");
  const [isAnonymous, setIsAnonymous] = useState(false);
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [status, setStatus] = useState<ClaimStatus>({
    message: "",
    tone: "",
  });

  useEffect(() => {
    let cancelled = false;
    setReviews(seedReviews);

    if (!publicReviewsFirebaseConfigured) return () => {
      cancelled = true;
    };

    listPublicClubReviews({clubId: listing.id})
      .then((result) => {
        if (cancelled || !result.reviews.length) return;
        setReviews(mergeReviews(result.reviews, seedReviews));
      })
      .catch((error) => {
        if (cancelled) return;
        setStatus({
          message: readableError(error),
          tone: "is-error",
        });
      });

    return () => {
      cancelled = true;
    };
  }, [listing]);

  const seedReviewKeys = new Set(seedReviews.map(reviewKey));
  const supplementalReviews = reviews.filter(
    (review) => !seedReviewKeys.has(reviewKey(review))
  );
  const aggregateReviewCount = listing.metrics?.reviewCount;
  const aggregateRating = listing.metrics?.rating;
  const displayReviewCount = aggregateReviewCount !== undefined ?
    aggregateReviewCount + supplementalReviews.length :
    reviews.length;
  const supplementalRatingTotal = supplementalReviews.reduce(
    (sum, review) => sum + review.rating,
    0
  );
  const visibleRatingAverage = reviews.length
    ? reviews.reduce((sum, review) => sum + review.rating, 0) / reviews.length
    : 0;
  const displayRating = aggregateRating !== undefined && aggregateReviewCount ?
    (
      (aggregateRating * aggregateReviewCount + supplementalRatingTotal) /
      displayReviewCount
    ) :
    visibleRatingAverage;
  const visibleVerifiedCount = reviews.filter(
    (review) => review.verificationStatus === "verified" ||
      (!review.verificationStatus && review.source !== "publicListing")
  ).length;
  const verifiedCount = Math.max(
    listing.listingVariant === "appCreatedClub" ? aggregateReviewCount ?? 0 : 0,
    visibleVerifiedCount
  );
  const reviewFormId = `review-${listing.id}`;
  const isAppCreated = listing.listingVariant === "appCreatedClub";
  const verifiedReviews = reviews
    .filter(isVerifiedReview)
    .map(reviewCardForReview);
  const publicReviews = reviews
    .filter((review) => !isVerifiedReview(review))
    .map(reviewCardForReview);
  const ownerResponseCount = reviews.filter((review) => review.ownerResponse).length;
  const ownerPromptStats = [
    {label: "published responses", value: ownerResponseCount},
    {label: "verified signals", value: verifiedCount},
    {label: "public reviews", value: publicReviews.length},
  ];

  async function submitReview(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();
    setStatus({message: "", tone: ""});

    const trimmedComment = comment.trim();
    const trimmedName = reviewerName.trim();
    if (!trimmedComment) {
      setStatus({message: "Review text is required.", tone: "is-error"});
      return;
    }
    if (!isAnonymous && !trimmedName) {
      setStatus({
        message: "Add your name, or choose anonymous.",
        tone: "is-error",
      });
      return;
    }

    setIsSubmitting(true);
    const localReview: HostListingReview = {
      id: `local-${Date.now()}`,
      reviewerName: isAnonymous ? "Anonymous reviewer" : trimmedName,
      rating,
      comment: trimmedComment,
      createdAt: new Date().toISOString(),
      verificationStatus: "unverified",
      source: "publicListing",
      isAnonymous,
      ownerResponse: null,
    };

    try {
      if (publicReviewsFirebaseConfigured) {
        const result = await createPublicClubReview({
          clubId: listing.id,
          rating,
          comment: trimmedComment,
          reviewerName: trimmedName,
          isAnonymous,
          submittedFromPath: window.location.pathname,
        });
        setReviews((current) => mergeReviews([result.review], current));
        setStatus({
          message: "Review published as an unverified public review.",
          tone: "is-success",
        });
      } else {
        setReviews((current) => mergeReviews([localReview], current));
        setStatus({
          message:
            "Preview review added locally. Configure website App Check to write it to Firestore.",
          tone: "is-success",
        });
      }
      setComment("");
      if (isAnonymous) setReviewerName("");
      trackMarketingEvent("listing_public_review_submitted", {
        club_id: listing.id,
        anonymous: isAnonymous,
        configured: publicReviewsFirebaseConfigured,
      });
    } catch (error) {
      setStatus({
        message: readableError(error),
        tone: "is-error",
      });
    } finally {
      setIsSubmitting(false);
    }
  }

  return (
    <section
      className="listing-section listing-section--reviews"
      id="reviews"
      aria-labelledby="listing-reviews-title"
    >
      <div className="section-heading" data-reveal>
        <span className="ui-label">Reviews</span>
        <h2 id="listing-reviews-title">Public reviews for {listing.name}.</h2>
        <p>
          Verified reviews come from logged-in Catch guests after attended
          events. Reviews submitted on this public page are unverified and can
          be anonymous.
        </p>
      </div>

      <div className="listing-review-summary" data-reveal>
        <div>
          <span className="ui-label">Rating</span>
          <strong>
            {displayReviewCount ? displayRating.toFixed(1) : "No reviews yet"}
          </strong>
        </div>
        <div>
          <span className="ui-label">Count</span>
          <strong>{displayReviewCount}</strong>
        </div>
        <div>
          <span className="ui-label">Verified</span>
          <strong>{verifiedCount}</strong>
        </div>
        <a
          className="button button--ghost"
          href={`#${reviewFormId}`}
          onClick={() => trackCtaClick("listing_review_intent", `#${reviewFormId}`)}
        >
          Add review
        </a>
      </div>

      <div className="listing-review-workspace">
        <div>
          {reviews.length ? (
            <div className="listing-review-lanes">
              <ReviewSignalLane
                title="Verified Catch attendee reviews"
                body="These reviews come from logged-in guests after attended Catch events and stay separate from public page feedback."
                reviews={verifiedReviews}
                emptyTitle="No verified attendee reviews are visible yet."
                emptyBody="Verified attendee reviews appear after Catch has operated the event and confirmed attendance."
              />
              <ReviewSignalLane
                title="Unverified public reviews"
                body="These reviews are submitted from the public web page. They are useful, but they are not treated as attended-event proof."
                reviews={publicReviews}
                emptyTitle="No public web reviews yet."
                emptyBody="Public reviews can be added here; Catch keeps them clearly labeled until they can be tied to a verified event."
              />
            </div>
          ) : (
            <div className="listing-review-empty" data-reveal>
              <div>
                <span className="ui-label">First review</span>
                <h3>No public reviews for {listing.name} yet.</h3>
                <p>
                  Add the first public review here. If the organizer claims this
                  page, they can respond from the verified host account.
                </p>
              </div>
            </div>
          )}
          <OwnerResponsePrompt
            title={isAppCreated ? "Owner replies stay attached to the source." : "Claiming unlocks owner replies."}
            body={isAppCreated ?
              "Catch separates attendee proof, public web feedback, and host replies so responses do not blur the review source." :
              "Public reviews can arrive before the organizer owns the page. Catch keeps them unverified until a claim is approved."}
            stats={ownerPromptStats}
            ctaHref={isAppCreated ? undefined : claimHrefForListing(listing)}
            ctaLabel={isAppCreated ? undefined : "Claim to respond"}
          />
        </div>

        <form
          className="listing-review-form"
          data-reveal
          id={reviewFormId}
          onSubmit={submitReview}
        >
          <div>
            <span className="ui-label">Add review</span>
            <h3>Share feedback for {listing.name}.</h3>
          </div>
          <label>
            Rating
            <select
              value={rating}
              onChange={(event) => setRating(Number(event.target.value))}
            >
              <option value={5}>5 stars</option>
              <option value={4}>4 stars</option>
              <option value={3}>3 stars</option>
              <option value={2}>2 stars</option>
              <option value={1}>1 star</option>
            </select>
          </label>
          <label>
            Display name
            <input
              value={reviewerName}
              disabled={isAnonymous}
              maxLength={120}
              onChange={(event) => setReviewerName(event.target.value)}
              placeholder={isAnonymous ? "Anonymous reviewer" : "Your name"}
            />
          </label>
          <label className="listing-review-checkbox">
            <input
              type="checkbox"
              checked={isAnonymous}
              onChange={(event) => setIsAnonymous(event.target.checked)}
            />
            Post anonymously
          </label>
          <label>
            Review
            <textarea
              value={comment}
              maxLength={1000}
              rows={6}
              onChange={(event) => setComment(event.target.value)}
              placeholder="What should people know about this organizer?"
            />
          </label>
          <button className="button" type="submit" disabled={isSubmitting}>
            {isSubmitting ? "Publishing..." : "Publish review"}
          </button>
          {status.message ? (
            <p className={`form-status ${status.tone}`} role="status">
              {status.message}
            </p>
          ) : null}
        </form>
      </div>
    </section>
  );
}

function ClaimListingPanel({listing}: {listing: HostListing}) {
  const [user, setUser] = useState<User | null>(null);
  const [authReady, setAuthReady] = useState(false);
  const [isSigningIn, setIsSigningIn] = useState(false);
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [status, setStatus] = useState<ClaimStatus>({
    message: "",
    tone: "",
  });

  useEffect(() => {
    return watchClaimAuthState((nextUser) => {
      setUser(nextUser);
      setAuthReady(true);
    });
  }, []);

  async function handleSignIn() {
    setIsSigningIn(true);
    setStatus({message: "", tone: ""});
    trackMarketingEvent("listing_claim_sign_in_started", {
      listing_id: listing.id,
    });
    try {
      await signInForClaim();
      trackMarketingEvent("listing_claim_signed_in", {
        listing_id: listing.id,
      });
    } catch (error) {
      setStatus({
        message:
          error instanceof Error ?
            error.message :
            "Sign-in did not complete. Please try again.",
        tone: "is-error",
      });
      trackMarketingEvent("listing_claim_sign_in_error", {
        listing_id: listing.id,
      });
    } finally {
      setIsSigningIn(false);
    }
  }

  async function handleSubmit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();
    if (!user) {
      setStatus({
        message: "Sign in before requesting this claim.",
        tone: "is-error",
      });
      return;
    }

    const form = event.currentTarget;
    const formData = new FormData(form);
    const requesterName = String(formData.get("requesterName") || "").trim();
    const requesterRole = String(formData.get("requesterRole") || "") as
      ClubClaimRole;
    const businessEmail = nullableString(formData.get("businessEmail"));
    const businessPhone = nullableString(formData.get("businessPhone"));
    const proofUrls = parseProofUrls(formData.get("proofUrls"));
    const message = nullableString(formData.get("message"));

    if (!requesterName || !requesterRole) {
      setStatus({
        message: "Add your name and role before requesting the claim.",
        tone: "is-error",
      });
      return;
    }

    if (!businessEmail && !businessPhone && proofUrls.length === 0) {
      setStatus({
        message: "Add a business contact or at least one public proof link.",
        tone: "is-error",
      });
      return;
    }

    setIsSubmitting(true);
    setStatus({message: "", tone: ""});
    trackMarketingEvent("listing_claim_submit_attempt", {
      listing_id: listing.id,
      proof_count: proofUrls.length,
      requester_role: requesterRole,
    });

    try {
      await requestClubClaim({
        clubId: listing.id,
        requesterName,
        requesterRole,
        businessEmail,
        businessPhone,
        proofUrls,
        message,
      });
      form.reset();
      setStatus({
        message: "Claim request received. Catch will review it before ownership changes.",
        tone: "is-success",
      });
      trackMarketingEvent("listing_claim_submitted", {
        listing_id: listing.id,
        proof_count: proofUrls.length,
        requester_role: requesterRole,
      });
    } catch (error) {
      setStatus({
        message:
          error instanceof Error ?
            error.message :
            "We could not submit this claim request. Please try again.",
        tone: "is-error",
      });
      trackMarketingEvent("listing_claim_submit_error", {
        listing_id: listing.id,
      });
    } finally {
      setIsSubmitting(false);
    }
  }

  if (!claimFirebaseConfigured) {
    return (
      <div className="claim-request-panel" id="claim" data-reveal>
        <div>
          <span className="ui-label">Claim this listing</span>
          <h3>Owner review is not enabled on this build.</h3>
          <p>
            Use the host application while this public claim flow is being
            connected to Firebase.
          </p>
        </div>
        <a
          className="button"
          href="/host/#founding-hosts"
          onClick={() => trackCtaClick("listing_claim_fallback", "/host/#founding-hosts")}
        >
          Apply as host
        </a>
      </div>
    );
  }

  return (
    <div className="claim-request-panel" id="claim" data-reveal>
      <div className="claim-request-panel__heading">
        <span className="ui-label">Claim this listing</span>
        <h3>Request ownership for {listing.name}</h3>
        <p>
          Approved claims attach this profile to a Catch host account before
          owner tools or responses are unlocked.
        </p>
      </div>

      <div className="claim-auth-row">
        <span>
          {user ?
            `Signed in as ${user.displayName || user.email || "Catch user"}` :
            authReady ?
              "Sign in to request ownership." :
              "Checking sign-in status."}
        </span>
        {user ? (
          <button
            className="button button--ghost"
            onClick={() => void signOutClaimUser()}
            type="button"
          >
            Sign out
          </button>
        ) : (
          <button
            className="button"
            disabled={!authReady || isSigningIn}
            onClick={() => void handleSignIn()}
            type="button"
          >
            {isSigningIn ? "Signing in..." : "Sign in"}
          </button>
        )}
      </div>

      <form className="claim-request-form" onSubmit={handleSubmit}>
        <label>
          Your name
          <input
            name="requesterName"
            autoComplete="name"
            defaultValue={user?.displayName ?? ""}
            required
          />
        </label>
        <label>
          Role
          <select name="requesterRole" defaultValue="owner" required>
            {claimRoleOptions.map((option) => (
              <option value={option.value} key={option.value}>
                {option.label}
              </option>
            ))}
          </select>
        </label>
        <label>
          Business email
          <input
            name="businessEmail"
            type="email"
            autoComplete="email"
            defaultValue={user?.email ?? ""}
          />
        </label>
        <label>
          Business phone
          <input name="businessPhone" type="tel" autoComplete="tel" />
        </label>
        <label className="span-2">
          Proof links
          <textarea
            name="proofUrls"
            rows={3}
            placeholder="Official website, Instagram, Luma, Linktree, or event page"
          />
        </label>
        <label className="span-2">
          Note for review
          <textarea
            name="message"
            rows={3}
            maxLength={1000}
            placeholder="Anything Catch should know before approving ownership"
          />
        </label>
        <button className="button" disabled={!user || isSubmitting} type="submit">
          {isSubmitting ? "Submitting..." : "Request claim"}
        </button>
        <p className={`form-status ${status.tone}`.trim()} role="status" aria-live="polite">
          {status.message}
        </p>
      </form>
    </div>
  );
}

function SiteHeader({
  brandHref: _brandHref,
  nav: _nav,
  ctaHref: _ctaHref,
  ctaLabel: _ctaLabel,
}: {
  brandHref: string;
  nav: Array<{href: string; label: string}>;
  ctaHref: string;
  ctaLabel: string;
}) {
  return (
    <CanonicalSiteHeader
      brandHref="/"
      nav={canonicalHeaderNav}
      actions={canonicalHeaderActions}
    />
  );
}

function LoopList({
  items,
  modifier,
}: {
  items: Array<{step: string; title: string; body: string}>;
  modifier?: string;
}) {
  return (
    <ol className={`loop-list ${modifier ?? ""}`.trim()}>
      {items.map((item) => (
        <li data-reveal key={item.step}>
          <span>{item.step}</span>
          <h3>{item.title}</h3>
          <p>{item.body}</p>
        </li>
      ))}
    </ol>
  );
}

function HostProductBoard() {
  return (
    <div className="product-board" aria-label="Catch host product board" data-reveal>
      <div className="product-board__nav">
        <span>Format</span>
        <span>Admission</span>
        <span>Live</span>
        <span>Report</span>
      </div>
      <div className="product-board__main">
        <article>
          <span className="ui-label">Create event</span>
          <h3>Pickleball social</h3>
          <p>Paired rotations, balanced admission, check-in required.</p>
          <div className="control-row">
            <span>Format</span>
            <strong>Racket sports</strong>
          </div>
          <div className="control-row">
            <span>Access</span>
            <strong>Invite code + public waitlist</strong>
          </div>
          <div className="control-row">
            <span>Live module</span>
            <strong>Partner switch</strong>
          </div>
        </article>
        <article className="product-board__dark">
          <span className="ui-label">Live event</span>
          <h3>Host mode</h3>
          <p>Check-in, prompts, rotations, and safety controls stay in one surface.</p>
          <div className="live-meter">
            <span>Arrival</span>
            <span>Prompt</span>
            <span>Reveal</span>
          </div>
        </article>
      </div>
    </div>
  );
}

function CreateEventWalkthrough({captures}: {captures: Record<string, CaptureRecord>}) {
  const [activeStep, setActiveStep] = useState(3);
  const step = hostCreateSteps[activeStep];
  const captureId = step.captureId ?? "host-event-setup";

  return (
    <section className="host-create-flow" aria-labelledby="host-create-flow-title">
      <div className="section-heading" data-reveal>
        <span className="ui-label">From the host app · Create flow</span>
        <h2 id="host-create-flow-title">An event goes live in five steps</h2>
        <p>
          This is the actual flow, not a brochure: details, location, schedule,
          then the two steps no ticketing tool has — a full admission policy and
          a live run-of-show guide.
        </p>
      </div>
      <div className="host-create-flow__grid">
        <div className="host-create-flow__rail" data-reveal>
          {hostCreateSteps.map((item, index) => (
            <button
              className={index === activeStep ? "is-active" : ""}
              type="button"
              aria-expanded={index === activeStep}
              onClick={() => setActiveStep(index)}
              key={item.id}
            >
              <span>0{index + 1}</span>
              <strong>{item.title}</strong>
              {index === activeStep ? <small>{item.sub}</small> : null}
            </button>
          ))}
        </div>
        <div className="host-create-flow__mock" data-reveal>
          <div className="mock-window__bar">
            <span>Create event · step {activeStep + 1}/5 · {step.title}</span>
            <div className="host-create-flow__progress" aria-hidden="true">
              {hostCreateSteps.map((item, index) => (
                <span
                  className={index <= activeStep ? "is-complete" : ""}
                  key={item.id}
                />
              ))}
            </div>
          </div>
          <div className="host-create-flow__fields">
            {step.fields.map((field) => (
              <div className={field.wide ? "is-wide" : ""} key={field.label}>
                <span className="ui-label">{field.label}</span>
                {field.options ? (
                  <div className="host-create-flow__chips" aria-label={`${field.label}: ${field.value}`}>
                    {field.options.map((option) => (
                      <b
                        className={option === field.activeOption ? "is-active" : ""}
                        key={option}
                      >
                        {option}
                      </b>
                    ))}
                  </div>
                ) : (
                  <strong>{field.value}</strong>
                )}
                {field.note ? <p>{field.note}</p> : null}
              </div>
            ))}
          </div>
          <div className="host-create-flow__actions">
            <span>Save draft</span>
            <strong>{activeStep === hostCreateSteps.length - 1 ? "Publish event" : "Next"}</strong>
          </div>
        </div>
        <div className="host-create-flow__capture" data-reveal>
          <PhoneCaptureFrame
            key={captureId}
            id={captureId}
            fallbackStep={step.title}
            captures={captures}
          />
        </div>
      </div>
    </section>
  );
}

function EventSuccessShowcase({captures}: {captures: Record<string, CaptureRecord>}) {
  const [stage, setStage] = useState("activity");
  const modules = eventSuccessModules.filter((module) => module.stage === stage);
  const captureId = stage === "after"
    ? "post-run-catch-window"
    : stage === "debrief"
      ? "host-post-event-report"
      : "host-live-console";

  return (
    <section className="event-success-showcase" aria-labelledby="event-success-showcase-title">
      <div className="section-heading" data-reveal>
        <span className="ui-label">Event Success</span>
        <h2 id="event-success-showcase-title">Optional modules, one live guide.</h2>
        <p>
          Social runs can stay lightweight. Mixers and dinners can carry full
          facilitation. Every module below maps to the live product catalog and
          keeps private catch targets out of host reporting.
        </p>
      </div>
      <div className="event-success-stage-rail" data-reveal>
        {eventSuccessStages.map((item, index) => (
          <button
            className={item.id === stage ? "is-active" : ""}
            type="button"
            onClick={() => setStage(item.id)}
            key={item.id}
          >
            <span>0{index + 1}</span>
            <strong>{item.label}</strong>
            <small>{item.sub}</small>
          </button>
        ))}
      </div>
      <div className="event-success-showcase__grid">
        <div className="event-success-module-grid" data-reveal>
          {modules.map((module) => (
            <article key={module.title}>
              <span className="ui-label">{module.stage}</span>
              <h3>{module.title}</h3>
              <p><strong>For attendees:</strong> {module.attendee}</p>
              <p><strong>For hosts:</strong> {module.host}</p>
            </article>
          ))}
        </div>
        <CaptureCard id={captureId} fallbackStep="Event Success" captures={captures} />
      </div>
      <div className="privacy-guardrail" data-reveal>
        <strong>Guardrails are part of the product.</strong>
        Hosts see aggregate coaching, never who caught whom. Attendees can opt
        out of live modules, and blocked pairs are never assigned together.
      </div>
    </section>
  );
}

function HostComparisonSection() {
  const [open, setOpen] = useState(false);
  const comparisonTableRef = useRef<HTMLDivElement | null>(null);

  useEffect(() => {
    if (!open) {
      return;
    }
    const frameId = window.requestAnimationFrame(() => {
      comparisonTableRef.current?.scrollIntoView({behavior: "smooth", block: "start"});
    });
    return () => window.cancelAnimationFrame(frameId);
  }, [open]);

  return (
    <section className="host-comparison" aria-labelledby="host-comparison-title">
      <div className="section-heading" data-reveal>
        <span className="ui-label">The honest comparison</span>
        <h2 id="host-comparison-title">Announcing an event is solved. Running one is not.</h2>
      </div>
      <div className="host-comparison__split">
        <article data-reveal>
          <span className="ui-label">Luma · Eventbrite · District · BookMyShow · Instagram · WhatsApp · Forms</span>
          <h3>They help you publish, sell, or get discovered.</h3>
          <p>
            Useful reach, event pages, and payments. Then social hosts still
            assemble admissions, ratios, door proof, follow-up, and reputation
            signals across scattered tools.
          </p>
        </article>
        <article data-reveal>
          <span className="ui-label">Catch</span>
          <h3>Catch fills it, runs it, and proves it.</h3>
          <p>
            Admission rules, waitlists, check-in, live console, attendance proof,
            post-event matching, verified reviews, and host reports stay in one loop.
          </p>
        </article>
      </div>
      <button
        className="see-all-button"
        type="button"
        aria-expanded={open}
        aria-controls="host-comparison-table"
        onClick={() => setOpen((current) => !current)}
      >
        {open ? "Hide full comparison" : "See full comparison"}
      </button>
      {open ? (
        <>
          <div
            className="comparison-table-heading"
            id="host-comparison-table"
            ref={comparisonTableRef}
            data-reveal
            tabIndex={-1}
          >
            <span className="ui-label">Full table</span>
            <p>
              District and BookMyShow are strong Indian discovery and ticketing
              surfaces. Catch is positioned around the host operating loop after the
              listing goes live.
            </p>
          </div>
          <div className="comparison-table-wrap" data-reveal>
            <table className="comparison-table" aria-label="Host platform comparison">
              <thead>
                <tr>
                  <th>Capability</th>
                  {hostComparisonColumns.map((column) => (
                    <th key={column}>{column}</th>
                  ))}
                </tr>
              </thead>
              <tbody>
                {hostComparisonRows.map((row) => (
                  <tr key={row[0]}>
                    <td>{row[0]}</td>
                    {row.slice(1).map((value, index) => (
                      <td key={`${row[0]}-${index}`} data-value={value}>
                        {value === "yes" ? "Yes" : value === "partial" ? "Partial" : "No"}
                      </td>
                    ))}
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </>
      ) : null}
    </section>
  );
}

function CaptureCard({
  id,
  fallbackStep,
  captures,
}: {
  id: string;
  fallbackStep: string;
  captures: Record<string, CaptureRecord>;
}) {
  return <CanonicalCaptureCard id={id} fallbackStep={fallbackStep} captures={captures} />;
}

function PhoneCaptureFrame({
  id,
  fallbackStep,
  captures,
}: {
  id: string;
  fallbackStep: string;
  captures: Record<string, CaptureRecord>;
}) {
  const capture = captures[id];
  const imagePath = capture?.webPath ?? `/assets/app-screenshots/placeholders/${id}.svg`;

  return (
    <figure className="phone-capture" data-capture-slot={id}>
      <div className="phone-capture__device">
        <span className="phone-capture__notch" aria-hidden="true" />
        <div className="phone-capture__screen">
          <img
            src={imagePath}
            alt={capture?.alt ?? `${fallbackStep} app screenshot`}
            loading="lazy"
          />
        </div>
      </div>
      <figcaption>{capture?.caption ?? `${fallbackStep} in the Catch app`}</figcaption>
    </figure>
  );
}

function HostApplicationFlow() {
  const [draft, setDraft] = useState<HostApplicationDraft>(initialHostApplicationDraft);
  const [step, setStep] = useState<HostApplicationStep>("profile");
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [hasStarted, setHasStarted] = useState(false);
  const [submitted, setSubmitted] = useState(false);
  const [status, setStatus] = useState<{message: string; tone: StatusTone}>({
    message: "",
    tone: "",
  });

  const currentStepIndex = hostApplicationSteps.findIndex((item) => item.id === step);
  const resolvedCity = draft.city === "Other" ? draft.customCity.trim() : draft.city;
  const canContinue = hostApplicationStepIsComplete(step, draft);

  function updateDraft<K extends keyof HostApplicationDraft>(
    key: K,
    value: HostApplicationDraft[K]
  ) {
    setDraft((current) => ({...current, [key]: value}));
  }

  function toggleDraftList(key: "formats" | "eventSuccessModules", value: string) {
    setDraft((current) => {
      const values = current[key];
      const next = values.includes(value)
        ? values.filter((item) => item !== value)
        : [...values, value];
      return {...current, [key]: next};
    });
  }

  function handleFormStart() {
    if (hasStarted) return;
    setHasStarted(true);
    trackMarketingEvent("host_operating_application_started", {
      form_variant: "host",
    });
  }

  function goNext() {
    if (!canContinue) {
      setStatus({
        message: hostApplicationStepError(step),
        tone: "is-error",
      });
      return;
    }
    const next = hostApplicationSteps[currentStepIndex + 1];
    if (next) {
      setStatus({message: "", tone: ""});
      setStep(next.id);
    }
  }

  function goBack() {
    const previous = hostApplicationSteps[currentStepIndex - 1];
    if (previous) setStep(previous.id);
  }

  async function handleSubmit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();
    if (!hostApplicationIsComplete(draft)) {
      setStatus({
        message: "Finish the required profile, event, and operating fields before submitting.",
        tone: "is-error",
      });
      return;
    }

    const eventId = createMarketingEventId("host_lead");
    const conversionPayload = waitlistAnalyticsPayload(eventId, "host");
    const body = {
      fullName: draft.fullName.trim(),
      email: draft.email.trim(),
      city: resolvedCity,
      role: "host",
      instagram: draft.communityLink.trim(),
      website: "",
      hostApplication: {
        organizationName: draft.organizationName.trim(),
        organizationType: draft.organizationType,
        operatingCity: resolvedCity,
        communityLink: draft.communityLink.trim(),
        formats: draft.formats,
        eventCadence: draft.eventCadence,
        nextEventName: draft.nextEventName.trim(),
        nextEventDate: draft.nextEventDate,
        eventLocation: draft.eventLocation.trim(),
        expectedCapacity: draft.expectedCapacity,
        priceRange: draft.priceRange,
        admissionModel: draft.admissionModel,
        waitlistPlan: draft.waitlistPlan,
        paymentReadiness: draft.paymentReadiness,
        eventSuccessModules: draft.eventSuccessModules,
        hostGoals: draft.hostGoals.trim(),
        operatingNotes: draft.operatingNotes.trim(),
      },
      ...conversionPayload,
    };

    setIsSubmitting(true);
    setStatus({message: "", tone: ""});
    trackMarketingEvent("host_operating_application_submit_attempt", {
      city: body.city,
      event_id: eventId,
      format_count: draft.formats.length,
      module_count: draft.eventSuccessModules.length,
    });

    try {
      const response = await fetch("/api/join-waitlist", {
        method: "POST",
        headers: {"Content-Type": "application/json"},
        body: JSON.stringify(body),
      });
      const data = (await response.json().catch(() => ({}))) as {
        alreadyJoined?: boolean;
        error?: string;
      };

      if (!response.ok) {
        throw new Error(
          typeof data.error === "string"
            ? data.error
            : "We couldn't submit the host application. Please try again."
        );
      }

      setSubmitted(true);
      setStatus({
        message: data.alreadyJoined
          ? "Application updated. Catch refreshed your operating packet."
          : "Application submitted. Catch will review the host packet before onboarding.",
        tone: "is-success",
      });
      trackMarketingEvent("host_operating_application_submitted", {
        already_joined: Boolean(data.alreadyJoined),
        city: body.city,
        event_id: eventId,
        format_count: draft.formats.length,
        module_count: draft.eventSuccessModules.length,
      });
      trackMarketingEvent("generate_lead", {
        city: body.city,
        event_id: eventId,
        form_variant: "host",
        lead_type: "host",
      });
    } catch (error) {
      setStatus({
        message:
          error instanceof Error ?
            error.message :
            "We couldn't submit the host application. Please try again.",
        tone: "is-error",
      });
      trackMarketingEvent("host_operating_application_submit_error", {
        event_id: eventId,
      });
    } finally {
      setIsSubmitting(false);
    }
  }

  return (
    <form
      className="host-application"
      onFocus={handleFormStart}
      onSubmit={handleSubmit}
    >
      <nav className="operational-step-rail" aria-label="Host application steps">
        {hostApplicationSteps.map((item, index) => (
          <button
            className={index === currentStepIndex ? "is-active" : index < currentStepIndex ? "is-done" : ""}
            key={item.id}
            onClick={() => setStep(item.id)}
            type="button"
          >
            <span>{String(index + 1).padStart(2, "0")}</span>
            <strong>{item.label}</strong>
            <small>{item.body}</small>
          </button>
        ))}
      </nav>

      <div className="host-application__panel">
        {submitted ? (
          <div className="host-application__submitted">
            <span className="submitted-panel__mark">✓</span>
            <div>
              <span className="ui-label">Host application received</span>
              <h3>Catch has the operating packet for {draft.organizationName || "your host profile"}.</h3>
              <p>
                Approval still has to happen before the website can create clubs,
                events, payouts, or owner dashboards on your behalf.
              </p>
            </div>
          </div>
        ) : null}

        {!submitted && step === "profile" ? (
          <div className="host-application__stage">
            <div className="flow-field-grid">
              <div className="field-block">
                <label htmlFor="host-full-name">Full name</label>
                <input
                  id="host-full-name"
                  value={draft.fullName}
                  autoComplete="name"
                  onChange={(event) => updateDraft("fullName", event.currentTarget.value)}
                  required
                />
              </div>
              <div className="field-block">
                <label htmlFor="host-email">Email</label>
                <input
                  id="host-email"
                  value={draft.email}
                  type="email"
                  autoComplete="email"
                  onChange={(event) => updateDraft("email", event.currentTarget.value)}
                  required
                />
              </div>
              <div className="field-block">
                <label htmlFor="host-city">Operating city</label>
                <select
                  id="host-city"
                  value={draft.city}
                  onChange={(event) => updateDraft("city", event.currentTarget.value)}
                  required
                >
                  {cities.map((city) => (
                    <option key={city}>{city}</option>
                  ))}
                </select>
              </div>
              {draft.city === "Other" ? (
                <div className="field-block">
                  <label htmlFor="host-custom-city">Your city</label>
                  <input
                    id="host-custom-city"
                    value={draft.customCity}
                    autoComplete="address-level2"
                    onChange={(event) => updateDraft("customCity", event.currentTarget.value)}
                    required
                  />
                </div>
              ) : null}
              <div className="field-block">
                <label htmlFor="host-org-name">Organizer, venue, or community name</label>
                <input
                  id="host-org-name"
                  value={draft.organizationName}
                  onChange={(event) => updateDraft("organizationName", event.currentTarget.value)}
                  required
                />
              </div>
              <div className="field-block">
                <label htmlFor="host-org-type">Host type</label>
                <select
                  id="host-org-type"
                  value={draft.organizationType}
                  onChange={(event) => updateDraft("organizationType", event.currentTarget.value)}
                >
                  <option>Independent host</option>
                  <option>Run club</option>
                  <option>Venue</option>
                  <option>Community</option>
                  <option>Event company</option>
                </select>
              </div>
              <div className="field-block span-2">
                <label htmlFor="host-community-link">Community or venue link</label>
                <input
                  id="host-community-link"
                  value={draft.communityLink}
                  autoComplete="url"
                  placeholder="Instagram, website, Luma, Linktree, or venue page"
                  onChange={(event) => updateDraft("communityLink", event.currentTarget.value)}
                  required
                />
              </div>
            </div>
          </div>
        ) : null}

        {!submitted && step === "event" ? (
          <div className="host-application__stage">
            <div className="field-block span-2">
              <label>Formats you want to run</label>
              <div className="choice-chip-grid">
                {hostFormatOptions.map((format) => (
                  <button
                    className={draft.formats.includes(format) ? "choice-chip is-selected" : "choice-chip"}
                    key={format}
                    onClick={() => toggleDraftList("formats", format)}
                    type="button"
                  >
                    {format}
                  </button>
                ))}
              </div>
            </div>
            <div className="flow-field-grid">
              <div className="field-block">
                <label htmlFor="host-event-cadence">Cadence</label>
                <select
                  id="host-event-cadence"
                  value={draft.eventCadence}
                  onChange={(event) => updateDraft("eventCadence", event.currentTarget.value)}
                >
                  <option>Weekly</option>
                  <option>Biweekly</option>
                  <option>Monthly</option>
                  <option>Quarterly</option>
                  <option>One-off launch</option>
                </select>
              </div>
              <div className="field-block">
                <label htmlFor="host-event-name">First Catch event</label>
                <input
                  id="host-event-name"
                  value={draft.nextEventName}
                  placeholder="Long table no. 1, Saturday run, singles mixer"
                  onChange={(event) => updateDraft("nextEventName", event.currentTarget.value)}
                  required
                />
              </div>
              <div className="field-block">
                <label htmlFor="host-event-date">Target date</label>
                <input
                  id="host-event-date"
                  value={draft.nextEventDate}
                  type="date"
                  onChange={(event) => updateDraft("nextEventDate", event.currentTarget.value)}
                />
              </div>
              <div className="field-block">
                <label htmlFor="host-event-location">Venue or meeting area</label>
                <input
                  id="host-event-location"
                  value={draft.eventLocation}
                  onChange={(event) => updateDraft("eventLocation", event.currentTarget.value)}
                  required
                />
              </div>
            </div>
          </div>
        ) : null}

        {!submitted && step === "policy" ? (
          <div className="host-application__stage">
            <div className="flow-field-grid">
              <div className="field-block">
                <label htmlFor="host-capacity">Expected capacity</label>
                <input
                  id="host-capacity"
                  value={draft.expectedCapacity}
                  inputMode="numeric"
                  onChange={(event) => updateDraft("expectedCapacity", event.currentTarget.value)}
                  required
                />
              </div>
              <div className="field-block">
                <label htmlFor="host-price-range">Price range</label>
                <input
                  id="host-price-range"
                  value={draft.priceRange}
                  onChange={(event) => updateDraft("priceRange", event.currentTarget.value)}
                />
              </div>
              <div className="field-block">
                <label htmlFor="host-admission">Admission model</label>
                <select
                  id="host-admission"
                  value={draft.admissionModel}
                  onChange={(event) => updateDraft("admissionModel", event.currentTarget.value)}
                >
                  <option>Open booking</option>
                  <option>Request to join</option>
                  <option>Invite-only</option>
                  <option>Balanced ratio</option>
                  <option>Members-only</option>
                </select>
              </div>
              <div className="field-block">
                <label htmlFor="host-waitlist-plan">Waitlist plan</label>
                <select
                  id="host-waitlist-plan"
                  value={draft.waitlistPlan}
                  onChange={(event) => updateDraft("waitlistPlan", event.currentTarget.value)}
                >
                  <option>Ranked timed offers</option>
                  <option>Manual review</option>
                  <option>Broadcast first come first served</option>
                  <option>No waitlist</option>
                </select>
              </div>
              <div className="field-block span-2">
                <label htmlFor="host-payment">Payment readiness</label>
                <select
                  id="host-payment"
                  value={draft.paymentReadiness}
                  onChange={(event) => updateDraft("paymentReadiness", event.currentTarget.value)}
                >
                  <option>Need Catch payment onboarding</option>
                  <option>Already sell paid tickets</option>
                  <option>Free events first</option>
                  <option>Sponsor or venue-funded</option>
                </select>
              </div>
            </div>
          </div>
        ) : null}

        {!submitted && step === "success" ? (
          <div className="host-application__stage">
            <div className="field-block span-2">
              <label>Event Success modules to start with</label>
              <div className="choice-chip-grid">
                {hostSuccessModuleOptions.map((module) => (
                  <button
                    className={draft.eventSuccessModules.includes(module) ? "choice-chip is-selected" : "choice-chip"}
                    key={module}
                    onClick={() => toggleDraftList("eventSuccessModules", module)}
                    type="button"
                  >
                    {module}
                  </button>
                ))}
              </div>
            </div>
            <div className="flow-field-grid">
              <div className="field-block span-2">
                <label htmlFor="host-goals">What should Catch help you improve?</label>
                <textarea
                  id="host-goals"
                  value={draft.hostGoals}
                  rows={3}
                  placeholder="Better gender balance, less awkward arrivals, verified reviews, repeat attendance..."
                  onChange={(event) => updateDraft("hostGoals", event.currentTarget.value)}
                  required
                />
              </div>
              <div className="field-block span-2">
                <label htmlFor="host-operating-notes">Operating notes</label>
                <textarea
                  id="host-operating-notes"
                  value={draft.operatingNotes}
                  rows={3}
                  placeholder="Constraints, safety needs, venue rules, approval preferences, payout timing, or launch questions"
                  onChange={(event) => updateDraft("operatingNotes", event.currentTarget.value)}
                />
              </div>
            </div>
          </div>
        ) : null}

        {!submitted && step === "review" ? (
          <div className="host-application__stage">
            <div className="host-application__review">
              <HostApplicationSummary title="Profile" rows={[
                ["Host", draft.fullName],
                ["Organization", draft.organizationName],
                ["City", resolvedCity],
                ["Link", draft.communityLink],
              ]} />
              <HostApplicationSummary title="First event" rows={[
                ["Formats", draft.formats.join(", ")],
                ["Event", draft.nextEventName],
                ["Location", draft.eventLocation],
                ["Cadence", draft.eventCadence],
              ]} />
              <HostApplicationSummary title="Operations" rows={[
                ["Capacity", draft.expectedCapacity],
                ["Admission", draft.admissionModel],
                ["Waitlist", draft.waitlistPlan],
                ["Payment", draft.paymentReadiness],
              ]} />
              <HostApplicationSummary title="Event Success" rows={[
                ["Modules", draft.eventSuccessModules.join(", ")],
                ["Goal", draft.hostGoals],
              ]} />
            </div>
            <div className="operational-note">
              <strong>What this does now</strong>
              <p>
                This submits a real host lead packet for review. Creating clubs,
                events, payout accounts, and owner dashboards still requires
                approval because those backend callables are host-authenticated.
              </p>
            </div>
          </div>
        ) : null}

        <div className="host-application__summary">
          <div>
            <span className="ui-label">Application completeness</span>
            <ProfileStrength value={hostApplicationCompleteness(draft)} />
          </div>
          <ul>
            {hostApplicationChecklist(draft).map((item) => (
              <li className={item.done ? "is-done" : ""} key={item.label}>
                <span>{item.done ? "✓" : "·"}</span>{item.label}
              </li>
            ))}
          </ul>
        </div>

        {!submitted ? (
          <div className="flow-actions">
            <button
              className="button button--ghost"
              disabled={currentStepIndex === 0}
              onClick={goBack}
              type="button"
            >
              Back
            </button>
            {step === "review" ? (
              <button className="button" disabled={isSubmitting} type="submit">
                {isSubmitting ? "Submitting..." : "Submit host packet"}
              </button>
            ) : (
              <button className="button" onClick={goNext} type="button">
                Continue
              </button>
            )}
          </div>
        ) : (
          <div className="flow-actions">
            <a className="button button--ghost" href="/organizers/">
              Browse organizer pages
            </a>
            <a className="button" href="/claim/">
              Claim an existing listing
            </a>
          </div>
        )}

        <p className={`form-status ${status.tone}`.trim()} role="status" aria-live="polite">
          {status.message}
        </p>
      </div>
    </form>
  );
}

function HostApplicationSummary({
  title,
  rows,
}: {
  title: string;
  rows: Array<[string, string]>;
}) {
  return (
    <article>
      <span className="ui-label">{title}</span>
      <dl>
        {rows.map(([label, value]) => (
          <div key={label}>
            <dt>{label}</dt>
            <dd>{value || "Not provided"}</dd>
          </div>
        ))}
      </dl>
    </article>
  );
}

function WaitlistForm({variant}: {variant: FormVariant}) {
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [status, setStatus] = useState<{message: string; tone: StatusTone}>({
    message: "",
    tone: "",
  });
  const [showCustomCity, setShowCustomCity] = useState(false);
  const [hasStarted, setHasStarted] = useState(false);

  const roleOptions = useMemo(
    () =>
      variant === "host"
        ? [
            {value: "host", label: "Host"},
            {value: "both", label: "Host and member"},
          ]
        : [
            {value: "", label: "Choose role"},
            {value: "member", label: "Member"},
            {value: "host", label: "Host"},
            {value: "both", label: "Both"},
          ],
    [variant]
  );

  async function handleSubmit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();
    const form = event.currentTarget;
    const payload = new FormData(form);
    const cityValue =
      payload.get("city") === "Other"
        ? String(payload.get("customCity") || "").trim()
        : String(payload.get("city") || "").trim();

    const eventId = createMarketingEventId(
      variant === "host" ? "host_lead" : "waitlist"
    );
    const conversionPayload = waitlistAnalyticsPayload(eventId, variant);
    const body = {
      fullName: String(payload.get("fullName") || "").trim(),
      email: String(payload.get("email") || "").trim(),
      city: cityValue,
      role: String(payload.get("role") || "").trim(),
      instagram: String(payload.get("instagram") || "").trim(),
      website: String(payload.get("website") || "").trim(),
      ...conversionPayload,
    };

    if (!body.fullName || !body.email || !body.city || !body.role) {
      setStatus({
        message: "Please fill out your name, email, city, and role.",
        tone: "is-error",
      });
      return;
    }

    setIsSubmitting(true);
    setStatus({message: "", tone: ""});
    trackMarketingEvent(
      variant === "host" ? "host_lead_submit_attempt" : "waitlist_submit_attempt",
      {city: body.city, event_id: eventId, form_variant: variant, role: body.role}
    );

    try {
      const response = await fetch("/api/join-waitlist", {
        method: "POST",
        headers: {"Content-Type": "application/json"},
        body: JSON.stringify(body),
      });
      const data = (await response.json().catch(() => ({}))) as {
        alreadyJoined?: boolean;
        error?: string;
      };

      if (!response.ok) {
        throw new Error(
          typeof data.error === "string"
            ? data.error
            : "We couldn't save your spot. Please try again."
        );
      }

      form.reset();
      setShowCustomCity(false);
      setHasStarted(false);
      setStatus({
        message: data.alreadyJoined
          ? "You're already on the list. We refreshed your details."
          : "You're in. We'll reach out when Catch opens in your city.",
        tone: "is-success",
      });
      trackMarketingEvent(
        variant === "host" ? "host_lead_submitted" : "waitlist_submitted",
        {
          already_joined: Boolean(data.alreadyJoined),
          city: body.city,
          event_id: eventId,
          form_variant: variant,
          role: body.role,
        }
      );
      trackMarketingEvent("generate_lead", {
        city: body.city,
        event_id: eventId,
        form_variant: variant,
        lead_type: variant === "host" ? "host" : "member",
      });
    } catch (error) {
      setStatus({
        message:
          error instanceof Error
            ? error.message
            : "We couldn't save your spot. Please try again.",
        tone: "is-error",
      });
      trackMarketingEvent("lead_submit_error", {
        event_id: eventId,
        form_variant: variant,
      });
    } finally {
      setIsSubmitting(false);
    }
  }

  function handleFormStart() {
    if (hasStarted) return;
    setHasStarted(true);
    trackMarketingEvent(
      variant === "host" ? "host_lead_started" : "waitlist_started",
      {form_variant: variant}
    );
  }

  return (
    <form className="waitlist-form" onFocus={handleFormStart} onSubmit={handleSubmit}>
      <label>
        Full name
        <input name="fullName" autoComplete="name" required />
      </label>
      <label>
        Email
        <input name="email" type="email" autoComplete="email" required />
      </label>
      <label>
        City
        <select
          name="city"
          required
          onChange={(event) => {
            const city = event.currentTarget.value;
            setShowCustomCity(city === "Other");
            if (city) {
              trackMarketingEvent("city_selected", {
                city,
                form_variant: variant,
              });
            }
          }}
        >
          <option value="">Choose city</option>
          {cities.map((city) => (
            <option key={city}>{city}</option>
          ))}
        </select>
      </label>
      <label hidden={!showCustomCity}>
        Your city
        <input name="customCity" autoComplete="address-level2" required={showCustomCity} />
      </label>
      <label>
        Joining as
        <select
          name="role"
          required
          defaultValue={variant === "host" ? "host" : ""}
          onChange={(event) => {
            if (event.currentTarget.value) {
              trackMarketingEvent("role_selected", {
                form_variant: variant,
                role: event.currentTarget.value,
              });
            }
          }}
        >
          {roleOptions.map((option) => (
            <option value={option.value} key={option.value || option.label}>
              {option.label}
            </option>
          ))}
        </select>
      </label>
      <label>
        {variant === "host" ? "Community or venue link" : "Instagram or community link"}
        <input name="instagram" autoComplete="url" />
      </label>
      <input
        className="honeypot"
        name="website"
        tabIndex={-1}
        autoComplete="off"
        aria-hidden="true"
      />
      <button className="button" type="submit" disabled={isSubmitting}>
        {isSubmitting ? (variant === "host" ? "Applying..." : "Joining...") : variant === "host" ? "Apply as host" : "Join the list"}
      </button>
      <p className={`form-status ${status.tone}`.trim()} role="status" aria-live="polite">
        {status.message}
      </p>
    </form>
  );
}

function MarketingConsentBanner() {
  const [consent, setConsent] = useState(() => getMarketingConsent());

  if (consent) return null;

  return (
    <aside className="consent-banner" aria-label="Analytics consent">
      <p>
        Catch uses analytics and ad measurement to understand which campaigns
        bring real waitlist and host demand.
      </p>
      <div>
        <button
          className="button button--small"
          type="button"
          onClick={() => setConsent(setMarketingConsent("accepted"))}
        >
          Accept all
        </button>
        <button
          className="button button--small button--ghost"
          type="button"
          onClick={() => setConsent(setMarketingConsent("essential"))}
        >
          Essential only
        </button>
      </div>
    </aside>
  );
}

function SiteFooter({
  brandHref,
  body,
  links,
}: {
  brandHref: string;
  body: string;
  links: Array<{href: string; label: string}>;
}) {
  return <CanonicalSiteFooter brandHref={brandHref} body={body} links={links} />;
}

function useDocumentMeta(meta: PageMeta) {
  useEffect(() => {
    document.title = meta.title;
    setMetaContent("description", meta.description);
    setMetaProperty("og:title", meta.title);
    setMetaProperty("og:description", meta.description);
    setMetaProperty("og:type", "website");
    setMetaProperty("og:url", `https://catchdates.com${meta.canonicalPath}`);
    setMetaContent("twitter:card", "summary_large_image");
    setMetaContent("twitter:title", meta.title);
    setMetaContent("twitter:description", meta.twitterDescription);
    setCanonical(`https://catchdates.com${meta.canonicalPath}`);
    setOptionalMetaContent("robots", meta.robots);
  }, [meta]);
}

function useMarketingAnalytics(page: PageKey) {
  useEffect(() => {
    initializeMarketingAnalytics();
    trackPageView(page);
  }, [page]);
}

function useRevealAnimations(page: PageKey) {
  useEffect(() => {
    const revealItems = Array.from(document.querySelectorAll<HTMLElement>("[data-reveal]"));
    revealItems.forEach((item, index) => {
      item.style.transitionDelay = `${(index % 4) * 80}ms`;
    });

    const prefersReducedMotion = window.matchMedia("(prefers-reduced-motion: reduce)").matches;
    if (prefersReducedMotion || !("IntersectionObserver" in window)) {
      revealItems.forEach((item) => item.classList.add("is-visible"));
      return undefined;
    }

    const observer = new IntersectionObserver(
      (entries, currentObserver) => {
        entries.forEach((entry) => {
          if (!entry.isIntersecting) return;
          entry.target.classList.add("is-visible");
          currentObserver.unobserve(entry.target);
        });
      },
      {threshold: 0.15, rootMargin: "0px 0px -40px 0px"}
    );

    revealItems.forEach((item) => observer.observe(item));
    return () => observer.disconnect();
  }, [page]);
}

function useHashScroll(page: PageKey) {
  useEffect(() => {
    if (!window.location.hash) return undefined;
    const frameIds: number[] = [];
    const timeoutIds: number[] = [];
    const scrollToHash = () => {
      if (!window.location.hash) return;
      const hash = decodeURIComponent(window.location.hash.slice(1));
      document.getElementById(hash)?.scrollIntoView({block: "start"});
    };
    const scheduleScroll = () => {
      frameIds.push(window.requestAnimationFrame(scrollToHash));
      timeoutIds.push(
        window.setTimeout(scrollToHash, 150),
        window.setTimeout(scrollToHash, 500),
        window.setTimeout(scrollToHash, 900)
      );
    };
    scheduleScroll();
    window.addEventListener("hashchange", scheduleScroll);
    return () => {
      frameIds.forEach((frame) => window.cancelAnimationFrame(frame));
      timeoutIds.forEach((timeout) => window.clearTimeout(timeout));
      window.removeEventListener("hashchange", scheduleScroll);
    };
  }, [page]);
}

function useMarketingCaptures() {
  const [captures, setCaptures] = useState<Record<string, CaptureRecord>>({});

  useEffect(() => {
    let isActive = true;
    fetch("/assets/app-screenshots/manifest.json", {cache: "no-cache"})
      .then((response) => (response.ok ? response.json() : null))
      .then((manifest: CaptureManifest | null) => {
        if (!isActive || !Array.isArray(manifest?.captures)) return;
        const byId: Record<string, CaptureRecord> = {};
        for (const capture of manifest.captures) {
          byId[capture.id] = capture;
        }
        setCaptures(byId);
      })
      .catch(() => {
        // Local static pages can run without a fetchable manifest.
      });

    return () => {
      isActive = false;
    };
  }, []);

  return captures;
}

function buildPublicEventSummaries(listings: HostListing[]): PublicEventCardModel[] {
  const now = Date.now();
  return listings
    .flatMap((listing) =>
      (listing.catchEvents ?? []).map((event) => {
        const activity = activityForKind(event.activityKind);
        const sortTime = Date.parse(event.startTime);
        return {
          sortTime: Number.isFinite(sortTime) ? sortTime : 0,
          model: {
            id: `${listing.id}-${event.id}`,
            title: event.title,
            href: eventDeepLinkForListing(listing, event),
            hostName: listing.name,
            activityLabel: activity.label,
            activityToken: activity.token,
            city: listing.city,
            date: event.date,
            location: event.location,
            priceLabel: event.priceLabel,
            bookedCount: event.bookedCount,
            capacityLimit: event.capacityLimit,
            waitlistedCount: event.waitlistedCount,
            summary: event.summary || listing.description,
          },
        };
      })
    )
    .sort((a, b) => {
      const aFuture = a.sortTime >= now;
      const bFuture = b.sortTime >= now;
      if (aFuture !== bFuture) return aFuture ? -1 : 1;
      return aFuture ? a.sortTime - b.sortTime : b.sortTime - a.sortTime;
    })
    .map((item) => item.model);
}

function buildPublicSearchSuggestions(
  listings: HostListing[],
  events: PublicEventCardModel[]
): PublicSearchSuggestion[] {
  const formatSuggestions = new Map<string, PublicSearchSuggestion>();
  for (const listing of listings) {
    for (const format of listing.formats) {
      const key = format.toLowerCase();
      if (formatSuggestions.has(key)) continue;
      const activity = activityForListing(listing);
      formatSuggestions.set(key, {
        id: `format-${key.replace(/[^a-z0-9]+/g, "-")}`,
        href: `/organizers/?q=${encodeURIComponent(format)}`,
        label: format,
        meta: `Browse ${format.toLowerCase()} organizers`,
        type: "format",
        activityToken: activity.token,
      });
    }
  }

  return [
    ...events.map((event) => ({
      id: `event-${event.id}`,
      href: event.href,
      label: event.title,
      meta: `${event.hostName} · ${event.city} · ${event.date}`,
      type: "event" as const,
      activityToken: event.activityToken,
    })),
    ...listings.map((listing) => {
      const activity = activityForListing(listing);
      return {
        id: `organizer-${listing.id}`,
        href: listing.path,
        label: listing.name,
        meta: `${listing.category} · ${listing.city} · ${listing.status}`,
        type: "organizer" as const,
        activityToken: activity.token,
      };
    }),
    ...formatSuggestions.values(),
  ];
}

function defaultOrganizerDirectoryFilters(): OrganizerDirectoryFilters {
  return {
    query: "",
    statusFilter: "all",
    formatFilter: "all",
    cityFilter: "all",
    upcomingOnly: false,
    minRating: 0,
    sort: "relevance",
  };
}

function readOrganizerFiltersFromUrl(
  cityOptions: string[],
  formatOptions: string[]
): OrganizerDirectoryFilters {
  const params = new URLSearchParams(window.location.search);
  const status = params.get("status");
  const sort = params.get("sort");
  const city = params.get("city");
  const format = params.get("format");
  const rating = Number(params.get("rating") ?? 0);
  return {
    query: params.get("q") ?? "",
    statusFilter: isOrganizerStatusFilter(status) ? status : "all",
    formatFilter: filterOptionValue(format, formatOptions),
    cityFilter: filterOptionValue(city, cityOptions),
    upcomingOnly: ["1", "true", "yes"].includes((params.get("upcoming") ?? "").toLowerCase()),
    minRating: [4, 4.5].includes(rating) ? rating : 0,
    sort: isOrganizerSort(sort) ? sort : "relevance",
  };
}

function replaceOrganizerDirectoryUrl(filters: OrganizerDirectoryFilters) {
  const params = new URLSearchParams();
  const normalizedQuery = filters.query.trim();
  if (normalizedQuery) params.set("q", normalizedQuery);
  if (filters.cityFilter !== "all") params.set("city", filters.cityFilter);
  if (filters.formatFilter !== "all") params.set("format", filters.formatFilter);
  if (filters.statusFilter !== "all") params.set("status", filters.statusFilter);
  if (filters.upcomingOnly) params.set("upcoming", "true");
  if (filters.minRating > 0) params.set("rating", String(filters.minRating));
  if (filters.sort !== "relevance") params.set("sort", filters.sort);

  const nextPath = params.toString() ? `/organizers/?${params}` : "/organizers/";
  const currentPath = `${window.location.pathname}${window.location.search}`;
  if (currentPath !== nextPath) {
    window.history.replaceState(null, "", nextPath);
  }
}

function filterOptionValue(value: string | null, options: string[]) {
  return value && options.includes(value) ? value : "all";
}

function isOrganizerStatusFilter(value: string | null): value is OrganizerStatusFilter {
  return organizerStatusFilters.includes(value as OrganizerStatusFilter);
}

function isOrganizerSort(value: string | null): value is OrganizerSort {
  return organizerSortOptions.includes(value as OrganizerSort);
}

function organizerDirectorySearchText(listing: HostListing) {
  return [
    listing.searchText,
    listing.name,
    listing.city,
    listing.region,
    listing.country,
    listing.category,
    listing.status,
    listing.headline,
    listing.description,
    listing.sourceSummary,
    listing.host?.name,
    listing.host?.role,
    ...(listing.formats ?? []),
    ...listing.facts.map((fact) => `${fact.label} ${fact.value}`),
    ...listing.sources.map((source) => `${source.label} ${source.detail} ${source.type}`),
    ...(listing.eventEvidence ?? []).flatMap((event) => [
      event.title,
      event.date,
      event.location,
      event.summary,
      event.sourceLabel,
      ...(event.facts ?? []),
    ]),
    ...(listing.catchEvents ?? []).flatMap((event) => [
      event.title,
      event.role,
      event.activityKind,
      event.timeline,
      event.date,
      event.location,
      event.summary,
      event.priceLabel,
    ]),
  ].filter(Boolean).join(" ").toLowerCase();
}

function eventHighlightsForListing(
  listing: HostListing,
  queryTerms: string[]
): OrganizerEventHighlight[] {
  const highlights: Array<OrganizerEventHighlight & {searchText: string}> = [
    ...(listing.catchEvents ?? []).map((event) => {
      const activity = activityForKind(event.activityKind);
      const isFuture = isFutureCatchEvent(event);
      const detail = [
        event.date,
        event.location,
        event.priceLabel,
        event.capacityLimit ? `${event.bookedCount}/${event.capacityLimit} booked` : null,
      ].filter(Boolean).join(" · ");
      return {
        id: `catch-${event.id}`,
        title: event.title,
        kind: isFuture ? "Future Catch event" : event.timeline === "past" ? "Past Catch event" : "Catch event",
        detail,
        href: eventDeepLinkForListing(listing, event),
        activityToken: activity.token,
        searchText: [
          event.title,
          event.role,
          event.activityKind,
          event.timeline,
          event.date,
          event.location,
          event.summary,
          event.priceLabel,
        ].filter(Boolean).join(" ").toLowerCase(),
      };
    }),
    ...(listing.eventEvidence ?? []).map((event, index) => {
      const activity = activityForListing(listing);
      const detail = [event.date, event.location, event.sourceLabel].filter(Boolean).join(" · ");
      return {
        id: `source-${listing.id}-${index}`,
        title: event.title,
        kind: "Source event",
        detail,
        href: listing.path,
        activityToken: activity.token,
        searchText: [
          event.title,
          event.date,
          event.location,
          event.summary,
          event.sourceLabel,
          ...(event.facts ?? []),
        ].filter(Boolean).join(" ").toLowerCase(),
      };
    }),
  ];

  const matched = queryTerms.length
    ? highlights.filter((event) => queryTerms.every((term) => event.searchText.includes(term)))
    : [];
  return (matched.length ? matched : highlights)
    .slice(0, 2)
    .map(({searchText: _searchText, ...event}) => event);
}

function nextFutureCatchEvent(listing: HostListing): {title: string} | null {
  const metricTime = listing.metrics?.nextEventAt ?
    Date.parse(listing.metrics.nextEventAt) :
    Number.NaN;
  if (Number.isFinite(metricTime) && metricTime >= Date.now()) {
    return {title: listing.metrics?.nextEventLabel ?? "Upcoming Catch event"};
  }

  const futureEvent = (listing.catchEvents ?? [])
    .filter(isFutureCatchEvent)
    .sort((a, b) => Date.parse(a.startTime) - Date.parse(b.startTime))[0];
  return futureEvent ? {title: futureEvent.title} : null;
}

function isFutureCatchEvent(event: HostListingCatchEvent) {
  const startTime = Date.parse(event.startTime);
  return Number.isFinite(startTime) && startTime >= Date.now();
}

function hasAnyEventSignal(listing: HostListing) {
  return Boolean(listing.catchEvents?.length || listing.eventEvidence?.length);
}

function isVerifiedListing(listing: HostListing) {
  return listing.listingVariant === "appCreatedClub" ||
    listing.sourceConfidence === "first_party";
}

function isUnclaimedListing(listing: HostListing) {
  return listing.status.toLowerCase() === "unclaimed";
}

function hasUpcomingCatchEvent(listing: HostListing) {
  return Boolean(nextFutureCatchEvent(listing));
}

function listingProfileStrength(listing: HostListing) {
  if (isVerifiedListing(listing)) {
    let value = 72;
    if (listing.catchEvents?.length) value += 8;
    if (listing.eventSuccessSummary) value += 8;
    if ((listing.metrics?.reviewCount ?? 0) > 0) value += 7;
    if (listing.host) value += 5;
    return Math.min(value, 96);
  }
  let value = listing.sourceConfidence === "high" ? 38 : 30;
  value += Math.min(listing.sources.length * 3, 9);
  value += Math.min((listing.eventEvidence?.length ?? 0) * 4, 8);
  value -= Math.min(listing.missingEvidence.length * 2, 12);
  return Math.max(24, Math.min(value, 55));
}

function activityForListing(listing: HostListing): ActivityMeta {
  const text = [
    listing.category,
    ...listing.formats,
    ...(listing.catchEvents ?? []).map((event) => event.activityKind),
  ].join(" ").toLowerCase();
  if (text.includes("dinner") || text.includes("table")) return activityMeta.dinner;
  if (text.includes("mixer") || text.includes("singles")) return activityMeta.singlesMixer;
  if (text.includes("run")) return activityMeta.socialRun;
  if (text.includes("quiz") || text.includes("trivia")) return activityMeta.pubQuiz;
  if (text.includes("padel") || text.includes("pickle") || text.includes("tennis") || text.includes("racket")) {
    return activityMeta.racket;
  }
  return activityMeta.open;
}

function activityForKind(kind: string): ActivityMeta {
  const normalized = kind.replace(/[^a-z0-9]+/gi, "").toLowerCase();
  if (normalized === "socialrun") return activityMeta.socialRun;
  if (normalized === "singlesmixer") return activityMeta.singlesMixer;
  if (normalized === "pubquiz") return activityMeta.pubQuiz;
  if (normalized === "running") return activityMeta.running;
  if (normalized === "dinner") return activityMeta.dinner;
  if (normalized === "racket" || normalized === "tennis" || normalized === "padel") {
    return activityMeta.racket;
  }
  return activityMeta.open;
}

function compareListings(a: HostListing, b: HostListing, sort: OrganizerSort) {
  if (sort === "reviews") {
    return (b.metrics?.reviewCount ?? 0) - (a.metrics?.reviewCount ?? 0);
  }
  if (sort === "rating") {
    return (b.metrics?.rating ?? 0) - (a.metrics?.rating ?? 0);
  }
  if (sort === "upcoming") {
    return Number(hasUpcomingCatchEvent(b)) - Number(hasUpcomingCatchEvent(a));
  }
  if (sort === "confidence") {
    return confidenceRank(b.sourceConfidence) - confidenceRank(a.sourceConfidence);
  }
  return listingProfileStrength(b) - listingProfileStrength(a);
}

function confidenceRank(value: string) {
  if (value === "first_party") return 4;
  if (value === "high") return 3;
  if (value === "medium") return 2;
  if (value === "low") return 1;
  return 0;
}

function hostApplicationStepIsComplete(
  step: HostApplicationStep,
  draft: HostApplicationDraft
): boolean {
  if (step === "profile") {
    return Boolean(
      draft.fullName.trim() &&
      draft.email.trim() &&
      (draft.city !== "Other" || draft.customCity.trim()) &&
      draft.organizationName.trim() &&
      draft.communityLink.trim()
    );
  }
  if (step === "event") {
    return Boolean(
      draft.formats.length &&
      draft.nextEventName.trim() &&
      draft.eventLocation.trim()
    );
  }
  if (step === "policy") {
    return Boolean(
      draft.expectedCapacity.trim() &&
      draft.priceRange.trim() &&
      draft.admissionModel &&
      draft.waitlistPlan &&
      draft.paymentReadiness
    );
  }
  if (step === "success") {
    return Boolean(draft.eventSuccessModules.length && draft.hostGoals.trim());
  }
  return hostApplicationIsComplete(draft);
}

function hostApplicationStepError(step: HostApplicationStep) {
  switch (step) {
    case "profile":
      return "Add your identity, organizer name, city, and public link.";
    case "event":
      return "Choose at least one format and describe the first event and location.";
    case "policy":
      return "Add capacity, pricing, admission, waitlist, and payment readiness.";
    case "success":
      return "Choose at least one Event Success module and add your host goal.";
    case "review":
      return "Finish the required fields before submitting.";
  }
}

function hostApplicationIsComplete(draft: HostApplicationDraft): boolean {
  return hostApplicationSteps
    .filter((item) => item.id !== "review")
    .every((item) => hostApplicationStepIsComplete(item.id, draft));
}

function hostApplicationCompleteness(draft: HostApplicationDraft) {
  const completed = hostApplicationChecklist(draft).filter((item) => item.done).length;
  return Math.round((completed / hostApplicationChecklist(draft).length) * 100);
}

function hostApplicationChecklist(draft: HostApplicationDraft) {
  return [
    {
      label: "Host identity and public link",
      done: hostApplicationStepIsComplete("profile", draft),
    },
    {
      label: "First event draft",
      done: hostApplicationStepIsComplete("event", draft),
    },
    {
      label: "Admission and payment policy",
      done: hostApplicationStepIsComplete("policy", draft),
    },
    {
      label: "Event Success setup",
      done: hostApplicationStepIsComplete("success", draft),
    },
  ];
}

function getPageKey(): Exclude<PageKey, "listing"> {
  if (window.location.pathname.startsWith("/claim")) return "claim";
  if (window.location.pathname.startsWith("/host")) return "host";
  if (window.location.pathname.startsWith("/organizers")) return "organizers";
  return "home";
}

function getHostListingForPath(pathname: string) {
  const normalizedPath = pathname.endsWith("/") ? pathname : `${pathname}/`;
  return hostListings.find((listing) => listing.path === normalizedPath) ?? null;
}

function getClaimListingFromUrl() {
  const lookup = getClaimListingLookupFromUrl();
  if (!lookup) return null;
  return hostListings.find((listing) =>
    listing.id === lookup ||
    listing.slug === lookup ||
    listing.path === lookup
  ) ?? null;
}

function getClaimListingLookupFromUrl() {
  const params = new URLSearchParams(window.location.search);
  const idOrSlug = params.get("listing") ?? params.get("clubId");
  const pathParts = window.location.pathname.split("/").filter(Boolean);
  const pathSlug = pathParts[0] === "claim" ? pathParts[1] : null;
  return idOrSlug ?? pathSlug;
}

function getClaimRequestIdFromUrl() {
  const params = new URLSearchParams(window.location.search);
  return params.get("requestId") ?? params.get("claimRequestId");
}

function claimStateForUrl(
  lookup: string | null,
  listing: HostListing | null
): ClaimUrlState {
  const params = new URLSearchParams(window.location.search);
  const status = (params.get("claimStatus") ?? params.get("status") ?? "").toLowerCase();
  if (listing && (status === "pending" || Boolean(getClaimRequestIdFromUrl()))) {
    return "pendingClaim";
  }
  if (lookup && !listing) return "notFound";
  if (listing && !isUnclaimedListing(listing)) return "alreadyClaimed";
  return null;
}

function claimHrefForListing(listing: HostListing) {
  return `/claim/?listing=${encodeURIComponent(listing.id)}`;
}

function absoluteListingUrl(listing: HostListing) {
  return `${window.location.origin}${listing.path}`;
}

function eventAnchorId(event: HostListingCatchEvent) {
  return `event-${event.id}`;
}

function eventDeepLinkForListing(
  listing: HostListing,
  event: HostListingCatchEvent
) {
  return `${listing.path}#${eventAnchorId(event)}`;
}

function eventActionCardForListing(
  listing: HostListing,
  event: HostListingCatchEvent
): EventActionCardModel {
  const isFuture = isFutureCatchEvent(event);
  const activity = activityForKind(event.activityKind);
  const actions: EventActionCardModel["actions"] = [
    {
      href: eventDeepLinkForListing(listing, event),
      label: isFuture ? "Open event link" : "Open event record",
      trackingLabel: isFuture ? "listing_event_open_upcoming" : "listing_event_open_past",
    },
  ];

  if (event.scorecard) {
    actions.push({
      href: "#event-success",
      label: "See outcomes",
      variant: "secondary",
      trackingLabel: "listing_event_success",
    });
  } else {
    actions.push({
      href: "#reviews",
      label: isFuture ? "Read reviews" : "Review event feedback",
      variant: "secondary",
      trackingLabel: "listing_event_reviews",
    });
  }

  return {
    id: eventAnchorId(event),
    eyebrow: isFuture ? "Upcoming Catch event" : "Past Catch event",
    title: event.title,
    body: event.summary,
    activityToken: activity.token,
    meta: [
      {label: "Date", value: event.date},
      {label: "Location", value: event.location},
      {label: "Price", value: event.priceLabel},
      {label: "Capacity", value: `${event.capacityLimit} spots`},
    ],
    counts: [
      {label: "booked", value: event.bookedCount},
      {label: "checked in", value: event.checkedInCount},
      {label: "waitlisted", value: event.waitlistedCount},
    ],
    actions,
  };
}

function nullableString(value: FormDataEntryValue | null): string | null {
  if (typeof value !== "string") return null;
  const trimmed = value.trim();
  return trimmed.length > 0 ? trimmed : null;
}

function parseProofUrls(value: FormDataEntryValue | null): string[] {
  if (typeof value !== "string") return [];
  const urls = value
    .split(/[\n,]+/)
    .map((item) => item.trim())
    .filter(Boolean)
    .map((item) =>
      item.startsWith("http://") || item.startsWith("https://") ?
        item :
        `https://${item}`
    )
    .filter((item) => {
      try {
        const url = new URL(item);
        return url.protocol === "http:" || url.protocol === "https:";
      } catch {
        return false;
      }
    });
  return [...new Set(urls)].slice(0, 8);
}

function mergeReviews(
  incoming: HostListingReview[],
  existing: HostListingReview[]
): HostListingReview[] {
  const seen = new Set<string>();
  const merged: HostListingReview[] = [];
  for (const review of [...incoming, ...existing]) {
    const key = reviewKey(review);
    if (seen.has(key)) continue;
    seen.add(key);
    merged.push(review);
  }
  return merged.sort(
    (a, b) => reviewTime(b.createdAt) - reviewTime(a.createdAt)
  );
}

function reviewKey(review: HostListingReview): string {
  return review.id ?? `${review.reviewerName}-${review.createdAt}`;
}

function reviewTime(value: string): number {
  const parsed = Date.parse(value);
  return Number.isNaN(parsed) ? 0 : parsed;
}

function reviewDateLabel(value: string): string {
  const parsed = Date.parse(value);
  if (Number.isNaN(parsed)) return value;
  const elapsedMs = Date.now() - parsed;
  if (elapsedMs >= 0 && elapsedMs < 60 * 1000) return "Just now";
  return new Intl.DateTimeFormat("en", {
    month: "short",
    day: "numeric",
    year: "numeric",
  }).format(new Date(parsed));
}

function isVerifiedReview(review: HostListingReview) {
  return review.verificationStatus === "verified" ||
    (!review.verificationStatus && review.source !== "publicListing");
}

function reviewCardForReview(review: HostListingReview): PublicReviewCardModel {
  const verified = isVerifiedReview(review);
  return {
    id: reviewKey(review),
    reviewerName: review.reviewerName,
    createdAtLabel: reviewDateLabel(review.createdAt),
    rating: review.rating,
    comment: review.comment,
    verified,
    verificationLabel: verified ? "Verified Catch attendee" : "Unverified public review",
    sourceLabel: review.source === "catchEvent" ? "Catch event" : "Public web",
    ownerResponse: review.ownerResponse ? {
      hostName: review.ownerResponse.hostName,
      message: review.ownerResponse.message,
      updatedAtLabel: reviewDateLabel(review.ownerResponse.updatedAt),
    } : null,
  };
}

function readableError(error: unknown): string {
  return error instanceof Error ?
    error.message :
    "Something went wrong. Please try again.";
}

function pageMetaForListing(listing: HostListing): PageMeta {
  return {
    title: `${listing.name} | ${listing.city} organizer profile | Catch`,
    description: listing.description,
    canonicalPath: listing.path,
    twitterDescription: listing.sourceSummary,
    robots: listing.indexing,
  };
}

function pageClassFor(page: PageKey) {
  if (page === "host") return "host-page";
  if (page === "listing") return "listing-page";
  if (page === "organizers") return "organizers-page";
  if (page === "claim") return "claim-page";
  return "home-page";
}

function setMetaContent(name: string, content: string) {
  const element = ensureMeta("name", name);
  element.content = content;
}

function setOptionalMetaContent(name: string, content?: string) {
  const selector = `meta[name="${name}"]`;
  const existing = document.head.querySelector<HTMLMetaElement>(selector);
  if (!content) {
    existing?.remove();
    return;
  }
  const element = existing ?? document.createElement("meta");
  element.name = name;
  element.content = content;
  if (!existing) document.head.appendChild(element);
}

function setMetaProperty(property: string, content: string) {
  const element = ensureMeta("property", property);
  element.content = content;
}

function ensureMeta(attribute: "name" | "property", value: string) {
  let element = document.head.querySelector<HTMLMetaElement>(`meta[${attribute}="${value}"]`);
  if (!element) {
    element = document.createElement("meta");
    element.setAttribute(attribute, value);
    document.head.appendChild(element);
  }
  return element;
}

function setCanonical(href: string) {
  let link = document.head.querySelector<HTMLLinkElement>('link[rel="canonical"]');
  if (!link) {
    link = document.createElement("link");
    link.rel = "canonical";
    document.head.appendChild(link);
  }
  link.href = href;
}

function trackCtaClick(label: string, href: string) {
  trackMarketingEvent("cta_click", {
    cta_href: href,
    cta_label: label,
    page_path: `${window.location.pathname}${window.location.search}`,
  });
}

export default App;
