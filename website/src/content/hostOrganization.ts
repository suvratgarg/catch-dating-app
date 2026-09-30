import type {LoopStepCopy, SectionCopy} from "./types";

// Authored marketing projections only. These examples neither call product APIs
// nor imply that separate approval, membership and admission states are linked.
export interface WorkflowExampleCopy extends SectionCopy {
  readonly id: "application-booking" | "live-event" | "multi-day";
  readonly audience: string;
  readonly outcome: string;
  readonly boundary: string;
  readonly steps: readonly LoopStepCopy[];
  readonly facts: readonly {label: string; value: string}[];
}

export const hostOrganizationCopy = {
  review: {
    title: "Content review · proposed website organisation",
    body: "Review the buyer’s next decision and the page order. This is a working content mockup using existing Catch styling, not a published offer or customer case study.",
  },
  menu: {
    dialogLabel: "Host website menu", openLabel: "Menu", closeLabel: "Close",
    kicker: "Catch Host", hint: "Event operations, around your setup", navLabel: "Host website",
  },
  hero: {
    eyebrow: "Catch Host · event operations",
    title: "Keep the event moving. Keep the decisions connected.",
    body: "Applications in one place, guest decisions in another, updates across messages. Start with the part of your event that needs a clearer handoff, and walk through a supported setup with us.",
    primaryAction: "Request a guided walkthrough",
    secondaryAction: "Find your workflow",
    contactNote: "Opens an email to the Catch team. No account or payment required to enquire.",
  },
  workflows: {
    eyebrow: "Start with the job",
    title: "Choose the handoff you need to improve.",
    body: "These are different ways into the same capabilities. A social event does not need membership screening; a wedding does not need a ticket checkout.",
  },
  exampleLabel: "Illustrative workflow · fictional data",
  detailAction: "Explore this workflow",
  capabilities: {
    eyebrow: "Shared underneath",
    title: "One set of capabilities. Different event workflows.",
    body: "The organiser’s job determines the combination. Confirm availability, prerequisites and the smallest useful pilot during the walkthrough.",
    items: [
      {title: "Forms and applications", body: "Collect the details a decision actually needs."},
      {title: "Guest records and membership", body: "Keep organiser guest history separate from global identity and event access."},
      {title: "Eligibility and approval", body: "Review the person and check this event independently."},
      {title: "Reservations, capacity and payments", body: "Offer a place under the event’s rules; rely on verified admission, not a payment callback alone."},
      {title: "Communications", body: "Plan invitations and updates with channel configuration and independent consent."},
      {title: "Admission and live operations", body: "Manage attendance and the live event with host control."},
      {title: "Attribution and reporting", body: "Understand source links and event outcomes without implying ad-platform conversion tracking."},
    ],
  },
  pilot: {
    eyebrow: "A small adoption step",
    title: "Walk through one event before changing your setup.",
    body: "Bring the workflow, current tools and the next event. We can identify a supported starting point and discuss who can access which guest data, consent requirements and operational limits.",
    items: [
      {title: "Keep what already works", body: "For the live-event path, start from a reviewed CSV or XLSX export. File import is not a direct sync integration."},
      {title: "Agree the data boundary", body: "Confirm organiser scope, staff access and guest-facing information before a pilot. Do not treat this mockup as a security assurance."},
      {title: "Confirm the supported scope", body: "The current live-event beta is selected and hands-on. Broader workflow availability and commercial terms need a conversation."},
    ],
    betaAction: "View the existing live-event beta application",
    betaNote: "That application remains a separate, event-qualified beta intake; it does not book a call.",
  },
  footer: "Catch Host · a working content structure for guided event-operations conversations.",
} as const;

