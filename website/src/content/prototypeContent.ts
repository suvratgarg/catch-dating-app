/** Authored prototype content retained for migration. originalCopy is reference-only,
 * never production display copy. No raw HTML, concept JS/CSS, or demo endpoints. */
export interface PrototypeSourceLink { readonly label: string; readonly sourceHref: string }
export interface PrototypeContentItem { readonly label?: string; readonly title?: string; readonly body: string; readonly bullets?: readonly string[]; readonly originalCopy: readonly string[] }
export interface PrototypeContentSection { readonly id: string; readonly sourceId: string | null; readonly heading: string; readonly body: readonly string[]; readonly items: readonly PrototypeContentItem[]; readonly links: readonly PrototypeSourceLink[]; readonly interactionHints: readonly string[]; readonly originalCopy: readonly string[] }
export interface PrototypeSourceForm { readonly action: string | null; readonly method: string | null; readonly role: string | null; readonly fields: readonly { readonly tag: string; readonly attributes: Readonly<Record<string, string | null>> }[] }
export interface PrototypeContentPage { readonly sourceFile: string; readonly slug: string; readonly title: string; readonly description: string; readonly originalDescription: string; readonly conceptNotice: string; readonly sections: readonly PrototypeContentSection[]; readonly headerDestinations: readonly PrototypeSourceLink[]; readonly footerCopy: readonly string[]; readonly footerDestinations: readonly PrototypeSourceLink[]; readonly sourceSha256: string; readonly sourceForms: readonly PrototypeSourceForm[] }
export const prototypeContentPages: readonly PrototypeContentPage[] = [
  {
    "sourceFile": "index.html",
    "slug": "index",
    "title": "Catch — the room before the match",
    "description": "Illustrative concept: Catch runs curated social events where showing up comes before matching — and gives hosts one system from guest list to last goodbye.",
    "originalDescription": "Catch runs curated social events where showing up comes before matching — and gives hosts one system from guest list to last goodbye.",
    "conceptNotice": "Content migrated from the static concept. Availability, integrations, pricing, example events, listing samples and predicted outcomes require verification; this page does not grant access or promise production support.",
    "sections": [
      {
        "id": "section-1",
        "sourceId": null,
        "heading": "The room before the match.",
        "body": [
          "Illustrative concept: Curated events · Verified attendance · Real context",
          "Illustrative concept: Curated runs, dinners, quiz nights, and mixers where people meet in person first — and the host tooling that makes those rooms worth attending."
        ],
        "items": [
          {
            "body": "Illustrative concept: Tonight · Bandra · 40 seats 31 in",
            "originalCopy": [
              "Sunday Supper Club",
              "Tonight · Bandra · 40 seats",
              "31",
              "in"
            ],
            "title": "Sunday Supper Club"
          },
          {
            "body": "Illustrative concept: Sat · Indore · pace pods on opens 7:00",
            "originalCopy": [
              "Saturday Social Run",
              "Sat · Indore · pace pods on",
              "opens 7:00"
            ],
            "title": "Saturday Social Run"
          },
          {
            "body": "Illustrative concept: Fri · Mumbai · teams forming waitlist 12",
            "originalCopy": [
              "Quiz Night XI",
              "Fri · Mumbai · teams forming",
              "waitlist 12"
            ],
            "title": "Quiz Night XI"
          },
          {
            "body": "Illustrative concept: 19:02 Avery checked in — guest list verified",
            "originalCopy": [
              "19:02",
              "Avery checked in — guest list verified"
            ]
          },
          {
            "body": "Illustrative concept: 19:02 First Hello sent → \"Find Jordan, ask about the duet\"",
            "originalCopy": [
              "19:02",
              "First Hello sent → \"Find Jordan, ask about the duet\""
            ]
          },
          {
            "body": "Illustrative concept: 19:04 Wingman request — host review queued",
            "originalCopy": [
              "19:04",
              "Wingman request — host review queued"
            ]
          },
          {
            "body": "Illustrative concept: 19:05 Morgan checked in — walk-in approved",
            "originalCopy": [
              "19:05",
              "Morgan checked in — walk-in approved"
            ]
          },
          {
            "body": "Illustrative concept: 19:07 Table rotations published to 6 groups",
            "originalCopy": [
              "19:07",
              "Table rotations published to 6 groups"
            ]
          },
          {
            "body": "Illustrative concept: 19:09 Referral link \"priya-share\" → 3 opens, 1 registered",
            "originalCopy": [
              "19:09",
              "Referral link \"priya-share\" → 3 opens, 1 registered"
            ]
          }
        ],
        "links": [
          {
            "label": "I host events",
            "sourceHref": "host.html"
          },
          {
            "label": "I'm here to attend",
            "sourceHref": "#attend"
          }
        ],
        "interactionHints": [
          "data-checkin",
          "data-console",
          "data-count",
          "data-reveal"
        ],
        "originalCopy": [
          "Curated events · Verified attendance · Real context",
          "The room",
          "before",
          "the match.",
          "Curated runs, dinners, quiz nights, and mixers where people meet in person first — and the host tooling that makes those rooms worth attending.",
          "I host events",
          "I'm here to attend",
          "Catch Host — live event console",
          "Sunday Supper Club",
          "Tonight · Bandra · 40 seats",
          "31",
          "in",
          "Saturday Social Run",
          "Sat · Indore · pace pods on",
          "opens 7:00",
          "Quiz Night XI",
          "Fri · Mumbai · teams forming",
          "waitlist 12",
          "19:02",
          "Avery checked in — guest list verified",
          "19:02",
          "First Hello sent → \"Find Jordan, ask about the duet\"",
          "19:04",
          "Wingman request — host review queued",
          "19:05",
          "Morgan checked in — walk-in approved",
          "19:07",
          "Table rotations published to 6 groups",
          "19:09",
          "Referral link \"priya-share\" → 3 opens, 1 registered",
          "live",
          "no-download guest runtime",
          "host overrides on"
        ]
      },
      {
        "id": "section-2",
        "sourceId": null,
        "heading": "Happening on Catch.",
        "body": [
          "Illustrative concept: Live in Mumbai & Indore",
          "Illustrative concept: Sat 7:00 · Indore · pace pods",
          "Illustrative concept: Sun 19:00 · Bandra · table rotations",
          "Illustrative concept: Fri 20:00 · Mumbai · team mixer",
          "Illustrative concept: Real upcoming events and organizers publish here from the Catch directory. Browse all →"
        ],
        "items": [
          {
            "body": "Illustrative concept: Sat 7:00 · Indore · pace pods",
            "originalCopy": [
              "Social run",
              "Saturday Social Run",
              "Sat 7:00 · Indore · pace pods"
            ],
            "title": "Saturday Social Run",
            "label": "Social run"
          },
          {
            "body": "Illustrative concept: Sun 19:00 · Bandra · table rotations",
            "originalCopy": [
              "Supper club",
              "Sunday Supper Club",
              "Sun 19:00 · Bandra · table rotations"
            ],
            "title": "Sunday Supper Club",
            "label": "Supper club"
          },
          {
            "body": "Illustrative concept: Fri 20:00 · Mumbai · team mixer",
            "originalCopy": [
              "Pub quiz",
              "Quiz Night XI",
              "Fri 20:00 · Mumbai · team mixer"
            ],
            "title": "Quiz Night XI",
            "label": "Pub quiz"
          }
        ],
        "links": [
          {
            "label": "Social run Saturday Social RunSat 7:00 · Indore · pace pods",
            "sourceHref": "#"
          },
          {
            "label": "Supper club Sunday Supper ClubSun 19:00 · Bandra · table rotations",
            "sourceHref": "#"
          },
          {
            "label": "Pub quiz Quiz Night XIFri 20:00 · Mumbai · team mixer",
            "sourceHref": "#"
          },
          {
            "label": "Browse all →",
            "sourceHref": "directory.html"
          }
        ],
        "interactionHints": [
          "data-reveal"
        ],
        "originalCopy": [
          "Live in Mumbai & Indore",
          "Happening on Catch.",
          "Search",
          "Social run",
          "Saturday Social Run",
          "Sat 7:00 · Indore · pace pods",
          "Supper club",
          "Sunday Supper Club",
          "Sun 19:00 · Bandra · table rotations",
          "Pub quiz",
          "Quiz Night XI",
          "Fri 20:00 · Mumbai · team mixer",
          "Real upcoming events and organizers publish here from the Catch directory.",
          "Browse all →"
        ]
      },
      {
        "id": "section-3",
        "sourceId": null,
        "heading": "Built around the way you host.",
        "body": [
          "Illustrative concept: For hosts",
          "Illustrative concept: Catch Host works at whatever level you run — pick the lane that sounds like you.",
          "Illustrative concept: Weddings, conferences, retreats. Households, travel, staffing, and every message in between.",
          "Illustrative concept: Fill the room, balance the room, and see which promotion actually worked.",
          "Illustrative concept: Run clubs, pickleball, trivia, supper clubs — weekly events without the weekly scramble."
        ],
        "items": [
          {
            "body": "Illustrative concept: Weddings, conferences, retreats. Households, travel, staffing, and every message in between. For planners →",
            "originalCopy": [
              "01 · Planners",
              "Multi-day productions",
              "Weddings, conferences, retreats. Households, travel, staffing, and every message in between.",
              "For planners →"
            ],
            "title": "Multi-day productions",
            "label": "01 · Planners"
          },
          {
            "body": "Illustrative concept: Fill the room, balance the room, and see which promotion actually worked. For organizers →",
            "originalCopy": [
              "02 · Singles & social",
              "Mixers & dating formats",
              "Fill the room, balance the room, and see which promotion actually worked.",
              "For organizers →"
            ],
            "title": "Mixers & dating formats",
            "label": "02 · Singles & social"
          },
          {
            "body": "Illustrative concept: Run clubs, pickleball, trivia, supper clubs — weekly events without the weekly scramble. For communities →",
            "originalCopy": [
              "03 · Communities",
              "Clubs & recurring events",
              "Run clubs, pickleball, trivia, supper clubs — weekly events without the weekly scramble.",
              "For communities →"
            ],
            "title": "Clubs & recurring events",
            "label": "03 · Communities"
          }
        ],
        "links": [
          {
            "label": "01 · Planners Multi-day productions Weddings, conferences, retreats. Households, travel, staffing, and every message in between. For planners →",
            "sourceHref": "planners.html"
          },
          {
            "label": "02 · Singles & social Mixers & dating formats Fill the room, balance the room, and see which promotion actually worked. For organizers →",
            "sourceHref": "mixers.html"
          },
          {
            "label": "03 · Communities Clubs & recurring events Run clubs, pickleball, trivia, supper clubs — weekly events without the weekly scramble. For communities →",
            "sourceHref": "clubs.html"
          }
        ],
        "interactionHints": [
          "data-reveal"
        ],
        "originalCopy": [
          "For hosts",
          "Built around",
          "the way",
          "you host.",
          "Catch Host works at whatever level you run — pick the lane that sounds like you.",
          "01 · Planners",
          "Multi-day productions",
          "Weddings, conferences, retreats. Households, travel, staffing, and every message in between.",
          "For planners →",
          "02 · Singles & social",
          "Mixers & dating formats",
          "Fill the room, balance the room, and see which promotion actually worked.",
          "For organizers →",
          "03 · Communities",
          "Clubs & recurring events",
          "Run clubs, pickleball, trivia, supper clubs — weekly events without the weekly scramble.",
          "For communities →"
        ]
      },
      {
        "id": "section-4",
        "sourceId": null,
        "heading": "One system. Three levels of commitment.",
        "body": [
          "Illustrative concept: Catch Host",
          "Illustrative concept: Start with the guest list you already have. Move booking onto Catch when you're ready. Plug into the member network when you want the platform to help fill the room.",
          "Illustrative concept: Import the guest list. Run check-in, icebreakers, forms, messaging, and CRM — no platform switch.",
          "Illustrative concept: Checkout, waitlists, balanced admission, demand pricing, revenue truth.",
          "Illustrative concept: Verified member profiles, post-event matching, discovery, CrossPaths."
        ],
        "items": [
          {
            "body": "Illustrative concept: Works alongside Your tools stay Import the guest list. Run check-in, icebreakers, forms, messaging, and CRM — no platform switch.",
            "originalCopy": [
              "Works alongside",
              "Your tools stay",
              "Import the guest list. Run check-in, icebreakers, forms, messaging, and CRM — no platform switch."
            ],
            "title": "Your tools stay"
          },
          {
            "body": "Illustrative concept: Catch booking We sell the tickets Checkout, waitlists, balanced admission, demand pricing, revenue truth.",
            "originalCopy": [
              "Catch booking",
              "We sell the tickets",
              "Checkout, waitlists, balanced admission, demand pricing, revenue truth."
            ],
            "title": "We sell the tickets"
          },
          {
            "body": "Illustrative concept: Catch network We help fill the room Verified member profiles, post-event matching, discovery, CrossPaths.",
            "originalCopy": [
              "Catch network",
              "We help fill the room",
              "Verified member profiles, post-event matching, discovery, CrossPaths."
            ],
            "title": "We help fill the room"
          }
        ],
        "links": [
          {
            "label": "See what each tier unlocks",
            "sourceHref": "host.html#tiers"
          }
        ],
        "interactionHints": [
          "data-reveal"
        ],
        "originalCopy": [
          "Catch Host",
          "One system.",
          "Three levels",
          "of commitment.",
          "Start with the guest list you already have. Move booking onto Catch when you're ready. Plug into the member network when you want the platform to help fill the room.",
          "See what each tier unlocks",
          "Works alongside",
          "Your tools stay",
          "Import the guest list. Run check-in, icebreakers, forms, messaging, and CRM — no platform switch.",
          "Catch booking",
          "We sell the tickets",
          "Checkout, waitlists, balanced admission, demand pricing, revenue truth.",
          "Catch network",
          "We help fill the room",
          "Verified member profiles, post-event matching, discovery, CrossPaths."
        ]
      },
      {
        "id": "section-5",
        "sourceId": null,
        "heading": "Your organizer page may already exist.",
        "body": [
          "Illustrative concept: Already on Catch?",
          "Illustrative concept: We maintain public, source-backed profiles for organizers in our launch markets — events, formats, and reviews included. Claim yours to unlock host tools, responses, and analytics on a page that's already ranking.",
          "Illustrative concept: Your public page may already exist — sourced from public event data.",
          "Illustrative concept: Role, contact details, and proof links — reviewed by a human.",
          "Illustrative concept: Responses, event publishing, analytics — on the listing people already find."
        ],
        "items": [
          {
            "body": "Illustrative concept: Search Find your listing Your public page may already exist — sourced from public event data.",
            "originalCopy": [
              "Search",
              "Find your listing",
              "Your public page may already exist — sourced from public event data."
            ],
            "title": "Find your listing"
          },
          {
            "body": "Illustrative concept: Verify Prove it's you Role, contact details, and proof links — reviewed by a human.",
            "originalCopy": [
              "Verify",
              "Prove it's you",
              "Role, contact details, and proof links — reviewed by a human."
            ],
            "title": "Prove it's you"
          },
          {
            "body": "Illustrative concept: Unlock Tools attach to the page Responses, event publishing, analytics — on the listing people already find.",
            "originalCopy": [
              "Unlock",
              "Tools attach to the page",
              "Responses, event publishing, analytics — on the listing people already find."
            ],
            "title": "Tools attach to the page"
          }
        ],
        "links": [
          {
            "label": "Find & claim your page",
            "sourceHref": "claim.html"
          },
          {
            "label": "Browse the directory",
            "sourceHref": "directory.html"
          }
        ],
        "interactionHints": [
          "data-reveal"
        ],
        "originalCopy": [
          "Already on Catch?",
          "Your organizer page may already exist.",
          "We maintain public, source-backed profiles for organizers in our launch markets — events, formats, and reviews included. Claim yours to unlock host tools, responses, and analytics on a page that's already ranking.",
          "Find & claim your page",
          "Browse the directory",
          "Search",
          "Find your listing",
          "Your public page may already exist — sourced from public event data.",
          "Verify",
          "Prove it's you",
          "Role, contact details, and proof links — reviewed by a human.",
          "Unlock",
          "Tools attach to the page",
          "Responses, event publishing, analytics — on the listing people already find."
        ]
      },
      {
        "id": "attend",
        "sourceId": "attend",
        "heading": "Here for the events, not the tooling?",
        "body": [
          "Illustrative concept: Catch is live for members in Mumbai and Indore. Join the waitlist to hear when new cities and formats open.",
          "Illustrative concept: iOS + Android app links appear here in production"
        ],
        "items": [],
        "links": [
          {
            "label": "Join the member waitlist",
            "sourceHref": "#waitlist"
          }
        ],
        "interactionHints": [
          "data-reveal"
        ],
        "originalCopy": [
          "Here for the events,",
          "not the tooling?",
          "Catch is live for members in Mumbai and Indore. Join the waitlist to hear when new cities and formats open.",
          "Join the member waitlist",
          "iOS + Android app links appear here in production"
        ]
      }
    ],
    "headerDestinations": [
      {
        "label": "Catch.",
        "sourceHref": "index.html"
      },
      {
        "label": "For hosts",
        "sourceHref": "host.html"
      },
      {
        "label": "Stack audit",
        "sourceHref": "stack.html"
      },
      {
        "label": "Organizer directory",
        "sourceHref": "directory.html"
      },
      {
        "label": "Planners",
        "sourceHref": "planners.html"
      },
      {
        "label": "Singles & social",
        "sourceHref": "mixers.html"
      },
      {
        "label": "Clubs",
        "sourceHref": "clubs.html"
      },
      {
        "label": "Request a pilot",
        "sourceHref": "apply.html"
      }
    ],
    "footerCopy": [
      "Catch Host — the operating system for real-world events.",
      "Directory · Claim your page · Privacy · Terms · Help"
    ],
    "footerDestinations": [],
    "sourceSha256": "448c6da7286263c3a6f541f46e739b94c3e984f753c920e8670f7c80e2965c59",
    "sourceForms": [
      {
        "action": "directory.html",
        "method": "get",
        "role": "search",
        "fields": [
          {
            "tag": "input",
            "attributes": {
              "type": "search",
              "name": "q",
              "placeholder": "Events, organizers, formats…",
              "aria-label": "Search events and organizers"
            }
          },
          {
            "tag": "button",
            "attributes": {
              "type": "submit"
            }
          }
        ]
      }
    ]
  },
  {
    "sourceFile": "host.html",
    "slug": "host",
    "title": "Catch Host — the operating system for real-world events",
    "description": "Illustrative concept: Forms, guest lists, check-in, live room tools, payments, messaging, CRM, and attribution — working alongside your booking platform or as it.",
    "originalDescription": "Forms, guest lists, check-in, live room tools, payments, messaging, CRM, and attribution — working alongside your booking platform or as it.",
    "conceptNotice": "Content migrated from the static concept. Availability, integrations, pricing, example events, listing samples and predicted outcomes require verification; this page does not grant access or promise production support.",
    "sections": [
      {
        "id": "section-1",
        "sourceId": null,
        "heading": "Your booking tool stops at the sale. That's where we start.",
        "body": [
          "Illustrative concept: Catch Host",
          "Illustrative concept: Catch Host is the operating layer for live events. Bring the guest list you already have — get a no-download live room, attendance, guest messaging, and a real CRM. Unlock ticketing, balanced admission, and the member network as you go deeper.",
          "Illustrative concept: Guest lists in from Luma · Eventbrite · Partiful · POSH · BookMyShow · or a plain spreadsheet"
        ],
        "items": [],
        "links": [
          {
            "label": "Request a free pilot",
            "sourceHref": "apply.html"
          },
          {
            "label": "See what each tier unlocks",
            "sourceHref": "#tiers"
          }
        ],
        "interactionHints": [
          "data-reveal"
        ],
        "originalCopy": [
          "Catch Host",
          "Your booking tool stops at the sale.",
          "That's where we start.",
          "Catch Host is the operating layer for live events. Bring the guest list you already have — get a no-download live room, attendance, guest messaging, and a real CRM. Unlock ticketing, balanced admission, and the member network as you go deeper.",
          "Request a free pilot",
          "See what each tier unlocks",
          "Guest lists in from  Luma · Eventbrite · Partiful · POSH · BookMyShow · or a plain spreadsheet"
        ]
      },
      {
        "id": "tiers",
        "sourceId": "tiers",
        "heading": "Every feature is honest about what it needs.",
        "body": [
          "Illustrative concept: The model",
          "Illustrative concept: Catch Host doesn't ask you to switch platforms on day one. Each circle is cumulative — everything inside keeps working. Click a ring or a card →",
          "Illustrative concept: Import a guest list from anywhere. Guests join the live event in a mobile browser — no app, no profile. You get check-in, icebreakers, messaging, and a CRM from day one.",
          "Illustrative concept: *WhatsApp campaigns use your own Meta Business account.",
          "Illustrative concept: Checkout, refunds, and waitlists — plus the rules only a ticketing layer can enforce at signup, not at the door.",
          "Illustrative concept: When your guests are Catch members, the event keeps working after it ends — and your audience compounds."
        ],
        "items": [
          {
            "body": "Illustrative concept: Catch network",
            "originalCopy": [
              "Catch network"
            ]
          },
          {
            "body": "Illustrative concept: Catch booking",
            "originalCopy": [
              "Catch booking"
            ]
          },
          {
            "body": "Illustrative concept: Works alongside",
            "originalCopy": [
              "Works alongside"
            ]
          },
          {
            "body": "Illustrative concept: Import a guest list from anywhere. Guests join the live event in a mobile browser — no app, no profile. You get check-in, icebreakers, messaging, and a CRM from day one. *WhatsApp campaigns use your own Meta Business account.",
            "originalCopy": [
              "Start here — works alongside",
              "tap to expand",
              "Your tools stay. The room gets smarter.",
              "Import a guest list from anywhere. Guests join the live event in a mobile browser — no app, no profile. You get check-in, icebreakers, messaging, and a CRM from day one.",
              "Guest-list import — CSV/XLSX, forwarding, Luma sync (beta)",
              "QR + manual check-in, walk-in approvals, rehearsal mode",
              "First Hello, prompts, quiet introductions, rotations & pairings",
              "Forms with payments, automations, and applications",
              "Tracked invite / promoter / referral links",
              "Scheduled reminders, announcements, WhatsApp campaigns*",
              "CRM with segments, saved audiences, merge review",
              "External payment links + evidence reconciliation",
              "*WhatsApp campaigns use your own Meta Business account."
            ],
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
            ]
          },
          {
            "body": "Illustrative concept: Checkout, refunds, and waitlists — plus the rules only a ticketing layer can enforce at signup, not at the door.",
            "originalCopy": [
              "Go deeper — Catch booking",
              "tap to expand",
              "Catch sells the tickets. The numbers become real.",
              "Checkout, refunds, and waitlists — plus the rules only a ticketing layer can enforce at signup, not at the door.",
              "Event pages, free RSVPs, paid checkout (Razorpay/Stripe)",
              "Payout accounts, refunds, post-event settlement",
              "Gender- and cohort-balanced admission caps & waitlists",
              "Cohort + demand pricing rules",
              "Age- and gender-restricted events vs. verified profiles",
              "True revenue + funnel attribution"
            ],
            "title": "Catch sells the tickets. The numbers become real.",
            "label": "Go deeper — Catch booking",
            "bullets": [
              "Illustrative concept: Event pages, free RSVPs, paid checkout (Razorpay/Stripe)",
              "Illustrative concept: Payout accounts, refunds, post-event settlement",
              "Illustrative concept: Gender- and cohort-balanced admission caps & waitlists",
              "Illustrative concept: Cohort + demand pricing rules",
              "Illustrative concept: Age- and gender-restricted events vs. verified profiles",
              "Illustrative concept: True revenue + funnel attribution"
            ]
          },
          {
            "body": "Illustrative concept: When your guests are Catch members, the event keeps working after it ends — and your audience compounds.",
            "originalCopy": [
              "Full platform — Catch network",
              "tap to expand",
              "Catch helps fill the room — and keep it.",
              "When your guests are Catch members, the event keeps working after it ends — and your audience compounds.",
              "Verified member profiles and event-context chat",
              "Private post-event matching — no cold DMs, no public rejection",
              "CrossPaths pair suggestions with reserved seats",
              "Discovery surface — your next event fills from the network"
            ],
            "title": "Catch helps fill the room — and keep it.",
            "label": "Full platform — Catch network",
            "bullets": [
              "Illustrative concept: Verified member profiles and event-context chat",
              "Illustrative concept: Private post-event matching — no cold DMs, no public rejection",
              "Illustrative concept: CrossPaths pair suggestions with reserved seats",
              "Illustrative concept: Discovery surface — your next event fills from the network"
            ]
          },
          {
            "body": "Illustrative concept: Weddings, conferences, multi-day productions: per-function schedules, household RSVPs, travel & accommodation logistics, lifecycle messaging — onboarded through managed pilots. For planners →",
            "originalCopy": [
              "Programs",
              "Weddings, conferences, multi-day productions: per-function schedules, household RSVPs, travel & accommodation logistics, lifecycle messaging — onboarded through managed pilots.",
              "For planners →"
            ],
            "label": "Programs"
          }
        ],
        "links": [
          {
            "label": "For planners →",
            "sourceHref": "planners.html"
          }
        ],
        "interactionHints": [
          "data-reveal",
          "data-tiers"
        ],
        "originalCopy": [
          "The model",
          "Every feature is",
          "honest",
          "about what it needs.",
          "Catch Host doesn't ask you to switch platforms on day one. Each circle is cumulative — everything inside keeps working.",
          "Click a ring or a card →",
          "Catch network",
          "Catch booking",
          "Works alongside",
          "Start here — works alongside",
          "tap to expand",
          "Your tools stay. The room gets smarter.",
          "Import a guest list from anywhere. Guests join the live event in a mobile browser — no app, no profile. You get check-in, icebreakers, messaging, and a CRM from day one.",
          "Guest-list import — CSV/XLSX, forwarding, Luma sync (beta)",
          "QR + manual check-in, walk-in approvals, rehearsal mode",
          "First Hello, prompts, quiet introductions, rotations & pairings",
          "Forms with payments, automations, and applications",
          "Tracked invite / promoter / referral links",
          "Scheduled reminders, announcements, WhatsApp campaigns*",
          "CRM with segments, saved audiences, merge review",
          "External payment links + evidence reconciliation",
          "*WhatsApp campaigns use your own Meta Business account.",
          "Go deeper — Catch booking",
          "tap to expand",
          "Catch sells the tickets. The numbers become real.",
          "Checkout, refunds, and waitlists — plus the rules only a ticketing layer can enforce at signup, not at the door.",
          "Event pages, free RSVPs, paid checkout (Razorpay/Stripe)",
          "Payout accounts, refunds, post-event settlement",
          "Gender- and cohort-balanced admission caps & waitlists",
          "Cohort + demand pricing rules",
          "Age- and gender-restricted events vs. verified profiles",
          "True revenue + funnel attribution",
          "Full platform — Catch network",
          "tap to expand",
          "Catch helps fill the room — and keep it.",
          "When your guests are Catch members, the event keeps working after it ends — and your audience compounds.",
          "Verified member profiles and event-context chat",
          "Private post-event matching — no cold DMs, no public rejection",
          "CrossPaths pair suggestions with reserved seats",
          "Discovery surface — your next event fills from the network",
          "Programs",
          "Weddings, conferences, multi-day productions: per-function schedules, household RSVPs, travel & accommodation logistics, lifecycle messaging — onboarded through managed pilots.",
          "For planners →"
        ]
      },
      {
        "id": "section-3",
        "sourceId": null,
        "heading": "Grouped by the job it does.",
        "body": [
          "Illustrative concept: The toolkit",
          "Illustrative concept: Forms with payments and automations. Named links per channel, promoter, and partner. Guest-list import by CSV/XLSX, secure forwarding, or Luma sync (beta). Applications with review built in.",
          "Illustrative concept: QR and manual check-in, walk-in approvals, icebreakers, compatibility prompts, quiet introduction requests, guided pairings for pickleball, quizzes, dinners, and pace groups — plus a rehearsal mode for your team.",
          "Illustrative concept: Attach your own payment links and reconcile with evidence — or sell on Catch for checkout, payouts, refunds, cohort and demand pricing.",
          "Illustrative concept: A member directory built from every event — segments, saved audiences, merge review, exports. Attribution down to the promoter link; a recap that ends in next steps.",
          "Illustrative concept: Announcements and scheduled reminders. WhatsApp Business campaigns through your Meta account*. Scoped, expiring staff access for the door.",
          "Illustrative concept: Per-function schedules and venues, household RSVPs, flight-tracked arrivals, transport dispatch, hotel inbound, vendor resources, staff duties. For planners →",
          "Illustrative concept: The guest list, the door, the messages, the money, and the recap are one connected record — not six exports stitched together at midnight.",
          "Illustrative concept: *Provider-gated: WhatsApp campaigns require your own Meta Business assets and approved templates."
        ],
        "items": [
          {
            "body": "Illustrative concept: Works alongside Forms, tracked links, imports, applications Forms with payments and automations. Named links per channel, promoter, and partner. Guest-list import by CSV/XLSX, secure forwarding, or Luma sync (beta). Applications with review built in.",
            "originalCopy": [
              "Get them in",
              "Works alongside",
              "Forms, tracked links, imports, applications",
              "Forms with payments and automations. Named links per channel, promoter, and partner. Guest-list import by CSV/XLSX, secure forwarding, or Luma sync (beta). Applications with review built in."
            ],
            "title": "Forms, tracked links, imports, applications",
            "label": "Get them in"
          },
          {
            "body": "Illustrative concept: Works alongside Check-in · First Hello · introductions · rotations QR and manual check-in, walk-in approvals, icebreakers, compatibility prompts, quiet introduction requests, guided pairings for pickleball, quizzes, dinners, and pace groups — plus a rehearsal mode for your team.",
            "originalCopy": [
              "Run the room",
              "Works alongside",
              "Check-in · First Hello · introductions · rotations",
              "QR and manual check-in, walk-in approvals, icebreakers, compatibility prompts, quiet introduction requests, guided pairings for pickleball, quizzes, dinners, and pace groups — plus a rehearsal mode for your team."
            ],
            "title": "Check-in · First Hello · introductions · rotations",
            "label": "Run the room"
          },
          {
            "body": "Illustrative concept: Both tiers Payment links · paid forms · full checkout Attach your own payment links and reconcile with evidence — or sell on Catch for checkout, payouts, refunds, cohort and demand pricing.",
            "originalCopy": [
              "Get paid",
              "Both tiers",
              "Payment links · paid forms · full checkout",
              "Attach your own payment links and reconcile with evidence — or sell on Catch for checkout, payouts, refunds, cohort and demand pricing."
            ],
            "title": "Payment links · paid forms · full checkout",
            "label": "Get paid"
          },
          {
            "body": "Illustrative concept: Works alongside CRM · attribution · recap A member directory built from every event — segments, saved audiences, merge review, exports. Attribution down to the promoter link; a recap that ends in next steps.",
            "originalCopy": [
              "Learn & grow",
              "Works alongside",
              "CRM · attribution · recap",
              "A member directory built from every event — segments, saved audiences, merge review, exports. Attribution down to the promoter link; a recap that ends in next steps."
            ],
            "title": "CRM · attribution · recap",
            "label": "Learn & grow"
          },
          {
            "body": "Illustrative concept: Works alongside Scheduled messaging · WhatsApp · staff access Announcements and scheduled reminders. WhatsApp Business campaigns through your Meta account*. Scoped, expiring staff access for the door.",
            "originalCopy": [
              "Coordinate",
              "Works alongside",
              "Scheduled messaging · WhatsApp · staff access",
              "Announcements and scheduled reminders. WhatsApp Business campaigns through your Meta account*. Scoped, expiring staff access for the door."
            ],
            "title": "Scheduled messaging · WhatsApp · staff access",
            "label": "Coordinate"
          },
          {
            "body": "Illustrative concept: Managed pilot Programs, households, travel & logistics Per-function schedules and venues, household RSVPs, flight-tracked arrivals, transport dispatch, hotel inbound, vendor resources, staff duties. For planners →",
            "originalCopy": [
              "Multi-day",
              "Managed pilot",
              "Programs, households, travel & logistics",
              "Per-function schedules and venues, household RSVPs, flight-tracked arrivals, transport dispatch, hotel inbound, vendor resources, staff duties.",
              "For planners →"
            ],
            "title": "Programs, households, travel & logistics",
            "label": "Multi-day"
          },
          {
            "body": "Illustrative concept: The guest list, the door, the messages, the money, and the recap are one connected record — not six exports stitched together at midnight.",
            "originalCopy": [
              "One record",
              "Every tool reads the same event.",
              "The guest list, the door, the messages, the money, and the recap are one connected record — not six exports stitched together at midnight."
            ],
            "title": "Every tool reads the same event.",
            "label": "One record"
          }
        ],
        "links": [
          {
            "label": "For planners →",
            "sourceHref": "planners.html"
          }
        ],
        "interactionHints": [
          "data-reveal"
        ],
        "originalCopy": [
          "The toolkit",
          "Grouped by",
          "the job",
          "it does.",
          "Get them in",
          "Works alongside",
          "Forms, tracked links, imports, applications",
          "Forms with payments and automations. Named links per channel, promoter, and partner. Guest-list import by CSV/XLSX, secure forwarding, or Luma sync (beta). Applications with review built in.",
          "Run the room",
          "Works alongside",
          "Check-in · First Hello · introductions · rotations",
          "QR and manual check-in, walk-in approvals, icebreakers, compatibility prompts, quiet introduction requests, guided pairings for pickleball, quizzes, dinners, and pace groups — plus a rehearsal mode for your team.",
          "Get paid",
          "Both tiers",
          "Payment links · paid forms · full checkout",
          "Attach your own payment links and reconcile with evidence — or sell on Catch for checkout, payouts, refunds, cohort and demand pricing.",
          "Learn & grow",
          "Works alongside",
          "CRM · attribution · recap",
          "A member directory built from every event — segments, saved audiences, merge review, exports. Attribution down to the promoter link; a recap that ends in next steps.",
          "Coordinate",
          "Works alongside",
          "Scheduled messaging · WhatsApp · staff access",
          "Announcements and scheduled reminders. WhatsApp Business campaigns through your Meta account*. Scoped, expiring staff access for the door.",
          "Multi-day",
          "Managed pilot",
          "Programs, households, travel & logistics",
          "Per-function schedules and venues, household RSVPs, flight-tracked arrivals, transport dispatch, hotel inbound, vendor resources, staff duties.",
          "For planners →",
          "One record",
          "Every tool reads the same event.",
          "The guest list, the door, the messages, the money, and the recap are one connected record — not six exports stitched together at midnight.",
          "*Provider-gated: WhatsApp campaigns require your own Meta Business assets and approved templates."
        ]
      },
      {
        "id": "section-4",
        "sourceId": null,
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
          {
            "label": "Request a pilot",
            "sourceHref": "apply.html"
          },
          {
            "label": "Open the full audit →",
            "sourceHref": "stack.html"
          }
        ],
        "interactionHints": [
          "data-count",
          "data-groups",
          "data-reveal",
          "data-rows",
          "data-stack",
          "data-tier-name",
          "data-tier-why"
        ],
        "originalCopy": [
          "The pile audit",
          "Tell us your pile. We'll tell you",
          "the fit.",
          "Every organizer runs some version of the same duct-taped stack. Pick what you use today — see what Catch keeps, what it replaces, and which tier that lands you on.",
          "The pile audit needs JavaScript — the mappings are listed in the capability section above.",
          "Your stack → Catch",
          "0 selected",
          "Select the tools you run today — we'll map each one to what it becomes on Catch.",
          "Suggested fit",
          "Works alongside",
          "Keep your booking flow exactly as it is. Catch runs the room and the record off the roster — nothing to migrate.",
          "Request a pilot",
          "*SMS sender is on the roadmap — event announcements and WhatsApp campaigns are live. Roster imports are reviewed for Luma, Eventbrite, Partiful, and POSH; other platforms come in via CSV/XLSX or secure forwarding.",
          "Open the full audit →"
        ]
      },
      {
        "id": "section-5",
        "sourceId": null,
        "heading": "Your organizer page may already exist.",
        "body": [
          "Illustrative concept: Already on Catch?",
          "Illustrative concept: Search the directory — if your events have run in our launch cities, there's likely a public page with your name on it. Claim it and the tools attach to a page guests already find."
        ],
        "items": [],
        "links": [
          {
            "label": "Claim your listing",
            "sourceHref": "claim.html"
          },
          {
            "label": "Search the directory",
            "sourceHref": "directory.html"
          }
        ],
        "interactionHints": [
          "data-reveal"
        ],
        "originalCopy": [
          "Already on Catch?",
          "Your organizer page may already exist.",
          "Search the directory — if your events have run in our launch cities, there's likely a public page with your name on it. Claim it and the tools attach to a page guests already find.",
          "Claim your listing",
          "Search the directory"
        ]
      },
      {
        "id": "pilot",
        "sourceId": "pilot",
        "heading": "Pilot Catch on your next event.",
        "body": [
          "Illustrative concept: The pilot",
          "Illustrative concept: We onboard a small number of organizers at a time, on real events. Tell us about yours — we'll get on a call, map your workflow, and set up a free pilot around it.",
          "Illustrative concept: Five quick steps — the event, your setup, what you'd use.",
          "Illustrative concept: Which tools you keep, which Catch replaces, which tier fits.",
          "Illustrative concept: Hands-on onboarding through doors, live tools, and recap.",
          "Illustrative concept: What worked, what it earned, what the next tier would add."
        ],
        "items": [
          {
            "body": "Illustrative concept: 01 Tell us about your event Five quick steps — the event, your setup, what you'd use.",
            "originalCopy": [
              "01",
              "Tell us about your event",
              "Five quick steps — the event, your setup, what you'd use."
            ],
            "title": "Tell us about your event"
          },
          {
            "body": "Illustrative concept: 02 We map your workflow on a call Which tools you keep, which Catch replaces, which tier fits.",
            "originalCopy": [
              "02",
              "We map your workflow on a call",
              "Which tools you keep, which Catch replaces, which tier fits."
            ],
            "title": "We map your workflow on a call"
          },
          {
            "body": "Illustrative concept: 03 You run a real event on Catch Hands-on onboarding through doors, live tools, and recap.",
            "originalCopy": [
              "03",
              "You run a real event on Catch",
              "Hands-on onboarding through doors, live tools, and recap."
            ],
            "title": "You run a real event on Catch"
          },
          {
            "body": "Illustrative concept: 04 We review it together What worked, what it earned, what the next tier would add.",
            "originalCopy": [
              "04",
              "We review it together",
              "What worked, what it earned, what the next tier would add."
            ],
            "title": "We review it together"
          }
        ],
        "links": [
          {
            "label": "Request a free pilot",
            "sourceHref": "apply.html"
          }
        ],
        "interactionHints": [
          "data-reveal"
        ],
        "originalCopy": [
          "The pilot",
          "Pilot Catch on your",
          "next event.",
          "We onboard a small number of organizers at a time, on real events. Tell us about yours — we'll get on a call, map your workflow, and set up a free pilot around it.",
          "Request a free pilot",
          "01",
          "Tell us about your event",
          "Five quick steps — the event, your setup, what you'd use.",
          "02",
          "We map your workflow on a call",
          "Which tools you keep, which Catch replaces, which tier fits.",
          "03",
          "You run a real event on Catch",
          "Hands-on onboarding through doors, live tools, and recap.",
          "04",
          "We review it together",
          "What worked, what it earned, what the next tier would add."
        ]
      },
      {
        "id": "section-7",
        "sourceId": null,
        "heading": "Fair questions.",
        "body": [
          "Illustrative concept: No. The first circle works entirely off an exported guest list. Catch-powered booking is there when the attribution and admission rules are worth the switch.",
          "Illustrative concept: No. Guests verify a phone number and join the live event in a mobile browser. The Catch app only enters the picture at the network tier — and it's their choice.",
          "Illustrative concept: Claimed pages unlock responses, event publishing, and analytics on a public page that's already discoverable. Claiming takes a few minutes and is reviewed by a human.",
          "Illustrative concept: A real upcoming event, a guest list, and one call to map your workflow. Onboarding is hands-on and free during the pilot.",
          "Illustrative concept: Pricing scales with which circles you use and the size of your operation. We quote it on the call — advanced and managed-program capabilities price differently from standalone tooling.",
          "Illustrative concept: Everything in the first circle. Catch booking, payments, and restrictions are live on the booking tier. Multi-day programs run through managed pilots; SMS and email senders are on the roadmap."
        ],
        "items": [
          {
            "body": "Illustrative concept: No. The first circle works entirely off an exported guest list. Catch-powered booking is there when the attribution and admission rules are worth the switch.",
            "originalCopy": [
              "Do I have to leave my booking platform?",
              "No. The first circle works entirely off an exported guest list. Catch-powered booking is there when the attribution and admission rules are worth the switch."
            ],
            "title": "Do I have to leave my booking platform?"
          },
          {
            "body": "Illustrative concept: No. Guests verify a phone number and join the live event in a mobile browser. The Catch app only enters the picture at the network tier — and it's their choice.",
            "originalCopy": [
              "Do my guests need to download an app?",
              "No. Guests verify a phone number and join the live event in a mobile browser. The Catch app only enters the picture at the network tier — and it's their choice."
            ],
            "title": "Do my guests need to download an app?"
          },
          {
            "body": "Illustrative concept: Claimed pages unlock responses, event publishing, and analytics on a public page that's already discoverable. Claiming takes a few minutes and is reviewed by a human.",
            "originalCopy": [
              "I'm already listed on Catch — what does claiming it do?",
              "Claimed pages unlock responses, event publishing, and analytics on a public page that's already discoverable. Claiming takes a few minutes and is reviewed by a human."
            ],
            "title": "I'm already listed on Catch — what does claiming it do?"
          },
          {
            "body": "Illustrative concept: A real upcoming event, a guest list, and one call to map your workflow. Onboarding is hands-on and free during the pilot.",
            "originalCopy": [
              "What does a pilot involve?",
              "A real upcoming event, a guest list, and one call to map your workflow. Onboarding is hands-on and free during the pilot."
            ],
            "title": "What does a pilot involve?"
          },
          {
            "body": "Illustrative concept: Pricing scales with which circles you use and the size of your operation. We quote it on the call — advanced and managed-program capabilities price differently from standalone tooling.",
            "originalCopy": [
              "How does pricing work?",
              "Pricing scales with which circles you use and the size of your operation. We quote it on the call — advanced and managed-program capabilities price differently from standalone tooling."
            ],
            "title": "How does pricing work?"
          },
          {
            "body": "Illustrative concept: Everything in the first circle. Catch booking, payments, and restrictions are live on the booking tier. Multi-day programs run through managed pilots; SMS and email senders are on the roadmap.",
            "originalCopy": [
              "What's actually live today?",
              "Everything in the first circle. Catch booking, payments, and restrictions are live on the booking tier. Multi-day programs run through managed pilots; SMS and email senders are on the roadmap."
            ],
            "title": "What's actually live today?"
          }
        ],
        "links": [],
        "interactionHints": [
          "data-reveal"
        ],
        "originalCopy": [
          "Fair questions.",
          "Do I have to leave my booking platform?",
          "No. The first circle works entirely off an exported guest list. Catch-powered booking is there when the attribution and admission rules are worth the switch.",
          "Do my guests need to download an app?",
          "No. Guests verify a phone number and join the live event in a mobile browser. The Catch app only enters the picture at the network tier — and it's their choice.",
          "I'm already listed on Catch — what does claiming it do?",
          "Claimed pages unlock responses, event publishing, and analytics on a public page that's already discoverable. Claiming takes a few minutes and is reviewed by a human.",
          "What does a pilot involve?",
          "A real upcoming event, a guest list, and one call to map your workflow. Onboarding is hands-on and free during the pilot.",
          "How does pricing work?",
          "Pricing scales with which circles you use and the size of your operation. We quote it on the call — advanced and managed-program capabilities price differently from standalone tooling.",
          "What's actually live today?",
          "Everything in the first circle. Catch booking, payments, and restrictions are live on the booking tier. Multi-day programs run through managed pilots; SMS and email senders are on the roadmap."
        ]
      }
    ],
    "headerDestinations": [
      {
        "label": "Catch.",
        "sourceHref": "index.html"
      },
      {
        "label": "For hosts",
        "sourceHref": "host.html"
      },
      {
        "label": "Stack audit",
        "sourceHref": "stack.html"
      },
      {
        "label": "Organizer directory",
        "sourceHref": "directory.html"
      },
      {
        "label": "Planners",
        "sourceHref": "planners.html"
      },
      {
        "label": "Singles & social",
        "sourceHref": "mixers.html"
      },
      {
        "label": "Clubs",
        "sourceHref": "clubs.html"
      },
      {
        "label": "Request a pilot",
        "sourceHref": "apply.html"
      }
    ],
    "footerCopy": [
      "Catch Host — the operating system for real-world events.",
      "Directory · Claim your page · Privacy · Terms · Help"
    ],
    "footerDestinations": [],
    "sourceSha256": "9698929bd98054317c1578fa398dac552bd606578c935765746a78242a2d67f4",
    "sourceForms": []
  },
  {
    "sourceFile": "planners.html",
    "slug": "planners",
    "title": "Catch for planners — multi-day events without the spreadsheet sprawl",
    "description": "Illustrative concept: Household RSVPs, travel and accommodation logistics, per-function check-in, staffing, and lifecycle messaging for weddings, conferences, and multi-day productions.",
    "originalDescription": "Household RSVPs, travel and accommodation logistics, per-function check-in, staffing, and lifecycle messaging for weddings, conferences, and multi-day productions.",
    "conceptNotice": "Content migrated from the static concept. Availability, integrations, pricing, example events, listing samples and predicted outcomes require verification; this page does not grant access or promise production support.",
    "sections": [
      {
        "id": "section-1",
        "sourceId": null,
        "heading": "The run of show is not a spreadsheet of spreadsheets.",
        "body": [
          "Illustrative concept: Catch for planners",
          "Illustrative concept: Multi-day productions have one operational record in Catch: guests and households, every function's schedule and venue, arrivals and transport, staffing, and the messages that tie it together — from save-the-date to departure."
        ],
        "items": [
          {
            "body": "Illustrative concept: Multi-day programs are onboarded through managed pilots — we set up with you, not just for you.",
            "originalCopy": [
              "Managed pilot",
              "Multi-day programs are onboarded through managed pilots — we set up with you, not just for you."
            ],
            "label": "Managed pilot"
          }
        ],
        "links": [
          {
            "label": "Talk to us about your production",
            "sourceHref": "apply.html"
          },
          {
            "label": "See the logistics layer",
            "sourceHref": "#logistics"
          }
        ],
        "interactionHints": [
          "data-reveal"
        ],
        "originalCopy": [
          "Catch for planners",
          "The run of show is not a",
          "spreadsheet of spreadsheets.",
          "Multi-day productions have one operational record in Catch: guests and households, every function's schedule and venue, arrivals and transport, staffing, and the messages that tie it together — from save-the-date to departure.",
          "Talk to us about your production",
          "See the logistics layer",
          "Managed pilot",
          "Multi-day programs are onboarded through managed pilots — we set up with you, not just for you."
        ]
      },
      {
        "id": "section-2",
        "sourceId": null,
        "heading": "One record from save-the-date to departure.",
        "body": [
          "Illustrative concept: The engagement",
          "Illustrative concept: Guests and households, every function's schedule and venue, arrivals and transport, staffing — one operational record."
        ],
        "items": [
          {
            "body": "Illustrative concept: 01 Save-the-date and formal invitations",
            "originalCopy": [
              "01",
              "Save-the-date and formal invitations"
            ],
            "title": "Save-the-date and formal invitations"
          },
          {
            "body": "Illustrative concept: 02 Household RSVPs with per-function answers",
            "originalCopy": [
              "02",
              "Household RSVPs with per-function answers"
            ],
            "title": "Household RSVPs with per-function answers"
          },
          {
            "body": "Illustrative concept: 03 Travel plans, flights, and pickups",
            "originalCopy": [
              "03",
              "Travel plans, flights, and pickups"
            ],
            "title": "Travel plans, flights, and pickups"
          },
          {
            "body": "Illustrative concept: 04 Per-function check-in and staffing",
            "originalCopy": [
              "04",
              "Per-function check-in and staffing"
            ],
            "title": "Per-function check-in and staffing"
          },
          {
            "body": "Illustrative concept: 05 Day-of alerts and schedule changes",
            "originalCopy": [
              "05",
              "Day-of alerts and schedule changes"
            ],
            "title": "Day-of alerts and schedule changes"
          },
          {
            "body": "Illustrative concept: 06 Post-event follow-up and feedback",
            "originalCopy": [
              "06",
              "Post-event follow-up and feedback"
            ],
            "title": "Post-event follow-up and feedback"
          }
        ],
        "links": [],
        "interactionHints": [
          "data-reveal"
        ],
        "originalCopy": [
          "The engagement",
          "One record from",
          "save-the-date",
          "to departure.",
          "Guests and households, every function's schedule and venue, arrivals and transport, staffing — one operational record.",
          "01",
          "Save-the-date and formal invitations",
          "02",
          "Household RSVPs with per-function answers",
          "03",
          "Travel plans, flights, and pickups",
          "04",
          "Per-function check-in and staffing",
          "05",
          "Day-of alerts and schedule changes",
          "06",
          "Post-event follow-up and feedback"
        ]
      },
      {
        "id": "logistics",
        "sourceId": "logistics",
        "heading": "The logistics layer.",
        "body": [
          "Illustrative concept: Programs layer",
          "Illustrative concept: Guests respond per household and per function through private signed links; headcounts stay live..ics feeds keep every function on their calendar.",
          "Illustrative concept: Track inbound flights with automatic enrichment and alerts, build transport plans, assign pickup points, and dispatch trips — with a journal of who arrived when.",
          "Illustrative concept: Hotel inbound tracking and vendor resources live on the same record as the guest list.",
          "Illustrative concept: Duty-scoped assignments give your team exactly the access they need — the door sees the door, transport sees transport."
        ],
        "items": [
          {
            "body": "Illustrative concept: Managed pilot",
            "originalCopy": [
              "Managed pilot"
            ]
          },
          {
            "body": "Illustrative concept: Guests respond per household and per function through private signed links; headcounts stay live..ics feeds keep every function on their calendar.",
            "originalCopy": [
              "01 · Households",
              "Households & invitations",
              "Guests respond per household and per function through private signed links; headcounts stay live. .ics feeds keep every function on their calendar."
            ],
            "title": "Households & invitations",
            "label": "01 · Households"
          },
          {
            "body": "Illustrative concept: Track inbound flights with automatic enrichment and alerts, build transport plans, assign pickup points, and dispatch trips — with a journal of who arrived when.",
            "originalCopy": [
              "02 · Transport",
              "Arrivals & transport",
              "Track inbound flights with automatic enrichment and alerts, build transport plans, assign pickup points, and dispatch trips — with a journal of who arrived when."
            ],
            "title": "Arrivals & transport",
            "label": "02 · Transport"
          },
          {
            "body": "Illustrative concept: Hotel inbound tracking and vendor resources live on the same record as the guest list. Managed pilot",
            "originalCopy": [
              "03 · Vendors",
              "Accommodation & vendors",
              "Hotel inbound tracking and vendor resources live on the same record as the guest list.",
              "Managed pilot"
            ],
            "title": "Accommodation & vendors",
            "label": "03 · Vendors"
          },
          {
            "body": "Illustrative concept: Duty-scoped assignments give your team exactly the access they need — the door sees the door, transport sees transport.",
            "originalCopy": [
              "04 · Staffing",
              "Staffing",
              "Duty-scoped assignments give your team exactly the access they need — the door sees the door, transport sees transport."
            ],
            "title": "Staffing",
            "label": "04 · Staffing"
          }
        ],
        "links": [],
        "interactionHints": [
          "data-reveal"
        ],
        "originalCopy": [
          "Programs layer",
          "Managed pilot",
          "The",
          "logistics",
          "layer.",
          "01 · Households",
          "Households & invitations",
          "Guests respond per household and per function through private signed links; headcounts stay live. .ics feeds keep every function on their calendar.",
          "02 · Transport",
          "Arrivals & transport",
          "Track inbound flights with automatic enrichment and alerts, build transport plans, assign pickup points, and dispatch trips — with a journal of who arrived when.",
          "03 · Vendors",
          "Accommodation & vendors",
          "Hotel inbound tracking and vendor resources live on the same record as the guest list.",
          "Managed pilot",
          "04 · Staffing",
          "Staffing",
          "Duty-scoped assignments give your team exactly the access they need — the door sees the door, transport sees transport."
        ]
      },
      {
        "id": "section-4",
        "sourceId": null,
        "heading": "Every message has a place in the timeline.",
        "body": [
          "Illustrative concept: Messaging",
          "Illustrative concept: Announcements, scheduled reminders, deadline chasers, and day-of alerts. WhatsApp Business campaigns run through your own Meta account*; email and SMS senders are on the roadmap.",
          "Illustrative concept: *Provider-gated: requires your Meta Business assets and approved templates."
        ],
        "items": [],
        "links": [],
        "interactionHints": [
          "data-reveal"
        ],
        "originalCopy": [
          "Messaging",
          "Every message has a place in",
          "the timeline.",
          "Announcements, scheduled reminders, deadline chasers, and day-of alerts. WhatsApp Business campaigns run through your own Meta account*; email and SMS senders are on the roadmap.",
          "*Provider-gated: requires your Meta Business assets and approved templates."
        ]
      },
      {
        "id": "section-5",
        "sourceId": null,
        "heading": "We run the first one with you.",
        "body": [
          "Illustrative concept: Managed pilot",
          "Illustrative concept: Programs are configured around your production — functions, households, travel flows, staffing. A managed pilot means our team maps your workflow and builds it with you before your guests ever see it.",
          "Illustrative concept: Five quick steps — the event, your setup, what you'd use.",
          "Illustrative concept: Functions, households, travel flows, staffing — configured around your production.",
          "Illustrative concept: Hands-on onboarding through doors, live tools, and recap.",
          "Illustrative concept: What worked, what it earned, what the next tier would add."
        ],
        "items": [
          {
            "body": "Illustrative concept: 01 Tell us about your event Five quick steps — the event, your setup, what you'd use.",
            "originalCopy": [
              "01",
              "Tell us about your event",
              "Five quick steps — the event, your setup, what you'd use."
            ],
            "title": "Tell us about your event"
          },
          {
            "body": "Illustrative concept: 02 We map your workflow on a call Functions, households, travel flows, staffing — configured around your production.",
            "originalCopy": [
              "02",
              "We map your workflow on a call",
              "Functions, households, travel flows, staffing — configured around your production."
            ],
            "title": "We map your workflow on a call"
          },
          {
            "body": "Illustrative concept: 03 You run a real event on Catch Hands-on onboarding through doors, live tools, and recap.",
            "originalCopy": [
              "03",
              "You run a real event on Catch",
              "Hands-on onboarding through doors, live tools, and recap."
            ],
            "title": "You run a real event on Catch"
          },
          {
            "body": "Illustrative concept: 04 We review it together What worked, what it earned, what the next tier would add.",
            "originalCopy": [
              "04",
              "We review it together",
              "What worked, what it earned, what the next tier would add."
            ],
            "title": "We review it together"
          }
        ],
        "links": [
          {
            "label": "Request a managed pilot",
            "sourceHref": "apply.html"
          }
        ],
        "interactionHints": [
          "data-reveal"
        ],
        "originalCopy": [
          "Managed pilot",
          "We run the first one",
          "with you.",
          "Programs are configured around your production — functions, households, travel flows, staffing. A managed pilot means our team maps your workflow and builds it with you before your guests ever see it.",
          "Request a managed pilot",
          "01",
          "Tell us about your event",
          "Five quick steps — the event, your setup, what you'd use.",
          "02",
          "We map your workflow on a call",
          "Functions, households, travel flows, staffing — configured around your production.",
          "03",
          "You run a real event on Catch",
          "Hands-on onboarding through doors, live tools, and recap.",
          "04",
          "We review it together",
          "What worked, what it earned, what the next tier would add."
        ]
      },
      {
        "id": "section-6",
        "sourceId": null,
        "heading": "Fair questions.",
        "body": [
          "Illustrative concept: Yes. Programs can scope invitations, RSVP, and check-in per function.",
          "Illustrative concept: Not fully — and deliberately. Productions get managed onboarding so the setup matches how you actually work.",
          "Illustrative concept: No. The first circle works entirely off an exported guest list. Catch-powered booking is there when the attribution and admission rules are worth the switch.",
          "Illustrative concept: No. Guests verify a phone number and join the live event in a mobile browser. The Catch app only enters the picture at the network tier — and it's their choice.",
          "Illustrative concept: A real upcoming event, a guest list, and one call to map your workflow. Onboarding is hands-on and free during the pilot.",
          "Illustrative concept: Pricing scales with which circles you use and the size of your operation. We quote it on the call — advanced and managed-program capabilities price differently from standalone tooling.",
          "Illustrative concept: Everything in the first circle. Catch booking, payments, and restrictions are live on the booking tier. Multi-day programs run through managed pilots; SMS and email senders are on the roadmap."
        ],
        "items": [
          {
            "body": "Illustrative concept: Yes. Programs can scope invitations, RSVP, and check-in per function.",
            "originalCopy": [
              "Can we run just one function, like the reception?",
              "Yes. Programs can scope invitations, RSVP, and check-in per function."
            ],
            "title": "Can we run just one function, like the reception?"
          },
          {
            "body": "Illustrative concept: Not fully — and deliberately. Productions get managed onboarding so the setup matches how you actually work.",
            "originalCopy": [
              "Is this self-serve yet?",
              "Not fully — and deliberately. Productions get managed onboarding so the setup matches how you actually work."
            ],
            "title": "Is this self-serve yet?"
          },
          {
            "body": "Illustrative concept: No. The first circle works entirely off an exported guest list. Catch-powered booking is there when the attribution and admission rules are worth the switch.",
            "originalCopy": [
              "Do I have to leave my booking platform?",
              "No. The first circle works entirely off an exported guest list. Catch-powered booking is there when the attribution and admission rules are worth the switch."
            ],
            "title": "Do I have to leave my booking platform?"
          },
          {
            "body": "Illustrative concept: No. Guests verify a phone number and join the live event in a mobile browser. The Catch app only enters the picture at the network tier — and it's their choice.",
            "originalCopy": [
              "Do my guests need to download an app?",
              "No. Guests verify a phone number and join the live event in a mobile browser. The Catch app only enters the picture at the network tier — and it's their choice."
            ],
            "title": "Do my guests need to download an app?"
          },
          {
            "body": "Illustrative concept: A real upcoming event, a guest list, and one call to map your workflow. Onboarding is hands-on and free during the pilot.",
            "originalCopy": [
              "What does a pilot involve?",
              "A real upcoming event, a guest list, and one call to map your workflow. Onboarding is hands-on and free during the pilot."
            ],
            "title": "What does a pilot involve?"
          },
          {
            "body": "Illustrative concept: Pricing scales with which circles you use and the size of your operation. We quote it on the call — advanced and managed-program capabilities price differently from standalone tooling.",
            "originalCopy": [
              "How does pricing work?",
              "Pricing scales with which circles you use and the size of your operation. We quote it on the call — advanced and managed-program capabilities price differently from standalone tooling."
            ],
            "title": "How does pricing work?"
          },
          {
            "body": "Illustrative concept: Everything in the first circle. Catch booking, payments, and restrictions are live on the booking tier. Multi-day programs run through managed pilots; SMS and email senders are on the roadmap.",
            "originalCopy": [
              "What's actually live today?",
              "Everything in the first circle. Catch booking, payments, and restrictions are live on the booking tier. Multi-day programs run through managed pilots; SMS and email senders are on the roadmap."
            ],
            "title": "What's actually live today?"
          }
        ],
        "links": [],
        "interactionHints": [
          "data-reveal"
        ],
        "originalCopy": [
          "Fair questions.",
          "Can we run just one function, like the reception?",
          "Yes. Programs can scope invitations, RSVP, and check-in per function.",
          "Is this self-serve yet?",
          "Not fully — and deliberately. Productions get managed onboarding so the setup matches how you actually work.",
          "Do I have to leave my booking platform?",
          "No. The first circle works entirely off an exported guest list. Catch-powered booking is there when the attribution and admission rules are worth the switch.",
          "Do my guests need to download an app?",
          "No. Guests verify a phone number and join the live event in a mobile browser. The Catch app only enters the picture at the network tier — and it's their choice.",
          "What does a pilot involve?",
          "A real upcoming event, a guest list, and one call to map your workflow. Onboarding is hands-on and free during the pilot.",
          "How does pricing work?",
          "Pricing scales with which circles you use and the size of your operation. We quote it on the call — advanced and managed-program capabilities price differently from standalone tooling.",
          "What's actually live today?",
          "Everything in the first circle. Catch booking, payments, and restrictions are live on the booking tier. Multi-day programs run through managed pilots; SMS and email senders are on the roadmap."
        ]
      }
    ],
    "headerDestinations": [
      {
        "label": "Catch.",
        "sourceHref": "index.html"
      },
      {
        "label": "For hosts",
        "sourceHref": "host.html"
      },
      {
        "label": "Stack audit",
        "sourceHref": "stack.html"
      },
      {
        "label": "Organizer directory",
        "sourceHref": "directory.html"
      },
      {
        "label": "Planners",
        "sourceHref": "planners.html"
      },
      {
        "label": "Singles & social",
        "sourceHref": "mixers.html"
      },
      {
        "label": "Clubs",
        "sourceHref": "clubs.html"
      },
      {
        "label": "Request a pilot",
        "sourceHref": "apply.html"
      }
    ],
    "footerCopy": [
      "Catch Host — the operating system for real-world events.",
      "Directory · Claim your page · Privacy · Terms · Help"
    ],
    "footerDestinations": [],
    "sourceSha256": "603da18615d5e5917506022d11e0e1a9939a64f3e684edac49d60532cf4d62c1",
    "sourceForms": []
  },
  {
    "sourceFile": "mixers.html",
    "slug": "mixers",
    "title": "Catch for singles & social organizers — fill the room, balance the room, grow the revenue",
    "description": "Illustrative concept: Tracked promotion, gender-balanced admission, demand pricing, live icebreakers, and post-event matching for mixers and dating-format events.",
    "originalDescription": "Tracked promotion, gender-balanced admission, demand pricing, live icebreakers, and post-event matching for mixers and dating-format events.",
    "conceptNotice": "Content migrated from the static concept. Availability, integrations, pricing, example events, listing samples and predicted outcomes require verification; this page does not grant access or promise production support.",
    "sections": [
      {
        "id": "section-1",
        "sourceId": null,
        "heading": "Fill the room. Balance the room. Get paid for both.",
        "body": [
          "Illustrative concept: Catch for singles & social",
          "Illustrative concept: You already know the three problems: getting enough people, getting the right mix, and knowing which promotion rupee did what. Catch Host is built around all three."
        ],
        "items": [],
        "links": [
          {
            "label": "Request a free pilot",
            "sourceHref": "apply.html"
          },
          {
            "label": "See how demand works",
            "sourceHref": "#demand"
          }
        ],
        "interactionHints": [
          "data-reveal"
        ],
        "originalCopy": [
          "Catch for singles & social",
          "Fill the room. Balance the room.",
          "Get paid for both.",
          "You already know the three problems: getting enough people, getting the right mix, and knowing which promotion rupee did what. Catch Host is built around all three.",
          "Request a free pilot",
          "See how demand works"
        ]
      },
      {
        "id": "demand",
        "sourceId": "demand",
        "heading": "Know which promotion actually worked.",
        "body": [
          "Illustrative concept: Demand",
          "Illustrative concept: Named links for every channel, promoter, and partner. Personal referral links your attendees share themselves. Opens, registrations, and actual attendance — attributed, so next month's spend goes where it earned.",
          "Illustrative concept: One link per channel, promoter, and partner — see what each actually delivered.",
          "Illustrative concept: Your attendees share them themselves — the guest list becomes a promotion channel.",
          "Illustrative concept: Next month's spend goes where it earned."
        ],
        "items": [
          {
            "body": "Illustrative concept: Catch reports what it can verify — opens, registrations, attendance. It never claims to see inside WhatsApp forwards.",
            "originalCopy": [
              "Honest attribution",
              "Catch reports what it can verify — opens, registrations, attendance. It never claims to see inside WhatsApp forwards."
            ],
            "label": "Honest attribution"
          },
          {
            "body": "Illustrative concept: Channels Named links One link per channel, promoter, and partner — see what each actually delivered.",
            "originalCopy": [
              "Channels",
              "Named links",
              "One link per channel, promoter, and partner — see what each actually delivered."
            ],
            "title": "Named links"
          },
          {
            "body": "Illustrative concept: Referrals Personal referral links Your attendees share them themselves — the guest list becomes a promotion channel.",
            "originalCopy": [
              "Referrals",
              "Personal referral links",
              "Your attendees share them themselves — the guest list becomes a promotion channel."
            ],
            "title": "Personal referral links"
          },
          {
            "body": "Illustrative concept: Attribution Opens → registrations → attendance Next month's spend goes where it earned.",
            "originalCopy": [
              "Attribution",
              "Opens → registrations → attendance",
              "Next month's spend goes where it earned."
            ],
            "title": "Opens → registrations → attendance"
          }
        ],
        "links": [],
        "interactionHints": [
          "data-reveal"
        ],
        "originalCopy": [
          "Demand",
          "Know which promotion",
          "actually worked.",
          "Named links for every channel, promoter, and partner. Personal referral links your attendees share themselves. Opens, registrations, and actual attendance — attributed, so next month's spend goes where it earned.",
          "Honest attribution",
          "Catch reports what it can verify — opens, registrations, attendance. It never claims to see inside WhatsApp forwards.",
          "Channels",
          "Named links",
          "One link per channel, promoter, and partner — see what each actually delivered.",
          "Referrals",
          "Personal referral links",
          "Your attendees share them themselves — the guest list becomes a promotion channel.",
          "Attribution",
          "Opens → registrations → attendance",
          "Next month's spend goes where it earned."
        ]
      },
      {
        "id": "section-3",
        "sourceId": null,
        "heading": "A balanced room is a pricing feature, not a compromise.",
        "body": [
          "Illustrative concept: Admission control",
          "Illustrative concept: Cohort caps and ratios keep the mix right while the waitlist keeps filling. Differentiated cohort pricing and demand rules let the scarce side subsidize the wait — enforced at checkout, not at the door.",
          "Illustrative concept: Age- and gender-restricted events are enforced against verified member profiles. On imported guest lists, restrictions stay advisory."
        ],
        "items": [
          {
            "body": "Illustrative concept: Catch booking",
            "originalCopy": [
              "Catch booking"
            ]
          },
          {
            "body": "Illustrative concept: Cohort caps & ratios",
            "originalCopy": [
              "Cohort caps & ratios"
            ]
          },
          {
            "body": "Illustrative concept: Waitlist keeps filling",
            "originalCopy": [
              "Waitlist keeps filling"
            ]
          },
          {
            "body": "Illustrative concept: Differentiated cohort pricing",
            "originalCopy": [
              "Differentiated cohort pricing"
            ]
          },
          {
            "body": "Illustrative concept: Demand rules",
            "originalCopy": [
              "Demand rules"
            ]
          },
          {
            "body": "Illustrative concept: Enforced at checkout, not the door",
            "originalCopy": [
              "Enforced at checkout, not the door"
            ]
          }
        ],
        "links": [],
        "interactionHints": [
          "data-reveal"
        ],
        "originalCopy": [
          "Admission control",
          "Catch booking",
          "A balanced room is a",
          "pricing feature,",
          "not a compromise.",
          "Cohort caps and ratios keep the mix right while the waitlist keeps filling. Differentiated cohort pricing and demand rules let the scarce side subsidize the wait — enforced at checkout, not at the door.",
          "Age- and gender-restricted events are enforced against verified member profiles. On imported guest lists, restrictions stay advisory.",
          "Cohort caps & ratios",
          "Waitlist keeps filling",
          "Differentiated cohort pricing",
          "Demand rules",
          "Enforced at checkout, not the door"
        ]
      },
      {
        "id": "section-4",
        "sourceId": null,
        "heading": "Revenue you can actually read.",
        "body": [
          "Illustrative concept: Revenue",
          "Illustrative concept: Catch checkout, refunds, and settlement give you the real funnel: who viewed, who paid, who dropped, who showed. Post-event recap ties revenue to attendance instead of a payment-app export.",
          "Illustrative concept: The real funnel"
        ],
        "items": [
          {
            "body": "Illustrative concept: Catch booking",
            "originalCopy": [
              "Catch booking"
            ]
          },
          {
            "body": "Illustrative concept: Who viewed",
            "originalCopy": [
              "Who viewed"
            ]
          },
          {
            "body": "Illustrative concept: Who paid",
            "originalCopy": [
              "Who paid"
            ]
          },
          {
            "body": "Illustrative concept: Who dropped",
            "originalCopy": [
              "Who dropped"
            ]
          },
          {
            "body": "Illustrative concept: Who showed",
            "originalCopy": [
              "Who showed"
            ]
          }
        ],
        "links": [],
        "interactionHints": [
          "data-reveal"
        ],
        "originalCopy": [
          "Revenue",
          "Catch booking",
          "Revenue you can",
          "actually read.",
          "Catch checkout, refunds, and settlement give you the real funnel: who viewed, who paid, who dropped, who showed. Post-event recap ties revenue to attendance instead of a payment-app export.",
          "The real funnel",
          "Who viewed",
          "Who paid",
          "Who dropped",
          "Who showed"
        ]
      },
      {
        "id": "section-5",
        "sourceId": null,
        "heading": "The first ten minutes decide the event.",
        "body": [
          "Illustrative concept: Live room",
          "Illustrative concept: Gives every arrival a person and an opener.",
          "Illustrative concept: Guests ask you for a warm intro — without public rejection.",
          "Illustrative concept: Keep the room moving — all in the browser, no download."
        ],
        "items": [
          {
            "body": "Illustrative concept: Gives every arrival a person and an opener.",
            "originalCopy": [
              "Icebreakers",
              "First Hello",
              "Gives every arrival a person and an opener."
            ],
            "title": "First Hello",
            "label": "Icebreakers"
          },
          {
            "body": "Illustrative concept: Guests ask you for a warm intro — without public rejection.",
            "originalCopy": [
              "Introductions",
              "Quiet requests",
              "Guests ask you for a warm intro — without public rejection."
            ],
            "title": "Quiet requests",
            "label": "Introductions"
          },
          {
            "body": "Illustrative concept: Keep the room moving — all in the browser, no download.",
            "originalCopy": [
              "Rotations",
              "Rotations & the mixer reveal",
              "Keep the room moving — all in the browser, no download."
            ],
            "title": "Rotations & the mixer reveal",
            "label": "Rotations"
          }
        ],
        "links": [],
        "interactionHints": [
          "data-reveal"
        ],
        "originalCopy": [
          "Live room",
          "The first",
          "ten minutes",
          "decide the event.",
          "Icebreakers",
          "First Hello",
          "Gives every arrival a person and an opener.",
          "Introductions",
          "Quiet requests",
          "Guests ask you for a warm intro — without public rejection.",
          "Rotations",
          "Rotations & the mixer reveal",
          "Keep the room moving — all in the browser, no download."
        ]
      },
      {
        "id": "section-6",
        "sourceId": null,
        "heading": "Events that build your audience, not just fill it.",
        "body": [
          "Illustrative concept: The upside",
          "Illustrative concept: On the Catch network, guests arrive with verified profiles, match privately after the event with shared context, and become members you can reach for the next one. CrossPaths pairs members with compatible people already going — the kind of draw a flyer can't copy.",
          "Illustrative concept: Match privately after the event with shared context.",
          "Illustrative concept: Members paired with compatible people already going — the kind of draw a flyer can't copy.",
          "Illustrative concept: The audience builds event over event instead of starting from zero."
        ],
        "items": [
          {
            "body": "Illustrative concept: Catch network",
            "originalCopy": [
              "Catch network"
            ]
          },
          {
            "body": "Illustrative concept: Verified Guests arrive with real profiles Match privately after the event with shared context.",
            "originalCopy": [
              "Verified",
              "Guests arrive with real profiles",
              "Match privately after the event with shared context."
            ],
            "title": "Guests arrive with real profiles"
          },
          {
            "body": "Illustrative concept: CrossPaths Pair suggestions before the event Members paired with compatible people already going — the kind of draw a flyer can't copy.",
            "originalCopy": [
              "CrossPaths",
              "Pair suggestions before the event",
              "Members paired with compatible people already going — the kind of draw a flyer can't copy."
            ],
            "title": "Pair suggestions before the event"
          },
          {
            "body": "Illustrative concept: Reach Members you can reach for the next one The audience builds event over event instead of starting from zero.",
            "originalCopy": [
              "Reach",
              "Members you can reach for the next one",
              "The audience builds event over event instead of starting from zero."
            ],
            "title": "Members you can reach for the next one"
          }
        ],
        "links": [],
        "interactionHints": [
          "data-reveal"
        ],
        "originalCopy": [
          "The upside",
          "Catch network",
          "Events that build your audience,",
          "not just fill it.",
          "On the Catch network, guests arrive with verified profiles, match privately after the event with shared context, and become members you can reach for the next one. CrossPaths pairs members with compatible people already going — the kind of draw a flyer can't copy.",
          "Verified",
          "Guests arrive with real profiles",
          "Match privately after the event with shared context.",
          "CrossPaths",
          "Pair suggestions before the event",
          "Members paired with compatible people already going — the kind of draw a flyer can't copy.",
          "Reach",
          "Members you can reach for the next one",
          "The audience builds event over event instead of starting from zero."
        ]
      },
      {
        "id": "pilot",
        "sourceId": "pilot",
        "heading": "Pilot Catch on your next event.",
        "body": [
          "Illustrative concept: The pilot",
          "Illustrative concept: We onboard a small number of organizers at a time, on real events. Tell us about yours — we'll get on a call, map your workflow, and set up a free pilot around it.",
          "Illustrative concept: Five quick steps — the event, your setup, what you'd use.",
          "Illustrative concept: Which tools you keep, which Catch replaces, which tier fits.",
          "Illustrative concept: Hands-on onboarding through doors, live tools, and recap.",
          "Illustrative concept: What worked, what it earned, what the next tier would add."
        ],
        "items": [
          {
            "body": "Illustrative concept: 01 Tell us about your event Five quick steps — the event, your setup, what you'd use.",
            "originalCopy": [
              "01",
              "Tell us about your event",
              "Five quick steps — the event, your setup, what you'd use."
            ],
            "title": "Tell us about your event"
          },
          {
            "body": "Illustrative concept: 02 We map your workflow on a call Which tools you keep, which Catch replaces, which tier fits.",
            "originalCopy": [
              "02",
              "We map your workflow on a call",
              "Which tools you keep, which Catch replaces, which tier fits."
            ],
            "title": "We map your workflow on a call"
          },
          {
            "body": "Illustrative concept: 03 You run a real event on Catch Hands-on onboarding through doors, live tools, and recap.",
            "originalCopy": [
              "03",
              "You run a real event on Catch",
              "Hands-on onboarding through doors, live tools, and recap."
            ],
            "title": "You run a real event on Catch"
          },
          {
            "body": "Illustrative concept: 04 We review it together What worked, what it earned, what the next tier would add.",
            "originalCopy": [
              "04",
              "We review it together",
              "What worked, what it earned, what the next tier would add."
            ],
            "title": "We review it together"
          }
        ],
        "links": [
          {
            "label": "Request a free pilot",
            "sourceHref": "apply.html"
          }
        ],
        "interactionHints": [
          "data-reveal"
        ],
        "originalCopy": [
          "The pilot",
          "Pilot Catch on your",
          "next event.",
          "We onboard a small number of organizers at a time, on real events. Tell us about yours — we'll get on a call, map your workflow, and set up a free pilot around it.",
          "Request a free pilot",
          "01",
          "Tell us about your event",
          "Five quick steps — the event, your setup, what you'd use.",
          "02",
          "We map your workflow on a call",
          "Which tools you keep, which Catch replaces, which tier fits.",
          "03",
          "You run a real event on Catch",
          "Hands-on onboarding through doors, live tools, and recap.",
          "04",
          "We review it together",
          "What worked, what it earned, what the next tier would add."
        ]
      },
      {
        "id": "section-8",
        "sourceId": null,
        "heading": "Fair questions.",
        "body": [
          "Illustrative concept: Yes — start standalone, import the guest list, and use the live room and attribution. Switch booking to Catch when balance and revenue truth are worth it.",
          "Illustrative concept: Cohort caps, a waitlist that only releases balanced spots, and differential pricing are built for exactly this.",
          "Illustrative concept: Catch booking",
          "Illustrative concept: No. The first circle works entirely off an exported guest list. Catch-powered booking is there when the attribution and admission rules are worth the switch.",
          "Illustrative concept: No. Guests verify a phone number and join the live event in a mobile browser. The Catch app only enters the picture at the network tier — and it's their choice.",
          "Illustrative concept: A real upcoming event, a guest list, and one call to map your workflow. Onboarding is hands-on and free during the pilot.",
          "Illustrative concept: Pricing scales with which circles you use and the size of your operation. We quote it on the call — advanced and managed-program capabilities price differently from standalone tooling.",
          "Illustrative concept: Everything in the first circle. Catch booking, payments, and restrictions are live on the booking tier. Multi-day programs run through managed pilots; SMS and email senders are on the roadmap."
        ],
        "items": [
          {
            "body": "Illustrative concept: Yes — start standalone, import the guest list, and use the live room and attribution. Switch booking to Catch when balance and revenue truth are worth it.",
            "originalCopy": [
              "Can I keep selling on Luma/Eventbrite?",
              "Yes — start standalone, import the guest list, and use the live room and attribution. Switch booking to Catch when balance and revenue truth are worth it."
            ],
            "title": "Can I keep selling on Luma/Eventbrite?"
          },
          {
            "body": "Illustrative concept: Cohort caps, a waitlist that only releases balanced spots, and differential pricing are built for exactly this. Catch booking",
            "originalCopy": [
              "What if the gender ratio is off?",
              "Cohort caps, a waitlist that only releases balanced spots, and differential pricing are built for exactly this.",
              "Catch booking"
            ],
            "title": "What if the gender ratio is off?",
            "label": "Catch booking"
          },
          {
            "body": "Illustrative concept: No. The first circle works entirely off an exported guest list. Catch-powered booking is there when the attribution and admission rules are worth the switch.",
            "originalCopy": [
              "Do I have to leave my booking platform?",
              "No. The first circle works entirely off an exported guest list. Catch-powered booking is there when the attribution and admission rules are worth the switch."
            ],
            "title": "Do I have to leave my booking platform?"
          },
          {
            "body": "Illustrative concept: No. Guests verify a phone number and join the live event in a mobile browser. The Catch app only enters the picture at the network tier — and it's their choice.",
            "originalCopy": [
              "Do my guests need to download an app?",
              "No. Guests verify a phone number and join the live event in a mobile browser. The Catch app only enters the picture at the network tier — and it's their choice."
            ],
            "title": "Do my guests need to download an app?"
          },
          {
            "body": "Illustrative concept: A real upcoming event, a guest list, and one call to map your workflow. Onboarding is hands-on and free during the pilot.",
            "originalCopy": [
              "What does a pilot involve?",
              "A real upcoming event, a guest list, and one call to map your workflow. Onboarding is hands-on and free during the pilot."
            ],
            "title": "What does a pilot involve?"
          },
          {
            "body": "Illustrative concept: Pricing scales with which circles you use and the size of your operation. We quote it on the call — advanced and managed-program capabilities price differently from standalone tooling.",
            "originalCopy": [
              "How does pricing work?",
              "Pricing scales with which circles you use and the size of your operation. We quote it on the call — advanced and managed-program capabilities price differently from standalone tooling."
            ],
            "title": "How does pricing work?"
          },
          {
            "body": "Illustrative concept: Everything in the first circle. Catch booking, payments, and restrictions are live on the booking tier. Multi-day programs run through managed pilots; SMS and email senders are on the roadmap.",
            "originalCopy": [
              "What's actually live today?",
              "Everything in the first circle. Catch booking, payments, and restrictions are live on the booking tier. Multi-day programs run through managed pilots; SMS and email senders are on the roadmap."
            ],
            "title": "What's actually live today?"
          }
        ],
        "links": [],
        "interactionHints": [
          "data-reveal"
        ],
        "originalCopy": [
          "Fair questions.",
          "Can I keep selling on Luma/Eventbrite?",
          "Yes — start standalone, import the guest list, and use the live room and attribution. Switch booking to Catch when balance and revenue truth are worth it.",
          "What if the gender ratio is off?",
          "Cohort caps, a waitlist that only releases balanced spots, and differential pricing are built for exactly this.",
          "Catch booking",
          "Do I have to leave my booking platform?",
          "No. The first circle works entirely off an exported guest list. Catch-powered booking is there when the attribution and admission rules are worth the switch.",
          "Do my guests need to download an app?",
          "No. Guests verify a phone number and join the live event in a mobile browser. The Catch app only enters the picture at the network tier — and it's their choice.",
          "What does a pilot involve?",
          "A real upcoming event, a guest list, and one call to map your workflow. Onboarding is hands-on and free during the pilot.",
          "How does pricing work?",
          "Pricing scales with which circles you use and the size of your operation. We quote it on the call — advanced and managed-program capabilities price differently from standalone tooling.",
          "What's actually live today?",
          "Everything in the first circle. Catch booking, payments, and restrictions are live on the booking tier. Multi-day programs run through managed pilots; SMS and email senders are on the roadmap."
        ]
      }
    ],
    "headerDestinations": [
      {
        "label": "Catch.",
        "sourceHref": "index.html"
      },
      {
        "label": "For hosts",
        "sourceHref": "host.html"
      },
      {
        "label": "Stack audit",
        "sourceHref": "stack.html"
      },
      {
        "label": "Organizer directory",
        "sourceHref": "directory.html"
      },
      {
        "label": "Planners",
        "sourceHref": "planners.html"
      },
      {
        "label": "Singles & social",
        "sourceHref": "mixers.html"
      },
      {
        "label": "Clubs",
        "sourceHref": "clubs.html"
      },
      {
        "label": "Request a pilot",
        "sourceHref": "apply.html"
      }
    ],
    "footerCopy": [
      "Catch Host — the operating system for real-world events.",
      "Directory · Claim your page · Privacy · Terms · Help"
    ],
    "footerDestinations": [],
    "sourceSha256": "009b4befbf91acf0bb274ba4d368b1fbcdf1e1f371c1e7131f07127ac2167526",
    "sourceForms": []
  },
  {
    "sourceFile": "clubs.html",
    "slug": "clubs",
    "title": "Catch for clubs & communities — recurring events without the weekly scramble",
    "description": "Illustrative concept: Attendance, pairings, forms, reminders, and a member directory for run clubs, racket sports, trivia nights, and recurring social formats.",
    "originalDescription": "Attendance, pairings, forms, reminders, and a member directory for run clubs, racket sports, trivia nights, and recurring social formats.",
    "conceptNotice": "Content migrated from the static concept. Availability, integrations, pricing, example events, listing samples and predicted outcomes require verification; this page does not grant access or promise production support.",
    "sections": [
      {
        "id": "section-1",
        "sourceId": null,
        "heading": "The weekly event, without the weekly scramble.",
        "body": [
          "Illustrative concept: Catch for clubs & communities",
          "Illustrative concept: Your regulars shouldn't re-register every week, and you shouldn't rebuild the roster. Catch remembers your community between events — and runs the part of the evening you used to improvise."
        ],
        "items": [],
        "links": [
          {
            "label": "Request a free pilot",
            "sourceHref": "apply.html"
          },
          {
            "label": "See the live tools",
            "sourceHref": "#live"
          }
        ],
        "interactionHints": [
          "data-reveal"
        ],
        "originalCopy": [
          "Catch for clubs & communities",
          "The weekly event, without the",
          "weekly scramble.",
          "Your regulars shouldn't re-register every week, and you shouldn't rebuild the roster. Catch remembers your community between events — and runs the part of the evening you used to improvise.",
          "Request a free pilot",
          "See the live tools"
        ]
      },
      {
        "id": "section-2",
        "sourceId": null,
        "heading": "The ops that repeat, automated.",
        "body": [
          "Illustrative concept: Recurring ops",
          "Illustrative concept: Recurring events carry their community forward instead of starting from a blank list.",
          "Illustrative concept: Forms feed the roster directly — no re-entry between events.",
          "Illustrative concept: The member directory builds itself out of your check-ins.",
          "Illustrative concept: WhatsApp included, through your own Meta account.",
          "Illustrative concept: Catch announcements and scheduled reminders are live; WhatsApp campaigns are provider-gated; SMS and email senders are coming."
        ],
        "items": [
          {
            "body": "Illustrative concept: Repeat Duplicate the event, keep the roster, send the reminder Recurring events carry their community forward instead of starting from a blank list.",
            "originalCopy": [
              "Repeat",
              "Duplicate the event, keep the roster, send the reminder",
              "Recurring events carry their community forward instead of starting from a blank list."
            ],
            "title": "Duplicate the event, keep the roster, send the reminder"
          },
          {
            "body": "Illustrative concept: Forms Signups and waivers, handled Forms feed the roster directly — no re-entry between events.",
            "originalCopy": [
              "Forms",
              "Signups and waivers, handled",
              "Forms feed the roster directly — no re-entry between events."
            ],
            "title": "Signups and waivers, handled"
          },
          {
            "body": "Illustrative concept: CRM Remembers everyone who's ever shown up The member directory builds itself out of your check-ins.",
            "originalCopy": [
              "CRM",
              "Remembers everyone who's ever shown up",
              "The member directory builds itself out of your check-ins."
            ],
            "title": "Remembers everyone who's ever shown up"
          },
          {
            "body": "Illustrative concept: Messaging Reminders and announcements on schedule WhatsApp included, through your own Meta account.",
            "originalCopy": [
              "Messaging",
              "Reminders and announcements on schedule",
              "WhatsApp included, through your own Meta account."
            ],
            "title": "Reminders and announcements on schedule"
          }
        ],
        "links": [],
        "interactionHints": [
          "data-reveal"
        ],
        "originalCopy": [
          "Recurring ops",
          "The ops that repeat,",
          "automated.",
          "Repeat",
          "Duplicate the event, keep the roster, send the reminder",
          "Recurring events carry their community forward instead of starting from a blank list.",
          "Forms",
          "Signups and waivers, handled",
          "Forms feed the roster directly — no re-entry between events.",
          "CRM",
          "Remembers everyone who's ever shown up",
          "The member directory builds itself out of your check-ins.",
          "Messaging",
          "Reminders and announcements on schedule",
          "WhatsApp included, through your own Meta account.",
          "Catch announcements and scheduled reminders are live; WhatsApp campaigns are provider-gated; SMS and email senders are coming."
        ]
      },
      {
        "id": "live",
        "sourceId": "live",
        "heading": "Pairings and pace groups, settled before the warm-up ends.",
        "body": [
          "Illustrative concept: Live tools",
          "Illustrative concept: Check people in by QR or name, then let the runtime sort the rest. Late arrivals and dropouts re-balance without you touching a spreadsheet.",
          "Illustrative concept: Pace pods for run clubs and walks — sorted at check-in.",
          "Illustrative concept: Partner rotations for pickleball, padel, tennis, and badminton.",
          "Illustrative concept: Table teams for trivia, pub quizzes, dinners, and supper clubs.",
          "Illustrative concept: Formats"
        ],
        "items": [
          {
            "body": "Illustrative concept: Pace pods for run clubs and walks — sorted at check-in.",
            "originalCopy": [
              "Run clubs",
              "Pace pods",
              "Pace pods for run clubs and walks — sorted at check-in."
            ],
            "title": "Pace pods",
            "label": "Run clubs"
          },
          {
            "body": "Illustrative concept: Partner rotations for pickleball, padel, tennis, and badminton.",
            "originalCopy": [
              "Racket sports",
              "Partner rotations",
              "Partner rotations for pickleball, padel, tennis, and badminton."
            ],
            "title": "Partner rotations",
            "label": "Racket sports"
          },
          {
            "body": "Illustrative concept: Table teams for trivia, pub quizzes, dinners, and supper clubs.",
            "originalCopy": [
              "Tables",
              "Table teams",
              "Table teams for trivia, pub quizzes, dinners, and supper clubs."
            ],
            "title": "Table teams",
            "label": "Tables"
          },
          {
            "body": "Illustrative concept: Social runs",
            "originalCopy": [
              "Social runs"
            ]
          },
          {
            "body": "Illustrative concept: Walks",
            "originalCopy": [
              "Walks"
            ]
          },
          {
            "body": "Illustrative concept: Pickleball",
            "originalCopy": [
              "Pickleball"
            ]
          },
          {
            "body": "Illustrative concept: Padel",
            "originalCopy": [
              "Padel"
            ]
          },
          {
            "body": "Illustrative concept: Tennis",
            "originalCopy": [
              "Tennis"
            ]
          },
          {
            "body": "Illustrative concept: Badminton",
            "originalCopy": [
              "Badminton"
            ]
          },
          {
            "body": "Illustrative concept: Cycling",
            "originalCopy": [
              "Cycling"
            ]
          },
          {
            "body": "Illustrative concept: Yoga",
            "originalCopy": [
              "Yoga"
            ]
          },
          {
            "body": "Illustrative concept: Dinners",
            "originalCopy": [
              "Dinners"
            ]
          },
          {
            "body": "Illustrative concept: Pub quizzes",
            "originalCopy": [
              "Pub quizzes"
            ]
          },
          {
            "body": "Illustrative concept: Bar crawls",
            "originalCopy": [
              "Bar crawls"
            ]
          },
          {
            "body": "Illustrative concept: Mixers",
            "originalCopy": [
              "Mixers"
            ]
          },
          {
            "body": "Illustrative concept: Custom formats",
            "originalCopy": [
              "Custom formats"
            ]
          }
        ],
        "links": [],
        "interactionHints": [
          "data-reveal"
        ],
        "originalCopy": [
          "Live tools",
          "Pairings and pace groups, settled before the",
          "warm-up ends.",
          "Check people in by QR or name, then let the runtime sort the rest. Late arrivals and dropouts re-balance without you touching a spreadsheet.",
          "Run clubs",
          "Pace pods",
          "Pace pods for run clubs and walks — sorted at check-in.",
          "Racket sports",
          "Partner rotations",
          "Partner rotations for pickleball, padel, tennis, and badminton.",
          "Tables",
          "Table teams",
          "Table teams for trivia, pub quizzes, dinners, and supper clubs.",
          "Formats",
          "Social runs",
          "Walks",
          "Pickleball",
          "Padel",
          "Tennis",
          "Badminton",
          "Cycling",
          "Yoga",
          "Dinners",
          "Pub quizzes",
          "Bar crawls",
          "Mixers",
          "Custom formats"
        ]
      },
      {
        "id": "section-4",
        "sourceId": null,
        "heading": "An attendance record that becomes a community.",
        "body": [
          "Illustrative concept: Community",
          "Illustrative concept: Every check-in builds the member directory: who's new, who's regular, who keeps bringing friends. Referral links show which members actually grow the club — and the recap shows what to fix next time.",
          "Illustrative concept: Who's new, who's regular, who keeps bringing friends.",
          "Illustrative concept: Show which members actually grow the club.",
          "Illustrative concept: Shows what to fix next time."
        ],
        "items": [
          {
            "body": "Illustrative concept: Directory Member directory Who's new, who's regular, who keeps bringing friends.",
            "originalCopy": [
              "Directory",
              "Member directory",
              "Who's new, who's regular, who keeps bringing friends."
            ],
            "title": "Member directory"
          },
          {
            "body": "Illustrative concept: Referrals Referral links Show which members actually grow the club.",
            "originalCopy": [
              "Referrals",
              "Referral links",
              "Show which members actually grow the club."
            ],
            "title": "Referral links"
          },
          {
            "body": "Illustrative concept: Recap Post-event recap Shows what to fix next time.",
            "originalCopy": [
              "Recap",
              "Post-event recap",
              "Shows what to fix next time."
            ],
            "title": "Post-event recap"
          }
        ],
        "links": [],
        "interactionHints": [
          "data-reveal"
        ],
        "originalCopy": [
          "Community",
          "An attendance record that becomes a",
          "community.",
          "Every check-in builds the member directory: who's new, who's regular, who keeps bringing friends. Referral links show which members actually grow the club — and the recap shows what to fix next time.",
          "Directory",
          "Member directory",
          "Who's new, who's regular, who keeps bringing friends.",
          "Referrals",
          "Referral links",
          "Show which members actually grow the club.",
          "Recap",
          "Post-event recap",
          "Shows what to fix next time."
        ]
      },
      {
        "id": "pilot",
        "sourceId": "pilot",
        "heading": "Pilot Catch on your next event.",
        "body": [
          "Illustrative concept: The pilot",
          "Illustrative concept: We onboard a small number of organizers at a time, on real events. Tell us about yours — we'll get on a call, map your workflow, and set up a free pilot around it.",
          "Illustrative concept: Five quick steps — the event, your setup, what you'd use.",
          "Illustrative concept: Which tools you keep, which Catch replaces, which tier fits.",
          "Illustrative concept: Hands-on onboarding through doors, live tools, and recap.",
          "Illustrative concept: What worked, what it earned, what the next tier would add."
        ],
        "items": [
          {
            "body": "Illustrative concept: 01 Tell us about your event Five quick steps — the event, your setup, what you'd use.",
            "originalCopy": [
              "01",
              "Tell us about your event",
              "Five quick steps — the event, your setup, what you'd use."
            ],
            "title": "Tell us about your event"
          },
          {
            "body": "Illustrative concept: 02 We map your workflow on a call Which tools you keep, which Catch replaces, which tier fits.",
            "originalCopy": [
              "02",
              "We map your workflow on a call",
              "Which tools you keep, which Catch replaces, which tier fits."
            ],
            "title": "We map your workflow on a call"
          },
          {
            "body": "Illustrative concept: 03 You run a real event on Catch Hands-on onboarding through doors, live tools, and recap.",
            "originalCopy": [
              "03",
              "You run a real event on Catch",
              "Hands-on onboarding through doors, live tools, and recap."
            ],
            "title": "You run a real event on Catch"
          },
          {
            "body": "Illustrative concept: 04 We review it together What worked, what it earned, what the next tier would add.",
            "originalCopy": [
              "04",
              "We review it together",
              "What worked, what it earned, what the next tier would add."
            ],
            "title": "We review it together"
          }
        ],
        "links": [
          {
            "label": "Request a free pilot",
            "sourceHref": "apply.html"
          }
        ],
        "interactionHints": [
          "data-reveal"
        ],
        "originalCopy": [
          "The pilot",
          "Pilot Catch on your",
          "next event.",
          "We onboard a small number of organizers at a time, on real events. Tell us about yours — we'll get on a call, map your workflow, and set up a free pilot around it.",
          "Request a free pilot",
          "01",
          "Tell us about your event",
          "Five quick steps — the event, your setup, what you'd use.",
          "02",
          "We map your workflow on a call",
          "Which tools you keep, which Catch replaces, which tier fits.",
          "03",
          "You run a real event on Catch",
          "Hands-on onboarding through doors, live tools, and recap.",
          "04",
          "We review it together",
          "What worked, what it earned, what the next tier would add."
        ]
      },
      {
        "id": "section-6",
        "sourceId": null,
        "heading": "Fair questions.",
        "body": [
          "Illustrative concept: Standalone tools don't require Catch payments at all. If you collect dues or session fees, payment links and paid forms cover it without switching platforms.",
          "Illustrative concept: Not for the essentials — the live event works in a browser with phone verification. Profiles only matter at the network tier.",
          "Illustrative concept: No. The first circle works entirely off an exported guest list. Catch-powered booking is there when the attribution and admission rules are worth the switch.",
          "Illustrative concept: No. Guests verify a phone number and join the live event in a mobile browser. The Catch app only enters the picture at the network tier — and it's their choice.",
          "Illustrative concept: A real upcoming event, a guest list, and one call to map your workflow. Onboarding is hands-on and free during the pilot.",
          "Illustrative concept: Pricing scales with which circles you use and the size of your operation. We quote it on the call — advanced and managed-program capabilities price differently from standalone tooling.",
          "Illustrative concept: Everything in the first circle. Catch booking, payments, and restrictions are live on the booking tier. Multi-day programs run through managed pilots; SMS and email senders are on the roadmap."
        ],
        "items": [
          {
            "body": "Illustrative concept: Standalone tools don't require Catch payments at all. If you collect dues or session fees, payment links and paid forms cover it without switching platforms.",
            "originalCopy": [
              "We're free / pay-what-you-want — is this overkill?",
              "Standalone tools don't require Catch payments at all. If you collect dues or session fees, payment links and paid forms cover it without switching platforms."
            ],
            "title": "We're free / pay-what-you-want — is this overkill?"
          },
          {
            "body": "Illustrative concept: Not for the essentials — the live event works in a browser with phone verification. Profiles only matter at the network tier.",
            "originalCopy": [
              "Do my regulars need accounts?",
              "Not for the essentials — the live event works in a browser with phone verification. Profiles only matter at the network tier."
            ],
            "title": "Do my regulars need accounts?"
          },
          {
            "body": "Illustrative concept: No. The first circle works entirely off an exported guest list. Catch-powered booking is there when the attribution and admission rules are worth the switch.",
            "originalCopy": [
              "Do I have to leave my booking platform?",
              "No. The first circle works entirely off an exported guest list. Catch-powered booking is there when the attribution and admission rules are worth the switch."
            ],
            "title": "Do I have to leave my booking platform?"
          },
          {
            "body": "Illustrative concept: No. Guests verify a phone number and join the live event in a mobile browser. The Catch app only enters the picture at the network tier — and it's their choice.",
            "originalCopy": [
              "Do my guests need to download an app?",
              "No. Guests verify a phone number and join the live event in a mobile browser. The Catch app only enters the picture at the network tier — and it's their choice."
            ],
            "title": "Do my guests need to download an app?"
          },
          {
            "body": "Illustrative concept: A real upcoming event, a guest list, and one call to map your workflow. Onboarding is hands-on and free during the pilot.",
            "originalCopy": [
              "What does a pilot involve?",
              "A real upcoming event, a guest list, and one call to map your workflow. Onboarding is hands-on and free during the pilot."
            ],
            "title": "What does a pilot involve?"
          },
          {
            "body": "Illustrative concept: Pricing scales with which circles you use and the size of your operation. We quote it on the call — advanced and managed-program capabilities price differently from standalone tooling.",
            "originalCopy": [
              "How does pricing work?",
              "Pricing scales with which circles you use and the size of your operation. We quote it on the call — advanced and managed-program capabilities price differently from standalone tooling."
            ],
            "title": "How does pricing work?"
          },
          {
            "body": "Illustrative concept: Everything in the first circle. Catch booking, payments, and restrictions are live on the booking tier. Multi-day programs run through managed pilots; SMS and email senders are on the roadmap.",
            "originalCopy": [
              "What's actually live today?",
              "Everything in the first circle. Catch booking, payments, and restrictions are live on the booking tier. Multi-day programs run through managed pilots; SMS and email senders are on the roadmap."
            ],
            "title": "What's actually live today?"
          }
        ],
        "links": [],
        "interactionHints": [
          "data-reveal"
        ],
        "originalCopy": [
          "Fair questions.",
          "We're free / pay-what-you-want — is this overkill?",
          "Standalone tools don't require Catch payments at all. If you collect dues or session fees, payment links and paid forms cover it without switching platforms.",
          "Do my regulars need accounts?",
          "Not for the essentials — the live event works in a browser with phone verification. Profiles only matter at the network tier.",
          "Do I have to leave my booking platform?",
          "No. The first circle works entirely off an exported guest list. Catch-powered booking is there when the attribution and admission rules are worth the switch.",
          "Do my guests need to download an app?",
          "No. Guests verify a phone number and join the live event in a mobile browser. The Catch app only enters the picture at the network tier — and it's their choice.",
          "What does a pilot involve?",
          "A real upcoming event, a guest list, and one call to map your workflow. Onboarding is hands-on and free during the pilot.",
          "How does pricing work?",
          "Pricing scales with which circles you use and the size of your operation. We quote it on the call — advanced and managed-program capabilities price differently from standalone tooling.",
          "What's actually live today?",
          "Everything in the first circle. Catch booking, payments, and restrictions are live on the booking tier. Multi-day programs run through managed pilots; SMS and email senders are on the roadmap."
        ]
      }
    ],
    "headerDestinations": [
      {
        "label": "Catch.",
        "sourceHref": "index.html"
      },
      {
        "label": "For hosts",
        "sourceHref": "host.html"
      },
      {
        "label": "Stack audit",
        "sourceHref": "stack.html"
      },
      {
        "label": "Organizer directory",
        "sourceHref": "directory.html"
      },
      {
        "label": "Planners",
        "sourceHref": "planners.html"
      },
      {
        "label": "Singles & social",
        "sourceHref": "mixers.html"
      },
      {
        "label": "Clubs",
        "sourceHref": "clubs.html"
      },
      {
        "label": "Request a pilot",
        "sourceHref": "apply.html"
      }
    ],
    "footerCopy": [
      "Catch Host — the operating system for real-world events.",
      "Directory · Claim your page · Privacy · Terms · Help"
    ],
    "footerDestinations": [],
    "sourceSha256": "feab32f9cc28f623943d40c098415328a97368f138d9ed47682654737ccfcb7d",
    "sourceForms": []
  },
  {
    "sourceFile": "directory.html",
    "slug": "directory",
    "title": "Catch organizer directory — find your page",
    "description": "Illustrative concept: Public, source-backed pages for organizers in our launch cities — events, formats, and reviews included. Claim yours to attach host tools, responses, and analytics.",
    "originalDescription": "Public, source-backed pages for organizers in our launch cities — events, formats, and reviews included. Claim yours to attach host tools, responses, and analytics.",
    "conceptNotice": "Content migrated from the static concept. Availability, integrations, pricing, example events, listing samples and predicted outcomes require verification; this page does not grant access or promise production support.",
    "sections": [
      {
        "id": "section-1",
        "sourceId": null,
        "heading": "Organizers already on the record.",
        "body": [
          "Illustrative concept: Organizer directory",
          "Illustrative concept: Public, source-backed pages for organizers in our launch cities — events, formats, and reviews included. Claim yours to attach host tools, responses, and analytics."
        ],
        "items": [],
        "links": [],
        "interactionHints": [
          "data-reveal"
        ],
        "originalCopy": [
          "Organizer directory",
          "Organizers already on",
          "the record.",
          "Public, source-backed pages for organizers in our launch cities — events, formats, and reviews included. Claim yours to attach host tools, responses, and analytics."
        ]
      },
      {
        "id": "section-2",
        "sourceId": null,
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
            "originalCopy": [
              "B",
              "Bandra Supper Society",
              "Supper club · Mumbai · 4 sources",
              "Unclaimed — claim it"
            ]
          },
          {
            "title": "Indore Run Collective",
            "label": "Fictional directory sample",
            "body": "Illustrative concept: I Indore Run Collective Social runs · Indore · 3 sources Claimed",
            "originalCopy": [
              "I",
              "Indore Run Collective",
              "Social runs · Indore · 3 sources",
              "Claimed"
            ]
          },
          {
            "title": "Courtside Padel Club",
            "label": "Fictional directory sample",
            "body": "Illustrative concept: C Courtside Padel Club Racket club · Mumbai · 5 sources Unclaimed — claim it",
            "originalCopy": [
              "C",
              "Courtside Padel Club",
              "Racket club · Mumbai · 5 sources",
              "Unclaimed — claim it"
            ]
          },
          {
            "title": "The Wednesday Quiz",
            "label": "Fictional directory sample",
            "body": "Illustrative concept: W The Wednesday Quiz Pub quiz · Indore · 2 sources Unclaimed — claim it",
            "originalCopy": [
              "W",
              "The Wednesday Quiz",
              "Pub quiz · Indore · 2 sources",
              "Unclaimed — claim it"
            ]
          },
          {
            "title": "Fort Nights Social",
            "label": "Fictional directory sample",
            "body": "Illustrative concept: F Fort Nights Social Mixers · Mumbai · 3 sources Unclaimed — claim it",
            "originalCopy": [
              "F",
              "Fort Nights Social",
              "Mixers · Mumbai · 3 sources",
              "Unclaimed — claim it"
            ]
          },
          {
            "title": "Slow Morning Yoga Co.",
            "label": "Fictional directory sample",
            "body": "Illustrative concept: S Slow Morning Yoga Co. Yoga · Indore · 2 sources Claimed",
            "originalCopy": [
              "S",
              "Slow Morning Yoga Co.",
              "Yoga · Indore · 2 sources",
              "Claimed"
            ]
          }
        ],
        "links": [
          {
            "label": "B Bandra Supper SocietySupper club · Mumbai · 4 sources Unclaimed — claim it",
            "sourceHref": "claim.html"
          },
          {
            "label": "C Courtside Padel ClubRacket club · Mumbai · 5 sources Unclaimed — claim it",
            "sourceHref": "claim.html"
          },
          {
            "label": "W The Wednesday QuizPub quiz · Indore · 2 sources Unclaimed — claim it",
            "sourceHref": "claim.html"
          },
          {
            "label": "F Fort Nights SocialMixers · Mumbai · 3 sources Unclaimed — claim it",
            "sourceHref": "claim.html"
          }
        ],
        "interactionHints": [
          "data-reveal"
        ],
        "originalCopy": [
          "Search the record",
          "Find",
          "your page.",
          "Search",
          "B",
          "Bandra Supper Society",
          "Supper club · Mumbai · 4 sources",
          "Unclaimed — claim it",
          "I",
          "Indore Run Collective",
          "Social runs · Indore · 3 sources",
          "Claimed",
          "C",
          "Courtside Padel Club",
          "Racket club · Mumbai · 5 sources",
          "Unclaimed — claim it",
          "W",
          "The Wednesday Quiz",
          "Pub quiz · Indore · 2 sources",
          "Unclaimed — claim it",
          "F",
          "Fort Nights Social",
          "Mixers · Mumbai · 3 sources",
          "Unclaimed — claim it",
          "S",
          "Slow Morning Yoga Co.",
          "Yoga · Indore · 2 sources",
          "Claimed",
          "Sample rows for the concept preview — production listings are sourced from public event data and reviews."
        ]
      },
      {
        "id": "section-3",
        "sourceId": null,
        "heading": "Prototype content",
        "body": [
          "Illustrative concept: Pilot access is for organizers with real upcoming events — listed or not."
        ],
        "items": [
          {
            "body": "Illustrative concept: Pilot access is for organizers with real upcoming events — listed or not. Request a pilot",
            "originalCopy": [
              "Pilot access",
              "Not listed yet?",
              "Pilot access is for organizers with real upcoming events — listed or not.",
              "Request a pilot"
            ],
            "title": "Not listed yet?",
            "label": "Pilot access"
          }
        ],
        "links": [
          {
            "label": "Request a pilot",
            "sourceHref": "apply.html"
          }
        ],
        "interactionHints": [
          "data-reveal"
        ],
        "originalCopy": [
          "Pilot access",
          "Not listed yet?",
          "Pilot access is for organizers with real upcoming events — listed or not.",
          "Request a pilot"
        ]
      }
    ],
    "headerDestinations": [
      {
        "label": "Catch.",
        "sourceHref": "index.html"
      },
      {
        "label": "For hosts",
        "sourceHref": "host.html"
      },
      {
        "label": "Stack audit",
        "sourceHref": "stack.html"
      },
      {
        "label": "Organizer directory",
        "sourceHref": "directory.html"
      },
      {
        "label": "Planners",
        "sourceHref": "planners.html"
      },
      {
        "label": "Singles & social",
        "sourceHref": "mixers.html"
      },
      {
        "label": "Clubs",
        "sourceHref": "clubs.html"
      },
      {
        "label": "Request a pilot",
        "sourceHref": "apply.html"
      }
    ],
    "footerCopy": [
      "Catch Host — the operating system for real-world events.",
      "Directory · Claim your page · Privacy · Terms · Help"
    ],
    "footerDestinations": [],
    "sourceSha256": "9e1b9e4d9b083f841fad30384f4bfd7acb868d2efef8e97ca507db722c795b82",
    "sourceForms": [
      {
        "action": "claim.html",
        "method": "get",
        "role": "search",
        "fields": [
          {
            "tag": "input",
            "attributes": {
              "type": "search",
              "name": "q",
              "placeholder": "Search organizers, formats, cities…",
              "aria-label": "Search organizers"
            }
          },
          {
            "tag": "button",
            "attributes": {
              "type": "submit"
            }
          }
        ]
      }
    ]
  },
  {
    "sourceFile": "claim.html",
    "slug": "claim",
    "title": "Claim your organizer page — Catch",
    "description": "Illustrative concept: Claim your public organizer page on Catch — verified by a human before host tools, responses, and analytics attach to it.",
    "originalDescription": "Claim your public organizer page on Catch — verified by a human before host tools, responses, and analytics attach to it.",
    "conceptNotice": "Content migrated from the static concept. Availability, integrations, pricing, example events, listing samples and predicted outcomes require verification; this page does not grant access or promise production support.",
    "sections": [
      {
        "id": "section-1",
        "sourceId": null,
        "heading": "This page is yours. Prove it.",
        "body": [
          "Illustrative concept: Claim your listing",
          "Illustrative concept: Every claim is reviewed by a human before anything attaches to the page. Tell us who you are, show a little proof, and the listing's tools unlock once it checks out."
        ],
        "items": [],
        "links": [
          {
            "label": "Search the directory",
            "sourceHref": "directory.html"
          },
          {
            "label": "See how it works",
            "sourceHref": "#how"
          }
        ],
        "interactionHints": [
          "data-reveal"
        ],
        "originalCopy": [
          "Claim your listing",
          "This page is yours.",
          "Prove it.",
          "Every claim is reviewed by a human before anything attaches to the page. Tell us who you are, show a little proof, and the listing's tools unlock once it checks out.",
          "Search the directory",
          "See how it works"
        ]
      },
      {
        "id": "how",
        "sourceId": "how",
        "heading": "Three steps. One review.",
        "body": [
          "Illustrative concept: The flow",
          "Illustrative concept: Claiming takes a few minutes. Nothing goes live on the page until a person on our team signs off.",
          "Illustrative concept: Search the directory and pick your organizer page.",
          "Illustrative concept: Name, role, work email or phone, and a few proof links.",
          "Illustrative concept: Choose a verification method, sign in with Google, submit — we review before tools attach."
        ],
        "items": [
          {
            "body": "Illustrative concept: 01 Find your listing Search the directory and pick your organizer page.",
            "originalCopy": [
              "01",
              "Find your listing",
              "Search the directory and pick your organizer page."
            ],
            "title": "Find your listing"
          },
          {
            "body": "Illustrative concept: 02 Tell us who you are Name, role, work email or phone, and a few proof links.",
            "originalCopy": [
              "02",
              "Tell us who you are",
              "Name, role, work email or phone, and a few proof links."
            ],
            "title": "Tell us who you are"
          },
          {
            "body": "Illustrative concept: 03 Verify & submit Choose a verification method, sign in with Google, submit — we review before tools attach.",
            "originalCopy": [
              "03",
              "Verify & submit",
              "Choose a verification method, sign in with Google, submit — we review before tools attach."
            ],
            "title": "Verify & submit"
          }
        ],
        "links": [],
        "interactionHints": [
          "data-reveal"
        ],
        "originalCopy": [
          "The flow",
          "Three steps.",
          "One review.",
          "Claiming takes a few minutes. Nothing goes live on the page until a person on our team signs off.",
          "01",
          "Find your listing",
          "Search the directory and pick your organizer page.",
          "02",
          "Tell us who you are",
          "Name, role, work email or phone, and a few proof links.",
          "03",
          "Verify & submit",
          "Choose a verification method, sign in with Google, submit — we review before tools attach."
        ]
      },
      {
        "id": "section-3",
        "sourceId": null,
        "heading": "Your page, working for you.",
        "body": [
          "Illustrative concept: What claiming unlocks",
          "Illustrative concept: Answer guests where the public record lives.",
          "Illustrative concept: Your next event posts straight to your page.",
          "Illustrative concept: Views, sources, and the searches that find you.",
          "Illustrative concept: Guest lists, check-in, and messaging — on the listing people already find."
        ],
        "items": [
          {
            "body": "Illustrative concept: Answer guests where the public record lives.",
            "originalCopy": [
              "Reviews",
              "Respond to reviews",
              "Answer guests where the public record lives."
            ],
            "title": "Respond to reviews",
            "label": "Reviews"
          },
          {
            "body": "Illustrative concept: Your next event posts straight to your page.",
            "originalCopy": [
              "Events",
              "Publish & manage events",
              "Your next event posts straight to your page."
            ],
            "title": "Publish & manage events",
            "label": "Events"
          },
          {
            "body": "Illustrative concept: Views, sources, and the searches that find you.",
            "originalCopy": [
              "Analytics",
              "See listing analytics",
              "Views, sources, and the searches that find you."
            ],
            "title": "See listing analytics",
            "label": "Analytics"
          },
          {
            "body": "Illustrative concept: Guest lists, check-in, and messaging — on the listing people already find.",
            "originalCopy": [
              "Host tools",
              "Attach host tools",
              "Guest lists, check-in, and messaging — on the listing people already find."
            ],
            "title": "Attach host tools",
            "label": "Host tools"
          }
        ],
        "links": [],
        "interactionHints": [
          "data-reveal"
        ],
        "originalCopy": [
          "What claiming unlocks",
          "Your page,",
          "working for you.",
          "Reviews",
          "Respond to reviews",
          "Answer guests where the public record lives.",
          "Events",
          "Publish & manage events",
          "Your next event posts straight to your page.",
          "Analytics",
          "See listing analytics",
          "Views, sources, and the searches that find you.",
          "Host tools",
          "Attach host tools",
          "Guest lists, check-in, and messaging — on the listing people already find."
        ]
      },
      {
        "id": "section-4",
        "sourceId": null,
        "heading": "Where a claim can land.",
        "body": [
          "Illustrative concept: Listing states",
          "Illustrative concept: We verify ownership first — a human reads every claim before anything attaches.",
          "Illustrative concept: If that's wrong, contact us — disputes are reviewed by hand.",
          "Illustrative concept: Some listings aren't claimable yet — request a pilot instead."
        ],
        "items": [
          {
            "body": "Illustrative concept: State 01 Pending review We verify ownership first — a human reads every claim before anything attaches. In queue",
            "originalCopy": [
              "State 01",
              "Pending review",
              "We verify ownership first — a human reads every claim before anything attaches.",
              "In queue"
            ],
            "title": "Pending review",
            "label": "In queue"
          },
          {
            "body": "Illustrative concept: State 02 Already claimed If that's wrong, contact us — disputes are reviewed by hand. Dispute path",
            "originalCopy": [
              "State 02",
              "Already claimed",
              "If that's wrong, contact us — disputes are reviewed by hand.",
              "Dispute path"
            ],
            "title": "Already claimed",
            "label": "Dispute path"
          },
          {
            "body": "Illustrative concept: State 03 Unavailable Some listings aren't claimable yet — request a pilot instead. Locked",
            "originalCopy": [
              "State 03",
              "Unavailable",
              "Some listings aren't claimable yet — request a pilot instead.",
              "Locked"
            ],
            "title": "Unavailable",
            "label": "Locked"
          }
        ],
        "links": [],
        "interactionHints": [
          "data-reveal"
        ],
        "originalCopy": [
          "Listing states",
          "Where a claim can",
          "land.",
          "State 01",
          "Pending review",
          "We verify ownership first — a human reads every claim before anything attaches.",
          "In queue",
          "State 02",
          "Already claimed",
          "If that's wrong, contact us — disputes are reviewed by hand.",
          "Dispute path",
          "State 03",
          "Unavailable",
          "Some listings aren't claimable yet — request a pilot instead.",
          "Locked"
        ]
      },
      {
        "id": "section-5",
        "sourceId": null,
        "heading": "Found your page? Start there.",
        "body": [
          "Illustrative concept: Start your claim",
          "Illustrative concept: Search the directory to find your listing. Not listed? Pilots are open to organizers with real upcoming events either way."
        ],
        "items": [],
        "links": [
          {
            "label": "Search the directory",
            "sourceHref": "directory.html"
          },
          {
            "label": "Request a pilot instead",
            "sourceHref": "apply.html"
          }
        ],
        "interactionHints": [
          "data-reveal"
        ],
        "originalCopy": [
          "Start your claim",
          "Found your page?",
          "Start there.",
          "Search the directory to find your listing. Not listed? Pilots are open to organizers with real upcoming events either way.",
          "Search the directory",
          "Request a pilot instead"
        ]
      },
      {
        "id": "section-6",
        "sourceId": null,
        "heading": "Fair questions.",
        "body": [
          "Illustrative concept: Role, contact details, and proof links — then a human reviews the claim. Tools don't attach until it passes.",
          "Illustrative concept: Claim it and correct it — corrections go through the same review before they publish.",
          "Illustrative concept: Contact us from the listing page — disputes are reviewed."
        ],
        "items": [
          {
            "body": "Illustrative concept: Role, contact details, and proof links — then a human reviews the claim. Tools don't attach until it passes.",
            "originalCopy": [
              "How do you verify ownership?",
              "Role, contact details, and proof links — then a human reviews the claim. Tools don't attach until it passes."
            ],
            "title": "How do you verify ownership?"
          },
          {
            "body": "Illustrative concept: Claim it and correct it — corrections go through the same review before they publish.",
            "originalCopy": [
              "What if my page shows wrong info?",
              "Claim it and correct it — corrections go through the same review before they publish."
            ],
            "title": "What if my page shows wrong info?"
          },
          {
            "body": "Illustrative concept: Contact us from the listing page — disputes are reviewed.",
            "originalCopy": [
              "Claimed by someone else?",
              "Contact us from the listing page — disputes are reviewed."
            ],
            "title": "Claimed by someone else?"
          }
        ],
        "links": [],
        "interactionHints": [
          "data-reveal"
        ],
        "originalCopy": [
          "Fair questions.",
          "How do you verify ownership?",
          "Role, contact details, and proof links — then a human reviews the claim. Tools don't attach until it passes.",
          "What if my page shows wrong info?",
          "Claim it and correct it — corrections go through the same review before they publish.",
          "Claimed by someone else?",
          "Contact us from the listing page — disputes are reviewed."
        ]
      }
    ],
    "headerDestinations": [
      {
        "label": "Catch.",
        "sourceHref": "index.html"
      },
      {
        "label": "For hosts",
        "sourceHref": "host.html"
      },
      {
        "label": "Stack audit",
        "sourceHref": "stack.html"
      },
      {
        "label": "Organizer directory",
        "sourceHref": "directory.html"
      },
      {
        "label": "Planners",
        "sourceHref": "planners.html"
      },
      {
        "label": "Singles & social",
        "sourceHref": "mixers.html"
      },
      {
        "label": "Clubs",
        "sourceHref": "clubs.html"
      },
      {
        "label": "Request a pilot",
        "sourceHref": "apply.html"
      }
    ],
    "footerCopy": [
      "Catch Host — the operating system for real-world events.",
      "Directory · Claim your page · Privacy · Terms · Help"
    ],
    "footerDestinations": [],
    "sourceSha256": "596632d59f288c26699dd119e14d59596f0836c600af8937dacda495986605ae",
    "sourceForms": []
  },
  {
    "sourceFile": "apply.html",
    "slug": "apply",
    "title": "Request a free pilot — Catch Host",
    "description": "Illustrative concept: Five quick steps — who you are, the event you'd run, your current setup, and where Catch could help most. We review every application ourselves.",
    "originalDescription": "Five quick steps — who you are, the event you'd run, your current setup, and where Catch could help most. We review every application ourselves.",
    "conceptNotice": "Content migrated from the static concept. Availability, integrations, pricing, example events, listing samples and predicted outcomes require verification; this page does not grant access or promise production support.",
    "sections": [
      {
        "id": "section-1",
        "sourceId": null,
        "heading": "Request a free pilot.",
        "body": [
          "Illustrative concept: Pilot request",
          "Illustrative concept: Five quick steps — who you are, the event you'd run, your current setup, and where Catch could help most. We review every application ourselves and reply about scheduling a call."
        ],
        "items": [
          {
            "body": "Illustrative concept: Free during the pilot. No platform switch required to start.",
            "originalCopy": [
              "The pilot",
              "Free during the pilot. No platform switch required to start."
            ],
            "label": "The pilot"
          },
          {
            "body": "Illustrative concept: Application form mounts here — existing 5-step flow: About you → Your next event → Current setup → What you'd use → Review & send",
            "originalCopy": [
              "Application form mounts here — existing 5-step flow: About you → Your next event → Current setup → What you'd use → Review & send"
            ]
          }
        ],
        "links": [],
        "interactionHints": [
          "data-reveal"
        ],
        "originalCopy": [
          "Pilot request",
          "Request a",
          "free pilot.",
          "Five quick steps — who you are, the event you'd run, your current setup, and where Catch could help most. We review every application ourselves and reply about scheduling a call.",
          "The pilot",
          "Free during the pilot. No platform switch required to start.",
          "Application form mounts here — existing 5-step flow: About you → Your next event → Current setup → What you'd use → Review & send"
        ]
      },
      {
        "id": "section-2",
        "sourceId": null,
        "heading": "Five quick steps.",
        "body": [
          "Illustrative concept: The application",
          "Illustrative concept: Who hosts and what you run.",
          "Illustrative concept: The real event we'd pilot on.",
          "Illustrative concept: Booking/RSVP platform and guest-list size.",
          "Illustrative concept: The capabilities that matter most.",
          "Illustrative concept: Confirm and we schedule a call."
        ],
        "items": [
          {
            "body": "Illustrative concept: 01 About you Who hosts and what you run.",
            "originalCopy": [
              "01",
              "About you",
              "Who hosts and what you run."
            ],
            "title": "About you"
          },
          {
            "body": "Illustrative concept: 02 Your next event The real event we'd pilot on.",
            "originalCopy": [
              "02",
              "Your next event",
              "The real event we'd pilot on."
            ],
            "title": "Your next event"
          },
          {
            "body": "Illustrative concept: 03 Your current setup Booking/RSVP platform and guest-list size.",
            "originalCopy": [
              "03",
              "Your current setup",
              "Booking/RSVP platform and guest-list size."
            ],
            "title": "Your current setup"
          },
          {
            "body": "Illustrative concept: 04 What you'd use The capabilities that matter most.",
            "originalCopy": [
              "04",
              "What you'd use",
              "The capabilities that matter most."
            ],
            "title": "What you'd use"
          },
          {
            "body": "Illustrative concept: 05 Review & send Confirm and we schedule a call.",
            "originalCopy": [
              "05",
              "Review & send",
              "Confirm and we schedule a call."
            ],
            "title": "Review & send"
          }
        ],
        "links": [],
        "interactionHints": [
          "data-reveal"
        ],
        "originalCopy": [
          "The application",
          "Five",
          "quick",
          "steps.",
          "01",
          "About you",
          "Who hosts and what you run.",
          "02",
          "Your next event",
          "The real event we'd pilot on.",
          "03",
          "Your current setup",
          "Booking/RSVP platform and guest-list size.",
          "04",
          "What you'd use",
          "The capabilities that matter most.",
          "05",
          "Review & send",
          "Confirm and we schedule a call."
        ]
      },
      {
        "id": "section-3",
        "sourceId": null,
        "heading": "Application in.",
        "body": [
          "Illustrative concept: After you send",
          "Illustrative concept: We read every one — expect a call scheduling link if your event is a good pilot fit."
        ],
        "items": [],
        "links": [
          {
            "label": "See what Catch Host does",
            "sourceHref": "host.html"
          }
        ],
        "interactionHints": [
          "data-reveal"
        ],
        "originalCopy": [
          "After you send",
          "Application",
          "in.",
          "We read every one — expect a call scheduling link if your event is a good pilot fit.",
          "See what Catch Host does"
        ]
      }
    ],
    "headerDestinations": [
      {
        "label": "Catch.",
        "sourceHref": "index.html"
      },
      {
        "label": "For hosts",
        "sourceHref": "host.html"
      },
      {
        "label": "Stack audit",
        "sourceHref": "stack.html"
      },
      {
        "label": "Organizer directory",
        "sourceHref": "directory.html"
      },
      {
        "label": "Planners",
        "sourceHref": "planners.html"
      },
      {
        "label": "Singles & social",
        "sourceHref": "mixers.html"
      },
      {
        "label": "Clubs",
        "sourceHref": "clubs.html"
      },
      {
        "label": "Request a pilot",
        "sourceHref": "apply.html"
      }
    ],
    "footerCopy": [
      "Catch Host — the operating system for real-world events.",
      "Directory · Claim your page · Privacy · Terms · Help"
    ],
    "footerDestinations": [],
    "sourceSha256": "36892b2cbc8cbfd4292f7944486773820a0154f595ee7e0dcce0c2d043cc2a22",
    "sourceForms": []
  },
  {
    "sourceFile": "stack.html",
    "slug": "stack",
    "title": "The pile audit — map your event stack on Catch",
    "description": "Illustrative concept: Pick the tools you run today. See what Catch keeps, what it replaces, and which tier your stack lands on.",
    "originalDescription": "Pick the tools you run today. See what Catch keeps, what it replaces, and which tier your stack lands on.",
    "conceptNotice": "Content migrated from the static concept. Availability, integrations, pricing, example events, listing samples and predicted outcomes require verification; this page does not grant access or promise production support.",
    "sections": [
      {
        "id": "section-1",
        "sourceId": null,
        "heading": "Map your stack. Keep what works.",
        "body": [
          "Illustrative concept: The pile audit",
          "Illustrative concept: Nobody wakes up wanting another platform. Tick the tools your event actually runs on — we'll show you exactly what Catch keeps, what it replaces, and where your stack lands.",
          "Illustrative concept: Tap a receipt row for the detail →"
        ],
        "items": [],
        "links": [],
        "interactionHints": [
          "data-reveal"
        ],
        "originalCopy": [
          "The pile audit",
          "Map your stack.",
          "Keep what works.",
          "Nobody wakes up wanting another platform. Tick the tools your event actually runs on — we'll show you exactly what Catch keeps, what it replaces, and where your stack lands.",
          "Tap a receipt row for the detail →"
        ]
      },
      {
        "id": "section-2",
        "sourceId": null,
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
          {
            "label": "Request a pilot",
            "sourceHref": "apply.html"
          }
        ],
        "interactionHints": [
          "data-count",
          "data-groups",
          "data-reveal",
          "data-rows",
          "data-stack",
          "data-stack-search",
          "data-stats",
          "data-tier-name",
          "data-tier-why"
        ],
        "originalCopy": [
          "Step one",
          "What do you",
          "run today?",
          "The audit needs JavaScript to run — the mappings are summarized on the host page.",
          "Your stack → Catch",
          "0 selected",
          "Select the tools you run today — we'll map each one to what it becomes on Catch.",
          "Suggested fit",
          "Works alongside",
          "Keep your booking flow exactly as it is. Catch runs the room and the record off the roster — nothing to migrate.",
          "Request a pilot",
          "*SMS sender is on the roadmap — event announcements and WhatsApp campaigns are live. Roster imports are reviewed for Luma, Eventbrite, Partiful, and POSH; other platforms come in via CSV/XLSX or secure forwarding."
        ]
      },
      {
        "id": "section-3",
        "sourceId": null,
        "heading": "Five fractures every duct-taped stack shares.",
        "body": [
          "Illustrative concept: Why the pile hurts",
          "Illustrative concept: Every adjacent pair of tools is a manual export-import. The form feeds the sheet; the sheet feeds the broadcast list; nothing feeds back.",
          "Illustrative concept: The Razorpay dashboard and the guest list never merge. \"I paid but I'm not on the list\" gets resolved by screenshot.",
          "Illustrative concept: Priya attended three events and no-showed once — invisible. Every event starts a fresh sheet from zero.",
          "Illustrative concept: \"Reminder to confirmed-but-unpaid\" requires export, filter, re-import. So it doesn't get sent.",
          "Illustrative concept: The data dies in a sheet instead of becoming the next event's invite list. Reach resets to zero every time.",
          "Illustrative concept: Registration, payment, comms, check-in, and memory — the same guest, start to finish."
        ],
        "items": [
          {
            "body": "Illustrative concept: Every adjacent pair of tools is a manual export-import. The form feeds the sheet; the sheet feeds the broadcast list; nothing feeds back.",
            "originalCopy": [
              "01",
              "CSV churn",
              "Every adjacent pair of tools is a manual export-import. The form feeds the sheet; the sheet feeds the broadcast list; nothing feeds back."
            ],
            "title": "CSV churn",
            "label": "01"
          },
          {
            "body": "Illustrative concept: The Razorpay dashboard and the guest list never merge. \"I paid but I'm not on the list\" gets resolved by screenshot.",
            "originalCopy": [
              "02",
              "Payment ≠ attendance",
              "The Razorpay dashboard and the guest list never merge. \"I paid but I'm not on the list\" gets resolved by screenshot."
            ],
            "title": "Payment ≠ attendance",
            "label": "02"
          },
          {
            "body": "Illustrative concept: Priya attended three events and no-showed once — invisible. Every event starts a fresh sheet from zero.",
            "originalCopy": [
              "03",
              "No identity continuity",
              "Priya attended three events and no-showed once — invisible. Every event starts a fresh sheet from zero."
            ],
            "title": "No identity continuity",
            "label": "03"
          },
          {
            "body": "Illustrative concept: \"Reminder to confirmed-but-unpaid\" requires export, filter, re-import. So it doesn't get sent.",
            "originalCopy": [
              "04",
              "Messages off the record",
              "\"Reminder to confirmed-but-unpaid\" requires export, filter, re-import. So it doesn't get sent."
            ],
            "title": "Messages off the record",
            "label": "04"
          },
          {
            "body": "Illustrative concept: The data dies in a sheet instead of becoming the next event's invite list. Reach resets to zero every time.",
            "originalCopy": [
              "05",
              "No post-event loop",
              "The data dies in a sheet instead of becoming the next event's invite list. Reach resets to zero every time."
            ],
            "title": "No post-event loop",
            "label": "05"
          },
          {
            "body": "Illustrative concept: Registration, payment, comms, check-in, and memory — the same guest, start to finish.",
            "originalCopy": [
              "The fix",
              "One record, end to end.",
              "Registration, payment, comms, check-in, and memory — the same guest, start to finish."
            ],
            "title": "One record, end to end.",
            "label": "The fix"
          }
        ],
        "links": [],
        "interactionHints": [
          "data-reveal"
        ],
        "originalCopy": [
          "Why the pile hurts",
          "Five fractures every duct-taped stack",
          "shares.",
          "01",
          "CSV churn",
          "Every adjacent pair of tools is a manual export-import. The form feeds the sheet; the sheet feeds the broadcast list; nothing feeds back.",
          "02",
          "Payment ≠ attendance",
          "The Razorpay dashboard and the guest list never merge. \"I paid but I'm not on the list\" gets resolved by screenshot.",
          "03",
          "No identity continuity",
          "Priya attended three events and no-showed once — invisible. Every event starts a fresh sheet from zero.",
          "04",
          "Messages off the record",
          "\"Reminder to confirmed-but-unpaid\" requires export, filter, re-import. So it doesn't get sent.",
          "05",
          "No post-event loop",
          "The data dies in a sheet instead of becoming the next event's invite list. Reach resets to zero every time.",
          "The fix",
          "One record, end to end.",
          "Registration, payment, comms, check-in, and memory — the same guest, start to finish."
        ]
      },
      {
        "id": "section-4",
        "sourceId": null,
        "heading": "Bring the pile. We'll map it on the call.",
        "body": [
          "Illustrative concept: Next step",
          "Illustrative concept: Pilots are free and scoped to a real event. If a chunk of your stack needs keeping, that's the design — not a blocker."
        ],
        "items": [],
        "links": [
          {
            "label": "Request a free pilot",
            "sourceHref": "apply.html"
          },
          {
            "label": "Back to the platform",
            "sourceHref": "host.html"
          }
        ],
        "interactionHints": [
          "data-reveal"
        ],
        "originalCopy": [
          "Next step",
          "Bring the pile.",
          "We'll map it on the call.",
          "Pilots are free and scoped to a real event. If a chunk of your stack needs keeping, that's the design — not a blocker.",
          "Request a free pilot",
          "Back to the platform"
        ]
      }
    ],
    "headerDestinations": [
      {
        "label": "Catch.",
        "sourceHref": "index.html"
      },
      {
        "label": "For hosts",
        "sourceHref": "host.html"
      },
      {
        "label": "Stack audit",
        "sourceHref": "stack.html"
      },
      {
        "label": "Organizer directory",
        "sourceHref": "directory.html"
      },
      {
        "label": "Planners",
        "sourceHref": "planners.html"
      },
      {
        "label": "Singles & social",
        "sourceHref": "mixers.html"
      },
      {
        "label": "Clubs",
        "sourceHref": "clubs.html"
      },
      {
        "label": "Request a pilot",
        "sourceHref": "apply.html"
      }
    ],
    "footerCopy": [
      "Catch Host — the operating system for real-world events.",
      "Directory · Claim your page · Privacy · Terms · Help"
    ],
    "footerDestinations": [],
    "sourceSha256": "48c91ed3fe233b7386a64e9f5022fff4018154d2ace38aece209794edc39c882",
    "sourceForms": [
      {
        "action": null,
        "method": null,
        "role": "search",
        "fields": [
          {
            "tag": "input",
            "attributes": {
              "type": "search",
              "data-stack-search": null,
              "placeholder": "Filter tools — try 'razorpay' or 'form'…",
              "aria-label": "Filter tools"
            }
          }
        ]
      }
    ]
  }
];
