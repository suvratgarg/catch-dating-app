import type {FaqItem, PlaybookModule, PlaybookStage, SectionCopy} from "./types";

export const playbook = {
  eyebrow: "THE PLAYBOOK",
  title: "A better room, without more work for the host.",
  body: [
    "Choose the facilitation that fits your format, from a light arrival flow to a fully guided night.",
    "Every stage stays connected to the same attendance record, with host overrides and guest privacy built in.",
  ],
  railLabel: "Playbook stages",
  captureFallback: "Playbook",
  guardrailTitle: "Guardrails are part of the product.",
  guardrailBody:
    "You see coaching, never who caught whom. Guests can opt out of any live module. Blocked pairs are never assigned together.",
  formatNote:
    "Social runs stay light — movement is the icebreaker. Dinners and mixers can run the full program. Every module is optional, per event.",
} as const;

export const playbookStages = [
  {id: "before", label: "Before", sub: "The room takes shape", guestLine: "The room feels put together, not random.", hostLine: "The balance preview shows gaps in mix, pace, and group size while there is still time to fix them."},
  {id: "arrival", label: "Arrival", sub: "First Hello", guestLine: "A guided first interaction helps arrivals join the room.", hostLine: "Check-in confirms who is present and gives each guest a clear first step."},
  {id: "opening", label: "Opening", sub: "Welcome script", guestLine: "The room gets clear permission to talk.", hostLine: "A concise script opens the night well without requiring a professional MC."},
  {id: "mixing", label: "Mixing", sub: "Missions and introductions", guestLine: "Guests get an easy reason to start another conversation.", hostLine: "Small groups, prompts, and consented introduction requests keep the room moving."},
  {id: "activity", label: "Activity", sub: "Rotations and reveals", guestLine: "Assignments make it easier to meet across the room.", hostLine: "Timed rotations and synchronized reveals keep the flow visible, with overrides close by."},
  {id: "after", label: "After", sub: "The catch window", guestLine: "Private catches turn shared event context into warmer conversations.", hostLine: "Suggested openers support the first message without adding host admin."},
  {id: "debrief", label: "Debrief", sub: "The recap", guestLine: "Feedback helps the next event improve.", hostLine: "Attendance, mixing, catches, matches, and reviews return as concrete operating advice."},
] satisfies readonly PlaybookStage[];

