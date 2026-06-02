export interface AdminOverviewMetric {
  id: string;
  label: string;
  value: number;
  unit?: string;
}

export interface AdminQueueItem {
  id: string;
  title: string;
  detail: string;
  status: string;
  createdAt: string | null;
  targetPath: string;
}

export interface AdminOverviewResponse {
  generatedAt: string;
  timezone: "UTC";
  metrics: AdminOverviewMetric[];
  queues: {
    safetyReports: AdminQueueItem[];
    moderationFlags: AdminQueueItem[];
    eventSafetyReports: AdminQueueItem[];
    accessApplications: AdminQueueItem[];
    paymentIssues: AdminQueueItem[];
  };
  dataQuality: Array<{
    id: string;
    label: string;
    state: "ok" | "warning" | "blocked";
    detail: string;
  }>;
}

export type DataMode = "sample" | "live";

export type AccessApplicationDecision = "approve" | "deny";

export interface AdminDecideAccessApplicationPayload {
  applicationUid: string;
  decision: AccessApplicationDecision;
  note?: string | null;
  cohortId?: string | null;
}

export interface AdminDecideAccessApplicationResponse {
  applicationUid: string;
  decision: AccessApplicationDecision;
  status: "approvedForProfile" | "notSelectedYet";
}
