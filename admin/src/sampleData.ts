import {AdminOverviewResponse} from "./types";

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
