// Retained prototype copy; every mapping is illustrative until independently verified.
export const prototypeStackGroups = [
  {
    "id": "ticketing",
    "label": "Ticketing & bookings",
    "hint": "Catch plugs in — you keep the sales channel"
  },
  {
    "id": "forms",
    "label": "Forms & signups",
    "hint": "We replace these"
  },
  {
    "id": "payments",
    "label": "Payments",
    "hint": "We replace these"
  },
  {
    "id": "messaging",
    "label": "Guest messaging",
    "hint": "We replace these"
  },
  {
    "id": "records",
    "label": "Guest records",
    "hint": "We replace these"
  },
  {
    "id": "door",
    "label": "The door",
    "hint": "We replace these"
  },
  {
    "id": "links",
    "label": "Links & promotion",
    "hint": "We replace these"
  },
  {
    "id": "scope",
    "label": "Scope",
    "hint": "Changes the answer"
  }
] as const;

export const prototypeStackTools = [
  {
    "id": "luma",
    "group": "ticketing",
    "kind": "keep",
    "name": "Luma",
    "job": "ticket sales",
    "blurb": "Community-event ticketing and RSVPs.",
    "catch": "Keep it — Catch reads the roster; the room runs on it",
    "detail": "Reviewed roster mapping — imports are verified. Catch runs check-in, the live room, and the record from your Luma list."
  },
  {
    "id": "eventbrite",
    "group": "ticketing",
    "kind": "keep",
    "name": "Eventbrite",
    "job": "ticket sales",
    "blurb": "General-purpose ticketing marketplace.",
    "catch": "Keep it — Catch reads the roster; the room runs on it",
    "detail": "Reviewed roster mapping. Keep Eventbrite's reach; Catch adds the room, the door, and the record."
  },
  {
    "id": "partiful",
    "group": "ticketing",
    "kind": "keep",
    "name": "Partiful",
    "job": "RSVPs",
    "blurb": "Invite-first social RSVPs.",
    "catch": "Keep it — Catch reads the roster; the room runs on it",
    "detail": "Reviewed roster mapping. Partiful collects the yeses; Catch runs what happens after."
  },
  {
    "id": "posh",
    "group": "ticketing",
    "kind": "keep",
    "name": "POSH",
    "job": "guest list",
    "blurb": "Nightlife and promoter-led ticketing.",
    "catch": "Keep it — Catch reads the roster; the room runs on it",
    "detail": "Reviewed roster mapping. Promoter channels stay; Catch attributes them and runs the room."
  },
  {
    "id": "bookmyshow",
    "group": "ticketing",
    "kind": "keep",
    "name": "BookMyShow",
    "job": "ticket sales",
    "blurb": "India's large-venue ticketing marketplace.",
    "catch": "Keep it — export the roster; Catch runs the room",
    "detail": "Curated marketplace — export your attendee list; Catch handles check-in, live tools, and the recap."
  },
  {
    "id": "district",
    "group": "ticketing",
    "kind": "keep",
    "name": "District · Insider",
    "job": "ticket sales",
    "blurb": "Zomato's events and experiences marketplace.",
    "catch": "Keep it — export the roster; Catch runs the room",
    "detail": "Keep District's discovery. Your guest relationship and the room are yours on Catch."
  },
  {
    "id": "sortmyscene",
    "group": "ticketing",
    "kind": "keep",
    "name": "SortMyScene",
    "job": "ticket sales",
    "blurb": "Indie nightlife ticketing across ~100 cities.",
    "catch": "Keep it — export the roster; Catch runs the room",
    "detail": "Its follower CRM overlaps ours — Catch adds the live room, cohort rules, and cross-event memory."
  },
  {
    "id": "allevents",
    "group": "ticketing",
    "kind": "keep",
    "name": "AllEvents",
    "job": "ticket sales",
    "blurb": "Self-serve listings with broad SEO discovery.",
    "catch": "Keep it — export the roster; Catch runs the room",
    "detail": "Keep the listing for discovery; Catch owns the guest record end-to-end."
  },
  {
    "id": "townscript",
    "group": "ticketing",
    "kind": "keep",
    "name": "Townscript",
    "job": "ticket sales",
    "blurb": "Self-serve registration for conferences and workshops.",
    "catch": "Keep it — export the roster; Catch runs the room",
    "detail": "Roster via CSV export; Catch modernizes the guest-facing flow and the door."
  },
  {
    "id": "skillbox",
    "group": "ticketing",
    "kind": "keep",
    "name": "SkillBox",
    "job": "ticket sales",
    "blurb": "Music and live-community ticketing.",
    "catch": "Keep it — export the roster; Catch runs the room",
    "detail": "No exclusivity demanded — Catch sits under any listing as the live layer."
  },
  {
    "id": "urbanaut",
    "group": "ticketing",
    "kind": "keep",
    "name": "Urbanaut",
    "job": "experience bookings",
    "blurb": "Curated experiences marketplace.",
    "catch": "Keep it — export the roster; Catch runs the room",
    "detail": "Curated bookings stay curated; Catch adds check-in, live tools, and your own CRM."
  },
  {
    "id": "aroundu",
    "group": "ticketing",
    "kind": "keep",
    "name": "AroundU",
    "job": "WhatsApp bookings",
    "blurb": "WhatsApp-native booking and QR tickets.",
    "catch": "Keep it — forward the roster; Catch adds the live layer",
    "detail": "Same no-download philosophy — Catch extends it with the room, cohort rules, and the record."
  },
  {
    "id": "ticketfairy",
    "group": "ticketing",
    "kind": "keep",
    "name": "Ticket Fairy",
    "job": "ticket sales",
    "blurb": "Ticketing with a referral-rewards engine.",
    "catch": "Keep it — export the roster; Catch runs the room",
    "detail": "Its referral engine maps to our named-link attribution — yours runs across every channel."
  },
  {
    "id": "noplatform",
    "group": "ticketing",
    "kind": "none",
    "name": "No platform yet",
    "job": "DMs & lists",
    "blurb": "Instagram DMs and a guest list you maintain.",
    "catch": "Catch can be the booking platform — checkout, waitlists, balanced admission",
    "detail": "Skip the pile entirely: Catch booking gives you checkout, waitlists, and cohort rules on the same record the door uses."
  },
  {
    "id": "gforms",
    "group": "forms",
    "kind": "replace",
    "name": "Google Forms",
    "job": "registration forms",
    "blurb": "Free forms, answers land in Sheets.",
    "catch": "Forms that write straight to the guest record",
    "detail": "Same form job — but responses become guests, not rows. Payments, automations, and review built in."
  },
  {
    "id": "typeform",
    "group": "forms",
    "kind": "replace",
    "name": "Typeform",
    "job": "registration forms",
    "blurb": "Conversational branded forms.",
    "catch": "Forms that write straight to the guest record",
    "detail": "Branded intake without the response caps — and the answers are attached to the person, not a CSV."
  },
  {
    "id": "fillout",
    "group": "forms",
    "kind": "replace",
    "name": "Fillout",
    "job": "registration forms",
    "blurb": "Database-backed forms and scheduling.",
    "catch": "Forms that write straight to the guest record",
    "detail": "If Fillout writes to Airtable today, Catch removes the middle step — the form is the record."
  },
  {
    "id": "tally",
    "group": "forms",
    "kind": "replace",
    "name": "Tally",
    "job": "registration forms",
    "blurb": "Free unlimited forms with logic.",
    "catch": "Forms that write straight to the guest record",
    "detail": "Keep the logic; lose the export. Responses attach to guests the moment they're submitted."
  },
  {
    "id": "razorpaylinks",
    "group": "payments",
    "kind": "replace",
    "name": "Razorpay links",
    "job": "payment links in DMs",
    "blurb": "Payment links pasted into WhatsApp.",
    "catch": "Tracked offers — or real checkout on the booking tier",
    "detail": "Links stay possible with evidence reconciliation — or move to Catch checkout for payouts, refunds, and revenue truth."
  },
  {
    "id": "instamojo",
    "group": "payments",
    "kind": "replace",
    "name": "Instamojo",
    "job": "payment links",
    "blurb": "Payment links and a mini store.",
    "catch": "Tracked offers — or real checkout on the booking tier",
    "detail": "Each payment ties to a guest, not a dashboard you reconcile by hand."
  },
  {
    "id": "stripelinks",
    "group": "payments",
    "kind": "replace",
    "name": "Stripe links",
    "job": "payment links",
    "blurb": "Payment links on Stripe.",
    "catch": "Tracked offers — or real checkout on the booking tier",
    "detail": "Catch checkout also runs on Stripe — same rails, with the guest record attached."
  },
  {
    "id": "upi",
    "group": "payments",
    "kind": "replace",
    "name": "Direct UPI",
    "job": "screenshot payments",
    "blurb": "Guests pay your UPI ID and screenshot back.",
    "catch": "Tracked offers — or real checkout on the booking tier",
    "detail": "No more screenshot matching — payments land on the guest record automatically."
  },
  {
    "id": "wabroadcast",
    "group": "messaging",
    "kind": "replace",
    "name": "WhatsApp broadcast",
    "job": "broadcast lists",
    "blurb": "Broadcast lists and event groups.",
    "catch": "Scheduled announcements + campaigns on your Meta account",
    "detail": "Targeted sends by segment — confirmed, unpaid, attended-before — instead of one noisy group. Requires your own Meta Business assets."
  },
  {
    "id": "waapi",
    "group": "messaging",
    "kind": "replace",
    "name": "WhatsApp API · AiSensy/Wati",
    "job": "campaign tooling",
    "blurb": "BSP dashboards on the WhatsApp API.",
    "catch": "Campaigns connected to the guest record",
    "detail": "Same rails — Catch targets them off the guest record instead of uploaded contact lists. Provider-gated."
  },
  {
    "id": "mailchimp",
    "group": "messaging",
    "kind": "replace",
    "name": "Mailchimp · Brevo",
    "job": "email blasts",
    "blurb": "Email newsletters and reminders.",
    "catch": "Segmented guest messaging — no export step",
    "detail": "Segments live where the guests live; no list maintenance between events."
  },
  {
    "id": "sms",
    "group": "messaging",
    "kind": "replace",
    "name": "SMS provider",
    "job": "SMS sends",
    "blurb": "DLT-registered transactional SMS.",
    "catch": "In-product messaging live; SMS sender on the roadmap*",
    "detail": "Announcements and WhatsApp are live today; a native SMS sender is coming — mark this as a near-term gap."
  },
  {
    "id": "gsheets",
    "group": "records",
    "kind": "replace",
    "name": "Google Sheets",
    "job": "the master sheet",
    "blurb": "One tab per event; the source of truth.",
    "catch": "CRM with segments and saved audiences — no export churn",
    "detail": "No FINAL_v3 at the door — one roster, live, shared by every tool."
  },
  {
    "id": "excel",
    "group": "records",
    "kind": "replace",
    "name": "Excel",
    "job": "the master sheet",
    "blurb": "The guest workbook.",
    "catch": "CRM with segments and saved audiences — no export churn",
    "detail": "The sheet becomes a view, not the system of record."
  },
  {
    "id": "airtable",
    "group": "records",
    "kind": "replace",
    "name": "Airtable",
    "job": "guest database",
    "blurb": "A nicer database for the same job.",
    "catch": "CRM with segments and saved audiences — no export churn",
    "detail": "Record caps and rebuild-per-event end; guest history persists across events."
  },
  {
    "id": "notion",
    "group": "records",
    "kind": "replace",
    "name": "Notion",
    "job": "planning docs",
    "blurb": "Run-sheets and planning pages.",
    "catch": "One record — the doc stops being the database",
    "detail": "Keep docs for planning; guests, money, and messages move to a real record."
  },
  {
    "id": "paper",
    "group": "door",
    "kind": "replace",
    "name": "Paper list",
    "job": "check-in",
    "blurb": "A printed list and a pen at the door.",
    "catch": "QR + manual check-in that updates the roster live",
    "detail": "Attendance writes back to the same record the form created — attendance rate is known before the event ends."
  },
  {
    "id": "scanner",
    "group": "door",
    "kind": "replace",
    "name": "Scanner app",
    "job": "check-in",
    "blurb": "A QR reader app at the door.",
    "catch": "QR + manual check-in that updates the roster live",
    "detail": "Codes issued per guest from the same system — scanning validates against the live roster."
  },
  {
    "id": "checkinapp",
    "group": "door",
    "kind": "replace",
    "name": "Check-in app",
    "job": "door ops",
    "blurb": "Dedicated per-event check-in tooling.",
    "catch": "Check-in plus the live room — icebreakers, rotations, walk-ins",
    "detail": "Door staff get scoped, expiring access; the same check-in feeds the room's pairing and prompts."
  },
  {
    "id": "linktree",
    "group": "links",
    "kind": "replace",
    "name": "Linktree",
    "job": "bio links",
    "blurb": "The bio-link hub.",
    "catch": "Named tracked links per channel, promoter, partner",
    "detail": "Clicks connect to registrations and door scans — the link stops being a dead end."
  },
  {
    "id": "bitly",
    "group": "links",
    "kind": "replace",
    "name": "Bitly",
    "job": "link tracking",
    "blurb": "Short links with click counts.",
    "catch": "Attribution down to the promoter link",
    "detail": "Attribution runs to RSVP and attendance, not just the click."
  },
  {
    "id": "igads",
    "group": "links",
    "kind": "replace",
    "name": "Instagram ads + promoters",
    "job": "paid reach",
    "blurb": "Paid posts and promoter networks.",
    "catch": "Channel attribution — and CrossPaths on the network tier",
    "detail": "Know which channel and which promoter actually filled the room. On the network tier, popular members become the draw.",
    "network": true
  },
  {
    "id": "multiday",
    "group": "scope",
    "kind": "program",
    "name": "Multi-day program",
    "job": "multi-day production",
    "blurb": "Weddings, conferences, multi-venue productions.",
    "catch": "Programs — functions, households, travel. Managed pilot",
    "detail": "Per-function schedules, household RSVPs, flight-tracked arrivals, transport and hotel logistics — onboarded hands-on through a managed pilot."
  }
] as const;

export const prototypeStackTiers = {
  "alongside": {
    "name": "Works alongside",
    "why": "A lean stack stays cheap to run. Catch layers onto your booking flow — the room and the record get smarter without a platform switch."
  },
  "booking": {
    "name": "Catch booking",
    "why": "That many moving parts pay for a consolidated record. Move checkout onto Catch — rules, revenue truth, and attribution in the same place as the door."
  },
  "managed": {
    "name": "Managed program",
    "why": "Multi-day scope is onboarded hands-on — functions, households, travel, staff. We map your production on the pilot call."
  }
} as const;
