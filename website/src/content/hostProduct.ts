import type {LoopStepCopy, SectionCopy} from "./types";

// Consolidated product copy. Broader workflows remain proposals until scoped for a pilot.
export const hostProductCopy = {
  exampleLabel: "Illustrative workflow · fictional data",
  features: {
    title: "One event record, from the guest list to the recap.",
    body: "Start with the supported live-event pilot. The broader capabilities below describe workflows to discuss, not a promise that every integration or feature is available for your event.",
    items: [
      {title: "Bring your guest list", body: "Keep your booking platform and review a CSV or XLSX import. Coordinate QR or manual check-in, walk-in approvals, rehearsal, optional icebreakers and the post-event recap."},
      {title: "Connect the guest decisions", body: "Forms and applications, guest history, segments, saved audiences and duplicate-record review can support a connected guest record. Application approval, organiser membership, event eligibility, payment and admission remain separate decisions."},
      {title: "Discuss Catch booking", body: "Free RSVPs, paid checkout, payout accounts, refunds, settlement, cohort caps, balanced waitlists and demand pricing belong to the booking workflow. Razorpay or Stripe setup and supported event rules must be confirmed before use. Imported-list restrictions are advisory; verified-profile rules require the appropriate identity and booking configuration."},
      {title: "Reach guests with context", body: "Named channel, promoter, partner and personal referral links connect measurable opens, registrations and attendance. They cannot see inside WhatsApp forwards or imply ad-platform conversion tracking. Plan announcements, reminders and campaigns around independently collected channel consent."},
      {title: "Explore the member network", body: "Verified member profiles, event-context chat, private post-event matching without cold DMs or public rejection, CrossPaths pair suggestions and reserved seats, and discovery for the next event are a separate network proposition. They require member participation and supported availability; they are not prerequisites for the live-event browser experience."},
      {title: "Coordinate a programme", body: "Weddings, conferences, retreats and multi-day productions need per-function schedules, households, travel, accommodation, vendors and staffing. Discuss a managed setup before assuming those capabilities are available."},
    ],
  },
  useCases: {
    title: "Built around the way you host.",
    body: "Choose the smallest useful workflow. These examples describe potential setups; scope and availability are confirmed with the Catch team.",
    items: [
      {question: "Clubs and recurring communities", answer: "Run clubs, walks, cycling, yoga, pickleball, padel, tennis, badminton, trivia, pub quizzes, dinners, supper clubs, bar crawls and custom formats share recurring guest coordination. Discuss event duplication, a retained roster, signup and waiver forms, scheduled reminders, attendance history, new-versus-regular guest segments and referral links. Pace pods, partner rotations and table teams can give the live event structure; confirm late-arrival and dropout handling for your setup. Free or pay-what-you-want events need not adopt Catch payments. Dues, paid forms and session-fee links need a separately supported payment workflow. Attendance history does not automatically grant membership."},
      {question: "Mixers, singles and social events", answer: "Work through three jobs: attracting guests, balancing admission and understanding revenue. Named channel, promoter, partner and attendee-referral links can relate measurable opens to registrations and attendance. Cohort caps, ratios, waitlists and differentiated cohort or demand pricing require supported Catch booking; age and gender restrictions depend on verified profiles. Payment, refunds and settlement should connect to attendance in the recap. First Hello offers a person and an opener; quiet introduction requests, host-reviewed Wingman requests, table rotations and mixer reveals help the first ten minutes. Optional member-network participation adds private matching, event-context chat, CrossPaths and future-event discovery. Keep existing ticket sales if you only need the live room."},
      {question: "Planners, weddings and multi-day productions", answer: "Start with save-the-dates and formal invitations, then household RSVP answers for each invited function, schedules and venues, travel plans, flights, pickups, transport dispatch, accommodation, vendor resources, per-function check-in and duty-scoped staff access. Plan deadline chasers, day-of alerts, schedule changes and post-event feedback around the same operational record. A single reception can be scoped independently. Private invitation links and calendar feeds, flight enrichment and alerts, arrival journals, hotel tracking and automated delivery are topics for a managed walkthrough, not general availability promises. The existing household RSVP route does not imply all of these integrations are live. Production onboarding is hands-on rather than fully self-serve."},
      {question: "Corporate events, conferences and retreats", answer: "Start from the team gathering, sessions and programme. Coordinate invited people, responses, staff and operational information across venues or functions. Membership screening and ticket checkout are not required merely to coordinate a household or session. Agree access to guest data, consent, logistics and operational limits before the pilot."},
    ],
  },
  tools: {
    title: "Keep what works. Review the handoffs.",
    body: "The supported starting point is a reviewed CSV or XLSX guest-list export. A tool name here is a workflow example, not a verified direct integration or an instruction to cancel it. Forwarding, sync, provider delivery and automatic reconciliation need separate confirmation.",
    items: [
      {question: "Ticketing and RSVP tools", answer: "Luma, Eventbrite, Partiful and POSH cover community ticketing, social RSVPs and promoter-led guest lists. BookMyShow, District / Insider, SortMyScene, AllEvents, Townscript, SkillBox and Urbanaut provide different listing, discovery, registration or experience-booking channels. AroundU represents a WhatsApp booking flow; Ticket Fairy represents referral-led ticketing. Keep the channel that works and bring an authorised attendee export for review. Catch can add arrival, live facilitation and a guest record without demanding exclusivity. Direct sync, secure forwarding and platform-specific roster mappings are not promised. If you currently use only DMs and a list, discuss supported Catch booking, checkout, waitlists and cohort rules."},
      {question: "Forms and signup tools", answer: "Google Forms and Sheets, Typeform, Fillout with Airtable, and Tally are examples of intake and conditional-form setups. The proposed handoff attaches responses to the relevant guest record instead of repeatedly exporting rows. Discuss branded intake, logic, application review, payments and automations. Existing form limits or a competing tool’s response caps are not a promise of unlimited Catch capacity."},
      {question: "Payments and reconciliation", answer: "Razorpay links, Instamojo, Stripe links and direct UPI represent payment-link or screenshot workflows. Discuss tracked offers and evidence reconciliation, or supported Catch checkout with payouts, refunds and settlement. Payment evidence must be verified against the guest and event; a screenshot or payment callback alone is not admission, and automatic UPI matching is not promised."},
      {question: "Guest messaging", answer: "WhatsApp broadcasts, event groups and API tools such as AiSensy or Wati, Mailchimp or Brevo email lists, and a DLT-registered SMS provider represent different channels. The aim is relevant reminders for confirmed, unpaid or returning guests without repeated contact-list exports. WhatsApp Business campaigns require your Meta Business assets, approved templates and channel consent. Email and SMS sender availability, provider setup and delivery must be confirmed independently. An event announcement is not proof that an external message was delivered."},
      {question: "Guest records and planning", answer: "Google Sheets, Excel and Airtable often hold the master roster; Notion may hold run sheets and planning pages. Keep planning documents where useful. Discuss a shared guest record with cross-event attendance, no-show history, segments, saved audiences and merge review so each event does not start from zero. The sheet can become a view rather than a second authority; no unlimited record-cap promise is implied."},
      {question: "The door and live room", answer: "Paper lists, QR scanner apps and dedicated check-in apps can be assessed against QR plus manual attendance, live roster validation, walk-in approval and optional icebreakers, pairings and rotations. Confirm duty-scoped, expiring door access and the event’s guest identity requirements. Guests can use a phone-verified mobile browser for a supported live event without downloading the app."},
      {question: "Links, promotion and the next event", answer: "Linktree, Bitly, Instagram ads and promoter networks are examples of distribution tools. Named links can connect a measurable open to registration and attendance rather than stopping at clicks. Compare channel and promoter outcomes without pretending to see private forwards or ad-platform conversions. Referrals, consented follow-up and a connected recap can inform the next invitation list. Catch network discovery and CrossPaths are separately scoped possibilities, not a guaranteed audience or revenue uplift."},
      {question: "Multi-day scope", answer: "A wedding, conference or multi-venue production changes the setup: functions, households, schedules, travel, transport, hotels and staff need a managed conversation. Tool count alone cannot choose a commercial tier or establish integration support."},
    ],
    problems: [
      {title: "Repeated exports", body: "A form feeds a sheet, the sheet feeds a broadcast list, and nothing feeds back. Review which handoff can be removed first."},
      {title: "Payment and attendance disagree", body: "Resolve ‘I paid but I am not on the list’ with verified evidence and event admission, not an unrelated dashboard or screenshot."},
      {title: "Guest history resets", body: "A guest’s previous attendance and no-shows should inform the next event where authorised, rather than disappearing into separate files."},
      {title: "Messages lose their context", body: "A reminder for confirmed-but-unpaid guests should have a clear audience, consent and delivery state."},
      {title: "The recap goes nowhere", body: "Connect registration, payments, communication and check-in to follow-up and the next event instead of leaving the data in a final spreadsheet."},
    ],
  },
  pricing: {
    title: "Pilot access and pricing",
    body: "The current live-event beta is selected, hands-on and free during the pilot. Apply with a real upcoming event and a guest list. Broader booking, network and managed-programme scope, capacity and commercial terms are agreed with the team; these are adoption paths, not purchasable pricing tiers.",
    items: [
      {title: "Start alongside your tools", body: "Bring the workflow, current tools, guest-list size and next event. Keep your booking flow while reviewing the live-event handoff."},
      {title: "Agree the pilot", body: "If your event is a fit, map the workflow together, confirm supported capabilities, staff access, guest-data boundaries and consent, then arrange hands-on onboarding."},
      {title: "Run, recap and decide", body: "Review what worked after the real event. Discuss booking, member-network or managed-programme adoption only when it solves a useful next problem."},
    ],
  },
  application: {
    title: "Apply for a Catch Host pilot",
    body: "Tell us who hosts, your next real event, your current booking or RSVP setup and guest-list size, and the capabilities you would use. Review the details before sending. We review applications and follow up if the event is a fit; submission does not book a call or grant access.",
    back: "Explore Catch Host", action: "Apply for a pilot",
    note: "No platform switch is required to enquire. A public organiser listing is not required to apply.",
  },
} as const;

export interface WorkflowExampleCopy extends SectionCopy {
  readonly id: "application-booking" | "live-event" | "multi-day";
  readonly audience: string;
  readonly outcome: string;
  readonly boundary: string;
  readonly steps: readonly LoopStepCopy[];
  readonly facts: readonly {label: string; value: string}[];
}

export const hostWorkflowExamples = [
  {
    id: "application-booking", audience: "Curated communities and returning guests",
    title: "From application review to a confirmed place.",
    body: "A curated run club: a campaign brings a new application, the team reviews it, and this Sunday’s invitation is checked separately before booking.",
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
