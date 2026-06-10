import {AdminClubDetails, AdminOverviewResponse} from "./types";

export const sampleOverview: AdminOverviewResponse = {
  generatedAt: "2026-06-01T08:30:00.000Z",
  timezone: "UTC",
  metrics: [
    {id: "signupsToday", label: "Signups today", value: 18},
    {id: "signupsThisWeek", label: "Signups this week", value: 96},
    {id: "completedProfiles", label: "Completed profiles", value: 714},
    {id: "openReports", label: "Open reports", value: 4},
    {id: "pendingModerationFlags", label: "Pending moderation", value: 7},
    {id: "eventSafetyReports", label: "Event safety reports", value: 2},
    {id: "pendingApplications", label: "Pending applications", value: 41},
    {id: "pendingClubClaims", label: "Pending organizer claims", value: 2},
    {id: "indexReviewPages", label: "Index review pages", value: 2},
    {id: "activeHosts", label: "Active host claims", value: 23},
    {id: "activeEvents", label: "Active events", value: 31},
    {id: "completedPayments", label: "Completed payments", value: 186},
    {id: "failedPayments", label: "Failed payments", value: 3},
    {id: "signupFailedPayments", label: "Signup-failed payments", value: 1},
    {id: "payoutRestrictedHosts", label: "Payout issues", value: 5},
  ],
  queues: {
    safetyReports: [
      {
        id: "reports/report-1",
        title: "harassment",
        detail: "target user_829 - chat",
        status: "open",
        createdAt: "2026-06-01T07:44:00.000Z",
        targetPath: "reports/report-1",
      },
      {
        id: "reports/report-2",
        title: "fake_profile",
        detail: "target user_115 - profile",
        status: "open",
        createdAt: "2026-06-01T05:02:00.000Z",
        targetPath: "reports/report-2",
      },
    ],
    moderationFlags: [
      {
        id: "moderationFlags/flag-1",
        title: "banned_text",
        detail: "target user_322 - chat_message",
        status: "pending",
        createdAt: "2026-06-01T06:16:00.000Z",
        targetPath: "moderationFlags/flag-1",
      },
      {
        id: "moderationFlags/flag-2",
        title: "explicit_photo",
        detail: "target user_667 - profile_photo",
        status: "pending",
        createdAt: "2026-05-31T19:31:00.000Z",
        targetPath: "moderationFlags/flag-2",
      },
    ],
    eventSafetyReports: [
      {
        id: "eventSafetyReports/event-1_user-1",
        title: "Event delhi-mixer-14",
        detail: "club south-delhi-runs - reporter user_441",
        status: "open",
        createdAt: "2026-06-01T03:28:00.000Z",
        targetPath: "eventSafetyReports/event-1_user-1",
      },
    ],
    accessApplications: [
      {
        id: "accessApplications/application-1",
        title: "Maya Shah",
        detail: "delhi - attendee - wants to host",
        status: "pending",
        createdAt: "2026-06-01T02:11:00.000Z",
        targetPath: "accessApplications/application-1",
      },
      {
        id: "accessApplications/application-2",
        title: "Rohan Mehta",
        detail: "mumbai - host",
        status: "pending",
        createdAt: "2026-05-31T22:05:00.000Z",
        targetPath: "accessApplications/application-2",
      },
    ],
    clubClaimRequests: [
      {
        id: "clubClaimRequests/club_claim_afterfly",
        title: "AFTER FLY owner",
        detail: "club afterfly-run-club-indore - founder - hello@afterfly.in - 2 proof links",
        status: "pending",
        createdAt: "2026-06-01T01:48:00.000Z",
        targetPath: "clubClaimRequests/club_claim_afterfly",
      },
      {
        id: "clubClaimRequests/club_claim_bhag",
        title: "Bhag Club manager",
        detail: "club bhag-run-club-delhi - manager - no contact - 1 proof links",
        status: "pending",
        createdAt: "2026-05-31T20:14:00.000Z",
        targetPath: "clubClaimRequests/club_claim_bhag",
      },
    ],
    clubIndexReviews: [
      {
        id: "clubs/afterfly-run-club-indore",
        title: "AFTER FLY",
        detail: "/organizers/indore/afterfly-run-club/ - high - sourceBacked",
        status: "noindex",
        createdAt: "2026-06-01T12:00:00.000Z",
        targetPath: "clubs/afterfly-run-club-indore",
      },
      {
        id: "clubs/bhag-run-club-delhi",
        title: "Bhag Run Club",
        detail: "/organizers/delhi/bhag-run-club/ - medium - sourceBacked",
        status: "noindex",
        createdAt: "2026-06-01T11:00:00.000Z",
        targetPath: "clubs/bhag-run-club-delhi",
      },
    ],
    paymentIssues: [
      {
        id: "payments/payment-1",
        title: "INR 150000",
        detail: "event bandra-run-4 - user user_221",
        status: "failed",
        createdAt: "2026-06-01T04:52:00.000Z",
        targetPath: "payments/payment-1",
      },
    ],
  },
  dataQuality: [
    {
      id: "signup-source",
      label: "Signup metric source",
      state: "warning",
      detail: "Using Auth metadata until server-owned profile timestamps exist.",
    },
    {
      id: "finance-ledger",
      label: "Host settlement ledger",
      state: "blocked",
      detail: "Commission and settlement records are not modeled yet.",
    },
    {
      id: "exports",
      label: "BigQuery marts",
      state: "warning",
      detail: "Participant exports exist; users/events/payments exports are next.",
    },
  ],
};

