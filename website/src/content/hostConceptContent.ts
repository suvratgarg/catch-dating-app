/** Canonical concept presentation copy. Reference/source metadata lives only in the parity fixture. */
import {prototypeConsoleContentItems, prototypeInteractionContent, type PrototypeTierId} from './prototypeInteractionContent';
import {hostConceptCopy} from './hostConceptNavigation';
export interface HostConceptContentLink { readonly label: string; readonly href: string }
export type HostConceptSectionLayout = 'content' | 'faq' | 'tiers' | 'stack' | 'console';
export type HostConceptItemRole = 'content' | 'tier-detail' | 'tier-note' | 'tier-hidden';
export interface HostConceptContentItem { readonly label?: string; readonly title?: string; readonly body: string; readonly bullets?: readonly string[]; readonly role: HostConceptItemRole; readonly tierId?: PrototypeTierId }
export interface HostConceptContentSection { readonly id: string; readonly heading: string; readonly body: readonly string[]; readonly items: readonly HostConceptContentItem[]; readonly links: readonly HostConceptContentLink[]; readonly layout: readonly HostConceptSectionLayout[] }
export interface HostConceptContentPage { readonly slug: string; readonly title: string; readonly description: string; readonly conceptNotice: string; readonly sectionAction?: HostConceptContentLink; readonly sections: readonly HostConceptContentSection[] }

const tierMarkers = {
  alongside: {body: `Illustrative concept: ${prototypeInteractionContent.tiers[0].name}`, role: 'content'},
  booking: {body: `Illustrative concept: ${prototypeInteractionContent.tiers[1].name}`, role: 'content'},
  network: {body: `Illustrative concept: ${prototypeInteractionContent.tiers[2].name}`, role: 'content'},
} as const satisfies Record<PrototypeTierId, HostConceptContentItem>;

const pilotSteps = {
  "event": {
    "body": "Illustrative concept: 01 Tell us about your event Five quick steps — the event, your setup, what you'd use.",
    "role": "content",
    "title": "Tell us about your event"
  },
  "workflow": {
    "body": "Illustrative concept: 02 We map your workflow on a call Which tools you keep, which Catch replaces, which tier fits.",
    "role": "content",
    "title": "We map your workflow on a call"
  },
  "run": {
    "body": "Illustrative concept: 03 You run a real event on Catch Hands-on onboarding through doors, live tools, and recap.",
    "role": "content",
    "title": "You run a real event on Catch"
  },
  "review": {
    "body": "Illustrative concept: 04 We review it together What worked, what it earned, what the next tier would add.",
    "role": "content",
    "title": "We review it together"
  }
} as const satisfies Record<string, HostConceptContentItem>;

const commonFaq = {
  "bookingPlatform": {
    "body": "Illustrative concept: No. The first circle works entirely off an exported guest list. Catch-powered booking is there when the attribution and admission rules are worth the switch.",
    "role": "content",
    "title": "Do I have to leave my booking platform?"
  },
  "guestApp": {
    "body": "Illustrative concept: No. Guests verify a phone number and join the live event in a mobile browser. The Catch app only enters the picture at the network tier — and it's their choice.",
    "role": "content",
    "title": "Do my guests need to download an app?"
  },
  "pilot": {
    "body": "Illustrative concept: A real upcoming event, a guest list, and one call to map your workflow. Onboarding is hands-on and free during the pilot.",
    "role": "content",
    "title": "What does a pilot involve?"
  },
  "pricing": {
    "body": "Illustrative concept: Pricing scales with which circles you use and the size of your operation. We quote it on the call — advanced and managed-program capabilities price differently from standalone tooling.",
    "role": "content",
    "title": "How does pricing work?"
  },
  "availability": {
    "body": "Illustrative concept: Everything in the first circle. Catch booking, payments, and restrictions are live on the booking tier. Multi-day programs run through managed pilots; SMS and email senders are on the roadmap.",
    "role": "content",
    "title": "What's actually live today?"
  }
} as const satisfies Record<string, HostConceptContentItem>;

const conceptActions = {
  "freePilot": {
    "href": "/host/apply/",
    "label": "Request a free pilot"
  },
  "planners": {
    "href": "/host/planners/",
    "label": "For planners →"
  },
  "pilot": {
    "href": "/host/apply/",
    "label": "Request a pilot"
  },
  "directory": {
    "href": "/host/directory/",
    "label": "Search the directory"
  },
  "directorySection": {
    "href": "/organizers/",
    "label": hostConceptCopy.directory
  },
  "claimSection": {
    "href": "/claim/",
    "label": hostConceptCopy.claim
  },
  "applySection": {
    "href": "/host/#founding-hosts",
    "label": hostConceptCopy.apply
  }
} as const satisfies Record<string, HostConceptContentLink>;

const pilotSection = {
  "id": "pilot",
  "heading": "Pilot Catch on your next event.",
  "body": [
    "Illustrative concept: The pilot",
    "Illustrative concept: We onboard a small number of organizers at a time, on real events. Tell us about yours — we'll get on a call, map your workflow, and set up a free pilot around it."
  ],
  "items": [
    pilotSteps.event,
    pilotSteps.workflow,
    pilotSteps.run,
    pilotSteps.review
  ],
  "links": [
    conceptActions.freePilot
  ],
  "layout": [
    "content"
  ]
} as const satisfies HostConceptContentSection;

const conceptNotice = "Content migrated from the static concept. Availability, integrations, pricing, example events, listing samples and predicted outcomes require verification; this page does not grant access or promise production support.";