export const hostWorkflowExamples = [
  {
    id: "application-booking", audience: "Curated communities and returning guests",
    title: "From application review to a confirmed place.",
    body: "An Afterfly-like run club: a campaign brings a new application, the team reviews it, and this Sunday’s invitation is checked separately before booking.",
    outcome: "The organiser can explain why this person received this event offer; the guest gets a clear booking result.",
    boundary: "Illustrative connections: application approval does not create membership or grant admission. Automatic membership updates, external confirmations and returning-guest recognition require separate verification.",
    steps: [
      {step: "01", title: "Apply from a campaign", body: "Collect relevant details and retain the configured source-link reference."},
      {step: "02", title: "Review the application", body: "Record the application decision; keep durable membership status separate."},
      {step: "03", title: "Check event eligibility", body: "Decide whether this guest may receive this event’s offer."},
      {step: "04", title: "Offer gated payment", body: "Use the governed invitation and checkout path only when enabled."},
      {step: "05", title: "Confirm admission", body: "Show a place only after the server confirms admission and its receipt."},
    ],
    facts: [
      {label: "Fictional guest", value: "Aanya · Sunday run, Indore"},
      {label: "Application", value: "Approved"},
      {label: "Membership", value: "Separate decision; not automatically changed"},
      {label: "Event eligibility", value: "Eligible for this Sunday’s offer"},
      {label: "Payment", value: "Verified in the fictional example"},
      {label: "Event admission", value: "Confirmed in the fictional example"},
    ],
  },
  {
    id: "live-event", audience: "Social events with an existing booking tool",
    title: "Keep the booking tool. Coordinate the live event.",
    body: "A Sirf Coffee-like social format: bookings stay in Luma or the existing tool. A reviewed guest-list export starts the companion event; arrival and optional facilitation follow.",
    outcome: "Hosts know who arrived and can coordinate the room without asking guests to install an app.",
    boundary: "Illustrative organiser example, not a customer claim. The verified starting point is file import, not Luma direct sync. Live tools and guest identity requirements depend on the event configuration.",
    steps: [
      {step: "01", title: "Keep current bookings", body: "Use the ticketing or RSVP tool that already works."},
      {step: "02", title: "Review the import", body: "Check the CSV or XLSX mapping before the event."},
      {step: "03", title: "Manage arrival", body: "Use phone-verified browser access with host attendance controls."},
      {step: "04", title: "Run only useful live tools", body: "Choose optional prompts or facilitation and keep host overrides available."},
    ],
    facts: [
      {label: "Booking source", value: "Existing tool retained"},
      {label: "Handoff", value: "Reviewed file export and import"},
      {label: "Guest entry", value: "Event-scoped mobile browser"},
      {label: "Adoption", value: "Hands-on live-event beta review"},
    ],
  },
  {
    id: "multi-day", audience: "Weddings, retreats and multi-session events",
    title: "Coordinate people across functions and sessions.",
    body: "An illustrative wedding: a household receives only its invited functions, responds for those functions, and receives the relevant operational information. Retreats and conferences can start from session coordination instead.",
    outcome: "The planner can see the responses needed for each function without forcing a membership or payment funnel.",
    boundary: "Workflow discussion, not a launch promise for every wedding or corporate feature. Household RSVP has an existing scoped product route; travel integrations, flight enrichment and automatic channel delivery are not implied.",
    steps: [
      {step: "01", title: "Scope the invitation", body: "Identify the household or guest and the functions they are invited to."},
      {step: "02", title: "Collect the right responses", body: "Keep attendance answers specific to each invited function."},
      {step: "03", title: "Coordinate the next update", body: "Plan event information and channel consent separately from RSVP."},
    ],
    facts: [
      {label: "Fictional household", value: "The Mehta family"},
      {label: "Invitation scope", value: "Welcome dinner and ceremony"},
      {label: "Decisions", value: "Response per invited function"},
      {label: "Not required", value: "Membership screening or ticket checkout"},
    ],
  },
] as const satisfies readonly WorkflowExampleCopy[];

export const hostOrganizationNavigation = [
  {href: "#workflows", label: "Workflows"},
  {href: "#capabilities", label: "Shared capabilities"},
  {href: "#supported-pilot", label: "Supported pilot"},
] as const;