export const sampleClubDetails: Record<string, AdminClubDetails> = {
  "afterfly-run-club-indore": {
    clubId: "afterfly-run-club-indore",
    name: "AFTER FLY",
    description:
      "Movement and music community discovered from public event sources.",
    location: "indore",
    area: "Indore",
    tags: ["run club", "music", "community"],
    instagramHandle: "afterfly.in",
    phoneNumber: null,
    email: null,
    imageUrl: null,
    profileImageUrl: null,
    entityKind: "creatorCommunity",
    entitySubtypes: ["social run club", "music community"],
    displayCategory: "Run club",
    cityName: "Indore",
    regionName: "Madhya Pradesh",
    countryCode: "IN",
    countryName: "India",
    appVisibility: "hidden",
    ownershipState: "programmatic",
    claimState: "unclaimed",
    publicPage: {
      slug: "afterfly-run-club",
      citySlug: "indore",
      canonicalPath: "/organizers/indore/afterfly-run-club/",
      publishStatus: "qa",
      indexStatus: "noindex",
      robots: "noindex, follow",
      seoTitle: "AFTER FLY | Indore organizer profile | Catch",
      seoDescription:
        "Unclaimed Catch profile for AFTER FLY, a movement and music community in Indore.",
    },
    provenance: {
      origin: "scraper",
      sourceConfidence: "high",
      verificationStatus: "sourceBacked",
    },
    publicProfile: {
      headline: "AFTER FLY movement and music community in Indore",
      summary:
        "A public event page connects AFTER FLY to an Indore run and rave format. This profile stays hidden from app discovery and noindexed until owner contact, cadence, and media rights are reviewed.",
      sourceSummary:
        "Public Luma event evidence confirms an Indore event and an Instagram handle.",
      formats: ["Run and rave", "Social run"],
      fitNotes: [
        "Social post-run format",
        "Useful target for Catch host onboarding",
      ],
      missingEvidence: ["Current cadence", "Owner contact", "Media permission"],
    },
  },
  "bhag-run-club-delhi": {
    clubId: "bhag-run-club-delhi",
    name: "Bhag Club",
    description:
      "Running community and activewear brand with public official sources.",
    location: "delhi-ncr",
    area: "Delhi NCR",
    tags: ["run club", "activewear", "community"],
    instagramHandle: "bhagclub",
    phoneNumber: null,
    email: null,
    imageUrl: null,
    profileImageUrl: null,
    entityKind: "brand",
    entitySubtypes: ["run club", "activewear brand"],
    displayCategory: "Running community",
    cityName: "Delhi NCR",
    regionName: "Delhi",
    countryCode: "IN",
    countryName: "India",
    appVisibility: "hidden",
    ownershipState: "programmatic",
    claimState: "unclaimed",
    publicPage: {
      slug: "bhag-run-club",
      citySlug: "delhi-ncr",
      canonicalPath: "/organizers/delhi/bhag-run-club/",
      publishStatus: "qa",
      indexStatus: "noindex",
      robots: "noindex, follow",
      seoTitle: "Bhag Club | Delhi organizer profile | Catch",
      seoDescription:
        "Unclaimed Catch profile for Bhag Club. Delhi evidence still needs review.",
    },
    provenance: {
      origin: "scraper",
      sourceConfidence: "medium",
      verificationStatus: "sourceBacked",
    },
    publicProfile: {
      headline: "Bhag Club running community in Delhi NCR",
      summary:
        "Bhag Club appears to be both a running community and an activewear brand. The Delhi profile should stay noindex until city-specific public evidence is verified.",
      sourceSummary:
        "Official site and public event evidence support the brand/community identity.",
      formats: ["Community run", "Training program"],
      fitNotes: [
        "Brand plus community profile",
        "May need national organizer model",
      ],
      missingEvidence: [
        "Delhi-specific event source",
        "Owner contact",
        "Media permission",
      ],
    },
  },
};

export const retentionPoints = [
  {label: "M0", value: 100},
  {label: "M1", value: 58},
  {label: "M2", value: 41},
  {label: "M3", value: 33},
  {label: "M4", value: 27},
  {label: "M5", value: 21},
];

export const hostGrowth = [
  {label: "Jan", value: 4},
  {label: "Feb", value: 7},
  {label: "Mar", value: 11},
  {label: "Apr", value: 14},
  {label: "May", value: 19},
  {label: "Jun", value: 23},
];

export const eventRows = [
  {
    event: "South Delhi social 5K",
    host: "Delhi Run Club",
    fill: "94%",
    checkIn: "81%",
    rating: "4.6",
    gmv: "INR 38k",
    risk: "low",
  },
  {
    event: "Bandra coffee walk",
    host: "Mumbai Miles",
    fill: "76%",
    checkIn: "69%",
    rating: "4.2",
    gmv: "INR 24k",
    risk: "watch",
  },
  {
    event: "Indiranagar mixer",
    host: "Bengaluru Social",
    fill: "100%",
    checkIn: "88%",
    rating: "4.8",
    gmv: "INR 52k",
    risk: "low",
  },
];
