export const prototypeInteractionContent = {
  notice: 'Illustrative local preview. These tool mappings, commercial tiers and activity examples preserve the prototype for discussion; they do not verify integrations, availability or pricing.',
  stack: {
    selectedCount: '{count} selected',
    statistics: '{retired} retired · {kept} kept',
    empty: "Select the tools you run today — we'll map each one to what it becomes on Catch.",
    networkSuffix: " And when your guests adopt the Catch app, CrossPaths and discovery kick in — that's the network tier.",
    searchLabel: 'Filter tools',
    searchPlaceholder: "Filter tools — try 'razorpay' or 'form'…",
    receiptHeading: 'Your stack → Catch',
    resultHeading: 'Suggested starting point',
    disclosure: 'Tool selections stay in this browser view. No account, connection, import or purchase is created.',
  },
  tiers: [
    { id: 'alongside', name: 'Works alongside', ringLabel: 'Works alongside tier' },
    { id: 'booking', name: 'Catch booking', ringLabel: 'Catch booking tier' },
    { id: 'network', name: 'Catch network', ringLabel: 'Catch network tier' },
  ],
  console: {
    heading: 'Catch Host — live event console',
    notice: 'Illustrative activity replay. Names, events and counts are fictional.',
    activityLabel: 'Example event activity',
    initialCheckIns: 31,
    events: [
      { id: 'supper', name: 'Sunday Supper Club', detail: 'Tonight · Bandra · 40 seats', status: 'in' },
      { id: 'run', name: 'Saturday Social Run', detail: 'Sat · Indore · pace pods on', status: 'opens 7:00' },
      { id: 'quiz', name: 'Quiz Night XI', detail: 'Fri · Mumbai · teams forming', status: 'waitlist 12' },
    ],
    rows: [
      { id: 'avery', time: '19:02', text: 'Avery checked in — guest list verified', checkIn: true },
      { id: 'hello', time: '19:02', text: 'First Hello sent → "Find Jordan, ask about the duet"', checkIn: false },
      { id: 'wingman', time: '19:04', text: 'Wingman request — host review queued', checkIn: false },
      { id: 'morgan', time: '19:05', text: 'Morgan checked in — walk-in approved', checkIn: true },
      { id: 'rotations', time: '19:07', text: 'Table rotations published to 6 groups', checkIn: false },
      { id: 'referral', time: '19:09', text: 'Referral link "priya-share" → 3 opens, 1 registered', checkIn: false },
    ],
    footer: ['live', 'no-download guest runtime', 'host overrides on'],
  },
} as const;