export const hostConceptContentPages: readonly HostConceptContentPage[] = [
  {
    "slug": "index",
    "title": "Catch — the room before the match",
    "description": "Illustrative concept: Catch runs curated social events where showing up comes before matching — and gives hosts one system from guest list to last goodbye.",
    "conceptNotice": conceptNotice,
    "sections": [
      {
        "id": "section-1",
        "heading": "The room before the match.",
        "body": [
          "Illustrative concept: Curated events · Verified attendance · Real context",
          "Illustrative concept: Curated runs, dinners, quiz nights, and mixers where people meet in person first — and the host tooling that makes those rooms worth attending."
        ],
        "items": prototypeConsoleContentItems,
        "links": [
          {
            "label": "I host events",
            "href": "/host/platform/"
          },
          {
            "label": "I'm here to attend",
            "href": "#attend"
          }
        ],
        "layout": [
          "console"
        ]
      },
      {
        "id": "section-2",
        "heading": "Happening on Catch.",
        "body": [
          "Illustrative concept: Live in Mumbai & Indore",
          "Illustrative concept: Real upcoming events and organizers publish here from the Catch directory. Browse all →"
        ],
        "items": [
          {
            "body": "Illustrative concept: Sat 7:00 · Indore · pace pods",
            "title": "Saturday Social Run",
            "label": "Social run",
            "role": "content"
          },
          {
            "body": "Illustrative concept: Sun 19:00 · Bandra · table rotations",
            "title": "Sunday Supper Club",
            "label": "Supper club",
            "role": "content"
          },
          {
            "body": "Illustrative concept: Fri 20:00 · Mumbai · team mixer",
            "title": "Quiz Night XI",
            "label": "Pub quiz",
            "role": "content"
          }
        ],
        "links": [
          {
            "label": "Browse all →",
            "href": "/host/directory/"
          }
        ],
        "layout": [
          "content"
        ]
      },
      {
        "id": "section-3",
        "heading": "Built around the way you host.",
        "body": [
          "Illustrative concept: For hosts",
          "Illustrative concept: Catch Host works at whatever level you run — pick the lane that sounds like you."
        ],
        "items": [
          {
            "body": "Illustrative concept: Weddings, conferences, retreats. Households, travel, staffing, and every message in between. For planners →",
            "title": "Multi-day productions",
            "label": "01 · Planners",
            "role": "content"
          },
          {
            "body": "Illustrative concept: Fill the room, balance the room, and see which promotion actually worked. For organizers →",
            "title": "Mixers & dating formats",
            "label": "02 · Singles & social",
            "role": "content"
          },
          {
            "body": "Illustrative concept: Run clubs, pickleball, trivia, supper clubs — weekly events without the weekly scramble. For communities →",
            "title": "Clubs & recurring events",
            "label": "03 · Communities",
            "role": "content"
          }
        ],
        "links": [
          {
            "label": "01 · Planners Multi-day productions Weddings, conferences, retreats. Households, travel, staffing, and every message in between. For planners →",
            "href": "/host/planners/"
          },
          {
            "label": "02 · Singles & social Mixers & dating formats Fill the room, balance the room, and see which promotion actually worked. For organizers →",
            "href": "/host/mixers/"
          },
          {
            "label": "03 · Communities Clubs & recurring events Run clubs, pickleball, trivia, supper clubs — weekly events without the weekly scramble. For communities →",
            "href": "/host/clubs/"
          }
        ],
        "layout": [
          "content"
        ]
      },
      {
        "id": "section-4",
        "heading": "One system. Three levels of commitment.",
        "body": [
          "Illustrative concept: Catch Host",
          "Illustrative concept: Start with the guest list you already have. Move booking onto Catch when you're ready. Plug into the member network when you want the platform to help fill the room."
        ],
        "items": [
          {
            "body": "Illustrative concept: Works alongside Your tools stay Import the guest list. Run check-in, icebreakers, forms, messaging, and CRM — no platform switch.",
            "title": "Your tools stay",
            "role": "content"
          },
          {
            "body": "Illustrative concept: Catch booking We sell the tickets Checkout, waitlists, balanced admission, demand pricing, revenue truth.",
            "title": "We sell the tickets",
            "role": "content"
          },
          {
            "body": "Illustrative concept: Catch network We help fill the room Verified member profiles, post-event matching, discovery, CrossPaths.",
            "title": "We help fill the room",
            "role": "content"
          }
        ],
        "links": [
          {
            "label": "See what each tier unlocks",
            "href": "/host/platform/#tiers"
          }
        ],
        "layout": [
          "content"
        ]
      },
      {
        "id": "section-5",
        "heading": "Your organizer page may already exist.",
        "body": [
          "Illustrative concept: Already on Catch?",
          "Illustrative concept: We maintain public, source-backed profiles for organizers in our launch markets — events, formats, and reviews included. Claim yours to unlock host tools, responses, and analytics on a page that's already ranking."
        ],
        "items": [
          {
            "body": "Illustrative concept: Search Find your listing Your public page may already exist — sourced from public event data.",
            "title": "Find your listing",
            "role": "content"
          },
          {
            "body": "Illustrative concept: Verify Prove it's you Role, contact details, and proof links — reviewed by a human.",
            "title": "Prove it's you",
            "role": "content"
          },
          {
            "body": "Illustrative concept: Unlock Tools attach to the page Responses, event publishing, analytics — on the listing people already find.",
            "title": "Tools attach to the page",
            "role": "content"
          }
        ],
        "links": [
          {
            "label": "Find & claim your page",
            "href": "/host/claim/"
          },
          {
            "label": "Browse the directory",
            "href": "/host/directory/"
          }
        ],
        "layout": [
          "content"
        ]
      },
      {
        "id": "attend",
        "heading": "Here for the events, not the tooling?",
        "body": [
          "Illustrative concept: Catch is live for members in Mumbai and Indore. Join the waitlist to hear when new cities and formats open.",
          "Illustrative concept: iOS + Android app links appear here in production"
        ],
        "items": [],
        "links": [
          {
            "label": "Join the member waitlist",
            "href": "/#waitlist"
          }
        ],
        "layout": [
          "content"
        ]
      }
    ]
  },
  {
    "slug": "host",
    "title": "Catch Host — the operating system for real-world events",
    "description": "Illustrative concept: Forms, guest lists, check-in, live room tools, payments, messaging, CRM, and attribution — working alongside your booking platform or as it.",
    "conceptNotice": conceptNotice,
    "sections": [
      {
        "id": "section-1",
        "heading": "Your booking tool stops at the sale. That's where we start.",
        "body": [
          "Illustrative concept: Catch Host",
          "Illustrative concept: Catch Host is the operating layer for live events. Bring the guest list you already have — get a no-download live room, attendance, guest messaging, and a real CRM. Unlock ticketing, balanced admission, and the member network as you go deeper.",
          "Illustrative concept: Guest lists in from Luma · Eventbrite · Partiful · POSH · BookMyShow · or a plain spreadsheet"
        ],
        "items": [],
        "links": [
          conceptActions.freePilot,
          {
            "label": "See what each tier unlocks",
            "href": "#tiers"
          }
        ],
        "layout": [
          "content"
        ]
      },
      {
        "id": "tiers",
        "heading": "Every feature is honest about what it needs.",
        "body": [
          "Illustrative concept: The model",
          "Illustrative concept: Catch Host doesn't ask you to switch platforms on day one. Each circle is cumulative — everything inside keeps working. Click a ring or a card →"
        ],
        "items": [
          {...tierMarkers.network, role: "tier-hidden"},
          {...tierMarkers.booking, role: "tier-hidden"},
          {...tierMarkers.alongside, role: "tier-hidden"},
          {
            "body": "Illustrative concept: Import a guest list from anywhere. Guests join the live event in a mobile browser — no app, no profile. You get check-in, icebreakers, messaging, and a CRM from day one. *WhatsApp campaigns use your own Meta Business account.",
            "title": "Your tools stay. The room gets smarter.",
            "label": "Start here — works alongside",
            "bullets": [
              "Illustrative concept: Guest-list import — CSV/XLSX, forwarding, Luma sync (beta)",
              "Illustrative concept: QR + manual check-in, walk-in approvals, rehearsal mode",
              "Illustrative concept: First Hello, prompts, quiet introductions, rotations & pairings",
              "Illustrative concept: Forms with payments, automations, and applications",
              "Illustrative concept: Tracked invite / promoter / referral links",
              "Illustrative concept: Scheduled reminders, announcements, WhatsApp campaigns*",
              "Illustrative concept: CRM with segments, saved audiences, merge review",
              "Illustrative concept: External payment links + evidence reconciliation"
            ],
            "role": "tier-detail",
            "tierId": "alongside"
          },
          {
            "body": "Illustrative concept: Checkout, refunds, and waitlists — plus the rules only a ticketing layer can enforce at signup, not at the door.",
            "title": "Catch sells the tickets. The numbers become real.",
            "label": "Go deeper — Catch booking",
            "bullets": [
              "Illustrative concept: Event pages, free RSVPs, paid checkout (Razorpay/Stripe)",
              "Illustrative concept: Payout accounts, refunds, post-event settlement",
              "Illustrative concept: Gender- and cohort-balanced admission caps & waitlists",
              "Illustrative concept: Cohort + demand pricing rules",
              "Illustrative concept: Age- and gender-restricted events vs. verified profiles",
              "Illustrative concept: True revenue + funnel attribution"
            ],
            "role": "tier-detail",
            "tierId": "booking"
          },
          {
            "body": "Illustrative concept: When your guests are Catch members, the event keeps working after it ends — and your audience compounds.",
            "title": "Catch helps fill the room — and keep it.",
            "label": "Full platform — Catch network",
            "bullets": [
              "Illustrative concept: Verified member profiles and event-context chat",
              "Illustrative concept: Private post-event matching — no cold DMs, no public rejection",
              "Illustrative concept: CrossPaths pair suggestions with reserved seats",
              "Illustrative concept: Discovery surface — your next event fills from the network"
            ],
            "role": "tier-detail",
            "tierId": "network"
          },
          {
            "body": "Illustrative concept: Weddings, conferences, multi-day productions: per-function schedules, household RSVPs, travel & accommodation logistics, lifecycle messaging — onboarded through managed pilots. For planners →",
            "label": "Programs",
            "role": "tier-note"
          }
        ],
        "links": [
          conceptActions.planners
        ],
        "layout": [
          "tiers"
        ]
      },
      {
        "id": "section-3",
        "heading": "Grouped by the job it does.",
        "body": [
          "Illustrative concept: The toolkit",
          "Illustrative concept: *Provider-gated: WhatsApp campaigns require your own Meta Business assets and approved templates."
        ],
        "items": [
          {
            "body": "Illustrative concept: Works alongside Forms, tracked links, imports, applications Forms with payments and automations. Named links per channel, promoter, and partner. Guest-list import by CSV/XLSX, secure forwarding, or Luma sync (beta). Applications with review built in.",
            "title": "Forms, tracked links, imports, applications",
            "label": "Get them in",
            "role": "content"
          },
          {
            "body": "Illustrative concept: Works alongside Check-in · First Hello · introductions · rotations QR and manual check-in, walk-in approvals, icebreakers, compatibility prompts, quiet introduction requests, guided pairings for pickleball, quizzes, dinners, and pace groups — plus a rehearsal mode for your team.",
            "title": "Check-in · First Hello · introductions · rotations",
            "label": "Run the room",
            "role": "content"
          },
          {
            "body": "Illustrative concept: Both tiers Payment links · paid forms · full checkout Attach your own payment links and reconcile with evidence — or sell on Catch for checkout, payouts, refunds, cohort and demand pricing.",
            "title": "Payment links · paid forms · full checkout",
            "label": "Get paid",
            "role": "content"
          },
          {
            "body": "Illustrative concept: Works alongside CRM · attribution · recap A member directory built from every event — segments, saved audiences, merge review, exports. Attribution down to the promoter link; a recap that ends in next steps.",
            "title": "CRM · attribution · recap",
            "label": "Learn & grow",
            "role": "content"
          },
          {
            "body": "Illustrative concept: Works alongside Scheduled messaging · WhatsApp · staff access Announcements and scheduled reminders. WhatsApp Business campaigns through your Meta account*. Scoped, expiring staff access for the door.",
            "title": "Scheduled messaging · WhatsApp · staff access",
            "label": "Coordinate",
            "role": "content"
          },
          {
            "body": "Illustrative concept: Managed pilot Programs, households, travel & logistics Per-function schedules and venues, household RSVPs, flight-tracked arrivals, transport dispatch, hotel inbound, vendor resources, staff duties. For planners →",
            "title": "Programs, households, travel & logistics",
            "label": "Multi-day",
            "role": "content"
          },
          {
            "body": "Illustrative concept: The guest list, the door, the messages, the money, and the recap are one connected record — not six exports stitched together at midnight.",
            "title": "Every tool reads the same event.",
            "label": "One record",
            "role": "content"
          }
        ],
        "links": [
          conceptActions.planners
        ],
        "layout": [
          "content"
        ]
      },
      {
        "id": "section-4",
        "heading": "Tell us your pile. We'll tell you the fit.",
        "body": [
          "Illustrative concept: The pile audit",
          "Illustrative concept: Every organizer runs some version of the same duct-taped stack. Pick what you use today — see what Catch keeps, what it replaces, and which tier that lands you on.",
          "Illustrative concept: The pile audit needs JavaScript — the mappings are listed in the capability section above.",
          "Illustrative concept: Select the tools you run today — we'll map each one to what it becomes on Catch.",
          "Illustrative concept: Keep your booking flow exactly as it is. Catch runs the room and the record off the roster — nothing to migrate.",
          "Illustrative concept: *SMS sender is on the roadmap — event announcements and WhatsApp campaigns are live. Roster imports are reviewed for Luma, Eventbrite, Partiful, and POSH; other platforms come in via CSV/XLSX or secure forwarding. Open the full audit →"
        ],
        "items": [],
        "links": [
          conceptActions.pilot,
          {
            "label": "Open the full audit →",
            "href": "/host/stack/"
          }
        ],
        "layout": [
          "stack"
        ]
      },
      {
        "id": "section-5",
        "heading": "Your organizer page may already exist.",
        "body": [
          "Illustrative concept: Already on Catch?",
          "Illustrative concept: Search the directory — if your events have run in our launch cities, there's likely a public page with your name on it. Claim it and the tools attach to a page guests already find."
        ],
        "items": [],
        "links": [
          {
            "label": "Claim your listing",
            "href": "/host/claim/"
          },
          conceptActions.directory
        ],
        "layout": [
          "content"
        ]
      },
      pilotSection,
      {
        "id": "section-7",
        "heading": "Fair questions.",
        "body": [],
        "items": [
          commonFaq.bookingPlatform,
          commonFaq.guestApp,
          {
            "body": "Illustrative concept: Claimed pages unlock responses, event publishing, and analytics on a public page that's already discoverable. Claiming takes a few minutes and is reviewed by a human.",
            "title": "I'm already listed on Catch — what does claiming it do?",
            "role": "content"
          },
          commonFaq.pilot,
          commonFaq.pricing,
          commonFaq.availability
        ],
        "links": [],
        "layout": [
          "faq"
        ]
      }
    ]
  },
  {
    "slug": "planners",
    "title": "Catch for planners — multi-day events without the spreadsheet sprawl",
    "description": "Illustrative concept: Household RSVPs, travel and accommodation logistics, per-function check-in, staffing, and lifecycle messaging for weddings, conferences, and multi-day productions.",
    "conceptNotice": conceptNotice,
    "sections": [
      {
        "id": "section-1",
        "heading": "The run of show is not a spreadsheet of spreadsheets.",
        "body": [
          "Illustrative concept: Catch for planners",
          "Illustrative concept: Multi-day productions have one operational record in Catch: guests and households, every function's schedule and venue, arrivals and transport, staffing, and the messages that tie it together — from save-the-date to departure."
        ],
        "items": [
          {
            "body": "Illustrative concept: Multi-day programs are onboarded through managed pilots — we set up with you, not just for you.",
            "label": "Managed pilot",
            "role": "content"
          }
        ],
        "links": [
          {
            "label": "Talk to us about your production",
            "href": "/host/apply/"
          },
          {
            "label": "See the logistics layer",
            "href": "#logistics"
          }
        ],
        "layout": [
          "content"
        ]
      },
      {
        "id": "section-2",
        "heading": "One record from save-the-date to departure.",
        "body": [
          "Illustrative concept: The engagement",
          "Illustrative concept: Guests and households, every function's schedule and venue, arrivals and transport, staffing — one operational record."
        ],
        "items": [
          {
            "body": "Illustrative concept: 01 Save-the-date and formal invitations",
            "title": "Save-the-date and formal invitations",
            "role": "content"
          },
          {
            "body": "Illustrative concept: 02 Household RSVPs with per-function answers",
            "title": "Household RSVPs with per-function answers",
            "role": "content"
          },
          {
            "body": "Illustrative concept: 03 Travel plans, flights, and pickups",
            "title": "Travel plans, flights, and pickups",
            "role": "content"
          },
          {
            "body": "Illustrative concept: 04 Per-function check-in and staffing",
            "title": "Per-function check-in and staffing",
            "role": "content"
          },
          {
            "body": "Illustrative concept: 05 Day-of alerts and schedule changes",
            "title": "Day-of alerts and schedule changes",
            "role": "content"
          },
          {
            "body": "Illustrative concept: 06 Post-event follow-up and feedback",
            "title": "Post-event follow-up and feedback",
            "role": "content"
          }
        ],
        "links": [],
        "layout": [
          "content"
        ]
      },
      {
        "id": "logistics",
        "heading": "The logistics layer.",
        "body": [
          "Illustrative concept: Programs layer"
        ],
        "items": [
          {
            "body": "Illustrative concept: Managed pilot",
            "role": "content"
          },
          {
            "body": "Illustrative concept: Guests respond per household and per function through private signed links; headcounts stay live..ics feeds keep every function on their calendar.",
            "title": "Households & invitations",
            "label": "01 · Households",
            "role": "content"
          },
          {
            "body": "Illustrative concept: Track inbound flights with automatic enrichment and alerts, build transport plans, assign pickup points, and dispatch trips — with a journal of who arrived when.",
            "title": "Arrivals & transport",
            "label": "02 · Transport",
            "role": "content"
          },
          {
            "body": "Illustrative concept: Hotel inbound tracking and vendor resources live on the same record as the guest list. Managed pilot",
            "title": "Accommodation & vendors",
            "label": "03 · Vendors",
            "role": "content"
          },
          {
            "body": "Illustrative concept: Duty-scoped assignments give your team exactly the access they need — the door sees the door, transport sees transport.",
            "title": "Staffing",
            "label": "04 · Staffing",
            "role": "content"
          }
        ],
        "links": [],
        "layout": [
          "content"
        ]
      },
      {
        "id": "section-4",
        "heading": "Every message has a place in the timeline.",
        "body": [
          "Illustrative concept: Messaging",
          "Illustrative concept: Announcements, scheduled reminders, deadline chasers, and day-of alerts. WhatsApp Business campaigns run through your own Meta account*; email and SMS senders are on the roadmap.",
          "Illustrative concept: *Provider-gated: requires your Meta Business assets and approved templates."
        ],
        "items": [],
        "links": [],
        "layout": [
          "content"
        ]
      },
      {
        "id": "section-5",
        "heading": "We run the first one with you.",
        "body": [
          "Illustrative concept: Managed pilot",
          "Illustrative concept: Programs are configured around your production — functions, households, travel flows, staffing. A managed pilot means our team maps your workflow and builds it with you before your guests ever see it."
        ],
        "items": [
          pilotSteps.event,
          {
            "body": "Illustrative concept: 02 We map your workflow on a call Functions, households, travel flows, staffing — configured around your production.",
            "title": "We map your workflow on a call",
            "role": "content"
          },
          pilotSteps.run,
          pilotSteps.review
        ],
        "links": [
          {
            "label": "Request a managed pilot",
            "href": "/host/apply/"
          }
        ],
        "layout": [
          "content"
        ]
      },
      {
        "id": "section-6",
        "heading": "Fair questions.",
        "body": [],
        "items": [
          {
            "body": "Illustrative concept: Yes. Programs can scope invitations, RSVP, and check-in per function.",
            "title": "Can we run just one function, like the reception?",
            "role": "content"
          },
          {
            "body": "Illustrative concept: Not fully — and deliberately. Productions get managed onboarding so the setup matches how you actually work.",
            "title": "Is this self-serve yet?",
            "role": "content"
          },
          commonFaq.bookingPlatform,
          commonFaq.guestApp,
          commonFaq.pilot,
          commonFaq.pricing,
          commonFaq.availability
        ],
        "links": [],
        "layout": [
          "faq"
        ]
      }
    ]
  },
  {
    "slug": "mixers",
    "title": "Catch for singles & social organizers — fill the room, balance the room, grow the revenue",
    "description": "Illustrative concept: Tracked promotion, gender-balanced admission, demand pricing, live icebreakers, and post-event matching for mixers and dating-format events.",
    "conceptNotice": conceptNotice,
    "sections": [
      {
        "id": "section-1",
        "heading": "Fill the room. Balance the room. Get paid for both.",
        "body": [
          "Illustrative concept: Catch for singles & social",
          "Illustrative concept: You already know the three problems: getting enough people, getting the right mix, and knowing which promotion rupee did what. Catch Host is built around all three."
        ],
        "items": [],
        "links": [
          conceptActions.freePilot,
          {
            "label": "See how demand works",
            "href": "#demand"
          }
        ],
        "layout": [
          "content"
        ]
      },
      {
        "id": "demand",
        "heading": "Know which promotion actually worked.",
        "body": [
          "Illustrative concept: Demand",
          "Illustrative concept: Named links for every channel, promoter, and partner. Personal referral links your attendees share themselves. Opens, registrations, and actual attendance — attributed, so next month's spend goes where it earned."
        ],
        "items": [
          {
            "body": "Illustrative concept: Catch reports what it can verify — opens, registrations, attendance. It never claims to see inside WhatsApp forwards.",
            "label": "Honest attribution",
            "role": "content"
          },
          {
            "body": "Illustrative concept: Channels Named links One link per channel, promoter, and partner — see what each actually delivered.",
            "title": "Named links",
            "role": "content"
          },
          {
            "body": "Illustrative concept: Referrals Personal referral links Your attendees share them themselves — the guest list becomes a promotion channel.",
            "title": "Personal referral links",
            "role": "content"
          },
          {
            "body": "Illustrative concept: Attribution Opens → registrations → attendance Next month's spend goes where it earned.",
            "title": "Opens → registrations → attendance",
            "role": "content"
          }
        ],
        "links": [],
        "layout": [
          "content"
        ]
      },
      {
        "id": "section-3",
        "heading": "A balanced room is a pricing feature, not a compromise.",
        "body": [
          "Illustrative concept: Admission control",
          "Illustrative concept: Cohort caps and ratios keep the mix right while the waitlist keeps filling. Differentiated cohort pricing and demand rules let the scarce side subsidize the wait — enforced at checkout, not at the door.",
          "Illustrative concept: Age- and gender-restricted events are enforced against verified member profiles. On imported guest lists, restrictions stay advisory."
        ],
        "items": [
          tierMarkers.booking,
          {
            "body": "Illustrative concept: Cohort caps & ratios",
            "role": "content"
          },
          {
            "body": "Illustrative concept: Waitlist keeps filling",
            "role": "content"
          },
          {
            "body": "Illustrative concept: Differentiated cohort pricing",
            "role": "content"
          },
          {
            "body": "Illustrative concept: Demand rules",
            "role": "content"
          },
          {
            "body": "Illustrative concept: Enforced at checkout, not the door",
            "role": "content"
          }
        ],
        "links": [],
        "layout": [
          "content"
        ]
      },
      {
        "id": "section-4",
        "heading": "Revenue you can actually read.",
        "body": [
          "Illustrative concept: Revenue",
          "Illustrative concept: Catch checkout, refunds, and settlement give you the real funnel: who viewed, who paid, who dropped, who showed. Post-event recap ties revenue to attendance instead of a payment-app export.",
          "Illustrative concept: The real funnel"
        ],
        "items": [
          tierMarkers.booking,
          {
            "body": "Illustrative concept: Who viewed",
            "role": "content"
          },
          {
            "body": "Illustrative concept: Who paid",
            "role": "content"
          },
          {
            "body": "Illustrative concept: Who dropped",
            "role": "content"
          },
          {
            "body": "Illustrative concept: Who showed",
            "role": "content"
          }
        ],
        "links": [],
        "layout": [
          "content"
        ]
      },
      {
        "id": "section-5",
        "heading": "The first ten minutes decide the event.",
        "body": [
          "Illustrative concept: Live room"
        ],
        "items": [
          {
            "body": "Illustrative concept: Gives every arrival a person and an opener.",
            "title": "First Hello",
            "label": "Icebreakers",
            "role": "content"
          },
          {
            "body": "Illustrative concept: Guests ask you for a warm intro — without public rejection.",
            "title": "Quiet requests",
            "label": "Introductions",
            "role": "content"
          },
          {
            "body": "Illustrative concept: Keep the room moving — all in the browser, no download.",
            "title": "Rotations & the mixer reveal",
            "label": "Rotations",
            "role": "content"
          }
        ],
        "links": [],
        "layout": [
          "content"
        ]
      },
      {
        "id": "section-6",
        "heading": "Events that build your audience, not just fill it.",
        "body": [
          "Illustrative concept: The upside",
          "Illustrative concept: On the Catch network, guests arrive with verified profiles, match privately after the event with shared context, and become members you can reach for the next one. CrossPaths pairs members with compatible people already going — the kind of draw a flyer can't copy."
        ],
        "items": [
          tierMarkers.network,
          {
            "body": "Illustrative concept: Verified Guests arrive with real profiles Match privately after the event with shared context.",
            "title": "Guests arrive with real profiles",
            "role": "content"
          },
          {
            "body": "Illustrative concept: CrossPaths Pair suggestions before the event Members paired with compatible people already going — the kind of draw a flyer can't copy.",
            "title": "Pair suggestions before the event",
            "role": "content"
          },
          {
            "body": "Illustrative concept: Reach Members you can reach for the next one The audience builds event over event instead of starting from zero.",
            "title": "Members you can reach for the next one",
            "role": "content"
          }
        ],
        "links": [],
        "layout": [
          "content"
        ]
      },
      pilotSection,
      {
        "id": "section-8",
        "heading": "Fair questions.",
        "body": [],
        "items": [
          {
            "body": "Illustrative concept: Yes — start standalone, import the guest list, and use the live room and attribution. Switch booking to Catch when balance and revenue truth are worth it.",
            "title": "Can I keep selling on Luma/Eventbrite?",
            "role": "content"
          },
          {
            "body": "Illustrative concept: Cohort caps, a waitlist that only releases balanced spots, and differential pricing are built for exactly this. Catch booking",
            "title": "What if the gender ratio is off?",
            "label": "Catch booking",
            "role": "content"
          },
          commonFaq.bookingPlatform,
          commonFaq.guestApp,
          commonFaq.pilot,
          commonFaq.pricing,
          commonFaq.availability
        ],
        "links": [],
        "layout": [
          "faq"
        ]
      }
    ]
  },
  {
    "slug": "clubs",
    "title": "Catch for clubs & communities — recurring events without the weekly scramble",
    "description": "Illustrative concept: Attendance, pairings, forms, reminders, and a member directory for run clubs, racket sports, trivia nights, and recurring social formats.",
    "conceptNotice": conceptNotice,
    "sections": [
      {
        "id": "section-1",
        "heading": "The weekly event, without the weekly scramble.",
        "body": [
          "Illustrative concept: Catch for clubs & communities",
          "Illustrative concept: Your regulars shouldn't re-register every week, and you shouldn't rebuild the roster. Catch remembers your community between events — and runs the part of the evening you used to improvise."
        ],
        "items": [],
        "links": [
          conceptActions.freePilot,
          {
            "label": "See the live tools",
            "href": "#live"
          }
        ],
        "layout": [
          "content"
        ]
      },
      {
        "id": "section-2",
        "heading": "The ops that repeat, automated.",
        "body": [
          "Illustrative concept: Recurring ops",
          "Illustrative concept: Catch announcements and scheduled reminders are live; WhatsApp campaigns are provider-gated; SMS and email senders are coming."
        ],
        "items": [
          {
            "body": "Illustrative concept: Repeat Duplicate the event, keep the roster, send the reminder Recurring events carry their community forward instead of starting from a blank list.",
            "title": "Duplicate the event, keep the roster, send the reminder",
            "role": "content"
          },
          {
            "body": "Illustrative concept: Forms Signups and waivers, handled Forms feed the roster directly — no re-entry between events.",
            "title": "Signups and waivers, handled",
            "role": "content"
          },
          {
            "body": "Illustrative concept: CRM Remembers everyone who's ever shown up The member directory builds itself out of your check-ins.",
            "title": "Remembers everyone who's ever shown up",
            "role": "content"
          },
          {
            "body": "Illustrative concept: Messaging Reminders and announcements on schedule WhatsApp included, through your own Meta account.",
            "title": "Reminders and announcements on schedule",
            "role": "content"
          }
        ],
        "links": [],
        "layout": [
          "content"
        ]
      },
      {
        "id": "live",
        "heading": "Pairings and pace groups, settled before the warm-up ends.",
        "body": [
          "Illustrative concept: Live tools",
          "Illustrative concept: Check people in by QR or name, then let the runtime sort the rest. Late arrivals and dropouts re-balance without you touching a spreadsheet.",
          "Illustrative concept: Formats"
        ],
        "items": [
          {
            "body": "Illustrative concept: Pace pods for run clubs and walks — sorted at check-in.",
            "title": "Pace pods",
            "label": "Run clubs",
            "role": "content"
          },
          {
            "body": "Illustrative concept: Partner rotations for pickleball, padel, tennis, and badminton.",
            "title": "Partner rotations",
            "label": "Racket sports",
            "role": "content"
          },
          {
            "body": "Illustrative concept: Table teams for trivia, pub quizzes, dinners, and supper clubs.",
            "title": "Table teams",
            "label": "Tables",
            "role": "content"
          },
          {
            "body": "Illustrative concept: Social runs",
            "role": "content"
          },
          {
            "body": "Illustrative concept: Walks",
            "role": "content"
          },
          {
            "body": "Illustrative concept: Pickleball",
            "role": "content"
          },
          {
            "body": "Illustrative concept: Padel",
            "role": "content"
          },
          {
            "body": "Illustrative concept: Tennis",
            "role": "content"
          },
          {
            "body": "Illustrative concept: Badminton",
            "role": "content"
          },
          {
            "body": "Illustrative concept: Cycling",
            "role": "content"
          },
          {
            "body": "Illustrative concept: Yoga",
            "role": "content"
          },
          {
            "body": "Illustrative concept: Dinners",
            "role": "content"
          },
          {
            "body": "Illustrative concept: Pub quizzes",
            "role": "content"
          },
          {
            "body": "Illustrative concept: Bar crawls",
            "role": "content"
          },
          {
            "body": "Illustrative concept: Mixers",
            "role": "content"
          },
          {
            "body": "Illustrative concept: Custom formats",
            "role": "content"
          }
        ],
        "links": [],
        "layout": [
          "content"
        ]
      },
      {
        "id": "section-4",
        "heading": "An attendance record that becomes a community.",
        "body": [
          "Illustrative concept: Community",
          "Illustrative concept: Every check-in builds the member directory: who's new, who's regular, who keeps bringing friends. Referral links show which members actually grow the club — and the recap shows what to fix next time."
        ],
        "items": [
          {
            "body": "Illustrative concept: Directory Member directory Who's new, who's regular, who keeps bringing friends.",
            "title": "Member directory",
            "role": "content"
          },
          {
            "body": "Illustrative concept: Referrals Referral links Show which members actually grow the club.",
            "title": "Referral links",
            "role": "content"
          },
          {
            "body": "Illustrative concept: Recap Post-event recap Shows what to fix next time.",
            "title": "Post-event recap",
            "role": "content"
          }
        ],
        "links": [],
        "layout": [
          "content"
        ]
      },
      pilotSection,
      {
        "id": "section-6",
        "heading": "Fair questions.",
        "body": [],
        "items": [
          {
            "body": "Illustrative concept: Standalone tools don't require Catch payments at all. If you collect dues or session fees, payment links and paid forms cover it without switching platforms.",
            "title": "We're free / pay-what-you-want — is this overkill?",
            "role": "content"
          },
          {
            "body": "Illustrative concept: Not for the essentials — the live event works in a browser with phone verification. Profiles only matter at the network tier.",
            "title": "Do my regulars need accounts?",
            "role": "content"
          },
          commonFaq.bookingPlatform,
          commonFaq.guestApp,
          commonFaq.pilot,
          commonFaq.pricing,
          commonFaq.availability
        ],
        "links": [],
        "layout": [
          "faq"
        ]
      }
    ]
  },
  {
    "slug": "directory",
    "title": "Catch organizer directory — find your page",
    "description": "Illustrative concept: Public, source-backed pages for organizers in our launch cities — events, formats, and reviews included. Claim yours to attach host tools, responses, and analytics.",
    "conceptNotice": conceptNotice,
    "sectionAction": conceptActions.directorySection,
    "sections": [
      {
        "id": "section-1",
        "heading": "Organizers already on the record.",
        "body": [
          "Illustrative concept: Organizer directory",
          "Illustrative concept: Public, source-backed pages for organizers in our launch cities — events, formats, and reviews included. Claim yours to attach host tools, responses, and analytics."
        ],
        "items": [],
        "links": [],
        "layout": [
          "content"
        ]
      },
      {
        "id": "section-2",
        "heading": "Find your page.",
        "body": [
          "Illustrative concept: Search the record",
          "Illustrative concept: Sample rows for the concept preview — production listings are sourced from public event data and reviews."
        ],
        "items": [
          {
            "title": "Bandra Supper Society",
            "label": "Fictional directory sample",
            "body": "Illustrative concept: B Bandra Supper Society Supper club · Mumbai · 4 sources Unclaimed — claim it",
            "role": "content"
          },
          {
            "title": "Indore Run Collective",
            "label": "Fictional directory sample",
            "body": "Illustrative concept: I Indore Run Collective Social runs · Indore · 3 sources Claimed",
            "role": "content"
          },
          {
            "title": "Courtside Padel Club",
            "label": "Fictional directory sample",
            "body": "Illustrative concept: C Courtside Padel Club Racket club · Mumbai · 5 sources Unclaimed — claim it",
            "role": "content"
          },
          {
            "title": "The Wednesday Quiz",
            "label": "Fictional directory sample",
            "body": "Illustrative concept: W The Wednesday Quiz Pub quiz · Indore · 2 sources Unclaimed — claim it",
            "role": "content"
          },
          {
            "title": "Fort Nights Social",
            "label": "Fictional directory sample",
            "body": "Illustrative concept: F Fort Nights Social Mixers · Mumbai · 3 sources Unclaimed — claim it",
            "role": "content"
          },
          {
            "title": "Slow Morning Yoga Co.",
            "label": "Fictional directory sample",
            "body": "Illustrative concept: S Slow Morning Yoga Co. Yoga · Indore · 2 sources Claimed",
            "role": "content"
          }
        ],
        "links": [
          {
            "label": "B Bandra Supper SocietySupper club · Mumbai · 4 sources Unclaimed — claim it",
            "href": "/host/claim/"
          },
          {
            "label": "C Courtside Padel ClubRacket club · Mumbai · 5 sources Unclaimed — claim it",
            "href": "/host/claim/"
          },
          {
            "label": "W The Wednesday QuizPub quiz · Indore · 2 sources Unclaimed — claim it",
            "href": "/host/claim/"
          },
          {
            "label": "F Fort Nights SocialMixers · Mumbai · 3 sources Unclaimed — claim it",
            "href": "/host/claim/"
          }
        ],
        "layout": [
          "content"
        ]
      },
      {
        "id": "section-3",
        "heading": "Prototype content",
        "body": [],
        "items": [
          {
            "body": "Illustrative concept: Pilot access is for organizers with real upcoming events — listed or not. Request a pilot",
            "title": "Not listed yet?",
            "label": "Pilot access",
            "role": "content"
          }
        ],
        "links": [
          conceptActions.pilot
        ],
        "layout": [
          "faq"
        ]
      }
    ]
  },
  {
    "slug": "claim",
    "title": "Claim your organizer page — Catch",
    "description": "Illustrative concept: Claim your public organizer page on Catch — verified by a human before host tools, responses, and analytics attach to it.",
    "conceptNotice": conceptNotice,
    "sectionAction": conceptActions.claimSection,
    "sections": [
      {
        "id": "section-1",
        "heading": "This page is yours. Prove it.",
        "body": [
          "Illustrative concept: Claim your listing",
          "Illustrative concept: Every claim is reviewed by a human before anything attaches to the page. Tell us who you are, show a little proof, and the listing's tools unlock once it checks out."
        ],
        "items": [],
        "links": [
          conceptActions.directory,
          {
            "label": "See how it works",
            "href": "#how"
          }
        ],
        "layout": [
          "content"
        ]
      },
      {
        "id": "how",
        "heading": "Three steps. One review.",
        "body": [
          "Illustrative concept: The flow",
          "Illustrative concept: Claiming takes a few minutes. Nothing goes live on the page until a person on our team signs off."
        ],
        "items": [
          {
            "body": "Illustrative concept: 01 Find your listing Search the directory and pick your organizer page.",
            "title": "Find your listing",
            "role": "content"
          },
          {
            "body": "Illustrative concept: 02 Tell us who you are Name, role, work email or phone, and a few proof links.",
            "title": "Tell us who you are",
            "role": "content"
          },
          {
            "body": "Illustrative concept: 03 Verify & submit Choose a verification method, sign in with Google, submit — we review before tools attach.",
            "title": "Verify & submit",
            "role": "content"
          }
        ],
        "links": [],
        "layout": [
          "content"
        ]
      },
      {
        "id": "section-3",
        "heading": "Your page, working for you.",
        "body": [
          "Illustrative concept: What claiming unlocks"
        ],
        "items": [
          {
            "body": "Illustrative concept: Answer guests where the public record lives.",
            "title": "Respond to reviews",
            "label": "Reviews",
            "role": "content"
          },
          {
            "body": "Illustrative concept: Your next event posts straight to your page.",
            "title": "Publish & manage events",
            "label": "Events",
            "role": "content"
          },
          {
            "body": "Illustrative concept: Views, sources, and the searches that find you.",
            "title": "See listing analytics",
            "label": "Analytics",
            "role": "content"
          },
          {
            "body": "Illustrative concept: Guest lists, check-in, and messaging — on the listing people already find.",
            "title": "Attach host tools",
            "label": "Host tools",
            "role": "content"
          }
        ],
        "links": [],
        "layout": [
          "content"
        ]
      },
      {
        "id": "section-4",
        "heading": "Where a claim can land.",
        "body": [
          "Illustrative concept: Listing states"
        ],
        "items": [
          {
            "body": "Illustrative concept: State 01 Pending review We verify ownership first — a human reads every claim before anything attaches. In queue",
            "title": "Pending review",
            "label": "In queue",
            "role": "content"
          },
          {
            "body": "Illustrative concept: State 02 Already claimed If that's wrong, contact us — disputes are reviewed by hand. Dispute path",
            "title": "Already claimed",
            "label": "Dispute path",
            "role": "content"
          },
          {
            "body": "Illustrative concept: State 03 Unavailable Some listings aren't claimable yet — request a pilot instead. Locked",
            "title": "Unavailable",
            "label": "Locked",
            "role": "content"
          }
        ],
        "links": [],
        "layout": [
          "content"
        ]
      },
      {
        "id": "section-5",
        "heading": "Found your page? Start there.",
        "body": [
          "Illustrative concept: Start your claim",
          "Illustrative concept: Search the directory to find your listing. Not listed? Pilots are open to organizers with real upcoming events either way."
        ],
        "items": [],
        "links": [
          conceptActions.directory,
          {
            "label": "Request a pilot instead",
            "href": "/host/apply/"
          }
        ],
        "layout": [
          "content"
        ]
      },
      {
        "id": "section-6",
        "heading": "Fair questions.",
        "body": [],
        "items": [
          {
            "body": "Illustrative concept: Role, contact details, and proof links — then a human reviews the claim. Tools don't attach until it passes.",
            "title": "How do you verify ownership?",
            "role": "content"
          },
          {
            "body": "Illustrative concept: Claim it and correct it — corrections go through the same review before they publish.",
            "title": "What if my page shows wrong info?",
            "role": "content"
          },
          {
            "body": "Illustrative concept: Contact us from the listing page — disputes are reviewed.",
            "title": "Claimed by someone else?",
            "role": "content"
          }
        ],
        "links": [],
        "layout": [
          "faq"
        ]
      }
    ]
  },
  {
    "slug": "apply",
    "title": "Request a free pilot — Catch Host",
    "description": "Illustrative concept: Five quick steps — who you are, the event you'd run, your current setup, and where Catch could help most. We review every application ourselves.",
    "conceptNotice": conceptNotice,
    "sectionAction": conceptActions.applySection,
    "sections": [
      {
        "id": "section-1",
        "heading": "Request a free pilot.",
        "body": [
          "Illustrative concept: Pilot request",
          "Illustrative concept: Five quick steps — who you are, the event you'd run, your current setup, and where Catch could help most. We review every application ourselves and reply about scheduling a call."
        ],
        "items": [
          {
            "body": "Illustrative concept: Free during the pilot. No platform switch required to start.",
            "label": "The pilot",
            "role": "content"
          },
          {
            "body": "Illustrative concept: Application form mounts here — existing 5-step flow: About you → Your next event → Current setup → What you'd use → Review & send",
            "role": "content"
          }
        ],
        "links": [],
        "layout": [
          "content"
        ]
      },
      {
        "id": "section-2",
        "heading": "Five quick steps.",
        "body": [
          "Illustrative concept: The application"
        ],
        "items": [
          {
            "body": "Illustrative concept: 01 About you Who hosts and what you run.",
            "title": "About you",
            "role": "content"
          },
          {
            "body": "Illustrative concept: 02 Your next event The real event we'd pilot on.",
            "title": "Your next event",
            "role": "content"
          },
          {
            "body": "Illustrative concept: 03 Your current setup Booking/RSVP platform and guest-list size.",
            "title": "Your current setup",
            "role": "content"
          },
          {
            "body": "Illustrative concept: 04 What you'd use The capabilities that matter most.",
            "title": "What you'd use",
            "role": "content"
          },
          {
            "body": "Illustrative concept: 05 Review & send Confirm and we schedule a call.",
            "title": "Review & send",
            "role": "content"
          }
        ],
        "links": [],
        "layout": [
          "content"
        ]
      },
      {
        "id": "section-3",
        "heading": "Application in.",
        "body": [
          "Illustrative concept: After you send",
          "Illustrative concept: We read every one — expect a call scheduling link if your event is a good pilot fit."
        ],
        "items": [],
        "links": [
          {
            "label": "See what Catch Host does",
            "href": "/host/platform/"
          }
        ],
        "layout": [
          "content"
        ]
      }
    ]
  },
  {
    "slug": "stack",
    "title": "The pile audit — map your event stack on Catch",
    "description": "Illustrative concept: Pick the tools you run today. See what Catch keeps, what it replaces, and which tier your stack lands on.",
    "conceptNotice": conceptNotice,
    "sections": [
      {
        "id": "section-1",
        "heading": "Map your stack. Keep what works.",
        "body": [
          "Illustrative concept: The pile audit",
          "Illustrative concept: Nobody wakes up wanting another platform. Tick the tools your event actually runs on — we'll show you exactly what Catch keeps, what it replaces, and where your stack lands.",
          "Illustrative concept: Tap a receipt row for the detail →"
        ],
        "items": [],
        "links": [],
        "layout": [
          "content"
        ]
      },
      {
        "id": "section-2",
        "heading": "What do you run today?",
        "body": [
          "Illustrative concept: Step one",
          "Illustrative concept: The audit needs JavaScript to run — the mappings are summarized on the host page.",
          "Illustrative concept: Select the tools you run today — we'll map each one to what it becomes on Catch.",
          "Illustrative concept: Keep your booking flow exactly as it is. Catch runs the room and the record off the roster — nothing to migrate.",
          "Illustrative concept: *SMS sender is on the roadmap — event announcements and WhatsApp campaigns are live. Roster imports are reviewed for Luma, Eventbrite, Partiful, and POSH; other platforms come in via CSV/XLSX or secure forwarding."
        ],
        "items": [],
        "links": [
          conceptActions.pilot
        ],
        "layout": [
          "stack"
        ]
      },
      {
        "id": "section-3",
        "heading": "Five fractures every duct-taped stack shares.",
        "body": [
          "Illustrative concept: Why the pile hurts"
        ],
        "items": [
          {
            "body": "Illustrative concept: Every adjacent pair of tools is a manual export-import. The form feeds the sheet; the sheet feeds the broadcast list; nothing feeds back.",
            "title": "CSV churn",
            "label": "01",
            "role": "content"
          },
          {
            "body": "Illustrative concept: The Razorpay dashboard and the guest list never merge. \"I paid but I'm not on the list\" gets resolved by screenshot.",
            "title": "Payment ≠ attendance",
            "label": "02",
            "role": "content"
          },
          {
            "body": "Illustrative concept: Priya attended three events and no-showed once — invisible. Every event starts a fresh sheet from zero.",
            "title": "No identity continuity",
            "label": "03",
            "role": "content"
          },
          {
            "body": "Illustrative concept: \"Reminder to confirmed-but-unpaid\" requires export, filter, re-import. So it doesn't get sent.",
            "title": "Messages off the record",
            "label": "04",
            "role": "content"
          },
          {
            "body": "Illustrative concept: The data dies in a sheet instead of becoming the next event's invite list. Reach resets to zero every time.",
            "title": "No post-event loop",
            "label": "05",
            "role": "content"
          },
          {
            "body": "Illustrative concept: Registration, payment, comms, check-in, and memory — the same guest, start to finish.",
            "title": "One record, end to end.",
            "label": "The fix",
            "role": "content"
          }
        ],
        "links": [],
        "layout": [
          "content"
        ]
      },
      {
        "id": "section-4",
        "heading": "Bring the pile. We'll map it on the call.",
        "body": [
          "Illustrative concept: Next step",
          "Illustrative concept: Pilots are free and scoped to a real event. If a chunk of your stack needs keeping, that's the design — not a blocker."
        ],
        "items": [],
        "links": [
          conceptActions.freePilot,
          {
            "label": "Back to the platform",
            "href": "/host/platform/"
          }
        ],
        "layout": [
          "content"
        ]
      }
    ]
  }
];
