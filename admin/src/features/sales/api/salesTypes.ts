export type SalesResearchStatus =
  | "new" | "needs_research" | "ready_for_review" | "qualified"
  | "benchmark_only" | "no_fit" | "archived";

export type SalesTaskStatus = "open" | "completed" | "cancelled";
export type SalesTaskKind = "research" | "reply" | "follow_up" | "demo" |
  "pilot" | "duplicate_review" | "opt_out" | "service_commitment";
export type SalesActivityType = "note" | "reply" | "call" | "demo" |
  "pilot" | "correction";

export interface SalesAccountSummary {
  organizerId: string;
  name: string;
  city?: string | null;
  market?: string | null;
  eventTypes?: string[];
  researchStatus: SalesResearchStatus;
  fitLabel?: string | null;
  stage?: string | null;
  assignedOwnerUid?: string | null;
  nextAction?: string | null;
}

export interface SalesAccount {
  organizerId: string;
  revision: number;
  researchStatus: SalesResearchStatus;
  assignedOwnerUid?: string | null;
  summary?: string | null;
  nextAction?: string | null;
}

export interface SalesOrganizerSummary {
  name: string;
  city?: string | null;
  market?: string | null;
  eventTypes?: string[];
  appVisibility?: string | null;
  claimStatus?: string | null;
}

export interface SalesActivity {
  activityId: string;
  type: SalesActivityType;
  occurredAt: string;
  note: string;
}

export interface SalesTask {
  taskId: string;
  organizerId: string;
  kind: SalesTaskKind;
  title: string;
  dueAt: string | null;
  ownerUid: string;
  status: SalesTaskStatus;
  revision: number;
  reason?: string | null;
}

export interface SalesOpportunity {
  opportunityId: string;
  organizerId: string;
  motion: string;
  stage: string;
  ownerUid: string;
  nextStep: string | null;
  nextStepAt: string | null;
  revision: number;
}

export interface SalesAccountDetail {
  account: SalesAccount;
  organizerSummary: SalesOrganizerSummary;
  activities: SalesActivity[];
  opportunities: SalesOpportunity[];
  tasks: SalesTask[];
  customValues?: SalesCustomFieldValue[];
}

export type SalesCustomFieldType = "string" | "number" | "boolean" | "date" | "enum";

export interface SalesCustomFieldDefinition {
  fieldId: string;
  label: string;
  type: SalesCustomFieldType;
  recordType: "account";
  helpText?: string | null;
  enumOptions?: string[];
  revision: number;
}

export interface SalesCustomFieldValue {
  fieldId: string;
  value: string | number | boolean | null;
  revision: number;
}

export interface SalesCreateCustomFieldInput {
  requestId: string;
  field: Pick<SalesCustomFieldDefinition,
    "fieldId" | "label" | "type" | "recordType" | "helpText" | "enumOptions">;
}

export interface SalesSetCustomFieldValueInput {
  organizerId: string;
  requestId: string;
  expectedRevision: number;
  fieldId: string;
  value: string | number | boolean;
}

export interface SalesPage<T> {
  rows: T[];
  nextCursor: string | null;
}

export interface SalesListAccountsInput {
  limit?: 25 | 50;
  cursor?: string;
  query?: string;
  ownerUid?: string;
  researchStatus?: SalesResearchStatus;
}

export interface SalesListTasksInput {
  limit?: 25 | 50;
  cursor?: string;
  status?: SalesTaskStatus;
  ownerUid?: string;
}

export interface SalesListOpportunitiesInput {
  limit?: number;
  cursor?: string;
  stage?: string;
  ownerUid?: string;
}

export type SalesInboundStatus = "needs_identity_review" | "linked" | "dismissed";

export interface SalesInboundIntent {
  intentId: string;
  revision: number;
  status: SalesInboundStatus;
  fullName: string;
  city: string | null;
  createdAt: string;
  organizerId: string | null;
  evidenceStatus: "self_reported";
  hostApplication: Record<string, unknown> | null;
}

export interface SalesListInboundIntentsInput {
  limit?: number;
  cursor?: string;
  status?: SalesInboundStatus;
}

export interface SalesLinkInboundIntentInput {
  intentId: string;
  organizerId: string;
  requestId: string;
  expectedRevision: number;
}

export interface SalesUpdateAccountInput {
  organizerId: string;
  requestId: string;
  expectedRevision: number;
  patch: Partial<Pick<SalesAccount,
    "researchStatus" | "assignedOwnerUid" | "summary" | "nextAction">>;
}

export interface SalesUpsertTaskInput {
  organizerId: string;
  taskId?: string;
  requestId: string;
  expectedRevision: number;
  task: Pick<SalesTask, "kind" | "title" | "dueAt" | "ownerUid" | "status">;
}

export interface SalesUpsertOpportunityInput {
  organizerId: string;
  opportunityId?: string;
  requestId: string;
  expectedRevision: number;
  fields: Pick<SalesOpportunity,
    "motion" | "stage" | "ownerUid" | "nextStep" | "nextStepAt">;
}

export interface SalesRecordActivityInput {
  organizerId: string;
  requestId: string;
  type: SalesActivityType;
  occurredAt: string;
  note: string;
  opportunityId?: string;
}

export interface SalesCreateAccountInput {
  organizerId: string;
  requestId: string;
}