export const playbookModules = [
  {id:"crowd_balance",anchor:"playbook-balance-preview",publicName:"Balance preview",stageId:"before",chip:"NEW POWER",oneLiner:"See who the room is missing — while you can still fix it.",more:"As bookings arrive, see the shape of the room: mix, age spread, pace, skill gaps, and group sizes. Guests never see these numbers; the room simply feels more intentional.",fits:"Every format."},
  {id:"qr_check_in",anchor:"playbook-door-check-in",publicName:"Door check-in",stageId:"arrival",chip:"OFF YOUR PLATE",oneLiner:"Know who is actually in the room.",more:"Guests check in by QR or with a host tap. One attendance record unlocks catching, verified reviews, and reporting, with manual check-in available when needed.",fits:"Every format."},
  {id:"first_hello_check_in",anchor:"playbook-first-hello",publicName:"First Hello",stageId:"arrival",chip:"NEW POWER",oneLiner:"Give every arrival a clear first interaction.",more:"A small arrival mission suggests a person to find and a question to ask. Guests can skip or request another mission; blocked pairs are never assigned.",fits:"Dinners, mixers, quiz nights, and pickleball. Off by default."},
  {id:"host_script",anchor:"playbook-welcome-script",publicName:"Welcome script",stageId:"opening",chip:"OFF YOUR PLATE",oneLiner:"Open the night with a clear, concise guide.",more:"A welcome line, safety note, and first prompt fit on the host screen and give the room permission to talk.",fits:"Every format."},
  {id:"micro_pods",anchor:"playbook-starter-pods",publicName:"Starter pods",stageId:"opening",chip:"OFF YOUR PLATE",oneLiner:"Start in small groups instead of cold approaches.",more:"Guests begin in groups of four to six based on pace, interests, or who came together. Hosts can reshuffle when arrivals differ from signups.",fits:"Every format; especially runs and large mixers."},
  {id:"social_missions",anchor:"playbook-missions",publicName:"Missions",stageId:"mixing",chip:"OFF YOUR PLATE",oneLiner:"An easy reason to start one more conversation.",more:"Three light prompts tailored to the event run while the room mixes. They are optional and return attention to the event rather than the app.",fits:"Every format."},
  {id:"guided_rotations",anchor:"playbook-rotations",publicName:"Rotations",stageId:"activity",chip:"OFF YOUR PLATE",oneLiner:"Move pairs, tables, or pods without manual logistics.",more:"Set round length and count; the Playbook reshuffles assignments and shows each guest only where to go next. The host keeps override control.",fits:"Dinners, mixers, quiz nights, and racket socials."},
  {id:"live_reveal",anchor:"playbook-countdown-reveals",publicName:"Countdown reveals",stageId:"activity",chip:"NEW POWER",oneLiner:"Give the night shared transition moments.",more:"A synchronized countdown, optional clue, and reveal move the room together. Hosts control each round from the live screen.",fits:"Dinners, mixers, quiz nights, and pickleball."},
  {id:"compatibility_questionnaire",anchor:"playbook-match-clues",publicName:"Match clues",stageId:"before",chip:"NEW POWER",oneLiner:"Add conversation context beyond looks.",more:"An optional short questionnaire creates reveal clues and light pairing context as conversation starters, never a chemistry score.",fits:"Mixers, dinners, and quiz nights. Off by default."},
  {id:"wingman_requests",anchor:"playbook-help-me-say-hi",publicName:"Help me say hi",stageId:"mixing",chip:"NEW POWER",oneLiner:"Let guests request a quiet introduction.",more:"Checked-in guests can make explicit, private requests. The other person is not notified; the host decides whether and how to make the introduction.",fits:"Every stationary format."},
  {id:"contextual_openers",anchor:"playbook-openers",publicName:"Openers",stageId:"after",chip:"NEW POWER",oneLiner:"Start a match chat with shared context.",more:"Catch suggests openers based on the event both people attended. Either person can ignore them, and the host has no extra work.",fits:"Every format; automatic."},
  {id:"decomposed_feedback",anchor:"playbook-guest-feedback",publicName:"Guest feedback",stageId:"after",chip:"NEW POWER",oneLiner:"Learn what guests experienced and what can improve.",more:"Short private questions cover welcome, balance, structure, safety, and connection. Hosts see aggregate patterns, not individual answers.",fits:"Every format."},
  {id:"host_analytics",anchor:"playbook-recap",publicName:"The recap",stageId:"debrief",chip:"NEW POWER",oneLiner:"Turn event signals into one or two next steps.",more:"Attendance, mixing, catches, matches, reviews, and repeat guests become a concise brief with concrete recommendations.",fits:"Every format; automatic."},
  {id:"safety_controls",anchor:"playbook-safety-layer",publicName:"Safety layer",stageId:"always",oneLiner:"Not a module. The floor.",more:"Blocks and reports apply to every assignment, reveal, and introduction. Guests can opt out, and help actions remain close throughout the event.",fits:"Every format; always on."},
] satisfies readonly PlaybookModule[];

export const hostFoundingOffer = {
  title: "Founding hosts pay 0% Catch platform fee for 24 months.",
  body:
    "Apply for manual approval. Your 24-month lock starts when your first Catch event goes live. Standard payment processor fees still apply, e.g. Stripe, Razorpay, etc.",
  badgeAriaLabel: "Founding Host badge preview",
  badgeLabel: "Founding",
  badgeValue: "Host",
  steps: ["Apply", "Get approved", "Publish first event", "Lock begins"],
} as const;

export const hostTrust = {
  title: "Guardrails are part of the product.",
  body:
    "Get clear controls for admission, payments, attendance, privacy, safety, and post-event follow-up in one operating flow.",
} satisfies SectionCopy;

export const hostTrustItems = [
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
] as const;

export const hostFaq = {
  title: "Questions hosts ask before switching tools.",
} satisfies SectionCopy;

export const hostFaqs = [
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
] satisfies readonly FaqItem[];
